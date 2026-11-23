import BioCore.Core
/-!
# BioCore.Firing (kernel 0.2)

Kernel 0.2 adds this file to kernel 0.1. No file of kernel 0.1 is edited, so every theorem and
every library built on 0.1 stays valid as it is.

What kernel 0.1 could not say, and what is added here:

* `Feasible` looks at the NET change of each species. A species written on both sides of a
  reaction (an enzyme, a template, a seed) is therefore not required to be present.
  `FeasibleS` requires every molecule on the left side to be in the state, and `ReachS` is
  reachability under that rule. `reach_of_reachS` shows `ReachS` is contained in `Reach`, so the
  conservation theorems of kernel 0.1 apply to it unchanged.
* `Reach` compares states as lists. `StateEq` says two states have the same number of molecules of
  every species name and the same amount of every element and charge; `ReachSC` is reachability up
  to `StateEq`. Both are decidable, and `ReachSC` is transitive and conserves every quantity.
* Small additions: decidable equality of species, decidability of `Feasible`, `count_append`,
  transitivity of `Reach` and `ReachS`.

Definitions a reader has to trust in addition to those of `BioCore.Core`: `consumed`, `FeasibleS`,
`ReachS`, `SameCounts`, `SameAmounts`, `StateEq`, `ReachSC`. Everything else is proved.
-/
namespace BioCore

deriving instance DecidableEq for Species

instance instDecidableFeasible (st r : FSum) : Decidable (Feasible st r) := by
  unfold Feasible; infer_instance

theorem count_append (a b : FSum) (nm : String) : count (a ++ b) nm = count a nm + count b nm := by
  induction a with
  | nil => simp [count]
  | cons h t ih =>
    obtain ⟨c, s⟩ := h
    simp [count, ih, Int.add_assoc]

/-! ## A firing rule that sees both sides of a reaction -/

/-- Molecules of the species called `nm` that a reaction consumes (its left side only). -/
def consumed : FSum → String → Int
  | [], _ => 0
  | (c, s) :: t, nm => (if s.name = nm then (if c < 0 then -c else 0) else 0) + consumed t nm

theorem count_ge_neg_consumed (r : FSum) (nm : String) : -consumed r nm ≤ count r nm := by
  induction r with
  | nil => simp [count, consumed]
  | cons h t ih =>
    obtain ⟨c, s⟩ := h
    simp only [count, consumed]
    by_cases h1 : s.name = nm <;> by_cases h2 : c < 0 <;> simp [h1, h2] <;> omega

/-- Strict firing rule: every molecule on the left side of the reaction is present in the state. -/
def FeasibleS (st r : FSum) : Prop := ∀ x ∈ r, consumed r x.2.name ≤ count st x.2.name

instance instDecidableFeasibleS (st r : FSum) : Decidable (FeasibleS st r) := by
  unfold FeasibleS; infer_instance

/-- The strict rule implies the rule of kernel 0.1. -/
theorem feasible_of_feasibleS {st r : FSum} (h : FeasibleS st r) : Feasible st r := by
  intro x hx
  have h1 := h x hx
  have h2 := count_ge_neg_consumed r x.2.name
  rw [count_append]; omega

/-- Reachability under the strict firing rule. -/
inductive ReachS (L : List FSum) : FSum → FSum → Prop where
  | refl (a : FSum) : ReachS L a a
  | step {a b : FSum} (r : FSum) : r ∈ L → FeasibleS a r → ReachS L (a ++ r) b → ReachS L a b

/-- Strict reachability is contained in the reachability of kernel 0.1. -/
theorem reach_of_reachS {L : List FSum} {a b : FSum} (h : ReachS L a b) : Reach L a b := by
  induction h with
  | refl a => exact Reach.refl a
  | step r hr hf _ ih => exact Reach.step r hr (feasible_of_feasibleS hf) ih

theorem reachS_conserves {L : List FSum} (hL : ∀ r ∈ L, Balanced r) {a b : FSum}
    (h : ReachS L a b) : ∀ q, net b q = net a q :=
  reach_conserves hL (reach_of_reachS h)

theorem not_reachS_of_net_ne {L : List FSum} (hL : ∀ r ∈ L, Balanced r) {a b : FSum} {q : Qty}
    (hne : net b q ≠ net a q) : ¬ ReachS L a b :=
  fun h => hne (reachS_conserves hL h q)

theorem reach_trans {L : List FSum} {a b c : FSum} (h1 : Reach L a b) (h2 : Reach L b c) :
    Reach L a c := by
  induction h1 with
  | refl a => exact h2
  | step r hr hf _ ih => exact Reach.step r hr hf (ih h2)

theorem reachS_trans {L : List FSum} {a b c : FSum} (h1 : ReachS L a b) (h2 : ReachS L b c) :
    ReachS L a c := by
  induction h1 with
  | refl a => exact h2
  | step r hr hf _ ih => exact ReachS.step r hr hf (ih h2)

/-! ## States compared by their content, not by the order in which they are written -/

/-- Species names that occur in a formal sum. -/
def names : FSum → List String
  | [] => []
  | (_, s) :: t => s.name :: names t

theorem names_append (a b : FSum) : names (a ++ b) = names a ++ names b := by
  induction a with
  | nil => rfl
  | cons h t ih => obtain ⟨c, s⟩ := h; simp [names, ih]

theorem count_eq_zero_of_not_mem {a : FSum} {nm : String} (h : nm ∉ names a) : count a nm = 0 := by
  induction a with
  | nil => rfl
  | cons hd t ih =>
    obtain ⟨c, s⟩ := hd
    have h1 : s.name ≠ nm := by
      intro e; apply h; simp [names, e]
    have h2 : nm ∉ names t := by
      intro m; apply h; simp [names, m]
    simp [count, h1, ih h2]

/-- Two states hold the same number of molecules of every species name. -/
def SameCounts (a b : FSum) : Prop := ∀ nm, count a nm = count b nm

/-- The finite check for `SameCounts`: only names that occur need to be compared. -/
def sameCountsB (a b : FSum) : Bool := (names a ++ names b).all (fun nm => count a nm == count b nm)

theorem sameCounts_of_check {a b : FSum} (h : sameCountsB a b = true) : SameCounts a b := by
  intro nm
  by_cases hm : nm ∈ names a ++ names b
  · have h2 := (List.all_eq_true.mp h) nm hm
    simpa using h2
  · have ha : nm ∉ names a := fun m => hm (List.mem_append.mpr (Or.inl m))
    have hb : nm ∉ names b := fun m => hm (List.mem_append.mpr (Or.inr m))
    rw [count_eq_zero_of_not_mem ha, count_eq_zero_of_not_mem hb]

theorem check_of_sameCounts {a b : FSum} (h : SameCounts a b) : sameCountsB a b = true := by
  apply List.all_eq_true.mpr
  intro nm _
  simp [h nm]

instance instDecidableSameCounts (a b : FSum) : Decidable (SameCounts a b) :=
  decidable_of_iff (sameCountsB a b = true) ⟨sameCounts_of_check, check_of_sameCounts⟩

/-- Two states hold the same amount of every element and the same charge. -/
def SameAmounts (a b : FSum) : Prop := ∀ q, net a q = net b q

theorem sameAmounts_iff (a b : FSum) : SameAmounts a b ↔ Balanced (a ++ scale (-1) b) := by
  constructor
  · intro h q
    rw [net_append, net_scale, h q]; omega
  · intro h q
    have := h q
    rw [net_append, net_scale] at this; omega

instance instDecidableSameAmounts (a b : FSum) : Decidable (SameAmounts a b) :=
  decidable_of_iff _ (sameAmounts_iff a b).symm

/-- The same state: the same molecules by name and the same atoms and charge. -/
def StateEq (a b : FSum) : Prop := SameCounts a b ∧ SameAmounts a b

instance instDecidableStateEq (a b : FSum) : Decidable (StateEq a b) := by
  unfold StateEq; infer_instance

theorem StateEq.refl (a : FSum) : StateEq a a := ⟨fun _ => rfl, fun _ => rfl⟩

theorem StateEq.symm {a b : FSum} (h : StateEq a b) : StateEq b a :=
  ⟨fun nm => (h.1 nm).symm, fun q => (h.2 q).symm⟩

theorem StateEq.trans {a b c : FSum} (h1 : StateEq a b) (h2 : StateEq b c) : StateEq a c :=
  ⟨fun nm => (h1.1 nm).trans (h2.1 nm), fun q => (h1.2 q).trans (h2.2 q)⟩

/-- Firing the same reaction in two equal states gives equal states. -/
theorem StateEq.append_right {a a' : FSum} (h : StateEq a a') (r : FSum) :
    StateEq (a ++ r) (a' ++ r) := by
  constructor
  · intro nm; rw [count_append, count_append, h.1 nm]
  · intro q; rw [net_append, net_append, h.2 q]

/-- The strict firing rule depends only on the molecule counts of the state. -/
theorem feasibleS_congr {a a' r : FSum} (h : SameCounts a a') (hf : FeasibleS a r) :
    FeasibleS a' r := by
  intro x hx
  have := hf x hx
  rw [← h x.2.name]; exact this

/-- A derivation can be replayed from any equal state, and ends in an equal state. -/
theorem reachS_congr {L : List FSum} {a b : FSum} (h : ReachS L a b) :
    ∀ a', StateEq a a' → ∃ b', ReachS L a' b' ∧ StateEq b b' := by
  induction h with
  | refl a => intro a' he; exact ⟨a', ReachS.refl a', he⟩
  | step r hr hf _ ih =>
    intro a' he
    obtain ⟨b', hb, hbe⟩ := ih (a' ++ r) (he.append_right r)
    exact ⟨b', ReachS.step r hr (feasibleS_congr he.1 hf) hb, hbe⟩

/-- Strict reachability up to equality of states. -/
def ReachSC (L : List FSum) (a b : FSum) : Prop := ∃ b', ReachS L a b' ∧ StateEq b' b

theorem reachSC_of_reachS {L : List FSum} {a b : FSum} (h : ReachS L a b) : ReachSC L a b :=
  ⟨b, h, StateEq.refl b⟩

theorem reachSC_trans {L : List FSum} {a b c : FSum} (h1 : ReachSC L a b) (h2 : ReachSC L b c) :
    ReachSC L a c := by
  obtain ⟨b', hb, hbe⟩ := h1
  obtain ⟨c', hc, hce⟩ := h2
  obtain ⟨c'', hc2, hce2⟩ := reachS_congr hc b' hbe.symm
  exact ⟨c'', reachS_trans hb hc2, hce2.symm.trans hce⟩

/-- Conservation holds for reachability up to equality of states. -/
theorem reachSC_conserves {L : List FSum} (hL : ∀ r ∈ L, Balanced r) {a b : FSum}
    (h : ReachSC L a b) : ∀ q, net b q = net a q := by
  obtain ⟨b', hb, hbe⟩ := h
  intro q
  rw [← hbe.2 q]; exact reachS_conserves hL hb q

theorem not_reachSC_of_net_ne {L : List FSum} (hL : ∀ r ∈ L, Balanced r) {a b : FSum} {q : Qty}
    (hne : net b q ≠ net a q) : ¬ ReachSC L a b :=
  fun h => hne (reachSC_conserves hL h q)

end BioCore
