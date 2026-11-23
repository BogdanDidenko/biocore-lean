/-!
# BioCore.Sequence

Sequences and the reading of a coding sequence. Definitions to trust: `transcribe`, `readCodons`,
`GeneticCode`, `decodeCDS`. A coding sequence is either decoded to exactly one protein or rejected
with a stated reason; there is no score.
-/
namespace BioCore

inductive DNt where | A | C | G | T
  deriving DecidableEq, Repr
inductive RNt where | A | C | G | U
  deriving DecidableEq, Repr
/-- The 20 standard amino acids and selenocysteine (`U`). -/
inductive AA where
  | A | R | N | D | C | Q | E | G | H | I | L | K | M | F | P | S | T | W | Y | V | U
  deriving DecidableEq, Repr

/-- One-letter code; `none` (a stop) is written `*`. -/
def AA.letter : Option AA → Char
  | none => '*'
  | some .A => 'A' | some .R => 'R' | some .N => 'N' | some .D => 'D' | some .C => 'C'
  | some .Q => 'Q' | some .E => 'E' | some .G => 'G' | some .H => 'H' | some .I => 'I'
  | some .L => 'L' | some .K => 'K' | some .M => 'M' | some .F => 'F' | some .P => 'P'
  | some .S => 'S' | some .T => 'T' | some .W => 'W' | some .Y => 'Y' | some .V => 'V'
  | some .U => 'U'

/-- Transcription of the coding strand: the same letters, with U for T. -/
def transcribeBase : DNt → RNt
  | .A => .A | .C => .C | .G => .G | .T => .U
def transcribe (d : List DNt) : List RNt := d.map transcribeBase

/-- Watson-Crick partner. -/
def complement : DNt → DNt
  | .A => .T | .T => .A | .C => .G | .G => .C
/-- The other strand, read 5' to 3'. -/
def revComp (d : List DNt) : List DNt := (d.map complement).reverse

theorem complement_complement (b : DNt) : complement (complement b) = b := by cases b <;> rfl

theorem revComp_revComp (d : List DNt) : revComp (revComp d) = d := by
  simp [revComp, List.map_reverse, Function.comp_def, complement_complement]

theorem transcribeBase_injective {a b : DNt} (h : transcribeBase a = transcribeBase b) : a = b := by
  cases a <;> cases b <;> first | rfl | cases h

/-- Transcription loses nothing: different coding strands give different RNAs. -/
theorem transcribe_injective {d e : List DNt} (h : transcribe d = transcribe e) : d = e := by
  induction d generalizing e with
  | nil => cases e with
    | nil => rfl
    | cons _ _ => simp [transcribe] at h
  | cons a t ih => cases e with
    | nil => simp [transcribe] at h
    | cons b u =>
      simp only [transcribe, List.map_cons, List.cons.injEq] at h
      rw [transcribeBase_injective h.1, ih h.2]

abbrev Codon := RNt × RNt × RNt

/-- Split into codons; `none` when the length is not a multiple of three. -/
def readCodons : List RNt → Option (List Codon)
  | [] => some []
  | a :: b :: c :: t => (readCodons t).map (fun l => (a, b, c) :: l)
  | _ => none

/-- A genetic code: what each codon means (`none` = stop) and which codons can start a protein. -/
structure GeneticCode where
  aa : Codon → Option AA
  start : Codon → Bool

/-- Position of a base in the NCBI ordering T, C, A, G. -/
def RNt.ncbiIndex : RNt → Nat
  | .U => 0 | .C => 1 | .A => 2 | .G => 3
def Codon.ncbiIndex (c : Codon) : Nat := 16 * c.1.ncbiIndex + 4 * c.2.1.ncbiIndex + c.2.2.ncbiIndex

/-- Build a code from the two 64-entry rows of an NCBI translation table. -/
def GeneticCode.ofRows (row : List (Option AA)) (starts : List Bool) : GeneticCode where
  aa := fun c => row.getD c.ncbiIndex none
  start := fun c => starts.getD c.ncbiIndex false

/-- Why a coding sequence is not accepted. -/
inductive Reject where
  | notWholeCodons
  | empty
  | badStart
  | internalStop (codon : Nat)
  | noStop
  deriving DecidableEq, Repr

inductive Decoded where
  | ok (protein : List AA)
  | rejected (why : Reject)
  deriving DecidableEq, Repr

/-- Read the codons after the first one: amino acids up to a stop, which must be the last codon. -/
def translateBody (g : GeneticCode) : List Codon → Nat → Decoded
  | [], _ => .rejected .noStop
  | c :: t, i =>
    match g.aa c, t with
    | none, [] => .ok []
    | none, _ :: _ => .rejected (.internalStop i)
    | some _, [] => .rejected .noStop
    | some a, _ :: _ =>
      match translateBody g t (i + 1) with
      | .ok p => .ok (a :: p)
      | r => r

/-- Decode a coding sequence under a genetic code.
Accepted only if: whole codons; the first codon is a start codon (read as Met); the last codon is a
stop; no stop before it. The result is then the one protein the sequence spells. -/
def decodeCDS (g : GeneticCode) (r : List RNt) : Decoded :=
  match readCodons r with
  | none => .rejected .notWholeCodons
  | some [] => .rejected .empty
  | some (c :: t) =>
    if g.start c then
      match translateBody g t 1 with
      | .ok p => .ok (AA.M :: p)
      | r => r
    else .rejected .badStart

/-- All 64 codons in NCBI order. -/
def allCodons : List Codon :=
  let b := [RNt.U, RNt.C, RNt.A, RNt.G]
  b.flatMap fun x => b.flatMap fun y => b.map fun z => (x, y, z)

end BioCore
