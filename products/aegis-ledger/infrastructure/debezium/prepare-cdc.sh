#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

SECRET_FILE="infrastructure/debezium/debezium.properties"
SECRET_TEMPLATE="${SECRET_FILE}.example"
CONNECTOR_FILE="infrastructure/debezium/aegis-outbox-connector.json"

if [[ ! -f "$SECRET_FILE" ]]; then
  cp "$SECRET_TEMPLATE" "$SECRET_FILE"
fi

# Start the local eventing stack. The application runs Flyway before becoming healthy,
# which guarantees the outbox table exists before publication setup below.
docker compose --profile eventing up -d --build postgres kafka app connect

wait_for_url() {
  local url="$1"
  local label="$2"
  for _ in $(seq 1 120); do
    if curl -fsS "$url" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  echo "Timed out waiting for $label at $url" >&2
  return 1
}

wait_for_url "http://localhost:8080/actuator/health" "AegisLedger"
wait_for_url "http://localhost:8083/connectors" "Debezium Connect"

# The CDC user is intentionally not the application user. The admin/table owner grants
# only the table read privilege needed by Debezium and creates the publication explicitly.
docker compose exec -T postgres \
  psql -v ON_ERROR_STOP=1 -U aegis_admin -d aegis \
  -c "GRANT SELECT ON TABLE public.outbox_events TO aegis_cdc;"

publication_exists="$(docker compose exec -T postgres \
  psql -U aegis_admin -d aegis -tAc \
  "SELECT 1 FROM pg_publication WHERE pubname = 'aegis_outbox_pub'" | tr -d '[:space:]')"

if [[ "$publication_exists" != "1" ]]; then
  docker compose exec -T postgres \
    psql -v ON_ERROR_STOP=1 -U aegis_admin -d aegis \
    -c "CREATE PUBLICATION aegis_outbox_pub FOR TABLE public.outbox_events;"
fi

# PUT is idempotent: it creates the connector if absent and updates its configuration if present.
tmp_config="$(mktemp)"
trap 'rm -f "$tmp_config"' EXIT
python3 - "$CONNECTOR_FILE" "$tmp_config" <<'PY'
import json
import sys
source, target = sys.argv[1:]
with open(source, encoding="utf-8") as fh:
    payload = json.load(fh)
with open(target, "w", encoding="utf-8") as fh:
    json.dump(payload["config"], fh)
PY

curl -fsS \
  -X PUT \
  -H 'Content-Type: application/json' \
  --data-binary "@$tmp_config" \
  http://localhost:8083/connectors/aegis-outbox/config >/dev/null

for _ in $(seq 1 60); do
  state="$(curl -fsS http://localhost:8083/connectors/aegis-outbox/status \
    | python3 -c 'import json,sys; print(json.load(sys.stdin)["connector"]["state"])' 2>/dev/null || true)"
  if [[ "$state" == "RUNNING" ]]; then
    echo "AegisLedger CDC connector is RUNNING."
    exit 0
  fi
  if [[ "$state" == "FAILED" ]]; then
    curl -fsS http://localhost:8083/connectors/aegis-outbox/status || true
    exit 1
  fi
  sleep 1
done

echo "Debezium connector did not reach RUNNING state." >&2
curl -fsS http://localhost:8083/connectors/aegis-outbox/status || true
exit 1
