/-!
# BioCore.Core

The trusted definitions of the chemistry layer and the general theorems about them.
Nothing here is statistical: a statement is either derived and accepted by the kernel, or it is not.

Definitions a reader has to trust (about 30 lines): `Qty`, `Formula`, `amount`, `Species`, `FSum`,
`net`, `Balanced`, `Feasible`, `Reach`. Everything else is proved from them.
-/
namespace BioCore

/-- A conserved quantity. `0` is electric charge, `1 … 118` are atomic numbers, and numbers from
`1000` on are reserved for generic groups (R-groups) that pass through a reaction unchanged. -/
abbrev Qty := Nat

/-- A composition: pairs (quantity, amount). A quantity may occur more than once; amounts add. -/
abbrev Formula := List (Qty × Int)

/-- The amount of quantity `q` in a formula. -/
def amount : Formula → Qty → Int
  | [], _ => 0
  | (k, n) :: t, q => (if k = q then n else 0) + amount t q

/-- A molecular species: a name and a composition (atoms of each element, and charge). -/
structure Species where
  name : String
  formula : Formula
  deriving Repr

/-- A formal sum of species with integer coefficients.
Read as a reaction, negative coefficients are consumed and positive ones produced.
Read as a state, coefficients are molecule counts. -/
abbrev FSum := List (Int × Species)

/-- Net amount of quantity `q` in a formal sum. -/
def net : FSum → Qty → Int
  | [], _ => 0
  | (c, s) :: t, q => c * amount s.formula q + net t q

/-- A reaction is balanced when it creates and destroys nothing: every element and charge nets to zero. -/
def Balanced (r : FSum) : Prop := ∀ q, net r q = 0

/-! ## Additivity -/

theorem amount_append (a b : Formula) (q : Qty) :
    amount (a ++ b) q = amount a q + amount b q := by
  induction a with
  | nil => simp [amount]
  | cons h t ih =>
    obtain ⟨k, n⟩ := h
    simp [amount, ih, Int.add_assoc]

theorem net_append (a b : FSum) (q : Qty) : net (a ++ b) q = net a q + net b q := by
  induction a with
  | nil => simp [net]
  | cons h t ih =>
    obtain ⟨c, s⟩ := h
    simp [net, ih, Int.add_assoc]

/-- Multiply every coefficient of a formal sum by `k`. -/
def scale (k : Int) (r : FSum) : FSum := r.map (fun p => (k * p.1, p.2))

theorem net_scale (k : Int) (r : FSum) (q : Qty) : net (scale k r) q = k * net r q := by
  induction r with
  | nil => simp [scale, net]
  | cons h t ih =>
    obtain ⟨c, s⟩ := h
    have ih' : net (List.map (fun p => (k * p.1, p.2)) t) q = k * net t q := ih
    simp [scale, net, ih', Int.mul_add, Int.mul_assoc]

theorem balanced_append {a b : FSum} (ha : Balanced a) (hb : Balanced b) : Balanced (a ++ b) := by
  intro q; rw [net_append, ha q, hb q]; rfl

theorem balanced_scale (k : Int) {r : FSum} (h : Balanced r) : Balanced (scale k r) := by
  intro q; rw [net_scale, h q]; simp

/-! ## A decision procedure for balance, proved correct

`balancedB` checks only the quantities that occur in the reaction. The two theorems below show
that this finite check is equivalent to `Balanced`, which quantifies over every quantity. -/

/-- Quantities named in a formula. -/
def fkeys (f : Formula) : List Qty := f.map (·.1)

/-- Quantities named anywhere in a formal sum. -/
def keys : FSum → List Qty
  | [] => []
  | (_, s) :: t => fkeys s.formula ++ keys t

theorem amount_eq_zero_of_not_mem {f : Formula} {q : Qty} (h : q ∉ fkeys f) : amount f q = 0 := by
  induction f with
  | nil => rfl
  | cons hd t ih =>
    obtain ⟨k, n⟩ := hd
    have hk : k ≠ q := by
      intro e; apply h; simp [fkeys, e]
    have ht : q ∉ fkeys t := by
      intro m; apply h; simp only [fkeys, List.map_cons, List.mem_cons]; exact Or.inr m
    simp [amount, hk, ih ht]

theorem net_eq_zero_of_not_mem {r : FSum} {q : Qty} (h : q ∉ keys r) : net r q = 0 := by
  induction r with
  | nil => rfl
  | cons hd t ih =>
    obtain ⟨c, s⟩ := hd
    have hs : q ∉ fkeys s.formula := by
      intro m; apply h; simp only [keys, List.mem_append]; exact Or.inl m
    have ht : q ∉ keys t := by
      intro m; apply h; simp only [keys, List.mem_append]; exact Or.inr m
    simp [net, amount_eq_zero_of_not_mem hs, ih ht]

/-- The finite check: every quantity that occurs nets to zero. -/
def balancedB (r : FSum) : Bool := (keys r).all (fun q => net r q == 0)

theorem balanced_of_check {r : FSum} (h : balancedB r = true) : Balanced r := by
  intro q
  by_cases hq : q ∈ keys r
  · have h2 := (List.all_eq_true.mp h) q hq
    simpa using h2
  · exact net_eq_zero_of_not_mem hq

theorem check_of_balanced {r : FSum} (h : Balanced r) : balancedB r = true := by
  apply List.all_eq_true.mpr
  intro q _
  simp [h q]

instance (r : FSum) : Decidable (Balanced r) :=
  decidable_of_iff (balancedB r = true) ⟨balanced_of_check, check_of_balanced⟩

/-! ## Pathways and reachability -/

/-- Net conversion of a pathway: each reaction taken `k` times. -/
def pathNet : List (Int × FSum) → FSum
  | [] => []
  | (k, r) :: t => scale k r ++ pathNet t

/-- A pathway built from balanced reactions is balanced. -/
theorem pathNet_balanced {p : List (Int × FSum)} (h : ∀ x ∈ p, Balanced x.2) :
    Balanced (pathNet p) := by
  induction p with
  | nil => intro q; rfl
  | cons hd t ih =>
    obtain ⟨k, r⟩ := hd
    have hr : Balanced r := h (k, r) (by simp)
    have ht : ∀ x ∈ t, Balanced x.2 := fun x hx => h x (by simp [hx])
    exact balanced_append (balanced_scale k hr) (ih ht)

/-- Number of molecules of the species called `nm` in a state. -/
def count : FSum → String → Int
  | [], _ => 0
  | (c, s) :: t, nm => (if s.name = nm then c else 0) + count t nm

/-- A reaction can fire in a state when no species it touches would go below zero. -/
def Feasible (st r : FSum) : Prop := ∀ x ∈ r, 0 ≤ count (st ++ r) x.2.name

/-- `Reach L a b`: state `b` is obtained from state `a` by firing reactions of the library `L`,
one at a time, never using a molecule that is not there. -/
inductive Reach (L : List FSum) : FSum → FSum → Prop where
  | refl (a : FSum) : Reach L a a
  | step {a b : FSum} (r : FSum) : r ∈ L → Feasible a r → Reach L (a ++ r) b → Reach L a b

/-- Conservation: whatever is reached through balanced reactions has exactly the atoms and the
charge of the starting state. -/
theorem reach_conserves {L : List FSum} (hL : ∀ r ∈ L, Balanced r) {a b : FSum}
    (h : Reach L a b) : ∀ q, net b q = net a q := by
  induction h with
  | refl a => intro q; rfl
  | step r hr _ _ ih =>
    intro q
    rw [ih q, net_append, hL r hr q]; simp

/-- Impossibility from conservation: a state with a different amount of any element, or a different
charge, cannot be reached, whatever the pathway. -/
theorem not_reach_of_net_ne {L : List FSum} (hL : ∀ r ∈ L, Balanced r) {a b : FSum} {q : Qty}
    (hne : net b q ≠ net a q) : ¬ Reach L a b :=
  fun h => hne (reach_conserves hL h q)

end BioCore
