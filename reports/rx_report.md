# rx_report.md — BioCore 0.1 reaction library (track "Reactions", prefix rx)

Date: 2026-11-21. Kernel: BioCore 0.1 (frozen, untouched). Checker: Lean 4.36.0, no Mathlib.

Three levels are kept apart throughout. **K** = accepted by the Lean kernel with at most the three
standard axioms. **N** = `native_decide` (not used anywhere in this work). **X** = computed by a program,
not proved. Only level K is called proved.

## 1. Result in one table

Scope: **19,005 master reactions** of Rhea release 143 (one per row of `tsv/rhea-directions.tsv`).

| class | level | final rules (choices + amendment 1) | choices file unamended |
|---|---|---|---|
| PROVED_BALANCED | K | 18,595 | 18,119 |
| PROVED_UNBALANCED | K | 6 | 5 |
| NOT_EXPRESSIBLE | – | 404 | 881 |
| sum | | 19,005 | 19,005 |

Every record is in exactly one class under each rule set (asserted in code; both columns sum to the scope).
The two columns differ only by amendment 1, which admits ChEBI's symbol `A` (generic hydrogen acceptor)
as a third conserved pseudo-quantity; it was written after the generator's counts were known and before
any of the affected reactions was given to the kernel (section 9). The kernel-checked statements in the
right-hand column are a subset of those in the left-hand column.

Level K count: 18,601 reaction theorems (one per expressible reaction), all proved by plain
`decide`; no theorem was rejected, so the fallback procedure of the choices file was never used.

**Agreement with Rhea.** Rhea curates balance itself, so agreement was the expected outcome, and it is
what was found: every reaction that is inside the grammar and that Rhea flags as chemically balanced is
proved balanced, except three that involve iron–sulfur clusters whose ChEBI 257 formula differs from the
formula written in Rhea; the three Preliminary reactions that Rhea itself flags as not balanced are proved
unbalanced. This is a consistency check of two curated databases against each other through a proof
checker, not a discovery.

## 2. What was run

Sources, downloaded inside Kaggle and checked by sha256 in every notebook:

| file | sha256 | bytes | check |
|---|---|---|---|
| `rhea-release.properties` | `3c8c07b783e683ef38ce5796eb28563981ab33975c1f83bf3b29cdf6e603f41b` | 53 | pinned, equal |
| `rhea-directions.tsv` | `daeb374f4327c38808006613ca8bbef56d048f907a09ab9c55038baba2cf94f9` | 456168 | pinned, equal |
| `rhea2ec.tsv` | `738662df828e9a5eb850e1d3b3e9e2b9dabd741e7ac6321765881111c6a8beb7` | 195998 | pinned, equal |
| `rhea-reactions.txt.gz` | `1ee6e61236c4fb4249463ff93eac9b6e0997f584c5a5e325d1a3daec435a1a92` | 1585181 | pinned, equal |
| `rhea.rdf.gz` | `8f858aff8d984d8e882b90fac0d81d6980589fb819b460da388ccb796195fa25` | 8875804 | pinned, equal |
| `chebi_chemical_data.tsv.gz` | `431f2724c75e11d5fc8241c8297fb3b68613be262c5c094a3f4175523046b260` | 3758526 | pinned, equal |
| `chebi_compounds.tsv.gz` | `66d9a9a66279e00d1f8ed001664d0efc366208d873b3693e564bd682af055893` | 6997481 | pinned, equal |
| `chebi_secondary_ids.tsv.gz` | `807e476348d7418babbbf3982ec53245d98d2efa21c6cec40e0e95a79990714e` | 86794 | recorded in this run |
| `lean-4.36.0-linux.tar.zst` | `2b7ab1ed8b92d2e6abfaf41344823b510064dbc9c0260cac73eb496ab2dea6eb` | 607649028 | pinned, equal |

Rhea release 143 (2026-11-04). ChEBI release 257 (2026-11-05); the two ChEBI hashes equal those recorded
in the kernel's `sources/SOURCE_SHA256.txt`. The frozen kernel archive (sha256
`8bd9fa5a7996fd84a88e4d0444db982ea3adb6115b99138a851c1d0d0e8c3368`) was supplied to the notebooks as the
private dataset `rx-biocore-kernel`; its ten files were checked against `KERNEL_SHA256.txt` before and
after the build.

Kaggle notebooks (private, CPU, 4 vCPU Intel Xeon 2.20 GHz, 31 GB), one at a time:

| notebook | purpose | script wall time |
|---|---|---|
| `rx-sources-look` v1 | download, sha256, file layout only | 74 s |
| `rx-measure` v1 | generate; build kernel + species; chunk 1 with `decide` (29.52 s) and `decide +kernel` (20.94 s) | 263 s |
| `rx-build` v1 | generate; all 63 chunks in a pool of 4; clean build; axioms audit | 2,764 s |

Total about 0.86 hours of notebook time, i.e. about 3.4 vCPU-hours. No GPU. The Mac only drove the Kaggle
command line and moved files. Local sandbox: small Lean development checks only (listed in section 8).

Order of work: layout inspection → choices file written and hashed → generator written and tested on a
hand-made RDF sample → measurement → amendment 1 → build. The choices file ([rx_choices.md](../docs/reactions/rx_choices.md),
sha256 `237134aaa9376fbdad9c456243c295d8a2dff242747d5ba710758e9d8faaa37f`) was saved before the generator
existed; the amendment ([rx_choices_amendment_1.md](../docs/reactions/rx_choices_amendment_1.md)) before the build.

How a reaction is read: participants, sides, coefficients and compartments from `rdf/rhea.rdf.gz`
(blocks merged by subject; an identical repeated triple counts once); formulas and charges from ChEBI 257
`chemical_data.tsv.gz` only. A macromolecule participant (Rhea `GENERIC:`) is represented by its reactive
parts. As a level-X cross-check, the ChEBI multiset of each reaction was compared with the `EQUATION` line
of `txt/rhea-reactions.txt.gz`: it agrees for all 18,601 expressible
reactions (for 366 NOT_EXPRESSIBLE records the simple parser of that line does not match, which is
expected for polymer and `n` notations and was not pursued).

## 3. The library

rx_library.tgz: this repository (`BioCore/Library/Reactions/`) (sha256 `e23bec090bc989fec21075a412f83db70e77c1b0a639dcb1f648bbe7047a1fae`, 82 files).
It adds files only: `BioCore/Library/Reactions/` (77 Lean files), `tools/rx_gen.py`, `docs/`.
No kernel file and no lakefile is changed or copied: the library is built with the frozen `lakefile.toml`
through Lake's module target, `lake build +BioCore.Library.Reactions.All`.

**Clean build.** In a fresh directory holding only the unpacked frozen kernel archive plus this archive:
return code 0, 77 library modules built, 0 errors, 0 warnings,
**1,350.7 s wall** on a Kaggle CPU notebook (4 vCPU Intel Xeon 2.20 GHz, 31 GB, Linux x86_64,
Lean 4.36.0 commit 611c117). Kernel files unchanged afterwards: True.
Before that, every chunk was compiled on its own (pool of 4): 63 of 63 accepted with empty output in round 1,
82 s median per chunk when four run together (chunk 1 alone: 29.52 s).

Contents (all kernel-accepted in the clean build):

| what | count |
|---|---|
| species definitions (one per ChEBI accession, namespace `BioCore.Rhea`) | 14,413 |
| reaction definitions `rhea_<id> : FSum` | 18,601 |
| reaction theorems (`_balanced` / `_unbalanced`), by `decide` | 18,601 |
| list theorems (blocks of 20, per chunk, and `balancedLibrary_all`) | 995 |
| kernel-species identities (`BioCore.Chebi.c… = BioCore.Rhea.c…`, by `rfl`) | 57 |
| hand-written theorems: `Basic.lean` / `Statements.lean` | 8 / 10 |
| theorems in total | 19,671 |

`balancedLibrary : List FSum` holds the 18,595 proved-balanced reactions, with
`balancedLibrary_all : ∀ r ∈ balancedLibrary, Balanced r` assembled from the per-reaction theorems (an
addition beyond the brief, declared in the choices file). 57 of the kernel's 61 species occur in Rhea
reactions and are proved to be the same terms as the library's; the other four (CHEBI:29997, 30006, 30015,
46217, amino-acid residues) are not used by any in-scope reaction.

Of the 14,413 species, 1,570 carry the pseudo-quantity `R` (1000), 7 carry `X` (1001) and 2 carry `A` (1002).
The map symbol → number is injective (asserted by the generator; `pseudo_qty_separate` in `Basic.lean`
states that the three numbers differ and lie above 118). Balance in a pseudo-quantity means equal counts
of generic groups on both sides, not that the groups are the same group.

**Axioms audit** ([rx_axioms_audit.txt](../results/rx_axioms_audit.txt); `#print axioms` in the clean build):

| set | constants | union of axioms |
|---|---|---|
| declared random sample of generated reaction theorems (seeded, 400) | 400 | Classical.choice, Quot.sound, propext |
| every reaction theorem (extra) | 18,601 | Classical.choice, Quot.sound, propext |
| every hand-written declaration (`Basic.lean`, `Statements.lean`) | 30 | Classical.choice, Quot.sound, propext |
| chunk list theorems, `balancedLibrary_all`, kernel-species identities | 121 | Classical.choice, Quot.sound, propext |

Union over everything: **propext, Quot.sound, Classical.choice**. No `sorryAx`, no `Lean.ofReduceBool`.
The archive contains no `sorry`, no `native_decide` and no `axiom` declaration (text search; the word
"axiom" occurs only in header comments). The 931 block-level list theorems were not printed one by one;
they are dependencies of the 63 chunk-level theorems that were.

## 4. PROVED_UNBALANCED: all 6 records

The brief asks for the 10 with the smallest imbalance; only 6 exist, so all are shown, smallest first.
The imbalance vector (right side minus left side) is computed by the generator: **level X**. That each
reaction is unbalanced is level K. Quotes are the Rhea `rdfs:label` of the master reaction.

| reaction | Rhea status | Rhea's own balance flag | Rhea entry | imbalance (X) | sum of absolute values (X) | kind of record |
|---|---|---|---|---|---|---|
| RHEA:22076 | Approved | true | `[protein] with 2 [4Fe-4S] clusters + sulfite + 6 AH2 + 2 S-adenosyl-L-methionine = [protein] with [8Fe-9S-C] cluster + 5'-deoxyadenosine + L-methionine + 6 A + S-adenosyl-L-homocysteine + 3 H2O + 8 H(+)` | `{"H": -2}` | 2 | Approved; Rhea flags it balanced. ChEBI 257 writes the two [4Fe-4S] clusters as H4Fe4S4 and the L cluster as CH6Fe8S9; the Rhea copy has Fe4S4 and CFe8S9. Expressible only through amendment 1 (it contains AH2 / A). |
| RHEA:42456 | Preliminary | false | `4alpha-methylzymosterol = zymosterol` | `{"H": -2, "C": -1}` | 3 | Preliminary; Rhea itself flags it as not chemically balanced. One participant on each side; the right side has one C and two H fewer. |
| RHEA:16585 | Approved | true | `[[Fe-S] cluster scaffold protein carrying a second [4Fe-4S](2+) cluster] + N(6)-octanoyl-L-lysyl-[protein] + 2 oxidized [2Fe-2S]-[ferredoxin] + 2 S-adenosyl-L-methionine + 4 H(+) = [[Fe-S] cluster scaffold protein] + N(6)-[(R)-dihydrolipoyl]-L-lysyl-[protein] + 4 Fe(3+) + 2 hydrogen sulfide + 2 5'-deoxyadenosine + 2 L-methionine + 2 reduced [2Fe-2S]-[ferredoxin]` | `{"H": -4}` | 4 | Approved; Rhea flags it balanced. Three [4Fe-4S] cluster terms (two left, one right) use the ChEBI 257 formula H4Fe4S4; the Rhea copy has Fe4S4. |
| RHEA:71239 | Approved | true | `2 [3Fe-4S](0)-[protein] + 2 Fe(2+)-[Dph3] + NADH = 2 [4Fe-4S](1+)-[protein] + 2 [Dph3] + NAD(+) + H(+)` | `{"H": 6}` | 6 | Approved; Rhea flags it balanced. ChEBI 257 writes [3Fe-4S](0) as HFe3S4 and [4Fe-4S](1+) as H4Fe4S4; the Rhea copy has Fe3S4 and Fe4S4. |
| RHEA:42428 | Preliminary | false | `clavaminate = (3R,5R)-clavulanate-9-aldehyde` | `{"charge": -1, "H": -4, "N": -1, "O": 1}` | 7 | Preliminary; Rhea itself flags it as not chemically balanced. One participant on each side. |
| RHEA:33095 | Preliminary | false | `chorismate + inosine + phosphoenolpyruvate = futalosine` | `{"charge": 4, "H": -5, "C": -4, "O": -10, "P": -1}` | 24 | Preliminary; Rhea itself flags it as not chemically balanced. Three participants on the left, one on the right. |

So there are two kinds. Three are Preliminary records that Rhea already marks as unbalanced. Three are
Approved records that balance with the formulas written in Rhea but not with ChEBI release 257, because
ChEBI 257 gives hydrogen-containing formulas to five iron–sulfur cluster entries (CHEBI:33722, 33723, 33751,
47402 and 85715) where Rhea's copy has none. In all, 15 species have a ChEBI 257 composition that differs
from Rhea's copy (the five clusters, `A` / `H2A` written `R` / `H2R` in Rhea, and eight others); 507 proved-balanced
reactions contain at least one of them (476 through `A` / `H2A`, 31 others). The 15 are listed in
[rx_species.tsv](../results/rx_species.tsv) (column `differs_from_rhea_copy`). Those reactions are balanced with the
ChEBI 257 formulas, which are the only formulas the library uses. Which formula is right for a cluster is a curation question for ChEBI/Rhea and is not decided here.
Table: [rx_unbalanced.csv](../results/rx_unbalanced.csv).

## 5. NOT_EXPRESSIBLE: 404 records (final rules)

| primary reason code | count | what it means |
|---|---|---|
| `polymer_participant` | 289 | a participant is a Rhea polymer with a polymerisation index (n, n+1, n-1, …) |
| `symbolic_coefficient` | 77 | a stoichiometric coefficient is N, 2n, N+1 or N-1 |
| `chebi_no_formula` | 33 | ChEBI 257 has the entry but no formula |
| `chebi_id_absent` | 5 | the accession is not a primary identifier in ChEBI 257 |
| sum | 404 | |

The primary code is the first that applies in the declared priority order; 41 records have two codes
(`all_reasons`): 39 with a symbolic coefficient and a polymer, 2 with a polymer and a missing formula.
Under the unamended choices file there are 477 more (`formula_unknown_token`, symbol `A`).
Reason codes that were declared and never occurred: malformed_record, non_integer_coefficient,
generic_without_reactive_part, participant_without_chebi_id, chebi_ambiguous_data, chebi_no_charge,
formula_has_brackets, kernel_did_not_accept.

Examples (two per code) and what would be needed:

- **polymer_participant** (289 as primary reason; 328 records carry the code, the other 39 behind `symbolic_coefficient`). Polymerisation indices of the 660 polymer participants in those 328 records (one count per participant, not per record): n (451), n-1 (136), n+1 (56), n-2 (10), n-3 (4), n+2 (1), n-4 (1), n-5 (1).
  - RHEA:10580 — `(6S)-5,6,7,8-tetrahydrofolyl-(gamma-L-Glu)(n) + L-glutamate + ATP = (6S)-5,6,7,8-tetrahydrofolyl-(gamma-L-Glu)(n+1) + ADP + phosphate + H(+)` — polymer_participant: POLYMER:14738 (6S)-5,6,7,8-tetrahydrofolyl-(gamma-L-Glu)(n) index n
  - RHEA:10628 — `tRNA(n+1) + phosphate = tRNA(n) + a ribonucleoside 5'-diphosphate` — polymer_participant: POLYMER:17343 tRNA(n) index n
  - Needed: species whose formula depends on a natural number (a base formula plus n repeat units) and
    statements of the form `∀ n, Balanced (r n)`. See section 7, proposal 1.
- **symbolic_coefficient** (77; 38 of them with no polymer participant). Coefficient texts of the 196 participants with a symbolic coefficient in those 77 records (one count per participant, not per record): N (176), 2n (11), Nplus1 (5), Nminus1 (4).
  - RHEA:10068 — `4-O-[(D-ribitylphospho)(n)-D-ribitylphospho-(2R)-glycerylphospho]-N-acetyl-beta-D-mannosaminyl-(1->4)-N-acetyl-alpha-D-glucosaminyl di-trans,octa-cis-undecaprenyl diphosphate + n UDP-alpha-D-glucose = 4-O-[(2-beta-D-glucosyl-D-ribitylphospho)(n)-D-ribitylphospho-(2R)-glycerylphospho]-N-acetyl-beta-D-mannosaminyl-(1->4)-N-acetyl-alpha-D-glucosaminyl di-trans,octa-cis-undecaprenyl diphosphate + n UDP + n H(+)` — symbolic_coefficient: Participant_10068_compound_2309: N
  - RHEA:10256 — `[(1->4)-6-phospho-alpha-D-glucosyl](n) + n ATP + n H2O = [(1->4)-3,6-bisphospho-alpha-D-glucosyl](n) + n AMP + n phosphate + 2n H(+)` — symbolic_coefficient: Participant_10256_compound_1283: N
  - RHEA:14993 — `n malonyl-CoA + acetyl-CoA + 2n NADPH + 2n H(+) = a long-chain fatty acid + n CO2 + 2n NADP(+) + (n+1) CoA` — symbolic_coefficient: Participant_14993_compound_1264: Nplus1
  - RHEA:22896 — `n malonyl-CoA + acetyl-CoA + 2n NADPH + 2n H(+) = a long-chain fatty acyl-CoA + n CO2 + 2n NADP(+) + n CoA + H2O` — symbolic_coefficient: Participant_22896_compound_1264: N
  - Needed: the same as for polymers (coefficients linear in n).
- **chebi_no_formula** (33 as primary reason): photon CHEBI:30212 in 28 records, electron CHEBI:10545 in 3, "chemical entity" CHEBI:24431 in 2; each record has exactly one such entry. 2 further records carry this code behind `polymer_participant` (CHEBI:10545 in 1, CHEBI:30212 in 1).
  - RHEA:10732 — `firefly D-luciferin + ATP + O2 = firefly oxyluciferin + hnu + AMP + CO2 + diphosphate` — chebi_no_formula: CHEBI:30212
  - RHEA:10988 — `nitrous oxide + H2O = 2 e(-) + 2 nitric oxide + 2 H(+)` — chebi_no_formula: CHEBI:10545
  - Needed: no kernel change. A declared data rule would do: electron = empty formula with charge −1;
    photon = empty formula (the kernel has no energy, so light is invisible to it). The brief forbids taking
    formulas from elsewhere without declaring it first, so these stay NOT_EXPRESSIBLE here. "Chemical
    entity" is unspecified by nature.
- **chebi_id_absent** (5): CHEBI:87164 in 3 records, CHEBI:193521 in 2; both are listed in ChEBI 257 `secondary_ids.tsv.gz`.
  - RHEA:46976 — `(S)-6-hydroxynicotine + O2 = 6-hydroxy-N-methylmyosmine + H2O2` — chebi_id_absent: CHEBI:87164 (listed in secondary_ids)
  - RHEA:46988 — `(R)-6-hydroxynicotine + O2 = 6-hydroxy-N-methylmyosmine + H2O2` — chebi_id_absent: CHEBI:87164 (listed in secondary_ids)
  - Needed: no kernel change; a declared rule to follow secondary identifiers to their primary entry.

Flags on classified reactions (a reaction may carry several):

| flag | PROVED_BALANCED | PROVED_UNBALANCED | NOT_EXPRESSIBLE |
|---|---|---|---|
| `compartments_ignored` | 1,571 | 0 | 56 |
| `macromolecule_reactive_part` | 3,345 | 3 | 27 |
| `pseudo_quantity` | 2,598 | 2 | 0 |
| `amendment1_symbol_A` | 476 | 1 | 0 |
| `chebi_rows_agree_after_parsing` | 0 | 0 | 0 |
| `chebi257_differs_from_rhea_copy` | 507 | 3 | 0 |

`compartments_ignored`: the In/Out location is dropped, so a pure transport reaction (same species on
both sides) is balanced trivially and its theorem says nothing about transport.
`macromolecule_reactive_part`: only the reactive parts of a protein, nucleic acid or other macromolecule
are balanced; the rest of the macromolecule is assumed unchanged.
Rhea status: 18,612 Approved, 393 Preliminary in scope; 297 further RDF masters are Obsolete, are not rows of
`rhea-directions.tsv`, and are outside scope.

## 6. Hand-written statements (`Statements.lean`, all level K)

(a) **Glycolysis, alpha-D-glucose to pyruvate**, ten library reactions, all PROVED_BALANCED:
RHEA:36495 (×1), 11816 (×1), 16109 (×1), 14729 (×1), 18585 (×−1), 10300 (×2), 14801 (×−2), 15901 (×−2),
10164 (×2), 18157 (×−2); a negative number runs the Rhea equation right to left. The steps are the ten
enzyme steps of the Embden–Meyerhof–Parnas pathway as in standard biochemistry textbooks; the Rhea
reaction of each step was taken from `rhea2ec.tsv` by EC number, except step 1 (below).
`glycolysis_pathway_balanced : Balanced (pathNet glycolysis)` is obtained from `pathNet_balanced` and the
ten library theorems. The net conversion is written out,
`alpha-D-glucose + 2 ADP + 2 phosphate + 2 NAD(+) → 2 pyruvate + 2 ATP + 2 NADH + 2 H2O + 2 H(+)`;
`glycolysis_net_counts` proves that the pathway and this formal sum have the same number of molecules of
every species (all intermediates cancel), and `glycolysisNet_balanced` proves it balanced from the
pathway theorem.
Step 1 is not the EC-annotated hexokinase reaction RHEA:17825: its product is CHEBI:61548 (D-glucose
6-phosphate, anomer unspecified), and no in-scope reaction contains both CHEBI:61548 and the isomerase
substrate CHEBI:58225 (alpha-D-glucose 6-phosphate). RHEA:36495 (alpha-D-glucose + ATP = alpha-D-glucose
6-phosphate + ADP + H(+)) closes the chain; it has no EC number in `rhea2ec.tsv`. So the pathway proved
is from alpha-D-glucose, not from "D-glucose".

(b) **Reachability.** `reach_afterFourSteps`: from one alpha-D-glucose and two ATP, RHEA:36495, 11816,
16109 and 14729 fire in this order, each `Feasible` by `decide`. `afterFourSteps_counts` shows the state
reached holds one D-glyceraldehyde 3-phosphate, one dihydroxyacetone phosphate, two ADP and two H(+).
`aldolase_not_feasible_at_start` shows a step that cannot fire (¬ Feasible, by `decide`).

(c) **Impossibility.** `threePyruvate_unreachable`: through `not_reach_of_net_ne` with carbon (quantity 6)
and `balancedLibrary_all`, no sequence of reactions from the whole list of 18,595 proved-balanced
reactions leads from the starting mixture of glycolysis to the product mixture with a third pyruvate.
`carbon_from_glycolysisStart` is the positive form: every state reachable from that mixture has its 68
carbon atoms. (`Reach` fires reactions as written, left to right; conservation holds either way.)

## 7. What the kernel would need (proposals, nothing was changed)

1. **Reactions with an index n** (366 records). `FSum` is a closed list with integer coefficients and
   `Balanced` is decided by evaluation, so a reaction with a symbolic `n` is not a term the decision
   procedure can evaluate. Proposal: a repeat-unit formula `base ++ n · unit` with the lemma
   `amount (base ++ n · unit) q = amount base q + n * amount unit q`, and a theorem reducing
   `∀ n, Balanced (r n)` to two closed checks (the part constant in n and the part linear in n), in the
   style of `elongation_balanced`. This can live in a library file; putting the scaling lemma into `Core`
   would let later libraries share it.
2. **`Feasible` has no `Decidable` instance** in `Core` (it is a plain `def`). The library adds one that
   only unfolds the definition. Proposal: state the instance in `Core`.
3. **`Species` has no decidable equality**, so membership `r ∈ L` is proved by position
   (`List.Mem.head/tail`), which does not scale to `balancedLibrary`. Proposal: `deriving DecidableEq` for
   `Species`, or generated membership lemmas per reaction.
4. **Direction.** `Reach` fires a library reaction only as written. Using a reversible Rhea reaction
   backwards needs `scale (-1) r` in the library list. Proposal: a helper that closes a list under
   reversal, with the lemma that it stays balanced.
5. **Compartments.** `Species` has a name and a formula; a location is not modelled. Giving the same
   formula two names ("… (in)", "… (out)") would make `count` and `Feasible` see transport while `net`
   stays the same; that is a library convention, not a kernel change, and was declared out of scope here.
6. **Entries without a formula / secondary identifiers** (38 records): data rules, not kernel changes
   (section 5).

## 8. Failures and findings, in order

Nothing was rejected by the kernel in the two real notebooks. What failed before that:

1. `Feasible … := by decide` failed locally with "failed to synthesize Decidable (Feasible …)": the
   kernel defines `Feasible` without an instance. Fixed by the instance in `Basic.lean`.
2. Generator, on the hand-made RDF sample: a participant that occurs in two RDF blocks gave two
   `rh:compound` values. Repeated identical triples are now counted once (RDF is a set of triples). Whether
   this matters on the real file was not measured.
3. Generator, on the hand-made sample: theorem line numbers in the chunk manifest were wrong (a header
   element holds several lines), so a failure could not be attributed to its theorem. Fixed before the
   first real run; the fallback ladder was then exercised on the sample with deliberately wrong
   predictions (all steps reached, opposite statement accepted).
4. ChEBI `compounds.tsv.gz`: 14 lines have another field count under plain tab splitting (quoted fields);
   the generator falls back to CSV quoting for that file, as logged; 218,832 rows, all consistent.
5. `glycolysis_net_counts` and `glycolysis_net_amounts` by plain `decide` stopped at the elaborator's
   maximum recursion depth (local check on the ten reactions). They use `decide +kernel`; the audit shows
   the standard axioms only.
6. Chunks take about 80 s each when four are compiled together on the 4-vCPU machine, against 30 s alone;
   the whole library needs about 23 minutes there.

Local Lean development checks (macOS toolchain, seconds each): toy reactions typed from kernel species
(two files of 200 theorems, about 5 s, to choose the proof form and test the Lake module target); the
hand-made RDF sample (3 theorems); the ten glycolysis reactions with their species copied from the Kaggle
tables, to develop `Statements.lean`. No library-scale build was run locally.

## 9. Deviations

1. **Amendment 1 changes a rule after counts were known.** When it was written the generator's level-X
   counts were known (881 outside the grammar, 477 of them because of symbol `A`); no kernel result existed for
   the affected reactions. Effect: 477 reactions move from NOT_EXPRESSIBLE to a proved class (476 balanced, 1
   unbalanced). Both rule sets are reported in every table; rows carry `class_frozen_choices`.
2. **Glycolysis step 1** is RHEA:36495, not a reaction selected by EC number, and the pathway starts from
   alpha-D-glucose (amendment 1, item 3).
3. **Fewer than 10 unbalanced reactions exist** (6); all are shown.
4. `KernelSpecies.lean` is generated, not hand-written as the choices file says (amendment 1, item 2).
5. Two hand-written finite checks use `decide +kernel` instead of `decide` (section 8, item 5); level K.
6. Parsing details not written in the choices file: identical repeated RDF triples counted once; CSV
   quoting for `compounds.tsv.gz`.
7. The first local toy check compiled 400 theorems (about 5 s), more than "a handful".

No record was dropped, capped, truncated or sampled: all 19,005 master reactions are classified, all 63 chunks
were built, and the audit covers every reaction theorem.

## 10. Files

- [rx_choices.md](../docs/reactions/rx_choices.md) (hash file [rx_choices.sha256](../docs/reactions/rx_choices.sha256)), [rx_choices_amendment_1.md](../docs/reactions/rx_choices_amendment_1.md)
- [rx_results.parquet](../results/rx_results.parquet) — one row per master reaction: `rhea_id`, `class`, `reason_code`, `level`, `n_participants`,
  `flags` (and one boolean column per flag), `imbalance_X` columns, `class_frozen_choices`, theorem name, axioms, the Rhea equation, terms
- [rx_summary.csv](../results/rx_summary.csv) — counts per class and reason, for both rule sets
- rx_library.tgz: this repository (`BioCore/Library/Reactions/`) — the Lean library
- rx_build_logs.tgz (not in this repository) — clean-build log, per-chunk results, run logs, notebook scripts
- [rx_axioms_audit.txt](../results/rx_axioms_audit.txt) — `#print axioms` output
- [rx_unbalanced.csv](../results/rx_unbalanced.csv), [rx_species.tsv](../results/rx_species.tsv)
- raw Kaggle outputs, saved before aggregation: rx_raw_measure_outputs.tgz (not in this repository), rx_raw_build_outputs.tgz (not in this repository), rx_sources_look.txt (not in this repository)
