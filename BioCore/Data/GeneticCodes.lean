import BioCore.Sequence
/-!
# BioCore.Data.GeneticCodes

GENERATED FILE from NCBI `gc.prt` version 4.6 (ftp.ncbi.nlm.nih.gov/entrez/misc/data/gc.prt).
Codon order is the NCBI order: first base T,C,A,G; then second base; then third base.
`none` is a stop codon. The `…_is_ncbi` theorems check each row against the NCBI letters.
-/
namespace BioCore

/-- NCBI translation table 1: Standard. -/
def standardRow : List (Option AA) := [some .F, some .F, some .L, some .L, some .S, some .S, some .S, some .S, some .Y, some .Y, none, none, some .C, some .C, none, some .W, some .L, some .L, some .L, some .L, some .P, some .P, some .P, some .P, some .H, some .H, some .Q, some .Q, some .R, some .R, some .R, some .R, some .I, some .I, some .I, some .M, some .T, some .T, some .T, some .T, some .N, some .N, some .K, some .K, some .S, some .S, some .R, some .R, some .V, some .V, some .V, some .V, some .A, some .A, some .A, some .A, some .D, some .D, some .E, some .E, some .G, some .G, some .G, some .G]
def standardStarts : List Bool := [false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
def standardCode : GeneticCode := GeneticCode.ofRows standardRow standardStarts
theorem standardRow_length : standardRow.length = 64 := by decide
theorem standardStarts_length : standardStarts.length = 64 := by decide
theorem standardRow_is_ncbi : standardRow.map AA.letter = ['F', 'F', 'L', 'L', 'S', 'S', 'S', 'S', 'Y', 'Y', '*', '*', 'C', 'C', '*', 'W', 'L', 'L', 'L', 'L', 'P', 'P', 'P', 'P', 'H', 'H', 'Q', 'Q', 'R', 'R', 'R', 'R', 'I', 'I', 'I', 'M', 'T', 'T', 'T', 'T', 'N', 'N', 'K', 'K', 'S', 'S', 'R', 'R', 'V', 'V', 'V', 'V', 'A', 'A', 'A', 'A', 'D', 'D', 'E', 'E', 'G', 'G', 'G', 'G'] := by decide

/-- NCBI translation table 2: Vertebrate Mitochondrial. -/
def vertMitoRow : List (Option AA) := [some .F, some .F, some .L, some .L, some .S, some .S, some .S, some .S, some .Y, some .Y, none, none, some .C, some .C, some .W, some .W, some .L, some .L, some .L, some .L, some .P, some .P, some .P, some .P, some .H, some .H, some .Q, some .Q, some .R, some .R, some .R, some .R, some .I, some .I, some .M, some .M, some .T, some .T, some .T, some .T, some .N, some .N, some .K, some .K, some .S, some .S, none, none, some .V, some .V, some .V, some .V, some .A, some .A, some .A, some .A, some .D, some .D, some .E, some .E, some .G, some .G, some .G, some .G]
def vertMitoStarts : List Bool := [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false]
def vertMitoCode : GeneticCode := GeneticCode.ofRows vertMitoRow vertMitoStarts
theorem vertMitoRow_length : vertMitoRow.length = 64 := by decide
theorem vertMitoStarts_length : vertMitoStarts.length = 64 := by decide
theorem vertMitoRow_is_ncbi : vertMitoRow.map AA.letter = ['F', 'F', 'L', 'L', 'S', 'S', 'S', 'S', 'Y', 'Y', '*', '*', 'C', 'C', 'W', 'W', 'L', 'L', 'L', 'L', 'P', 'P', 'P', 'P', 'H', 'H', 'Q', 'Q', 'R', 'R', 'R', 'R', 'I', 'I', 'M', 'M', 'T', 'T', 'T', 'T', 'N', 'N', 'K', 'K', 'S', 'S', '*', '*', 'V', 'V', 'V', 'V', 'A', 'A', 'A', 'A', 'D', 'D', 'E', 'E', 'G', 'G', 'G', 'G'] := by decide

end BioCore
