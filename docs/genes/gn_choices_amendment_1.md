# Gene library (track gn): amendment 1 to gn_choices.md (2026-11-21, after Kaggle session 1, before the level-K bulk run)

The rules of `gn_choices.md` (sha256 0b771778a0ed607671ba6e67f2625e918cee7c3013b4b1f57dc09dd9d7bce071) are not changed.
This file records the outcome of the method rule (8.4) and four engineering decisions.

## What was already known when this was written

Everything in the outputs of Kaggle session 1 (saved as `gn_s1_raw_outputs.tar`,
sha256 d9ce6ea8e65ad5745cb40739078710fe4fa2c1510876d1203ce11d6bcd2a4e26):

- scope 19450 records (SELECT 19363, PLUS_CLINICAL 74, MITO 13); level-X classes ACCEPTED_EQUAL 19339,
  ACCEPTED_DIFFERENT 0, REJECTED 41, NOT_EXPRESSIBLE 70; Lean program and Python agree on 19380 of 19380;
- the timing set (20 records, CDS length 39 to 107976 bases, each as its own Lean process without output files):
  M1 20 of 20 built, M2 20 of 20 built, M3 19 of 20 built (the longest record, 107976 bases, reached the
  3600 s limit under M3);
- the same 20 records under M2 through `lake build` with 4 jobs and with compiled data definitions took
  1580 s of wall time, of which the longest record took 1564 s (210 s as its own process);
- a local development measurement on one record of 8532 bases: with the data definitions marked
  `noncomputable` the compiled file was 321808 bytes instead of 14490744 bytes.

## Outcome of the method rule (8.4)

- Summed seconds over the 20 timing records (both list-literal methods built all 20):
  M1 248.256 s, M2 232.749 s. **Primary method: M2** (`decide +kernel`, ordinary list literals).
- No timing record failed under a list-literal method, so there is no L*: no record goes straight to M3.
- Projection for the scope (19380 records with a statement, 33913863 bases), by the declared interpolation:
  M2 27926 s of single-process time, 1.94 h at 4 jobs; M1 2.37 h; M3 1.54 h
  (M3 projection uses the 19 records it built). The M2 projection is below 9 hours, so M2 stays primary.
- Fallback for a record that fails under M2 stays as declared: M3 once, then `FAILED`.

## Engineering decisions (they do not change any statement or class)

1. **Data definitions are `noncomputable` in the bulk modules.** The sequence and protein definitions of a
   record are marked `noncomputable`, so Lean generates no program code for them. Reason: file size and
   build time under `lake` (see above). The theorems and their kernel check are the same. The timing set
   was measured with compiled definitions, so the projection above is for that form.
2. **Negative controls (added, not in the choices file).** Six false statements are given to Lean in every
   level-K session and must be refused: for the first three ACCEPTED_EQUAL records of the order, the
   annotated protein with its last residue changed; for the first three REJECTED records, the claim that
   the record decodes to its annotated protein. They are not part of the library.
3. **A short first level-K session (label k0)** builds the first two batches (500 records, which include all
   41 REJECTED records) to check the batch driver on Kaggle. Its session time counts in the level-K budget.
   The main sessions (k1, …) start again from the first record, so that the whole library can be built in
   one tree and its root file compiled; the k0 results are kept as raw outputs and reported as a rehearsal.
4. **Build driver**: `lake build` on one batch root per 250 records (8.6, first option); seconds per record
   are lake's reported build time of its module, measured with 4 jobs running.
