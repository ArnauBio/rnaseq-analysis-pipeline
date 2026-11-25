
#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VALIDATOR="$PROJECT_DIR/analysis/scripts/01_validate_fastq.sh"

TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

echo "Running FASTQ validator tests..."

# Test 1: Valid paired-end FASTQ

cat > "$TEST_DIR/test_1_subsampled.fastqsanger" <<'EOF'
@read001/1
ACGT
+
IIII
@read002/1
TGCA
+
IIII
EOF

cat > "$TEST_DIR/test_2_subsampled.fastqsanger" <<'EOF'
@read001/2
TGCA
+
IIII
@read002/2
ACGT
+
IIII
EOF

if "$VALIDATOR" "$TEST_DIR"; then
    echo "PASS: Valid FASTQ files accepted"
else
    echo "FAIL: Valid FASTQ files rejected"
    exit 1
fi

# Test 2: Introduce a pairing mismatch

sed -i 's/@read002\/2/@wrong002\/2/' \
    "$TEST_DIR/test_2_subsampled.fastqsanger"

if "$VALIDATOR" "$TEST_DIR"; then
    echo "FAIL: Invalid pairing was accepted"
    exit 1
else
    echo "PASS: Pairing mismatch detected"
fi

echo "All initial tests passed."
