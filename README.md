
# RNA-seq Analysis Pipeline

**A reproducible, reference-based RNA-seq workflow for gene expression analysis in *Drosophila melanogaster*.**

## Overview

This project aims to develop a reproducible computational workflow for processing RNA-seq data, from raw sequencing reads to differential gene expression and biological interpretation.

The workflow is being developed independently as part of a bioinformatics portfolio, using publicly available sequencing data.

**Project status:** In development — initial setup and data acquisition.

## Biological Question

How does RNA interference-mediated depletion of the *pasilla* gene affect gene expression in *Drosophila melanogaster* cells?

## Dataset

The project uses public RNA-seq data from the Pasilla experiment described by Brooks et al. (2011), available through NCBI GEO (GSE18508).

The initial workflow development uses paired-end training data for:

| Sample | Condition | Sequencing |
|---|---|---|
| GSM461177 | Untreated | Paired-end |
| GSM461180 | Pasilla RNAi | Paired-end |

These two samples are used for testing and learning, not for definitive differential-expression inference.

Dataset source: https://zenodo.org/records/6457007

## Planned Workflow

1. **Data acquisition and validation:** Download public FASTQ files and verify sample metadata.
2. **Quality control:** Assess sequencing quality using FastQC and MultiQC.
3. **Preprocessing:** Evaluate the need for adapter and quality trimming.
4. **Read alignment:** Align reads to the appropriate reference genome using a splice-aware aligner.
5. **Gene quantification:** Generate gene-level count matrices.
6. **Differential expression:** Analyze biological replicates using DESeq2.
7. **Visualization and interpretation:** Generate PCA plots, heatmaps, volcano plots and biological summaries.

## Technologies

- Linux / Bash
- FastQC and MultiQC
- SAMtools
- Splice-aware read alignment
- featureCounts
- R and DESeq2
- Git and GitHub

Exact software versions and dependencies will be recorded as the workflow is implemented.

## Repository Structure

```text
rnaseq-analysis-pipeline/
├── data/
│   ├── raw/
│   └── metadata/
├── reference/
├── scripts/
├── results/
│   ├── qc/
│   ├── alignment/
│   ├── counts/
│   └── differential_expression/
├── figures/
├── logs/
├── docs/
├── .gitignore
└── README.md
```

## Reproducibility

Raw sequencing files, downloaded reference files, and large intermediate outputs are excluded from Git.

Data accessions, analysis scripts, software dependencies, parameters, and execution instructions will be documented as the project progresses.

## Current Progress

- [x] Initialize the GitHub repository
- [x] Create the project directory structure
- [x] Download the initial RNA-seq dataset
- [x] Create sample metadata
- [x] Implement FASTQ structural validation
- [x] Implement paired-end synchronization
- [x] Add validation logging
- [x] Complete automated validation tests
- [ ] Perform FastQC and MultiQC analysis
- [ ] Prepare reference genome and annotation
- [ ] Implement read alignment
- [ ] Generate gene-level count matrices
- [ ] Perform differential expression analysis
- [ ] Interpret biological results
- [ ] Finalize reproducibility documentation


## References

- Brooks AN et al. (2011). Conservation of an RNA regulatory map between Drosophila and mammals. *Genome Research*. https://doi.org/10.1101/gr.108662.110
- Galaxy Training Network: https://training.galaxyproject.org/training-material/topics/transcriptomics/tutorials/ref-based/tutorial.html
- Public training dataset: https://doi.org/10.5281/zenodo.6457007

## Author

ArnauBio — Molecular Biology & Bioinformatics

GitHub: https://github.com/ArnauBio
  


## FASTQ Data Validation

### Overview

The initial stage of the RNA-seq workflow implements structural and paired-end synchronization checks to verify the consistency of sequencing data before downstream quality control and alignment.

The validation module is implemented in Bash and AWK:

`analysis/scripts/01_validate_fastq.sh`

### Validation Procedures

The script performs the following checks:

1. **File discovery:** Identifies paired-end FASTQ files and checks that corresponding mate files exist.
2. **FASTQ structure:** Verifies sequence headers, separator lines, complete records, and matching sequence-quality string lengths.
3. **Mate identification:** Checks the expected `/1` and `/2` read identifier suffixes.
4. **Paired-end synchronization:** Compares corresponding R1 and R2 identifiers in their original order.
5. **Error handling:** Returns a nonzero exit status when validation fails.

Paired-end reads are processed sequentially to avoid storing complete read identifier arrays in memory.

### Execution

From the project root:

```bash
./analysis/scripts/01_validate_fastq.sh
```

To capture a timestamped validation log:

```bash
mkdir -p logs
set -o pipefail

./analysis/scripts/01_validate_fastq.sh 2>&1 | \
    tee "logs/fastq_validation_$(date +%Y%m%d_%H%M%S).log"
```

### Validation Results

The initial paired-end training dataset passed the implemented structural and synchronization checks.

| Sample | Condition | Validated read pairs | Status |
|---|---|---:|---|
| GSM461177 | Untreated | 1,057,657 | PASS |
| GSM461180 | Pasilla RNAi | 1,226,483 | PASS |
| **Total** | | **2,284,140** | **PASS** |

These results establish consistency under the implemented validation rules. They do not establish sequencing quality or guarantee the absence of every possible FASTQ formatting error.

### Limitations and Next Steps

The validator currently targets the filename and mate-identifier conventions used by the selected Pasilla training dataset.

Further development includes automated tests using deliberately malformed FASTQ records, additional integrity checks, and more comprehensive validation of sequence content.

The next analytical stage will assess sequencing quality using FastQC and MultiQC.