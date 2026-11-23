import BioCore.Sequence
/-!
# BioCore.Library.Genes.Pack

A compact way to write a long sequence: one natural number instead of a list literal.
Definitions to trust when a statement uses them: `baseOfDigit`, `unpackDNA`, `aaOfDigit`, `unpackAA`.
A statement written with `unpackDNA` or `unpackAA` relies on these four definitions in addition to
the kernel's own. Statements written with ordinary list literals do not use this file.
-/
namespace BioCore.Genes

/-- Two bits per base: 0 A, 1 C, 2 G, 3 T. -/
def baseOfDigit : Nat → DNt
  | 0 => .A | 1 => .C | 2 => .G | _ => .T

def unpackDNAAux : Nat → Nat → List DNt → List DNt
  | 0, _, acc => acc
  | len + 1, n, acc => unpackDNAAux len (n / 4) (baseOfDigit (n % 4) :: acc)

/-- The `len` bases written by `n` in base 4; the first base is the most significant digit. -/
def unpackDNA (len n : Nat) : List DNt := unpackDNAAux len n []

/-- Five bits per residue, in the order of the constructors of `AA`: 0 A, 1 R, …, 19 V, 20 U. -/
def aaOfDigit : Nat → AA
  | 0 => .A | 1 => .R | 2 => .N | 3 => .D | 4 => .C | 5 => .Q | 6 => .E | 7 => .G | 8 => .H
  | 9 => .I | 10 => .L | 11 => .K | 12 => .M | 13 => .F | 14 => .P | 15 => .S | 16 => .T
  | 17 => .W | 18 => .Y | 19 => .V | _ => .U

def unpackAAAux : Nat → Nat → List AA → List AA
  | 0, _, acc => acc
  | len + 1, n, acc => unpackAAAux len (n / 32) (aaOfDigit (n % 32) :: acc)

/-- The `len` residues written by `n` in base 32; the first residue is the most significant digit. -/
def unpackAA (len n : Nat) : List AA := unpackAAAux len n []

/-! ## Checks of the decoder (kernel) -/

theorem unpackDNAAux_length (len n : Nat) (acc : List DNt) :
    (unpackDNAAux len n acc).length = len + acc.length := by
  induction len generalizing n acc with
  | zero => simp [unpackDNAAux]
  | succ k ih => simp [unpackDNAAux, ih]; omega

/-- The decoder returns exactly `len` bases. -/
theorem unpackDNA_length (len n : Nat) : (unpackDNA len n).length = len := by
  simp [unpackDNA, unpackDNAAux_length]

theorem unpackAAAux_length (len n : Nat) (acc : List AA) :
    (unpackAAAux len n acc).length = len + acc.length := by
  induction len generalizing n acc with
  | zero => simp [unpackAAAux]
  | succ k ih => simp [unpackAAAux, ih]; omega

/-- The decoder returns exactly `len` residues. -/
theorem unpackAA_length (len n : Nat) : (unpackAA len n).length = len := by
  simp [unpackAA, unpackAAAux_length]

/-- ATGGCCTAA: base-4 digits 0 3 2 2 1 1 3 0 0; the leading A (digit 0) is kept by `len`. -/
example : unpackDNA 9 0xE970 = [.A, .T, .G, .G, .C, .C, .T, .A, .A] := by decide
example : unpackAA 2 (12 * 32 + 0) = [.M, .A] := by decide

end BioCore.Genes
