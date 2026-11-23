# Gene library for BioCore 0.1 (track gn)

Unpack this archive over the frozen BioCore 0.1 tree (it adds files only; no kernel file is in it), put the
Lean 4.36.0 `bin` directory on `PATH`, then:

    lake -f lakefile_gn.toml build BioCoreLibraryGenes     # the whole library (hours; see gn_report.md)
    lake -f lakefile_gn.toml build +BioCore.Library.Genes.Chain +BioCore.Library.Genes.StopCompletion   # seconds
    lake -f lakefile_gn.toml env lean GenesAudit.lean       # axioms of the hand-written theorems
    lake -f lakefile_gn.toml exe gn_decode in.tsv out.tsv   # level X program (computed, not proved)

`lakefile_gn.toml` is a copy of the frozen `lakefile.toml` with a library target, a program target and a
larger thread stack added; the frozen `lakefile.toml` is untouched.

| Path | Content |
|---|---|
| `BioCore/Library/Genes/Rec/<record>.lean` | one module per record: the coding strand, the annotated protein, and the kernel-checked statement (`X.decodes` or `X.rejected`), with `#print axioms` |
| `BioCore/Library/Genes/Batch/*.lean` | import lists, 250 records each, in the order they were built |
| `BioCore/Library/Genes/Chain.lean` | hand-written: INS, TP53, BRCA1 from coding strand to protein, with the balance theorems |
| `BioCore/Library/Genes/StopCompletion.lean` | stop codons completed by 3' adenines (7 records) |
| `BioCore/Library/Genes/Pack.lean` | a compact encoding and its decoder; NOT used by any statement of the library |
| `BioCore/Library/Genes/DecodeMain.lean` | the level X program: calls the kernel's `decodeCDS` on every line of a file |
| `BioCoreLibraryGenes.lean` | root: imports everything above except the program |
| `GenesAudit.lean` | `#print axioms` for every hand-written theorem |
| `tools/gn_*.py`, `tools/Chain.lean.template` | parser, independent Python decoder, module generator, session drivers |
| `gn_choices.md`, `gn_choices_amendment_*.md` | the rules declared before the results, and the dated amendments |

Record names: `NM_000546.6` is module `BioCore.Library.Genes.Rec.NM_000546_6`, with `BioCore.Genes.NM_000546_6.cds`,
`.protein` and `.decodes`. Levels: the statements in `Rec/`, `Chain.lean` and `StopCompletion.lean` are level K
(accepted by the Lean kernel, standard axioms only). The class of each record and the agreement with the
annotation for the whole scope were first computed at level X; see `gn_report.md`.
