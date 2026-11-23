import BioCore.FiringCheck
/-!
# BioCore.FiringMustFail (kernel 0.2)

This file must NOT compile. Each `example` states a false variant as true; `decide` refuses it.
-/
namespace BioCore.FiringCheck
open BioCore

/-- False: the kinase reaction fires in a state without the kinase. -/
example : FeasibleS noEnzyme phosphorylation := by decide

/-- False: the mark is removed without the phosphatase. -/
example : FeasibleS (kinaseOnly ++ phosphorylation) dephosphorylation := by decide

/-- False: a state without the enzymes is the same state as the one after the cycle. -/
example : StateEq ((withEnzymes ++ phosphorylation) ++ dephosphorylation) afterCycleNoEnzymes := by decide

end BioCore.FiringCheck
