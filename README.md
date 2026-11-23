
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

- [x] Create initial project directory structure
- [x] Download initial paired-end training data
- [ ] Validate sample metadata and downloaded files
- [ ] Implement sequencing quality control
- [ ] Prepare reference genome and annotation
- [ ] Implement read alignment and quantification
- [ ] Perform differential expression analysis
- [ ] Generate figures and scientific interpretation
- [ ] Finalize reproducible workflow documentation

## References

- Brooks AN et al. (2011). Conservation of an RNA regulatory map between Drosophila and mammals. *Genome Research*. https://doi.org/10.1101/gr.108662.110
- Galaxy Training Network: https://training.galaxyproject.org/training-material/topics/transcriptomics/tutorials/ref-based/tutorial.html
- Public training dataset: https://doi.org/10.5281/zenodo.6457007

## Author

ArnauBio — Molecular Biology & Bioinformatics

GitHub: https://github.com/ArnauBio
  
