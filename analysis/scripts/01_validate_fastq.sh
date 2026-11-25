
#!/usr/bin/env bash
set -euo pipefail

# FASTQ structural and paired-end validation
# Project: RNA-seq Analysis Pipeline

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RAW_DIR="${1:-PROJECT_DIR/data/raw}"

echo "=================================="
echo "  RNA-seq FASTQ Validation"
echo "=================================="

shopt -s nullglob

r1_files=("$RAW_DIR"/*_1_subsampled.fastqsanger)
r2_files=("$RAW_DIR"/*_2_subsampled.fastqsanger)

if (( ${#r1_files[@]} == 0 )); then
    echo "ERROR: No R1 FASTQ files found." >&2
    exit 1
fi

if (( ${#r1_files[@]} != ${#r2_files[@]} )); then
    echo "ERROR: R1/R2 file counts differ." >&2
    exit 1
fi

for r1 in "${r1_files[@]}"; do

    r2="${r1/_1_subsampled.fastqsanger/_2_subsampled.fastqsanger}"

    if [[ ! -f "$r2" ]]; then
        echo "ERROR: Missing mate for $(basename "$r1")" >&2
        exit 1
    fi

    sample=$(basename "$r1" _1_subsampled.fastqsanger)

    echo
    echo "Sample: $sample"

    awk -v mate="$r2" '
    function check_record(line, position, side,    id) {
        if (position == 1) {
            if (line !~ /^@/) {
                print "ERROR: Invalid FASTQ header" > "/dev/stderr"
                errors++
            }

            if (side == 1 && line !~ /\/1$/)
                errors++

            if (side == 2 && line !~ /\/2$/)
                errors++

            return
        }

        if (position == 2) {
            if (side == 1)
                len1 = length(line)
            else
                len2 = length(line)
        }

        if (position == 3 && line !~ /^\+/) {
            print "ERROR: Invalid separator" > "/dev/stderr"
            errors++
        }

        if (position == 4) {
            if (side == 1 && length(line) != len1)
                errors++

            if (side == 2 && length(line) != len2)
                errors++
        }
    }

    {
        pos = (NR - 1) % 4 + 1

        # Read the corresponding line from R2
        result = getline line2 < mate

        if (result != 1) {
            print "ERROR: R2 ended early or could not be read" > "/dev/stderr"
            errors++
            exit 1
        }

        check_record($0, pos, 1)
        check_record(line2, pos, 2)

        if (pos == 1) {
            id1 = $0
            id2 = line2

            sub(/\/1$/, "", id1)
            sub(/\/2$/, "", id2)

            if (id1 != id2) {
                printf "ERROR: Read pair mismatch at pair %d\n", pairs + 1 > "/dev/stderr"
                errors++
            }

            pairs++
        }
    }

    END {
        if (NR == 0 || NR % 4 != 0)
            errors++

        if (getline extra < mate > 0)
            errors++

        close(mate)

        if (errors > 0) {
            printf "FAIL: %d validation errors\n", errors > "/dev/stderr"
            exit 1
        }

        printf "PASS: %d read pairs validated\n", pairs
    }' "$r1"

done

echo "All samples passed FASTQ validation."

