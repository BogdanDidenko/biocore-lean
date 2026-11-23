# Prior-work search, track "pl": the Lean prover (versions 3 and 4)

Access date for every source and query: 2026-11-21. Scope of the verdicts: Lean only. Work in other provers that was met on the way is recorded in the sources table but belongs to the other tracks.

Files: pl_sources.csv (not in this repository) (70 rows) and pl_queries.csv (not in this repository) (298 logged queries).

## How to read the verdicts

- ALREADY DONE means at least one Lean source, read beyond its abstract (full text or the code itself), does the thing asked. It does not mean the prior work has the same design, scale or trust base as the library described in the task.
- "kernel-checked" in the sources table is what each source claims. Nothing was compiled or rebuilt in this session.
- Most Lean sources outside the two anchors date from 2026, and many are self-published deposits or repositories written with heavy AI assistance and without peer review. They show that a path has been walked. They are weak evidence of quality or maintenance.
- NOT FOUND WITH THIS EFFORT is a statement about the searches listed, not about existence.

## Searches behind every verdict

298 logged queries on 2026-11-21: OpenAlex title-and-abstract search and citation filters (146), arXiv API metadata search (91), Zenodo record search (30), GitHub repository search restricted to language Lean, unauthenticated (14), general web search (12), Semantic Scholar citation and reference lists of the two anchors (4), CrossRef/DataCite resolution of 27 DOIs (1 batch). Forward citations were pulled for the two anchors and 15 further hits; reference lists were screened for the two anchors, and read in passing for K-Lean and the BioLean related-work note.

## Verdicts

### Q1. Elemental and charge balance of reactions formalised and proved: ALREADY DONE (toy scale, Lean 4, 2026)

Sources: `https://github.com/humanfia/hoa (icho2026/)` (code inspected); `10.5281/zenodo.23304201` (full text).

The Lean 4 formalisations of the 2026 chemistry-olympiad theory problems define, inside individual problem files, element counts and formal charge for a finite species type, the predicates `AtomBalanced` (every element agrees on both sides) and `ChargeBalanced`, and prove them for named reactions: steam reforming, partial oxidation, water-gas shift, ammonia formation, methane combustion, silver bromide precipitation, and the half-reactions and overall equation of the Belousov-Zhabotinsky system. One file proves in general that atom balance implies formula-mass balance for arbitrary atomic masses; another proves that the coefficients of methane combustion are unique. In the 77 files read, 12 of 68 problem files define a balance predicate and there are 18 atom- or charge-balance theorems. Seven of the 18 are closed with `native_decide`, which trusts compiled code, so those seven are not pure kernel proofs; four use `decide` and seven use `simp`/`norm_num`/`omega`. The HeytingLean report describes a Lean 4 chemistry layer with a periodic table, formula objects, reactions as reactant and product lists, and a solver that finds balancing coefficients, shown on worked examples; the report states no balance theorem and the word "charge" does not occur in it.

What these do not have: one shared definition, a proved equivalence between a finite check and balance for arbitrary reactions, closure of balance under integer combination (pathways), or independence from Mathlib.

Not found before 2026 in Lean: the anchor repository `https://github.com/ATOMSLab/LeanChemicalTheories` has no stoichiometry or reaction file; the reference list of the 2024 paper (117 items) names no chemistry-balance formalisation.

### Q2. The same at database scale (Rhea, KEGG, MetaCyc, BiGG, Reactome): NOT FOUND WITH THIS EFFORT

Searched: OpenAlex title/abstract `"Lean 4"` with Rhea, KEGG, MetaCyc (0, 0, 0 hits), `"genome-scale"` (1 hit, unrelated), `"metabolic network"` (0), `"metabolic"` (13, none on reaction databases); arXiv `"Lean 4"` with Rhea, KEGG, "metabolic network", "flux balance" (0 each); Zenodo `"Lean 4"` with Rhea, KEGG, ChEBI (0 each); GitHub language Lean with metabolic, biochemistry, stoichiometry (0 each). BioLean grounds literature claims in ChEBI identifiers but does not check reactions. The largest reaction sets met in Lean are single textbook systems (Oregonator from one BioModels file, seven PEtab benchmark ODE models). The forward citations of doi:10.1093/bioinformatics/btn425 (109 in OpenAlex) contain no title or abstract with proof-assistant terms.

### Q3. Genetic code, transcription, translation formalised: ALREADY DONE (toy scale, Lean 4)

Sources: `2610.36343` (full text, read end to end); `10.5281/zenodo.20097207` (full text). Related, not read beyond README or abstract: `https://github.com/Takeo140/Mathematical-Medicine`, `https://github.com/KosmoNexus/FDBLean` (listing only), `10.5281/zenodo.19522970`.

Jones and Josephson define nucleotide and amino-acid types, transcription from template and coding strands, translation with the standard codon table, replication, reverse transcription and mutations, and prove redundancy of the code, injectivity and length conservation of transcription and replication, the inverse relation with reverse transcription, and template/coding equivalence. The Yamamoto deposit separates DNA and RNA at the type level and proves three length theorems around a codon-optimisation function. Both use one codon table and Mathlib. Neither has alternative genetic-code tables, a coding-sequence decoder with start and stop conditions checked against annotation (the first paper splits on STOP and lists initiation rules as future work), or any real sequence data.

### Q4. The same at genome scale: NOT FOUND WITH THIS EFFORT

Searched: OpenAlex title/abstract `"Lean 4"` with "coding sequence" (0), genome (13), "genome-scale" (1), codon (13), "sequence alignment" (0), bioinformatics (1); Zenodo `"Lean 4"` with "coding sequence" (0), genome (17), bioinformatics (9); arXiv `"Lean 4"` with genome, "sequence alignment", bioinformatics (0 each); GitHub language Lean with genome (1), bioinformatics (6), codon (1), DNA (7). The hits are verified algorithms on generic sequences (for example the Needleman-Wunsch alignment repository in the sources table; further alignment and superstring repositories appeared in the GitHub listing and were not opened) and toy sequence models. None applies a kernel-checked decoder to the annotated coding sequences of an organism.

### Q5. Chemistry of polymer synthesis joined with sequence semantics in one library: PARTLY (one adjacent source; the stated theorem itself NOT FOUND WITH THIS EFFORT)

Source: `https://github.com/humanfia/hoa (chemlib/)` (code inspected).

The AFPS2017 extension of Chemlib models solid-phase peptide synthesis: deprotection, coupling and wash steps act on a resin-bound chain, and a theorem states that repeated successful cycles construct the target sequence. In the same library a three-species reaction network (growing chain + incoming residue -> extended chain) is proved to conserve residue count. Its header says the result is "neither a molecular-mass conservation claim nor a complete amide-coupling mechanism". There are no nucleic-acid alphabets, no genetic code and no template. No source was found that proves, for an arbitrary template, that transcription, replication or translation is balanced in elements and charge. The genetic-code sources of Q3 contain no chemistry; the reaction-network sources of Q6 and Q8 contain no sequences. Searched in addition: OpenAlex `"Lean 4"` with polymerase (0), nucleotide (5), peptide (6), polymer (16), "replication" DNA (6), "transcription" "translation" (6); Zenodo `"Lean 4"` with "amino acid" AND transcription (0), nucleotide (1), peptide (1).

### Q6. Kernel-checked reachability or impossibility from conservation invariants, certified flux-balance or elementary-mode results: PARTLY

Sources: `10.5281/zenodo.21288080` (code inspected); `https://github.com/humanfia/hoa (chemlib/)` (code inspected); `2607.13531` (abstract and passages); `10.5281/zenodo.23476933`, `10.5281/zenodo.23459493`, `10.5281/zenodo.21288068` (abstracts); `https://github.com/yourbuddyconner/BioLib` (README).

crnt-lean proves that elementary flux modes are exactly the extreme rays of the steady-flux cone and generate it, that linear conservation laws are constants of motion of mass-action solutions, and gives a decidable bounded reachability relation between complexes of the reaction graph. Chemlib defines conservation laws as weights annihilating every reaction vector and has integer hyperflows and stoichiometric autocatalysis criteria. Ripple proves that a CRN reproduces each step of a machine as a reachability fact. Mislan's deposits treat when a network can contain an autocatalytic core. All of this is on abstract species. Not found: a reachability relation on states whose invariant is element content, an impossibility proof of the form "this reaction set cannot make this product", or a certified flux-balance or elementary-mode computation on a named metabolic network. Searched in addition: OpenAlex `"Lean 4"` with "flux balance" (0), "elementary flux" (0), `"reaction network" reachability` (0), `"conservation law" reaction` (0).

### Q7. A stated aim of a shared core library for chemistry or biology in a proof assistant: ALREADY DONE as a stated aim, several times; no shared community core found

Sources read beyond the abstract: `10.1039/d3dd00077j`, `10.1080/00268976.2025.2539421`, `10.21203/rs.3.rs-10086537/v1`, `https://github.com/humanfia/hoa (chemlib/)`, `10.1002/advs.202517294`, `https://github.com/leanprover-community/physlib`, `10.18653/v1/2026.acl-long.1057`. README only: `https://github.com/yourbuddyconner/BioLib`, `https://github.com/dbolser/BioLean`, `https://github.com/rsthornton/leanbio`, `https://github.com/ATOMSLab/LeanSMILES`.

Who and where, in order of appearance:

1. Bobbin et al. (preprint 2022, journal 2024): "we propose the creation of a library of formally-proven theories in all fields of science". State today: the Lean 3 repository was last pushed in March 2024; the group has since published separate Lean 4 projects (Lennard-Jones energy, dimensional analysis, BET analysis, the genetic code, and a SMILES toolkit created in October 2026) rather than one library.
2. Physlib, the community physics library: its README restricts the project to mainstream physics, and its three module indexes contain no chemistry or biology area on the access date.
3. Chemlib (2026): describes itself as a reusable verified Lean 4 library for mathematical chemistry; 100 Lean files; agent-generated; covers reaction-network theory, kinetics, thermodynamics, stochastic chemistry.
4. K-Lean (2026): presents itself as "the first sorry-free Lean 4 library for computational biology"; 94 properties of closed-form quantities; single author.
5. BioLib (created 2026-11-11): "Formally verified computational biology in Lean 4", with a chemistry module for stoichiometric networks and SBML import, and a stated long-term aim of composable published models.
6. BioLean (created 2026-10-23): evidence-weighted literature claims with reusable named derivations called "biolib".
7. LeanBio (created 2026-11-10): a registry of candidate organism-level laws following the physics library's conventions.
8. HeytingLean (report dated February 2026, deposited October 2026): a Lean 4 chemistry layer for materials search.
9. FormalScience (ACL 2026) says its pipeline could be applied to chemistry and biology and leaves that as future work.

No source was found that states or builds a single shared core joining reaction bookkeeping with molecular-biology sequence semantics, and no chemistry or biology library with a community review process comparable to the mathematics or physics libraries.

### Q8. Chemical physics, thermodynamics or kinetics formalised and connected to biology: ALREADY DONE at the level of theory; the connection to biology is PARTLY done

Sources read beyond the abstract: `10.1039/d3dd00077j` (adsorption, gas laws), `10.5281/zenodo.21288080` (mass action, deficiency theorems, stochastic product form), `https://github.com/humanfia/hoa (chemlib/)` (mass action, stochastic CRN, open-network thermodynamics, one BioModels SBML model), `10.21203/rs.3.rs-10086537/v1` (Michaelis-Menten, Hill and inhibition formulas as sign and monotonicity properties), `2607.13531` and `2610.30808` (abstract and passages: mean-field limit, global convergence of detailed-balanced systems). Abstract only: `10.5281/zenodo.23805852` and `10.5281/zenodo.23338174` (PEtab systems-biology ODE models translated from SBML and certified), `10.5281/zenodo.23511662`, `10.5281/zenodo.23511664`, `10.5281/zenodo.22176567`, `10.24433/co.4598965.v1` (binding equilibria), `10.5281/zenodo.18403968`.

Mass-action ODEs, chemical reaction network theory and stochastic kinetics have Lean 4 formalisations. Michaelis-Menten appears as a closed-form rate with proved properties; no derivation of it from an enzyme mechanism was confirmed by reading (crnt-lean's field map lists elimination of intermediates, which was not opened). Biological content is by example: a gene-expression network file, the Oregonator, benchmark ODE models, kinetic proofreading.

## Closest prior work

For the chemistry layer, the closest Lean work found is the set of 2026 olympiad formalisations in `https://github.com/humanfia/hoa (icho2026/)`: they define atom and charge balance over element counts and prove them for a handful of named reactions (18 atom- or charge-balance theorems in the release read), with a general lemma from atom balance to mass balance. They differ from the library in the task by being per-problem definitions without a shared core, without a decision-procedure equivalence or pathway closure, with part of the proofs resting on `native_decide`, and without any database. For the sequence layer, the closest is arXiv:2610.36343, which already has transcription, translation, replication and reverse transcription with injectivity and length theorems, on one codon table and without real sequences. For reaction networks, crnt-lean and Chemlib are far larger than the library in the task on dynamics and structure theory (deficiency theorems, flux cones, stochastic product forms) but work on abstract species with no elements. The one place where sequence assembly and reaction stoichiometry sit in a single Lean library is Chemlib's peptide-synthesis extension, and it disclaims mass conservation. On this evidence, the items of the task for which no Lean precedent was found are: balance checked for a whole curated reaction database (Q2), decoding of all annotated coding sequences of an organism (Q4), a general theorem that template-directed synthesis of any sequence is element- and charge-balanced (Q5), and reachability with element conservation used to prove that a target cannot be made (Q6, the impossibility part). The remaining items have precedents at toy scale.

## What was NOT searched or not done

- Provers other than Lean (other tracks).
- Lean Zulip chat, Lean Reservoir package index, OpenReview, DBLP, Google Scholar, ProQuest or university thesis repositories (one web search for theses only), Scopus, IEEE Xplore, Springer Nature APIs, bioRxiv and ChemRxiv native search (both reached only through OpenAlex).
- Semantic Scholar keyword search and Semantic Scholar citation lists for hits other than the two anchors: the credential prompt went unanswered after the first call, so only the anchor lists were obtained.
- arXiv API search covers titles and abstracts, not full text. OpenAlex search was on titles and abstracts; its full-text search was not used.
- GitHub: 14 repository-name/description searches with language Lean, unauthenticated; no code search, no topic search, no forks or issues. A first batch of 28 queries stalled and was stopped; the 14 that replaced it ran. Repositories are covered by another track.
- Backward references were followed for the two anchors only; forward citations for the two anchors and 15 further hits. OpenAlex returned 24 of the 28 citing works it counts for the 2024 paper, and no OpenAlex record exists for two arXiv-only hits, so their citers were not pulled.
- Of 13 arXiv full texts retrieved, one (2610.36343) was read end to end; the others were read by keyword-targeted passages. 28 sources were read at abstract level only and 9 as listings.
- Roughly 360 self-published Zenodo and PhilPapers records returned by the Lean queries were screened by title; about 40 abstracts were read; none of that code was opened except the two PDFs noted in the sources table.
- No Lean code was compiled. Counts of theorems and tactics in the olympiad files come from text search over one of several releases in that repository (gpt-5.6-sol-full68-formalization plus two Chem support folders), and are provisional for the repository as a whole.
- One white paper ("Lean for Science Formalization", ulam.ai, February 2026) is on a host outside the sandbox allowlist; only the search-engine excerpt was seen. It is listed as UNRESOLVED and supports no verdict.
