# BioCore 0.1

Kernel-checked bookkeeping for molecular biology in Lean 4 (release 4.36.0, no Mathlib).

A statement here is either derived from stated assumptions and accepted by the Lean kernel, or it is not in the library. The price is scope: the core covers element and charge balance of reactions and the reading of the genetic code, and nothing about what happens in a cell.

## Status (2026-11-23)

- **Kernel 0.2: complete.** One file added to kernel 0.1, `BioCore/Firing.lean`: a firing rule that requires every molecule on the left side of a reaction (so an enzyme written on both sides must be present), and states compared by content. No kernel 0.1 file is edited. See `docs/kernel_0_2.md`; hashes in `KERNEL_0_2_SHA256.txt`.
- **Site core: complete** (`BioCore/Library/Sites/Base.lean`, `Data.lean`, `SiteProtein.lean`): a protein as a sequence plus site states with a derived formula, and the theorem that a one-site modification is balanced on the protein exactly when it is balanced on the residue.
- **Named-site library: partial, work in progress.** Present: `Sites/Marks.lean` (chain ends and bridges as site states, a general theorem per kind of change) and `Sites/Enzymes.lean` (writers and erasers under the strict firing rule; nothing is reachable from a state where no reaction can fire). Not done: residue lemmas generated from Rhea, human Swiss-Prot sites checked against their sequences, worked examples, the composition tool.
- **Damage and repair library: partial, work in progress.** Present: 894 Rhea records of the damage and repair classes proved balanced (`Damage/Rx01`–`Rx03`, `RxAll`); spontaneous damage reactions that Rhea does not hold, each with a refused false variant and the source for the claim that it occurs without an enzyme, which stays an assumption (`Damage/Spontaneous.lean`); general theorems on what a reaction library can and cannot undo (`Damage/General.lean`); a test of the rule for deriving residue formulas against ChEBI (`Damage/RuleTest.lean`); the choices file `docs/damage/dg_choices.md`. Not done: repair cycles with their net cost, the per-product classification "route back exists / no route back", worked examples on named proteins, time scales attached as data.
- All modules listed above build on kernel 0.2. Their 1,498 theorems depend only on `propext`, `Quot.sound` and `Classical.choice` (13 on none); there is no `sorry` and no `native_decide`. No module was left out. The partial libraries were not reviewed beyond this build and axioms check.

## What is in it

| Part | Content | Size |
|---|---|---|
| Kernel (`BioCore/Core.lean`, `Polymer.lean`, `Sequence.lean`, `CentralDogma.lean`, `Data/`) | formulas, reactions, balance and its decision procedure, pathways, reachability and conservation; templated synthesis of a linear polymer; DNA, RNA, amino acids, genetic codes, decoding of a coding sequence | 472 lines plus two generated data files |
| Reaction library (`BioCore/Library/Reactions/`) | every master reaction of Rhea release 143 with ChEBI release 257 formulas, one theorem per expressible reaction | 19,005 reactions classified |
| Gene library (`BioCore/Library/Genes/`) | every human MANE 1.5 coding sequence and the 13 mitochondrial protein genes, decoded by the kernel's `decodeCDS` and compared with the annotated protein | 19,450 records classified |

The kernel is frozen: `KERNEL_SHA256.txt` lists the hashes of its files, and the libraries add files without editing them.

## Results

**Reaction library** (details: `reports/rx_report.md`, table: `results/rx_results.parquet`)

| Class | Reactions |
|---|---|
| Proved balanced (kernel, `decide`) | 18,595 |
| Proved unbalanced (kernel, `decide`) | 6 |
| Not expressible in the kernel's grammar | 404 |

**Gene library** (details: `reports/gn_report.md`, table: `results/gn_results_without_sequences.csv.gz`)

| Class | Records |
|---|---|
| Decodes to the annotated protein (kernel, `decide +kernel`) | 19,339 |
| Rejected by the decoder, with the reason (kernel, `decide +kernel`) | 41 |
| Not expressible (non-coding transcript, no coding sequence) | 70 |

The generated theorems depend only on Lean's standard axioms (`propext`, `Quot.sound`, `Classical.choice`). There is no `sorry` and no `native_decide`.

## How to read these results

- **Agreement with Rhea and MANE is the expected outcome.** Both sources are curated, so the confirmations are a check of the library and not a finding.
- **A data definition is an assumption.** Formulas, charges, sequences and code tables are copied from the sources named in `NOTICE.md`. The kernel checks what follows from them, not that they describe the real molecule.
- **The six unbalanced reactions:** three are Preliminary records that Rhea itself flags as unbalanced; three are Approved iron-sulfur cluster reactions (RHEA:16585, 22076, 71239) where the ChEBI 257 formula carries a different hydrogen count from Rhea's own copy. That is a mismatch between two databases.
- **1,249 reactions balance trivially** because the same species stand on both sides (mostly transport). The kernel has no compartments, so these theorems carry no information.
- **A rule was changed after counts were known.** ChEBI's symbol `A` (generic hydrogen acceptor) was admitted as a pseudo-element after the generator had shown that 477 reactions were excluded by it, and before any of them reached the kernel. Under the original rules the counts are 18,119 / 5 / 881 (`docs/reactions/rx_choices_amendment_1.md`).
- **The 41 rejected coding sequences** are known biology the kernel does not have: 25 selenoproteins (UGA read as selenocysteine), 9 annotated start codons outside the code table, 7 stop codons completed by polyadenylation.
- **A looseness:** 27 accepted records start with CUG or UUG, which the standard table lists as possible starts; the kernel accepts such a first codon without evidence that it is used.
- **The gene library root file was never compiled as one tree.** The build was split over two sessions; every module the root imports was compiled.

## What is not covered

Amounts, rates, time, regulation, splicing, the tRNA route of translation (peptides are treated as net condensation), recoding, compartments, and whether a reaction occurs in a cell at all.

## Prior work

A search on 2026-11-21 and 22 (`docs/prior_work/prior_work_verdicts.md`, 361 source rows) found that the general theorems of the chemistry layer and a toy-scale central dogma have precedents:

- element balance with a proved boolean check in Coq (`CharlesCNorton/rfna-verified`);
- balance with a charge coordinate in Lean 4 (`facebookresearch/atlas-lean`);
- the genetic code with transcription and translation in Lean 4 (arXiv:2610.36343);
- reaction-network theory and kinetics in Lean 4, far broader than anything here (`marpaia/crnt-lean`, `humanfia/chemlib`);
- database-scale balance checks by ordinary programs (for example doi:10.1186/1471-2105-7-517).

Not found with that effort: a curated reaction database checked by a proof-assistant kernel, decoding of all annotated coding sequences of an organism, and a theorem that templated synthesis of any sequence is element- and charge-balanced. "Not found" is a statement about that search and its limits, which the file lists.

## Build

Put the Lean 4.36.0 `bin` directory on `PATH`.

    lake build                                    # kernel, seconds
    lake env lean Audit.lean                      # axioms of the kernel theorems
    lake build +BioCore.Library.Reactions.All     # reaction library, about 23 minutes on 4 virtual CPUs
    lake -f lakefile_gn.toml build +BioCore.Library.Genes.Chain +BioCore.Library.Genes.StopCompletion

The 19,380 generated gene record modules (325 MB of Lean text) are not in the git tree. They are in the archive `releases/biocore_gene_records_v0_1.tar.gz` in this repository (54.7 MB), together with the full results table including sequences; its sha256 is in `docs/genes/RECORDS_ARCHIVE_SHA256.txt`. Unpack it over this tree (`tar -xzf releases/biocore_gene_records_v0_1.tar.gz`), then:

    lake -f lakefile_gn.toml build BioCoreLibraryGenes     # hours; see reports/gn_report.md

## Layout

| Path | Content |
|---|---|
| `BioCore/` | kernel and libraries |
| `tools/` | generators (`gen_data.py`, `rx_gen.py`, `gn_*.py`); they copy data and predict which statement to emit, and are not trusted |
| `sources/` | NCBI code table, ChEBI README and licence, hashes of the source files |
| `docs/` | design note, rules declared before the results with their dated amendments, prior-work search |
| `reports/`, `results/` | reports and tables of the two libraries, axioms audits |

Some log archives named in the reports are not in this repository; the reports mark them.

## Licence

- **Code** (`.lean`, `.py`, `.toml` and other build files): Apache License 2.0, see `LICENSE`.
- **Text, reports and result tables written for this project:** Creative Commons Attribution 4.0 International, see `LICENSE-CC-BY-4.0.txt`.
- **Third-party data** embedded in generated files and tables stay under the terms of their sources, see `NOTICE.md`.

Copyright 2026 Bogdan Didenko.
