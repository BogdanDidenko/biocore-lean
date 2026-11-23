# Notice: third-party data and their terms

This repository contains data copied from public databases. Each stays under its own terms, as found on 2026-11-22.

| Source | What is used here | Where | Terms as stated by the source |
|---|---|---|---|
| ChEBI, release 257 (EMBL-EBI), http://www.ebi.ac.uk/chebi | formulas and charges of chemical entities | `BioCore/Data/Monomers.lean`, `BioCore/Library/Reactions/Species*.lean`, `results/rx_species.tsv`, `data_monomers_chebi257.tsv` | Creative Commons Attribution 4.0 International (licence file of the release: `sources/chebi_LICENSE.txt`) |
| Rhea, release 143 (SIB Swiss Institute of Bioinformatics), https://www.rhea-db.org | master reactions: participants, coefficients, status | `BioCore/Library/Reactions/Chunk*.lean`, `results/rx_results.parquet` | Creative Commons Attribution 4.0 International (Rhea "License & Disclaimer" page); data are provided for research, educational and informational purposes, not for medical use |
| NCBI genetic code tables, `gc.prt` version 4.6 | translation tables 1 and 2 | `sources/ncbi_gc.prt`, `BioCore/Data/GeneticCodes.lean` | NCBI states that it places no restrictions on the use or distribution of its molecular data, and that submitters of original data may claim rights NCBI cannot assess |
| RefSeq and MANE release 1.5 (NCBI and EMBL-EBI) | coding sequences and annotated proteins of MANE Select and MANE Plus Clinical transcripts | generated record files (release archive), seven record files under `BioCore/Library/Genes/Rec/`, `BioCore/Library/Genes/Chain.lean`, `results/gn_*` | same NCBI statement; the MANE README carries no licence statement of its own |
| Human mitochondrial genome NC_012920.1 (RefSeq) | 13 protein-coding genes | as above | same NCBI statement |

A data definition in a Lean file is an assumption copied from the source. The Lean kernel checks what follows from it. It does not check that the formula or sequence describes the real molecule.

Please cite the sources when you reuse these data: ChEBI (Hastings et al., Nucleic Acids Research 2016, doi:10.1093/nar/gkv1031), Rhea (Bansal et al., Nucleic Acids Research 2022, doi:10.1093/nar/gkab1016), MANE (Morales et al., Nature 2022, doi:10.1038/s41586-022-04558-8).
