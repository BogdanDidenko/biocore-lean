# rx_choices_amendment_1.md — amendment to rx_choices.md (track "Reactions", prefix rx)

Written 2026-11-21, after the measurement notebook (`rx-measure`, version 1) and before the build notebook.
`rx_choices.md` (sha256 237134aaa9376fbdad9c456243c295d8a2dff242747d5ba710758e9d8faaa37f) is unchanged.

## What was already known when this amendment was written

- Scope: 19,005 master reactions in `rhea-directions.tsv` (297 further RDF masters are outside scope).
- The generator's classification before any library build (level X, from `rx_gen_log.txt` of the
  measurement notebook): 18,124 inside the grammar; 881 outside, by primary reason:
  symbolic_coefficient 77, polymer_participant 289, chebi_id_absent 5, chebi_no_formula 33,
  formula_unknown_token 477.
- All 483 records that carry `formula_unknown_token` (477 as primary reason, 6 behind another reason)
  do so because of two ChEBI entries: CHEBI:13193 "hydrogen acceptor", formula `A`, and CHEBI:17499
  "hydrogen donor", formula `H2A`. The Rhea RDF writes the same two entries as `R` and `H2R`.
- Generator predictions for the 18,124: 18,119 balanced, 5 unbalanced (level X).
- Kernel results: chunk 1 only (300 theorems, accepted with `decide` in 29.5 s and with `decide +kernel`
  in 20.9 s on a 4-vCPU Kaggle machine). No reaction containing CHEBI:13193 or CHEBI:17499 had been
  given to the kernel.
- The participants of the glycolysis candidates (which Rhea reactions carry which ChEBI species).

## Changes

1. **Symbol `A`.** The pseudo-symbol table of section 5 becomes `R` → 1000, `X` → 1001, `A` → 1002.
   `A` is ChEBI's symbol for the generic hydrogen acceptor; it is treated like `R`: a conserved
   pseudo-quantity whose count must be the same on both sides. The map stays injective (asserted by the
   generator; the three numbers are stated distinct in `Basic.lean`). The classification under the
   unamended file is kept in every row (`frozen_expressible`, `frozen_reason_code`), reactions that are
   expressible only through this amendment carry the flag `amendment1_symbol_A`, and counts are reported
   under both rule sets, never merged in one figure.
2. **Wording.** `KernelSpecies.lean` is generated (from the list in the kernel's `Data/Monomers.lean`),
   not hand-written as section 6 says; its theorems are audited with the generated ones.
3. **Glycolysis, step 1.** Section 10 takes each step from the `rhea2ec.tsv` rows of its EC number. For
   hexokinase (2.7.1.1 / 2.7.1.2) the only glucose reaction with that EC is RHEA:17825, whose product is
   CHEBI:61548 (D-glucose 6-phosphate, anomer not specified); no in-scope reaction contains both
   CHEBI:61548 and the isomerase substrate CHEBI:58225 (alpha-D-glucose 6-phosphate), so the chain cannot
   be closed with it. Step 1 is therefore RHEA:36495 (alpha-D-glucose + ATP = alpha-D-glucose 6-phosphate
   + ADP + H(+)), which has no EC number in `rhea2ec.tsv`; the pathway is stated from alpha-D-glucose.
   Steps 2–10 follow section 10 unchanged.
4. **Measurement outcome (no rule change).** Plain `decide` is kept for the library: it did not fail on
   chunk 1 and the projection is about 30 single-core minutes.

## Not changed

Everything else. In particular entries without a formula in ChEBI 257 (electron CHEBI:10545, photon
CHEBI:30212, chemical entity CHEBI:24431) and accessions that release 257 lists only as secondary
identifiers (CHEBI:87164, CHEBI:193521) stay NOT_EXPRESSIBLE.
