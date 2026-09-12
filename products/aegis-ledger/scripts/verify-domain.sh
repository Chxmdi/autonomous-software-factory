#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/target/jdk-smoke"
rm -rf "$OUT"
mkdir -p "$OUT"
find "$ROOT/aegis-domain/src/main/java" "$ROOT/aegis-application/src/main/java" -name '*.java' -print0 \
  | xargs -0 javac --release 21 -d "$OUT"
javac --release 21 -cp "$OUT" -d "$OUT" "$ROOT/verification/DomainSmokeMain.java"
java -ea -cp "$OUT" DomainSmokeMain
