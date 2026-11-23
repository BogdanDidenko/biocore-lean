# Track pf: formal methods in systems biology and chemistry that are not proof assistants

Date of all searches: 2026-11-21. Deliverables: `pf_sources.csv` (146 sources), `pf_queries.csv` (448 logged requests), this file.

## How to read this file

- A verdict is one of ALREADY DONE / PARTLY / NOT FOUND WITH THIS EFFORT. "Not found" is a statement about this search, not about the literature.
- Read depth per source is in `pf_sources.csv`: 21 full text (keyword-searched), 15 full-text passages, 27 abstract only, 83 listing only. For listing-only rows the `kernel_checked` value follows from the formalism named in the title or record, not from reading the source; those rows carry no verdict.
- All numbers quoted below were read from the fetched text of the named source in this session.

## Search effort and limits (provisional where noted)

- Requests logged: 448 (arxiv 72, crossref 285, europepmc 22, europepmc_fulltext 4, fulltext_fetch 26, semanticscholar 28, web_search 11); 26 of them failed (rate limit or server error) and are marked in the query file.
- OpenAlex was NOT used: the stored key could not be approved (no user present), and keyless calls are not permitted.
- Semantic Scholar keyword search was unavailable without a key (HTTP 429); only its citation and reference endpoints worked. Forward citations were scanned by title for proof-assistant terms: MEMOTE: 475 citing records; Danos-Laneve Kappa: 543 citing records; Schaub-Thiele ASP: 51 citing records; Rashid2017 HOL: 12 citing records; Zsyntax HOL4: 9 citing records; Koch2005 Petri: 156 citing records; Heiner2008 Petri: 377 citing records; PathwayLogic2002: 178 citing records; Searls2002: 413 citing records; Meneco: 83 citing records; Handorf scope: 190 citing records; Weerasena: 0 citing records; WABI2018: 1 citing records; BIOCHAM: 41 citing records; Rhea2022: 233 citing records; DeMaria Coq: 15 citing records; Zsyntax2010: 27 citing records; Chan2017: 99 citing records; BioPEPA: 369 citing records; Gevorgyan 2008: 108 citing records; MONGOOSE: 47 citing records; Lean chemical physics (arXiv:2210.12150): 23 citing records; LGEM+: 3 citing records; Lean genetic code (arXiv:2610.36343): 0 citing records. The citation request for 10.1007/978-3-319-40530-8_5 failed (HTTP 404). Title matching can miss papers whose titles do not name the method, so every "none found among citers" below is provisional.
- arXiv API: abstract-level search only, heavily rate-limited; several Boolean phrase queries returned zero hits and should be read as weak evidence.
- Europe PMC full-text search worked for the first queries and then degraded (HTTP 500/503); it indexes life-science literature, not computer-science proceedings.
- Web search: 11 queries.
- One DataCite-registered DOI (10.4230/LIPIcs.WABI.2018.1) could not be resolved through CrossRef; the registry resolver host is outside the network allowlist. The record was confirmed through the Semantic Scholar citation listing and the publisher page returned by web search.

## What each family guarantees, by what, at what scale

| Family | What is guaranteed | Trust base | Largest scale seen | Machine-checked proof behind it |
|---|---|---|---|---|
| Rule-based languages (Kappa, BioNetGen) | Executable rule semantics; over-approximated reachability of patterns (KaSa) | Simulator and static analyser code | Signalling models | Not found (1 web query; 543 citers of 10.1016/j.tcs.2004.03.065 scanned by title) |
| Process calculi (pi-calculus, Bio-PEPA, BlenX) | Behavioural semantics, stochastic analysis | Tool implementations | Pathways | Not found among 369 citers of 10.1016/j.tcs.2009.02.037 (title scan); sources themselves listing only |
| Rewriting logic (Pathway Logic) | Symbolic reachability by rewriting and model checking | Rewriting engine | Signalling pathways | Not found among 178 citers of 10.1142/9789812799623_0038 (title scan) |
| Petri nets | P-invariants (conservation relations), T-invariants (steady-state pathways), siphons and traps | Net analysis tools, constraint solvers | Single pathways | Not found (1 web query; 156 and 377 citers of 10.1093/bioinformatics/bti145 and 10.1007/978-3-540-68894-5_7 scanned by title) |
| Model checking (BIOCHAM, probabilistic) | Temporal-logic properties of model behaviours | Model checker | Pathways | Not found among 41 citers of 10.1093/bioinformatics/btl172 (title scan); sources listing only |
| Logic programming, answer sets, SAT, first-order provers | Qualitative producibility (scope), gap-filling, growth/no-growth deduction | ASP/SAT solver or automated first-order prover (iProver in arXiv:2306.06065) | Genome scale (10,800 degraded E. coli networks in 10.1371/journal.pcbi.1005276; Yeast8 in arXiv:2306.06065) | Not found; the two sources read in full or in passages (Meneco, LGEM+) leave stoichiometry out |
| Graph-grammar chemistry | Atom-level rewrite rules; pathways as integer hyperflows | Graph transformation software, ILP solver | Chemical spaces, pathways | Not found |
| Exact or certified FBA and EFM | Exact rational optima; certificates of infeasibility as linear combinations of constraints | Exact LP solver plus checking scripts (10.1038/ncomms5893) | 98 genome-scale reconstructions | Not found (47 citers of 10.1038/ncomms5893 scanned by title) |
| Stoichiometric and elemental checks of models | Mass, charge and stoichiometric consistency tests | Python/MATLAB code and LP solvers | 10,780 models (10.1038/s41587-020-0446-y); 84 BiGG models (10.4230/LIPIcs.WABI.2018.1); 651 BioModels (10.1093/bioinformatics/btaa720); 57 models (10.1371/journal.pcbi.1004732) | Not found (475 citers of 10.1038/s41587-020-0446-y scanned by title) |
| Reaction database curation | Balance as a curation rule or consistency-checker test | Database pipelines and curators | KEGG: 5,323 assessable reactions, 3,711 balanced, 1,612 unbalanced (10.1186/1471-2105-7-517); MetaCyc 10,262 and KEGG 8,879 reaction instances with 532 and 1,475 unbalanced counting hydrogen (10.1186/1471-2105-14-112); 12,742 balanced MetaCyc reactions in 2015 (MetaCyc guide) | Not found (233 citers of 10.1093/nar/gkab1016 scanned by title) |
| Sequence-specific macromolecular synthesis in models | Per-gene transcription and translation reactions with elemental balance | Reconstruction scripts | 13,694 reactions, more than 99% mass- and charge-balanced (10.1371/journal.pcbi.1000312); 12,655 reactions (10.1371/journal.pcbi.1006302) | Not found |
| Sequence grammars and annotation validation | Syntax of variant descriptions; internal-stop, frameshift and similar alerts; exact transcript matching | Parsers and annotation pipelines | More than one million variant descriptions (10.1186/1471-2105-12-s4-s5); GenBank submissions; MANE Select for 97% of human protein-coding genes | Not found; the one "formal verification of bioinformatics software" paper uses bounded model checking and an SMT-backed symbolic executor on aligners and data structures (10.1093/bib/bbaf383) |

## Verdicts

**Q1. Elemental and charge balance formalised and proved in a proof assistant.** NOT FOUND WITH THIS EFFORT (within this track: no proof-assistant formalisation of elemental and charge balance surfaced in the non-proof-assistant families or in their citing literature; the check itself is ALREADY DONE many times as ordinary software).
Sources: the check as software in 10.1038/s41587-020-0446-y, 10.1371/journal.pcbi.1004732 (formulacheck, chargecheck), arXiv:1510.03964, 10.1093/bioinformatics/btaa720; formula-free variants in 10.1093/bioinformatics/btn425 and 10.4230/LIPIcs.WABI.2018.1; paper definitions of "atomic" networks in 10.1007/s11047-018-9687-9. The nearest kernel-checked item seen here, 10.1371/journal.pone.0180179 (HOL Light), formalises stoichiometric matrices and rate laws; a keyword search of its full text found no conservation or balance statement. Direct proof-assistant searches belong to the other tracks.

**Q2. The same at database scale.** PARTLY (database-scale balance classification is ALREADY DONE by ordinary programs for KEGG, MetaCyc, BiGG models and others; a proof-assistant kernel checking a curated database NOT FOUND WITH THIS EFFORT).
Sources (all read in full text or passages): 10.1186/1471-2105-7-517, 10.1186/1471-2105-14-112, https://metacyc.org/PGDBConceptsGuide.shtml, 10.1093/nar/gkr1126, 10.1038/s41587-020-0446-y, 10.4230/LIPIcs.WABI.2018.1 (abstract), 10.1371/journal.pcbi.1004732. Searched for a kernel-checked counterpart: Europe PMC full-text queries combining database or model terms with proof-assistant names, arXiv abstract queries, title scans of 475 MEMOTE citers and 233 Rhea-2022 citers; nothing surfaced.

**Q3. Genetic code, transcription, translation in a proof assistant.** ALREADY DONE (toy scale, one code table: arXiv:2610.36343 in Lean 4; in this track only grammars, first-order axioms and parsers were found, none kernel-checked).
Source: arXiv:2610.36343 (abstract plus HTML passages). In this track: 10.1186/1471-2105-10-377 (first-order axioms for sequences in an automated prover, no translation), 10.1186/1471-2105-12-s4-s5 (EBNF grammar and parser), grammar papers at listing level.

**Q4. The same at genome scale.** NOT FOUND WITH THIS EFFORT (kernel-checked or verified-program decoding of all annotated coding sequences of an organism; whole-genome CDS validation by unverified pipelines is routine).
Non-proof-assistant counterparts: https://www.ncbi.nlm.nih.gov/genbank/validation/, 10.1186/s12859-020-3537-3, 10.1038/s41586-022-04558-8, 10.1371/journal.pcbi.1006302 (translation reactions built from each gene sequence and codon table). Searched: Europe PMC full-text queries for formally verified or machine-checked work on coding sequences or annotation, arXiv abstract queries, one web query; the only hit, 10.1093/bib/bbaf383, has no codon or translation content.

**Q5. The two layers joined in one library.** PARTLY (sequence-derived transcription/translation reactions with elemental balance exist at genome scale in ordinary code: E-matrix 2009, COBRAme 2018; a proved theorem for arbitrary templates in one proof-assistant library NOT FOUND WITH THIS EFFORT).
Sources: 10.1371/journal.pcbi.1000312 and 10.1371/journal.pcbi.1006302 (full text). These compute and check balance per generated reaction; they do not state or prove a property for every possible template. Zsyntax (10.1371/journal.pone.0009511, 10.12694/scpe.v16i1.1059; listing only) is a logic of molecular interactions without chemistry bookkeeping.

**Q6. Kernel-checked reachability or impossibility from conservation invariants; certified FBA or elementary modes.** PARTLY (independently checkable certificates in exact arithmetic and conservation-relation arguments exist at genome scale without a proof assistant; a theorem-prover proof of unreachability from a mass invariant exists for toy reactor ODEs; kernel-checked metabolic-network reachability or certified FBA/EFM NOT FOUND WITH THIS EFFORT).
Sources: 10.1038/ncomms5893 (full text), 10.15252/msb.20156157 (passages), 10.1371/journal.pone.0100750 (full text), 10.1529/biophysj.105.069278 (abstract), arXiv:2610.14566 (abstract), 10.1371/journal.pcbi.1005276 (full text), arXiv:2306.06065 (passages), arXiv:2509.01130 (abstract), arXiv:1404.5439 (passages).

**Q7. A stated aim of a shared core library.** PARTLY (abstract-level evidence only and outside this track: extensible Lean developments are stated for chemical physics and for reaction-network computation; no stated shared core library for biochemistry or molecular biology surfaced here).
Sources: arXiv:2210.12150, arXiv:2607.13531 (abstracts). This track did not search for it directly.

**Q8. Kinetics and thermodynamics formalised and connected to biology.** ALREADY DONE (toy or single-pathway scale: mass-action kinetics and stoichiometric matrices in HOL Light with pathway case studies, read in full text; further items at abstract level).
Sources: 10.1371/journal.pone.0180179 (full text); 10.1049/iet-syb.2020.0026, arXiv:2509.01130, arXiv:2607.13531, arXiv:2605.02474 (abstracts).

## Closest prior work (one paragraph)

Outside proof assistants, every piece of the library has a counterpart at equal or larger scale, produced by ordinary programs. Reaction balance has been classified for whole databases since 2006 (KEGG: 3,711 balanced and 1,612 unbalanced of 5,323 assessable reactions, 10.1186/1471-2105-7-517; MetaCyc and KEGG compared in 10.1186/1471-2105-14-112) and is a standard test for genome-scale models (10,780 models in 10.1038/s41587-020-0446-y). Sequence-derived transcription and translation reactions with elemental balance exist for a whole bacterium (13,694 reactions in 10.1371/journal.pcbi.1000312; 10.1371/journal.pcbi.1006302). Impossibility results from conservation relations exist at genome scale on paper and in numerics (10.1529/biophysj.105.069278), and exact-arithmetic certificates of infeasibility that can be rechecked independently exist for 98 reconstructions (10.1038/ncomms5893); the dispute that followed (10.15252/msb.20156157) turned on how model files were parsed and interpreted, which is the part a proof-assistant library fixes by definition. What this search did not find in any of these families is a statement checked by a proof-assistant kernel: the trust base is always a solver, a parser or a curation pipeline, and the balance results are per-instance test outcomes, not theorems quantified over all sequences or all pathways. The two proof-assistant items nearest to this track are 10.1371/journal.pone.0180179 (HOL Light kinetics for small pathways, no balance) and arXiv:2610.36343 (Lean 4 central dogma at example scale).

## What was NOT searched

- OpenAlex (no key approval) and Semantic Scholar keyword search (rate-limited without a key); Scopus, IEEE Xplore, Springer and ACM full-text search; DBLP; Google Scholar.
- Code hosts: no repository search was run (GitHub, GitLab, the Isabelle Archive of Formal Proofs, Lean and Coq package indexes, Zenodo), so unpublished formalisations are outside this track's evidence.
- Proof-assistant community channels (mailing lists, chat archives), theses and non-English literature.
- Reference lists were followed only for arXiv:2610.36343 (29 references via Semantic Scholar); backward references of the other sources were not expanded. Forward citations were scanned by title only.
- Process calculi, rewriting logic, most Petri-net, graph-grammar and grammar-of-genes sources were resolved as listings and not read; statements about them rest on titles.
- Reactome, BRENDA, SABIO-RK and UniProt curation checks; SBML specification validation rules; INSDC feature-table specification text; Ensembl/GENCODE QC documentation; CCDS QA test lists (listing only).
- Verified linear-programming or Farkas-certificate checkers in proof assistants were queried once (arXiv, CrossRef) without a targeted follow-up; whether any has been applied to a metabolic model remains open.
