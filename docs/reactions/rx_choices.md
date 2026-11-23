# rx_choices.md — pre-declared choices, track "Reactions" (prefix rx), BioCore 0.1

Written 2026-11-21, before any Rhea reaction was parsed or classified and before any ChEBI formula was
parsed by the generator. Rules below are not changed afterwards; any later change is a separate dated
amendment file that states what was already known when it was written.

## 0. What was known when this file was written

- The frozen kernel (all files of `KERNEL_SHA256.txt`, hashes verified, local build passes).
- Output of one Kaggle notebook (`rx-sources-look`, version 1) that downloaded the sources and printed
  file layout only: directory listings, release numbers, sha256, column names, the first few records of
  each file, the list of distinct RDF tag names, a handful of example RDF blocks (reaction 10000, two
  generic compounds, two polymer compounds, two participants with a location, coefficient definitions),
  and the set of characters that occur in the ChEBI formula column (characters only, no counts).
- Local development checks on toy reactions typed by hand from kernel species: `decide` and
  `decide +kernel` both prove `Balanced r` / `¬ Balanced r`; `Feasible` needs a `Decidable` instance
  (the kernel defines it as a plain `def`); `lake build +BioCore.Library.Reactions.All` builds library
  modules with the frozen `lakefile.toml` unchanged; 200 toy theorems compile in about 2.5 s per file.
- Not known: any count of reactions per class, any count of ChEBI formulas inside or outside the grammar,
  how many ChEBI compounds have several chemical_data rows, whether any theorem fails.

## 1. Sources (pinned)

Rhea release 143 (2026-11-04, from `rhea-release.properties`). ChEBI release 257 (flat files README,
last update 2026-11-05; the two ChEBI hashes equal those in the kernel's `sources/SOURCE_SHA256.txt`).
Every later notebook downloads these files again inside Kaggle and stops if a sha256 differs.

| file | url | sha256 | bytes |
|---|---|---|---|
| `rhea-release.properties` | https://ftp.expasy.org/databases/rhea/rhea-release.properties | `3c8c07b783e683ef38ce5796eb28563981ab33975c1f83bf3b29cdf6e603f41b` | 53 |
| `rhea-directions.tsv` | https://ftp.expasy.org/databases/rhea/tsv/rhea-directions.tsv | `daeb374f4327c38808006613ca8bbef56d048f907a09ab9c55038baba2cf94f9` | 456168 |
| `rhea2ec.tsv` | https://ftp.expasy.org/databases/rhea/tsv/rhea2ec.tsv | `738662df828e9a5eb850e1d3b3e9e2b9dabd741e7ac6321765881111c6a8beb7` | 195998 |
| `rhea-relationships.tsv` | https://ftp.expasy.org/databases/rhea/tsv/rhea-relationships.tsv | `83e574d47d91b5e9db9b7a5a8c1f06a0e4a38307008e1143d30037f3fbaff0f5` | 375601 |
| `rhea2xrefs.tsv` | https://ftp.expasy.org/databases/rhea/tsv/rhea2xrefs.tsv | `0dfd8f356e13063c7df65ec752f8d17e483261074cc0947dce13795c3aa75837` | 1201884 |
| `rhea-reactions.txt.gz` | https://ftp.expasy.org/databases/rhea/txt/rhea-reactions.txt.gz | `1ee6e61236c4fb4249463ff93eac9b6e0997f584c5a5e325d1a3daec435a1a92` | 1585181 |
| `rhea.rdf.gz` | https://ftp.expasy.org/databases/rhea/rdf/rhea.rdf.gz | `8f858aff8d984d8e882b90fac0d81d6980589fb819b460da388ccb796195fa25` | 8875804 |
| `chebi_chemical_data.tsv.gz` | https://ftp.ebi.ac.uk/pub/databases/chebi/flat_files/chemical_data.tsv.gz | `431f2724c75e11d5fc8241c8297fb3b68613be262c5c094a3f4175523046b260` | 3758526 |
| `chebi_compounds.tsv.gz` | https://ftp.ebi.ac.uk/pub/databases/chebi/flat_files/compounds.tsv.gz | `66d9a9a66279e00d1f8ed001664d0efc366208d873b3693e564bd682af055893` | 6997481 |
| `lean-4.36.0-linux.tar.zst` | https://github.com/leanprover/lean4/releases/download/v4.36.0/lean-4.36.0-linux.tar.zst | `2b7ab1ed8b92d2e6abfaf41344823b510064dbc9c0260cac73eb496ab2dea6eb` | 607649028 |

Additional file used for diagnostics only (downloaded in the run, sha256 recorded there):
ChEBI `secondary_ids.tsv.gz` (same folder, release 257).

Formulas and charges are taken from ChEBI release 257 `chemical_data.tsv.gz` only. The copies of
formula and charge inside the Rhea RDF are used for a diagnostic comparison (level X) and never for a
Lean term.

## 2. Scope

One record per row of `tsv/rhea-directions.tsv`, identified by column `RHEA_ID_MASTER`. Directional and
bidirectional identifiers are carried as columns, not as records. The count is stated after the run.
Reactions that the RDF marks Obsolete or Preliminary stay in scope if they are rows of that file; the
status is a column. Master reactions present in the RDF but absent from `rhea-directions.tsv` are
counted and reported as outside scope.

## 3. Reading a reaction (source: `rdf/rhea.rdf.gz`)

All `rdf:Description` blocks are merged by subject (one subject may be split over several blocks).
For master M: sides are the objects of `rh:side` (`M_L` = left, `M_R` = right). A side holds its
participants through predicates `rh:contains<suffix>`; the coefficient is the `rh:coefficient` literal of
that predicate's own definition (the generic `rh:contains` predicate carries no coefficient and is used
only to check that no participant is missed). A participant points to a compound by `rh:compound` and
may have `rh:location` (In / Out). Compound kinds by `rdfs:subClassOf`:

- `SmallMolecule`: its ChEBI identifier is the object of `rh:chebi`, else an `rh:accession` that starts
  with `CHEBI:`.
- `Generic…` (macromolecule with reactive parts; accession `GENERIC:`): the participant is represented by
  its reactive parts (`rh:reactivePart`), each a ChEBI entry; every reactive part becomes one term with
  the participant's coefficient. The unspecified remainder of the macromolecule is not modelled (it is
  taken to be the same on both sides, which is also how Rhea writes these reactions). Flag
  `macromolecule_reactive_part`.
- `Polymer` (accession `POLYMER:`, `rh:polymerizationIndex`): not expressible.

## 4. Classes

Every record ends in exactly one of: `PROVED_BALANCED` (level K), `PROVED_UNBALANCED` (level K),
`NOT_EXPRESSIBLE` (with a reason code). The three counts are asserted to sum to the scope.

### NOT_EXPRESSIBLE reason codes, in priority order

The primary reason code of a record is the first code in this list that applies to it; every code that
applies is also stored (`all_reasons`), with a detail string.

1. `malformed_record` — no RDF description, fewer or more than two sides, or a side with no participant,
   or a participant without a compound.
2. `symbolic_coefficient` — a coefficient that is not a decimal integer (N, 2n, N+1, N-1, any other text).
3. `non_integer_coefficient` — a numeric coefficient that is not a positive integer.
4. `polymer_participant` — a participant whose compound is of kind Polymer.
5. `generic_without_reactive_part` — a Generic compound with no reactive part.
6. `participant_without_chebi_id` — a small molecule or reactive part with no ChEBI identifier, or a
   compound of a kind not listed in section 3.
7. `chebi_id_absent` — the ChEBI accession is not a row of `compounds.tsv.gz` of release 257
   (secondary identifiers are not followed; whether `secondary_ids.tsv.gz` lists it is a diagnostic column).
8. `chebi_no_formula` — the accession exists but no `chemical_data` row with a non-empty formula.
9. `chebi_ambiguous_data` — several `chemical_data` rows that do not agree (rule in section 5).
10. `chebi_no_charge` — formula present, charge empty or not an integer.
11. `formula_has_brackets` — the formula contains any of `( ) [ ] { }` (repeat units, indexed groups,
    isotope labels).
12. `formula_unknown_token` — the formula has no brackets but does not parse under the grammar of
    section 5 (the first offending text is recorded).
13. `kernel_did_not_accept` — the record is inside the grammar but the kernel accepted neither statement
    under the procedure of section 8.

## 5. Grammar of an expressible formula

```
formula    = part , { "." , part } ;
part       = [ multiplier ] , item , { item } ;
multiplier = positive decimal integer ;
item       = symbol , [ count ] ;
count      = positive decimal integer ;
symbol     = one of the 118 element symbols (H … Og, the list in the kernel's tools/gen_data.py)
           | "R" | "X" ;
```

Tokenisation is the kernel's: a symbol is one capital letter optionally followed by one lower-case
letter, read greedily (`[A-Z][a-z]?`), then digits. A token whose symbol is not in the table makes the
formula `formula_unknown_token` (no fallback to a shorter symbol). Leading/trailing white space is
stripped; nothing else is rewritten. No length limit of any kind.

Meaning: the amount of a symbol is the sum over parts of multiplier × counts (dot-separated parts add).
Quantity numbers: element → atomic number (1 … 118); charge → 0; `R` → 1000; `X` → 1001. `R` and `X` are
ChEBI's generic group and generic halogen; each is treated as a conserved pseudo-quantity, as the kernel
documents for numbers from 1000 on. The map is injective (118 distinct atomic numbers, 0, 1000, 1001);
the generator asserts it and the library states it as a kernel-checked fact about the two pseudo-quantity
numbers. Any other non-element symbol (for example D, T, A, Z, or a symbol with digits/superscripts) is
not expressible. Balance in `R`/`X` means equal counts of generic groups on both sides, not that the
groups are the same group.

Lean term for a species: pairs (quantity, amount) in order of first occurrence in the formula, amounts
of a repeated symbol summed, then `(0, charge)` if the charge is not 0 — the same convention as the
kernel's `Data/Monomers.lean`.

ChEBI lookup: accession → `compounds.tsv.gz` row (`chebi_accession`) → `chemical_data.tsv.gz` rows with
that `compound_id` and a non-empty formula. One row, or several rows with identical (formula, charge)
text: use it. Several rows with different text: if every row parses under this grammar and all give the
same composition and the same integer charge, use it (flag `chebi_rows_agree_after_parsing`); otherwise
`chebi_ambiguous_data`. No row is preferred by status or by the autogenerated flag.

Coefficients: a positive decimal integer. Left side negative, right side positive.
Compartments (In/Out) are not modelled: the location is dropped, the reaction is expressible, flag
`compartments_ignored`.

## 6. Generated Lean

- Namespace `BioCore.Rhea` (the kernel's own species stay in `BioCore.Chebi`).
- Species: one `def c<number> : Species` per ChEBI accession that is used by at least one in-scope
  reaction and whose formula and charge are inside the grammar; name string = accession, a space, and the
  ChEBI `ascii_name` (else `name`), with backslashes removed, double quotes replaced by single quotes and
  any character outside printable ASCII replaced by `?`. Files of 2,000 species sorted by number,
  `BioCore/Library/Reactions/Species<kk>.lean`, all imported by `Species.lean`.
- Reaction: `def rhea_<master id> : FSum := [...]`, terms in this order: left side then right side;
  within a side by Rhea compound number, then location (none, In, Out); reactive parts of a generic
  compound in the order of their identifiers. Terms are not merged: a species may occur on both sides.
- One theorem per expressible reaction: `theorem rhea_<id>_balanced : Balanced rhea_<id> := by decide`
  or `theorem rhea_<id>_unbalanced : ¬ Balanced rhea_<id> := by decide`, whichever the generator's own
  integer arithmetic predicts. The generator is untrusted; only the kernel's acceptance counts.
- Chunks: expressible reactions sorted by master id, 300 per file,
  `BioCore/Library/Reactions/Chunk<nnnn>.lean`.
- Addition beyond the brief (generated, no new `decide`): per chunk a list of its reactions with a
  `_balanced` theorem and a theorem that every member is balanced, assembled from the individual
  theorems; `Balanced.lean` concatenates them into `balancedLibrary` with
  `balancedLibrary_all : ∀ r ∈ balancedLibrary, Balanced r`. If this addition fails to build it is
  dropped and reported; it does not affect the classification.
- Hand-written files: `Basic.lean` (helper lemmas, pseudo-quantity facts, `Decidable (Feasible …)`),
  `KernelSpecies.lean` (the 61 kernel species equal the library species of the same accession, where the
  library has them), `Statements.lean` (the three statements of section 10).
- No kernel file is edited. The library is built with the frozen `lakefile.toml` through the module
  target `lake build +BioCore.Library.Reactions.All`.

## 7. Compute and order of work

1. Kaggle notebook M (measure): generate everything, build kernel + species, compile chunk 1 twice
   (`decide`, `decide +kernel`), report seconds. Rule fixed now: the library uses plain `decide`; it
   switches as a whole to `decide +kernel` only if plain `decide` fails on chunk 1 for resource reasons
   or the projected 4-core wall time of the whole library exceeds 4 hours (recorded as an amendment).
2. Kaggle notebook B (build): generate; compile every chunk with `lake env lean` in a pool of 4, one
   result file per chunk as it finishes (return code, seconds, messages); apply section 8 to failures;
   then, in a clean directory holding the untouched frozen kernel archive plus the library archive,
   run `lake build +BioCore.Library.Reactions.All` and time it; then the axioms audit (section 9).
   The final classes are taken from that clean build.
3. Raw outputs are saved as artifacts before any aggregation.
4. At most one running notebook; CPU only; notebooks of at most about 5 hours; if the build does not fit
   in one notebook, chunk results are carried by `kernel_sources` and reused only for chunk files with an
   identical sha256.

## 8. When the kernel does not accept a theorem, or a build fails

- A chunk that fails is not dropped. Its messages are read; each failing theorem is identified by name.
- Per failing theorem, in this order: (i) the same statement by `decide +kernel`; (ii) the same statement
  with `set_option maxRecDepth 100000` and `set_option maxHeartbeats 0`; (iii) the opposite statement by
  `decide`, then by `decide +kernel` (acceptance of the opposite statement means the generator's
  pre-check was wrong: a finding, reported with the record); (iv) if nothing is accepted:
  `NOT_EXPRESSIBLE` / `kernel_did_not_accept`, with the messages kept.
- A failure that is not about one theorem (syntax of a generated file, a name clash, the toolchain) is a
  generator defect: it is fixed in the generator, the fix is described in the report, and everything is
  regenerated; classification rules do not change.
- `native_decide` and `sorry` are never used. Level N and level X results are never called verified.

## 9. Axioms audit

`#print axioms` on every hand-written theorem and on a random sample of 400 generated theorems:
all generated theorem names are sorted by sha256 of the text `rx-audit-2026-11-21:` + name, and the
first 400 are taken. In addition an audit of every generated theorem is attempted in the same notebook
(an extra; if it does not finish, the sample stands and this is reported). The union of axioms is
reported. A theorem whose axioms are not within {propext, Quot.sound, Classical.choice} is not level K
and is listed.

## 10. Hand-written statements (all level K)

(a) Glycolysis from glucose to pyruvate if every step is `PROVED_BALANCED`. Steps: the ten enzyme steps
of the Embden–Meyerhof–Parnas pathway as given in standard biochemistry textbooks (hexokinase 2.7.1.1,
glucose-6-phosphate isomerase 5.3.1.9, 6-phosphofructokinase 2.7.1.11, fructose-bisphosphate aldolase
4.1.2.13, triose-phosphate isomerase 5.3.1.1, glyceraldehyde-3-phosphate dehydrogenase 1.2.1.12,
phosphoglycerate kinase 2.7.2.3, phosphoglycerate mutase 5.4.2.11 or 5.4.2.12, enolase 4.2.1.11,
pyruvate kinase 2.7.1.40). The Rhea master for a step is chosen from `rhea2ec.tsv` rows with that EC
number: the reaction whose species connect it to the neighbouring steps; if several, the lowest master
id. If the chosen reactions do not connect through identical ChEBI species (anomers, generic entries),
further library reactions that connect them are added and named, or the net conversion is stated with
the unconnected species left in it; this is decided after the classification exists and is described in
the report (it does not touch the classification). The net conversion is written out as an explicit
formal sum, shown to have the same count of every species as the pathway, and proved balanced through
`pathNet_balanced`.
(b) One `Reach` derivation of a small state through at least 3 library reactions, `Feasible` by `decide`.
(c) One impossibility through `not_reach_of_net_ne`, over `balancedLibrary` if that list builds,
otherwise over the reactions of (a).

## 11. Level X diagnostics (never used to classify)

Imbalance vector of each `PROVED_UNBALANCED` reaction (quantity → net amount, right minus left) and
`imbalance_abs_sum` (sum of absolute values); the 10 smallest by (abs_sum, number of quantities off,
master id) are quoted from the Rhea entry. Rhea's own `rh:isChemicallyBalanced` flag. Whether the
ChEBI-257 composition of a species equals the one written in the Rhea RDF. Whether the ChEBI multiset
of the `EQUATION` line in `txt/rhea-reactions.txt.gz` equals the one read from the RDF.

## 12. Deviations

Anything processed less than, or other than, the above — a record left unclassified, a chunk not built,
a sample smaller than declared, a source file with another sha256, a rule applied differently — is
declared with its count. Results from reduced coverage are provisional.
