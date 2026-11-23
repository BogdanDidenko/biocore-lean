import BioCore.Library.Reactions.Balanced
/-!
# BioCore.Library.Reactions.Statements

HAND-WRITTEN. Three general theorems of `BioCore.Core` instantiated on the reaction library.
Every statement here is accepted by the Lean kernel (level K); nothing is computed outside it.
Two finite checks (`glycolysis_net_counts`, `glycolysis_net_amounts`) use `decide +kernel`: the
elaborator's own evaluation of these larger checks stops at its recursion limit, so the evaluation is
left to the kernel alone; the proof term is the same kind and uses no additional axiom.

(a) Glycolysis, alpha-D-glucose to pyruvate, as ten library reactions (Rhea master identifiers), each
    with the number of times and the direction it runs. The steps are the ten enzyme steps of the
    Embden–Meyerhof–Parnas pathway as given in standard biochemistry textbooks; the Rhea reaction of
    each step was taken from `rhea2ec.tsv` (Rhea release 143) by EC number, except step 1, which is
    RHEA:36495 (see `rx_choices_amendment_1.md`). The net conversion is written out, shown to have the
    same number of molecules of every species as the pathway, and proved balanced through
    `pathNet_balanced`.
(b) A `Reach` derivation: from one alpha-D-glucose and two ATP, four reactions fire one after another,
    none using a molecule that is absent.
(c) An impossibility by conservation (`not_reach_of_net_ne`): no sequence of reactions from the whole
    list `balancedLibrary`, however long, turns the starting mixture of glycolysis into one with a
    third pyruvate.
-/
namespace BioCore.Rhea
open BioCore

/-! ## (a) Glycolysis

| step | enzyme (EC) | Rhea | times | Rhea equation (left = right) |
|---|---|---|---|---|
| 1 | hexokinase (2.7.1.1) | RHEA:36495 | +1 | alpha-D-glucose + ATP = alpha-D-glucose 6-phosphate + ADP + H(+) |
| 2 | glucose-6-phosphate isomerase (5.3.1.9) | RHEA:11816 | +1 | alpha-D-glucose 6-phosphate = beta-D-fructose 6-phosphate |
| 3 | 6-phosphofructokinase (2.7.1.11) | RHEA:16109 | +1 | beta-D-fructose 6-phosphate + ATP = beta-D-fructose 1,6-bisphosphate + ADP + H(+) |
| 4 | fructose-bisphosphate aldolase (4.1.2.13) | RHEA:14729 | +1 | beta-D-fructose 1,6-bisphosphate = D-glyceraldehyde 3-phosphate + dihydroxyacetone phosphate |
| 5 | triose-phosphate isomerase (5.3.1.1) | RHEA:18585 | -1 | D-glyceraldehyde 3-phosphate = dihydroxyacetone phosphate |
| 6 | glyceraldehyde-3-phosphate dehydrogenase (1.2.1.12) | RHEA:10300 | +2 | D-glyceraldehyde 3-phosphate + phosphate + NAD(+) = (2R)-3-phospho-glyceroyl phosphate + NADH + H(+) |
| 7 | phosphoglycerate kinase (2.7.2.3) | RHEA:14801 | -2 | (2R)-3-phosphoglycerate + ATP = (2R)-3-phospho-glyceroyl phosphate + ADP |
| 8 | phosphoglycerate mutase (5.4.2.11, 5.4.2.12) | RHEA:15901 | -2 | (2R)-2-phosphoglycerate = (2R)-3-phosphoglycerate |
| 9 | enolase (4.2.1.11) | RHEA:10164 | +2 | (2R)-2-phosphoglycerate = phosphoenolpyruvate + H2O |
| 10 | pyruvate kinase (2.7.1.40) | RHEA:18157 | -2 | pyruvate + ATP = phosphoenolpyruvate + ADP + H(+) |

A negative number of times means the reaction runs from right to left. -/

/-- Glycolysis: each library reaction with the number of times it runs. -/
def glycolysis : List (Int × FSum) :=
  [(1, rhea_36495), (1, rhea_11816), (1, rhea_16109), (1, rhea_14729), (-1, rhea_18585),
   (2, rhea_10300), (-2, rhea_14801), (-2, rhea_15901), (2, rhea_10164), (-2, rhea_18157)]

/-- Every step is a library reaction with its own balance theorem. -/
theorem glycolysis_steps_balanced : ∀ x ∈ glycolysis, Balanced x.2 := by
  intro x hx
  simp only [glycolysis, List.mem_cons, List.not_mem_nil, or_false] at hx
  rcases hx with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  · exact rhea_36495_balanced
  · exact rhea_11816_balanced
  · exact rhea_16109_balanced
  · exact rhea_14729_balanced
  · exact rhea_18585_balanced
  · exact rhea_10300_balanced
  · exact rhea_14801_balanced
  · exact rhea_15901_balanced
  · exact rhea_10164_balanced
  · exact rhea_18157_balanced

/-- The pathway as a whole is balanced, by the general theorem `pathNet_balanced`. -/
theorem glycolysis_pathway_balanced : Balanced (pathNet glycolysis) :=
  pathNet_balanced glycolysis_steps_balanced

/-- The net conversion, written out:
alpha-D-glucose + 2 ADP + 2 phosphate + 2 NAD(+) → 2 pyruvate + 2 ATP + 2 NADH + 2 H2O + 2 H(+). -/
def glycolysisNet : FSum :=
  [(-1, c17925), (-2, c456216), (-2, c43474), (-2, c57540),
   (2, c15361), (2, c30616), (2, c57945), (2, c15377), (2, c15378)]

/-- The pathway and the written-out conversion have the same number of molecules of every species:
all intermediates cancel and nothing else is left over. -/
theorem glycolysis_net_counts : ∀ nm, count (pathNet glycolysis) nm = count glycolysisNet nm :=
  count_eq_of_check (by decide +kernel)

/-- The written-out conversion has the same net amount of every quantity as the pathway. -/
theorem glycolysis_net_amounts : ∀ q, net glycolysisNet q = net (pathNet glycolysis) q :=
  net_eq_of_check (by decide +kernel)

/-- **The net conversion of glycolysis is balanced**, derived from the pathway theorem. -/
theorem glycolysisNet_balanced : Balanced glycolysisNet :=
  balanced_of_net_eq glycolysis_net_amounts glycolysis_pathway_balanced

/-! ## (b) A reachability derivation -/

/-- The reactions used below, as a small library (Rhea direction, left to right). -/
def upperGlycolysis : List FSum := [rhea_36495, rhea_11816, rhea_16109, rhea_14729]

/-- One alpha-D-glucose and two ATP. -/
def startState : FSum := [(1, c17925), (2, c30616)]

/-- The state after firing RHEA:36495, RHEA:11816, RHEA:16109 and RHEA:14729, in this order. -/
def afterFourSteps : FSum :=
  (((startState ++ rhea_36495) ++ rhea_11816) ++ rhea_16109) ++ rhea_14729

/-- **Reachability.** Each reaction is a member of the library and can fire in the state it meets
(`Feasible`, decided by the kernel): no molecule is used that is not there. -/
theorem reach_afterFourSteps : Reach upperGlycolysis startState afterFourSteps :=
  Reach.step rhea_36495 (List.Mem.head _) (by decide)
    (Reach.step rhea_11816 (List.Mem.tail _ (List.Mem.head _)) (by decide)
      (Reach.step rhea_16109 (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _))) (by decide)
        (Reach.step rhea_14729
          (List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _)))) (by decide)
          (Reach.refl _))))

/-- What that state contains: one D-glyceraldehyde 3-phosphate, one dihydroxyacetone phosphate,
two ADP and two H(+); glucose, ATP and the intermediates are used up. -/
theorem afterFourSteps_counts : ∀ nm,
    count afterFourSteps nm = count [(1, c59776), (1, c57642), (2, c456216), (2, c15378)] nm :=
  count_eq_of_check (by decide)

/-- A reaction that needs a molecule the state lacks cannot fire: the aldolase step in the start state. -/
theorem aldolase_not_feasible_at_start : ¬ Feasible startState rhea_14729 := by decide

/-! ## (c) An impossibility by conservation -/

/-- The starting mixture of glycolysis: alpha-D-glucose, 2 ADP, 2 phosphate, 2 NAD(+). -/
def glycolysisStart : FSum := [(1, c17925), (2, c456216), (2, c43474), (2, c57540)]

/-- The products of glycolysis with a third pyruvate. -/
def threePyruvate : FSum := [(3, c15361), (2, c30616), (2, c57945), (2, c15377), (2, c15378)]

/-- **Impossibility.** Whatever reactions of `balancedLibrary` fire, in whatever order and however
many times, the mixture with three pyruvate is never reached from the starting mixture: it has a
different number of carbon atoms (quantity 6), and every reaction of the list conserves carbon. -/
theorem threePyruvate_unreachable : ¬ Reach balancedLibrary glycolysisStart threePyruvate :=
  not_reach_of_net_ne (q := 6) balancedLibrary_all (by decide)

/-- The same fact in positive form: every state reachable from the starting mixture through
`balancedLibrary` has exactly its 68 carbon atoms. -/
theorem carbon_from_glycolysisStart (b : FSum) (h : Reach balancedLibrary glycolysisStart b) :
    net b 6 = 68 := by
  rw [reach_conserves balancedLibrary_all h 6]; decide

end BioCore.Rhea
