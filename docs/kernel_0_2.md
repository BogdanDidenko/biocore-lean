# Kernel 0.2

Kernel 0.2 is kernel 0.1 plus one file, `BioCore/Firing.lean` (219 lines). No file of kernel 0.1 is edited: their hashes in `KERNEL_SHA256.txt` are unchanged, and `KERNEL_0_2_SHA256.txt` lists the same ten files plus the new one. Every theorem and library built on 0.1 stays valid without a rebuild. `import BioCore` gives kernel 0.1; `import BioCore.Firing` adds 0.2.

## Why

Two limits of kernel 0.1 were proved as theorems during the event-class analysis:

- `Feasible` looks at the net change of each species, so a species written on both sides of a reaction (an enzyme, a template, a seed) need not be present for the reaction to fire.
- `Reach` compares states as lists, so a state with the right molecules written in another order is not reached.

## What is added

| Definition or theorem | Meaning |
|---|---|
| `consumed`, `FeasibleS` | strict firing rule: every molecule on the left side of the reaction is in the state |
| `ReachS` | reachability under the strict rule |
| `reach_of_reachS` | `ReachS` is contained in the `Reach` of kernel 0.1, so the old conservation theorems apply |
| `reachS_conserves`, `not_reachS_of_net_ne` | conservation and impossibility for `ReachS` |
| `SameCounts`, `SameAmounts`, `StateEq` | two states hold the same molecules by name, and the same atoms and charge; each is decidable through a finite check proved correct |
| `reachS_congr` | a derivation can be replayed from any equal state and ends in an equal state |
| `ReachSC` | strict reachability up to equality of states; `reachSC_trans`, `reachSC_conserves`, `not_reachSC_of_net_ne` |
| small additions | decidable equality of `Species`, decidability of `Feasible` and `FeasibleS`, `count_append`, `reach_trans`, `reachS_trans` |

Definitions a reader has to trust in addition to kernel 0.1: `consumed`, `FeasibleS`, `ReachS`, `SameCounts`, `SameAmounts`, `StateEq`, `ReachSC`.

## Check on real molecules

`BioCore/FiringCheck.lean` uses a kinase and a phosphatase acting on one serine residue (RHEA:17989, RHEA:20629, ChEBI release 257 formulas). The two enzymes are written on both sides with their composition left out; that they catalyse the reactions is an assumption written into the reactions.

- Under the 0.1 rule the kinase reaction fires with no kinase present; under `FeasibleS` it does not.
- With no enzyme in the state, the only reachable state is the starting one.
- The mark cannot be removed without the phosphatase.
- One turn of the cycle returns the residue and both enzymes (`ReachSC`), and a second turn is impossible because the ATP is spent.
- False variants are refused: a wrong end state (different atoms), and a state with the same atoms but without the enzymes.

`BioCore/FiringMustFail.lean` states three false variants as true and must not compile.

Audit: 65 declarations of the two files depend only on `propext`, `Classical.choice` and `Quot.sound`, or on nothing. No `sorry`, no `native_decide`.

## What is not in kernel 0.2

Site states, complexes, compartments and indexed species remain library definitions. Time, rates and amounts remain outside. `Feasible` and `Reach` of kernel 0.1 are kept as they are.

Build: `lake build +BioCore.FiringCheck` (seconds).
