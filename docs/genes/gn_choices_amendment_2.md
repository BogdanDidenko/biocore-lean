# Gene library (track gn): amendment 2 to gn_choices.md (2026-11-21, after the rehearsal session k0, before the main level-K sessions)

The rules of `gn_choices.md` and amendment 1 are not changed. Two engineering decisions are recorded.

## What was already known when this was written

Everything in amendment 1, and the outputs of the rehearsal session k0 (first two batches of the order,
500 records including all 41 REJECTED records): 500 of 500 modules built under M2, none failed, the six
negative controls were refused, the hand-written file built, axioms seen: `propext`, and for the general
balance theorems `Quot.sound` and `Classical.choice`. Batch wall times 269 s and 312 s for 250 records each
(4 jobs, 4 virtual CPUs); mean reported module time 4.52 s, median 2.70 s.
At that rate the 78 batches need about 6.3 hours of session time.
A local development measurement on one record (BRCA1, 5592 bases): writing the list elements with their
type name (`DNt.A`, `AA.M`) instead of the dotted form (`.A`, `.M`) built in 1.07 s instead of 1.47 s.

## Decisions

1. **List elements are written with their type name** (`[DNt.A, DNt.T, …]`, `[AA.M, …]`) in the modules of the
   main sessions. The terms are the same; only the cost of reading them changes. The timing set and the
   rehearsal k0 used the dotted form.
2. **Sessions.** Main session k1 starts from the first record with a session limit of 4.83 hours for
   starting new batches. If it does not finish, session k2 continues from the k1 results. Session time
   already used at level K: k0, 659 s. The library root file is compiled as one tree only if one session
   holds every compiled module; otherwise the report says that the library was built batch by batch.
