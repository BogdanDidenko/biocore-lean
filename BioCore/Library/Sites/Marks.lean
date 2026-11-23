import BioCore.Library.Sites.SiteProtein
/-!
# BioCore.Library.Sites.Marks

HAND-WRITTEN (track st, kernel 0.2). The general machinery of the named-site library. Nothing here is
an axiom and nothing here is data.

* `SameF`, `NetEq`: equal compositions, formal sums with equal net amounts; both decidable or closed
  under the operations used.
* Chain ends as site states: `capN`, `capC` (what a terminal residue has more than an internal one)
  and `ntSite`, `ctSite`. `termini_sum` shows the two caps are the kernel's one water.
* `bridgeA`, `bridgeB`: a link between two residues of one chain (a disulfide), held as two site states
  whose names record the partner.
* `Part`: what a Rhea record does to ONE protein participant: one internal residue changes
  (`one`), the N-terminal or the C-terminal residue changes (`nterm`, `cterm`), two residues become one
  bridged species (`form`) or the reverse (`break`).
* `MarkRxn`: a residue-level lemma for a Rhea record with any number of protein participants; `bal` is
  the one chemical fact, checked by the kernel on the residues.
* `mark_iff`, `mark_balanced`: **the reaction written on proteins, at any eligible sites of any
  sequences, is balanced exactly when it is balanced on the residues.** For a single internal residue
  this is `site_rxn_iff` of the shared core (`mark_at_one`).
* Several marks on one protein: `setAll_perm` (the resulting protein, name and formula, does not depend
  on the order in which marks at different positions are put on), `setSeq_netEq` and
  `setSeq_amount` (the composition of a protein with any list of marks is the composition of the
  unmodified protein plus the residue differences), `one_one_commute` (two marks at different sites
  can be made in either order and each step stays eligible).
-/
namespace BioCore.Sites
open BioCore

/-! ## Equal compositions, net-equal sums -/

/-- Two formulas hold the same amount of every element and the same charge. -/
def SameF (f g : Formula) : Prop := ∀ q, amount f q = amount g q

theorem sameF_iff (f g : Formula) : SameF f g ↔ Balanced [(1, ⟨"", f⟩), (-1, ⟨"", g⟩)] := by
  constructor
  · intro h q; have := h q; simp only [net]; omega
  · intro h q; have := h q; simp only [net] at this; omega

instance instDecidableSameF (f g : Formula) : Decidable (SameF f g) :=
  decidable_of_iff _ (sameF_iff f g).symm

/-- Two formal sums have the same net amount of every element and the same net charge. -/
def NetEq (a b : FSum) : Prop := ∀ q, net a q = net b q

theorem NetEq.refl (a : FSum) : NetEq a a := fun _ => rfl
theorem NetEq.symm {a b : FSum} (h : NetEq a b) : NetEq b a := fun q => (h q).symm
theorem NetEq.trans {a b c : FSum} (h1 : NetEq a b) (h2 : NetEq b c) : NetEq a c :=
  fun q => (h1 q).trans (h2 q)
theorem NetEq.append {a b c d : FSum} (h1 : NetEq a b) (h2 : NetEq c d) : NetEq (a ++ c) (b ++ d) := by
  intro q; rw [net_append, net_append, h1 q, h2 q]

theorem netEq_iff (a b : FSum) : NetEq a b ↔ Balanced (a ++ scale (-1) b) := by
  constructor
  · intro h q; rw [net_append, net_scale, h q]; omega
  · intro h q; have := h q; rw [net_append, net_scale] at this; omega

instance instDecidableNetEq (a b : FSum) : Decidable (NetEq a b) :=
  decidable_of_iff _ (netEq_iff a b).symm

/-- Net-equal sums are balanced together. -/
theorem balanced_congr {a b : FSum} (h : NetEq a b) : Balanced a ↔ Balanced b := by
  constructor <;> intro hb q
  · rw [← h q]; exact hb q
  · rw [h q]; exact hb q

/-- One site changed: on the protein and on the residue the net amounts are the same. -/
theorem set_netEq (P : SProt) (i : Nat) (x y : Site) (h : P.sites[i]? = some x) :
    NetEq [(-1, P.species), (1, (P.set i y).species)] [(-1, x.res), (1, y.res)] := by
  intro q
  have k := amount_prot_set P.sites i x y h q
  simp only [net, SProt.species, SProt.set]; omega

/-! ## Chain ends as site states -/

/-- What an N-terminal residue (ammonium form) has more than the internal residue: 2 H, charge +1. -/
def capN : Formula := [(1, 2), (0, 1)]
def uncapN : Formula := [(1, -2), (0, -1)]
/-- What a C-terminal residue (carboxylate form) has more than the internal residue: 1 O, charge -1. -/
def capC : Formula := [(8, 1), (0, -1)]
def uncapC : Formula := [(8, -1), (0, 1)]

/-- The two caps together are the one water that `protFormula` adds for the chain ends. -/
theorem termini_sum : SameF (capN ++ capC) water.formula := by decide
theorem capN_uncapN : SameF (capN ++ uncapN) [] := by decide
theorem capC_uncapC : SameF (capC ++ uncapC) [] := by decide

/-- Site state of the first position holding the N-terminal residue species `s` (a ChEBI N-terminal
residue): its composition without the cap, because `protFormula` already counts the chain ends. -/
def ntSite (a : AA) (s : Species) : Site := ⟨a, ⟨s.name, s.formula ++ uncapN⟩⟩
/-- Site state of the last position holding the C-terminal residue species `s`. -/
def ctSite (a : AA) (s : Species) : Site := ⟨a, ⟨s.name, s.formula ++ uncapC⟩⟩

/-! ## A link between two residues of one chain -/

/-- First residue of a bridge: carries the whole bridged species `b` (for a disulfide, the L-cystine
residue); the name records the partner position (counted from 1). -/
def bridgeA (b : Species) (j : Nat) : Species :=
  ⟨b.name ++ " (bridge to residue " ++ natStr (j + 1) ++ ")", b.formula⟩
/-- Second residue of a bridge: its atoms are counted at the first residue. -/
def bridgeB (i : Nat) : Species := ⟨"(in the bridge of residue " ++ natStr (i + 1) ++ ")", []⟩

/-! ## What a reaction does to one protein participant -/

inductive Part where
  /-- one internal residue of amino acid `aa` goes from `src` to `dst` -/
  | one (aa : AA) (src dst : Species)
  /-- the N-terminal residue goes from the N-terminal species `src` to `dst` -/
  | nterm (aa : AA) (src dst : Species)
  /-- the C-terminal residue goes from the C-terminal species `src` to `dst` -/
  | cterm (aa : AA) (src dst : Species)
  /-- two residues `x`, `u` become one bridged species `b` -/
  | form (a1 a2 : AA) (x u b : Species)
  /-- one bridged species `b` becomes two residues `x`, `u` -/
  | break (a1 a2 : AA) (b x u : Species)

/-- The residue-level terms of a part. -/
def Part.terms : Part → FSum
  | .one _ src dst => [(-1, src), (1, dst)]
  | .nterm _ src dst => [(-1, src), (1, dst)]
  | .cterm _ src dst => [(-1, src), (1, dst)]
  | .form _ _ x u b => [(-1, x), (-1, u), (1, b)]
  | .break _ _ b x u => [(-1, b), (1, x), (1, u)]

/-- The protein after the part has acted at position `i` (and `j` for a bridge); positions from 0. -/
def Part.apply : Part → SProt → Nat → Nat → SProt
  | .one aa _ dst, P, i, _ => P.set i ⟨aa, dst⟩
  | .nterm aa _ dst, P, _, _ => P.set 0 (ntSite aa dst)
  | .cterm aa _ dst, P, _, _ => P.set (P.sites.length - 1) (ctSite aa dst)
  | .form a1 a2 _ _ b, P, i, j => (P.set i ⟨a1, bridgeA b j⟩).set j ⟨a2, bridgeB i⟩
  | .break a1 a2 _ x u, P, i, j => (P.set i ⟨a1, x⟩).set j ⟨a2, u⟩

/-- A terminal position is eligible when it holds amino acid `aa` in a state with composition `f`. -/
def TermOK (o : Option Site) (aa : AA) (f : Formula) : Prop :=
  match o with
  | some x => x.aa = aa ∧ SameF x.res.formula f
  | none => False

instance instDecidableTermOK (o : Option Site) (aa : AA) (f : Formula) : Decidable (TermOK o aa f) := by
  unfold TermOK; cases o <;> infer_instance

/-- When a part can act at position `i` (and `j`) of protein `P`.
An internal residue must be exactly in the source state. A terminal residue must be the first (last)
position, hold the amino acid of the part and have the composition of the source species without
its cap; an unmodified first residue qualifies exactly when the source species is the N-terminal
form of that amino acid. -/
def Part.Eligible : Part → SProt → Nat → Nat → Prop
  | .one aa src _, P, i, _ => P.sites[i]? = some ⟨aa, src⟩
  | .nterm aa src _, P, _, _ => TermOK P.sites[0]? aa (src.formula ++ uncapN)
  | .cterm aa src _, P, _, _ => TermOK P.sites[P.sites.length - 1]? aa (src.formula ++ uncapC)
  | .form a1 a2 x u _, P, i, j => i ≠ j ∧ P.sites[i]? = some ⟨a1, x⟩ ∧ P.sites[j]? = some ⟨a2, u⟩
  | .break a1 a2 b _ _, P, i, j =>
      i ≠ j ∧ P.sites[i]? = some ⟨a1, bridgeA b j⟩ ∧ P.sites[j]? = some ⟨a2, bridgeB i⟩

instance instDecidableEligible (p : Part) (P : SProt) (i j : Nat) : Decidable (p.Eligible P i j) := by
  cases p <;> unfold Part.Eligible <;> infer_instance

theorem term_netEq (P : SProt) (k : Nat) (aa : AA) (src dst : Species) (un : Formula)
    (h : TermOK P.sites[k]? aa (src.formula ++ un)) :
    NetEq [(-1, P.species), (1, (P.set k ⟨aa, ⟨dst.name, dst.formula ++ un⟩⟩).species)]
      [(-1, src), (1, dst)] := by
  unfold TermOK at h
  split at h
  · rename_i x hx
    obtain ⟨_, hs⟩ := h
    refine (set_netEq P k x _ hx).trans ?_
    intro q
    have := hs q
    simp only [net, amount_append] at this ⊢
    omega
  · exact h.elim

/-- **A part on a protein and on its residues**: the same net amounts, at any eligible position. -/
theorem part_netEq (p : Part) (P : SProt) (i j : Nat) (h : p.Eligible P i j) :
    NetEq [(-1, P.species), (1, (p.apply P i j).species)] p.terms := by
  cases p with
  | one aa src dst => exact set_netEq P i ⟨aa, src⟩ ⟨aa, dst⟩ h
  | nterm aa src dst => exact term_netEq P 0 aa src dst uncapN h
  | cterm aa src dst => exact term_netEq P _ aa src dst uncapC h
  | form a1 a2 x u b =>
    obtain ⟨hij, hi, hj⟩ := h
    have hj' : (P.sites.set i ⟨a1, bridgeA b j⟩)[j]? = some ⟨a2, u⟩ := by
      rw [List.getElem?_set_ne hij]; exact hj
    intro q
    have k1 := amount_prot_set P.sites i ⟨a1, x⟩ ⟨a1, bridgeA b j⟩ hi q
    have k2 := amount_prot_set (P.sites.set i ⟨a1, bridgeA b j⟩) j ⟨a2, u⟩ ⟨a2, bridgeB i⟩ hj' q
    simp only [net, Part.apply, Part.terms, SProt.species, SProt.set, bridgeA, bridgeB, amount] at k1 k2 ⊢
    omega
  | «break» a1 a2 b x u =>
    obtain ⟨hij, hi, hj⟩ := h
    have hj' : (P.sites.set i ⟨a1, x⟩)[j]? = some ⟨a2, bridgeB i⟩ := by
      rw [List.getElem?_set_ne hij]; exact hj
    intro q
    have k1 := amount_prot_set P.sites i ⟨a1, bridgeA b j⟩ ⟨a1, x⟩ hi q
    have k2 := amount_prot_set (P.sites.set i ⟨a1, x⟩) j ⟨a2, bridgeB i⟩ ⟨a2, u⟩ hj' q
    simp only [net, Part.apply, Part.terms, SProt.species, SProt.set, bridgeA, bridgeB, amount] at k1 k2 ⊢
    omega

/-! ## Residue-level lemmas for reactions with any number of protein participants -/

/-- Where a part acts: a protein and one or two positions (counted from 0; `j` is used by bridges). -/
structure Place where
  P : SProt
  i : Nat
  j : Nat

def partsTerms : List Part → FSum
  | [] => []
  | p :: t => p.terms ++ partsTerms t

/-- The protein-level terms: for every part, the protein before (consumed) and after (produced). -/
def protTerms : List Part → List Place → FSum
  | p :: ps, x :: xs => (-1, x.P.species) :: (1, (p.apply x.P x.i x.j).species) :: protTerms ps xs
  | _, _ => []

/-- Every part is given a place where it is eligible. -/
def AllEligible : List Part → List Place → Prop
  | [], [] => True
  | p :: ps, x :: xs => p.Eligible x.P x.i x.j ∧ AllEligible ps xs
  | _, _ => False

theorem protTerms_netEq : ∀ (ps : List Part) (xs : List Place), AllEligible ps xs →
    NetEq (protTerms ps xs) (partsTerms ps)
  | [], [], _ => NetEq.refl _
  | [], _ :: _, h => h.elim
  | _ :: _, [], h => h.elim
  | p :: ps, x :: xs, h => by
    have h1 := part_netEq p x.P x.i x.j h.1
    have h2 := protTerms_netEq ps xs h.2
    exact NetEq.append h1 h2

/-- **Any reaction on proteins, at any eligible sites, with any co-substrates, is balanced exactly
when it is balanced on the residues.** -/
theorem mark_iff (ps : List Part) (xs : List Place) (h : AllEligible ps xs) (co : FSum) :
    Balanced (protTerms ps xs ++ co) ↔ Balanced (partsTerms ps ++ co) :=
  balanced_congr (NetEq.append (protTerms_netEq ps xs h) (NetEq.refl co))

/-- A residue-level lemma: the protein participants of a reaction (as parts), the other terms, and
the one chemical fact needed (`bal`, checked by the kernel on the residue species). -/
structure MarkRxn where
  name : String
  parts : List Part
  co : FSum
  bal : Balanced (partsTerms parts ++ co)

/-- The reaction of the lemma written on proteins at the given places. -/
def MarkRxn.at (R : MarkRxn) (xs : List Place) : FSum := protTerms R.parts xs ++ R.co

/-- **The modification theorem**: at any eligible places the reaction on the proteins is balanced. -/
theorem mark_balanced (R : MarkRxn) (xs : List Place) (h : AllEligible R.parts xs) :
    Balanced (R.at xs) := (mark_iff R.parts xs h R.co).mpr R.bal

/-- For one internal residue the statement is the one of the shared core (`site_rxn_iff`). -/
theorem mark_at_one (aa : AA) (src dst : Species) (co : FSum) (P : SProt) (i j : Nat) :
    protTerms [Part.one aa src dst] [⟨P, i, j⟩] ++ co
      = (-1, P.species) :: (1, (P.set i ⟨aa, dst⟩).species) :: co := rfl

/-- An unmodified position of a sequence. -/
theorem plain_site {s : List AA} {i : Nat} {a : AA} (h : s[i]? = some a) (nm : String) :
    (protein nm s).sites[i]? = some (Site.plain a) := by
  simp [protein, plain, List.getElem?_map, h]

/-! ## Several marks on one protein -/

theorem SProt.set_comm (P : SProt) (i j : Nat) (y v : Site) (h : i ≠ j) :
    (P.set i y).set j v = (P.set j v).set i y := by
  simp only [SProt.set]
  rw [List.set_comm _ _ h]

/-- Put a list of site states on a protein, one after another. -/
def setAll (P : SProt) : List (Nat × Site) → SProt
  | [] => P
  | (i, y) :: t => setAll (P.set i y) t

/-- **The order of marking does not matter for the resulting species**: marks at pairwise different
positions give the same protein (same derived name, same derived formula) in any order. -/
theorem setAll_perm {l l' : List (Nat × Site)} (hp : l.Perm l') :
    (l.map (·.1)).Nodup → ∀ P : SProt, setAll P l = setAll P l' := by
  induction hp with
  | nil => intro _ _; rfl
  | cons x _ ih =>
    intro hn P
    obtain ⟨i, y⟩ := x
    simp only [List.map_cons, List.nodup_cons] at hn
    simp only [setAll]
    exact ih hn.2 _
  | swap x y l =>
    intro hn P
    obtain ⟨i, a⟩ := x
    obtain ⟨j, b⟩ := y
    simp only [List.map_cons, List.nodup_cons, List.mem_cons, not_or] at hn
    simp only [setAll]
    rw [SProt.set_comm P j i b a (fun e => hn.1.1 e)]
  | trans h1 _ ih1 ih2 =>
    intro hn P
    have hn2 := ((h1.map (·.1)).nodup_iff).mp hn
    exact (ih1 hn P).trans (ih2 hn2 P)

/-- A list of marks with the state each position must hold before (old) and after (new), applied
one after another. -/
def setSeq (P : SProt) : List (Nat × Site × Site) → SProt
  | [] => P
  | (i, _, y) :: t => setSeq (P.set i y) t

/-- Each mark of the list finds its position in the stated old state. -/
def Marked (P : SProt) : List (Nat × Site × Site) → Prop
  | [] => True
  | (i, x, y) :: t => P.sites[i]? = some x ∧ Marked (P.set i y) t

/-- The residue differences of a list of marks. -/
def deltaTerms : List (Nat × Site × Site) → FSum
  | [] => []
  | (_, x, y) :: t => (-1, x.res) :: (1, y.res) :: deltaTerms t

/-- **Composition of a protein with any list of marks**: the protein before and after differ by the
residue differences of the marks, for every sequence and every list. -/
theorem setSeq_netEq : ∀ (ms : List (Nat × Site × Site)) (P : SProt), Marked P ms →
    NetEq [(-1, P.species), (1, (setSeq P ms).species)] (deltaTerms ms)
  | [], P, _ => by intro q; simp only [net, setSeq, deltaTerms]; omega
  | (i, x, y) :: t, P, h => by
    have h1 := set_netEq P i x y h.1
    have h2 := setSeq_netEq t (P.set i y) h.2
    intro q
    have a := h1 q
    have b := h2 q
    simp only [net, setSeq, deltaTerms] at a b ⊢
    omega

/-- The same as an equation for the derived formula. -/
theorem setSeq_amount (ms : List (Nat × Site × Site)) (P : SProt) (h : Marked P ms) (q : Qty) :
    amount (setSeq P ms).species.formula q = amount P.species.formula q + net (deltaTerms ms) q := by
  have := setSeq_netEq ms P h q
  simp only [net] at this
  omega

/-- Two marks at different internal sites: after the first, the second site is still eligible, and
both orders give the same protein. -/
theorem one_one_commute (P : SProt) (i j : Nat) (a1 a2 : AA) (s1 d1 s2 d2 : Species) (hij : i ≠ j)
    (hi : (Part.one a1 s1 d1).Eligible P i 0) (hj : (Part.one a2 s2 d2).Eligible P j 0) :
    (Part.one a2 s2 d2).Eligible ((Part.one a1 s1 d1).apply P i 0) j 0
      ∧ (Part.one a1 s1 d1).Eligible ((Part.one a2 s2 d2).apply P j 0) i 0
      ∧ (Part.one a2 s2 d2).apply ((Part.one a1 s1 d1).apply P i 0) j 0
          = (Part.one a1 s1 d1).apply ((Part.one a2 s2 d2).apply P j 0) i 0 := by
  refine ⟨?_, ?_, ?_⟩
  · simp only [Part.Eligible, Part.apply, SProt.set] at hi hj ⊢
    rw [List.getElem?_set_ne hij]; exact hj
  · simp only [Part.Eligible, Part.apply, SProt.set] at hi hj ⊢
    rw [List.getElem?_set_ne (fun e => hij e.symm)]; exact hi
  · simp only [Part.apply]
    exact SProt.set_comm P i j _ _ hij

end BioCore.Sites
