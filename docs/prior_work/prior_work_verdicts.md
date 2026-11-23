# Prior work: proof-assistant libraries joining chemistry and molecular biology

Search dates 2026-11-21 and 2026-11-22. Four parallel tracks: Lean; other proof assistants; formal methods outside proof assistants; community venues (code hosts, package indexes, Lean chat). Totals: 361 source rows, 308 distinct identifiers (37 seen by more than one track), 1,520 logged queries.

Read depth of the 361 rows: listing only 127, abstract only 91, full text 54, README only 40, code inspected 20, full text (passages) 16, unresolved 8, other (see read_depth) 5.

Merged table: [prior_work_sources.csv](prior_work_sources.csv). Track verdict files: [Lean](pl_verdicts_lean.md), [other provers](po_verdicts_other_provers.md), [formal methods](pf_verdicts_formal_methods.md), [community](pc_verdicts_community.md).

## How to read the verdicts

"Not found with this effort" is a statement about these searches, not about the world. The limits are listed at the end; the main ones are that no found repository was compiled, 127 rows are listing-level, and two tracks ran without OpenAlex.

## Verdict per question

| Question | Verdict | Evidence (read depth) |
|---|---|---|
| Q1. Element and charge balance of reactions proved in a proof assistant | **Already done, toy scale** | Coq: `CharlesCNorton/rfna-verified` has `balancedb r = true <-> balanced r`, no charge, 9 reactions (code inspected by a track and re-read by the lead). Lean 4: `facebookresearch/atlas-lean` `IsBalanced` over a composition matrix with a charge coordinate, conservation under reaction extents, abstract (code inspected, re-read by the lead). Lean 4: `humanfia/hoa` per-problem atom and charge balance, part by `native_decide` (code inspected). Idris 2: `justinkelly-ie/FinSc-Chemistry`, 3 reactions (code inspected). No peer-reviewed paper found. |
| Q2. The same for a curated database, checked by a kernel | **Not found with this effort** (kernel); **already done** by ordinary programs | Ordinary programs: KEGG balance classification, 10.1186/1471-2105-7-517 (full text); MetaCyc vs KEGG, 10.1186/1471-2105-14-112 (full text); model test suite, 10.1038/s41587-020-0446-y (full text). Nearest prover item: an unreleased package described on the Lean chat (reactions from a Cantera file that type-check only if atom-balanced; no code found). |
| Q3. Genetic code, transcription, translation in a proof assistant | **Already done, toy scale** | arXiv:2610.36343 = `ATOMSLab/LeanGenetics` (full text and code); 10.5281/zenodo.20097207 (full text); Idris 2 `justinkelly-ie/FinSc-Biology` (code inspected). One codon table each, no annotated sequences. |
| Q4. All coding sequences of an organism checked by a kernel or verified program | **Not found with this effort** | Whole-genome CDS validation by unverified pipelines is routine. |
| Q5. Chemistry of polymer synthesis joined with sequence semantics | **Partly** | Ordinary code at genome scale: sequence-specific transcription and translation reactions with element balance per instance, 10.1371/journal.pcbi.1000312 and 10.1371/journal.pcbi.1006302 (full text). Provers: residue-count conservation for peptide coupling in `humanfia/chemlib` (code inspected; its own header disclaims mass conservation); mass-number identities for three dipeptides in `FinSc-Biology`. A theorem for an arbitrary template: not found. |
| Q6. Kernel-checked "can / cannot make" for metabolic networks | **Partly** | General conservation theorems: `atlas-lean`, `marpaia/crnt-lean` (10.5281/zenodo.21288080, code inspected). Reachability for designed abstract networks in Isabelle, arXiv:1909.05390 (full text). Reactor invariants in KeYmaera X, arXiv:2509.01130. Outside provers: producibility from conservation relations, 10.1529/biophysj.105.069278 (abstract); exact-arithmetic certificates for 98 reconstructions, 10.1038/ncomms5893 (full text). A kernel-checked impossibility for a concrete metabolic target: not found. |
| Q7. Stated aim of a shared core library for chemistry or biology | **Already done as an aim**, several times | 10.1039/d3dd00077j (full text; preprint arXiv:2210.12150 from October 2022; its repository was last pushed 2024-03); Chemlib (`humanfia/chemlib`), `atlas-lean` chemistry and biology domains, several 2026 repositories named BioLib, BioLean, LeanBio; Idris 2 "Finite Science"; Coq `forbars/forbars` (2014, inactive). None found in the Lean package index, the Isabelle archive or the Rocq package index. |
| Q8. Kinetics, thermodynamics, reaction-network theory formalised and tied to biology | **Already done**, and broader than this library | Lean 4: reaction-network theory with deficiency theorems, flux cone, stochastic product form (`crnt-lean`); Chemlib; arXiv:2607.13531. HOL Light: mass-action kinetics for small pathways, 10.1371/journal.pone.0180179 (full text). All on species as opaque names, without elements. |

## What this means for the core

1. **Not new.** The balance predicate, the equivalence of a finite check with balance, conservation under combinations of balanced reactions, and the central-dogma functions with injectivity all have precedents. The aim of a science library in a proof assistant was stated in the preprint arXiv:2210.12150 (posted October 2022, published 2024 as 10.1039/d3dd00077j) and several times since.
2. **Not found (provisional).** A curated reaction database checked by a kernel; decoding of all annotated coding sequences of an organism; a general theorem that templated synthesis of any sequence is element- and charge-balanced; an impossibility proof from element conservation over a database-scale library. These are contributions of scale and integration. Their outcomes agree with curated databases by construction, so they are checks, not discoveries.
3. **Ordinary programs already do each of these at larger scale without proofs.** What the kernel adds is a smaller trust base, not new biological content.
4. **Kinetics and reaction-network theory should be reused, not rebuilt.** The Lean developments found are far ahead there; they depend on Mathlib, which this core does not use.
5. **The field moves fast.** Almost all proof-assistant hits date from 2026 and most are self-published.

## Limits of this search

- No found repository was compiled. "Proved" for those sources means source reading plus the authors' claims.
- OpenAlex was not used by the formal-methods and other-provers tracks (the key approval was not answered). Semantic Scholar keyword search was mostly unavailable in three tracks; citation following was one step and partial.
- GitHub code search, GitLab and other code hosts, conference programmes, grant databases, theses and non-English literature were not searched.
- The Lean chat archive was searched by topic title up to 2026-02-28, and by full text only in web-public channels.
- About 360 self-published records returned by Lean queries were screened by title only.
- Eight rows are marked unresolved or not retrieved and support no verdict.
- The lead re-read two repositories (`rfna-verified`, `atlas-lean`), confirmed that six further repositories and the arXiv listing respond, and resolved eight DOIs through CrossRef. Everything else rests on the tracks.
