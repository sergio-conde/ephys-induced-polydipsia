# Electrophysiological Markers of Compulsive Behavior in a SIP Model

## Overview

This repository contains the analysis pipeline for an electrophysiology project investigating the neural correlates of compulsive behavior using the **Schedule-Induced Polydipsia (SIP)** model in rats. The pipeline processes local field potentials (LFPs) and single-unit spiking activity recorded simultaneously from the **orbitofrontal cortex (OFC)** and the **striatum**, with the goal of identifying electrophysiological markers associated with the **development and expression of compulsive behaviors**.

Recordings were obtained via chronically implanted tetrodes, and behavioral data were collected through Med-PC boxes during SIP sessions. Behavioral data processing relies on a companion toolbox, [medpc-behavior](https://github.com/sergio-conde/medpc-behavior), developed in parallel by the same author.

## Scientific background

Schedule-induced polydipsia is a well-established behavioral model used to study the emergence of compulsive-like responding in rodents. By combining detailed behavioral tracking with multi-site electrophysiological recordings, this project aims to characterize how activity and coordination between the OFC and striatum evolve as compulsive drinking behavior develops, and how these patterns relate to its expression across SIP sessions.

## Repository structure

```
.
├── example_data
├── example_data
├── matlab
    ├── behavior/         # Parsing and analysis of Med-PC box outputs (SIP session behavior)
    ├── lfp/              # LFP preprocessing, frequency-domain analysis, and synchrony markers
    ├── spikes/           # Spike sorting and post-processing
    │   ├── ofc/          # Cell classification: pyramidal vs. interneuron
    │   └── striatum/     # Cell classification: MSN vs. FSI
    ├── rate_analysis/     # Firing rate analysis by cell type and behavioral epoch
    ├── coordination/      # Spike-LFP coordination markers (e.g., phase-locking, coherence)
    ├── utils/             # Shared helper functions
    └── docs/              # Additional documentation, pipeline diagrams, etc.
```

## Pipeline stages

1. **Behavioral analysis** — Parses raw Med-PC box outputs to extract SIP-relevant behavioral measures (e.g., drinking patterns, schedule-induced responses) across sessions. This stage relies on [medpc-behavior](https://github.com/sergio-conde/medpc-behavior), a companion MATLAB toolbox developed in parallel for parsing and analyzing Med-PC outputs.
2. **LFP analysis** — Preprocessing, frequency-domain analysis (e.g., power spectra, band-limited power), and synchrony markers between OFC and striatal LFPs.
3. **Spike sorting** — Isolation of single units from tetrode recordings, performed using [WaveClus](https://github.com/csn-le/wave_clus).
4. **Cell classification**
   - OFC: pyramidal neurons vs. interneurons
   - Striatum: medium spiny neurons (MSN) vs. fast-spiking interneurons (FSI)
5. **Rate analysis** — Firing rate characterization per cell type, related to behavioral events/epochs.
6. **Spike–LFP coordination** — Markers of coordination between spiking activity and LFP oscillations (e.g., phase-locking, spike-field coherence).

## Requirements

- MATLAB (tested on R2020a or above)
- MATLAB Signal Processing Toolbox
- [WaveClus](https://github.com/csn-le/wave_clus) — used for spike sorting
- [Fieldtrip] (https://github.com/fieldtrip) — used for spectral and rste analysis
- [medpc-behavior](https://github.com/sergio-conde/medpc-behavior) — used for behavioral data parsing

## Data availability

This repository contains **code only**. Raw electrophysiological and behavioral data are not included due to their size and are stored on a separate institutional server. Data are available from the corresponding author upon reasonable request.
## Usage

*(To be expanded as the pipeline matures — e.g., example commands, expected input file formats, and how to run each stage.)*

## Status

🚧 This pipeline is under active development as part of an ongoing research project. Structure and documentation will be updated as components are completed.

## Citation

If you use this pipeline, please cite:

> *(Citation to be added upon publication.)*

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## Author

Developed by Sergio Conde-Ocazionez, as part of research conducted at the Neuromodulation & Behavior group, Netherlands Institute for Neuroscience, Amsterdam.
Contact: [sconde.ocazionez@gmail.com](mailto:sconde.ocazionez@gmail.com) · [ORCID](https://orcid.org/0000-0002-8290-5502) · [Google Scholar](https://scholar.google.com/citations?user=MlP-zs0AAAAJ&hl=es) · [LinkedIn]
