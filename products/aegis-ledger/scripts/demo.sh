#!/usr/bin/env bash
set -euo pipefail
BASE_URL="${BASE_URL:-http://localhost:8080}"
TENANT="11111111-1111-1111-1111-111111111111"
LEDGER="22222222-2222-2222-2222-222222222222"
CLEARING="33333333-3333-3333-3333-333333333333"
CUSTOMER="44444444-4444-4444-4444-444444444444"
MERCHANT="55555555-5555-5555-5555-555555555555"
NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

curl -fsS -X POST "$BASE_URL/v1/transactions" \
  -H 'Content-Type: application/json' \
  -H "X-Tenant-Id: $TENANT" \
  -H 'Idempotency-Key: demo-deposit-1' \
  -d "{\"ledgerId\":\"$LEDGER\",\"currency\":\"CAD\",\"reference\":\"demo-deposit\",\"effectiveAt\":\"$NOW\",\"entries\":[{\"accountId\":\"$CLEARING\",\"direction\":\"DEBIT\",\"amountMinor\":10000},{\"accountId\":\"$CUSTOMER\",\"direction\":\"CREDIT\",\"amountMinor\":10000}]}"
echo

curl -fsS -X POST "$BASE_URL/v1/transactions" \
  -H 'Content-Type: application/json' \
  -H "X-Tenant-Id: $TENANT" \
  -H 'Idempotency-Key: demo-purchase-1' \
  -d "{\"ledgerId\":\"$LEDGER\",\"currency\":\"CAD\",\"reference\":\"demo-purchase\",\"effectiveAt\":\"$NOW\",\"entries\":[{\"accountId\":\"$CUSTOMER\",\"direction\":\"DEBIT\",\"amountMinor\":2500},{\"accountId\":\"$MERCHANT\",\"direction\":\"CREDIT\",\"amountMinor\":2500}]}"
echo
