# A checked core for cell biology: design note (version 0.1, 2026-11-21)

## Aim

A small core in which a statement about a cell is either derived from stated axioms and accepted by a
proof checker, or not accepted. No score, no held-out data, no dependence on cell counts. It covers
less than the earlier count language (CSL 1.0), and everything it accepts is checked.

The foundation is chemistry, with sequences on top:

- **Chemistry layer.** Molecules have an exact composition (atoms of each element, and charge).
  A reaction is accepted only if it creates and destroys nothing.
- **Sequence layer.** DNA, RNA and protein are sequences; making them is a reaction of the chemistry
  layer, so the two layers are one system.

It is written in Lean 4 (release 4.36.0), so the checker is Lean's own kernel.

## What has to be trusted

1. **The Lean kernel.**
2. **The definitions**: what a composition, a reaction, "balanced", "reachable", a genetic code and
   "decodes to" mean. They are short and are listed at the top of each file.
3. **The data axioms**: formulas and charges copied from ChEBI release 257, and the codon tables copied
   from NCBI `gc.prt` version 4.6. The kernel checks what follows from them, not that they describe
   real molecules.
4. **The copying script** (`tools/gen_data.py`), which is outside the kernel. It regenerates the two
   data files byte for byte, and the codon rows are checked inside Lean against the NCBI letters.

## Three levels of checking, never mixed

| Level | How it is checked | Called |
|---|---|---|
| K | Lean kernel, standard axioms only | verified |
| N | compiled evaluation (`native_decide`), trusts the compiler | computed and certified by the compiler |
| X | output of a compiled program | computed, not proved |

Version 0.1 contains level K only.

## What exists now (version 0.1)

All of it builds in about 3 seconds; no `sorry`, no `native_decide`, no added axioms. The theorems
depend only on Lean's three standard axioms (`propext`, `Quot.sound`, `Classical.choice`).

General theorems, each for every input:

- **A finite check decides balance.** Checking the elements that occur in a reaction is equivalent to
  balance over every element and charge (`balanced_of_check`, `check_of_balanced`). So each reaction
  is either proved balanced or proved unbalanced.
- **Pathways.** Any combination of balanced reactions is balanced (`pathNet_balanced`).
- **Conservation.** A state reached by firing balanced reactions, one at a time and never using a
  molecule that is absent, has exactly the atoms and charge of the starting state (`reach_conserves`);
  so a state with a different amount of any element cannot be reached (`not_reach_of_net_ne`).
- **Templated synthesis.** For every sequence of every length, making the polymer from its activated
  building blocks is balanced (`elongation_balanced`), given one balanced step per kind of building
  block. Instances: RNA from nucleoside triphosphates, DNA from deoxynucleoside triphosphates, and
  peptides from amino acids (`transcription_balanced`, `replication_balanced`, `peptide_balanced`).
  The step facts (4 + 4 + 21 cases) are checked by the kernel from the ChEBI formulas.
- **Sequences.** Transcription is injective; reverse complement is its own inverse.

Decoding a coding sequence (`decodeCDS`) returns either the one protein it spells or a reason for
rejection (not whole codons, empty, bad start, internal stop at a position, no stop). Kernel-checked
facts about the standard code: 61 sense codons; stops UAA, UAG, UGA; start codons UUG, CUG, AUG;
the code is not injective; UGA is tryptophan in vertebrate mitochondria.

Negative controls (must fail, and do): RNA synthesis with water as by-product instead of diphosphate
is proved unbalanced; a wrong protein for a coding sequence is proved wrong.

Size: Core 178 lines, Polymer 55, Sequence 128, CentralDogma 111.

## What it does not do

- **No amounts, rates or regulation.** It says what can and cannot happen, not how much or when.
- **Peptide synthesis is a net condensation.** The route through aminoacyl-tRNA with its ATP and GTP
  cost is not modelled yet.
- **No splicing, no modified residues, no recoding.** Selenoproteins, non-standard starts and
  frameshifts will be rejected by the standard code until explicit rules are added.
- **A reaction being balanced does not mean it happens.** That a cell has an enzyme for it is an
  axiom with a source, to be added per organism.

## Prior work found (three searches, not a literature review)

- Chemistry and chemical physics in Lean: adsorption theory, thermodynamics, kinematics
  (Digital Discovery 2024, volume 3, page 264; arXiv:2210.12150).
- The central dogma in Lean 4: transcription and translation as functions, redundancy of the code,
  injectivity of transcription (arXiv:2610.36343, October 2026).
- Stoichiometric consistency of metabolic models, defined and tested outside proof assistants
  (10.1093/bioinformatics/btn425).

Not found in these searches: the two layers joined (synthesis of every sequence as a balanced
reaction), a kernel-checked library at database scale, and proof-carrying statements about what a
cell can or cannot make. That is a statement about three searches, not a novelty claim.

## Next stages

1. **Reaction library.** Every Rhea reaction, with ChEBI formulas, classified as proved balanced,
   proved unbalanced, or not expressible (with the reason). Rhea curates balance itself, so the
   expected result is agreement; the product is a checked base to build on and the list of what the
   kernel cannot yet express (polymers of unspecified length, generic groups).
2. **Gene library.** Every human MANE Select coding sequence decoded and compared with its annotated
   protein; rejections listed by reason (selenocysteine, non-AUG start, frameshift, mitochondrial code).
3. **Capability certificates.** Reactions an organism can carry out, as axioms with their gene and
   source; then "this cell can make X from this medium" proved by an explicit pathway, and "cannot
   make X" proved by an invariant (a closed set of reachable species). A first target with a known
   answer: the essential amino acids of human cells.
4. **Later:** energy and thermodynamic direction, then amounts (steady-state fluxes as exact rational
   certificates), then stochastic kinetics.

## Where it runs

Development checks take seconds and run in the local sandbox. Library builds with thousands of
theorems run on Kaggle CPU notebooks, as in the earlier programme.
