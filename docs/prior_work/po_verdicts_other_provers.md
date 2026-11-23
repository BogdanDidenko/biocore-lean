# Prior work outside Lean: verdicts (track `po`)

Scope: proof assistants and verified-programming systems other than Lean (Coq/Rocq, Isabelle/HOL, HOL Light, HOL4, Agda, ACL2, Mizar, PVS, Idris, F*, Dafny, Why3), plus KeYmaera X where it surfaced. Searches ran on 2026-11-21 and 2026-11-22.

Files: po_sources.csv (not in this repository) (71 sources) and po_queries.csv (not in this repository) (378 logged queries, 39 of them failed requests).

Every verdict below is limited to this track and to this search effort. NOT FOUND means not found with the engines and query counts stated, never that the work does not exist. No repository was compiled here; "kernel-checked" for repositories is therefore recorded as unclear.

## What was searched

| Engine | Logged queries | Notes |
|---|---|---|
| GitHub repository search (unauthenticated) | 184 | language-filtered and free-text; first 30 results per query; failed requests are logged and were retried |
| arXiv API | 66 | first 60 results per query |
| CrossRef title search | 60 | first 40 results per query, relevance order |
| Semantic Scholar keyword search (keyless) | 20 | heavily rate-limited: 12 of 42 planned queries answered |
| Semantic Scholar citation graph (keyless) | 14 | references and citing papers of 14 anchor works |
| Europe PMC (full-text index) | 14 | one title query reviewed only its first 40 of 191 hits |
| Web search | 12 | low yield for this topic |
| Library listings | 8 | AFP mirror (all 1,043 entry metadata files), Coq opam archive (605 + 355 package names), ACL2 books, HOL Light, HOL4 examples, PVS NASA library, two owners' repository lists |

## Verdicts

### Q1. Elemental and charge balance formalised and proved — PARTLY
- Element balance: done at toy scale in two unpublished repositories, both read at code level. `CharlesCNorton/rfna-verified` (Rocq, one file of 7,627 lines) defines a formula record over 8 elements, a proposition `balanced` (per-element equality of the two sides), a Boolean check `balancedb` with the lemma `balancedb r = true <-> balanced r`, proves 9 reactions balanced, and proves that balanced implies atom and mass conservation. `justinkelly-ie/FinSc-Chemistry` (Idris 2) checks atom conservation for three reactions with Boolean audit functions.
- Charge balance: NOT FOUND WITH THIS EFFORT in any non-Lean system.
- No peer-reviewed paper on reaction balance in a proof assistant was found. The HOL Light kinetics work (10.1371/journal.pone.0180179) formalises stoichiometric matrices but its text contains neither "conservation" nor "balanced".
- Sources: repo CharlesCNorton/rfna-verified; repo justinkelly-ie/FinSc-Chemistry; context 10.1186/s13321-022-00621-8 (paper mathematics), 10.1002/anie.202417657 (SMT charge neutrality, not a proof assistant).

### Q2. The same at database scale — NOT FOUND WITH THIS EFFORT
- No source checks reactions of Rhea, KEGG, MetaCyc, BiGG or Reactome with a proof-assistant kernel. Europe PMC full-text queries combining prover names with those database names returned 0 hits; all 108 citing records of 10.1093/bioinformatics/btn425 are numerical tools by title.
- Database-scale balance checking exists only outside provers (10.1093/bioinformatics/btn425, 10.1093/bioinformatics/btx453, 10.1101/816876; all listing-level reads here).

### Q3. Genetic code, transcription, translation — ALREADY DONE at toy scale (one unpublished Idris 2 repository); otherwise fragments only
- `justinkelly-ie/FinSc-Biology` (Idris 2, code inspected, not compiled): RNA alphabet, a projection from nucleobases to RNA bases, an amino-acid type with a stop value, a full 64-case `translateCodon` table, reading-frame translation with a length proof.
- Fragments elsewhere: nucleotide type, complement and local alignment in Coq (`forbars/forbars`, 2014, code inspected); reverse-complement and seed-matching properties of bioinformatics libraries in Rosette, an SMT-backed tool without an LCF-style kernel (10.1093/bib/bbaf383, full text); verified sequence algorithms in Isabelle (10.1007/s10817-025-09735-8 and the seqAlign paper, abstracts only).
- No Coq/Rocq, Isabelle, HOL, Agda, ACL2, Mizar, PVS, F*, Dafny or Why3 formalisation of the genetic code was found. The Lean paper arXiv:2610.36343 itself reports that "their formal verification within a rigorous logical and computational framework remains largely unexplored" and cites only HOL4 Zsyntax and a Coq neural-network model.

### Q4. The same at genome scale — NOT FOUND WITH THIS EFFORT
- No source decodes all annotated coding sequences of an organism in a prover or verified program. The Rosette work verifies library operations, not genome annotations.

### Q5. The two layers joined in one library — PARTLY (instances only)
- `justinkelly-ie/FinSc-Biology` places codon translation and peptide-bond condensation in one file, with compile-time mass-number identities for three dipeptides (Gly-Ala, Met-Phe, Cys-Cys). These identities hold by construction, because the dipeptide mass is defined as the sum minus 18.
- NOT FOUND: a generic theorem that templated synthesis of any sequence is balanced; per-element or charge balance of polymerisation; transcription or replication chemistry tied to sequence semantics.
- Context: a linear-logic model of prebiotic polymerisation (10.1101/2025.03.23.644802, abstract only) describes simulation, with no prover named.

### Q6. Kernel-checked reachability or impossibility from conservation; certified FBA/EFM — PARTLY
- Kernel-checked reachability exists for designed, abstract reaction networks: Isabelle/HOL proofs of termination and outcome for all initial populations (arXiv:1909.05390; follow-up 10.1109/allerton58177.2023.10313474, abstract only). The invariants are population counts, not element conservation.
- KeYmaera X proofs bound reachable concentrations in isothermal reactors and use conservation of mass as an invariant (arXiv:2509.01130, full text). The setting is ODE concentrations of a few species.
- `rfna-verified` defines an inductive `reachable` relation and `invariant_preserved`, but no theorem uses them.
- Certified structural analysis of metabolic models exists outside provers: exact rational arithmetic with solver certificates over 98 models, 44 of 89 with a blocked biomass reaction (10.1038/ncomms5893, full text).
- NOT FOUND: a kernel-checked statement that a metabolic reaction set cannot make a target because of an elemental invariant; flux-balance or elementary-mode results certified by a proof assistant.

### Q7. Stated aim of a shared core library for chemistry or biology — PARTLY
- Aims found: (a) the Lean chemical-physics paper, "we propose the creation of a library of formally-proven theories in all fields of science" (arXiv:2210.12150, full text; Lean track); (b) the Finite Science ecosystem in Idris 2, a single-author layered set of repositories from multiset algebra to chemistry and biology, described as "enforcing conservation laws and cosmological structures at compile time in Idris 2" (README; chemistry and biology layers created 2026-08/09, last push 2026-11-19); (c) ForBaRS, a 2014 Coq/Ada repository whose README states the aim of formalised bioinformatics, inactive since 2014; (d) a Coq-based position paper for computational logic as a unified certified framework for systems biology (arXiv:2007.07571, abstract only); (e) the HOL framework for formal reasoning about systems biology (10.1371/journal.pone.0180179).
- State today: no shared, community-maintained core library for chemistry or biology was found in the Isabelle AFP (1,043 entries scanned, no chemistry or biology topic), the Coq opam archive (960 package names), ACL2 books, HOL Light, HOL4 examples or the PVS NASA library (names only for the last four).

### Q8. Chemical physics, thermodynamics or kinetics connected to biology — ALREADY DONE for mass-action kinetics; other sub-topics NOT FOUND
- Mass-action reaction kinetics (flux vectors, stoichiometric matrices, ODE models of generic pathways) are formalised in HOL Light and applied to TP53 phosphorylation and a tumour-growth model (10.1371/journal.pone.0180179, full text; extensions 10.1049/iet-syb.2020.0026, arXiv:1912.07340).
- Michaelis-Menten kinetics appear in KeYmaera X reactor proofs (arXiv:2509.01130, full text).
- NOT FOUND outside Lean: chemical reaction network theory (the only hit, `crndefzero-verified`, is a header comment without definitions or proofs), stochastic kinetics or Gillespie semantics, binding equilibria, thermodynamics tied to biology. Lean pointers for the other track: arXiv:2607.13531 (Kurtz mean-field theorem for CRNs).

## Closest prior work

For the chemistry layer the closest match is the Rocq file `rfna.v` in `CharlesCNorton/rfna-verified`: it has the same skeleton as layer (i) of the library (formula as element counts, species, reaction, a `Balanced`-style proposition, a Boolean check proved equivalent, and an inductive reachability relation over firing reactions). It differs in having no charge, a fixed record of 8 elements, 9 propellant reactions, no pathway theorem, no theorem about reachability, no biology and no database. It contains 594 `Qed` and 4 `Admitted` (all four in an integer square-root section) and was not compiled here. For the sequence layer and for the join, the closest match is the Idris 2 file `RibosomalTranslation.idr` in `justinkelly-ie/FinSc-Biology`: a full codon table and reading-frame translation next to peptide-condensation mass identities for three dipeptides; it has no generic polymer-synthesis theorem and no element or charge balance of the condensation. Both are recent, unpublished, single-author repositories with no stars. In the peer-reviewed literature the nearest line is the HOL4/HOL Light work of Ahmad, Rashid, Hasan and co-authors (Zsyntax pathway logic and reaction kinetics), which treats molecules as opaque names and reasons about pathway deduction and rates, not composition. Nothing found in this track checks a curated reaction database or a genome annotation with a prover kernel.

## What was NOT searched

1. OpenAlex: the credential request could not be approved because no user was present; no keyless call was made.
2. Scopus, IEEE Xplore, Springer Nature APIs: not attempted after the first credential request went unanswered.
3. Semantic Scholar keyword search: 30 of 42 planned queries were never answered because of rate limiting (they are in the query log as failed, or were not sent).
4. Google Scholar, DBLP (bot check on the API), HAL, Zenodo, institutional thesis repositories.
5. www.isa-afp.org and opencitations.net are blocked by the sandbox; the AFP GitHub mirror and Semantic Scholar citations were used instead.
6. GitHub code search (needs authentication), GitLab, Codeberg, SourceHut.
7. Mizar Mathematical Library article list; Agda and Idris package collections; F*, Dafny and Why3 example galleries (only keyword queries were run for these).
8. Mailing lists, Zulip, Discourse and conference talk abstracts (ITP, CPP, CMSB, DNA) were not scanned systematically.
9. Result depth: only the first 30 (GitHub, Semantic Scholar), 40 (CrossRef) or 60 (arXiv) results of each query were reviewed.
10. Read depth: of 71 sources, 12 were read at full-text level (keyword-guided), 7 at code level, the rest at abstract, README or listing level; no proof development was compiled.
