# BioCore reaction library (track "Reactions")

Every master reaction of Rhea release 143, read with ChEBI release 257 formulas and charges, and
classified by the BioCore 0.1 kernel: for each reaction inside the grammar there is one theorem,
`rhea_<id>_balanced : Balanced rhea_<id>` or `rhea_<id>_unbalanced : ¬ Balanced rhea_<id>`, proved by
`decide` and accepted by the Lean kernel.

## Build

Unpack the frozen kernel archive (`biocore_v0_1.tgz`), unpack this archive into its `biocore/`
directory (it only adds files: `BioCore/Library/Reactions/`, `tools/rx_gen.py`, `docs/`), put the
Lean 4.36.0 `bin` directory on `PATH`, and run

    lake build +BioCore.Library.Reactions.All

No kernel file and no lakefile is changed; the library is built through Lake's module target.

## Files

| File | Content |
|---|---|
| `Basic.lean` | hand-written helper lemmas; pseudo-quantity numbers; `Decidable (Feasible …)` |
| `Species00.lean` … , `Species.lean` | generated: one `Species` per ChEBI accession used by Rhea (namespace `BioCore.Rhea`) |
| `Chunk0001.lean` … | generated: 300 reactions per file, each with its one theorem; the list of the file's balanced reactions |
| `Balanced.lean` | generated: `balancedLibrary` and `balancedLibrary_all : ∀ r ∈ balancedLibrary, Balanced r` |
| `KernelSpecies.lean` | generated: kernel species equal the library species of the same accession |
| `Statements.lean` | hand-written: glycolysis through `pathNet_balanced`, a `Reach` derivation, an impossibility by conservation |
| `All.lean` | root of the library |
| `tools/rx_gen.py` | the generator (untrusted; it copies data and predicts which statement to emit) |
| `docs/` | the pre-declared choices and their amendment |

Data: Rhea (CC BY 4.0, https://www.rhea-db.org), ChEBI (CC BY 4.0, http://www.ebi.ac.uk/chebi, release 257).
A species definition is a data axiom: the kernel checks what follows from the formula and charge, not
that they describe the real molecule. Quantities: 0 charge, 1–118 atomic numbers, 1000 `R`, 1001 `X`,
1002 `A` (generic groups, conserved as counts).
