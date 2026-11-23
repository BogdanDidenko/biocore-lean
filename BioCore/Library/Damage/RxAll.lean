import BioCore.Library.Damage.Rx01
import BioCore.Library.Damage.Rx02
import BioCore.Library.Damage.Rx03
/-!
# BioCore.Library.Damage.RxAll

GENERATED. All Rhea records of the damage and repair classes that the kernel proves balanced.
-/
namespace BioCore.Damage.Rx
open BioCore BioCore.Damage

def rxAll : List FSum := list_Rx01 ++ (list_Rx02 ++ (list_Rx03))
theorem rxAll_balanced : ∀ r ∈ rxAll, Balanced r := bal_append list_Rx01_balanced (bal_append list_Rx02_balanced (list_Rx03_balanced))
theorem rxAll_length : rxAll.length = 894 := by decide +kernel

end BioCore.Damage.Rx
