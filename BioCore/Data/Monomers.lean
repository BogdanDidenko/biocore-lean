import BioCore.Core
/-!
# BioCore.Data.Monomers

GENERATED FILE. Species used by the polymer chemistry, copied from ChEBI release 257
(flat files chemical_data.tsv.gz and compounds.tsv.gz of 2026-11-05; ChEBI data are CC BY 4.0,
http://www.ebi.ac.uk/chebi). Each line is a data axiom: the kernel checks what follows from these
formulas and charges, not that they describe the real molecule.
Pairs are (quantity, amount): quantity 0 is charge, otherwise the atomic number.
-/
namespace BioCore.Chebi

def c15377 : Species := ⟨"CHEBI:15377 water", [(1, 2), (8, 1)]⟩
def c15378 : Species := ⟨"CHEBI:15378 hydron", [(1, 1), (0, 1)]⟩
def c16044 : Species := ⟨"CHEBI:16044 L-methionine residue", [(6, 5), (1, 9), (7, 1), (8, 1), (16, 1)]⟩
def c29947 : Species := ⟨"CHEBI:29947 glycine residue", [(6, 2), (1, 3), (7, 1), (8, 1)]⟩
def c29950 : Species := ⟨"CHEBI:29950 L-cysteine residue", [(6, 3), (1, 5), (7, 1), (8, 1), (16, 1)]⟩
def c29954 : Species := ⟨"CHEBI:29954 L-tryptophan residue", [(6, 11), (1, 10), (7, 2), (8, 1)]⟩
def c29961 : Species := ⟨"CHEBI:29961 L-aspartate residue", [(6, 4), (1, 4), (7, 1), (8, 3), (0, -1)]⟩
def c29965 : Species := ⟨"CHEBI:29965 L-argininium residue", [(6, 6), (1, 13), (7, 4), (8, 1), (0, 1)]⟩
def c29969 : Species := ⟨"CHEBI:29969 L-lysinium residue", [(6, 6), (1, 13), (7, 2), (8, 1), (0, 1)]⟩
def c29973 : Species := ⟨"CHEBI:29973 L-glutamate residue", [(6, 5), (1, 6), (7, 1), (8, 3), (0, -1)]⟩
def c29979 : Species := ⟨"CHEBI:29979 L-histidine residue", [(6, 6), (1, 7), (7, 3), (8, 1)]⟩
def c29985 : Species := ⟨"CHEBI:29985 L-glutamate(1-)", [(6, 5), (1, 8), (7, 1), (8, 4), (0, -1)]⟩
def c29991 : Species := ⟨"CHEBI:29991 L-aspartate(1-)", [(6, 4), (1, 6), (7, 1), (8, 4), (0, -1)]⟩
def c29997 : Species := ⟨"CHEBI:29997 L-phenylalanine residue", [(6, 9), (1, 9), (7, 1), (8, 1)]⟩
def c29999 : Species := ⟨"CHEBI:29999 L-serine residue", [(6, 3), (1, 5), (7, 1), (8, 2)]⟩
def c30000 : Species := ⟨"CHEBI:30000 L-selenocysteine residue", [(6, 3), (1, 5), (7, 1), (8, 1), (34, 1)]⟩
def c30006 : Species := ⟨"CHEBI:30006 L-leucine residue", [(6, 6), (1, 11), (7, 1), (8, 1)]⟩
def c30009 : Species := ⟨"CHEBI:30009 L-isoleucine residue", [(6, 6), (1, 11), (7, 1), (8, 1)]⟩
def c30011 : Species := ⟨"CHEBI:30011 L-glutamine residue", [(6, 5), (1, 8), (7, 2), (8, 2)]⟩
def c30013 : Species := ⟨"CHEBI:30013 L-threonine residue", [(6, 4), (1, 7), (7, 1), (8, 2)]⟩
def c30015 : Species := ⟨"CHEBI:30015 L-valine residue", [(6, 5), (1, 9), (7, 1), (8, 1)]⟩
def c30616 : Species := ⟨"CHEBI:30616 ATP(4-)", [(6, 10), (1, 12), (7, 5), (8, 13), (15, 3), (0, -4)]⟩
def c32551 : Species := ⟨"CHEBI:32551 L-lysinium(1+)", [(6, 6), (1, 15), (7, 2), (8, 2), (0, 1)]⟩
def c32682 : Species := ⟨"CHEBI:32682 L-argininium(1+)", [(6, 6), (1, 15), (7, 4), (8, 2), (0, 1)]⟩
def c33019 : Species := ⟨"CHEBI:33019 diphosphate(3-)", [(1, 1), (8, 7), (15, 2), (0, -3)]⟩
def c33384 : Species := ⟨"CHEBI:33384 L-serine zwitterion", [(6, 3), (1, 7), (7, 1), (8, 3)]⟩
def c35235 : Species := ⟨"CHEBI:35235 L-cysteine zwitterion", [(6, 3), (1, 7), (7, 1), (8, 2), (16, 1)]⟩
def c37563 : Species := ⟨"CHEBI:37563 CTP(4-)", [(6, 9), (1, 12), (7, 3), (8, 14), (15, 3), (0, -4)]⟩
def c37565 : Species := ⟨"CHEBI:37565 GTP(4-)", [(6, 10), (1, 12), (7, 5), (8, 14), (15, 3), (0, -4)]⟩
def c37568 : Species := ⟨"CHEBI:37568 dTTP(4-)", [(6, 10), (1, 13), (7, 2), (8, 14), (15, 3), (0, -4)]⟩
def c46217 : Species := ⟨"CHEBI:46217 L-alanine residue", [(6, 3), (1, 5), (7, 1), (8, 1)]⟩
def c46398 : Species := ⟨"CHEBI:46398 UTP(4-)", [(6, 9), (1, 11), (7, 2), (8, 15), (15, 3), (0, -4)]⟩
def c46858 : Species := ⟨"CHEBI:46858 L-tyrosine residue", [(6, 9), (1, 9), (7, 1), (8, 2)]⟩
def c50342 : Species := ⟨"CHEBI:50342 L-proline residue", [(6, 5), (1, 7), (7, 1), (8, 1)]⟩
def c50347 : Species := ⟨"CHEBI:50347 L-asparagine residue", [(6, 4), (1, 6), (7, 2), (8, 2)]⟩
def c57305 : Species := ⟨"CHEBI:57305 glycine zwitterion", [(6, 2), (1, 5), (7, 1), (8, 2)]⟩
def c57427 : Species := ⟨"CHEBI:57427 L-leucine zwitterion", [(6, 6), (1, 13), (7, 1), (8, 2)]⟩
def c57595 : Species := ⟨"CHEBI:57595 L-histidine zwitterion", [(6, 6), (1, 9), (7, 3), (8, 2)]⟩
def c57762 : Species := ⟨"CHEBI:57762 L-valine zwitterion", [(6, 5), (1, 11), (7, 1), (8, 2)]⟩
def c57843 : Species := ⟨"CHEBI:57843 L-selenocysteine zwitterion", [(6, 3), (1, 7), (7, 1), (8, 2), (34, 1)]⟩
def c57844 : Species := ⟨"CHEBI:57844 L-methionine zwitterion", [(6, 5), (1, 11), (7, 1), (8, 2), (16, 1)]⟩
def c57912 : Species := ⟨"CHEBI:57912 L-tryptophan zwitterion", [(6, 11), (1, 12), (7, 2), (8, 2)]⟩
def c57926 : Species := ⟨"CHEBI:57926 L-threonine zwitterion", [(6, 4), (1, 9), (7, 1), (8, 3)]⟩
def c57972 : Species := ⟨"CHEBI:57972 L-alanine zwitterion", [(6, 3), (1, 7), (7, 1), (8, 2)]⟩
def c58045 : Species := ⟨"CHEBI:58045 L-isoleucine zwitterion", [(6, 6), (1, 13), (7, 1), (8, 2)]⟩
def c58048 : Species := ⟨"CHEBI:58048 L-asparagine zwitterion", [(6, 4), (1, 8), (7, 2), (8, 3)]⟩
def c58095 : Species := ⟨"CHEBI:58095 L-phenylalanine zwitterion", [(6, 9), (1, 11), (7, 1), (8, 2)]⟩
def c58315 : Species := ⟨"CHEBI:58315 L-tyrosine zwitterion", [(6, 9), (1, 11), (7, 1), (8, 3)]⟩
def c58359 : Species := ⟨"CHEBI:58359 L-glutamine zwitterion", [(6, 5), (1, 10), (7, 2), (8, 3)]⟩
def c60039 : Species := ⟨"CHEBI:60039 L-proline zwitterion", [(6, 5), (1, 9), (7, 1), (8, 2)]⟩
def c61404 : Species := ⟨"CHEBI:61404 dATP(4-)", [(6, 10), (1, 12), (7, 5), (8, 12), (15, 3), (0, -4)]⟩
def c61429 : Species := ⟨"CHEBI:61429 dGTP(4-)", [(6, 10), (1, 12), (7, 5), (8, 13), (15, 3), (0, -4)]⟩
def c61481 : Species := ⟨"CHEBI:61481 dCTP(4-)", [(6, 9), (1, 12), (7, 3), (8, 13), (15, 3), (0, -4)]⟩
def c65315 : Species := ⟨"CHEBI:65315 uridine 5'-monophosphate(1-) residue", [(6, 9), (1, 10), (7, 2), (8, 8), (15, 1), (0, -1)]⟩
def c74269 : Species := ⟨"CHEBI:74269 guanosine 5'-monophosphate(1-) residue", [(6, 10), (1, 11), (7, 5), (8, 7), (15, 1), (0, -1)]⟩
def c74411 : Species := ⟨"CHEBI:74411 adenosine 5'-monophosphate(1-) residue", [(6, 10), (1, 11), (7, 5), (8, 6), (15, 1), (0, -1)]⟩
def c82748 : Species := ⟨"CHEBI:82748 cytidine 5'-monophosphate(1-) residue", [(6, 9), (1, 11), (7, 3), (8, 7), (15, 1), (0, -1)]⟩
def c85445 : Species := ⟨"CHEBI:85445 2'-deoxyguanosine 5'-monophosphate(1-) residue", [(6, 10), (1, 11), (7, 5), (8, 6), (15, 1), (0, -1)]⟩
def c85452 : Species := ⟨"CHEBI:85452 2'-deoxycytidine 5'-monophosphate(1-) residue", [(6, 9), (1, 11), (7, 3), (8, 6), (15, 1), (0, -1)]⟩
def c90615 : Species := ⟨"CHEBI:90615 2'-deoxyadenosine 5'-monophosphate(1-) residue", [(6, 10), (1, 11), (7, 5), (8, 5), (15, 1), (0, -1)]⟩
def c137386 : Species := ⟨"CHEBI:137386 thymidine 5'-monophosphate(1-) residue", [(6, 10), (1, 12), (7, 2), (8, 7), (15, 1), (0, -1)]⟩

end BioCore.Chebi
