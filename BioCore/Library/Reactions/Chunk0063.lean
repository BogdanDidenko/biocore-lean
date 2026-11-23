import BioCore.Library.Reactions.Species
import BioCore.Library.Reactions.Basic
/-!
# BioCore.Library.Reactions.Chunk0063

GENERATED FILE (tools/rx_gen.py). Source: Rhea release 143 (reactions, CC BY 4.0, https://www.rhea-db.org) and
ChEBI release 257 (formulas and charges, CC BY 4.0, http://www.ebi.ac.uk/chebi). Each definition is a data
axiom copied from those files; the kernel checks what follows from it, not that it describes the molecule.
Pairs are (quantity, amount): 0 is charge, 1..118 atomic numbers, 1000 the generic group R, 1001 the generic halogen X,
1002 the generic hydrogen acceptor A (rx_choices_amendment_1.md).
A negative coefficient is the left side of the Rhea equation. One theorem per reaction; the statement
was predicted by the generator and is accepted or rejected by the kernel.
-/
namespace BioCore.Rhea
open BioCore

def rhea_89591 : FSum := [(-1, c58659), (1, c747865)]
theorem rhea_89591_balanced : Balanced rhea_89591 := by decide

def balanced_Chunk0063_b00 : List FSum := [rhea_89591]
theorem balanced_Chunk0063_b00_all : ∀ r ∈ balanced_Chunk0063_b00, Balanced r := bal_cons rhea_89591_balanced (bal_nil)
/-- The reactions of this file that are proved balanced. -/
def balanced_Chunk0063 : List FSum := balanced_Chunk0063_b00 ++ ([])
theorem balanced_Chunk0063_all : ∀ r ∈ balanced_Chunk0063, Balanced r := bal_append balanced_Chunk0063_b00_all (bal_nil)

end BioCore.Rhea
