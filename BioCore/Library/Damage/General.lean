import BioCore.Library.Damage.Basic
/-!
# BioCore.Library.Damage.General

HAND-WRITTEN. General theorems about what a library of reactions can and cannot undo, on kernel 0.2.
They hold for EVERY library `L` and every state; nothing here is about a particular molecule.

* `count_mono_reachS` (T1): if no reaction of `L` consumes the species called `nm`, the number of its
  molecules never decreases along `ReachS L`. Also for `ReachSC` and, with the net form of the
  hypothesis, for `Reach` of kernel 0.1.
* `absent_stays_absent` (T2): if every reaction that makes a species of the set `S` also needs a species
  of `S`, and nothing of `S` is present, nothing of `S` ever appears. With `S = [nm]`:
  `never_appears`.
* `consumed_eq_zero_of_not_mem`, `names_scale`, `allAvoid` (T4): a species that is not named in a
  reaction is neither consumed nor produced by it, in either direction; a finite check over a list.
* `count_mono_union`: T1 for a union of libraries, one of them taken in both directions.

Every use of these theorems is relative to the library given. They say nothing about reactions that
are not in it.
-/
namespace BioCore.Damage
open BioCore

theorem count_nonneg_of_consumed_zero {r : FSum} {nm : String} (h : consumed r nm = 0) :
    0 ≤ count r nm := by
  have := count_ge_neg_consumed r nm; omega

/-- **T1.** If no reaction of the library consumes `nm`, its count never decreases. -/
theorem count_mono_reachS {L : List FSum} {nm : String} (hL : ∀ r ∈ L, consumed r nm = 0)
    {a b : FSum} (h : ReachS L a b) : count a nm ≤ count b nm := by
  induction h with
  | refl a => exact Int.le_refl _
  | step r hr _ _ ih =>
    have h0 := count_nonneg_of_consumed_zero (hL r hr)
    rw [count_append] at ih; omega

/-- T1 up to equality of states. -/
theorem count_mono_reachSC {L : List FSum} {nm : String} (hL : ∀ r ∈ L, consumed r nm = 0)
    {a b : FSum} (h : ReachSC L a b) : count a nm ≤ count b nm := by
  obtain ⟨b', hb, he⟩ := h
  have := count_mono_reachS hL hb
  rw [← he.1 nm]; exact this

/-- T1 for the firing rule of kernel 0.1, with the hypothesis on the net change. -/
theorem count_mono_reach {L : List FSum} {nm : String} (hL : ∀ r ∈ L, 0 ≤ count r nm)
    {a b : FSum} (h : Reach L a b) : count a nm ≤ count b nm := by
  induction h with
  | refl a => exact Int.le_refl _
  | step r hr _ _ ih =>
    have h0 := hL r hr
    rw [count_append] at ih; omega

/-- Consequence of T1: a lesion that is present can never be absent again. -/
theorem lesion_persists {L : List FSum} {nm : String} (hL : ∀ r ∈ L, consumed r nm = 0)
    {a b : FSum} (ha : 0 < count a nm) (h : ReachSC L a b) : 0 < count b nm := by
  have := count_mono_reachSC hL h; omega

theorem consumed_nonneg (r : FSum) (nm : String) : 0 ≤ consumed r nm := by
  induction r with
  | nil => simp [consumed]
  | cons h t ih =>
    obtain ⟨c, s⟩ := h
    simp only [consumed]
    by_cases h1 : s.name = nm <;> by_cases h2 : c < 0 <;> simp [h1, h2] <;> omega

theorem consumed_pos_mem {r : FSum} {nm : String} (h : 0 < consumed r nm) : ∃ x ∈ r, x.2.name = nm := by
  induction r with
  | nil => simp [consumed] at h
  | cons hd t ih =>
    obtain ⟨c, s⟩ := hd
    by_cases h1 : s.name = nm
    · exact ⟨(c, s), by simp, h1⟩
    · simp only [consumed, h1] at h
      have : 0 < consumed t nm := by simpa using h
      obtain ⟨x, hx, hn⟩ := ih this
      exact ⟨x, by simp [hx], hn⟩

/-- `S` is closed in `L`: every reaction with a net gain of a species of `S` consumes a species of `S`. -/
def Closed (L : List FSum) (S : List String) : Prop :=
  ∀ r ∈ L, (∃ nm ∈ S, 0 < count r nm) → ∃ nm ∈ S, 0 < consumed r nm

instance (L : List FSum) (S : List String) : Decidable (Closed L S) := by
  unfold Closed; infer_instance

/-- **T2.** If nothing of a closed set is present, nothing of it ever appears. -/
theorem absent_stays_absent {L : List FSum} {S : List String} (hc : Closed L S) {a b : FSum}
    (h : ReachS L a b) (ha : ∀ nm ∈ S, count a nm ≤ 0) : ∀ nm ∈ S, count b nm ≤ 0 := by
  induction h with
  | refl a => exact ha
  | step r hr hf _ ih =>
    apply ih
    intro nm hnm
    rw [count_append]
    by_cases hpos : 0 < count r nm
    · exfalso
      obtain ⟨nm', hS', hc'⟩ := hc r hr ⟨nm, hnm, hpos⟩
      obtain ⟨x, hx, hn⟩ := consumed_pos_mem hc'
      have h1 := hf x hx
      rw [hn] at h1
      have h2 := ha nm' hS'
      omega
    · have := ha nm hnm; omega

/-- T2 for one species: if every reaction that makes `nm` also needs `nm`, it never appears. -/
theorem never_appears {L : List FSum} {nm : String}
    (hL : ∀ r ∈ L, 0 < count r nm → 0 < consumed r nm) {a b : FSum}
    (h : ReachS L a b) (ha : count a nm ≤ 0) : count b nm ≤ 0 := by
  have hc : Closed L [nm] := by
    intro r hr ⟨n, hn, hp⟩
    simp at hn; subst hn
    exact ⟨n, by simp, hL r hr hp⟩
  exact absent_stays_absent hc h (by intro n hn; simp at hn; subst hn; exact ha) nm (by simp)

/-! ## A species that is not named in a reaction -/

theorem consumed_eq_zero_of_not_mem {r : FSum} {nm : String} (h : nm ∉ names r) : consumed r nm = 0 := by
  induction r with
  | nil => rfl
  | cons hd t ih =>
    obtain ⟨c, s⟩ := hd
    have h1 : s.name ≠ nm := by intro e; apply h; simp [names, e]
    have h2 : nm ∉ names t := by intro m; apply h; simp [names, m]
    simp [consumed, h1, ih h2]

theorem names_scale (k : Int) (r : FSum) : names (scale k r) = names r := by
  induction r with
  | nil => rfl
  | cons hd t ih =>
    obtain ⟨c, s⟩ := hd
    have ih' : names (List.map (fun p => (k * p.1, p.2)) t) = names t := ih
    simp [scale, names, ih']

/-- The reaction names none of the species in `S`. -/
def avoids (S : List String) (r : FSum) : Bool := (names r).all fun n => !(S.contains n)

/-- No reaction of the list names a species of `S`. -/
def allAvoid (S : List String) (L : List FSum) : Bool := L.all (avoids S)

theorem allAvoid_append (S : List String) (L M : List FSum) :
    allAvoid S (L ++ M) = (allAvoid S L && allAvoid S M) := by simp [allAvoid]

theorem not_mem_names_of_allAvoid {S : List String} {L : List FSum} (h : allAvoid S L = true)
    {nm : String} (hn : nm ∈ S) {r : FSum} (hr : r ∈ L) : nm ∉ names r := by
  intro hm
  have h1 := (List.all_eq_true.mp h) r hr
  have h2 := (List.all_eq_true.mp h1) nm hm
  simp [hn] at h2

/-- A list that avoids `S` consumes no species of `S`, as written and reversed. -/
theorem consumed_zero_of_allAvoid {S : List String} {L : List FSum} (h : allAvoid S L = true)
    {nm : String} (hn : nm ∈ S) : (∀ r ∈ L, consumed r nm = 0) ∧ (∀ r ∈ L.map (scale (-1)), consumed r nm = 0) := by
  constructor
  · intro r hr; exact consumed_eq_zero_of_not_mem (not_mem_names_of_allAvoid h hn hr)
  · intro r hr
    obtain ⟨r0, hr0, e⟩ := List.mem_map.mp hr
    subst e
    apply consumed_eq_zero_of_not_mem
    rw [names_scale]; exact not_mem_names_of_allAvoid h hn hr0

/-- **T1 for a union**: a directed library `L` that does not consume `nm`, together with any list `R`
that does not name `nm`, taken in BOTH directions. -/
theorem count_mono_union {L R : List FSum} {S : List String} {nm : String}
    (hL : ∀ r ∈ L, consumed r nm = 0) (hR : allAvoid S R = true) (hn : nm ∈ S) {a b : FSum}
    (h : ReachS (L ++ (R ++ R.map (scale (-1)))) a b) : count a nm ≤ count b nm := by
  apply count_mono_reachS _ h
  intro r hr
  obtain ⟨h1, h2⟩ := consumed_zero_of_allAvoid hR hn
  rcases List.mem_append.mp hr with h' | h'
  · exact hL r h'
  · rcases List.mem_append.mp h' with h'' | h''
    · exact h1 r h''
    · exact h2 r h''

/-! ## The hypotheses are needed (false variants as proved negations) -/

private def xA : Species := ⟨"A", [(1, 1)]⟩
private def xB : Species := ⟨"B", [(1, 1)]⟩

/-- T1 without its hypothesis is false: a library with a reaction that consumes `B` lowers its count. -/
theorem count_mono_needs_hypothesis :
    ¬ (∀ (L : List FSum) (nm : String) (a b : FSum), ReachS L a b → count a nm ≤ count b nm) := by
  intro h
  have r : ReachS [[(-1, xB), (1, xA)]] [(1, xB)] ([(1, xB)] ++ [(-1, xB), (1, xA)]) :=
    ReachS.step _ (by simp) (by decide) (ReachS.refl _)
  exact absurd (h _ "B" _ _ r) (by decide)

/-- T2 without closure is false: a reaction that makes `B` from `A` makes `B` appear. -/
theorem never_appears_needs_hypothesis :
    ¬ (∀ (L : List FSum) (nm : String) (a b : FSum), ReachS L a b → count a nm ≤ 0 → count b nm ≤ 0) := by
  intro h
  have r : ReachS [[(-1, xA), (1, xB)]] [(1, xA)] ([(1, xA)] ++ [(-1, xA), (1, xB)]) :=
    ReachS.step _ (by simp) (by decide) (ReachS.refl _)
  exact absurd (h _ "B" _ _ r (by decide)) (by decide)

end BioCore.Damage
