
#!/usr/bin/env bash
set -euo pipefail

# Automated tests for FASTQ validation
# Project: RNA-seq Analysis Pipeline

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VALIDATOR="$PROJECT_DIR/analysis/scripts/01_validate_fastq.sh"

TEST_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TEST_DIR"' EXIT

R1="$TEST_DIR/test_1_subsampled.fastqsanger"
R2="$TEST_DIR/test_2_subsampled.fastqsanger"
LOG="$TEST_DIR/test_output.log"

# Generate a valid paired-end FASTQ dataset
create_valid_fastq() {

    cat > "$R1" <<'EOF'
@read001/1
ACGT
+
IIII
@read002/1
TGCA
+
IIII
EOF

    cat > "$R2" <<'EOF'
@read001/2
TGCA
+
IIII
@read002/2
ACGT
+
IIII
EOF
}

# Test that valid data are accepted
expect_success() {
    local name="$1"

    if "$VALIDATOR" "$TEST_DIR" > "$LOG" 2>&1; then
        echo "PASS: $name"
    else
        echo "FAIL: $name"
        cat "$LOG"
        exit 1
    fi
}

# Test that invalid data are rejected
expect_failure() {
    local name="$1"

    if "$VALIDATOR" "$TEST_DIR" > "$LOG" 2>&1; then
        echo "FAIL: $name (invalid data accepted)"
        exit 1
    fi

    if ! grep -Eq 'ERROR:|FAIL:' "$LOG"; then
        echo "FAIL: $name (no validation diagnostic)"
        cat "$LOG"
        exit 1
    fi

    echo "PASS: $name"
}

# Verify script syntax before testing
bash -n "$VALIDATOR"

echo "Running FASTQ validator tests..."
echo

# Test 1: Valid FASTQ
create_valid_fastq
expect_success "Valid FASTQ accepted"

# Test 2: Incorrect pairing
create_valid_fastq
sed -i 's/@read002\/2/@wrong002\/2/' "$R2"
expect_failure "Pairing mismatch detected"

# Test 3: Invalid header
create_valid_fastq
sed -i '1s/^@/!/' "$R1"
expect_failure "Invalid FASTQ header detected"

# Test 4: Incorrect quality length
create_valid_fastq
sed -i '4s/IIII/III/' "$R1"
expect_failure "Sequence-quality mismatch detected"

# Test 5: Incomplete FASTQ record
create_valid_fastq
sed -i '$d' "$R2"
expect_failure "Incomplete FASTQ record detected"

# Test 6: Missing mate file
create_valid_fastq
rm "$R2"
expect_failure "Missing R2 file detected"

echo
echo "All six FASTQ validation tests passed."
