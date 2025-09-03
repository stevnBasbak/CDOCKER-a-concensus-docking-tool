# CDOCKER – Consensus Docking Software

<p align="center">
  <img alt="cover" src="x86_64Linux2/cover.png" style="max-width:100%; height:auto;" />
</p>

<!-- Badges -->

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
[![GitHub tag](https://img.shields.io/github/v/tag/stevnBasbak/CDOCKER-a-concensus-docking-tool?sort=semver)](https://github.com/stevnBasbak/CDOCKER-a-concensus-docking-tool/tags)
[![GitHub Actions CI](https://github.com/stevnBasbak/CDOCKER-a-concensus-docking-tool/actions/workflows/ci.yml/badge.svg)](https://github.com/stevnBasbak/CDOCKER-a-concensus-docking-tool/actions)
[![GitHub Actions Docs](https://github.com/stevnBasbak/CDOCKER-a-concensus-docking-tool/actions/workflows/docs.yml/badge.svg)](https://github.com/stevnBasbak/CDOCKER-a-concensus-docking-tool/actions)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/stevnBasbak/CDOCKER-a-concensus-docking-tool/HEAD)

[![GitHub closed PRs](https://img.shields.io/github/issues-pr-closed/stevnBasbak/CDOCKER-a-concensus-docking-tool?label=closed%20PRs)](https://github.com/stevnBasbak/CDOCKER-a-concensus-docking-tool/pulls?q=is%3Apr+is%3Aclosed)
[![GitHub open PRs](https://img.shields.io/github/issues-pr/stevnBasbak/CDOCKER-a-concensus-docking-tool?label=open%20PRs)](https://github.com/stevnBasbak/CDOCKER-a-concensus-docking-tool/pulls)
[![GitHub closed issues](https://img.shields.io/github/issues-closed/stevnBasbak/CDOCKER-a-concensus-docking-tool?label=closed%20issues)](https://github.com/stevnBasbak/CDOCKER-a-concensus-docking-tool/issues?q=is%3Aissue+is%3Aclosed)
[![GitHub open issues](https://img.shields.io/github/issues/stevnBasbak/CDOCKER-a-concensus-docking-tool?label=open%20issues)](https://github.com/stevnBasbak/CDOCKER-a-concensus-docking-tool/issues)

> **CDOCKER** is a lightweight **bash-based consensus molecular docking workflow** combining AutoDock Vina (v1.2.3) and AutoDock4 search methods, plus tools for conformer generation and post-processing.

---

## Table of Contents

* [Highlights](#highlights)
* [Quick demo (one-liner)](#quick-demo-one-liner)
* [Requirements](#requirements)
* [Repository layout & Inputs](#repository-layout--inputs)
* [Quick start](#quick-start)
* [Pipeline overview](#pipeline-overview)
* [Outputs](#outputs)
* [Sample `gridsize_INPUT`](#sample-gridsize_input)
* [License & Citation](#license--citation)
* [Contributing](#contributing)
* [Contact](#contact)

---

## Highlights

* Runs **five docking strategies per ligand** (Vina with two scoring functions and AutoDock4 with multiple search algorithms).
* Minimal user interaction: provide a SMILES text file and a receptor `.pdbqt` plus grid definition and run `docking.sh`.
* Includes conformer generation (Balloon), conversion to `.pdbqt`, flexible docking workflows, and summary/analysis scripts.

---

## Quick demo (one-liner)

```bash
# From repo root (after populating INPUTS and installing required tools)
./docking.sh
```

---

## Requirements

* Linux x86\_64 (tested on Ubuntu-like environments)
* Bash (POSIX shell)
* AutoDock Vina v1.2.3
* AutoDock4 / AD4 utilities (ADFrun / autogrid4)
* MGLTools (for `prepare_*` conversions)
* Balloon (for conformer generation)
* Standard Unix utilities: `awk`, `sed`, `perl`

---

## Repository layout & Inputs

```
<repo>/
├─ codes/                 # scripts 01 to 17 (pipeline steps)
├─ INPUTS/                # put your input files here
│  ├─ molecules.smi       # SMILES strings file
│  ├─ receptor.pdbqt      # receptor in PDBQT format
│  └─ gridsize_INPUT      # grid definition
├─ ADFRsuite-1.1dev/      # AutoDock tools (user-provided)
├─ mgltools_x86_64Linux2_1.5.7/  # MGLTools (user-provided)
├─ COMFORMERS/            # generated conformers
├─ DOCKING/               # docking outputs
└─ docking.sh             # entry point
```

### What to place in `INPUTS/`

* `molecules.smi` — plain text file with SMILES strings (no stereochemistry).
* `receptor.pdbqt` — receptor file in PDBQT format.
* `gridsize_INPUT` — grid box parameters (see sample below).

---

## Quick start

1. Place required third-party tools under expected folders.
2. Add `molecules.smi`, `receptor.pdbqt`, and `gridsize_INPUT` into `INPUTS/`.
3. Make scripts executable:

```bash
chmod +x codes/*.sh
chmod +x docking.sh
```

4. Launch:

```bash
./docking.sh
```

---

## Pipeline overview

Scripts 01–17 implement the workflow:

1. **01\_smiles** — split SMILES → `.smi` files.
2. **02\_Conformers** — generate conformers with Balloon.
3. **03\_splitter** — split multi-conformer `.mol2`.
4. **04\_transformer** — prepare `.mol2` → `.pdbqt`.
5. **05\_gridtransformer.sh** — normalize grid coordinates.
6. **06\_docking\_autodockvina\_vina.sh** — dock with Vina scoring.
7. **07\_Summerizer\_ADV\_vina.sh** — summarize Vina logs.
8. **08\_docking\_autodockvina\_vinardo.sh** — dock with Vinardo scoring.
9. **09\_Summerizer\_ADV\_vinardo.sh** — summarize Vinardo logs.
10. **10\_autogrid4.sh** — precalculate AD4 grids.
    11–13. **Specifiers.sh** — generate AD4 input files for GA, LGA, LS.
11. **14\_AD4\_docker.sh** — run AD4 docking.
12. **15\_AD4\_Summerizer.sh** — summarize AD4 docking.
13. **16\_Organiser.sh** — merge ADV & AD4 results.
14. **17\_Data\_analyser.sh** — final analysis.

---

## Outputs

* `DOCKING/ADV_vina/` and `DOCKING/ADV_vinardo/` — Vina docking outputs.
* `DOCKING/AD4/` — AutoDock4 docking outputs.
* Summaries: CSV tables from `*_Summerizer.sh` scripts.
* Final merged `results_*.csv` for downstream analysis.

---

## Sample `gridsize_INPUT`

```
5ek0
spacing    0.372
npts       44 44 44
center    -48.776 -28.363 3.617
```

---

## License & Citation

This project is licensed under **Creative Commons Attribution 4.0 (CC BY 4.0)**.
If publishing results, please cite **CDOCKER** and include a link to this repository:

[CDOCKER GitHub Repository](https://github.com/stevnBasbak/CDOCKER-a-concensus-docking-tool)

> Optionally, generate a Zenodo DOI for citations.

---

## Contributing

Contributions are welcome! Suggested workflow:

1. Fork the repo.
2. Create a feature branch.
3. Add tests/docs.
4. Open a pull request.

---

## Contact

Maintainer: **Stijn De Vos** (stevnBasbak)
Computational researcher at VUB
[GitHub Profile](https://github.com/stevnBasbak)

---
