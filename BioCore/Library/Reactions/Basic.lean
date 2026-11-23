import BioCore.Core
/-!
# BioCore.Library.Reactions.Basic

HAND-WRITTEN. Helper lemmas for the reaction library. Nothing here is an axiom and no kernel file is
changed; every statement is proved from the definitions of `BioCore.Core`.

* `qtyR`, `qtyX`, `qtyA`: the pseudo-quantity numbers used by the generator for ChEBI's generic group
  `R`, generic halogen `X` and generic hydrogen acceptor `A` (numbers from 1000 on, as `BioCore.Core`
  documents), with the fact that they differ from each other, from every atomic number and from charge.
* `bal_nil`, `bal_cons`, `bal_append`: assemble "every member of a list is balanced" from per-reaction
  theorems.
* `Decidable (Feasible st r)`: the kernel defines `Feasible` as a plain definition, so the instance is
  stated here; it only unfolds the definition.
* `names`, `count_eq_zero_of_not_mem`, `count_eq_of_check`, `net_eq_of_check`, `balanced_of_net_eq`:
  finite checks that two formal sums have the same molecule counts / the same net amounts.
-/
namespace BioCore.Rhea
open BioCore

/-- Pseudo-quantity of ChEBI's generic group `R`. -/
def qtyR : Qty := 1000
/-- Pseudo-quantity of ChEBI's generic halogen `X`. -/
def qtyX : Qty := 1001
/-- Pseudo-quantity of ChEBI's generic hydrogen acceptor `A` (added by `rx_choices_amendment_1.md`). -/
def qtyA : Qty := 1002

/-- The pseudo-quantities are pairwise distinct, are not charge (0) and lie above every atomic number. -/
theorem pseudo_qty_separate :
    qtyR ≠ qtyX ∧ qtyR ≠ qtyA ∧ qtyX ≠ qtyA ∧ 1000 ≤ qtyR ∧ 1000 ≤ qtyX ∧ 1000 ≤ qtyA ∧ 118 < 1000 := by
  decide

theorem bal_nil : ∀ r ∈ ([] : List FSum), Balanced r := fun _ h => nomatch h

theorem bal_cons {x : FSum} {l : List FSum} (hx : Balanced x) (hl : ∀ r ∈ l, Balanced r) :
    ∀ r ∈ x :: l, Balanced r := fun r h => by
  cases h with
  | head => exact hx
  | tail _ h' => exact hl r h'

theorem bal_append {l m : List FSum} (hl : ∀ r ∈ l, Balanced r) (hm : ∀ r ∈ m, Balanced r) :
    ∀ r ∈ l ++ m, Balanced r := fun r h => (List.mem_append.mp h).elim (hl r) (hm r)

instance instDecidableFeasible (st r : FSum) : Decidable (Feasible st r) := by
  unfold Feasible; infer_instance

/-- Names of the species that occur in a formal sum. -/
def names : FSum → List String
  | [] => []
  | (_, s) :: t => s.name :: names t

theorem count_eq_zero_of_not_mem {r : FSum} {nm : String} (h : nm ∉ names r) : count r nm = 0 := by
  induction r with
  | nil => rfl
  | cons hd t ih =>
    obtain ⟨c, s⟩ := hd
    have h1 : s.name ≠ nm := by intro e; apply h; simp [names, e]
    have h2 : nm ∉ names t := by intro m; apply h; simp [names, m]
    simp [count, h1, ih h2]

/-- Equal molecule counts on the species that occur give equal counts for every name. -/
theorem count_eq_of_check {a b : FSum}
    (h : ∀ nm ∈ names a ++ names b, count a nm = count b nm) : ∀ nm, count a nm = count b nm := by
  intro nm
  by_cases hm : nm ∈ names a ++ names b
  · exact h nm hm
  · have ha : nm ∉ names a := fun m => hm (List.mem_append.mpr (Or.inl m))
    have hb : nm ∉ names b := fun m => hm (List.mem_append.mpr (Or.inr m))
    rw [count_eq_zero_of_not_mem ha, count_eq_zero_of_not_mem hb]

/-- Equal net amounts on the quantities that occur give equal net amounts for every quantity. -/
theorem net_eq_of_check {a b : FSum}
    (h : ∀ q ∈ keys a ++ keys b, net a q = net b q) : ∀ q, net a q = net b q := by
  intro q
  by_cases hm : q ∈ keys a ++ keys b
  · exact h q hm
  · have ha : q ∉ keys a := fun m => hm (List.mem_append.mpr (Or.inl m))
    have hb : q ∉ keys b := fun m => hm (List.mem_append.mpr (Or.inr m))
    rw [net_eq_zero_of_not_mem ha, net_eq_zero_of_not_mem hb]

/-- A formal sum with the same net amounts as a balanced one is balanced. -/
theorem balanced_of_net_eq {a b : FSum} (h : ∀ q, net a q = net b q) (hb : Balanced b) : Balanced a :=
  fun q => (h q).trans (hb q)

end BioCore.Rhea
