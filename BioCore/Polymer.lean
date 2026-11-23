import BioCore.Core
/-!
# BioCore.Polymer

Linear polymers made one unit at a time (RNA from nucleoside triphosphates, DNA from deoxynucleoside
triphosphates, peptides from amino acids). One theorem covers every sequence of every length.
-/
namespace BioCore

/-- The chemistry of adding one unit to a linear polymer.
`step_balanced` is the only chemical fact required: for each kind of unit, the activated monomer
has exactly the atoms and charge of the unit that stays in the chain plus the by-product. -/
structure PolyChem (α : Type) where
  /-- activated building block consumed at each position -/
  monomer : α → Species
  /-- what remains in the chain -/
  residue : α → Species
  /-- by-product released for each unit added -/
  leaving : Species
  step_balanced : ∀ a, Balanced [(-1, monomer a), (1, residue a), (1, leaving)]

/-- Composition of a starter extended by the units of `s`. -/
def chainFormula {α : Type} (P : PolyChem α) (init : Formula) : List α → Formula
  | [] => init
  | a :: t => (P.residue a).formula ++ chainFormula P init t

/-- The polymer obtained by extending the starter molecule `init` with the sequence `s`. -/
def chain {α : Type} (P : PolyChem α) (init : Species) (s : List α) (name : String) : Species :=
  ⟨name, chainFormula P init.formula s⟩

/-- The overall reaction: starter + one monomer per position → chain + one by-product per position. -/
def elongation {α : Type} (P : PolyChem α) (init : Species) (s : List α) (name : String) : FSum :=
  ((-1, init) :: s.map (fun a => (-1, P.monomer a))) ++
    ((1, chain P init s name) :: s.map (fun _ => (1, P.leaving)))

theorem elongation_core {α : Type} (P : PolyChem α) (init : Formula) (s : List α) (q : Qty) :
    net (s.map (fun a => ((-1 : Int), P.monomer a))) q + amount (chainFormula P init s) q
      + net (s.map (fun _ => ((1 : Int), P.leaving))) q = amount init q := by
  induction s with
  | nil => simp [net, chainFormula]
  | cons a t ih =>
    have hb := P.step_balanced a q
    simp only [net] at hb
    simp only [List.map_cons, net, chainFormula, amount_append]
    omega

/-- **Templated synthesis conserves atoms and charge, for every sequence.** -/
theorem elongation_balanced {α : Type} (P : PolyChem α) (init : Species) (s : List α)
    (name : String) : Balanced (elongation P init s name) := by
  intro q
  have h := elongation_core P init.formula s q
  simp only [elongation, net_append, net, chain]
  omega

end BioCore
