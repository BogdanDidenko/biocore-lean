import BioCore.Firing
/-!
# BioCore.FiringCheck (kernel 0.2): the new relations on real molecules

A writer-eraser pair on one serine residue: RHEA:17989 (kinase) and RHEA:20629 (phosphatase), with
ChEBI release 257 formulas. The two enzymes are written on both sides of their reactions. Their
composition is left empty: it cancels in every statement below, and only their presence matters.
That an enzyme catalyses the reaction is an assumption written into the reaction, not a result.

True statements are theorems; the false variants are theorems of the negation. The same false
claims stated as true are in `BioCore/FiringMustFail.lean`, which must not compile.
-/
namespace BioCore.FiringCheck
open BioCore

-- source: ChEBI release 257 (CC BY 4.0), accessions in the names; formulas as in results/rx_species.tsv
def water : Species := ⟨"CHEBI:15377 water", [(1, 2), (8, 1)]⟩
def hydron : Species := ⟨"CHEBI:15378 hydron", [(1, 1), (0, 1)]⟩
def ser : Species := ⟨"CHEBI:29999 L-serine residue", [(6, 3), (1, 5), (7, 1), (8, 2)]⟩
def pSer : Species := ⟨"CHEBI:83421 O-phospho-L-serine(2-) residue", [(6, 3), (1, 4), (7, 1), (8, 5), (15, 1), (0, -2)]⟩
def atp : Species := ⟨"CHEBI:30616 ATP(4-)", [(6, 10), (1, 12), (7, 5), (8, 13), (15, 3), (0, -4)]⟩
def adp : Species := ⟨"CHEBI:456216 ADP(3-)", [(6, 10), (1, 12), (7, 5), (8, 10), (15, 2), (0, -3)]⟩
def phosphate : Species := ⟨"CHEBI:43474 hydrogenphosphate", [(1, 1), (8, 4), (15, 1), (0, -2)]⟩
/-- Fixtures: enzymes as named species whose composition is not needed. -/
def kinase : Species := ⟨"protein kinase (enzyme, composition left out)", []⟩
def phosphatase : Species := ⟨"protein phosphatase (enzyme, composition left out)", []⟩

/-- RHEA:17989 with the kinase on both sides. -/
def phosphorylation : FSum :=
  [(-1, kinase), (-1, ser), (-1, atp), (1, kinase), (1, pSer), (1, adp), (1, hydron)]
/-- RHEA:20629 with the phosphatase on both sides. -/
def dephosphorylation : FSum :=
  [(-1, phosphatase), (-1, pSer), (-1, water), (1, phosphatase), (1, ser), (1, phosphate)]
def lib : List FSum := [phosphorylation, dephosphorylation]

theorem lib_balanced : ∀ r ∈ lib, Balanced r := by decide

/-- A state with substrate, ATP and water but NO enzyme. -/
def noEnzyme : FSum := [(1, ser), (1, atp), (1, water)]
/-- The same with one kinase and one phosphatase molecule. -/
def withEnzymes : FSum := [(1, kinase), (1, phosphatase), (1, ser), (1, atp), (1, water)]
/-- Only the kinase present. -/
def kinaseOnly : FSum := [(1, kinase), (1, ser), (1, atp), (1, water)]

/-! ## 1. The enzyme must be present -/

/-- Kernel 0.1: the reaction may fire although no kinase is there. -/
theorem old_rule_fires_without_enzyme : Feasible noEnzyme phosphorylation := by decide

/-- Kernel 0.2: it may not. -/
theorem no_kinase_no_firing : ¬ FeasibleS noEnzyme phosphorylation := by decide

theorem fires_with_kinase : FeasibleS withEnzymes phosphorylation := by decide

/-- Without any enzyme nothing happens at all: the only reachable state is the starting one. -/
theorem no_enzyme_nothing_reachable (b : FSum) (h : ReachS lib noEnzyme b) : b = noEnzyme := by
  cases h with
  | refl => rfl
  | step r hr hf _ =>
    exfalso
    have hr' : r = phosphorylation ∨ r = dephosphorylation := by simpa [lib] using hr
    cases hr' with
    | inl e => subst e; exact absurd hf (by decide)
    | inr e => subst e; exact absurd hf (by decide)

/-- The eraser needs its own enzyme: with the kinase alone the mark cannot be removed. -/
theorem no_phosphatase_no_erasure :
    ¬ FeasibleS (kinaseOnly ++ phosphorylation) dephosphorylation := by decide

/-! ## 2. One turn of the cycle returns the residue -/

/-- The state after writer and eraser, written the way one would write it by hand. -/
def afterCycle : FSum :=
  [(1, kinase), (1, phosphatase), (1, ser), (1, adp), (1, phosphate), (1, hydron)]

theorem cycle_strict : ReachS lib withEnzymes ((withEnzymes ++ phosphorylation) ++ dephosphorylation) :=
  ReachS.step phosphorylation (by decide) (by decide)
    (ReachS.step dephosphorylation (by decide) (by decide) (ReachS.refl _))

/-- **The cycle returns the residue and both enzymes; ATP and water became ADP, phosphate and H+.** -/
theorem cycle_returns_residue : ReachSC lib withEnzymes afterCycle :=
  ⟨_, cycle_strict, by decide⟩

/-- A second turn is impossible: the ATP is spent. -/
theorem second_turn_needs_atp :
    ¬ FeasibleS ((withEnzymes ++ phosphorylation) ++ dephosphorylation) phosphorylation := by decide

/-! ## 3. False variants, refused -/

/-- "After the cycle the residue is still phosphorylated and ADP is there": different atoms. -/
def afterCycleWrong : FSum :=
  [(1, kinase), (1, phosphatase), (1, pSer), (1, adp), (1, phosphate), (1, hydron)]

theorem cycle_wrong_state_refused : ¬ ReachSC lib withEnzymes afterCycleWrong :=
  not_reachSC_of_net_ne (q := 15) lib_balanced (by decide)

/-- "The cycle state equals a state with the enzymes used up": same atoms, different molecules. -/
def afterCycleNoEnzymes : FSum := [(1, ser), (1, adp), (1, phosphate), (1, hydron)]

theorem same_atoms_but_not_same_state :
    SameAmounts ((withEnzymes ++ phosphorylation) ++ dephosphorylation) afterCycleNoEnzymes ∧
    ¬ StateEq ((withEnzymes ++ phosphorylation) ++ dephosphorylation) afterCycleNoEnzymes := by decide

end BioCore.FiringCheck
