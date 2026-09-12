#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

cleanup() {
  if [[ "${AEGIS_CDC_CLEANUP:-true}" == "true" ]]; then
    docker compose --profile eventing down -v --remove-orphans >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

bash infrastructure/debezium/prepare-cdc.sh

tenant_id="$(python3 -c 'import uuid; print(uuid.uuid4())')"
ledger_id="$(python3 -c 'import uuid; print(uuid.uuid4())')"
customer_id="$(python3 -c 'import uuid; print(uuid.uuid4())')"
merchant_id="$(python3 -c 'import uuid; print(uuid.uuid4())')"
idempotency_key="cdc-smoke-$(python3 -c 'import uuid; print(uuid.uuid4())')"

docker compose exec -T postgres psql -v ON_ERROR_STOP=1 -U aegis_admin -d aegis <<SQL
INSERT INTO tenants(id, name) VALUES ('$tenant_id', 'CDC Smoke Tenant');
INSERT INTO ledgers(id, tenant_id, name, currency)
VALUES ('$ledger_id', '$tenant_id', 'CDC CAD Ledger', 'CAD');
INSERT INTO accounts(
  id, tenant_id, ledger_id, account_type, operational_role, normal_balance,
  currency, negative_policy, posted_balance_minor)
VALUES
  ('$customer_id', '$tenant_id', '$ledger_id', 'LIABILITY', 'CUSTOMER_FUNDS', 'CREDIT', 'CAD', 'DISALLOW_NEGATIVE', 1000),
  ('$merchant_id', '$tenant_id', '$ledger_id', 'LIABILITY', 'MERCHANT_PAYABLE', 'CREDIT', 'CAD', 'ALLOW_NEGATIVE', 0);
SQL

request_file="$(mktemp)"
response_file="$(mktemp)"
trap 'rm -f "$request_file" "$response_file"; cleanup' EXIT

cat > "$request_file" <<JSON
{
  "ledgerId": "$ledger_id",
  "currency": "CAD",
  "reference": "cdc-smoke-purchase",
  "effectiveAt": "2026-09-12T04:00:00Z",
  "entries": [
    {"accountId": "$customer_id", "direction": "DEBIT", "amountMinor": 100},
    {"accountId": "$merchant_id", "direction": "CREDIT", "amountMinor": 100}
  ]
}
JSON

http_code="$(curl -sS -o "$response_file" -w '%{http_code}' \
  -X POST http://localhost:8080/v1/transactions \
  -H 'Content-Type: application/json' \
  -H "X-Tenant-Id: $tenant_id" \
  -H "Idempotency-Key: $idempotency_key" \
  --data-binary "@$request_file")"

if [[ "$http_code" != "201" ]]; then
  echo "Expected HTTP 201 from ledger posting, got $http_code" >&2
  cat "$response_file" >&2
  exit 1
fi

transaction_id="$(python3 - "$response_file" <<'PY'
import json, sys
with open(sys.argv[1], encoding='utf-8') as fh:
    print(json.load(fh)['transactionId'])
PY
)"

projection_count=0
for _ in $(seq 1 60); do
  projection_count="$(docker compose exec -T postgres \
    psql -U aegis_admin -d aegis -tAc \
    "SELECT count(*) FROM account_activity_projection WHERE tenant_id='$tenant_id' AND transaction_id='$transaction_id'" \
    | tr -d '[:space:]')"
  if [[ "$projection_count" == "2" ]]; then
    break
  fi
  sleep 1
done

if [[ "$projection_count" != "2" ]]; then
  echo "CDC smoke failed: projection did not converge to two journal lines." >&2
  docker compose logs connect app kafka --tail=200 >&2 || true
  exit 1
fi

customer_balance="$(docker compose exec -T postgres \
  psql -U aegis_admin -d aegis -tAc \
  "SELECT balance_after_minor FROM account_activity_projection WHERE tenant_id='$tenant_id' AND transaction_id='$transaction_id' AND account_id='$customer_id'" \
  | tr -d '[:space:]')"
merchant_balance="$(docker compose exec -T postgres \
  psql -U aegis_admin -d aegis -tAc \
  "SELECT balance_after_minor FROM account_activity_projection WHERE tenant_id='$tenant_id' AND transaction_id='$transaction_id' AND account_id='$merchant_id'" \
  | tr -d '[:space:]')"
processed_events="$(docker compose exec -T postgres \
  psql -U aegis_admin -d aegis -tAc \
  "SELECT count(*) FROM projection_processed_events WHERE tenant_id='$tenant_id'" \
  | tr -d '[:space:]')"

[[ "$customer_balance" == "900" ]] || { echo "Expected customer projection 900, got $customer_balance" >&2; exit 1; }
[[ "$merchant_balance" == "100" ]] || { echo "Expected merchant projection 100, got $merchant_balance" >&2; exit 1; }
[[ "$processed_events" == "1" ]] || { echo "Expected one processed event, got $processed_events" >&2; exit 1; }

# Replay the same HTTP command. Business idempotency must return the original transaction
# and must not create a second outbox event.
replay_code="$(curl -sS -o /tmp/aegis-cdc-replay.json -w '%{http_code}' \
  -X POST http://localhost:8080/v1/transactions \
  -H 'Content-Type: application/json' \
  -H "X-Tenant-Id: $tenant_id" \
  -H "Idempotency-Key: $idempotency_key" \
  --data-binary "@$request_file")"
[[ "$replay_code" == "200" ]] || { echo "Expected replay HTTP 200, got $replay_code" >&2; exit 1; }

outbox_count="$(docker compose exec -T postgres \
  psql -U aegis_admin -d aegis -tAc \
  "SELECT count(*) FROM outbox_events WHERE tenant_id='$tenant_id' AND aggregate_id='$transaction_id'" \
  | tr -d '[:space:]')"
[[ "$outbox_count" == "1" ]] || { echo "Expected one outbox event after replay, got $outbox_count" >&2; exit 1; }

echo "AegisLedger CDC smoke: PASS"
echo "PostgreSQL journal -> outbox -> Debezium -> Kafka -> idempotent projection converged correctly."
