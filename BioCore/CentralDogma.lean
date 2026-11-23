import BioCore.Polymer
import BioCore.Sequence
import BioCore.Data.Monomers
import BioCore.Data.GeneticCodes
/-!
# BioCore.CentralDogma

The chemistry of the three templated syntheses, and the theorems that hold for every sequence.
The only chemical inputs are the ChEBI formulas in `Data/Monomers.lean`; the `step_balanced`
fields below are checked by the kernel from those formulas, one case per building block.
-/
namespace BioCore

/-- RNA synthesis: nucleoside triphosphate(4-) → nucleotide residue(1-) in the chain + diphosphate(3-). -/
def rnaChem : PolyChem RNt where
  monomer := fun x => match x with | .A => Chebi.c30616 | .C => Chebi.c37563 | .G => Chebi.c37565 | .U => Chebi.c46398
  residue := fun x => match x with | .A => Chebi.c74411 | .C => Chebi.c82748 | .G => Chebi.c74269 | .U => Chebi.c65315
  leaving := Chebi.c33019
  step_balanced := by intro a; cases a <;> decide

/-- DNA synthesis: deoxynucleoside triphosphate(4-) → residue(1-) + diphosphate(3-). -/
def dnaChem : PolyChem DNt where
  monomer := fun x => match x with | .A => Chebi.c61404 | .C => Chebi.c61481 | .G => Chebi.c61429 | .T => Chebi.c37568
  residue := fun x => match x with | .A => Chebi.c90615 | .C => Chebi.c85452 | .G => Chebi.c85445 | .T => Chebi.c137386
  leaving := Chebi.c33019
  step_balanced := by intro a; cases a <;> decide

/-- Peptide bond formation as a net condensation: amino acid → residue + water.
The cell does this through aminoacyl-tRNA at the cost of ATP and GTP; that route is not modelled here. -/
def peptideChem : PolyChem AA where
  monomer := fun x => match x with | .A => Chebi.c57972 | .R => Chebi.c32682 | .N => Chebi.c58048 | .D => Chebi.c29991 | .C => Chebi.c35235 | .Q => Chebi.c58359 | .E => Chebi.c29985 | .G => Chebi.c57305 | .H => Chebi.c57595 | .I => Chebi.c58045 | .L => Chebi.c57427 | .K => Chebi.c32551 | .M => Chebi.c57844 | .F => Chebi.c58095 | .P => Chebi.c60039 | .S => Chebi.c33384 | .T => Chebi.c57926 | .W => Chebi.c57912 | .Y => Chebi.c58315 | .V => Chebi.c57762 | .U => Chebi.c57843
  residue := fun x => match x with | .A => Chebi.c46217 | .R => Chebi.c29965 | .N => Chebi.c50347 | .D => Chebi.c29961 | .C => Chebi.c29950 | .Q => Chebi.c30011 | .E => Chebi.c29973 | .G => Chebi.c29947 | .H => Chebi.c29979 | .I => Chebi.c30009 | .L => Chebi.c30006 | .K => Chebi.c29969 | .M => Chebi.c16044 | .F => Chebi.c29997 | .P => Chebi.c50342 | .S => Chebi.c29999 | .T => Chebi.c30013 | .W => Chebi.c29954 | .Y => Chebi.c46858 | .V => Chebi.c30015 | .U => Chebi.c30000
  leaving := Chebi.c15377
  step_balanced := by intro a; cases a <;> decide

/-- Making an RNA of sequence `s`: the first nucleotide keeps its triphosphate; every further
nucleotide releases one diphosphate. -/
def transcriptionRxn : List RNt → FSum
  | [] => []
  | a :: t => elongation rnaChem (rnaChem.monomer a) t "RNA"

/-- Copying a DNA strand of sequence `s` from deoxynucleoside triphosphates. -/
def replicationRxn : List DNt → FSum
  | [] => []
  | a :: t => elongation dnaChem (dnaChem.monomer a) t "DNA"

/-- Condensing amino acids into the peptide `p`. -/
def peptideRxn : List AA → FSum
  | [] => []
  | a :: t => elongation peptideChem (peptideChem.monomer a) t "peptide"

/-- **Every RNA, of any sequence and length, is made without creating or destroying an atom or a charge.** -/
theorem transcription_balanced (s : List RNt) : Balanced (transcriptionRxn s) := by
  cases s with
  | nil => intro q; rfl
  | cons a t => exact elongation_balanced rnaChem _ t _

theorem replication_balanced (s : List DNt) : Balanced (replicationRxn s) := by
  cases s with
  | nil => intro q; rfl
  | cons a t => exact elongation_balanced dnaChem _ t _

theorem peptide_balanced (p : List AA) : Balanced (peptideRxn p) := by
  cases p with
  | nil => intro q; rfl
  | cons a t => exact elongation_balanced peptideChem _ t _

/-- From a coding strand to its RNA: balanced for every gene. -/
theorem gene_transcription_balanced (d : List DNt) : Balanced (transcriptionRxn (transcribe d)) :=
  transcription_balanced _

/-! ## Facts about the standard genetic code, checked by the kernel -/

theorem standard_stop_codons :
    (allCodons.filter fun c => (standardCode.aa c).isNone) =
      [(.U, .A, .A), (.U, .A, .G), (.U, .G, .A)] := by decide

theorem standard_sense_codon_count :
    (allCodons.filter fun c => (standardCode.aa c).isSome).length = 61 := by decide

theorem standard_start_codons :
    (allCodons.filter fun c => standardCode.start c) =
      [(.U, .U, .G), (.C, .U, .G), (.A, .U, .G)] := by decide

/-- The code is redundant: two different codons, one amino acid. -/
theorem standard_code_not_injective :
    ∃ c d : Codon, c ≠ d ∧ standardCode.aa c = standardCode.aa d :=
  ⟨(.U, .U, .U), (.U, .U, .C), by decide, by decide⟩

/-- In vertebrate mitochondria UGA is tryptophan, not stop. -/
theorem mito_UGA_is_Trp :
    vertMitoCode.aa (.U, .G, .A) = some .W ∧ standardCode.aa (.U, .G, .A) = none := by decide

/-! ## Worked checks -/

/-- AUG GCC UAA decodes to Met-Ala. -/
example : decodeCDS standardCode [.A, .U, .G, .G, .C, .C, .U, .A, .A] = .ok [.M, .A] := by decide

/-- A stop in the middle is rejected, with its position. -/
example : decodeCDS standardCode [.A, .U, .G, .U, .G, .A, .G, .C, .C, .U, .A, .A]
    = .rejected (.internalStop 1) := by decide

/-- The same sequence is accepted under the mitochondrial code, where UGA is Trp and UAA is stop. -/
example : decodeCDS vertMitoCode [.A, .U, .G, .U, .G, .A, .G, .C, .C, .U, .A, .A]
    = .ok [.M, .W, .A] := by decide

/-- A claim that RNA is made without releasing diphosphate is rejected: the kernel proves it false. -/
example : ¬ Balanced [(-1, Chebi.c30616), (-1, Chebi.c46398),
    (1, chain rnaChem Chebi.c30616 [RNt.U] "pApU")] := by decide

end BioCore
