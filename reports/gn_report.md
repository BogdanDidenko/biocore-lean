# Gene library for BioCore 0.1 (track "Genes", prefix gn): report

Written 2026-11-22. Every number below was computed by code and read back from a saved file (session outputs, `gn_results.parquet`, `gn_summary.csv`, `gn_summary_level_K.csv`, `gn_axioms_audit.json`).

Three levels of checking are kept apart throughout. **Level K**: a theorem accepted by the Lean 4.36.0 kernel with only standard axioms; only this is called proved or verified. **Level N** (`native_decide`): not used. **Level X**: output of a compiled Lean program or of a script; computed, not proved.

## 1. Result in brief

- **Scope: 19450 records**: 19363 MANE Select transcripts (MANE release 1.5), 74 MANE Plus Clinical transcripts, 13 protein-coding genes of the mitochondrial genome NC_012920.1. Every record is in exactly one class; the classes sum to the scope.
- **Level X (computed)**: ACCEPTED_EQUAL 19339, ACCEPTED_DIFFERENT 0, REJECTED 41, NOT_EXPRESSIBLE 70. The Lean program that calls the kernel's `decodeCDS` and the independent Python re-implementation agree on 19380 of 19380 records (0 disagreements).
- **Level K (proved)**: 19380 of the 19380 records that have a statement were accepted by the kernel (19380 theorems, method M2, ordinary list literals); 0 failed; 0 were not reached; 70 records have no statement (class NOT_EXPRESSIBLE). Axioms used by the generated theorems: propext.
- The annotation pipeline checks these translations itself, so agreement was the expected outcome. The 41 rejections are the known kinds of exception (selenocysteine, start codons outside the table, stop codons completed by polyadenylation); the 70 records without a statement are MANE Select transcripts of non-coding genes.
- Kaggle CPU session time: level-K sessions 7.74 h in total (k0 0.18 h, k1 4.79 h, k2 2.77 h), preparation session 1.62 h. Each session had 4 virtual CPUs.

## 2. What was run

| session | kernel | what | cpu | virtual CPUs | started_utc | session s |
|---|---|---|---|---|---|---|
| s1 | gn-gene-library-session-1 | sources, parsing, level X, Python and Biopython checks, timing set | AMD EPYC 7B12 | 4 | 2026-11-21T13:29:10Z | 5818 |
| k0 | gn-gene-library-level-k-session-0 | rehearsal: first 500 records of the order, negative controls, hand-written file | Intel(R) Xeon(R) CPU @ 2.20GHz | 4 | 2026-11-21T17:02:03Z | 659 |
| k1 | gn-gene-library-level-k-session-1 | level-K bulk build, negative controls, hand-written file, axioms sample | Intel(R) Xeon(R) CPU @ 2.20GHz | 4 | 2026-11-21T17:16:13Z | 17235 |
| k2 | gn-gene-library-level-k-session-2 | level-K bulk build (continued), stop-completion file, negative controls, hand-written file, axioms sample | Intel(R) Xeon(R) CPU @ 2.20GHz | 4 | 2026-11-22T00:01:20Z | 9971 |

All sessions are private Kaggle CPU script notebooks of account `bogdandidenko`, internet on, at most one running at a time. Lean: `Lean (version 4.36.0, x86_64-unknown-linux-gnu, commit 611c117bfaf7b7ae1cfcf246ce6fba31e8f509e9, Release)`, archive `lean-4.36.0-linux.tar.zst` from the GitHub release, sha256 `2b7ab1ed8b92d2e6abfaf41344823b510064dbc9c0260cac73eb496ab2dea6eb` (same in every session). The frozen kernel archive `biocore_v0_1.tgz` (sha256 `8bd9fa5a7996fd84a88e4d0444db982ea3adb6115b99138a851c1d0d0e8c3368`) came from a private dataset; its files were re-checked against `KERNEL_SHA256.txt` in every session (all OK) and built with the frozen `lakefile.toml` (3.66 s in session s1). No frozen file was edited.

Sources, downloaded inside session s1:

| file | bytes | sha256 | last_modified |
|---|---|---|---|
| README_versions.txt | 96 | 2c9c872e8d1669e4989a0bc97220137e30fcdcd6fb1ea5cda8cde58665d1b3e7 | Thu, 04 Dec 2025 19:59:16 GMT |
| MANE.GRCh38.v1.5.refseq_rna.gbff.gz | 86563420 | c7cfa52db191ecd43c20b5817ee7ab6164c5bb292cb8128ab6f6a1cd0aaf5989 | Thu, 04 Dec 2025 19:52:42 GMT |
| MANE.GRCh38.v1.5.summary.txt.gz | 1115288 | d10ace2720681a3b2e0eefd9da4f551274a6b4141ac9bfd6a2565dfb6e9ad55c | Thu, 04 Dec 2025 19:53:44 GMT |
| NC_012920.1.gb | 64640 | 7530d659e7174272372814edfecb2ece1f87a444395a861fcdf1b977c4aa5c1f |  |
| gc.prt | 16444 | 2aecbdd09ecc5e0d233c105090a593737298ef93d88f6bc0c1bef26df6051a04 | Wed, 10 Jun 2020 17:12:15 GMT |
| MANE_current_listing.html | 2413 | c7a4cb75b30481e8c218c8cc4a061b60dd6016013b905a4e1bc8ca71b8bdbc1d |  |

MANE `README_versions.txt`: MANE Version 1.5; NCBI RefSeq Annotation Release GCF_000001405.40-RS_2025_08; Ensembl Release 116. `gc.prt` is byte-identical to the copy in the kernel archive: True. The level-K sessions downloaded the five data sources again and found the same sha256 in every case: True.

Added files (none of them a kernel file): `BioCore/Library/Genes/Pack.lean`, `DecodeMain.lean`, `Chain.lean`, `StopCompletion.lean`, `Rec/*.lean` (one module per record), `Batch/*.lean` (import lists), the root `BioCoreLibraryGenes.lean`, `GenesAudit.lean`, `lakefile_gn.toml` (a COPY of the frozen lakefile with one library target, one program target and a larger thread stack added; used with `lake -f lakefile_gn.toml`), and `tools/gn_*.py`.

## 3. Scope and classes (level X: computed, not proved)

| group | ACCEPTED_EQUAL | ACCEPTED_DIFFERENT | REJECTED | NOT_EXPRESSIBLE | all |
|---|---|---|---|---|---|
| MITO | 7 | 0 | 6 | 0 | 13 |
| PLUS_CLINICAL | 74 | 0 | 0 | 0 | 74 |
| SELECT | 19258 | 0 | 35 | 70 | 19363 |
| all | 19339 | 0 | 41 | 70 | 19450 |

The MANE summary file has 19437 rows (MANE Select: 19363, MANE Plus Clinical: 74); the flat file has 19437 records, each matched to one summary row (0 flat-file records outside the summary). The mitochondrial record has 13 CDS features.

**Agreement of the two level-X implementations.** Lean program (kernel `revComp`, `transcribe`, `decodeCDS`, `standardCode` / `vertMitoCode`) against Python (tables 1 and 2 read from `gc.prt`): 19380 agreements on (verdict, reason, position, protein), 0 disagreements, of 19380 records given to the kernel.

**Third opinion (Biopython 1.88).** Its GenBank parser gave the same CDS feature count, `/translation`, record length and coding stretch as the parser of this track for 19450 of 19450 records (0 mismatches). Its `translate` agreed with the kernel protein from the second codon on, and ended in a stop, for 19339 of 19339 accepted records (0 mismatches).

### 3.1 ACCEPTED_DIFFERENT

None.

### 3.2 REJECTED: all 41 records

| group | kernel reject reason | annotation category | n |
|---|---|---|---|
| MITO | notWholeCodons | incomplete_stop_codon | 6 |
| SELECT | badStart | other_transl_except; non_AUG_start | 5 |
| SELECT | badStart | other_transl_except; non_AUG_start; other | 4 |
| SELECT | internalStop | selenocysteine | 23 |
| SELECT | internalStop | selenocysteine; non_AUG_start | 1 |
| SELECT | internalStop | selenocysteine; stop_codon_readthrough | 1 |
| SELECT | notWholeCodons | incomplete_stop_codon | 1 |

Position is the codon index (start codon = 0). For every `internalStop` the rejected codon is TGA and a `/transl_except` of the annotation names exactly that codon in 25 of 25 cases. The kernel reports the first internal stop only (SELENOP has ten annotated selenocysteine codons).

In the last column, PROVED means that the theorem `decodeCDS … = .rejected <reason>` for this record was accepted by the kernel (level K); the seconds are the build time of its module.

| group | gene | record | CDS bases | reject | first codon | category | annotation says (quoted) | level K |
|---|---|---|---|---|---|---|---|---|
| MITO | COX3 | NC_012920.1:COX3 | 784 | notWholeCodons | ATG | incomplete_stop_codon | /transl_except=(pos:9990,aa:TERM) /note="cytochrome c oxidase III; TAA stop codon is completed by the addition of 3' A residues to the mRNA" | PROVED 1.7 s |
| MITO | CYTB | NC_012920.1:CYTB | 1141 | notWholeCodons | ATG | incomplete_stop_codon | /transl_except=(pos:15887,aa:TERM) /note="TAA stop codon is completed by the addition of 3' A residues to the mRNA" | PROVED 2.4 s |
| MITO | ND1 | NC_012920.1:ND1 | 956 | notWholeCodons | ATA | incomplete_stop_codon | /transl_except=(pos:4261..4262,aa:TERM) /note="NADH dehydrogenase, subunit 1 (complex I); TAA stop codon is completed by the addition of 3' A residues to the mRNA" | PROVED 2 s |
| MITO | ND2 | NC_012920.1:ND2 | 1042 | notWholeCodons | ATT | incomplete_stop_codon | /transl_except=(pos:5511,aa:TERM) /note="TAA stop codon is completed by the addition of 3' A residues to the mRNA" | PROVED 2.4 s |
| MITO | ND3 | NC_012920.1:ND3 | 346 | notWholeCodons | ATA | incomplete_stop_codon | /transl_except=(pos:10404,aa:TERM) /note="NADH dehydrogenase, subunit 3 (complex I); TAA stop codon is completed by the addition of 3' A residues to the mRNA" | PROVED 1.1 s |
| MITO | ND4 | NC_012920.1:ND4 | 1378 | notWholeCodons | ATG | incomplete_stop_codon | /transl_except=(pos:12137,aa:TERM) /note="NADH dehydrogenase, subunit 4 (complex I); TAA stop codon is completed by the addition of 3' A residues to the mRNA" | PROVED 2.8 s |
| SELECT | EIF4G2 | NM_001418.4 | 2724 | badStart | GTG | other_transl_except; non_AUG_start | /transl_except=(pos:309..311,aa:Met) /note="isoform 1 is encoded by transcript variant 1; non-AUG (GUG) translation initiation codon; eIF-4-gamma 2; eukaryotic translation initiation factor 4G-like 1; death-associated protein 5; aging-associated protein 1; DAP-5; eIF4G 2; eIF-4G 2" RefSeq-Attributes: non-AUG initiation codon :: PMID: 9049310, 15718103 | PROVED 6.6 s |
| SELECT | KCTD11 | NM_001363642.1 | 816 | badStart | ATT | other_transl_except; non_AUG_start; other | /transl_except=(pos:665..667,aa:Met) /exception="alternative start codon" /note="isoform l is encoded by transcript variant 1b; non-AUG (AUU) translation initiation codon; BTB/POZ domain-containing protein KCTD11; retinoic acid, EGF, NGF induced gene protein; RING-type E3 ubiquitin transferase subunit KCTD11; potassium channel tetramerization domain-containing protein 11" RefSeq-Attributes: non-AUG initiation codon :: PMID: 21237243 | PROVED 1.7 s |
| SELECT | MRTFA | NM_020831.6 | 3096 | badStart | GTG | other_transl_except; non_AUG_start | /transl_except=(pos:326..328,aa:Met) /note="isoform 5 is encoded by transcript variant 1; non-AUG (GUG) translation initiation codon; MKL/myocardin-like protein 1; basic, SAP and coiled-coil domain; megakaryoblastic leukemia 1 protein; megakaryocytic acute leukemia protein; megakaryoblastic leukemia (translocation) 1; alternative protein MKL1" RefSeq-Attributes: non-AUG initiation codon :: inferred from conservation | PROVED 7.3 s |
| SELECT | PRPS1L1 | NM_175886.3 | 957 | badStart | ACG | other_transl_except; non_AUG_start; other | /transl_except=(pos:65..67,aa:Met) /exception="alternative start codon" /note="non-AUG (ACG) translation initiation codon; phosphoribosylpyrophosphate synthetase subunit III; ribose-phosphate diphosphokinase catalytic chain III; ribose-phosphate pyrophosphokinase III; PRPS1-like 1; phosphoribosyl pyrophosphate synthase III; phosphoribosyl pyrophosphate synthase 1-like 1" RefSeq-Attributes: non-AUG initiation codon :: PMID: 2168892 | PROVED 2.1 s |
| SELECT | RESP18 | NM_001441699.1 | 561 | badStart | ATA | other_transl_except; non_AUG_start | /transl_except=(pos:116..118,aa:Met) /note="isoform 1 precursor is encoded by transcript variant 1; non-AUG (AUA) translation initiation codon; regulated endocrine-specific protein 18 homolog" RefSeq-Attributes: non-AUG initiation codon :: inferred from conservation | PROVED 1.3 s |
| SELECT | TEAD1 | NM_021961.6 | 1281 | badStart | ATT | other_transl_except; non_AUG_start; other | /transl_except=(pos:622..624,aa:Met) /exception="alternative start codon" /note="non-AUG (AUU) translation initiation codon; protein GT-IIC; transcriptional enhancer factor 1; transcription factor 13; TEA domain family member 1 (SV40 transcriptional enhancer factor)" RefSeq-Attributes: non-AUG initiation codon :: PMID: 1851669 | PROVED 2.3 s |
| SELECT | TEAD3 | NM_003214.4 | 1308 | badStart | ATA | other_transl_except; non_AUG_start | /transl_except=(pos:232..234,aa:Met) /note="isoform 1 is encoded by transcript variant 1; non-AUG (AUA) translation initiation codon; TEA domain family member 5; transcriptional enhancer factor 5; transcriptional enhancer factor TEF-5 (DTEF-1); TEA domain family member 3" RefSeq-Attributes: non-AUG initiation codon :: PMID: 10379887 | PROVED 2.2 s |
| SELECT | TRPV6 | NM_018646.6 | 2298 | badStart | ACG | other_transl_except; non_AUG_start; other | /transl_except=(pos:110..112,aa:Met) /exception="alternative start codon" /note="non-AUG (ACG) translation initiation codon; epithelial calcium channel 2; epithelial apical membrane calcium transporter/channel CaT1; Alu-binding protein with zinc finger domain; calcium transport protein 1; calcium transporter-like protein" RefSeq-Attributes: non-AUG initiation codon :: PMID: 23612980 | PROVED 5.7 s |
| SELECT | WDR26 | NM_001379403.1 | 2286 | badStart | ACG | other_transl_except; non_AUG_start | /transl_except=(pos:393..395,aa:Met) /note="isoform c is encoded by transcript variant 3; non-AUG (ACG) translation initiation codon; CUL4- and DDB1-associated WDR protein 2; myocardial ischemic preconditioning upregulated protein 2; GID complex subunit 7 homolog" RefSeq-Attributes: non-AUG initiation codon :: inferred from conservation | PROVED 4.7 s |
| SELECT | DIO1 | NM_000792.7 | 750 | internalStop 125 | ATG | selenocysteine | /transl_except=(pos:400..402,aa:Sec) /note="UGA stop codon recoded as selenocysteine; isoform a is encoded by transcript variant 1; thyroxine deiodinase type I (selenoprotein); DIOI; type 1 DI; type-I 5'-deiodinase; iodothyronine deiodinase type 1; thyroxine 5'-deiodinase; deiodinase, iodothyronine type I; selenoprotein DIO1" RefSeq-Attributes: protein contains selenocysteine :: PMID: 1400883, 12775843 | PROVED 1.7 s |
| SELECT | DIO2 | NM_013989.5 | 822 | internalStop 132 | ATG | selenocysteine | /transl_except=(pos:429..431,aa:Sec) /transl_except=(pos:828..830,aa:Sec) /note="isoform a is encoded by transcript variant 1; thyroxine deiodinase, type II; type-II 5'deiodinase; type 2 iodothyronine deiodinase; type 2 DI; type-II 5'-deiodinase; deiodinase-2; deiodonase-2; selenoprotein Y; deiodinase, iodothyronine type II" RefSeq-Attributes: protein contains selenocysteine :: PMID: 9837913, 10403186 | PROVED 1.9 s |
| SELECT | DIO3 | NM_001362.4 | 915 | internalStop 169 | ATG | selenocysteine | /transl_except=(pos:510..512,aa:Sec) /note="UGA stop codon recoded as selenocysteine; type 3 iodothyronine selenodeiodinase; type-III 5' deiodinase; iodothyronine deiodinase, placental type; thyroxine deiodinase type III (selenoprotein); type 3 DI; deiodinase, iodothyronine type III; selenoprotein DIO3" RefSeq-Attributes: protein contains selenocysteine :: PMID: 7593630 | PROVED 2.4 s |
| SELECT | GPX1 | NM_000581.4 | 612 | internalStop 48 | ATG | selenocysteine | /transl_except=(pos:220..222,aa:Sec) /note="UGA stop codon recoded as selenocysteine; isoform 1 is encoded by transcript variant 1; cellular glutathione peroxidase; GSHPx-1; selenoprotein GPX1; phospholipid-hydroperoxide glutathione peroxidase GPX1" RefSeq-Attributes: protein contains selenocysteine :: PMID: 2955287 | PROVED 1.4 s |
| SELECT | GPX2 | NM_002083.4 | 573 | internalStop 39 | ATG | selenocysteine | /transl_except=(pos:137..139,aa:Sec) /note="UGA stop codon recoded as selenocysteine; glutathione peroxidase-related protein 2; glutathione peroxidase 2 (gastrointestinal); selenoprotein GPX2; gastrointestinal glutathione peroxidase; phospholipid hydroperoxide glutathione peroxidase GPX2" RefSeq-Attributes: protein contains selenocysteine :: PMID: 2388849 | PROVED 2.4 s |
| SELECT | GPX3 | NM_002084.5 | 681 | internalStop 72 | ATG | selenocysteine | /transl_except=(pos:281..283,aa:Sec) /note="UGA stop codon recoded as selenocysteine; isoform 1 precursor is encoded by transcript variant 1; extracellular glutathione peroxidase; glutathione peroxidase 3 (plasma); GPx-3; plasma glutathione peroxidase; selenoprotein GPX3" RefSeq-Attributes: protein contains selenocysteine :: PMID: 2229017 | PROVED 2 s |
| SELECT | GPX4 | NM_002085.5 | 594 | internalStop 72 | ATG | selenocysteine | /transl_except=(pos:267..269,aa:Sec) /note="UGA stop codon recoded as selenocysteine; isoform A precursor is encoded by transcript variant 1; phospholipid hydroperoxidase; sperm nucleus glutathione peroxidase; phospholipid hydroperoxide glutathione peroxidase, mitochondrial; epididymis secretory sperm binding protein; selenoprotein GPX4; phospholipid hydroperoxide glutathione peroxidase GPX4" RefSeq-Attributes: gene product(s) localized to mito. :: reported by MitoCarta ; multifunctional gene product(s) :: PMID: 11898409 ; protein contains selenocysteine :: PMID: 8039723 | PROVED 1.5 s |
| SELECT | GPX6 | NM_182701.1 | 666 | internalStop 72 | ATG | selenocysteine | /transl_except=(pos:267..269,aa:Sec) /note="UGA stop codon recoded as selenocysteine; glutathione peroxidase 6 (olfactory); selenoprotein GPX6" RefSeq-Attributes: protein contains selenocysteine :: PMID: 12775843 | PROVED 1.5 s |
| SELECT | MSRB1 | NM_016332.4 | 351 | internalStop 94 | ATG | selenocysteine | /transl_except=(pos:326..328,aa:Sec) /note="UGA stop codon recoded as selenocysteine; isoform 1 is encoded by transcript variant 1; selenoprotein R; methionine-R-sulfoxide reductase B1; selenoprotein X, 1" RefSeq-Attributes: protein contains selenocysteine :: PMID: 10567350, 10608886 | PROVED 1.2 s |
| SELECT | SELENOF | NM_004261.5 | 498 | internalStop 95 | ATG | selenocysteine | /transl_except=(pos:301..303,aa:Sec) /note="UGA stop codon recoded as selenocysteine; isoform 1 precursor is encoded by transcript variant 1; 15 kDa selenoprotein" RefSeq-Attributes: protein contains selenocysteine :: PMID: 9535873, 10945981 | PROVED 1.8 s |
| SELECT | SELENOH | NM_170746.4 | 369 | internalStop 43 | ATG | selenocysteine | /transl_except=(pos:235..237,aa:Sec) /note="UGA stop codon recoded as selenocysteine" RefSeq-Attributes: protein contains selenocysteine :: PMID: 12775843 | PROVED 1.9 s |
| SELECT | SELENOI | NM_033505.4 | 1194 | internalStop 386 | ATG | selenocysteine | /transl_except=(pos:1249..1251,aa:Sec) /note="UGA stop codon recoded as selenocysteine; hEPT1; ethanolaminephosphotransferase 1 (CDP-ethanolamine-specific)" RefSeq-Attributes: protein contains selenocysteine :: PMID: 12775843 | PROVED 4.5 s |
| SELECT | SELENOK | NM_021237.5 | 285 | internalStop 91 | ATG | selenocysteine | /transl_except=(pos:345..347,aa:Sec) /note="UGA stop codon recoded as selenocysteine" RefSeq-Attributes: protein contains selenocysteine :: PMID: 12775843 | PROVED 1.1 s |
| SELECT | SELENOM | NM_080430.4 | 438 | internalStop 47 | ATG | selenocysteine | /transl_except=(pos:205..207,aa:Sec) /note="UGA stop codon recoded as selenocysteine; selenoprotein SelM" RefSeq-Attributes: protein contains selenocysteine :: PMID: 11839807 | PROVED 1.2 s |
| SELECT | SELENON | NM_206926.2 | 1671 | internalStop 427 | ATG | selenocysteine | /transl_except=(pos:1320..1322,aa:Sec) /note="UGA stop codon recoded as selenocysteine; isoform 1 is encoded by transcript variant 1; selenoprotein N, 1" RefSeq-Attributes: protein contains selenocysteine :: PMID: 10608886 | PROVED 4.4 s |
| SELECT | SELENOO | NM_031454.2 | 2010 | internalStop 666 | ATG | selenocysteine | /transl_except=(pos:2025..2027,aa:Sec) /note="UGA stop codon recoded as selenocysteine" RefSeq-Attributes: gene product(s) localized to mito. :: PMID: 24751718 ; protein contains selenocysteine :: PMID: 12775843 | PROVED 6.7 s |
| SELECT | SELENOP | NM_005410.4 | 1146 | internalStop 58 | ATG | selenocysteine | /transl_except=(pos:245..247,aa:Sec) /transl_except=(pos:968..970,aa:Sec) /transl_except=(pos:1022..1024,aa:Sec) /transl_except=(pos:1058..1060,aa:Sec) /transl_except=(pos:1103..1105,aa:Sec) /transl_except=(pos:1124..1126,aa:Sec) /transl_except=(pos:1169..1171,aa:Sec) /transl_except=(pos:1175..1177,aa:Sec) /transl_except=(pos:1196..1198,aa:Sec) /transl_except=(pos:1202..1204,aa:Sec) /note="UGA stop codons recoded as selenocysteine; isoform 1 precursor is encoded by transcript variant 1; selenoprotein P, plasma, 1" RefSeq-Attributes: protein contains selenocysteine :: PMID: 8421687 | PROVED 2.9 s |
| SELECT | SELENOS | NM_018445.6 | 570 | internalStop 187 | ATG | selenocysteine | /transl_except=(pos:630..632,aa:Sec) /note="UGA stop codon recoded as selenocysteine; isoform 1 is encoded by transcript variant 1; VCP-interacting membrane protein; valosin-containing protein-interacting membrane protein; VCP interacting membrane selenoprotein; tanis" RefSeq-Attributes: protein contains selenocysteine :: PMID: 12775843, 23614019 | PROVED 1.8 s |
| SELECT | SELENOT | NM_016275.5 | 588 | internalStop 48 | ATG | selenocysteine | /transl_except=(pos:187..189,aa:Sec) /note="UGA stop codon recoded as selenocysteine; thioredoxin reductase-like enzyme; thioredoxin reductase-like selenoprotein T" RefSeq-Attributes: protein contains selenocysteine :: PMID: 10567350 | PROVED 1.3 s |
| SELECT | SELENOV | NM_182704.2 | 1041 | internalStop 272 | ATG | selenocysteine; stop_codon_readthrough | /transl_except=(pos:891..893,aa:Sec) /note="UGA stop codon recoded as selenocysteine; isoform 1 is encoded by transcript variant 1" RefSeq-Attributes: protein contains selenocysteine :: PMID: 12775843 ; stop codon readthrough :: PMID: 12775843 | PROVED 2.9 s |
| SELECT | SELENOW | NM_003009.4 | 264 | internalStop 12 | ATG | selenocysteine | /transl_except=(pos:120..122,aa:Sec) /note="UGA stop codon recoded as selenocysteine; selenoprotein W, 1" RefSeq-Attributes: CDS uses downstream in-frame AUG :: community standard (PMID:9256076) ; protein contains selenocysteine :: PMID: 12818432 | PROVED 0.903 s |
| SELECT | SEPHS2 | NM_012248.4 | 1347 | internalStop 59 | ATG | selenocysteine | /transl_except=(pos:325..327,aa:Sec) /note="UGA stop codon recoded as selenocysteine; selenium donor protein 2; selenoprotein SEPHS2; selenophosphate synthase 2" RefSeq-Attributes: protein contains selenocysteine :: PMID: 8986768 | PROVED 2.6 s |
| SELECT | TXNRD1 | NM_001093771.3 | 1950 | internalStop 647 | ATG | selenocysteine | /transl_except=(pos:1966..1968,aa:Sec) /note="UGA stop codon recoded as selenocysteine; isoform 5 is encoded by transcript variant 7; KM-102-derived reductase-like factor; thioredoxin reductase GRIM-12; thioredoxin reductase 1, cytoplasmic; oxidoreductase; thioredoxin reductase TR1; gene associated with retinoic and IFN-induced mortality 12 protein; selenoprotein TXNRD1; gene associated with retinoic and interferon-induced mortality 12 protein; testis tissue sperm-binding protein Li 46a; peroxidase TXNRD1" RefSeq-Attributes: protein contains selenocysteine :: PMID: 7589432, 8650234 | PROVED 7.4 s |
| SELECT | TXNRD2 | NM_006440.5 | 1575 | internalStop 522 | ATG | selenocysteine | /transl_except=(pos:1582..1584,aa:Sec) /note="UGA stop codon recoded as selenocysteine; isoform 1 precursor is encoded by transcript variant 1; selenoprotein Z; thioredoxin reductase 3; thioredoxin reductase 2, mitochondrial; thioredoxin reductase beta; thioredoxin reductase TR3" RefSeq-Attributes: gene product(s) localized to mito. :: PMID: 10215850; reported by MitoCarta ; NMD candidate :: PMID: 9923614 ; protein contains selenocysteine :: PMID: 9923614 | PROVED 5.2 s |
| SELECT | TXNRD3 | NM_052883.3 | 1932 | internalStop 641 | CTG | selenocysteine; non_AUG_start | /transl_except=(pos:2058..2060,aa:Sec) /note="UGA stop codon recoded as selenocysteine; isoform 1 is encoded by transcript variant 1; non-AUG (CUG) translation initiation codon; thioredoxin glutathione reductase; thioredoxin reductase TR2; thioredoxin and glutathione reductase; thioredoxin reductase 3 intronic transcript 1; thioredoxin reductase 2 intronic transcript 1; thioredoxin reductase 3 new transcript 1; TXNRD3 neighbor gene protein; thioredoxin reductase 3 neighbor gene protein; selenoprotein TXNRD3" RefSeq-Attributes: non-AUG initiation codon :: inferred from conservation ; protein contains selenocysteine :: PMID: 10455115 | PROVED 6.2 s |
| SELECT | TMEM247 | NM_001424184.1 | 659 | notWholeCodons | ATG | incomplete_stop_codon | /transl_except=(pos:679..680,aa:TERM) /note="stop codon completed by the addition of 3' A residue to the mRNA; transmembrane protein ENSP00000343375" RefSeq-Attributes: polyA required for stop codon :: translation inferred | PROVED 1.4 s |

### 3.3 NOT_EXPRESSIBLE: 70 records

| group | not_expressible_reason | n |
|---|---|---|
| SELECT | CDS_FEATURE_COUNT_0 | 70 |

All 70 are MANE Select transcripts of non-coding genes (accession prefix NR): the flat-file record has no CDS feature, so there is no coding sequence to decode. Gene symbols: ATXN8OS, BACE1-AS, CCAT2, CCR5AS, CDKN2B-AS1, CISTR, DBET, FALEC, GAS5, GNAS-AS1, H19, HOTAIR, HTT-AS, HULC, IFNG-AS1, IKBKB-DT, KCNQ1OT1, LINC00237, LINC00305, LINC00632, LINC01488, LINC02747, LRP1-AS, MALAT1, MEG3, MIAT, MIR17HG, MIR2052HG, NEAT1, NR2F1-AS1, OVAAL, PCA3, PCAT6, PCAT7, PTCSC3, PVT1, RMRP, RMST, RNU1-1, RNU1-2, RNU1-3, RNU1-4, RNU11, RNU12, RNU2-1, RNU2-2, RNU2-63P, RNU4-1, RNU4-2, RNU4ATAC, RNU5A-1, RNU5B-1, RNU5D-1, RNU5E-1, RNU6-1, RNU6-2, RNU6-7, RNU6-8, RNU6-9, RNU6ATAC, RNU7-1, SAMMSON, SCAANT1, SMN1-AS1, SNHG17, SNORD118, SORL1-AS1, TERC, TUSC7, XIST.

No record had a joined or partial CDS location, a `/codon_start` other than 1, or a letter outside A, C, G, T. Genes whose protein depends on ribosomal slippage and whose CDS is a join in RefSeq (PEG10, OAZ1, OAZ2, OAZ3) are not in the MANE summary file of this release: True.

### 3.4 Annotated peculiarities among ACCEPTED_EQUAL records

First codon of the accepted records:

| group | first codon (DNA) | n |
|---|---|---|
| MITO | ATA | 1 |
| MITO | ATG | 6 |
| PLUS_CLINICAL | ATG | 74 |
| SELECT | ATG | 19231 |
| SELECT | CTG | 25 |
| SELECT | TTG | 2 |

The standard table of the kernel (NCBI table 1) lists UUG, CUG and AUG as start codons and the kernel reads a start codon as Met, so the 27 nuclear records that start with CTG or TTG are accepted and equal to the annotation: BAG1 (CTG), C16orf82 (CTG), CACNG8 (CTG), DDX17 (CTG), GTF3A (CTG), HCK (CTG), HMHB1 (CTG), MORN2 (CTG), MYC (CTG), NELFB (CTG), NFKBID (CTG), NPTXR (CTG), NPW (CTG), NR1I2 (CTG), PANK2 (CTG), PIGX (CTG), POLGARF (CTG), R3HCC1 (CTG), RNF187 (CTG), SLC22A17 (CTG), STIM2 (TTG), SWI5 (CTG), TEAD4 (TTG), TUG1 (CTG), UFSP1 (CTG), VEGFA (CTG), WT1 (CTG). Whether a ribosome starts there is not something the kernel knows; it accepts any CUG or UUG first codon.

Annotation categories of the accepted records (keyword rules of the choices file):

| category | n |
|---|---|
| RNA_editing | 26 |
| non_AUG_start | 26 |
| non_AUG_start; RNA_editing | 1 |
| none_given | 19285 |
| ribosomal_slippage | 1 |

`RNA_editing` here is a RefSeq attribute of the gene ("undergoes RNA editing"); the flat-file CDS of these records decodes to the annotated protein, so the record describes one form. The one `ribosomal_slippage` hit (SHFL) is a false positive of the keyword rule: the words occur in a protein name ("inhibitor of ribosomal frameshifting protein"). 

## 4. Level K (proved by the kernel)

### 4.1 Statements

One Lean module per record, e.g. for an ACCEPTED_EQUAL record:

```lean
noncomputable def NM_000207_3.cds : List DNt := [DNt.A, DNt.T, DNt.G, …]       -- the annotated stretch
noncomputable def NM_000207_3.protein : List AA := [AA.M, AA.A, AA.L, …]        -- /translation of the flat file
theorem NM_000207_3.decodes :
    decodeCDS standardCode (transcribe NM_000207_3.cds) = .ok NM_000207_3.protein := by decide +kernel
```

For a REJECTED record the theorem is `decodeCDS … (transcribe X.cds) = .rejected <reason>`; for the mitochondrial gene on the other strand (ND6) `X.cds` is the kernel's `revComp` of the annotated stretch. The protein literal of an accepted record is written from the `/translation` string, not from the output of the level-X program. NOT_EXPRESSIBLE records have no statement.

### 4.2 Timing set (session s1, 20 records, each as its own Lean process, wall seconds)

| CDS bases | record | M1 s | M2 s | M3 s |
|---|---|---|---|---|
| 39 | NM_001416403.1 | 0.31 | 0.29 | 0.44 |
| 369 | NM_002622.5 | 0.65 | 0.50 | 0.51 |
| 501 | NM_006507.4 | 0.74 | 0.57 | 0.59 |
| 618 | NM_001258217.2 | 0.81 | 0.64 | 0.64 |
| 729 | NM_012217.3 | 0.93 | 0.69 | 0.70 |
| 843 | NM_015703.5 | 0.99 | 0.81 | 0.76 |
| 939 | NM_024570.4 | 1.04 | 0.86 | 0.75 |
| 1020 | NM_001080825.2 | 1.15 | 0.93 | 0.87 |
| 1122 | NM_003475.4 | 1.20 | 0.98 | 0.89 |
| 1239 | NM_003173.4 | 1.28 | 1.05 | 0.96 |
| 1362 | NM_001256317.3 | 1.33 | 1.10 | 1.04 |
| 1485 | NM_001098507.2 | 1.43 | 1.19 | 1.05 |
| 1617 | NM_021021.4 | 1.57 | 1.25 | 1.16 |
| 1788 | NM_005257.6 | 1.67 | 1.32 | 1.25 |
| 2019 | NM_023083.4 | 1.90 | 1.53 | 1.34 |
| 2295 | NM_021826.5 | 2.06 | 1.73 | 1.48 |
| 2688 | NM_182552.5 | 2.35 | 1.99 | 1.66 |
| 3264 | NM_001111020.3 | 2.86 | 2.26 | 2.06 |
| 4401 | NM_000090.4 | 3.87 | 3.15 | 2.54 |
| 107976 | NM_001267550.2 | 220.12 | 209.92 | 3600.20 (limit reached, not built) |

M1 = list literals + `decide`; M2 = list literals + `decide +kernel`; M3 = packed number literals with the decoder of `Pack.lean` + `decide +kernel`. Outcome of the declared rule (amendment 1): M2 primary (sum over the 20 records 232.7 s against 248.3 s for M1); projection for the scope 1.94 h at 4 jobs. The compact encoding was not needed: **no statement of the library relies on `Pack.lean`**. M3 did not finish the longest record within 3600 s.

### 4.3 Coverage

Level-K status per record: PROVED = the statement of the record's class (`= .ok protein` or `= .rejected reason`) was accepted by the kernel.

| group | class | PROVED | FAILED | NOT_REACHED | NOT_APPLICABLE |
|---|---|---|---|---|---|
| MITO | ACCEPTED_EQUAL | 7 | 0 | 0 | 0 |
| MITO | REJECTED | 6 | 0 | 0 | 0 |
| PLUS_CLINICAL | ACCEPTED_EQUAL | 74 | 0 | 0 | 0 |
| SELECT | ACCEPTED_EQUAL | 19258 | 0 | 0 | 0 |
| SELECT | NOT_EXPRESSIBLE | 0 | 0 | 0 | 70 |
| SELECT | REJECTED | 35 | 0 | 0 | 0 |
| all |  | 19380 | 0 | 0 | 70 |

- Records with a statement: 19380. Accepted by the kernel: **19380** (19380 theorems; 33913863 bases). Failed: 0. Not reached: 0. No statement (NOT_EXPRESSIBLE): 70.
- Methods used: {'M2': 19380}. Fallbacks used: 0.
- Order: the 41 records that are not ACCEPTED_EQUAL first, then ascending sha256 of the identifier, as declared.
- Batches: 78 batches of up to 250 records, each built with one `lake -f lakefile_gn.toml build` call on its import list; every batch root compiled: True.

### 4.4 Cost and throughput

- Main sessions (k1, k2): 27206 s of session time (7.56 h), of which 27023 s in the batch loop; 19380 records, i.e. 2582 records per session hour and 1255 bases per second of session time, with 4 jobs on 4 virtual CPUs (Intel(R) Xeon(R) CPU @ 2.20GHz).
- Module build time reported by lake (4 jobs running, so each job is slower than alone): sum 94847 s, median 2.80 s, mean 4.89 s, 95th percentile 13.0 s, maximum 2574 s.
- Including the rehearsal (k0) the level-K session time is 27865 s = 7.74 h, i.e. about 31.0 virtual-CPU hours. The preparation session s1 took 5818 s, of which 3600 s was the M3 attempt on the longest record and 1580 s the lake test of the timing set.
- Slowest modules:

| gene | record | CDS bases | module build s |
|---|---|---|---|
| TTN | NM_001267550.2 | 107976 | 2574.0 |
| MUC16 | NM_001401501.2 | 46050 | 555.0 |
| NEB | NM_001164508.2 | 25578 | 242.0 |
| MACF1 | NM_001394062.1 | 22668 | 225.0 |
| OBSCN | NM_001386125.1 | 26778 | 209.0 |

The longest record (TTN, 107976 bases) took 210 s as its own process without output files (session s1) and 2574 s as a module inside `lake build`, which also writes the compiled files and ran with three other jobs; the cause of the difference was not investigated. The cost per base grows with length.

### 4.5 Axioms audit

- Every generated module ends with `#print axioms` for each theorem; the lines were read from the build log of every module. Theorems audited: 19380. Union of axioms: **propext**.
- Declared random sample (the 200 accepted records with the smallest sha256 of `"gn-axioms-sample-v1|" + identifier`): 200 records, 200 theorems, union propext. All 200 were also re-queried from an audit file that imports the compiled modules (125 of them in session k1, 75 in session k2, each in the session that compiled the module), with the same result.
- Hand-written theorems (`Chain.lean`, and the lemmas of `Pack.lean`): 20 theorems audited, union Classical.choice, Quot.sound, propext. Per theorem: `Chain.INS.decoding` [propext]; `Chain.INS.rna_balanced` [Classical.choice, Quot.sound, propext]; `Chain.INS.protein_balanced` [Classical.choice, Quot.sound, propext]; `Chain.INS.chain` [Classical.choice, Quot.sound, propext]; `Chain.TP53.decoding` [propext]; `Chain.TP53.rna_balanced` [Classical.choice, Quot.sound, propext]; `Chain.TP53.protein_balanced` [Classical.choice, Quot.sound, propext]; `Chain.TP53.chain` [Classical.choice, Quot.sound, propext]; `Chain.BRCA1.decoding` [propext]; `Chain.BRCA1.rna_balanced` [Classical.choice, Quot.sound, propext]; `Chain.BRCA1.protein_balanced` [Classical.choice, Quot.sound, propext]; `Chain.BRCA1.chain` [Classical.choice, Quot.sound, propext]; `Chain.INS.not_TP53` [propext]; `unpackDNAAux_length` [Quot.sound, propext]; `unpackDNA_length` [Quot.sound, propext]; `unpackAAAux_length` [Quot.sound, propext]; `unpackAA_length` [Quot.sound, propext]; `Chain.INS.transcription` [no axioms]; `Chain.TP53.transcription` [no axioms]; `Chain.BRCA1.transcription` [no axioms].
- Stop-completion theorems: 7 theorems, union propext.
- **Union over everything: Classical.choice, Quot.sound, propext.** No `sorry`, no `native_decide`, no added axiom.

### 4.6 Negative controls (false statements; must be refused)

18 runs over the sessions, 18 refused, 18 with Lean's message that `decide` proved the proposition false. Kinds: wrong last residue claimed for an ACCEPTED_EQUAL record: 9; REJECTED record claimed to decode to the annotated protein: 9. They are not part of the library.

### 4.7 Hand-written file `BioCore/Library/Genes/Chain.lean`

Genes named in the choices file before any data was read: INS (NM_000207.3, 333 bases, 110 residues), TP53 (NM_000546.6, 1182 bases, 393 residues), BRCA1 (NM_007294.4, 5592 bases, 1863 residues). For each: `X.codingStrand`, `X.rna`, `X.protein`; `X.transcription : transcribe X.codingStrand = X.rna`; `X.decoding : decodeCDS standardCode X.rna = .ok X.protein`; `X.rna_balanced : Balanced (transcriptionRxn X.rna)` and `X.protein_balanced : Balanced (peptideRxn X.protein)`, both instances of the general theorems `transcription_balanced` and `peptide_balanced` (nothing computed per gene); and `X.chain`, the three facts about the coding strand in one statement. One more theorem, `INS.not_TP53`, states that the INS coding strand does not decode to the TP53 protein. The sequence literals were pasted by `tools/gn_fill_chain.py`; statements and proofs were written by hand. Built on Kaggle in 19 s, 23 s, 21 s (one build per session, exit 0 each time). The RNA here is the coding region only: the kernel has no splicing and no untranslated regions.

### 4.8 Extra: stop codons completed by polyadenylation (no kernel change needed)

For the records rejected as `notWholeCodons`, the file `StopCompletion.lean` states `decodeCDS <code> (transcribe X.cds ++ [RNt.A, …]) = .ok X.annotated`: the annotated stretch, transcribed, with the missing one or two adenines added at the 3' end, decodes under the unchanged kernel to the annotated protein. These are additional theorems; the class of the records stays REJECTED, because the stretch as annotated is rejected. This step was added after the classes were known (it is not in the choices file).

| group | gene | record | CDS bases | adenines added | Python (level X): equals annotation | theorem accepted (level K) | axioms |
|---|---|---|---|---|---|---|---|
| MITO | ND3 | NC_012920.1:ND3 | 346 | 2 | True | True | propext |
| SELECT | TMEM247 | NM_001424184.1 | 659 | 1 | True | True | propext |
| MITO | ND2 | NC_012920.1:ND2 | 1042 | 2 | True | True | propext |
| MITO | CYTB | NC_012920.1:CYTB | 1141 | 2 | True | True | propext |
| MITO | ND1 | NC_012920.1:ND1 | 956 | 1 | True | True | propext |
| MITO | COX3 | NC_012920.1:COX3 | 784 | 2 | True | True | propext |
| MITO | ND4 | NC_012920.1:ND4 | 1378 | 2 | True | True | propext |

### 4.9 The library archive

`gn_library.tgz` (33016647 bytes, sha256 `053729ecd509746aa3c12f43fa69aa0355f169f24572a8e3c5489f4b0d723e1a`) holds 19477 files: 19380 record modules, 78 batch import lists, `Pack.lean`, `DecodeMain.lean`, `Chain.lean`, `StopCompletion.lean`, the root `BioCoreLibraryGenes.lean`, `GenesAudit.lean`, `lakefile_gn.toml`, the choices file with its amendments and `tools/`. The record modules are byte for byte the files compiled on Kaggle (taken from each session's own source archive; 20 files present in two sessions were identical). Unpack it over the frozen BioCore 0.1 tree and run `lake -f lakefile_gn.toml build BioCoreLibraryGenes`.

**Build time and machine.** The library was built batch by batch on Kaggle CPU notebooks (4 virtual CPUs, Intel(R) Xeon(R) CPU @ 2.20GHz, 32 GB): 27023 s = 7.51 h for the 78 batches over 2 sessions, plus 44 s for `Chain.lean` (once per session). The root file `BioCoreLibraryGenes.lean` (an import list of the batches) was NOT compiled as one tree: the build was split over two sessions and no session held all compiled modules. Every module it imports was compiled. Compiled files of session k1 took 2651 MB for 11500 records. A local check of the packaging on the development machine built only `Pack.lean`, `Chain.lean` and `StopCompletion.lean` with its seven record modules (built in 10.4 s, exit 0; all 10 kernel files still match KERNEL_SHA256.txt after unpacking).

## 5. What rule the kernel would need for each class of rejection

1. **`internalStop` at UGA, annotation: selenocysteine (25 records).** The standard code reads UGA as stop; in these mRNAs a SECIS element in the 3' untranslated region makes the ribosome insert selenocysteine at stated UGA codons. Needed: a decoding function that takes, besides the code, a per-transcript list of recoded positions (`recode : List (Nat × AA)`), reads the codon at each listed position as the stated amino acid, and otherwise behaves like `decodeCDS`. The list is a data axiom per transcript with its source (the `/transl_except` qualifiers). The kernel type `AA` already has `U`. One of these records (TXNRD3) also starts with CUG, which the kernel accepts; one (SELENOV) carries the attribute "stop codon readthrough", which the same rule covers.
2. **`badStart` (9 records).** First codons GUG, AUU, AUA and ACG, annotated `/transl_except=(pos:…,aa:Met)` and "non-AUG (…) translation initiation codon". NCBI table 1 has only UUG, CUG and AUG as starts. Needed: the same per-transcript exception list applied to codon 0 (read as Met although the table does not list it as a start), again as a data axiom with source. Widening the start set of the code itself would be wrong: it would accept those codons as starts in every gene.
3. **`notWholeCodons` (7 records: 6 mitochondrial, 1 nuclear).** The annotated stretch ends with T or TA and the stop codon is completed by polyadenylation. No kernel change is needed: the statement about the RNA with the adenines added is already expressible and is proved in `StopCompletion.lean` (4.8). What is missing is a definition of the mature mRNA (cleavage and polyadenylation) from which the added adenines would follow instead of being stated.
4. **Not met in this scope, but met in RefSeq**: ribosomal slippage (a joined CDS such as PEG10 or OAZ1) needs a decoding rule with a frame shift at a stated position; RNA editing needs a base-change step between transcription and decoding. Neither is expressible now.
5. **Non-coding transcripts (70 records)** need no decoding rule; they need a statement form for "this gene has no coding sequence", which is outside `decodeCDS`.

## 6. Kernel change proposals (proposals only; the kernel was not touched)

1. Add `decodeCDSWith (g : GeneticCode) (exceptions : List (Nat × AA)) (r : List RNt) : Decoded`, with `decodeCDSWith g [] r = decodeCDS g r` proved, so that selenocysteine codons and annotated non-table start codons become statements with an explicit per-transcript exception list.
2. Report all internal stops (or a count), not only the first: for SELENOP the rejection names codon 58 while ten codons are recoded.
3. Separate "can start" from "is read as Met": the kernel accepts every CUG or UUG first codon under table 1 (27 accepted records start with CTG or TTG). A stricter mode that accepts only AUG unless an exception is supplied would make the 27 cases explicit instead of silent.
4. A definition of the processed transcript (splicing by a list of exon intervals, polyadenylation), so that the coding strand is derived from a gene and the stop-completion statements follow from it.
5. Cost: `decide +kernel` on list literals took 0.71 ms per base as a single process at 4401 bases (timing set) and 2.8 ms per base of module time in the bulk build with 4 jobs running. A sequence type with a cheaper kernel representation would cut this; the compact number encoding tried here (`Pack.lean`) was only a little cheaper at ordinary lengths (2.54 s against 3.15 s at 4401 bases) and did not finish the longest record within an hour, so it is not the answer as written.

## 7. Deviations and limits

- **Scope and coverage**: none reduced. All 19450 records were classified; all 19380 records with a statement were built at level K (no NOT_REACHED).
- **Budget reading**: "about 10 Kaggle CPU hours" was read, as declared in the choices file, as about 10 hours of Kaggle CPU notebook session time for level K; 7.74 h were used (about 31 virtual-CPU hours on 4 virtual CPUs). The preparation session s1 (1.62 h, of which 1.00 h was the one M3 attempt that reached the declared limit) is outside that figure. Session k1 ran 4.79 h.
- **Changes after the choices file, each in a dated amendment written before the run it affects**: data definitions marked `noncomputable` (amendment 1); negative controls added (amendment 1); a rehearsal session k0 whose 500 records were built again in k1 (amendment 1); list elements written with their type name (amendment 2). On Kaggle the last change made no material difference (the first 500 records: 2260 s of module time in k0, 2220 s in k1).
- **Added after the classes were known**: the stop-completion theorems (4.8). They do not change any class or count.
- **Timing set versus bulk form**: the 20 timing records were measured with compiled definitions and dotted literals, the bulk modules use `noncomputable` definitions and qualified literals; the projection of amendment 1 (1.94 h) was for single processes and the bulk took longer under 4 parallel jobs.
- **Root file**: see 4.9.
- **Local development checks** (macOS toolchain, seconds each, no library-scale build): synthetic sequences up to 108000 bases to choose process settings; 26 single RefSeq records and NC_012920.1 fetched through E-utilities to develop the parser (after the choices file was hashed); the hand-written file; the packaging check of 4.9. None of their outputs is used as a result.
- **Level-K seconds** are lake's reported module build times with 4 jobs running, to at most three significant digits; they are not single-process times.
- **Keyword categories** of the annotation are rule-based (one false positive is named in 3.4); the quoted qualifiers are joined across the line breaks of the flat file.
- **What a level-K theorem here says**: that the kernel's `decodeCDS`, on the letters copied from the flat file, returns the stated value. It does not say that the flat file is right, that the copying script is right (level X cross-checks: Python and Biopython), or that the protein is made in a cell.

## 8. Files

- [gn_choices.md](../docs/genes/gn_choices.md): choices declared before any result (sha256 0b771778a0ed607671ba6e67f2625e918cee7c3013b4b1f57dc09dd9d7bce071)
- [gn_choices.sha256](../docs/genes/gn_choices.sha256): its hash
- [gn_choices_amendment_1.md](../docs/genes/gn_choices_amendment_1.md): method rule outcome and engineering decisions, before the bulk run
- [gn_choices_amendment_2.md](../docs/genes/gn_choices_amendment_2.md): before the main sessions
- gn_results.parquet: `releases/biocore_gene_records_v0_1.tar.gz` (see the README): one row per record
- [gn_summary.csv](../results/gn_summary.csv): level-X counts per group, class, reason and annotation category
- [gn_summary_level_K.csv](../results/gn_summary_level_K.csv): level-K counts and seconds per group, class, status and method
- gn_library.tgz: this repository plus `releases/biocore_gene_records_v0_1.tar.gz` (see the README): the Lean files and tools
- [gn_axioms_audit.json](../results/gn_axioms_audit.json): axioms per theorem, the sample, the hand-written theorems, the union
- gn_logs.tgz (not in this repository): session logs, build logs, lake logs, timing files, negative controls
- gn_s1_raw_outputs.tar (not in this repository): raw outputs of session s1
- gn_k0_raw_outputs.tar (not in this repository): raw outputs of the rehearsal
- gn_k1_raw_outputs.tar (not in this repository): raw outputs of session k1
- gn_k2_raw_outputs.tar (not in this repository): raw outputs of session k2
