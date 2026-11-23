import BioCore.Library.Sites.Base
import BioCore.Library.Sites.Data
/-!
# BioCore.Library.Sites.SiteProtein

HAND-WRITTEN. Ported from the prototype `BioCore/Library/Events/Identity/SiteProtein.lean` onto kernel 0.2 (namespace changed, nothing else). A protein as a **sequence plus site states with a derived formula**.

A `Site` is a position of the chain: its amino acid (genetic identity) and the residue species that
occupies it now (the unmodified ChEBI residue of the kernel's `peptideChem`, or a modified residue).
The formula of the protein is DERIVED: the residues in order, plus one water for the two chain ends.
`protFormula_plain_kernel` shows that for an unmodified chain this is the formula of the kernel's
own `chain peptideChem`.

General theorems (each for every sequence, of any length):

* `site_rxn_iff`, `site_mod_balanced`: a reaction that changes the state of ONE site, with any
  co-substrates, is balanced on the whole protein exactly when it is balanced on the residue. One
  residue-level lemma (`ResRxn.bal`, a `decide`) therefore gives a modification class for every
  eligible site of every protein.
* `transfer_iff`: the same for a group passed between sites of two proteins; `two_sites_iff`: two
  sites of one protein.
* `cleavage_balanced` (any chain, any cut position), `cleavage_needs_water`.
* `hydrolysis_balanced` (complete hydrolysis of any sequence).
* `conjugation_balanced`, `deconjugation_balanced`, `e1_balanced`, `e2_balanced`, `e3_balanced`:
  a modifier protein (ubiquitin, SUMO, NEDD8: any sequence) attached through its C-terminal
  carboxylate to a lysine of any protein; the formula of the modified lysine is derived from the
  modifier's sequence.
* `chain_step_iff`, `amount_chain_append`, `splicing_balanced`, `splicing_step1/2`, `tail_balanced`:
  the same pattern for the kernel's nucleic-acid chains.
-/
namespace BioCore.Sites
open BioCore

/-- A position of a chain: its amino acid and the residue species occupying it now. -/
structure Site where
  aa : AA
  res : Species
  deriving DecidableEq

/-- An unmodified position: the kernel's residue for that amino acid. -/
def Site.plain (a : AA) : Site := ⟨a, peptideChem.residue a⟩
/-- An unmodified chain. -/
def plain (s : List AA) : List Site := s.map Site.plain

/-- Sum of the residues (no chain ends). -/
def resSum (s : List Site) : Formula := flat (s.map (·.res.formula))
/-- Water, the kernel's ChEBI:15377. -/
abbrev water : Species := Chebi.c15377
/-- **Derived formula of a protein**: its residues in their current states, plus one water (H on the
N-terminus, OH on the C-terminus). -/
def protFormula (s : List Site) : Formula := resSum s ++ water.formula

/-- Marks for the derived name: position (from 1) and residue name of every modified site. -/
def marks : Nat → List Site → String
  | _, [] => ""
  | i, x :: t =>
    (if x.res.name = (peptideChem.residue x.aa).name then "" else "[" ++ natStr i ++ ":" ++ x.res.name ++ "]")
      ++ marks (i + 1) t

/-- A protein with site states. `base` is the accession and name of the chain. -/
structure SProt where
  base : String
  sites : List Site

def SProt.name (P : SProt) : String := P.base ++ marks 1 P.sites
/-- The kernel species of a site-state protein: derived name, derived formula. -/
def SProt.species (P : SProt) : Species := ⟨P.name, protFormula P.sites⟩
/-- Put site `i` (counted from 0) into state `y`. -/
def SProt.set (P : SProt) (i : Nat) (y : Site) : SProt := ⟨P.base, P.sites.set i y⟩
/-- The unmodified protein of a sequence. -/
def protein (base : String) (s : List AA) : SProt := ⟨base, plain s⟩

/-! ## The derived formula agrees with the kernel's chain -/

theorem amount_chainFormula {α : Type} (P : PolyChem α) (init : Formula) (t : List α) (q : Qty) :
    amount (chainFormula P init t) q = amount (flat (t.map fun a => (P.residue a).formula)) q + amount init q := by
  induction t with
  | nil => simp [chainFormula, flat, amount]
  | cons a t ih => simp only [chainFormula, List.map_cons, flat, amount_append, ih]; omega

/-- For an unmodified chain the derived formula has the amounts of the kernel's
`chain peptideChem (monomer a) t` (first amino acid free, the others as residues). -/
theorem protFormula_plain_kernel (a : AA) (t : List AA) (nm : String) (q : Qty) :
    amount (protFormula (plain (a :: t))) q
      = amount (chain peptideChem (peptideChem.monomer a) t nm).formula q := by
  have hb := peptideChem.step_balanced a q
  simp only [net] at hb
  have e : (plain t).map (·.res.formula) = t.map fun a => (peptideChem.residue a).formula := by
    simp [plain, Site.plain, List.map_map, Function.comp_def]
  simp only [chain, amount_chainFormula, protFormula, resSum, plain, List.map_cons, flat, amount_append,
    Site.plain]
  have e' : List.map (fun x => x.res.formula) (List.map Site.plain t)
      = List.map (fun a => (peptideChem.residue a).formula) t := e
  rw [e']
  have hw : peptideChem.leaving = water := rfl
  rw [hw] at hb
  omega

/-! ## One site -/

theorem amount_prot_set (s : List Site) (i : Nat) (x y : Site) (h : s[i]? = some x) (q : Qty) :
    amount (protFormula (s.set i y)) q
      = amount (protFormula s) q - amount x.res.formula q + amount y.res.formula q := by
  have h' : (s.map (·.res.formula))[i]? = some x.res.formula := by simp [List.getElem?_map, h]
  have := amount_flat_set (s.map (·.res.formula)) i _ y.res.formula h' q
  simp only [protFormula, resSum, amount_append, List.map_set]
  omega

/-- **One site, any sequence.** Changing site `i` from state `x` to state `y`, with any co-substrates
`co`, is balanced on the protein exactly when it is balanced on the residue. -/
theorem site_rxn_iff (P : SProt) (i : Nat) (x y : Site) (h : P.sites[i]? = some x) (co : FSum) :
    Balanced ((-1, P.species) :: (1, (P.set i y).species) :: co)
      ↔ Balanced ((-1, x.res) :: (1, y.res) :: co) := by
  constructor <;> intro hb q <;> have := hb q <;> have k := amount_prot_set P.sites i x y h q <;>
    simp only [net, SProt.species, SProt.set] at this ⊢ <;> omega

/-- A residue-level reaction: the amino acid it applies to, the residue before and after, the
co-substrates and co-products, and the one chemical fact needed (`bal`, checked by the kernel). -/
structure ResRxn where
  name : String
  aa : AA
  src : Species
  dst : Species
  co : FSum
  bal : Balanced ((-1, src) :: (1, dst) :: co)

/-- The reaction `R` applied to site `i` of protein `P`. -/
def ResRxn.at (R : ResRxn) (P : SProt) (i : Nat) : FSum :=
  (-1, P.species) :: (1, (P.set i ⟨R.aa, R.dst⟩).species) :: R.co

/-- **The modification theorem.** For any protein and any eligible site (a site that now holds the
source residue of `R`), the modification with its co-substrates is balanced. -/
theorem site_mod_balanced (R : ResRxn) (P : SProt) (i : Nat) (h : P.sites[i]? = some ⟨R.aa, R.src⟩) :
    Balanced (R.at P i) :=
  (site_rxn_iff P i ⟨R.aa, R.src⟩ ⟨R.aa, R.dst⟩ h R.co).mpr R.bal

/-- **Two sites on two proteins** (a group passed from one protein to another, or a link between two
chains): balanced on the proteins exactly when balanced on the two residues. -/
theorem transfer_iff (P Q : SProt) (i j : Nat) (x y u v : Site)
    (hP : P.sites[i]? = some x) (hQ : Q.sites[j]? = some u) (co : FSum) :
    Balanced ((-1, P.species) :: (1, (P.set i y).species) :: (-1, Q.species) :: (1, (Q.set j v).species) :: co)
      ↔ Balanced ((-1, x.res) :: (1, y.res) :: (-1, u.res) :: (1, v.res) :: co) := by
  constructor <;> intro hb q <;> have := hb q <;> have k1 := amount_prot_set P.sites i x y hP q <;>
    have k2 := amount_prot_set Q.sites j u v hQ q <;>
    simp only [net, SProt.species, SProt.set] at this ⊢ <;> omega

/-- **Two sites on one protein** (for example a disulfide or another link inside one chain): balanced
on the protein exactly when balanced on the two residues. -/
theorem two_sites_iff (P : SProt) (i j : Nat) (x y u v : Site) (hij : i ≠ j)
    (hi : P.sites[i]? = some x) (hj : P.sites[j]? = some u) (co : FSum) :
    Balanced ((-1, P.species) :: (1, ((P.set i y).set j v).species) :: co)
      ↔ Balanced ((-1, x.res) :: (1, y.res) :: (-1, u.res) :: (1, v.res) :: co) := by
  have hj' : (P.sites.set i y)[j]? = some u := by
    rw [List.getElem?_set_ne hij]; exact hj
  constructor <;> intro hb q <;> have := hb q <;> have k1 := amount_prot_set P.sites i x y hi q <;>
    have k2 := amount_prot_set (P.sites.set i y) j u v hj' q <;>
    simp only [net, SProt.species, SProt.set] at this ⊢ <;> omega

/-! ## Cleavage and complete hydrolysis -/

theorem amount_resSum_append (a b : List Site) (q : Qty) :
    amount (resSum (a ++ b)) q = amount (resSum a) q + amount (resSum b) q := by
  simp [resSum, List.map_append, amount_flat_append]

/-- **Cleavage at any position of any chain** (site states included): chain(a ++ b) + H2O = chain(a) + chain(b). -/
theorem cleavage_balanced (n n1 n2 : String) (a b : List Site) :
    Balanced [(-1, (⟨n, a ++ b⟩ : SProt).species), (-1, water), (1, (⟨n1, a⟩ : SProt).species),
      (1, (⟨n2, b⟩ : SProt).species)] := by
  intro q
  simp only [net, SProt.species, protFormula, amount_append, amount_resSum_append]
  omega

/-- Without the water the same statement is false, for every chain and every cut position. -/
theorem cleavage_needs_water (n n1 n2 : String) (a b : List Site) :
    ¬ Balanced [(-1, (⟨n, a ++ b⟩ : SProt).species), (1, (⟨n1, a⟩ : SProt).species),
      (1, (⟨n2, b⟩ : SProt).species)] := by
  intro h
  have := h 8
  simp only [net, SProt.species, protFormula, amount_append, amount_resSum_append] at this
  have hw : amount water.formula 8 = 1 := by decide
  omega

theorem net_monomers (s : List AA) (q : Qty) :
    net (s.map fun a => ((1 : Int), peptideChem.monomer a)) q
      = amount (resSum (plain s)) q + (s.length : Int) * amount water.formula q := by
  induction s with
  | nil => simp [net, resSum, plain, flat, amount]
  | cons a t ih =>
    have hb := peptideChem.step_balanced a q
    have hw : peptideChem.leaving = water := rfl
    rw [hw] at hb
    simp only [net] at hb
    simp only [List.map_cons, net, ih, resSum, plain, flat, amount_append, Site.plain, List.length_cons]
    simp only [resSum, plain] at ih
    grind

/-- **Complete hydrolysis of any sequence**: a protein of `n` residues and `n - 1` waters give its `n`
amino acids (the coefficient of water is written `1 - n`, negative on the left side). -/
theorem hydrolysis_balanced (nm : String) (s : List AA) :
    Balanced ((-1, (protein nm s).species) :: ((1 : Int) - s.length, water)
      :: s.map fun a => ((1 : Int), peptideChem.monomer a)) := by
  intro q
  have h := net_monomers s q
  simp only [net, SProt.species, protein, protFormula, amount_append, h]
  grind

/-- The same on kernel 0.1 alone: the kernel's condensation reaction run backwards. -/
theorem kernel_hydrolysis_balanced (p : List AA) : Balanced (scale (-1) (peptideRxn p)) :=
  balanced_scale (-1) (peptide_balanced p)

/-! ## A modifier protein attached through its C-terminus (ubiquitin and ubiquitin-like modifiers) -/

/-- N6-(modifier)-L-lysine residue: the lysine residue plus the residues of the modifier (the
isopeptide bond takes the modifier's C-terminal OH and one H of the lysine side chain as water, and
the charges of the carboxylate and of the ammonium cancel). Formula DERIVED from the modifier. -/
def isoLys (m : SProt) : Site :=
  ⟨.K, ⟨"N6-(" ++ m.name ++ ")-L-lysine residue", (peptideChem.residue .K).formula ++ resSum m.sites⟩⟩

/-- S-(modifier)-L-cysteine residue (thioester on an E1 or E2 enzyme): the cysteine residue, the
residues of the modifier, and one hydron (the modifier's N-terminal charge is no longer cancelled
by its C-terminal carboxylate). Formula DERIVED from the modifier. -/
def thioCys (m : SProt) : Site :=
  ⟨.C, ⟨"S-(" ++ m.name ++ ")-L-cysteine residue",
    (peptideChem.residue .C).formula ++ resSum m.sites ++ Chebi.c15378.formula⟩⟩

/-- The one chemical fact used: ATP + H2O = AMP + diphosphate + H+ (ChEBI release 257 formulas). -/
theorem atp_amp_ppi : Balanced [(-1, Chebi.c30616), (-1, water), (1, Sp.c456215), (1, Chebi.c33019),
    (1, Chebi.c15378)] := by decide

/-- **Conjugation, net reaction** (C10, C11): modifier + ATP + lysine of a protein = conjugate + AMP +
diphosphate + H+, for any modifier sequence, any target and any lysine of it. -/
theorem conjugation_balanced (m T : SProt) (i : Nat) (h : T.sites[i]? = some (Site.plain .K)) :
    Balanced [(-1, T.species), (1, (T.set i (isoLys m)).species), (-1, m.species), (-1, Chebi.c30616),
      (1, Sp.c456215), (1, Chebi.c33019), (1, Chebi.c15378)] := by
  refine (site_rxn_iff T i _ _ h _).mpr ?_
  intro q
  have := atp_amp_ppi q
  simp only [net, isoLys, Site.plain, SProt.species, protFormula, amount_append] at this ⊢
  omega

/-- **Deconjugation** (C11): conjugate + H2O = protein + modifier. -/
theorem deconjugation_balanced (m T : SProt) (i : Nat) (h : T.sites[i]? = some (isoLys m)) :
    Balanced [(-1, T.species), (1, (T.set i (Site.plain .K)).species), (-1, water), (1, m.species)] := by
  refine (site_rxn_iff T i _ _ h _).mpr ?_
  intro q
  simp only [net, isoLys, Site.plain, SProt.species, protFormula, amount_append]
  omega

/-- **E1 step**: modifier + ATP + E1-Cys = E1-Cys-S-modifier + AMP + diphosphate. -/
theorem e1_balanced (m E1 : SProt) (i : Nat) (h : E1.sites[i]? = some (Site.plain .C)) :
    Balanced [(-1, E1.species), (1, (E1.set i (thioCys m)).species), (-1, m.species), (-1, Chebi.c30616),
      (1, Sp.c456215), (1, Chebi.c33019)] := by
  refine (site_rxn_iff E1 i _ _ h _).mpr ?_
  intro q
  have := atp_amp_ppi q
  simp only [net, thioCys, Site.plain, SProt.species, protFormula, amount_append] at this ⊢
  omega

/-- **E2 step** (transthiolation): E1-S-modifier + E2-Cys = E1-Cys + E2-S-modifier. -/
theorem e2_balanced (m E1 E2 : SProt) (i j : Nat) (h1 : E1.sites[i]? = some (thioCys m))
    (h2 : E2.sites[j]? = some (Site.plain .C)) :
    Balanced [(-1, E1.species), (1, (E1.set i (Site.plain .C)).species), (-1, E2.species),
      (1, (E2.set j (thioCys m)).species)] := by
  refine (transfer_iff E1 E2 i j _ _ _ _ h1 h2 []).mpr ?_
  intro q
  simp only [net, thioCys, Site.plain, amount_append]
  omega

/-- **E3 step**: E2-S-modifier + lysine of the target = E2-Cys + conjugate + H+. -/
theorem e3_balanced (m E2 T : SProt) (j i : Nat) (h2 : E2.sites[j]? = some (thioCys m))
    (h : T.sites[i]? = some (Site.plain .K)) :
    Balanced [(-1, E2.species), (1, (E2.set j (Site.plain .C)).species), (-1, T.species),
      (1, (T.set i (isoLys m)).species), (1, Chebi.c15378)] := by
  refine (transfer_iff E2 T j i _ _ _ _ h2 h [(1, Chebi.c15378)]).mpr ?_
  intro q
  simp only [net, thioCys, isoLys, Site.plain, amount_append]
  omega

/-! ## Nucleic-acid chains of the kernel -/

theorem amount_chain_append {α : Type} (P : PolyChem α) (init : Formula) (x y : List α) (q : Qty) :
    amount (chainFormula P init (x ++ y)) q
      = amount (flat (x.map fun a => (P.residue a).formula)) q + amount (chainFormula P init y) q := by
  induction x with
  | nil => simp [flat, amount]
  | cons a t ih => simp only [List.cons_append, chainFormula, List.map_cons, flat, amount_append, ih]; omega

/-- **One unit of any kernel chain**: removing (or adding) the unit `a` with any co-substrates is
balanced exactly when it is balanced on the residue. -/
theorem chain_step_iff {α : Type} (P : PolyChem α) (init : Species) (a : α) (t : List α)
    (n1 n2 : String) (co : FSum) :
    Balanced ((-1, chain P init (a :: t) n1) :: (1, chain P init t n2) :: co)
      ↔ Balanced ((-1, P.residue a) :: co) := by
  constructor <;> intro hb q <;> have := hb q <;>
    simp only [net, chain, chainFormula, amount_append] at this ⊢ <;> omega

/-- The RNA of a sequence as the kernel makes it: the first nucleotide keeps its 5'-triphosphate. -/
def rna (name : String) (first : RNt) (rest : List RNt) : Species :=
  chain rnaChem (rnaChem.monomer first) rest name
/-- A lariat (or any circular or 2'-5' branched RNA without a free 5' end): the residues only.
Formula DERIVED from the sequence. -/
def lariat (name : String) (s : List RNt) : Species :=
  ⟨name, flat (s.map fun a => (rnaChem.residue a).formula)⟩

/-- **Addition of one nucleotide at the 3' end of any RNA** (C34 tail; RHEA:11332 for `x = A`):
RNA + NTP = RNA-N + diphosphate. -/
theorem tail_balanced (n1 n2 : String) (first : RNt) (rest : List RNt) (x : RNt) :
    Balanced [(-1, rna n1 first rest), (-1, rnaChem.monomer x), (1, rna n2 first (rest ++ [x])),
      (1, rnaChem.leaving)] := by
  intro q
  have hb := rnaChem.step_balanced x q
  have h1 := amount_chain_append rnaChem (rnaChem.monomer first).formula rest [x] q
  have h2 := amount_chainFormula rnaChem (rnaChem.monomer first).formula rest q
  simp only [chainFormula, amount_append] at h1
  simp only [net, rna, chain] at hb ⊢
  omega

/-- **Splicing, first transesterification**: pre-mRNA = 5' exon + lariat intermediate (intron and 3' exon). -/
theorem splicing_step1 (n n1 n2 : String) (first : RNt) (e1 intr e2 : List RNt) :
    Balanced [(-1, rna n first (e1 ++ (intr ++ e2))), (1, rna n1 first e1), (1, lariat n2 (intr ++ e2))] := by
  intro q
  have h1 := amount_chain_append rnaChem (rnaChem.monomer first).formula e1 (intr ++ e2) q
  have h2 := amount_chainFormula rnaChem (rnaChem.monomer first).formula (intr ++ e2) q
  have h3 := amount_chainFormula rnaChem (rnaChem.monomer first).formula e1 q
  simp only [net, rna, chain, lariat]
  omega

/-- **Splicing, second transesterification**: 5' exon + lariat intermediate = mRNA + lariat intron. -/
theorem splicing_step2 (n1 n2 n3 n4 : String) (first : RNt) (e1 intr e2 : List RNt) :
    Balanced [(-1, rna n1 first e1), (-1, lariat n2 (intr ++ e2)), (1, rna n3 first (e1 ++ e2)),
      (1, lariat n4 intr)] := by
  intro q
  have h1 := amount_chain_append rnaChem (rnaChem.monomer first).formula e1 e2 q
  have h2 := amount_chainFormula rnaChem (rnaChem.monomer first).formula e2 q
  have h3 := amount_chainFormula rnaChem (rnaChem.monomer first).formula e1 q
  have h4 := amount_flat_append (intr.map fun a => (rnaChem.residue a).formula)
    (e2.map fun a => (rnaChem.residue a).formula) q
  simp only [net, rna, chain, lariat, List.map_append]
  omega

/-- **Splicing, net**: pre-mRNA(e1, intron, e2) = mRNA(e1, e2) + lariat intron. No atom and no charge
enters or leaves: a rearrangement of a sequence-derived RNA. -/
theorem splicing_balanced (n n3 n4 : String) (first : RNt) (e1 intr e2 : List RNt) :
    Balanced [(-1, rna n first (e1 ++ (intr ++ e2))), (1, rna n3 first (e1 ++ e2)), (1, lariat n4 intr)] := by
  intro q
  have a := splicing_step1 n "" "" first e1 intr e2 q
  have b := splicing_step2 "" "" n3 n4 first e1 intr e2 q
  simp only [net] at a b ⊢
  omega

end BioCore.Sites
