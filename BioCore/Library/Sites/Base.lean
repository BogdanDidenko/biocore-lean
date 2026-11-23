import BioCore.CentralDogma
import BioCore.Firing
/-!
# BioCore.Library.Sites.Base

Library lemmas shared by the site and damage libraries, on kernel 0.2. Ported from the prototype
`BioCore/Library/Events/Identity/Base.lean`; the firing rule, `count_append`, `reach_trans` and
decidable equality of species now come from the kernel module `BioCore.Firing` and are no longer
defined here. Nothing here is an axiom.

* `flat`: concatenation of a list of formulas, with `amount_flat_append` and `amount_flat_set`
  (replacing one item changes every amount by the difference of the two items).
* `natStr`, `joinStr`, `sepStr`: strings for derived names, written so that the kernel can
  evaluate them.
-/
namespace BioCore.Sites
open BioCore

/-- Concatenation of formulas. -/
def flat : List Formula → Formula
  | [] => []
  | f :: t => f ++ flat t

theorem amount_flat_append (a b : List Formula) (q : Qty) :
    amount (flat (a ++ b)) q = amount (flat a) q + amount (flat b) q := by
  induction a with
  | nil => simp [flat, amount]
  | cons h t ih => simp [flat, amount_append, ih, Int.add_assoc]

/-- Replacing item `i` (which was `x`) by `y` changes every amount by `y - x`. -/
theorem amount_flat_set (l : List Formula) (i : Nat) (x y : Formula) (h : l[i]? = some x) (q : Qty) :
    amount (flat (l.set i y)) q = amount (flat l) q - amount x q + amount y q := by
  induction l generalizing i with
  | nil => simp at h
  | cons f t ih =>
    cases i with
    | zero =>
      simp at h; subst h
      simp only [List.set_cons_zero, flat, amount_append]; omega
    | succ j =>
      simp at h
      simp only [List.set_cons_succ, flat, amount_append, ih j h]; omega

/-! ## Strings for derived names (own definitions, so that the kernel can evaluate them) -/

def digit : Nat → String
  | 0 => "0" | 1 => "1" | 2 => "2" | 3 => "3" | 4 => "4" | 5 => "5" | 6 => "6" | 7 => "7" | 8 => "8" | _ => "9"
def natStrAux : Nat → Nat → String
  | 0, _ => ""
  | f + 1, n => if n < 10 then digit n else natStrAux f (n / 10) ++ digit (n % 10)
/-- Decimal numeral (own definition, so that the kernel can evaluate it in names). -/
def natStr (n : Nat) : String := natStrAux (n + 1) n

def joinStr : List String → String
  | [] => ""
  | s :: t => s ++ joinStr t
def sepStr (sep : String) : List String → String
  | [] => ""
  | [s] => s
  | s :: t => s ++ sep ++ sepStr sep t

theorem natStr_test : natStr 0 = "0" ∧ natStr 7 = "7" ∧ natStr 42 = "42" ∧ natStr 1058 = "1058" := by decide

end BioCore.Sites
