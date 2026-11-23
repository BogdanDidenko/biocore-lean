# Gene library (track "Genes", prefix gn): choices declared before any result

Written 2026-11-21, before any record of the scope was downloaded, parsed, decoded or timed.
Known at the time of writing: the frozen BioCore 0.1 kernel sources (read in full); the file names,
sizes and dates in the NCBI directory `refseq/MANE/MANE_human/current/` (release 1.5, RefSeq annotation
GCF_000001405.40-RS_2025_08, Ensembl 116, files dated 2025-12-04); general textbook knowledge that human
annotation contains selenoproteins, non-AUG starts, ribosomal slippage and incomplete mitochondrial stop
codons. No sequence, no translation and no timing had been looked at.

The rules below are not changed afterwards. Later amendments are separate dated files that state what
was already known when they were written.

## 1. Levels of checking (never mixed)

- **K**: a theorem accepted by the Lean 4.36.0 kernel; `#print axioms` shows at most `propext`,
  `Quot.sound`, `Classical.choice`. Only this level is called "verified" or "proved".
- **N**: `native_decide`. Not used in this track.
- **X**: output of a compiled Lean program or of a script. Computed, not proved.

No `sorry`. No edit of any file listed in `KERNEL_SHA256.txt`; the hashes are re-checked inside every
Kaggle session before building.

## 2. Sources (downloaded inside the Kaggle notebook; sha256, size and version recorded)

1. `MANE.GRCh38.v<release>.refseq_rna.gbff.gz` and `MANE.GRCh38.v<release>.summary.txt.gz` and
   `README_versions.txt` from `https://ftp.ncbi.nlm.nih.gov/refseq/MANE/MANE_human/current/`.
   The release is whatever `current/` holds at download time; it is recorded.
2. Human mitochondrial genome `NC_012920.1`, GenBank flat file, through NCBI E-utilities
   (`efetch.fcgi?db=nuccore&id=NC_012920.1&rettype=gbwithparts&retmode=text`).
3. NCBI `gc.prt` (`https://ftp.ncbi.nlm.nih.gov/entrez/misc/data/gc.prt`) for the independent Python
   re-implementation only; its sha256 is compared with the one recorded in the kernel archive
   (`sources/SOURCE_SHA256.txt`); a mismatch is reported and the two tables used are compared letter
   by letter with the kernel's rows.
4. Lean 4.36.0 for Linux x86_64 from the GitHub release `v4.36.0`
   (`lean-4.36.0-linux.tar.zst`), sha256 recorded.

Later sessions re-download the same files and stop if a sha256 differs from the first session.

## 3. Scope and groups

- **Group SELECT**: every row of the MANE summary file with `MANE_status` = `MANE Select`.
- **Group PLUS_CLINICAL**: every row with `MANE_status` = `MANE Plus Clinical` (separate group).
- **Group MITO**: every CDS feature of `NC_012920.1` (13 are expected; if the count is not 13 every CDS
  feature found is processed and the count is reported as a deviation from expectation).
- Any other value of `MANE_status` is reported as its own group and processed the same way.
- Record identifier: the RefSeq transcript accession with version (`RefSeq_nuc`, for example
  `NM_000546.6`) for MANE groups; `NC_012920.1:<gene symbol>` for the mitochondrial group.
- Flat-file records whose accession.version is not in the summary file are counted and listed in the
  log; they are outside the scope. A summary row with no flat-file record stays in the scope
  (class NOT_EXPRESSIBLE, reason `NO_FLATFILE_RECORD`).
- The scope count is the number of summary rows of the two MANE groups plus the mitochondrial CDS
  features. Every record of the scope ends in exactly one class; the program asserts that the class
  counts sum to the scope count, per group and in total. Nothing is subsampled, truncated or skipped.
  There is no length limit on any sequence.

## 4. Taking the coding sequence; what is expressible

The kernel function is `decodeCDS (g : GeneticCode) (r : List RNt) : Decoded`, with
`transcribe : List DNt → List RNt` and `revComp : List DNt → List DNt`. The kernel has no splicing, no
joins, no recoding, and the alphabet `DNt` = A, C, G, T.

A record is **expressible** when all of the following hold; otherwise its class is NOT_EXPRESSIBLE
with the first failing reason in this order (all failing reasons are also stored):

1. `NO_FLATFILE_RECORD`: the summary accession.version has no record in the flat file.
2. `CDS_FEATURE_COUNT_<n>`: a MANE transcript record must contain exactly one `CDS` feature
   (mitochondrial genome: each CDS feature is its own record, so this does not apply).
3. Location grammar. MANE transcript: `INT..INT` only. Mitochondrial genome: `INT..INT`, or
   `complement(INT..INT)` (then the coding strand is the kernel's `revComp` of the stretch).
   Anything else is not expressible: `LOCATION_JOIN` (the location contains `join(` or `order(`),
   `LOCATION_PARTIAL` (contains `<` or `>`), `LOCATION_OTHER` (anything else; the raw location string
   is stored). A join is never concatenated by this pipeline.
4. `CODON_START_<n>`: `/codon_start` must be absent or 1.
5. `NON_ACGT`: every letter of the stretch must be one of a, c, g, t (case ignored); the offending
   letters and positions are stored.
6. `NO_TRANSLATION`: the CDS feature must carry a `/translation`.

Things that are deliberately NOT filtered before the kernel: a length that is not a multiple of three,
a first codon that is not AUG, an internal stop, a missing stop, `/transl_except`, `/exception`. These
records go to the kernel unchanged and receive the kernel's own verdict.

The stretch is taken exactly as annotated: bases `a..b` (1-based, inclusive) of the record's `ORIGIN`
sequence. Nothing is trimmed or padded (an incomplete stop codon is not completed).

Genetic code: `standardCode` for MANE groups; `vertMitoCode` for the mitochondrial group.

An annotated protein containing a letter outside the kernel's 21 amino acids
(A R N D C Q E G H I L K M F P S T W Y V U) cannot be equal to any kernel output; the record is still
decoded and, if it decodes, is ACCEPTED_DIFFERENT with the flag `annotation_outside_alphabet`.

## 5. Classes (each record gets exactly one; assigned from the level-X verdict of the Lean program)

- **ACCEPTED_EQUAL**: `decodeCDS` returns `.ok p` and the one-letter string of `p` equals the
  `/translation` string exactly.
- **ACCEPTED_DIFFERENT**: `.ok p` with a different string. Every such record is listed with both
  proteins and the positions that differ.
- **REJECTED**: `.rejected why`; the reason (`notWholeCodons`, `empty`, `badStart`, `internalStop i`,
  `noStop`) and, for `internalStop`, the codon index `i` (0-based; the start codon is codon 0) are stored.
- **NOT_EXPRESSIBLE**: section 4.

## 6. The annotation's own explanation

Stored for every record, reported for every record that is not ACCEPTED_EQUAL. Quoted verbatim from the
flat file: the CDS qualifiers `/transl_except`, `/exception`, `/ribosomal_slippage`, `/note`,
`/artificial_location`, `/pseudo`, `/codon_start` (if not 1), the raw location string, and the lines of
the record's `COMMENT` between `##RefSeq-Attributes-START##` and `##RefSeq-Attributes-END##`.
Categories (a record may have several; all are listed), decided by these rules only:

- `selenocysteine`: a `/transl_except` with `aa:Sec`.
- `incomplete_stop_codon`: a `/transl_except` with `aa:TERM`.
- `other_transl_except`: a `/transl_except` with any other amino acid.
- `non_AUG_start`: the text `non-AUG` (case ignored) in the CDS `/note` or in the RefSeq-Attributes block.
- `ribosomal_slippage`: the qualifier `/ribosomal_slippage`, or the text `ribosomal slippage` or
  `ribosomal frameshift` in those places.
- `stop_codon_readthrough`: the text `readthrough` within the CDS `/note`, `/exception` or the
  RefSeq-Attributes block, only where the same sentence also contains `stop codon`, `translational`,
  `UGA`, `UAG` or `UAA` (the word alone also denotes read-through transcription of neighbouring genes).
- `RNA_editing`: the text `RNA editing` in `/exception`, the CDS `/note` or the RefSeq-Attributes block.
- `other`: any `/exception` value not covered above (verbatim).
- `none_given`: nothing of the above.

Diagnostics (level X, Python, not part of the class): for REJECTED `internalStop i`, whether a
`/transl_except` covers exactly codon `i`; for ACCEPTED_EQUAL, the count of records whose first codon
is not AUG; for REJECTED `notWholeCodons`, the length modulo 3.

## 7. Level X and the independent re-implementation

- Lean program (`lake exe`, added target in a COPY of the lakefile; the frozen `lakefile.toml` is not
  edited): reads one record per line (identifier, code, strand, coding-strand letters), builds the
  `List DNt`, applies the kernel's `revComp` for the complement strand, the kernel's `transcribe`, then
  the kernel's `decodeCDS` with the kernel's `standardCode` / `vertMitoCode`, and writes the verdict,
  the reason and position, and the protein letters produced by the kernel's `AA.letter`.
  It contains no decoding logic of its own.
- Python re-implementation: written from the NCBI `gc.prt` tables (rows `ncbieaa` and `sncbieaa` of
  tables 1 and 2), with string slicing and a loop, independent of the Lean sources and data files.
  It returns the same fields.
- Agreement is counted on the tuple (verdict, reason, position, protein string) for every record given
  to the kernel. Every disagreement is listed. A disagreement is not resolved by choosing a side: the
  class stays the Lean program's, and the record is flagged.
- Third opinion, if the package installs in the session: Biopython `translate` of the same stretch
  (table 1 or 2, `cds=False`, `to_stop=False`), compared with the kernel protein for accepted records.
  Reported separately; it does not change any class. Biopython's GenBank parser, if available, is also
  used to cross-check the parsed CDS location, `/translation` and sequence length of every record.

## 8. Level K

### 8.1 Statements

One Lean module per record, under `BioCore/Library/Genes/`. For an expressible record with coding strand
`cds : List DNt` (as taken in section 4; for the complement strand the statement contains
`revComp <stretch>`):

- class ACCEPTED_EQUAL: `decodeCDS <code> (transcribe cds) = .ok <annotated protein>`, where the
  protein literal is generated by the Python script from the `/translation` string of the flat file
  (not from the Lean program's output).
- class ACCEPTED_DIFFERENT: `decodeCDS <code> (transcribe cds) = .ok <kernel protein>` and, when the
  annotation is inside the kernel alphabet, `decodeCDS <code> (transcribe cds) ≠ .ok <annotated protein>`.
- class REJECTED: `decodeCDS <code> (transcribe cds) = .rejected <reason>`.
- class NOT_EXPRESSIBLE: no theorem; level-K status `NOT_APPLICABLE`.

So each statement covers transcription and decoding of the annotated DNA letters in one equation.

### 8.2 Methods, in order of how much has to be trusted

- **M1**: sequence and protein as ordinary list literals; proof `by decide`.
- **M2**: the same statement; proof `by decide +kernel`.
- **M3**: sequence (and, if needed, protein) given through a compact encoding with a small decoder in a
  new Library file; proof `by decide +kernel`. Statements proved this way additionally rely on that
  decoder, and are counted separately everywhere.

M1 and M2 prove the identical statement and both are level K; they differ only in cost. Process settings
that do not change what is proved (stack size, `maxRecDepth`, memory, number of parallel jobs) are set
as needed and reported.

### 8.3 Timing set (measured before the bulk run; on Kaggle)

20 records of group SELECT: the expressible records sorted by (CDS length ascending, identifier
ascending), N of them; the records at ranks `round(i*(N-1)/19)` for i = 0..19 (Python `round`). This
includes the shortest and the longest. Each is built with each method, one record per Lean process, with
a limit of 3600 s per attempt; wall seconds, peak memory and outcome are recorded.

### 8.4 Method rule (fixed now, applied after the timing set)

- The **primary method** is the list-literal method (M1 or M2) with the smaller summed time over the
  timing records on which both succeed (if only one succeeds anywhere, that one).
- A record goes straight to M3 only if its CDS length is at least L*, where L* is the smallest CDS length
  in the timing set at which both list-literal methods failed, provided every longer timing record also
  failed with both. Otherwise there is no L*.
- Projection: seconds for a record = linear interpolation in (log length, log seconds) between timing
  records, clamped at the ends; projected session time = sum over the scope / number of parallel jobs.
  If the projection for the primary method exceeds 9 hours and the projection for M3 is at most half of
  it, M3 becomes the primary method for the sha256-ordered part (coverage within the budget has
  priority), and this is stated in a dated amendment before the bulk run.
- Fallback at build time: a record whose module fails or exceeds 3600 s under its first method is tried
  once with each remaining method in the order M2, M3. If all fail the level-K status is `FAILED`
  with the Lean message; the record keeps its level-X class and is listed.

### 8.5 Order and budget

Order of the bulk run, fixed before anything beyond the timing set is measured:

1. every expressible record whose level-X class is not ACCEPTED_EQUAL (all groups), in ascending order
   of sha256 of the identifier;
2. all remaining expressible records (all groups), in ascending order of the sha256 (hex) of the UTF-8
   identifier (accession with version; `NC_012920.1:<gene>` for the mitochondrial group).

Budget: "about 10 Kaggle CPU hours" is read as about 10 hours of Kaggle CPU notebook session time for
the level-K bulk run, with all cores of the session in use; no new batch is started once the cumulative
level-K session time reaches 9.5 hours. Session time of the preparation session (download, parsing,
level X, timing) is reported separately. Both session hours and core-hours are reported.
Kernels are at most about 5 hours each, at most one running at a time, results written per batch.
Records not reached have level-K status `NOT_REACHED`; coverage is reported as counts.
A level-X verdict is never described as proved.

### 8.6 Build driver

Modules are built with `lake build` (copy of the lakefile with added targets) on explicit module targets
in batches; seconds per record are the build time of its module. If lake does not expose per-module
time or messages reliably, modules are compiled one process per module with `lake env lean`, and the
packaged library is built once more with `lake build` as far as the budget allows. The report says which.

## 9. Axioms audit

- Every generated module ends with `#print axioms` for each of its theorems; the output is captured
  for every module and the union is reported, with the count of theorems audited.
- Declared random sample: the 200 records with the smallest sha256 of
  `"gn-axioms-sample-v1|" + identifier` among records with level-K status accepted. For these the
  `#print axioms` lines are reported separately (count and union), re-queried from an audit file that
  imports the compiled modules when the session still has them.
- Every theorem of the hand-written file and of any new Library file is audited with `#print axioms`.
- Any axiom outside `propext`, `Quot.sound`, `Classical.choice` moves the theorem out of level K.

## 10. Hand-written file

Three genes, named now: **INS**, **TP53**, **BRCA1** (the MANE Select transcript of each symbol in the
summary file). For each: the coding strand (`List DNt`), its transcription (`transcribe … = <RNA>`),
`decodeCDS standardCode <RNA> = …` (`.ok protein` if the level-X verdict is ACCEPTED_EQUAL; otherwise
the statement the kernel actually gives, and the report says so), `Balanced (transcriptionRxn <RNA>)`
from `transcription_balanced` and `Balanced (peptideRxn protein)` from `peptide_balanced` (general
theorems, no per-gene computation). The sequence literals are pasted by a script from the parsed flat
file; the statements and proofs are written by hand.

## 11. Order of work

1. This file: hash, save.
2. Small local development on SYNTHETIC sequences and a handful of single records fetched for parser
   development (no library-scale work locally).
3. Kaggle session 1: sources, hashes, parsing, classes of expressibility, level X (Lean program),
   Python re-implementation, optional Biopython, timing set. Raw outputs saved as artifacts before any
   aggregation.
4. Dated amendment stating the method chosen by the rule of 8.4.
5. Kaggle level-K sessions in the order of 8.5; raw outputs saved as artifacts.
6. Hand-written file, axioms audit, packaging of the library, tables and report.

## 12. Failures

- The frozen kernel does not build on Kaggle: stop and report; the kernel is not patched.
- A source cannot be downloaded inside Kaggle: retry inside Kaggle; never fetch it through the Mac.
- A generated module fails: section 8.4 fallback; then `FAILED` with the message.
- A session dies or is cut: finished batches that were saved are kept, the rest is rerun; the lost
  session time is counted in the budget and reported.
- Anything the kernel cannot express is reported as NOT EXPRESSIBLE with the reason, and where a kernel
  change would be needed it is described as a proposal only.
- A step blocked by a platform safety check is not retried and not reached another way.
