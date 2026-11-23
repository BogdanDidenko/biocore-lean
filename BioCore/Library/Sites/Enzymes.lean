import BioCore.Library.Sites.Marks
/-!
# BioCore.Library.Sites.Enzymes

HAND-WRITTEN (track st, kernel 0.2). Writers and erasers under the strict firing rule of
`BioCore.Firing`. Nothing here is an axiom and nothing here is data.

* `catalysed E r`: the reaction `r` with the enzyme `E` written on both sides. It is balanced exactly
  when `r` is (`catalysed_balanced_iff`), and under the strict rule it cannot fire in a state without
  `E` (`not_feasibleS_without_enzyme`).
* `dead_reachS`, `dead_reachSC`: **if no reaction of a library can fire in a state, nothing else is
  reachable from it.**
* `Siphon L B`: every reaction of `L` that makes (net) some member of the name set `B` consumes a
  member of `B`. `siphon_reachS`, `siphon_reachSC`: **a siphon that is empty stays empty**, whatever
  else the library does. This is the invariant behind every statement of the form "without these
  molecules that molecule is unreachable"; `Siphon` is decidable, so for a concrete library it is
  checked by the kernel.
* `no_enzyme_no_mark`: the special case asked for. ASSUMPTIONS, all of them explicit hypotheses:
  (1) every reaction of the library that makes the marked form consumes one of the listed enzymes
  (the library is taken as the complete list of ways to make the mark: a closed-world assumption,
  and the library is a copy of database annotations); (2) no reaction of the library makes a listed
  enzyme; (3) the starting state holds neither the marked form nor a listed enzyme. Conclusion: no
  reachable state holds the marked form. Nothing is said about cells: a kinase missing from the
  database is missing from the library.
* `reachSC_two`, `cycle_cost_balanced`: a writer followed by an eraser; the net cost of the cycle is
  a balanced reaction among the co-substrates alone.
-/
namespace BioCore.Sites
open BioCore

/-- The reaction `r` with the enzyme `E` written on both sides. -/
def catalysed (E : Species) (r : FSum) : FSum := (-1, E) :: (1, E) :: r

theorem catalysed_balanced_iff (E : Species) (r : FSum) : Balanced (catalysed E r) ↔ Balanced r := by
  constructor <;> intro h q <;> have := h q <;> simp only [catalysed, net] at this ⊢ <;> omega

theorem count_catalysed (E : Species) (r : FSum) (nm : String) :
    count (catalysed E r) nm = count r nm := by
  simp only [catalysed, count]; split <;> omega

theorem consumed_nonneg (r : FSum) (nm : String) : 0 ≤ consumed r nm := by
  induction r with
  | nil => simp [consumed]
  | cons h t ih =>
    obtain ⟨c, s⟩ := h
    simp only [consumed]
    by_cases h1 : s.name = nm <;> by_cases h2 : c < 0 <;> simp [h1, h2] <;> omega

theorem catalysed_consumes (E : Species) (r : FSum) : 1 ≤ consumed (catalysed E r) E.name := by
  have := consumed_nonneg r E.name
  simp only [catalysed, consumed]
  simp; omega

/-- Under the strict rule a catalysed reaction needs its enzyme. -/
theorem feasibleS_catalysed_needs {st : FSum} {E : Species} {r : FSum}
    (h : FeasibleS st (catalysed E r)) : 1 ≤ count st E.name := by
  have h1 := h (-1, E) (by simp [catalysed])
  have h2 := catalysed_consumes E r
  simp only at h1; omega

theorem not_feasibleS_without_enzyme {st : FSum} {E : Species} (r : FSum)
    (h : count st E.name ≤ 0) : ¬ FeasibleS st (catalysed E r) :=
  fun hf => by have := feasibleS_catalysed_needs hf; omega

/-! ## A state in which nothing can fire -/

/-- **If no reaction of the library can fire in a state, nothing else is reachable.** -/
theorem dead_reachS {L : List FSum} {a b : FSum} (h : ∀ r ∈ L, ¬ FeasibleS a r)
    (hr : ReachS L a b) : b = a := by
  cases hr with
  | refl => rfl
  | step r hm hf _ => exact absurd hf (h r hm)

theorem dead_reachSC {L : List FSum} {a b : FSum} (h : ∀ r ∈ L, ¬ FeasibleS a r)
    (hr : ReachSC L a b) : StateEq a b := by
  obtain ⟨b', hb, he⟩ := hr
  rw [dead_reachS h hb] at he; exact he

/-! ## Siphons: an empty set of species that stays empty -/

/-- None of the species named in `B` is present. -/
def Absent (st : FSum) (B : List String) : Prop := ∀ n ∈ B, count st n ≤ 0

/-- Every reaction of `L` that makes (net) a member of `B` consumes a member of `B`. -/
def Siphon (L : List FSum) (B : List String) : Prop :=
  ∀ r ∈ L, (∃ n ∈ B, 0 < count r n) → ∃ m ∈ B, 0 < consumed r m

instance instDecidableAbsent (st : FSum) (B : List String) : Decidable (Absent st B) := by
  unfold Absent; infer_instance
instance instDecidableSiphon (L : List FSum) (B : List String) : Decidable (Siphon L B) := by
  unfold Siphon; infer_instance

theorem consumed_pos_mem {r : FSum} {m : String} (h : 0 < consumed r m) : ∃ x ∈ r, x.2.name = m := by
  induction r with
  | nil => simp [consumed] at h
  | cons hd t ih =>
    obtain ⟨c, s⟩ := hd
    by_cases h1 : s.name = m
    · exact ⟨(c, s), by simp, h1⟩
    · simp only [consumed, h1, ite_false] at h
      obtain ⟨x, hx, hn⟩ := ih (by omega)
      exact ⟨x, by simp [hx], hn⟩

theorem siphon_step {L : List FSum} {B : List String} (hS : Siphon L B) {a r : FSum} (hr : r ∈ L)
    (hf : FeasibleS a r) (ha : Absent a B) : Absent (a ++ r) B := by
  intro n hn
  rw [count_append]
  have hcn : count r n ≤ 0 := by
    apply Int.not_lt.mp
    intro hpos
    obtain ⟨m, hm, hc⟩ := hS r hr ⟨n, hn, hpos⟩
    obtain ⟨x, hx, hxn⟩ := consumed_pos_mem hc
    have h1 := hf x hx
    rw [hxn] at h1
    have h2 := ha m hm
    omega
  have := ha n hn
  omega

/-- **An empty siphon stays empty** along every derivation of the library. -/
theorem siphon_reachS {L : List FSum} {B : List String} (hS : Siphon L B) {a b : FSum}
    (hr : ReachS L a b) : Absent a B → Absent b B := by
  induction hr with
  | refl a => exact id
  | step r hm hf _ ih => exact fun ha => ih (siphon_step hS hm hf ha)

theorem siphon_reachSC {L : List FSum} {B : List String} (hS : Siphon L B) {a b : FSum}
    (hr : ReachSC L a b) (ha : Absent a B) : Absent b B := by
  obtain ⟨b', hb, he⟩ := hr
  intro n hn
  rw [← he.1 n]; exact siphon_reachS hS hb ha n hn

/-- **Without the enzymes that the library lists for a mark, the marked form is unreachable.**
`M` is the name of the marked species, `Es` the names of the enzymes. See the header of this file for
what the three hypotheses assume. -/
theorem no_enzyme_no_mark (L : List FSum) (M : String) (Es : List String)
    (h1 : ∀ r ∈ L, 0 < count r M → ∃ e ∈ Es, 0 < consumed r e)
    (h2 : ∀ r ∈ L, ∀ e ∈ Es, count r e ≤ 0)
    {a b : FSum} (hM : count a M ≤ 0) (hE : ∀ e ∈ Es, count a e ≤ 0) (hr : ReachSC L a b) :
    count b M ≤ 0 := by
  have hS : Siphon L (M :: Es) := by
    intro r hr ⟨n, hn, hpos⟩
    rcases List.mem_cons.mp hn with rfl | hn'
    · obtain ⟨e, he, hc⟩ := h1 r hr hpos
      exact ⟨e, List.mem_cons_of_mem _ he, hc⟩
    · have := h2 r hr n hn'; omega
  have ha : Absent a (M :: Es) := by
    intro n hn
    rcases List.mem_cons.mp hn with rfl | hn'
    · exact hM
    · exact hE n hn'
  exact siphon_reachSC hS hr ha M (by simp)

/-- A library in which every reaction is catalysed by an enzyme named in `B`: `B` is a siphon. -/
theorem siphon_of_catalysed (L : List FSum) (B : List String)
    (h : ∀ r ∈ L, ∃ E r0, r = catalysed E r0 ∧ E.name ∈ B) : Siphon L B := by
  intro r hr _
  obtain ⟨E, r0, rfl, hE⟩ := h r hr
  exact ⟨E.name, hE, by have := catalysed_consumes E r0; omega⟩

/-- The writers of one site: the same site reaction once per listed enzyme. -/
def writers (Es : List Species) (r : FSum) : List FSum := Es.map fun E => catalysed E r

/-- **One site, its listed enzymes, any state without them**: nothing fires, so every reachable
state is the starting state (in particular the marked form does not appear). General in the site
reaction `r` and the enzyme list; the list is the database's, copied as an assumption. -/
theorem writers_dead (Es : List Species) (r : FSum) {a b : FSum}
    (hE : ∀ E ∈ Es, count a E.name ≤ 0) (hr : ReachSC (writers Es r) a b) : StateEq a b := by
  apply dead_reachSC _ hr
  intro x hx
  obtain ⟨E, hEm, rfl⟩ := List.mem_map.mp hx
  exact not_feasibleS_without_enzyme r (hE E hEm)

/-! ## Cycles -/

/-- Two reactions fired one after the other. -/
theorem reachSC_two {L : List FSum} {a b r1 r2 : FSum} (h1 : r1 ∈ L) (f1 : FeasibleS a r1)
    (h2 : r2 ∈ L) (f2 : FeasibleS (a ++ r1) r2) (he : StateEq ((a ++ r1) ++ r2) b) : ReachSC L a b :=
  ⟨_, ReachS.step r1 h1 f1 (ReachS.step r2 h2 f2 (ReachS.refl _)), he⟩

/-- One reaction fired. -/
theorem reachSC_one {L : List FSum} {a b r1 : FSum} (h1 : r1 ∈ L) (f1 : FeasibleS a r1)
    (he : StateEq (a ++ r1) b) : ReachSC L a b :=
  ⟨_, ReachS.step r1 h1 f1 (ReachS.refl _), he⟩

/-- **Net cost of a write-erase cycle.** If a writer takes a residue from `x` to `y` with
co-substrates `cw` and an eraser takes it back with co-substrates `ce`, then `cw ++ ce` is by itself a
balanced reaction: what the cell pays for one turn of the cycle. -/
theorem cycle_cost_balanced (x y : Species) (cw ce : FSum)
    (hw : Balanced ((-1, x) :: (1, y) :: cw)) (he : Balanced ((-1, y) :: (1, x) :: ce)) :
    Balanced (cw ++ ce) := by
  intro q
  have a := hw q
  have b := he q
  simp only [net] at a b
  rw [net_append]; omega

end BioCore.Sites
