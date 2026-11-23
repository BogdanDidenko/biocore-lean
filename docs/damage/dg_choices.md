# dg_choices.md — Damage and repair library on BioCore kernel 0.2

Written 2026-11-23, before any Lean file of this track was generated or compiled and before any
classification of a reaction, cycle, species pair or site was produced. Later changes go into dated
amendments (`dg_choices_amendment_<n>.md`) with before/after text.

## 0. What was already known when this file was written

- Read: the kernel (`BioCore/Core.lean`, `Firing.lean`, `Polymer.lean`), the shared site core
  (`BioCore/Library/Sites/{Base,Data,SiteProtein}.lean`), the prototype `Events/Residue/Damage.lean`
  (statements and false variants for C19–C27, C29, all compiled on kernel 0.1 by the earlier track), the
  list of theorem names of `Events/Identity/ExSites.lean`, the event class table, the 47 literature rows
  of the time-scale table for the damage classes.
- Counted from the census and the Rhea results table (inputs, not results of this track): 906 Rhea
  release 143 master records carry at least one of the classes C19–C29, C31, C32; 894 of them are
  `PROVED_BALANCED` in the reaction library and 12 (all C24) are `NOT_EXPRESSIBLE` there. Per class
  (a record may carry several): C24 540, C29 243, C32 50, C31 47, C19 29, C21 10, C22 9, C25 8, C20 8,
  C28 7, C27 4, C26 1, C23 1.
- Looked up in ChEBI release 257 (names and formula text only): which residue species exist for the
  damage products named in the task. Present as residues: methionine S-oxide (CHEBI:15989, 44120, 45764),
  methionine sulfone (156065), S-hydroxycysteine (61973), 3-sulfinoalanine (61974, 61967), cysteate
  (141830), isoaspartate (90596), D-aspartate (29962), fructosyl-lysinium (143253), carboxymethyl-lysine
  (53015), homocitrulline (144369), 3-nitrotyrosine (155899), tyrosinyl radical (32766), allysine
  (131803), glutamic 5-semialdehyde (41433), dUMP (133902), abasic site (139095). Present only as free
  compounds: dityrosine (50607/50609), pentosidine (59951), fructosyl-valine (167955/178071),
  S-(4-hydroxynonanal-3-yl)-L-cysteine (747433). Not found as a residue: aspartyl succinimide,
  8-oxo-2'-deoxyguanosine inside a strand.
- Looked up in the Rhea results table (equation text): Rhea release 143 has no master record for DNA
  ligase (EC 6.5.1.1 or 6.5.1.2) and none for removal of 8-oxoguanine from DNA by a glycosylase; it has
  uracil-DNA glycosylase (RHEA:81455, 81459), abasic-site hydrolysis (81527), abasic-site lyase (66592),
  removal of the 5'-deoxyribose phosphate (77919, 76255), fructosamine-3-kinase (59832, 59836),
  glyoxalase I and II (19069, 25245), thioredoxin reductase (20345), glutathione reductase (11740).
- Not known: whether any statement of this track compiles; the outcome of the residue rule test; the
  classification of any damage product; the content of any UniProt record.

## 1. Scope

Additions only under `BioCore/Library/Damage/`, namespace `BioCore.Damage`, file prefix `dg`.
No kernel file, no `lakefile.toml`, no file of `BioCore/Library/Sites/` is edited.

1. **Rhea records (item 1a).** All 906 records named above. Each expressible record is restated in
   `BioCore.Damage.Rx` with the species text of `results/rx_species.tsv` and the term list of the
   `terms` column of `rx_results.parquet`, and proved again (`decide`). A separate file (`Bridge`)
   imports the reaction library and proves, for each record, that the restated term list is equal to
   `BioCore.Rhea.rhea_<id>`. The 12 not-expressible records are listed with the reaction library's
   reason and get no theorem.
2. **Spontaneous reactions not held by Rhea (item 1b).** The list of the task: methionine to sulfoxide
   and sulfone; cysteine to sulfenic, sulfinic, sulfonic acid; asparagine to aspartate and isoaspartate
   with the succinimide intermediate; aspartate isomerisation and racemisation; first glycation step
   on an N-terminal valine (the lysine step is RHEA:15665); carboxymethyl-lysine from glyoxal and from
   fructosyl-lysine; pentosidine; carbamylation of lysine and of an N-terminal valine; tyrosine
   nitration and dityrosine; carbonyls with a defined structure (allysine from lysine, glutamic
   semialdehyde from arginine and from proline); a 4-hydroxynonenal Michael adduct of cysteine; cytosine
   and 5-methylcytosine deamination in DNA (cytosine: RHEA:66604); depurination; guanine oxidation to
   8-oxoguanine; cyclobutane and (6-4) pyrimidine dimers. Reactions the prototypes proved unbalanced as
   usually written are kept in both forms (as written: proved unbalanced; corrected: proved balanced).
   Species: ChEBI release 257. Where the oxidant of an oxidation is not fixed by the source, the
   reaction is written as a net with hydrogen peroxide or dioxygen and this is stated as an assumption
   of the library in the docstring.
3. **Repair and removal cycles (item 3).** Methionine sulfoxide reductase A and B with thioredoxin and
   thioredoxin reductase; sulfiredoxin; peroxiredoxin with thioredoxin; glutathione peroxidase with
   glutathione reductase; superoxide dismutase with catalase; isoaspartyl methyltransferase with the
   spontaneous steps that follow; fructosamine-3-kinase; glyoxalase I and II; base excision repair for
   uracil and for 8-oxoguanine. Steps come from Rhea where Rhea has them; a step Rhea does not have is
   written in the library with its source and marked.
4. **Reversibility relative to the library (item 4).** General theorems, then one classification row
   per damage product of items 1b and of the Rhea damage records used in the cycles.
5. **Named sites (item 5).** Haemoglobin beta (UniProtKB P68871) glycation; one lens crystallin
   (alpha-crystallin A, P02489, or another crystallin if that record has no deamidation or oxidation
   feature); calmodulin (P0DP23) or alpha-1-antitrypsin (P01009) methionine oxidation; one cytosine
   deamination in a short stretch of the HBB coding sequence (RefSeq NM_000518.5) with base excision
   repair.
6. **Time scales (item 6).** A CSV keyed by reaction; rows copied from `ts_timescales.csv`. No statement
   about time in Lean.

## 2. Sources and releases

| What | Source | Release | Terms as stated by the source |
|---|---|---|---|
| Reactions | Rhea, via `rx_results.parquet` of the reaction library | 143 (2026-11-04) | CC BY 4.0 |
| Formulas, charges, names, ontology relations | ChEBI flat files `chemical_data.tsv.gz` (sha256 431f2724…), `compounds.tsv.gz` (66d9a9a6…), `relation.tsv.gz`, `relation_type.tsv.gz`; species already in the reaction library are copied from `results/rx_species.tsv` | 257 (2026-11-05) | CC BY 4.0 |
| Protein sequences and feature annotations | UniProtKB REST (`rest.uniprot.org/uniprotkb/<acc>.json`) | release given by the response header (2026_04 when first reached) | to be copied from the UniProt licence page into `dg_notice.md` |
| DNA sequence | RefSeq NM_000518.5 (file already in the prototype archive, sha256 c114b998…) | as fetched by the prototype track | NCBI terms, copied into `dg_notice.md` |
| Enzyme reaction text where Rhea has no record | ENZYME (`ftp.expasy.org/databases/enzyme/enzyme.dat`) | release line of the file | to be copied into `dg_notice.md` |
| Claim "occurs without an enzyme" | PubMed records (E-utilities), one per spontaneous reaction or group | PMID, DOI where given | abstracts are read, not redistributed |
| Time scales | `ts_timescales.csv` of the earlier track | as delivered | rows carry their own sources |

Hashes of every downloaded file are written to `dg_notice.md`. Nothing is typed from memory: every
species line is generated from the ChEBI files, every Rhea term list from the parquet, every sequence
and feature from the downloaded record. Literature identifiers are obtained by searching PubMed and each
is used only after its abstract has been read in this track; the read depth is recorded (`abstract`
unless full text was read).

## 3. Data rules

**R1 (amino-acid residue from the free compound).** For an alpha-amino acid or a modified amino acid
that ChEBI holds only as a free compound, the residue in a chain is the free compound minus one water,
with the same charge: formula(residue) = formula(free) − H2O, charge(residue) = charge(free). The free
form used is the one whose backbone is neutral overall (zwitterion or uncharged form) and whose side
chain is in the state wanted. For a compound that links k residues (a crosslink), k waters are removed.

**R2 (nucleotide residue from the free nucleotide).** For a 2'-deoxynucleoside 5'-monophosphate(2−),
the residue inside a strand is the free compound minus one hydroxide: formula − HO, charge + 1.

**R3 (ring closure).** The aspartyl succinimide residue is the L-aspartic acid residue (CHEBI:29958)
minus one water. This is a definition of the library, not a rule applied to a free compound.

**Test of R1 and R2 (item 2).** Test set: every pair (X, Y) in `relation.tsv.gz` with relation
`is substituent group from` (X from Y), both entries having one parsable formula and charge under the
grammar of `rx_choices.md` section 5, and the name of X ending in `residue` (any charge suffix allowed).
For each pair the rule that applies is chosen by the name of X: R2 if X is a nucleoside monophosphate
residue, otherwise R1. Outcome per pair, each stated in Lean and decided by the kernel:
`RULE_AGREES` (Balanced [(-1, Y), (1, X), (1, water)] for R1; with hydroxide for R2),
`RULE_DIFFERS_BY_HYDRONS` (not balanced, but balanced after adding k hydrons: the two entries are in
different protonation states), `RULE_DIFFERS` (anything else). All pairs are reported; every
disagreement is listed. No pair is dropped for any reason other than a missing or unparsable formula,
and those are counted.

Every species obtained by a rule carries the tag `[rule R1]`, `[rule R1 x2]`, `[rule R2]` or
`[rule R3]` at the end of its name string, and a row in `dg_species.csv` with the free compound.

**Carriers.** Rhea writes a protein participant as its reactive residues. In a state, a residue species
is therefore ambiguous between proteins. `onCarrier tag s` gives the same formula a name of its own
(`<name> @ <tag>`). A general lemma shows renaming does not change balance.

**Enzymes.** An enzyme named in a cycle is a species with its accession in the name and an empty
formula, written once on each side. That it catalyses the step is an assumption copied from the source
named in the docstring (Rhea EC number, UniProtKB catalytic-activity annotation).

**Directions.** A Rhea master record has no direction. In `Rx` each record is written left to right as
in Rhea. In a cycle a step is written in the direction of the repair; where that is the reverse of the
Rhea record the step is `scale (-1)` of it. The direction is an assumption; where UniProtKB annotates a
physiological direction for the enzyme used, it is quoted.

## 4. Statement forms

| Kind | Lean statement | False variant |
|---|---|---|
| reaction | `Balanced r` by `decide` | a variant with one term changed, `¬ Balanced` proved; the same variant claimed balanced in a must-fail file |
| reaction as usually written | `¬ Balanced r`, and `Balanced` of the corrected form | the corrected form without its correction is the false variant |
| rule pair | `Balanced` or `¬ Balanced` of the rule reaction | each disagreement is itself a refused statement |
| cycle | `Balanced (pathNet p)` through `pathNet_balanced`; `SameCounts (pathNet p) net`; cost: `count (pathNet p) "<carrier>" = k`; strict firing: `ReachSC L start end` with the enzymes in the state | a wrong cost (proved negation); the first step is not `FeasibleS` without its enzyme; a wrong end state |
| general theorem (item 4) | for all libraries and states; see section 5 | a library where the hypothesis fails and the conclusion fails (proved) |
| classification | `ROUTE_BACK`: `ReachSC Lib s t`; `NO_ROUTE_BACK`: `∀ a b, ReachS L a b → count a p ≤ count b p` | route back claimed for a product that has none (must-fail), and a derivation without its enzyme |
| named site | `Balanced (R.at P i)` through `site_mod_balanced` / `site_rxn_iff` | a position that does not hold the residue; a co-substrate left out |

## 5. Reversibility: definitions

- `Lib`: the directed library of this track = spontaneous reactions as written ++ cycle steps as written
  (enzymes on both sides).
- `RheaAll`: the list of all `BioCore.Rhea.rhea_<id>` that the reaction library defines (18,601 by its
  report), and `RheaAllRev` = each of them multiplied by −1. Built in the `Bridge` file.
- General theorems (for any library `L`): (T1) if `consumed r nm = 0` for every `r ∈ L`, then
  `ReachS L a b → count a nm ≤ count b nm`; (T2) if `S` is a set of names such that every reaction that
  has a positive net count of a name in `S` also consumes a name in `S`, and no name of `S` is present
  in `a`, then none is present in any `b` with `ReachS L a b`; (T3) both for `Reach` where the
  hypothesis allows it; (T4) a name that does not occur in a reaction is neither consumed nor produced
  by it nor by its reverse.
- Classes of outcome for a damage product `p`:
  - `ROUTE_BACK_IN_LIBRARY`: a `ReachSC Lib` derivation from a state holding the product, the carriers
    and the enzymes to a state holding the undamaged species. Level K.
  - `NO_ROUTE_BACK_IN_LIBRARY`: T1 for `Lib ++ RheaAll ++ RheaAllRev` (the product is consumed by no
    reaction of this library and occurs in no Rhea record that the reaction library defines, in either
    direction). Level K if the `Bridge` file is built; otherwise the theorem is given for `Lib` only and
    the Rhea part is a program check (level X), and the row says so. That the product is not a
    participant of the 404 records the reaction library could not express is always level X.
  - `NO_ROUTE_BACK_IN_DAMAGE_LIBRARY`: T1 holds for `Lib`, but the species occurs in at least one Rhea
    record; the records are listed. Whether one of them is a repair is not decided.
  - `REMOVED_NOT_RESTORED`: a library reaction consumes the product but no derivation to the undamaged
    species was given.
- Every such row states: relative to Rhea release 143 and this library; absence of a repair reaction in
  a database is not absence in biology.

## 6. Classes of outcome and levels

Reactions: `PROVED_BALANCED` (K), `PROVED_UNBALANCED` (K), `NOT_EXPRESSIBLE` (reason copied from the
reaction library; no level), `NOT_WRITTEN` (a species has no formula in ChEBI and no rule gives one; no
level). Cycles: `CYCLE_PROVED` (K: all four statements of section 4), `CYCLE_PARTIAL` (K for the
statements that exist; the missing ones are named). Rule pairs and classifications: as above. Named
sites: `SITE_PROVED` (K). Bridge: `EQUAL_TO_REACTION_LIBRARY` (K).
Levels: K = accepted by the Lean kernel with axioms among `propext`, `Classical.choice`, `Quot.sound`.
N is not used. X = computed by a program. A count never mixes levels. `decide +kernel` is allowed
(kernel-checked, same axioms); `native_decide`, `sorry` and new axioms are not.

A database annotation used anywhere (a site, an enzyme for a step, the absence of an enzyme) is an
assumption copied from the source. Agreement of a Rhea record with the kernel is the expected outcome.

## 7. Order of work

1. Generator for species and Rhea records; build locally (the 894 records are about two chunks of the
   reaction library). 2. Rule test. 3. Spontaneous reactions with sources. 4. Cycles. 5. General
   theorems and classification. 6. Named sites. 7. Must-fail files, each compiled alone and required to
   fail. 8. Axioms audit of every theorem (`#print axioms`), saved. 9. Bridge file and a clean build of
   everything on a Kaggle CPU notebook (private dataset, private notebook, Lean 4.36.0 for Linux), with
   the reaction library. 10. Hash check of kernel files, `lakefile.toml` and the three shared site files.
   11. Tables, notice, report.

## 8. What is not attempted

Mixtures and end products without a defined structure (C28 beyond the Rhea records), radical chain
steps of lipid peroxidation, nucleotide excision repair, mismatch repair, double-strand break repair,
kinetics. No statement about rates or time in Lean.
