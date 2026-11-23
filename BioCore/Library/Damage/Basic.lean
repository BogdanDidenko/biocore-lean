import BioCore.Library.Sites.SiteProtein
/-!
# BioCore.Library.Damage.Basic

HAND-WRITTEN. Small definitions and lemmas shared by the damage and repair library, on kernel 0.2.
Nothing here is an axiom and no kernel file is changed.

* `bal_nil`, `bal_cons`, `bal_append`, `path_nil`, `path_cons`: assemble "every member is balanced".
* `fproj`, `balanced_congr`: balance depends only on coefficients and formulas, not on names.
* `onCarrier tag s`: the species `s` on a named carrier (a protein, a strand): same formula, a name of
  its own. Rhea writes a protein participant as its reactive residues; in a state the residue alone
  would be ambiguous between proteins.
* `enzyme`, `withEnzyme`: an enzyme as a named species with an empty formula, written on both sides of a
  step; `balanced_withEnzyme`. That the enzyme catalyses the step is an assumption of the data.
* `protonFix`: a reaction completed with the number of hydrons that restores its charge balance.
-/
namespace BioCore.Damage
open BioCore

theorem bal_nil : ∀ r ∈ ([] : List FSum), Balanced r := fun _ h => nomatch h

theorem bal_cons {x : FSum} {l : List FSum} (hx : Balanced x) (hl : ∀ r ∈ l, Balanced r) :
    ∀ r ∈ x :: l, Balanced r := fun r h => by
  cases h with
  | head => exact hx
  | tail _ h' => exact hl r h'

theorem bal_append {l m : List FSum} (hl : ∀ r ∈ l, Balanced r) (hm : ∀ r ∈ m, Balanced r) :
    ∀ r ∈ l ++ m, Balanced r := fun r h => (List.mem_append.mp h).elim (hl r) (hm r)

theorem path_nil : ∀ x ∈ ([] : List (Int × FSum)), Balanced x.2 := fun _ h => nomatch h

theorem path_cons {k : Int} {r : FSum} {p : List (Int × FSum)} (hr : Balanced r)
    (hp : ∀ x ∈ p, Balanced x.2) : ∀ x ∈ (k, r) :: p, Balanced x.2 := fun x h => by
  cases h with
  | head => exact hr
  | tail _ h' => exact hp x h'

/-- A formal sum with the names forgotten: coefficients and formulas only. -/
def fproj (r : FSum) : List (Int × Formula) := r.map fun p => (p.1, p.2.formula)

/-- Net amount computed from coefficients and formulas. -/
def netF : List (Int × Formula) → Qty → Int
  | [], _ => 0
  | (c, f) :: t, q => c * amount f q + netF t q

theorem net_fproj (r : FSum) (q : Qty) : net r q = netF (fproj r) q := by
  induction r with
  | nil => rfl
  | cons h t ih => obtain ⟨c, s⟩ := h; simp [net, netF, fproj] at ih ⊢; rw [ih]

/-- **Balance does not depend on names**: two formal sums with the same coefficients and formulas, term
by term, are balanced together. -/
theorem balanced_congr {r r' : FSum} (h : fproj r = fproj r') : Balanced r ↔ Balanced r' := by
  constructor <;> intro hb q <;> have := hb q <;> rw [net_fproj] at this ⊢
  · rw [← h]; exact this
  · rw [h]; exact this

/-- The species `s` on the carrier called `tag`: same composition, a name of its own. -/
def onCarrier (tag : String) (s : Species) : Species := ⟨s.name ++ " @ " ++ tag, s.formula⟩

theorem onCarrier_formula (tag : String) (s : Species) : (onCarrier tag s).formula = s.formula := rfl

/-- An enzyme (or any catalyst) as a named species whose composition is left out. -/
def enzyme (name : String) : Species := ⟨name, []⟩

/-- A step with its catalyst written on both sides, for the strict firing rule of kernel 0.2. -/
def withEnzyme (E : Species) (core : FSum) : FSum := (-1, E) :: (core ++ [(1, E)])

/-- Writing a catalyst on both sides does not change balance, whatever its composition. -/
theorem balanced_withEnzyme (E : Species) (core : FSum) : Balanced (withEnzyme E core) ↔ Balanced core := by
  constructor <;> intro hb q <;> have := hb q <;> simp only [withEnzyme, net, net_append] at this ⊢ <;> omega

/-- The catalyst is not consumed: its net count in the step is zero when the core does not contain it. -/
theorem count_withEnzyme (E : Species) (core : FSum) (nm : String) :
    count (withEnzyme E core) nm = count core nm := by
  simp only [withEnzyme, count, count_append]
  by_cases h : E.name = nm <;> simp [h] <;> omega

/-- `r` followed by the number of hydrons (CHEBI:15378) that makes the net charge zero. -/
def protonFix (r : FSum) : FSum := r ++ [(-(net r 0), Chebi.c15378)]

end BioCore.Damage
