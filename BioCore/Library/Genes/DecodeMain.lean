import BioCore
/-!
# BioCore.Library.Genes.DecodeMain  (level X: a compiled program, computed and not proved)

Reads one record per line: identifier, code (`std` or `mito`), strand (`+` or `-`), coding-strand
letters. Applies the kernel's `revComp` (strand `-`), `transcribe` and `decodeCDS` with the kernel's
`standardCode` or `vertMitoCode`, and writes the verdict. It has no decoding logic of its own.
Output columns: identifier, number of bases read, verdict (`ok`, `rejected`, `ERROR`), reason,
position, protein letters (from the kernel's `AA.letter`).
-/
open BioCore

namespace BioCore.Genes

def dntOfChar? : Char → Option DNt
  | 'A' => some .A | 'C' => some .C | 'G' => some .G | 'T' => some .T
  | 'a' => some .A | 'c' => some .C | 'g' => some .G | 't' => some .T
  | _ => none

def parseDNA (s : String) : Option (List DNt) := s.toList.mapM dntOfChar?

def rejectText : Reject → String × String
  | .notWholeCodons => ("notWholeCodons", "")
  | .empty => ("empty", "")
  | .badStart => ("badStart", "")
  | .internalStop i => ("internalStop", toString i)
  | .noStop => ("noStop", "")

def proteinText (p : List AA) : String := String.ofList (p.map fun a => AA.letter (some a))

def codeOf? : String → Option GeneticCode
  | "std" => some standardCode
  | "mito" => some vertMitoCode
  | _ => none

def verdictLine (id code strand dna : String) : String :=
  match codeOf? code, parseDNA dna with
  | none, _ => s!"{id}\t\tERROR\tunknown code\t\t"
  | _, none => s!"{id}\t\tERROR\tletter outside ACGT\t\t"
  | some g, some d =>
    if strand ≠ "+" ∧ strand ≠ "-" then s!"{id}\t{d.length}\tERROR\tunknown strand\t\t" else
    let d := if strand = "-" then revComp d else d
    match decodeCDS g (transcribe d) with
    | .ok p => s!"{id}\t{d.length}\tok\t\t\t{proteinText p}"
    | .rejected w =>
      let (r, pos) := rejectText w
      s!"{id}\t{d.length}\trejected\t{r}\t{pos}\t"

end BioCore.Genes

def main (args : List String) : IO UInt32 := do
  match args with
  | [inp, out] =>
    let text ← IO.FS.readFile inp
    let h ← IO.FS.Handle.mk out .write
    let mut n := 0
    for line in text.splitOn "\n" do
      if line.isEmpty then continue
      n := n + 1
      match line.splitOn "\t" with
      | [id, code, strand, dna] => h.putStrLn (BioCore.Genes.verdictLine id code strand dna)
      | _ => h.putStrLn s!"MALFORMED_LINE_{n}\t\tERROR\tmalformed line\t\t"
    h.flush
    IO.println s!"records read: {n}"
    return 0
  | _ =>
    IO.eprintln "usage: gn_decode <input.tsv> <output.tsv>"
    return 1
