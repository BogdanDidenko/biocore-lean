# Track pc - prior work announced on code hosts, package indexes and community chat

Search dates: 2026-11-21 and 2026-11-22. Sources table: pc_sources.csv (not in this repository) (74 rows: 67 resolved, 7 UNRESOLVED and not used for any verdict). Query log: pc_queries.csv (not in this repository) (396 logged queries).

Reading rule used below: ALREADY DONE is given only where at least one source was read beyond its abstract or README (here: the code itself). No repository was built in this session, so "kernel-checked" is the authors' claim plus my reading of the source; counts of `sorry` are token counts that include comments. NOT FOUND always means "not found with this effort", and the effort is stated.

Context that affects every verdict: almost all relevant repositories are from 2026, many from the last three months, and several are machine-generated at large volume. This map is a snapshot of a fast-moving area; it will age within weeks.

## Verdicts

| Q | Verdict | Sources behind it (ids as in pc_sources.csv) |
|---|---|---|
| Q1 element and charge balance proved in a proof assistant | **ALREADY DONE** (single reactions, single mechanisms, and as general theory) | github.com/CharlesCNorton/rfna-verified (code); github.com/facebookresearch/atlas-lean `PhyslibExt/Chemistry/Stoichiometry/Balance.lean` (code); github.com/humanfia/hoa IChO 2026 files (code); Zulip message 627545822 on LeanCatalyst (statement only, code UNRESOLVED) |
| Q2 the same at database scale | **NOT FOUND WITH THIS EFFORT** | nearest: LeanCatalyst description (mechanism files translated from Cantera YAML; size and code not public); github.com/humanfia/chemlib (one BioModels SBML model, stoichiometry only); github.com/dbolser/BioLean (thousands of database identifiers, but for evidence claims, not reactions) |
| Q3 genetic code, transcription, translation formalised | **ALREADY DONE** | github.com/ATOMSLab/LeanGenetics (code) = arXiv:2610.36343; partial: github.com/fractastical/leanbio (code table), github.com/KosmoNexus/FDBLean (code-table structure), github.com/cascade77/bio-algos-verification (complement lemmas, Rocq), github.com/Takeo140/Mathematical-Medicine |
| Q4 the same at genome scale | **NOT FOUND WITH THIS EFFORT** | no repository, package or thread found that decodes an organism's annotated coding sequences in a prover or verified program |
| Q5 chemistry of polymer synthesis joined with sequence semantics | **PARTLY** (weak); the specific theorem (templated synthesis of any sequence is element- and charge-balanced) NOT FOUND WITH THIS EFFORT | github.com/humanfia/chemlib `AFPS2017/Sequence/StoichiometryAdapter.lean` (code): a coarse peptide-elongation reaction with residue count as a conservation law, explicitly not a mass-balance claim |
| Q6 kernel-checked reachability/impossibility from conservation invariants; certified FBA/EFM | **PARTLY** | general theorems only: atlas-lean (conservation under extents; FBA as LP with duality and shadow prices), github.com/yourbuddyconner/BioLib (conserved totals constant along trajectories), github.com/OmnisGenomics/VeriBiota (linear invariants preserved by firing), rfna-verified (inductive `reachable` used for safety invariants), HOL4/HOL Light Zsyntax (doi:10.1007/978-3-319-15075-8_3, doi:10.1371/journal.pone.0180179: pathway deduction). Not found: an unreachability proof for a concrete metabolic target, or a certified FBA/elementary-mode result for a concrete model |
| Q7 stated aim of a shared core library for chemistry or biology | **ALREADY DONE** (the aim has been stated several times; see state below) | doi:10.1039/d3dd00077j; Zulip "should scilib and mathlib be separate libraries?"; humanfia/chemlib; atlas-lean; yourbuddyconner/BioLib; dbolser/BioLean; fractastical/leanbio + Zulip message 639852059; forbars/forbars (2014); Zulip message 571826630 |
| Q8 chemical physics, thermodynamics, kinetics formalised and connected to biology | **ALREADY DONE** | atlas-lean `Domains/Biology/Dynamics` (code docs: stochastic mass action, Michaelis-Menten, deficiency zero/one, metabolic control analysis); humanfia/chemlib (code); yourbuddyconner/BioLib (code); github.com/marpaia/crnt-lean (README + declaration grep); arXiv:2607.13531; arXiv:2610.30808; doi:10.1039/d3dd00077j; doi:10.1371/journal.pone.0180179 (HOL Light, abstract) |

## What was found, per question

**Q1.** Three independent code bases prove balance. (a) `rfna-verified` (Coq, Dec 2025, one 7,627-line file): a formula record with eight element counts, reactions as coefficient lists, a proposition `balanced`, a boolean `balancedb`, and the lemma `balancedb r = true <-> balanced r`; specific propellant reactions are then proved balanced by computation, and balance is shown to imply mass balance. It has no charge. (b) `atlas-lean` (Lean 4 over Mathlib, active on 2026-11-21): `IsBalanced A ν := A *ᵥ ν = 0`, where the rows of the composition matrix are the elements plus one coordinate for electric charge, with the theorem that any combination of balanced reactions leaves every balance coordinate of the amounts unchanged. (c) `humanfia/hoa`: per-problem `AtomBalanced` and `ChargeBalanced` definitions with proofs for individual redox reactions of the 2026 chemistry olympiad. In addition, T. Josephson described on the Lean chat (2026-09-28) a package in which reactions imported from a kinetics file are Lean definitions "guaranteed to satisfy atom balances when they type check"; I found no public code for it.

**Q2.** No source checks a curated reaction database in a prover. Searches of GitHub repository metadata for Rhea, ChEBI, KEGG, metabolic, SBML with Lean/Coq/Isabelle/Agda, and a grep of about 60 cloned repositories for database names, found database content only as identifiers for evidence statements (dbolser/BioLean), one SBML model (chemlib), and typed-in thermochemical constants (rfna-verified).

**Q3.** `ATOMSLab/LeanGenetics` (437 lines, Lean 4 + Mathlib, first commit 2025-06-10, last 2026-04-20) defines nucleotides and amino acids, transcription from template and coding strands, replication, translation with the standard code, reverse transcription, point mutations and frameshifts, and proves length conservation, injectivity of transcription and replication, non-injectivity of translation, and that reverse transcription inverts transcription. It is the code behind arXiv:2610.36343. The chat record dates the gap: in September 2023 a question about DNA sequence theorems was answered with "I doubt anyone has touched this in Lean."

**Q4.** Nothing found. The sequence developments above contain no genome or transcript data.

**Q5.** The only place where polymer-synthesis chemistry and a sequence model sit in one library is the peptide-synthesis formalization shipped with Chemlib. Its conserved quantity is the number of residues; its species have no elemental formulas and it has no genetic code. Nothing found states or proves balance of transcription, replication or translation for an arbitrary sequence.

**Q6.** Conservation is proved as a general fact in four code bases (continuous trajectories in BioLib and atlas-lean, discrete firing in VeriBiota, safety invariants over an inductive reachability relation in rfna-verified). Flux balance analysis is formalised in atlas-lean as linear-programming theory (attainment, duality, shadow prices), not as a certified result for a named model. I found no proof that a concrete target cannot be made by a concrete reaction set.

**Q7.** Who, where, state today:
- T. Josephson and the ATOMS Lab (UMBC). Stated in the 2024 Digital Discovery paper, which proposes "a library of formally-proven theories in all fields of science", and on the Lean chat in 2023 as "SciLib". State: the Lean 3 repository LeanChemicalTheories has had no commit since 2024-03-11; the work continues as separate Lean 4 packages (LeanLJ, LeanBET, LeanSMILES, LeanGenetics, and the unreleased LeanCatalyst). No single shared library exists under that name.
- Humanfia: "Chemlib", described as a verified Lean 4 library for mathematical chemistry (100 files, 11,308 lines; snapshot of 2026-10-05, development moved to another repository that I did not clone). Content is reaction-network theory, stochastic kinetics and thermodynamics.
- Meta (atlas-lean): autoformalized libraries with `PhyslibExt/Chemistry`, `Domains/Chemistry` and `Domains/Biology`; active on the search date.
- Individual 2026 projects named BioLib (yourbuddyconner; 6 commits), BioLean (dbolser; evidence-weighted claims), leanbio (fractastical; announced on the Lean chat on 2026-11-12 with the aim of a larger programme for biology), and a 2014 Coq project (forbars) with 11 commits.
- Indexes: the Lean package index (955 packages), the Isabelle Archive of Formal Proofs (1,060 entries; no chemistry or biology topic) and the Rocq opam archive (659 package names) contain no chemistry or molecular-biology library by name, topic or keyword. Physlib has no chemistry or biology directory.

**Q8.** Well covered: chemical reaction network theory (crnt-lean, 374,316 Lean lines; Chemlib; atlas-lean), stochastic kinetics and product-form results, mass-action convergence (arXiv:2610.30808), Michaelis-Menten and Hill kinetics (BioLib, atlas-lean, grn-lean), adsorption and thermodynamics (ATOMS Lab), and earlier HOL Light work on reaction kinetics for pathways.

## Closest prior work

For the chemistry layer, the closest design is `rfna-verified`: formula record, reaction, a boolean check proved equivalent to balance, and reactions certified by computation, in Coq and without charge, for a handful of reactions. The closest statement in Lean is the `IsBalanced` module of `atlas-lean`, which has elements and charge and the conservation theorem for combinations of balanced reactions, in matrix form over Mathlib and with no concrete species. The closest workflow is the LeanCatalyst description (data translated by an untrusted script, balance enforced when the generated file type-checks), for which no code was found. For the sequence layer, the closest is `LeanGenetics` / arXiv:2610.36343, which covers transcription, translation and replication with general theorems for the standard code. For the join of the two layers, the closest is the peptide-synthesis module of Chemlib, which conserves residue count only. Not found in any of them: a proved-balanced or proved-unbalanced classification of a whole curated reaction database; decoding of all coding sequences of an organism; a theorem that templated synthesis of an arbitrary sequence is element- and charge-balanced; a library doing this without Mathlib.

## What was searched

- GitHub repository search API, unauthenticated: 294 queries (58 terms x 4 languages Lean/Coq/Isabelle/Agda, plus 62 free-text queries), 321 distinct repositories returned, no query truncated by the result cap. About 60 repositories were cloned or tree-listed and grepped; the rest were screened by name and description.
- Lean chat: static archive (95 streams, 54,653 topic titles, last updated 2026-02-28) by title; live web-public full-text search for 43 terms; 46 threads fetched.
- Lean package index: full manifest of 955 packages. Isabelle AFP: topic index, 1,060 entry titles, 9,059 keywords. Rocq opam archive: 659 package names.
- arXiv API (10 searches; 11 records fetched by id), CrossRef (9 DOIs), cited-by lists for three papers (Semantic Scholar for arXiv:2210.12150; OpenAlex for doi:10.1039/d3dd00077j, doi:10.1371/journal.pone.0180179, doi:10.1049/iet-syb.2020.0026), 6 web searches.

## What was NOT searched

- GitHub code search (needs authentication) and README full text: repository search matches name, description and topics only, so a relevant repository with an uninformative description would be missed.
- GitLab, Codeberg, SourceHut, Bitbucket, Zenodo and Hugging Face. GitLab was blocked by the network sandbox and I proceeded without it.
- Programmes of Lean Together, ITP, CPP, CICM, CAV-adjacent workshops, CMSB, HSB and FMMB were not read. Conference talks were covered only through chat thread titles (Lean Together 2019-2026 streams) and web search.
- Grant databases (NSF award search, CORDIS, UKRI): not queried; one web search for an NSF award returned nothing usable.
- Coq/Rocq and Isabelle community chats, the Agda and HOL mailing lists, Proof Assistants Stack Exchange.
- Private or unlisted streams of the Lean chat; chat attachments (the BioLean.pdf draft was not fetched).
- AFP abstracts and opam package descriptions (titles, keywords and names only).
- Backward references of arXiv:2610.36343 and of the other papers; forward citations beyond one step; forward citations of arXiv:2505.09095 and arXiv:2610.36343 (Semantic Scholar returned HTTP 429 and they were not retried elsewhere).
- No repository was built; no proof was re-checked.
