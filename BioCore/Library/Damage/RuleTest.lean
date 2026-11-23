import BioCore.Library.Damage.Basic
/-!
# BioCore.Library.Damage.RuleTest

GENERATED FILE (BioCore/Library/Damage/gen/dg_gen.py, track dg). Each definition is data copied from the
named source; the kernel checks what follows from it, not that it describes the molecule.
Pairs are (quantity, amount): 0 is charge, 1..118 atomic numbers, 1000 the generic group R, 1001 the generic halogen X,
1002 the generic hydrogen acceptor A (rx_choices_amendment_1.md).
Test of the data rules R1 and R2 (dg_choices.md section 3) against every ChEBI release 257 pair `X is substituent group from Y`
in which X is a residue and both entries have a formula. R1: residue = free compound - H2O, same charge. R2 (nucleoside
monophosphate residues): residue = free compound - hydroxide. One theorem per pair: the rule reaction is balanced, or it is not
balanced but becomes balanced with the stated number of hydrons (the two entries are in different protonation states), or it is
not balanced. Species are restated here in their own namespace.
-/
namespace BioCore.Damage.RuleTest
open BioCore

abbrev water : Species := BioCore.Chebi.c15377
abbrev hydron : Species := BioCore.Chebi.c15378
def hydroxide : Species := ⟨"CHEBI:16234 hydroxide", [(1, 1), (8, 1), (0, -1)]⟩  -- ChEBI release 257 flat files

def c9068 : Species := ⟨"CHEBI:9068 Se-methylselenocysteine", [(6, 4), (1, 9), (7, 1), (8, 2), (34, 1)]⟩
def c9093 : Species := ⟨"CHEBI:9093 selenocysteine", [(6, 3), (1, 7), (7, 1), (8, 2), (34, 1)]⟩
def c10696 : Species := ⟨"CHEBI:10696 (3S)-3-hydroxy-L-aspartic acid", [(6, 4), (1, 7), (7, 1), (8, 5)]⟩
def c14321 : Species := ⟨"CHEBI:14321 glutamate(1-)", [(6, 5), (1, 8), (7, 1), (8, 4), (0, -1)]⟩
def c15356 : Species := ⟨"CHEBI:15356 cysteine", [(6, 3), (1, 7), (7, 1), (8, 2), (16, 1)]⟩
def c15428 : Species := ⟨"CHEBI:15428 glycine", [(6, 2), (1, 5), (7, 1), (8, 2)]⟩
def c15570 : Species := ⟨"CHEBI:15570 D-alanine", [(6, 3), (1, 7), (7, 1), (8, 2)]⟩
def c15603 : Species := ⟨"CHEBI:15603 L-leucine", [(6, 6), (1, 13), (7, 1), (8, 2)]⟩
def c15705 : Species := ⟨"CHEBI:15705 L-alpha-amino acid", [(6, 2), (1, 4), (7, 1), (8, 2), (1000, 1)]⟩
def c15729 : Species := ⟨"CHEBI:15729 L-ornithine", [(6, 5), (1, 12), (7, 2), (8, 2)]⟩
def c15768 : Species := ⟨"CHEBI:15768 3,5-diiodo-L-tyrosine", [(6, 9), (1, 9), (53, 2), (7, 1), (8, 3)]⟩
def c15811 : Species := ⟨"CHEBI:15811 O-phospho-L-serine", [(6, 3), (1, 8), (7, 1), (8, 6), (15, 1)]⟩
def c15816 : Species := ⟨"CHEBI:15816 D-arginine", [(6, 6), (1, 14), (7, 4), (8, 2)]⟩
def c15819 : Species := ⟨"CHEBI:15819 N(6)-(dimethylallyl)adenosine 5'-monophosphate", [(6, 15), (1, 22), (7, 5), (8, 7), (15, 1)]⟩
def c15836 : Species := ⟨"CHEBI:15836 4-phospho-L-aspartic acid", [(6, 4), (1, 8), (7, 1), (8, 7), (15, 1)]⟩
def c15918 : Species := ⟨"CHEBI:15918 2'-deoxycytosine 5'-monophosphate", [(6, 9), (1, 14), (7, 3), (8, 7), (15, 1)]⟩
def c15949 : Species := ⟨"CHEBI:15949 diphthamide", [(6, 13), (1, 24), (7, 5), (8, 3), (0, 1)]⟩
def c15966 : Species := ⟨"CHEBI:15966 D-glutamic acid", [(6, 5), (1, 9), (7, 1), (8, 4)]⟩
def c15971 : Species := ⟨"CHEBI:15971 L-histidine", [(6, 6), (1, 9), (7, 3), (8, 2)]⟩
def c15989 : Species := ⟨"CHEBI:15989 L-methionine S-oxide residue", [(6, 5), (1, 9), (7, 1), (8, 2), (16, 1)]⟩
def c16015 : Species := ⟨"CHEBI:16015 L-glutamic acid", [(6, 5), (1, 9), (7, 1), (8, 4)]⟩
def c16027 : Species := ⟨"CHEBI:16027 adenosine 5'-monophosphate", [(6, 10), (1, 14), (7, 5), (8, 7), (15, 1)]⟩
def c16044 : Species := ⟨"CHEBI:16044 L-methionine residue", [(6, 5), (1, 9), (7, 1), (8, 1), (16, 1)]⟩
def c16192 : Species := ⟨"CHEBI:16192 2'-deoxyguanosine 5'-monophosphate", [(6, 10), (1, 14), (7, 5), (8, 7), (15, 1)]⟩
def c16232 : Species := ⟨"CHEBI:16232 N(6)-acyl-L-lysine", [(6, 7), (1, 13), (7, 2), (8, 3), (1000, 1)]⟩
def c16283 : Species := ⟨"CHEBI:16283 L-cystine", [(6, 6), (1, 12), (7, 2), (8, 4), (16, 2)]⟩
def c16296 : Species := ⟨"CHEBI:16296 D-tryptophan", [(6, 11), (1, 12), (7, 2), (8, 2)]⟩
def c16303 : Species := ⟨"CHEBI:16303 3-amino-L-alanine", [(6, 3), (1, 8), (7, 2), (8, 2)]⟩
def c16313 : Species := ⟨"CHEBI:16313 D-proline", [(6, 5), (1, 9), (7, 1), (8, 2)]⟩
def c16335 : Species := ⟨"CHEBI:16335 adenosine", [(6, 10), (1, 13), (7, 5), (8, 4)]⟩
def c16338 : Species := ⟨"CHEBI:16338 4-hydroxy-L-glutamate(2-)", [(6, 5), (1, 7), (7, 1), (8, 5), (0, -2)]⟩
def c16345 : Species := ⟨"CHEBI:16345 3-sulfino-L-alanine", [(6, 3), (1, 7), (7, 1), (8, 4), (16, 1)]⟩
def c16349 : Species := ⟨"CHEBI:16349 L-citrulline", [(6, 6), (1, 13), (7, 3), (8, 3)]⟩
def c16367 : Species := ⟨"CHEBI:16367 N(tele)-methyl-L-histidine residue", [(6, 7), (1, 9), (7, 3), (8, 1)]⟩
def c16375 : Species := ⟨"CHEBI:16375 D-cysteine", [(6, 3), (1, 7), (7, 1), (8, 2), (16, 1)]⟩
def c16398 : Species := ⟨"CHEBI:16398 D-threonine", [(6, 4), (1, 9), (7, 1), (8, 3)]⟩
def c16414 : Species := ⟨"CHEBI:16414 L-valine", [(6, 5), (1, 11), (7, 1), (8, 2)]⟩
def c16449 : Species := ⟨"CHEBI:16449 alanine", [(6, 3), (1, 7), (7, 1), (8, 2)]⟩
def c16467 : Species := ⟨"CHEBI:16467 L-arginine", [(6, 6), (1, 14), (7, 4), (8, 2)]⟩
def c16523 : Species := ⟨"CHEBI:16523 D-serine", [(6, 3), (1, 7), (7, 1), (8, 3)]⟩
def c16533 : Species := ⟨"CHEBI:16533 L-tryptophanamide", [(6, 11), (1, 13), (7, 3), (8, 1)]⟩
def c16633 : Species := ⟨"CHEBI:16633 L-selenocysteine", [(6, 3), (1, 7), (7, 1), (8, 2), (34, 1)]⟩
def c16643 : Species := ⟨"CHEBI:16643 L-methionine", [(6, 5), (1, 11), (7, 1), (8, 2), (16, 1)]⟩
def c16692 : Species := ⟨"CHEBI:16692 diphthamide residue", [(6, 13), (1, 22), (7, 5), (8, 2), (0, 1)]⟩
def c16695 : Species := ⟨"CHEBI:16695 uridine 5'-monophosphate", [(6, 9), (1, 13), (7, 2), (8, 9), (15, 1)]⟩
def c16702 : Species := ⟨"CHEBI:16702 N-sulfo-D-glucosamine", [(6, 6), (1, 13), (7, 1), (8, 8), (16, 1)]⟩
def c16704 : Species := ⟨"CHEBI:16704 uridine", [(6, 9), (1, 12), (7, 2), (8, 6)]⟩
def c16733 : Species := ⟨"CHEBI:16733 D-alpha-amino acid", [(6, 2), (1, 4), (7, 1), (8, 2), (1000, 1)]⟩
def c16750 : Species := ⟨"CHEBI:16750 guanosine", [(6, 10), (1, 13), (7, 5), (8, 5)]⟩
def c16764 : Species := ⟨"CHEBI:16764 2'-deoxy-5-methyl-5'-cytidylic acid", [(6, 10), (1, 16), (7, 3), (8, 7), (15, 1)]⟩
def c16811 : Species := ⟨"CHEBI:16811 methionine", [(6, 5), (1, 11), (7, 1), (8, 2), (16, 1)]⟩
def c16828 : Species := ⟨"CHEBI:16828 L-tryptophan", [(6, 11), (1, 12), (7, 2), (8, 2)]⟩
def c16855 : Species := ⟨"CHEBI:16855 D-lysine", [(6, 6), (1, 14), (7, 2), (8, 2)]⟩
def c16857 : Species := ⟨"CHEBI:16857 L-threonine", [(6, 4), (1, 9), (7, 1), (8, 3)]⟩
def c16867 : Species := ⟨"CHEBI:16867 D-methionine", [(6, 5), (1, 11), (7, 1), (8, 2), (16, 1)]⟩
def c16889 : Species := ⟨"CHEBI:16889 trans-3-hydroxy-L-proline", [(6, 5), (1, 9), (7, 1), (8, 3)]⟩
def c16952 : Species := ⟨"CHEBI:16952 5-hydroxymethyldeoxycytidylic acid", [(6, 10), (1, 16), (7, 3), (8, 8), (15, 1)]⟩
def c16953 : Species := ⟨"CHEBI:16953 N-acetyl-L-aspartate(2-)", [(6, 6), (1, 7), (7, 1), (8, 5), (0, -2)]⟩
def c16977 : Species := ⟨"CHEBI:16977 L-alanine", [(6, 3), (1, 7), (7, 1), (8, 2)]⟩
def c16998 : Species := ⟨"CHEBI:16998 D-phenylalanine", [(6, 9), (1, 11), (7, 1), (8, 2)]⟩
def c17013 : Species := ⟨"CHEBI:17013 dTMP", [(6, 10), (1, 15), (7, 2), (8, 8), (15, 1)]⟩
def c17016 : Species := ⟨"CHEBI:17016 L-methionine S-oxide", [(6, 5), (1, 11), (7, 1), (8, 3), (16, 1)]⟩
def c17053 : Species := ⟨"CHEBI:17053 L-aspartic acid", [(6, 4), (1, 7), (7, 1), (8, 4)]⟩
def c17061 : Species := ⟨"CHEBI:17061 D-glutamine", [(6, 5), (1, 10), (7, 2), (8, 3)]⟩
def c17115 : Species := ⟨"CHEBI:17115 L-serine", [(6, 3), (1, 7), (7, 1), (8, 3)]⟩
def c17123 : Species := ⟨"CHEBI:17123 2-aminoacrylic acid", [(6, 3), (1, 5), (7, 1), (8, 2)]⟩
def c17191 : Species := ⟨"CHEBI:17191 L-isoleucine", [(6, 6), (1, 13), (7, 1), (8, 2)]⟩
def c17196 : Species := ⟨"CHEBI:17196 L-asparagine", [(6, 4), (1, 8), (7, 2), (8, 3)]⟩
def c17202 : Species := ⟨"CHEBI:17202 IMP", [(6, 10), (1, 13), (7, 4), (8, 8), (15, 1)]⟩
def c17203 : Species := ⟨"CHEBI:17203 L-proline", [(6, 5), (1, 9), (7, 1), (8, 2)]⟩
def c17232 : Species := ⟨"CHEBI:17232 L-glutamic 5-semialdehyde", [(6, 5), (1, 9), (7, 1), (8, 3)]⟩
def c17295 : Species := ⟨"CHEBI:17295 L-phenylalanine", [(6, 9), (1, 11), (7, 1), (8, 2)]⟩
def c17311 : Species := ⟨"CHEBI:17311 N(6),N(6),N(6)-trimethyl-L-lysine", [(6, 9), (1, 21), (7, 2), (8, 2), (0, 1)]⟩
def c17345 : Species := ⟨"CHEBI:17345 guanosine 5'-monophosphate", [(6, 10), (1, 14), (7, 5), (8, 8), (15, 1)]⟩
def c17361 : Species := ⟨"CHEBI:17361 cytidine 5'-monophosphate", [(6, 9), (1, 14), (7, 3), (8, 8), (15, 1)]⟩
def c17364 : Species := ⟨"CHEBI:17364 D-aspartic acid", [(6, 4), (1, 7), (7, 1), (8, 4)]⟩
def c17376 : Species := ⟨"CHEBI:17376 cystine", [(6, 6), (1, 12), (7, 2), (8, 4), (16, 2)]⟩
def c17443 : Species := ⟨"CHEBI:17443 L-homocitrulline", [(6, 7), (1, 15), (7, 3), (8, 3)]⟩
def c17561 : Species := ⟨"CHEBI:17561 L-cysteine", [(6, 3), (1, 7), (7, 1), (8, 2), (16, 1)]⟩
def c17562 : Species := ⟨"CHEBI:17562 cytidine", [(6, 9), (1, 13), (7, 3), (8, 5)]⟩
def c17592 : Species := ⟨"CHEBI:17592 N(5)-methyl-L-glutamine", [(6, 6), (1, 12), (7, 2), (8, 3)]⟩
def c17604 : Species := ⟨"CHEBI:17604 N(6)-methyl-L-lysine", [(6, 7), (1, 16), (7, 2), (8, 2)]⟩
def c17622 : Species := ⟨"CHEBI:17622 dUMP", [(6, 9), (1, 13), (7, 2), (8, 8), (15, 1)]⟩
def c17713 : Species := ⟨"CHEBI:17713 2'-deoxyadenosine 5'-monophosphate", [(6, 10), (1, 14), (7, 5), (8, 6), (15, 1)]⟩
def c17752 : Species := ⟨"CHEBI:17752 N(6)-acetyl-L-lysine", [(6, 8), (1, 16), (7, 2), (8, 3)]⟩
def c17786 : Species := ⟨"CHEBI:17786 N-acetyl-L-leucine", [(6, 8), (1, 15), (7, 1), (8, 3)]⟩
def c17822 : Species := ⟨"CHEBI:17822 serine", [(6, 3), (1, 7), (7, 1), (8, 3)]⟩
def c17895 : Species := ⟨"CHEBI:17895 L-tyrosine", [(6, 9), (1, 11), (7, 1), (8, 3)]⟩
def c17917 : Species := ⟨"CHEBI:17917 L-allysine", [(6, 6), (1, 11), (7, 1), (8, 3)]⟩
def c17929 : Species := ⟨"CHEBI:17929 N(omega),N(omega)-dimethyl-L-arginine", [(6, 8), (1, 18), (7, 4), (8, 2)]⟩
def c17981 : Species := ⟨"CHEBI:17981 O-acetyl-L-serine", [(6, 5), (1, 9), (7, 1), (8, 4)]⟩
def c18019 : Species := ⟨"CHEBI:18019 L-lysine", [(6, 6), (1, 14), (7, 2), (8, 2)]⟩
def c18050 : Species := ⟨"CHEBI:18050 L-glutamine", [(6, 5), (1, 10), (7, 2), (8, 3)]⟩
def c18054 : Species := ⟨"CHEBI:18054 diphthine", [(6, 13), (1, 23), (7, 4), (8, 4), (0, 1)]⟩
def c18095 : Species := ⟨"CHEBI:18095 trans-4-hydroxy-L-proline", [(6, 5), (1, 9), (7, 1), (8, 3)]⟩
def c18116 : Species := ⟨"CHEBI:18116 pseudouridine 5'-phosphate", [(6, 9), (1, 13), (7, 2), (8, 9), (15, 1)]⟩
def c18183 : Species := ⟨"CHEBI:18183 5-oxo-L-proline", [(6, 5), (1, 7), (7, 1), (8, 3)]⟩
def c18186 : Species := ⟨"CHEBI:18186 tyrosine", [(6, 9), (1, 11), (7, 1), (8, 3)]⟩
def c18237 : Species := ⟨"CHEBI:18237 glutamic acid", [(6, 5), (1, 9), (7, 1), (8, 4)]⟩
def c18240 : Species := ⟨"CHEBI:18240 4-hydroxy-L-proline", [(6, 5), (1, 9), (7, 1), (8, 3)]⟩
def c18257 : Species := ⟨"CHEBI:18257 ornithine", [(6, 5), (1, 12), (7, 2), (8, 2)]⟩
def c18258 : Species := ⟨"CHEBI:18258 3,3',5-triiodo-L-thyronine", [(6, 15), (1, 12), (53, 3), (7, 1), (8, 4)]⟩
def c18332 : Species := ⟨"CHEBI:18332 L-thyroxine", [(6, 15), (1, 11), (53, 4), (7, 1), (8, 4)]⟩
def c19228 : Species := ⟨"CHEBI:19228 2'-O-methylcytidine", [(6, 10), (1, 15), (7, 3), (8, 5)]⟩
def c19229 : Species := ⟨"CHEBI:19229 2'-O-methylguanosine", [(6, 11), (1, 15), (7, 5), (8, 5)]⟩
def c20056 : Species := ⟨"CHEBI:20056 3-hydroxy-L-proline", [(6, 5), (1, 9), (7, 1), (8, 3)]⟩
def c20252 : Species := ⟨"CHEBI:20252 cysteine tryptophylquinone residue", [(6, 14), (1, 11), (7, 3), (8, 4), (16, 1)]⟩
def c20489 : Species := ⟨"CHEBI:20489 5'-(N(6)-L-lysine)-L-tyrosylquinone residue", [(6, 15), (1, 17), (7, 3), (8, 4)]⟩
def c20899 : Species := ⟨"CHEBI:20899 D-alloisoleucine", [(6, 6), (1, 13), (7, 1), (8, 2)]⟩
def c21309 : Species := ⟨"CHEBI:21309 L-glutamine amide", [(6, 5), (1, 11), (7, 3), (8, 2)]⟩
def c21362 : Species := ⟨"CHEBI:21362 L-methioninamide", [(6, 5), (1, 12), (7, 2), (8, 1), (16, 1)]⟩
def c21363 : Species := ⟨"CHEBI:21363 L-methionine sulfone", [(6, 5), (1, 11), (7, 1), (8, 4), (16, 1)]⟩
def c21555 : Species := ⟨"CHEBI:21555 N-acetyl-L-isoleucine", [(6, 8), (1, 15), (7, 1), (8, 3)]⟩
def c21557 : Species := ⟨"CHEBI:21557 N-acetyl-L-methionine", [(6, 7), (1, 13), (7, 1), (8, 3), (16, 1)]⟩
def c21560 : Species := ⟨"CHEBI:21560 N-acetyl-L-proline", [(6, 7), (1, 11), (7, 1), (8, 3)]⟩
def c21563 : Species := ⟨"CHEBI:21563 N-acetyl-L-tyrosine", [(6, 11), (1, 13), (7, 1), (8, 4)]⟩
def c21565 : Species := ⟨"CHEBI:21565 N-acetyl-L-valine", [(6, 7), (1, 13), (7, 1), (8, 3)]⟩
def c21780 : Species := ⟨"CHEBI:21780 N-palmitoyl-L-cysteine", [(6, 19), (1, 37), (7, 1), (8, 3), (16, 1)]⟩
def c21858 : Species := ⟨"CHEBI:21858 hypusine", [(6, 10), (1, 23), (7, 3), (8, 3)]⟩
def c21884 : Species := ⟨"CHEBI:21884 N(6)-formyl-L-lysine", [(6, 7), (1, 14), (7, 2), (8, 3)]⟩
def c22046 : Species := ⟨"CHEBI:22046 S-geranylgeranyl-L-cysteine", [(6, 23), (1, 39), (7, 1), (8, 2), (16, 1)]⟩
def c22065 : Species := ⟨"CHEBI:22065 S-palmitoyl-L-cysteine", [(6, 19), (1, 37), (7, 1), (8, 3), (16, 1)]⟩
def c22066 : Species := ⟨"CHEBI:22066 S-phospho-L-cysteine", [(6, 3), (1, 8), (7, 1), (8, 5), (15, 1), (16, 1)]⟩
def c22653 : Species := ⟨"CHEBI:22653 asparagine", [(6, 4), (1, 8), (7, 2), (8, 3)]⟩
def c22660 : Species := ⟨"CHEBI:22660 aspartic acid", [(6, 4), (1, 7), (7, 1), (8, 4)]⟩
def c24898 : Species := ⟨"CHEBI:24898 isoleucine", [(6, 6), (1, 13), (7, 1), (8, 2)]⟩
def c25017 : Species := ⟨"CHEBI:25017 leucine", [(6, 6), (1, 13), (7, 1), (8, 2)]⟩
def c25094 : Species := ⟨"CHEBI:25094 lysine", [(6, 6), (1, 14), (7, 2), (8, 2)]⟩
def c25682 : Species := ⟨"CHEBI:25682 N(omega),N'(omega)-dimethyl-L-arginine", [(6, 8), (1, 18), (7, 4), (8, 2)]⟩
def c26271 : Species := ⟨"CHEBI:26271 proline", [(6, 5), (1, 9), (7, 1), (8, 2)]⟩
def c26986 : Species := ⟨"CHEBI:26986 threonine", [(6, 4), (1, 9), (7, 1), (8, 3)]⟩
def c27266 : Species := ⟨"CHEBI:27266 valine", [(6, 5), (1, 11), (7, 1), (8, 2)]⟩
def c27477 : Species := ⟨"CHEBI:27477 D-valine", [(6, 5), (1, 11), (7, 1), (8, 2)]⟩
def c27570 : Species := ⟨"CHEBI:27570 histidine", [(6, 6), (1, 9), (7, 3), (8, 2)]⟩
def c27596 : Species := ⟨"CHEBI:27596 N(pros)-methyl-L-histidine", [(6, 7), (1, 11), (7, 3), (8, 2)]⟩
def c27730 : Species := ⟨"CHEBI:27730 D-isoleucine", [(6, 6), (1, 13), (7, 1), (8, 2)]⟩
def c27812 : Species := ⟨"CHEBI:27812 Se-methyl-L-selenocysteine", [(6, 4), (1, 9), (7, 1), (8, 2), (34, 1)]⟩
def c27847 : Species := ⟨"CHEBI:27847 3-iodo-L-tyrosine", [(6, 9), (1, 10), (53, 1), (7, 1), (8, 3)]⟩
def c27897 : Species := ⟨"CHEBI:27897 tryptophan", [(6, 11), (1, 12), (7, 2), (8, 2)]⟩
def c27931 : Species := ⟨"CHEBI:27931 alpha-maltotriose", [(6, 18), (1, 32), (8, 16)]⟩
def c27947 : Species := ⟨"CHEBI:27947 D-histidine", [(6, 6), (1, 9), (7, 3), (8, 2)]⟩
def c27971 : Species := ⟨"CHEBI:27971 2-aminoisobutyric acid", [(6, 4), (1, 9), (7, 1), (8, 2)]⟩
def c28009 : Species := ⟨"CHEBI:28009 N-acetyl-beta-D-glucosamine", [(6, 8), (1, 15), (7, 1), (8, 6)]⟩
def c28044 : Species := ⟨"CHEBI:28044 phenylalanine", [(6, 9), (1, 11), (7, 1), (8, 2)]⟩
def c28159 : Species := ⟨"CHEBI:28159 D-asparagine", [(6, 4), (1, 8), (7, 2), (8, 3)]⟩
def c28225 : Species := ⟨"CHEBI:28225 D-leucine", [(6, 6), (1, 13), (7, 1), (8, 2)]⟩
def c28300 : Species := ⟨"CHEBI:28300 glutamine", [(6, 5), (1, 10), (7, 2), (8, 3)]⟩
def c28454 : Species := ⟨"CHEBI:28454 3-selenino-L-alanine", [(6, 3), (1, 7), (7, 1), (8, 4), (34, 1)]⟩
def c28479 : Species := ⟨"CHEBI:28479 D-tyrosine", [(6, 9), (1, 11), (7, 1), (8, 3)]⟩
def c28797 : Species := ⟨"CHEBI:28797 D-alpha-aminobutyric acid", [(6, 4), (1, 9), (7, 1), (8, 2)]⟩
def c28839 : Species := ⟨"CHEBI:28839 3-disulfanyl-L-alanine", [(6, 3), (1, 7), (7, 1), (8, 2), (16, 2)]⟩
def c28939 : Species := ⟨"CHEBI:28939 N-acetyl-L-cysteine", [(6, 5), (1, 9), (7, 1), (8, 3), (16, 1)]⟩
def c29016 : Species := ⟨"CHEBI:29016 arginine", [(6, 6), (1, 14), (7, 4), (8, 2)]⟩
def c29947 : Species := ⟨"CHEBI:29947 glycine residue", [(6, 2), (1, 3), (7, 1), (8, 1)]⟩
def c29949 : Species := ⟨"CHEBI:29949 D-alanine residue", [(6, 3), (1, 5), (7, 1), (8, 1)]⟩
def c29950 : Species := ⟨"CHEBI:29950 L-cysteine residue", [(6, 3), (1, 5), (7, 1), (8, 1), (16, 1)]⟩
def c29951 : Species := ⟨"CHEBI:29951 D-cysteine residue", [(6, 3), (1, 5), (7, 1), (8, 1), (16, 1)]⟩
def c29952 : Species := ⟨"CHEBI:29952 L-arginine residue", [(6, 6), (1, 12), (7, 4), (8, 1)]⟩
def c29953 : Species := ⟨"CHEBI:29953 D-arginine residue", [(6, 6), (1, 12), (7, 4), (8, 1)]⟩
def c29954 : Species := ⟨"CHEBI:29954 L-tryptophan residue", [(6, 11), (1, 10), (7, 2), (8, 1)]⟩
def c29955 : Species := ⟨"CHEBI:29955 D-tryptophan residue", [(6, 11), (1, 10), (7, 2), (8, 1)]⟩
def c29958 : Species := ⟨"CHEBI:29958 L-aspartic acid residue", [(6, 4), (1, 5), (7, 1), (8, 3)]⟩
def c29961 : Species := ⟨"CHEBI:29961 L-aspartate residue", [(6, 4), (1, 4), (7, 1), (8, 3), (0, -1)]⟩
def c29962 : Species := ⟨"CHEBI:29962 D-aspartate residue", [(6, 4), (1, 4), (7, 1), (8, 3), (0, -1)]⟩
def c29965 : Species := ⟨"CHEBI:29965 L-argininium residue", [(6, 6), (1, 13), (7, 4), (8, 1), (0, 1)]⟩
def c29966 : Species := ⟨"CHEBI:29966 D-argininium residue", [(6, 6), (1, 13), (7, 4), (8, 1), (0, 1)]⟩
def c29967 : Species := ⟨"CHEBI:29967 L-lysine residue", [(6, 6), (1, 12), (7, 2), (8, 1)]⟩
def c29968 : Species := ⟨"CHEBI:29968 D-lysine residue", [(6, 6), (1, 12), (7, 2), (8, 1)]⟩
def c29969 : Species := ⟨"CHEBI:29969 L-lysinium residue", [(6, 6), (1, 13), (7, 2), (8, 1), (0, 1)]⟩
def c29970 : Species := ⟨"CHEBI:29970 D-lysinium residue", [(6, 6), (1, 13), (7, 2), (8, 1), (0, 1)]⟩
def c29972 : Species := ⟨"CHEBI:29972 L-glutamic acid residue", [(6, 5), (1, 7), (7, 1), (8, 3)]⟩
def c29976 : Species := ⟨"CHEBI:29976 D-tyrosine residue", [(6, 9), (1, 9), (7, 1), (8, 2)]⟩
def c29979 : Species := ⟨"CHEBI:29979 L-histidine residue", [(6, 6), (1, 7), (7, 3), (8, 1)]⟩
def c29980 : Species := ⟨"CHEBI:29980 D-histidine residue", [(6, 6), (1, 7), (7, 3), (8, 1)]⟩
def c29981 : Species := ⟨"CHEBI:29981 D-histidinium residue", [(6, 6), (1, 8), (7, 3), (8, 1), (0, 1)]⟩
def c29982 : Species := ⟨"CHEBI:29982 L-histidinium residue", [(6, 6), (1, 8), (7, 3), (8, 1), (0, 1)]⟩
def c29984 : Species := ⟨"CHEBI:29984 D-methionine residue", [(6, 5), (1, 9), (7, 1), (8, 1), (16, 1)]⟩
def c29990 : Species := ⟨"CHEBI:29990 D-aspartate(1-)", [(6, 4), (1, 6), (7, 1), (8, 4), (0, -1)]⟩
def c29991 : Species := ⟨"CHEBI:29991 L-aspartate(1-)", [(6, 4), (1, 6), (7, 1), (8, 4), (0, -1)]⟩
def c29996 : Species := ⟨"CHEBI:29996 D-phenylalanine residue", [(6, 9), (1, 9), (7, 1), (8, 1)]⟩
def c29997 : Species := ⟨"CHEBI:29997 L-phenylalanine residue", [(6, 9), (1, 9), (7, 1), (8, 1)]⟩
def c29998 : Species := ⟨"CHEBI:29998 D-serine residue", [(6, 3), (1, 5), (7, 1), (8, 2)]⟩
def c29999 : Species := ⟨"CHEBI:29999 L-serine residue", [(6, 3), (1, 5), (7, 1), (8, 2)]⟩
def c30000 : Species := ⟨"CHEBI:30000 L-selenocysteine residue", [(6, 3), (1, 5), (7, 1), (8, 1), (34, 1)]⟩
def c30001 : Species := ⟨"CHEBI:30001 D-selenocysteine", [(6, 3), (1, 7), (7, 1), (8, 2), (34, 1)]⟩
def c30002 : Species := ⟨"CHEBI:30002 D-selenocysteine residue", [(6, 3), (1, 5), (7, 1), (8, 1), (34, 1)]⟩
def c30005 : Species := ⟨"CHEBI:30005 D-leucine residue", [(6, 6), (1, 11), (7, 1), (8, 1)]⟩
def c30006 : Species := ⟨"CHEBI:30006 L-leucine residue", [(6, 6), (1, 11), (7, 1), (8, 1)]⟩
def c30007 : Species := ⟨"CHEBI:30007 D-alloisoleucine residue", [(6, 6), (1, 11), (7, 1), (8, 1)]⟩
def c30008 : Species := ⟨"CHEBI:30008 L-alloisoleucine residue", [(6, 6), (1, 11), (7, 1), (8, 1)]⟩
def c30009 : Species := ⟨"CHEBI:30009 L-isoleucine residue", [(6, 6), (1, 11), (7, 1), (8, 1)]⟩
def c30010 : Species := ⟨"CHEBI:30010 D-isoleucine residue", [(6, 6), (1, 11), (7, 1), (8, 1)]⟩
def c30011 : Species := ⟨"CHEBI:30011 L-glutamine residue", [(6, 5), (1, 8), (7, 2), (8, 2)]⟩
def c30013 : Species := ⟨"CHEBI:30013 L-threonine residue", [(6, 4), (1, 7), (7, 1), (8, 2)]⟩
def c30014 : Species := ⟨"CHEBI:30014 D-threonine residue", [(6, 4), (1, 7), (7, 1), (8, 2)]⟩
def c30015 : Species := ⟨"CHEBI:30015 L-valine residue", [(6, 5), (1, 9), (7, 1), (8, 1)]⟩
def c30018 : Species := ⟨"CHEBI:30018 D-proline residue", [(6, 5), (1, 7), (7, 1), (8, 1)]⟩
def c30019 : Species := ⟨"CHEBI:30019 L-selenomethionine residue", [(6, 5), (1, 9), (7, 1), (8, 1), (34, 1)]⟩
def c30020 : Species := ⟨"CHEBI:30020 D-selenomethionine residue", [(6, 5), (1, 9), (7, 1), (8, 1), (34, 1)]⟩
def c30021 : Species := ⟨"CHEBI:30021 L-selenomethionine", [(6, 5), (1, 11), (7, 1), (8, 2), (34, 1)]⟩
def c30022 : Species := ⟨"CHEBI:30022 D-selenomethionine", [(6, 5), (1, 11), (7, 1), (8, 2), (34, 1)]⟩
def c30307 : Species := ⟨"CHEBI:30307 N(alpha)-gamma-L-glutamylhistamine", [(6, 10), (1, 16), (7, 4), (8, 3)]⟩
def c30652 : Species := ⟨"CHEBI:30652 5-oxo-L-proline residue", [(6, 5), (1, 5), (7, 1), (8, 2)]⟩
def c32441 : Species := ⟨"CHEBI:32441 alanine residue", [(6, 3), (1, 5), (7, 1), (8, 1)]⟩
def c32457 : Species := ⟨"CHEBI:32457 cysteinate(2-)", [(6, 3), (1, 5), (7, 1), (8, 2), (16, 1), (0, -2)]⟩
def c32460 : Species := ⟨"CHEBI:32460 cysteine residue", [(6, 3), (1, 5), (7, 1), (8, 1), (16, 1)]⟩
def c32461 : Species := ⟨"CHEBI:32461 cysteinate residue", [(6, 3), (1, 4), (7, 1), (8, 1), (16, 1), (0, -1)]⟩
def c32470 : Species := ⟨"CHEBI:32470 aspartic acid residue", [(6, 4), (1, 5), (7, 1), (8, 3)]⟩
def c32471 : Species := ⟨"CHEBI:32471 aspartate residue", [(6, 4), (1, 4), (7, 1), (8, 3), (0, -1)]⟩
def c32483 : Species := ⟨"CHEBI:32483 glutamic acid residue", [(6, 5), (1, 7), (7, 1), (8, 3)]⟩
def c32484 : Species := ⟨"CHEBI:32484 glutamate residue", [(6, 5), (1, 6), (7, 1), (8, 3), (0, -1)]⟩
def c32503 : Species := ⟨"CHEBI:32503 phenylalanine residue", [(6, 9), (1, 9), (7, 1), (8, 1)]⟩
def c32513 : Species := ⟨"CHEBI:32513 L-histidinium(1+)", [(6, 6), (1, 10), (7, 3), (8, 2), (0, 1)]⟩
def c32526 : Species := ⟨"CHEBI:32526 D-histidinium(1+)", [(6, 6), (1, 10), (7, 3), (8, 2), (0, 1)]⟩
def c32531 : Species := ⟨"CHEBI:32531 histidinium(1+)", [(6, 6), (1, 10), (7, 3), (8, 2), (0, 1)]⟩
def c32535 : Species := ⟨"CHEBI:32535 histidine residue", [(6, 6), (1, 7), (7, 3), (8, 1)]⟩
def c32536 : Species := ⟨"CHEBI:32536 histidinium residue", [(6, 6), (1, 8), (7, 3), (8, 1), (0, 1)]⟩
def c32551 : Species := ⟨"CHEBI:32551 L-lysinium(1+)", [(6, 6), (1, 15), (7, 2), (8, 2), (0, 1)]⟩
def c32557 : Species := ⟨"CHEBI:32557 D-lysinium(1+)", [(6, 6), (1, 15), (7, 2), (8, 2), (0, 1)]⟩
def c32564 : Species := ⟨"CHEBI:32564 lysinium(1+)", [(6, 6), (1, 15), (7, 2), (8, 2), (0, 1)]⟩
def c32568 : Species := ⟨"CHEBI:32568 lysine residue", [(6, 6), (1, 12), (7, 2), (8, 1)]⟩
def c32579 : Species := ⟨"CHEBI:32579 lysinium residue", [(6, 6), (1, 13), (7, 2), (8, 1), (0, 1)]⟩
def c32615 : Species := ⟨"CHEBI:32615 isoleucine residue", [(6, 6), (1, 11), (7, 1), (8, 1)]⟩
def c32619 : Species := ⟨"CHEBI:32619 L-leucinate", [(6, 6), (1, 12), (7, 1), (8, 2), (0, -1)]⟩
def c32630 : Species := ⟨"CHEBI:32630 leucine residue", [(6, 6), (1, 11), (7, 1), (8, 1)]⟩
def c32648 : Species := ⟨"CHEBI:32648 methionine residue", [(6, 5), (1, 9), (7, 1), (8, 1), (16, 1)]⟩
def c32664 : Species := ⟨"CHEBI:32664 asparagine residue", [(6, 4), (1, 6), (7, 2), (8, 2)]⟩
def c32677 : Species := ⟨"CHEBI:32677 glutamine residue", [(6, 5), (1, 8), (7, 2), (8, 2)]⟩
def c32682 : Species := ⟨"CHEBI:32682 L-argininium(1+)", [(6, 6), (1, 15), (7, 4), (8, 2), (0, 1)]⟩
def c32689 : Species := ⟨"CHEBI:32689 D-argininium(1+)", [(6, 6), (1, 15), (7, 4), (8, 2), (0, 1)]⟩
def c32696 : Species := ⟨"CHEBI:32696 argininium(1+)", [(6, 6), (1, 15), (7, 4), (8, 2), (0, 1)]⟩
def c32699 : Species := ⟨"CHEBI:32699 argininium residue", [(6, 6), (1, 13), (7, 4), (8, 1), (0, 1)]⟩
def c32700 : Species := ⟨"CHEBI:32700 arginine residue", [(6, 6), (1, 12), (7, 4), (8, 1)]⟩
def c32712 : Species := ⟨"CHEBI:32712 L-tryptophanyl radical", [(6, 11), (1, 11), (7, 2), (8, 2)]⟩
def c32713 : Species := ⟨"CHEBI:32713 L-tryptophanyl radical cation", [(6, 11), (1, 12), (7, 2), (8, 2), (0, 1)]⟩
def c32714 : Species := ⟨"CHEBI:32714 L-tryptophanyl radical residue", [(6, 11), (1, 9), (7, 2), (8, 1)]⟩
def c32715 : Species := ⟨"CHEBI:32715 L-tryptophanyl radical cation residue", [(6, 11), (1, 10), (7, 2), (8, 1), (0, 1)]⟩
def c32721 : Species := ⟨"CHEBI:32721 glycyl radical", [(6, 2), (1, 4), (7, 1), (8, 2)]⟩
def c32722 : Species := ⟨"CHEBI:32722 glycyl radical residue", [(6, 2), (1, 2), (7, 1), (8, 1)]⟩
def c32723 : Species := ⟨"CHEBI:32723 D-tryptophanyl radical", [(6, 11), (1, 11), (7, 2), (8, 2)]⟩
def c32724 : Species := ⟨"CHEBI:32724 D-tryptophanyl radical cation", [(6, 11), (1, 12), (7, 2), (8, 2), (0, 1)]⟩
def c32725 : Species := ⟨"CHEBI:32725 D-tryptophanyl radical residue", [(6, 11), (1, 9), (7, 2), (8, 1)]⟩
def c32726 : Species := ⟨"CHEBI:32726 D-tryptophanyl radical cation residue", [(6, 11), (1, 10), (7, 2), (8, 1), (0, 1)]⟩
def c32729 : Species := ⟨"CHEBI:32729 tryptophanyl radical cation", [(6, 11), (1, 12), (7, 2), (8, 2), (0, 1)]⟩
def c32730 : Species := ⟨"CHEBI:32730 tryptophanyl radical", [(6, 11), (1, 11), (7, 2), (8, 2)]⟩
def c32732 : Species := ⟨"CHEBI:32732 tryptophan residue", [(6, 11), (1, 10), (7, 2), (8, 1)]⟩
def c32733 : Species := ⟨"CHEBI:32733 tryptophanyl radical residue", [(6, 11), (1, 9), (7, 2), (8, 1)]⟩
def c32734 : Species := ⟨"CHEBI:32734 tryptophanyl radical cation residue", [(6, 11), (1, 10), (7, 2), (8, 1), (0, 1)]⟩
def c32736 : Species := ⟨"CHEBI:32736 L-cysteinyl radical", [(6, 3), (1, 6), (7, 1), (8, 2), (16, 1)]⟩
def c32737 : Species := ⟨"CHEBI:32737 L-cysteinyl radical residue", [(6, 3), (1, 4), (7, 1), (8, 1), (16, 1)]⟩
def c32738 : Species := ⟨"CHEBI:32738 D-cysteinyl radical", [(6, 3), (1, 6), (7, 1), (8, 2), (16, 1)]⟩
def c32739 : Species := ⟨"CHEBI:32739 D-cysteinyl radical residue", [(6, 3), (1, 4), (7, 1), (8, 1), (16, 1)]⟩
def c32740 : Species := ⟨"CHEBI:32740 cysteinyl radical", [(6, 3), (1, 6), (7, 1), (8, 2), (16, 1)]⟩
def c32741 : Species := ⟨"CHEBI:32741 cysteinyl radical residue", [(6, 3), (1, 4), (7, 1), (8, 1), (16, 1)]⟩
def c32757 : Species := ⟨"CHEBI:32757 selenocysteine residue", [(6, 3), (1, 5), (7, 1), (8, 1), (34, 1)]⟩
def c32759 : Species := ⟨"CHEBI:32759 L-tyrosinyl radical", [(6, 9), (1, 10), (7, 1), (8, 3)]⟩
def c32763 : Species := ⟨"CHEBI:32763 L-tyrosinyl radical cation", [(6, 9), (1, 11), (7, 1), (8, 3), (0, 1)]⟩
def c32766 : Species := ⟨"CHEBI:32766 L-tyrosinyl radical residue", [(6, 9), (1, 8), (7, 1), (8, 2)]⟩
def c32767 : Species := ⟨"CHEBI:32767 L-tyrosinyl radical cation residue", [(6, 9), (1, 9), (7, 1), (8, 2), (0, 1)]⟩
def c32776 : Species := ⟨"CHEBI:32776 D-tyrosinyl radical cation", [(6, 9), (1, 11), (7, 1), (8, 3), (0, 1)]⟩
def c32777 : Species := ⟨"CHEBI:32777 D-tyrosinyl radical", [(6, 9), (1, 10), (7, 1), (8, 3)]⟩
def c32781 : Species := ⟨"CHEBI:32781 D-tyrosinyl radical residue", [(6, 9), (1, 8), (7, 1), (8, 2)]⟩
def c32782 : Species := ⟨"CHEBI:32782 D-tyrosinyl radical cation residue", [(6, 9), (1, 9), (7, 1), (8, 2), (0, 1)]⟩
def c32783 : Species := ⟨"CHEBI:32783 tyrosinyl radical", [(6, 9), (1, 10), (7, 1), (8, 3)]⟩
def c32787 : Species := ⟨"CHEBI:32787 tyrosinyl radical cation", [(6, 9), (1, 11), (7, 1), (8, 3), (0, 1)]⟩
def c32789 : Species := ⟨"CHEBI:32789 tyrosine residue", [(6, 9), (1, 9), (7, 1), (8, 2)]⟩
def c32791 : Species := ⟨"CHEBI:32791 tyrosinyl radical residue", [(6, 9), (1, 8), (7, 1), (8, 2)]⟩
def c32792 : Species := ⟨"CHEBI:32792 tyrosinyl radical cation residue", [(6, 9), (1, 9), (7, 1), (8, 2), (0, 1)]⟩
def c32812 : Species := ⟨"CHEBI:32812 4-hydroxy-L-glutamate(1-)", [(6, 5), (1, 8), (7, 1), (8, 5), (0, -1)]⟩
def c32835 : Species := ⟨"CHEBI:32835 threonine residue", [(6, 4), (1, 7), (7, 1), (8, 2)]⟩
def c32848 : Species := ⟨"CHEBI:32848 serine residue", [(6, 3), (1, 5), (7, 1), (8, 2)]⟩
def c32861 : Species := ⟨"CHEBI:32861 valine residue", [(6, 5), (1, 9), (7, 1), (8, 1)]⟩
def c32874 : Species := ⟨"CHEBI:32874 proline residue", [(6, 5), (1, 7), (7, 1), (8, 1)]⟩
def c33704 : Species := ⟨"CHEBI:33704 alpha-amino acid", [(6, 2), (1, 4), (7, 1), (8, 2), (1000, 1)]⟩
def c33710 : Species := ⟨"CHEBI:33710 alpha-amino-acid residue", [(6, 2), (1, 2), (7, 1), (8, 1), (1000, 1)]⟩
def c35304 : Species := ⟨"CHEBI:35304 (2S,3R)-3-geranyl-2,3-dihydro-2,N(alpha)-cyclo-L-tryptophan", [(6, 21), (1, 28), (7, 2), (8, 2)]⟩
def c35391 : Species := ⟨"CHEBI:35391 aspartate(1-)", [(6, 4), (1, 6), (7, 1), (8, 4), (0, -1)]⟩
def c35494 : Species := ⟨"CHEBI:35494 D-cystine", [(6, 6), (1, 12), (7, 2), (8, 4), (16, 2)]⟩
def c35619 : Species := ⟨"CHEBI:35619 L-alpha-aminobutyric acid", [(6, 4), (1, 9), (7, 1), (8, 2)]⟩
def c36076 : Species := ⟨"CHEBI:36076 L-topaquinone", [(6, 9), (1, 9), (7, 1), (8, 5)]⟩
def c37012 : Species := ⟨"CHEBI:37012 L-3-oxoalanine", [(6, 3), (1, 5), (7, 1), (8, 3)]⟩
def c37083 : Species := ⟨"CHEBI:37083 cis-glycoluril", [(6, 4), (1, 6), (7, 4), (8, 2)]⟩
def c37525 : Species := ⟨"CHEBI:37525 O-phospho-L-threonine", [(6, 4), (1, 10), (7, 1), (8, 6), (15, 1)]⟩
def c37556 : Species := ⟨"CHEBI:37556 O-(alpha-D-mannosyl)-L-serine", [(6, 9), (1, 17), (7, 1), (8, 8)]⟩
def c37557 : Species := ⟨"CHEBI:37557 O-(alpha-D-mannosyl)-L-threonine", [(6, 10), (1, 19), (7, 1), (8, 8)]⟩
def c37628 : Species := ⟨"CHEBI:37628 desmosine", [(6, 24), (1, 40), (7, 5), (8, 8), (0, 1)]⟩
def c37629 : Species := ⟨"CHEBI:37629 desmosine residue", [(6, 24), (1, 32), (7, 5), (8, 4), (0, 1)]⟩
def c37788 : Species := ⟨"CHEBI:37788 O(4)-phospho-L-tyrosine", [(6, 9), (1, 12), (7, 1), (8, 6), (15, 1)]⟩
def c40196 : Species := ⟨"CHEBI:40196 N(6)-methyl-AMP", [(6, 11), (1, 16), (7, 5), (8, 7), (15, 1)]⟩
def c40410 : Species := ⟨"CHEBI:40410 N-acetylglycine", [(6, 4), (1, 7), (7, 1), (8, 3)]⟩
def c40460 : Species := ⟨"CHEBI:40460 2'-O-methyladenosine 5'-monophosphate", [(6, 11), (1, 16), (7, 5), (8, 7), (15, 1)]⟩
def c40477 : Species := ⟨"CHEBI:40477 L-arginine amide(1+)", [(6, 6), (1, 16), (7, 5), (8, 1), (0, 1)]⟩
def c40545 : Species := ⟨"CHEBI:40545 L-alpha-aminobutyric acid residue", [(6, 4), (1, 7), (7, 1), (8, 1)]⟩
def c40550 : Species := ⟨"CHEBI:40550 D-alpha-aminobutyric acid residue", [(6, 4), (1, 7), (7, 1), (8, 1)]⟩
def c40599 : Species := ⟨"CHEBI:40599 2-aminoisobutyric acid residue", [(6, 4), (1, 7), (7, 1), (8, 1)]⟩
def c40992 : Species := ⟨"CHEBI:40992 N-acetyl-L-alanine", [(6, 5), (1, 9), (7, 1), (8, 3)]⟩
def c41121 : Species := ⟨"CHEBI:41121 (3S)-3-hydroxy-L-aspartic acid residue", [(6, 4), (1, 5), (7, 1), (8, 4)]⟩
def c41149 : Species := ⟨"CHEBI:41149 4-methyl-2-pyrroline-5-carboxylic acid", [(6, 6), (1, 9), (7, 1), (8, 2)]⟩
def c41433 : Species := ⟨"CHEBI:41433 L-glutamic 5-semialdehyde residue", [(6, 5), (1, 7), (7, 1), (8, 2)]⟩
def c41450 : Species := ⟨"CHEBI:41450 gamma-carboxy-L-glutamic acid", [(6, 6), (1, 9), (7, 1), (8, 6)]⟩
def c41630 : Species := ⟨"CHEBI:41630 S-oxy-L-cysteine", [(6, 3), (1, 7), (7, 1), (8, 3), (16, 1)]⟩
def c41696 : Species := ⟨"CHEBI:41696 N-carboxy-L-methionine", [(6, 6), (1, 11), (7, 1), (8, 4), (16, 1)]⟩
def c41710 : Species := ⟨"CHEBI:41710 S-hydroxy-L-cysteine", [(6, 3), (1, 7), (7, 1), (8, 3), (16, 1)]⟩
def c41721 : Species := ⟨"CHEBI:41721 L-cysteine-S-dioxide", [(6, 3), (1, 7), (7, 1), (8, 4), (16, 1)]⟩
def c41834 : Species := ⟨"CHEBI:41834 L-2,4-diaminobutyric acid residue", [(6, 4), (1, 8), (7, 2), (8, 1)]⟩
def c42155 : Species := ⟨"CHEBI:42155 3-amino-L-alanine residue", [(6, 3), (1, 6), (7, 2), (8, 1)]⟩
def c42946 : Species := ⟨"CHEBI:42946 glycoluril", [(6, 4), (1, 6), (7, 4), (8, 2)]⟩
def c43433 : Species := ⟨"CHEBI:43433 L-alloisoleucine", [(6, 6), (1, 13), (7, 1), (8, 2)]⟩
def c43575 : Species := ⟨"CHEBI:43575 N(6)-carboxy-L-lysine", [(6, 7), (1, 14), (7, 2), (8, 4)]⟩
def c43903 : Species := ⟨"CHEBI:43903 N(pros)-methyl-L-histidine residue", [(6, 7), (1, 9), (7, 3), (8, 1)]⟩
def c43967 : Species := ⟨"CHEBI:43967 N(2),N(2)-dimethylguanosine 5'-monophosphate", [(6, 12), (1, 18), (7, 5), (8, 8), (15, 1)]⟩
def c43980 : Species := ⟨"CHEBI:43980 N-methyl-L-phenylalanine", [(6, 10), (1, 13), (7, 1), (8, 2)]⟩
def c43986 : Species := ⟨"CHEBI:43986 N(6),N(6)-dimethyl-AMP", [(6, 12), (1, 18), (7, 5), (8, 7), (15, 1)]⟩
def c43997 : Species := ⟨"CHEBI:43997 N(6),N(6)-dimethyl-L-lysine", [(6, 8), (1, 18), (7, 2), (8, 2)]⟩
def c44079 : Species := ⟨"CHEBI:44079 N(4)-methyl-L-asparagine", [(6, 5), (1, 10), (7, 2), (8, 3)]⟩
def c44120 : Species := ⟨"CHEBI:44120 L-methionine (S)-S-oxide residue", [(6, 5), (1, 9), (7, 1), (8, 2), (16, 1)]⟩
def c44337 : Species := ⟨"CHEBI:44337 N-acetyl-L-glutamate(2-)", [(6, 7), (1, 9), (7, 1), (8, 5), (0, -2)]⟩
def c44454 : Species := ⟨"CHEBI:44454 3-nitro-L-tyrosine", [(6, 9), (1, 10), (7, 2), (8, 5)]⟩
def c44514 : Species := ⟨"CHEBI:44514 O-methyl-L-threonine", [(6, 5), (1, 11), (7, 1), (8, 3)]⟩
def c44571 : Species := ⟨"CHEBI:44571 L-ornithine residue", [(6, 5), (1, 10), (7, 2), (8, 1)]⟩
def c44638 : Species := ⟨"CHEBI:44638 2'-O-methylguanosine 5'-monophosphate", [(6, 11), (1, 16), (7, 5), (8, 8), (15, 1)]⟩
def c44642 : Species := ⟨"CHEBI:44642 2'-O-methyluridine 5'-monophosphate", [(6, 10), (1, 15), (7, 2), (8, 9), (15, 1)]⟩
def c44666 : Species := ⟨"CHEBI:44666 2'-O-methylcytidine 5'-monophosphate", [(6, 10), (1, 16), (7, 3), (8, 8), (15, 1)]⟩
def c44813 : Species := ⟨"CHEBI:44813 N,N-dimethyl-L-prolinium", [(6, 7), (1, 14), (7, 1), (8, 2), (0, 1)]⟩
def c45441 : Species := ⟨"CHEBI:45441 N-acetyl-L-serine", [(6, 5), (1, 9), (7, 1), (8, 4)]⟩
def c45522 : Species := ⟨"CHEBI:45522 O-phospho-L-serine residue", [(6, 3), (1, 6), (7, 1), (8, 5), (15, 1)]⟩
def c45764 : Species := ⟨"CHEBI:45764 L-methionine (R)-S-oxide residue", [(6, 5), (1, 9), (7, 1), (8, 2), (16, 1)]⟩
def c45826 : Species := ⟨"CHEBI:45826 N-acetyl-L-threonine", [(6, 6), (1, 11), (7, 1), (8, 4)]⟩
def c46045 : Species := ⟨"CHEBI:46045 L-topaquinone residue", [(6, 9), (1, 7), (7, 1), (8, 4)]⟩
def c46217 : Species := ⟨"CHEBI:46217 L-alanine residue", [(6, 3), (1, 5), (7, 1), (8, 1)]⟩
def c46470 : Species := ⟨"CHEBI:46470 uridine 5'-monophosphate residue", [(6, 9), (1, 11), (7, 2), (8, 8), (15, 1)]⟩
def c46858 : Species := ⟨"CHEBI:46858 L-tyrosine residue", [(6, 9), (1, 9), (7, 1), (8, 2)]⟩
def c46928 : Species := ⟨"CHEBI:46928 ornithine residue", [(6, 5), (1, 10), (7, 2), (8, 1)]⟩
def c47276 : Species := ⟨"CHEBI:47276 L-6'-bromotryptophan", [(6, 11), (1, 11), (35, 1), (7, 2), (8, 2)]⟩
def c47977 : Species := ⟨"CHEBI:47977 2-amino-2-deoxy-D-glucopyranose", [(6, 6), (1, 13), (7, 1), (8, 5)]⟩
def c48094 : Species := ⟨"CHEBI:48094 D-aspartic acid residue", [(6, 4), (1, 5), (7, 1), (8, 3)]⟩
def c48096 : Species := ⟨"CHEBI:48096 D-glutamic acid residue", [(6, 5), (1, 7), (7, 1), (8, 3)]⟩
def c48097 : Species := ⟨"CHEBI:48097 D-glutamine residue", [(6, 5), (1, 8), (7, 2), (8, 2)]⟩
def c48230 : Species := ⟨"CHEBI:48230 diphthine residue", [(6, 13), (1, 21), (7, 4), (8, 3), (0, 1)]⟩
def c48950 : Species := ⟨"CHEBI:48950 L-2,4-diaminobutyric acid", [(6, 4), (1, 10), (7, 2), (8, 2)]⟩
def c49031 : Species := ⟨"CHEBI:49031 L-methionine (S)-S-oxide", [(6, 5), (1, 11), (7, 1), (8, 3), (16, 1)]⟩
def c49032 : Species := ⟨"CHEBI:49032 L-methionine (R)-S-oxide", [(6, 5), (1, 11), (7, 1), (8, 3), (16, 1)]⟩
def c49185 : Species := ⟨"CHEBI:49185 N(6)-carboxy-L-lysine residue", [(6, 7), (1, 12), (7, 2), (8, 3)]⟩
def c49348 : Species := ⟨"CHEBI:49348 7-hydroxy-L-tryptophan", [(6, 11), (1, 12), (7, 2), (8, 3)]⟩
def c49549 : Species := ⟨"CHEBI:49549 4-chloro-L-threonine", [(6, 4), (1, 8), (17, 1), (7, 1), (8, 3)]⟩
def c50038 : Species := ⟨"CHEBI:50038 deoxyhypusine", [(6, 10), (1, 23), (7, 3), (8, 2)]⟩
def c50051 : Species := ⟨"CHEBI:50051 cystine residue", [(6, 6), (1, 8), (7, 2), (8, 2), (16, 2)]⟩
def c50058 : Species := ⟨"CHEBI:50058 L-cystine residue", [(6, 6), (1, 8), (7, 2), (8, 2), (16, 2)]⟩
def c50065 : Species := ⟨"CHEBI:50065 D-cystine residue", [(6, 6), (1, 8), (7, 2), (8, 2), (16, 2)]⟩
def c50300 : Species := ⟨"CHEBI:50300 thymidine 5'-monophosphate residue", [(6, 10), (1, 13), (7, 2), (8, 7), (15, 1)]⟩
def c50306 : Species := ⟨"CHEBI:50306 adenosine 5'-monophosphate residue", [(6, 10), (1, 12), (7, 5), (8, 6), (15, 1)]⟩
def c50308 : Species := ⟨"CHEBI:50308 cytidine 5'-monophosphate residue", [(6, 9), (1, 12), (7, 3), (8, 7), (15, 1)]⟩
def c50321 : Species := ⟨"CHEBI:50321 2'-deoxycytidine 5'-monophosphate residue", [(6, 9), (1, 12), (7, 3), (8, 6), (15, 1)]⟩
def c50322 : Species := ⟨"CHEBI:50322 2'-deoxyguanosine 5'-monophosphate residue", [(6, 10), (1, 12), (7, 5), (8, 6), (15, 1)]⟩
def c50323 : Species := ⟨"CHEBI:50323 2'-deoxyadenosine 5'-monophosphate residue", [(6, 10), (1, 12), (7, 5), (8, 5), (15, 1)]⟩
def c50324 : Species := ⟨"CHEBI:50324 guanosine 5'-monophosphate residue", [(6, 10), (1, 12), (7, 5), (8, 7), (15, 1)]⟩
def c50328 : Species := ⟨"CHEBI:50328 D-valine residue", [(6, 5), (1, 9), (7, 1), (8, 1)]⟩
def c50342 : Species := ⟨"CHEBI:50342 L-proline residue", [(6, 5), (1, 7), (7, 1), (8, 1)]⟩
def c50347 : Species := ⟨"CHEBI:50347 L-asparagine residue", [(6, 4), (1, 6), (7, 2), (8, 2)]⟩
def c50349 : Species := ⟨"CHEBI:50349 D-asparagine residue", [(6, 4), (1, 6), (7, 2), (8, 2)]⟩
def c50599 : Species := ⟨"CHEBI:50599 N(tele)-methyl-L-histidine", [(6, 7), (1, 11), (7, 3), (8, 2)]⟩
def c50601 : Species := ⟨"CHEBI:50601 N(alpha)-methyl-L-histidine", [(6, 7), (1, 11), (7, 3), (8, 2)]⟩
def c50708 : Species := ⟨"CHEBI:50708 L-homomethionine", [(6, 6), (1, 13), (7, 1), (8, 2), (16, 1)]⟩
def c51448 : Species := ⟨"CHEBI:51448 cis-glycoluril residue", [(6, 4), (1, 2), (7, 4), (8, 2)]⟩
def c51449 : Species := ⟨"CHEBI:51449 glycoluril residue", [(6, 4), (1, 2), (7, 4), (8, 2)]⟩
def c52950 : Species := ⟨"CHEBI:52950 (2S,3R)-3-farnesyl-2,3-dihydro-2,N(alpha)-cyclo-L-tryptophan", [(6, 26), (1, 36), (7, 2), (8, 2)]⟩
def c53014 : Species := ⟨"CHEBI:53014 N(6)-carboxymethyl-L-lysine", [(6, 8), (1, 16), (7, 2), (8, 4)]⟩
def c53015 : Species := ⟨"CHEBI:53015 N(6)-carboxymethyl-L-lysine residue", [(6, 8), (1, 14), (7, 2), (8, 3)]⟩
def c53098 : Species := ⟨"CHEBI:53098 AMP 5'-end residue", [(6, 10), (1, 12), (7, 5), (8, 7), (15, 1), (0, -1)]⟩
def c53099 : Species := ⟨"CHEBI:53099 dAMP 5'-end residue", [(6, 10), (1, 12), (7, 5), (8, 6), (15, 1), (0, -1)]⟩
def c53100 : Species := ⟨"CHEBI:53100 GMP 5'-end residue", [(6, 10), (1, 12), (7, 5), (8, 8), (15, 1), (0, -1)]⟩
def c53101 : Species := ⟨"CHEBI:53101 dGMP 5'-end residue", [(6, 10), (1, 12), (7, 5), (8, 7), (15, 1), (0, -1)]⟩
def c53102 : Species := ⟨"CHEBI:53102 dTMP 5'-end residue", [(6, 10), (1, 13), (7, 2), (8, 8), (15, 1), (0, -1)]⟩
def c53103 : Species := ⟨"CHEBI:53103 CMP 5'-end residue", [(6, 9), (1, 12), (7, 3), (8, 8), (15, 1), (0, -1)]⟩
def c53104 : Species := ⟨"CHEBI:53104 dCMP 5'-end residue", [(6, 9), (1, 12), (7, 3), (8, 7), (15, 1), (0, -1)]⟩
def c53105 : Species := ⟨"CHEBI:53105 UMP 5'-end residue", [(6, 9), (1, 11), (7, 2), (8, 9), (15, 1), (0, -1)]⟩
def c53112 : Species := ⟨"CHEBI:53112 AMP 3'-end residue", [(6, 10), (1, 13), (7, 5), (8, 6), (15, 1)]⟩
def c53113 : Species := ⟨"CHEBI:53113 dAMP 3'-end residue", [(6, 10), (1, 13), (7, 5), (8, 5), (15, 1)]⟩
def c53114 : Species := ⟨"CHEBI:53114 GMP 3'-end residue", [(6, 10), (1, 13), (7, 5), (8, 7), (15, 1)]⟩
def c53116 : Species := ⟨"CHEBI:53116 CMP 3'-end residue", [(6, 9), (1, 13), (7, 3), (8, 7), (15, 1)]⟩
def c53117 : Species := ⟨"CHEBI:53117 dGMP 3'-end residue", [(6, 10), (1, 13), (7, 5), (8, 6), (15, 1)]⟩
def c53118 : Species := ⟨"CHEBI:53118 dTMP 3'-end residue", [(6, 10), (1, 14), (7, 2), (8, 7), (15, 1)]⟩
def c53119 : Species := ⟨"CHEBI:53119 dCMP 3'-end residue", [(6, 9), (1, 13), (7, 3), (8, 6), (15, 1)]⟩
def c53120 : Species := ⟨"CHEBI:53120 UMP 3'-end residue", [(6, 9), (1, 12), (7, 2), (8, 8), (15, 1)]⟩
def c53125 : Species := ⟨"CHEBI:53125 Se-methyl-D-selenocysteine", [(6, 4), (1, 9), (7, 1), (8, 2), (34, 1)]⟩
def c53133 : Species := ⟨"CHEBI:53133 Se-methylselenocysteine residue", [(6, 4), (1, 7), (7, 1), (8, 1), (34, 1)]⟩
def c53134 : Species := ⟨"CHEBI:53134 Se-methyl-L-selenocysteine residue", [(6, 4), (1, 7), (7, 1), (8, 1), (34, 1)]⟩
def c53135 : Species := ⟨"CHEBI:53135 Se-methyl-D-selenocysteine residue", [(6, 4), (1, 7), (7, 1), (8, 1), (34, 1)]⟩
def c53604 : Species := ⟨"CHEBI:53604 O-(N-acetyl-alpha-D-galactosaminyl)-L-serine residue", [(6, 11), (1, 18), (7, 2), (8, 7)]⟩
def c53606 : Species := ⟨"CHEBI:53606 O-[N-acetyl-alpha-neuraminyl-(2->6)-N-acetyl-alpha-D-galactosaminyl]-L-serine residue", [(6, 22), (1, 35), (7, 3), (8, 16)]⟩
def c53607 : Species := ⟨"CHEBI:53607 O-[N-acetyl-alpha-neuraminyl-(2->6)-N-acetyl-alpha-D-galactosaminyl]-L-threonine residue", [(6, 23), (1, 37), (7, 3), (8, 16)]⟩
def c53608 : Species := ⟨"CHEBI:53608 O-(N-acetyl-alpha-D-galactosaminyl)-L-serine", [(6, 11), (1, 20), (7, 2), (8, 8)]⟩
def c53609 : Species := ⟨"CHEBI:53609 O-(N-acetyl-alpha-D-galactosaminyl)-L-threonine", [(6, 12), (1, 22), (7, 2), (8, 8)]⟩
def c53610 : Species := ⟨"CHEBI:53610 O-[N-acetyl-alpha-neuraminyl-(2->6)-N-acetyl-alpha-D-galactosaminyl]-L-serine", [(6, 22), (1, 37), (7, 3), (8, 16)]⟩
def c53611 : Species := ⟨"CHEBI:53611 O-[N-acetyl-alpha-neuraminyl-(2->6)-N-acetyl-alpha-D-galactosaminyl]-L-threonine", [(6, 23), (1, 39), (7, 3), (8, 16)]⟩
def c53668 : Species := ⟨"CHEBI:53668 3-bromo-L-tyrosine", [(6, 9), (1, 10), (35, 1), (7, 1), (8, 3)]⟩
def c57524 : Species := ⟨"CHEBI:57524 O-phosphonato-L-serine(2-)", [(6, 3), (1, 6), (7, 1), (8, 6), (15, 1), (0, -2)]⟩
def c57566 : Species := ⟨"CHEBI:57566 2'-deoxycytosine 5'-monophosphate(2-)", [(6, 9), (1, 12), (7, 3), (8, 7), (15, 1), (0, -2)]⟩
def c57673 : Species := ⟨"CHEBI:57673 2'-deoxyguanosine 5'-monophosphate(2-)", [(6, 10), (1, 12), (7, 5), (8, 7), (15, 1), (0, -2)]⟩
def c57784 : Species := ⟨"CHEBI:57784 2-[3-carboxylato-3-(methylammonio)propyl]-L-histidine dizwitterion", [(6, 11), (1, 18), (7, 4), (8, 4)]⟩
def c57868 : Species := ⟨"CHEBI:57868 N-sulfo-D-glucosamine(1-)", [(6, 6), (1, 12), (7, 1), (8, 8), (16, 1), (0, -1)]⟩
def c58031 : Species := ⟨"CHEBI:58031 2-(3-amino-3-carboxypropyl)-L-histidine dizwitterion", [(6, 10), (1, 16), (7, 4), (8, 4)]⟩
def c58090 : Species := ⟨"CHEBI:58090 L-cysteate(1-)", [(6, 3), (1, 6), (7, 1), (8, 5), (16, 1), (0, -1)]⟩
def c58245 : Species := ⟨"CHEBI:58245 2'-deoxyadenosine 5'-monophosphate(2-)", [(6, 10), (1, 12), (7, 5), (8, 6), (15, 1), (0, -2)]⟩
def c58477 : Species := ⟨"CHEBI:58477 N(omega)-phosphonato-L-arginine", [(6, 6), (1, 14), (7, 4), (8, 5), (15, 1), (0, -1)]⟩
def c58672 : Species := ⟨"CHEBI:58672 L-2-aminoadipate(1-)", [(6, 6), (1, 10), (7, 1), (8, 4), (0, -1)]⟩
def c58675 : Species := ⟨"CHEBI:58675 O-phosphonato-L-threonine(2-)", [(6, 4), (1, 8), (7, 1), (8, 6), (15, 1), (0, -2)]⟩
def c58723 : Species := ⟨"CHEBI:58723 2-ammonio-2-deoxy-D-glucopyranose", [(6, 6), (1, 14), (7, 1), (8, 5), (0, 1)]⟩
def c60193 : Species := ⟨"CHEBI:60193 queuosine", [(6, 17), (1, 23), (7, 5), (8, 7)]⟩
def c60377 : Species := ⟨"CHEBI:60377 cytidine 5'-monophosphate(2-)", [(6, 9), (1, 12), (7, 3), (8, 8), (15, 1), (0, -2)]⟩
def c61085 : Species := ⟨"CHEBI:61085 3-sulfino-L-alanine(1-)", [(6, 3), (1, 6), (7, 1), (8, 4), (16, 1), (0, -1)]⟩
def c61265 : Species := ⟨"CHEBI:61265 (beta-D-glucopyranosyloxymethyl)deoxyuridine 5'-monophosphate residue", [(6, 16), (1, 23), (7, 2), (8, 13), (15, 1)]⟩
def c61884 : Species := ⟨"CHEBI:61884 N-methyl-L-phenylalanine residue", [(6, 10), (1, 11), (7, 1), (8, 1)]⟩
def c61888 : Species := ⟨"CHEBI:61888 N-acetylglycine residue", [(6, 4), (1, 5), (7, 1), (8, 2)]⟩
def c61891 : Species := ⟨"CHEBI:61891 N(5)-methyl-L-glutamine residue", [(6, 6), (1, 10), (7, 2), (8, 2)]⟩
def c61896 : Species := ⟨"CHEBI:61896 N(omega),N(omega)-dimethyl-L-arginine residue", [(6, 8), (1, 16), (7, 4), (8, 1)]⟩
def c61899 : Species := ⟨"CHEBI:61899 L-6'-bromotryptophan residue", [(6, 11), (1, 9), (35, 1), (7, 2), (8, 2)]⟩
def c61916 : Species := ⟨"CHEBI:61916 N(omega),N'(omega)-dimethyl-L-argininyl residue", [(6, 8), (1, 16), (7, 4), (8, 1)]⟩
def c61920 : Species := ⟨"CHEBI:61920 N-acetyl-L-alanine residue", [(6, 5), (1, 7), (7, 1), (8, 2)]⟩
def c61924 : Species := ⟨"CHEBI:61924 N-carboxy-L-methionine residue", [(6, 6), (1, 9), (7, 1), (8, 3), (16, 1)]⟩
def c61928 : Species := ⟨"CHEBI:61928 N(6)-methyl-L-lysine residue", [(6, 7), (1, 14), (7, 2), (8, 2)]⟩
def c61930 : Species := ⟨"CHEBI:61930 N(6)-acetyl-L-lysine residue", [(6, 8), (1, 14), (7, 2), (8, 2)]⟩
def c61939 : Species := ⟨"CHEBI:61939 gamma-carboxy-L-glutamic acid residue", [(6, 6), (1, 7), (7, 1), (8, 6)]⟩
def c61956 : Species := ⟨"CHEBI:61956 S-phospho-L-cysteine residue", [(6, 3), (1, 6), (7, 1), (8, 4), (15, 1), (16, 1)]⟩
def c61960 : Species := ⟨"CHEBI:61960 N(4)-methyl-L-asparagine residue", [(6, 5), (1, 8), (7, 2), (8, 2)]⟩
def c61961 : Species := ⟨"CHEBI:61961 N(6),N(6),N(6)-trimethyl-L-lysine residue", [(6, 9), (1, 19), (7, 2), (8, 1), (0, 1)]⟩
def c61962 : Species := ⟨"CHEBI:61962 S-oxy-L-cysteine residue", [(6, 3), (1, 5), (7, 1), (8, 2), (16, 1)]⟩
def c61963 : Species := ⟨"CHEBI:61963 3-disulfanyl-L-alanine residue", [(6, 3), (1, 5), (7, 1), (8, 1), (16, 2)]⟩
def c61964 : Species := ⟨"CHEBI:61964 L-cysteine-S-dioxide residue", [(6, 3), (1, 5), (7, 1), (8, 3), (16, 1)]⟩
def c61965 : Species := ⟨"CHEBI:61965 trans-4-hydroxy-L-proline residue", [(6, 5), (1, 7), (7, 1), (8, 2)]⟩
def c61967 : Species := ⟨"CHEBI:61967 3-sulfino-L-alanine residue", [(6, 3), (1, 5), (7, 1), (8, 3), (16, 1)]⟩
def c61969 : Species := ⟨"CHEBI:61969 N(6),N(6)-dimethyl-L-lysine residue", [(6, 8), (1, 16), (7, 2), (8, 1)]⟩
def c61971 : Species := ⟨"CHEBI:61971 O-phospho-L-threonine residue", [(6, 4), (1, 8), (7, 1), (8, 5), (15, 1)]⟩
def c61972 : Species := ⟨"CHEBI:61972 O(4)-phospho-L-tyrosine residue", [(6, 9), (1, 10), (7, 1), (8, 5), (15, 1)]⟩
def c61973 : Species := ⟨"CHEBI:61973 S-hydroxy-L-cysteine residue", [(6, 3), (1, 5), (7, 1), (8, 2), (16, 1)]⟩
def c61974 : Species := ⟨"CHEBI:61974 3-sulfino-L-alanine(1-) residue", [(6, 3), (1, 4), (7, 1), (8, 3), (16, 1), (0, -1)]⟩
def c61977 : Species := ⟨"CHEBI:61977 O-phosphonato-L-threonine(2-) residue", [(6, 4), (1, 6), (7, 1), (8, 5), (15, 1), (0, -2)]⟩
def c61978 : Species := ⟨"CHEBI:61978 O(4)-phosphonato-L-tyrosine(2-) residue", [(6, 9), (1, 8), (7, 1), (8, 5), (15, 1), (0, -2)]⟩
def c61979 : Species := ⟨"CHEBI:61979 4-methyl-2-pyrroline-5-carboxylic acid residue", [(6, 6), (1, 7), (7, 1), (8, 1)]⟩
def c61980 : Species := ⟨"CHEBI:61980 3-selenino-L-alanine residue", [(6, 3), (1, 5), (7, 1), (8, 3), (34, 1)]⟩
def c62141 : Species := ⟨"CHEBI:62141 S-[(2E,6E)-farnesyl]-L-cysteine zwitterion", [(6, 18), (1, 31), (7, 1), (8, 2), (16, 1)]⟩
def c62197 : Species := ⟨"CHEBI:62197 S-[(2E,6E)-farnesyl]-L-cysteine", [(6, 18), (1, 31), (7, 1), (8, 2), (16, 1)]⟩
def c62225 : Species := ⟨"CHEBI:62225 S-sulfo-L-cysteinate(1-)", [(6, 3), (1, 6), (7, 1), (8, 5), (16, 2), (0, -1)]⟩
def c62338 : Species := ⟨"CHEBI:62338 O(4)-phosphonato-L-tyrosine(2-)", [(6, 9), (1, 10), (7, 1), (8, 6), (15, 1), (0, -2)]⟩
def c62464 : Species := ⟨"CHEBI:62464 O-(3-O-beta-D-galactosyl-N-acetyl-alpha-D-galactosaminyl)-L-serine", [(6, 17), (1, 30), (7, 2), (8, 13)]⟩
def c62836 : Species := ⟨"CHEBI:62836 2-methylthio-N(6)-(cis-4-hydroxy-Delta(2)-isopentenyl)adenosine residue", [(6, 16), (1, 21), (7, 5), (8, 4), (16, 1)]⟩
def c62866 : Species := ⟨"CHEBI:62866 2-methylthio-N(6)-(Delta(2)-isopentenyl)adenosine residue", [(6, 16), (1, 21), (7, 5), (8, 3), (16, 1)]⟩
def c62875 : Species := ⟨"CHEBI:62875 2-methylthio-N(6)-(Delta(2)-isopentenyl)adenosine", [(6, 16), (1, 23), (7, 5), (8, 4), (16, 1)]⟩
def c62879 : Species := ⟨"CHEBI:62879 2-methylthio-N(6)-(cis-4-hydroxy-Delta(2)-isopentenyl)adenosine", [(6, 16), (1, 23), (7, 5), (8, 5), (16, 1)]⟩
def c62881 : Species := ⟨"CHEBI:62881 N(6)-(Delta(2)-isopentenyl)adenosine", [(6, 15), (1, 21), (7, 5), (8, 4)]⟩
def c62884 : Species := ⟨"CHEBI:62884 N(6)-(Delta(2)-isopentenyl)adenosine residue", [(6, 15), (1, 19), (7, 5), (8, 3)]⟩
def c62885 : Species := ⟨"CHEBI:62885 adenosine residue", [(6, 10), (1, 11), (7, 5), (8, 3)]⟩
def c63528 : Species := ⟨"CHEBI:63528 dTMP(2-)", [(6, 10), (1, 13), (7, 2), (8, 8), (15, 1), (0, -2)]⟩
def c63792 : Species := ⟨"CHEBI:63792 epoxyqueuosine", [(6, 17), (1, 23), (7, 5), (8, 8)]⟩
def c64035 : Species := ⟨"CHEBI:64035 threo-5-hydroxy-L-lysine", [(6, 6), (1, 14), (7, 2), (8, 3)]⟩
def c64299 : Species := ⟨"CHEBI:64299 queuosine residue", [(6, 17), (1, 21), (7, 5), (8, 6)]⟩
def c64300 : Species := ⟨"CHEBI:64300 epoxyqueuosine residue", [(6, 17), (1, 21), (7, 5), (8, 7)]⟩
def c64639 : Species := ⟨"CHEBI:64639 O-(alpha-D-mannose-1-phosphoryl)-L-serine residue", [(6, 9), (1, 16), (7, 1), (8, 10), (15, 1)]⟩
def c64640 : Species := ⟨"CHEBI:64640 hypusine residue", [(6, 10), (1, 21), (7, 3), (8, 2)]⟩
def c64654 : Species := ⟨"CHEBI:64654 guanosine residue", [(6, 10), (1, 11), (7, 5), (8, 4)]⟩
def c64655 : Species := ⟨"CHEBI:64655 2'-O-methylguanosine residue", [(6, 11), (1, 13), (7, 5), (8, 4)]⟩
def c64656 : Species := ⟨"CHEBI:64656 cytidine residue", [(6, 9), (1, 11), (7, 3), (8, 4)]⟩
def c64657 : Species := ⟨"CHEBI:64657 2'-O-methylcytidine residue", [(6, 10), (1, 13), (7, 3), (8, 4)]⟩
def c64679 : Species := ⟨"CHEBI:64679 O-(alpha-D-mannose-1-phosphoryl)-L-serine", [(6, 9), (1, 18), (7, 1), (8, 11), (15, 1)]⟩
def c64846 : Species := ⟨"CHEBI:64846 glycyl-AMP(1-)", [(6, 12), (1, 16), (7, 6), (8, 8), (15, 1), (0, -1)]⟩
def c64891 : Species := ⟨"CHEBI:64891 O-(pantetheine-4'-phosphoryl)serine residue", [(6, 14), (1, 26), (7, 3), (8, 8), (15, 1), (16, 1)]⟩
def c64896 : Species := ⟨"CHEBI:64896 O-(pantetheine-4'-phosphoryl)serine", [(6, 14), (1, 28), (7, 3), (8, 9), (15, 1), (16, 1)]⟩
def c64936 : Species := ⟨"CHEBI:64936 N(pros)-phospho-L-histidine residue", [(6, 6), (1, 8), (7, 3), (8, 4), (15, 1)]⟩
def c64938 : Species := ⟨"CHEBI:64938 N(pros)-phospho-L-histidine", [(6, 6), (1, 10), (7, 3), (8, 5), (15, 1)]⟩
def c65126 : Species := ⟨"CHEBI:65126 erythro-L-hydroxyallysine", [(6, 6), (1, 11), (7, 1), (8, 4)]⟩
def c65127 : Species := ⟨"CHEBI:65127 erythro-L-hydroxyallysine residue", [(6, 6), (1, 9), (7, 1), (8, 4)]⟩
def c65237 : Species := ⟨"CHEBI:65237 L-homomethionine residue", [(6, 8), (1, 17), (7, 1), (8, 1), (16, 1)]⟩
def c65270 : Species := ⟨"CHEBI:65270 [4)-D-GlcpNS-(1->](1-) residue", [(6, 6), (1, 10), (7, 1), (8, 7), (16, 1), (0, -1)]⟩
def c65271 : Species := ⟨"CHEBI:65271 [4)-D-GlcpN-(1->](1+) residue", [(6, 7), (1, 15), (7, 1), (8, 4), (0, 1)]⟩
def c65272 : Species := ⟨"CHEBI:65272 [4)-D-GlcpN-(1->] residue", [(6, 6), (1, 11), (7, 1), (8, 4)]⟩
def c65275 : Species := ⟨"CHEBI:65275 [4)-D-GlcpNS-(1->] residue", [(6, 6), (1, 11), (7, 1), (8, 7), (16, 1)]⟩
def c65320 : Species := ⟨"CHEBI:65320 pseudouridine 5'-phosphate residue", [(6, 11), (1, 17), (7, 2), (8, 8), (15, 1)]⟩
def c67012 : Species := ⟨"CHEBI:67012 L-dopa(1-)", [(6, 9), (1, 10), (7, 1), (8, 4), (0, -1)]⟩
def c71250 : Species := ⟨"CHEBI:71250 N(6)-(glycylglycyl)-L-lysine residue", [(6, 10), (1, 18), (7, 4), (8, 4)]⟩
def c71254 : Species := ⟨"CHEBI:71254 N(6)-(glycylglycyl)-L-lysine", [(6, 10), (1, 20), (7, 4), (8, 4)]⟩
def c73265 : Species := ⟨"CHEBI:73265 archaeosine residue", [(6, 12), (1, 14), (7, 6), (8, 4)]⟩
def c73271 : Species := ⟨"CHEBI:73271 archaeosine", [(6, 12), (1, 16), (7, 6), (8, 5)]⟩
def c73543 : Species := ⟨"CHEBI:73543 7-[(3S)-3-amino-3-carboxypropyl]wyosine 5'-monophosphate(1-) residue", [(6, 18), (1, 22), (7, 6), (8, 9), (15, 1), (0, -1)]⟩
def c73547 : Species := ⟨"CHEBI:73547 2-thio-N(6)-(Delta(2)-isopentenyl)adenosine residue", [(6, 15), (1, 19), (7, 5), (8, 3), (16, 1)]⟩
def c73550 : Species := ⟨"CHEBI:73550 4-demethyl-7-(3-amino-3-carboxypropyl)wyosine 5'-monophosphate(1-) residue", [(6, 17), (1, 20), (7, 6), (8, 9), (15, 1), (0, -1)]⟩
def c73551 : Species := ⟨"CHEBI:73551 2-thio-N(6)-(Delta(2)-isopentenyl)adenosine", [(6, 15), (1, 21), (7, 5), (8, 4), (16, 1)]⟩
def c73552 : Species := ⟨"CHEBI:73552 7-[(3S-amino)-3-carboxypropyl]wyosine 5'-monophosphate residue", [(6, 18), (1, 23), (7, 6), (8, 9), (15, 1)]⟩
def c73553 : Species := ⟨"CHEBI:73553 7-(3-amino-3-carboxypropyl)wyosine 5'-monophosphate", [(6, 18), (1, 25), (7, 6), (8, 10), (15, 1)]⟩
def c73555 : Species := ⟨"CHEBI:73555 7-(3-amino-3-carboxypropyl)wyosine 5'-monophosphate zwitterion", [(6, 18), (1, 24), (7, 6), (8, 7)]⟩
def c73556 : Species := ⟨"CHEBI:73556 4-demethyl-7-(3-amino-3-carboxypropyl)wyosine 5'-monophosphate residue", [(6, 17), (1, 21), (7, 6), (8, 9), (15, 1)]⟩
def c73557 : Species := ⟨"CHEBI:73557 4-demethyl-7-(3-amino-3-carboxypropyl)wyosine 5'-monophosphate", [(6, 17), (1, 23), (7, 6), (8, 10), (15, 1)]⟩
def c73559 : Species := ⟨"CHEBI:73559 4-demethyl-7-(3-amino-3-carboxypropyl)wyosine 5'-monophosphate zwitterion", [(6, 17), (1, 23), (7, 6), (8, 10), (15, 1)]⟩
def c73599 : Species := ⟨"CHEBI:73599 3-methylthioaspartate residue", [(6, 5), (1, 6), (7, 1), (8, 3), (16, 1), (0, -1)]⟩
def c73603 : Species := ⟨"CHEBI:73603 7-(2-hydroxy-3-amino-3-carboxypropyl)wyosine 5'-monophosphate(1-) residue", [(6, 18), (1, 22), (7, 6), (8, 10), (15, 1), (0, -1)]⟩
def c73619 : Species := ⟨"CHEBI:73619 3-methylthioaspartic acid residue", [(6, 5), (1, 7), (7, 1), (8, 3), (16, 1)]⟩
def c73620 : Species := ⟨"CHEBI:73620 3-methylthioaspartate(1-)", [(6, 5), (1, 8), (7, 1), (8, 4), (16, 1), (0, -1)]⟩
def c73621 : Species := ⟨"CHEBI:73621 3-methylthioaspartic acid", [(6, 5), (1, 9), (7, 1), (8, 4), (16, 1)]⟩
def c73622 : Species := ⟨"CHEBI:73622 beta-hydroxywybutosine 5'-monophosphate", [(6, 21), (1, 29), (7, 6), (8, 13), (15, 1)]⟩
def c73624 : Species := ⟨"CHEBI:73624 7-(2-hydroxy-3-amino-3-carboxypropyl)wyosine 5'-monophosphate residue", [(6, 18), (1, 23), (7, 6), (8, 10), (15, 1)]⟩
def c73625 : Species := ⟨"CHEBI:73625 7-(2-hydroxy-3-amino-3-carboxypropyl)wyosine 5'-monophosphate", [(6, 18), (1, 25), (7, 6), (8, 11), (15, 1)]⟩
def c73626 : Species := ⟨"CHEBI:73626 7-(2-hydroxy-3-amino-3-carboxypropyl)wyosine 5'-monophosphate zwitterion", [(6, 18), (1, 24), (7, 6), (8, 8)]⟩
def c73669 : Species := ⟨"CHEBI:73669 5'-(N(6)-L-lysine)-L-tyrosylquinone", [(6, 15), (1, 21), (7, 3), (8, 6)]⟩
def c73670 : Species := ⟨"CHEBI:73670 cysteine tryptophylquinone", [(6, 14), (1, 15), (7, 3), (8, 6), (16, 1)]⟩
def c73743 : Species := ⟨"CHEBI:73743 2-(3-amino-3-carboxypropyl)-L-histidine zwitterion residue", [(6, 10), (1, 14), (7, 4), (8, 3)]⟩
def c73744 : Species := ⟨"CHEBI:73744 2-[3-carboxylato-3-(methylammonio)propyl]-L-histidine residue", [(6, 11), (1, 16), (7, 4), (8, 3)]⟩
def c73745 : Species := ⟨"CHEBI:73745 2-[3-carboxylato-3-(dimethylammonio)propyl]-L-histidine residue", [(6, 12), (1, 18), (7, 4), (8, 3)]⟩
def c73746 : Species := ⟨"CHEBI:73746 2-[3-carboxylato-3-(trimethylammonio)propyl]-L-histidine residue", [(6, 13), (1, 20), (7, 4), (8, 3)]⟩
def c73747 : Species := ⟨"CHEBI:73747 uridine residue", [(6, 9), (1, 10), (7, 2), (8, 5)]⟩
def c73748 : Species := ⟨"CHEBI:73748 5-aminomethyl-2-thiouridine residue(1+)", [(6, 10), (1, 14), (7, 3), (8, 4), (16, 1), (0, 1)]⟩
def c73763 : Species := ⟨"CHEBI:73763 2-[3-carboxylato-3-(dimethylammonio)propyl]-L-histidine dizwitterion", [(6, 12), (1, 20), (7, 4), (8, 4)]⟩
def c73766 : Species := ⟨"CHEBI:73766 2-[3-carboxylato-3-(trimethylammonio)propyl]-L-histidine", [(6, 13), (1, 22), (7, 4), (8, 4)]⟩
def c73767 : Species := ⟨"CHEBI:73767 5-aminomethyl-2-thiouridine residue", [(6, 12), (1, 19), (7, 3), (8, 4), (16, 1)]⟩
def c73768 : Species := ⟨"CHEBI:73768 5-aminomethyl-2-thiouridine", [(6, 10), (1, 15), (7, 3), (8, 5), (16, 1)]⟩
def c73769 : Species := ⟨"CHEBI:73769 5-aminomethyl-2-thiouridine(1+)", [(6, 10), (1, 16), (7, 3), (8, 5), (16, 1), (0, 1)]⟩
def c73890 : Species := ⟨"CHEBI:73890 Gly-Cys", [(6, 5), (1, 10), (7, 2), (8, 3), (16, 1)]⟩
def c73995 : Species := ⟨"CHEBI:73995 2-[(3S)-3-amino-3-carboxypropyl]-L-histidine zwitterion residue", [(6, 10), (1, 14), (7, 4), (8, 3)]⟩
def c74042 : Species := ⟨"CHEBI:74042 2-[(3S)-3-amino-3-carboxypropyl]-L-histidine dizwitterion", [(6, 10), (1, 16), (7, 4), (8, 4)]⟩
def c74151 : Species := ⟨"CHEBI:74151 S-palmitoyl-L-cysteine residue", [(6, 19), (1, 35), (7, 1), (8, 2), (16, 1)]⟩
def c74267 : Species := ⟨"CHEBI:74267 N(1)-methylguanosine 5'-monophosphate residue", [(6, 13), (1, 20), (7, 5), (8, 7), (15, 1)]⟩
def c74268 : Species := ⟨"CHEBI:74268 N(1)-methylguanosine 5'-monophosphate", [(6, 11), (1, 16), (7, 5), (8, 8), (15, 1)]⟩
def c74271 : Species := ⟨"CHEBI:74271 4-demethylwyosine 5'-monophosphate residue", [(6, 13), (1, 14), (7, 5), (8, 7), (15, 1)]⟩
def c74273 : Species := ⟨"CHEBI:74273 4-demethylwyosine 5'-monophosphate", [(6, 13), (1, 16), (7, 5), (8, 8), (15, 1)]⟩
def c74300 : Species := ⟨"CHEBI:74300 wybutosine 5'-monophosphate", [(6, 21), (1, 29), (7, 6), (8, 12), (15, 1)]⟩
def c74301 : Species := ⟨"CHEBI:74301 wybutosine 5'-monophosphate residue", [(6, 21), (1, 27), (7, 6), (8, 11), (15, 1)]⟩
def c74302 : Species := ⟨"CHEBI:74302 beta-hydroxywybutosine 5'-monophosphate residue", [(6, 21), (1, 27), (7, 6), (8, 12), (15, 1)]⟩
def c74346 : Species := ⟨"CHEBI:74346 FMN-L-threonine residue", [(6, 21), (1, 26), (7, 5), (8, 10), (15, 1)]⟩
def c74347 : Species := ⟨"CHEBI:74347 FMN-L-threonine", [(6, 21), (1, 28), (7, 5), (8, 11), (15, 1)]⟩
def c74444 : Species := ⟨"CHEBI:74444 7-[(3S)-(3-amino-3-methoxycarbonyl)propyl]wyosine 5'-phosphate residue", [(6, 19), (1, 25), (7, 6), (8, 9), (15, 1)]⟩
def c74446 : Species := ⟨"CHEBI:74446 7-[(3S)-(3-amino-3-methoxycarbonyl)propyl]wyosine 5'-phosphate", [(6, 19), (1, 27), (7, 6), (8, 10), (15, 1)]⟩
def c74480 : Species := ⟨"CHEBI:74480 N(7)-methylguanosine 5'-phosphate zwitterion residue", [(6, 11), (1, 14), (7, 5), (8, 7), (15, 1)]⟩
def c74636 : Species := ⟨"CHEBI:74636 N(6)-L-threonylcarbamoyladenine 5'-monophosphate residue", [(6, 15), (1, 19), (7, 6), (8, 10), (15, 1)]⟩
def c74637 : Species := ⟨"CHEBI:74637 N(6)-L-threonylcarbamoyladenine 5'-monophosphate", [(6, 15), (1, 21), (7, 6), (8, 11), (15, 1)]⟩
def c74638 : Species := ⟨"CHEBI:74638 N(6)-dimethylallyladenine 5'-monophosphate residue", [(6, 17), (1, 26), (7, 5), (8, 6), (15, 1)]⟩
def c74642 : Species := ⟨"CHEBI:74642 2-thio-N(6)-dimethylallyladenine 5'-monophosphate residue", [(6, 15), (1, 20), (7, 5), (8, 6), (15, 1), (16, 1)]⟩
def c74643 : Species := ⟨"CHEBI:74643 2-thio-N(6)-dimethylallyladenine 5'-monophosphate", [(6, 15), (1, 22), (7, 5), (8, 7), (15, 1), (16, 1)]⟩
def c74645 : Species := ⟨"CHEBI:74645 2-methylthio-N(6)-dimethylallyladenine 5'-monophosphate residue", [(6, 16), (1, 22), (7, 5), (8, 6), (15, 1), (16, 1)]⟩
def c74646 : Species := ⟨"CHEBI:74646 2-methylthio-N(6)-dimethylallyladenine 5'-monophosphate", [(6, 16), (1, 24), (7, 5), (8, 7), (15, 1), (16, 1)]⟩
def c74648 : Species := ⟨"CHEBI:74648 2-thio-N(6)-L-threonylcarbamoyladenine 5'-monophosphate residue", [(6, 15), (1, 19), (7, 6), (8, 10), (15, 1), (16, 1)]⟩
def c74649 : Species := ⟨"CHEBI:74649 2-thio-N(6)-L-threonylcarbamoyladenine 5'-monophosphate", [(6, 15), (1, 21), (7, 6), (8, 11), (15, 1), (16, 1)]⟩
def c74652 : Species := ⟨"CHEBI:74652 3-thio-L-aspartic acid residue", [(6, 4), (1, 5), (7, 1), (8, 3), (16, 1)]⟩
def c74653 : Species := ⟨"CHEBI:74653 3-thio-L-aspartic acid", [(6, 4), (1, 7), (7, 1), (8, 4), (16, 1)]⟩
def c74672 : Species := ⟨"CHEBI:74672 5,6-dihydrouridine 5'-monophosphate residue", [(6, 9), (1, 13), (7, 2), (8, 8), (15, 1)]⟩
def c74673 : Species := ⟨"CHEBI:74673 5,6-dihydrouridine 5'-monophosphate", [(6, 9), (1, 15), (7, 2), (8, 9), (15, 1)]⟩
def c74674 : Species := ⟨"CHEBI:74674 2'-O-methylguanosine 5'-monophosphate residue", [(6, 11), (1, 14), (7, 5), (8, 7), (15, 1)]⟩
def c74676 : Species := ⟨"CHEBI:74676 N(6)-methyladenosine 5'-monophosphate residue", [(6, 13), (1, 20), (7, 5), (8, 6), (15, 1)]⟩
def c74677 : Species := ⟨"CHEBI:74677 5-aminomethyl-2-thiouridine 5'-monophosphate residue", [(6, 10), (1, 14), (7, 3), (8, 7), (15, 1), (16, 1)]⟩
def c74678 : Species := ⟨"CHEBI:74678 5-aminomethyl-2-thiouridine 5'-monophosphate", [(6, 10), (1, 16), (7, 3), (8, 8), (15, 1), (16, 1)]⟩
def c74679 : Species := ⟨"CHEBI:74679 5-methylaminomethyl-2-thiouridine 5'-monophosphate residue", [(6, 11), (1, 16), (7, 3), (8, 7), (15, 1), (16, 1)]⟩
def c74680 : Species := ⟨"CHEBI:74680 5-methylaminomethyl-2-thiouridine 5'-monophosphate", [(6, 11), (1, 18), (7, 3), (8, 8), (15, 1), (16, 1)]⟩
def c74681 : Species := ⟨"CHEBI:74681 2'-O-methyladenosine 5'-monophosphate residue", [(6, 11), (1, 14), (7, 5), (8, 6), (15, 1)]⟩
def c74685 : Species := ⟨"CHEBI:74685 2'-O-methyluridine 5'-monophosphate residue", [(6, 12), (1, 19), (7, 2), (8, 8), (15, 1)]⟩
def c74720 : Species := ⟨"CHEBI:74720 N(7)-methylguanosine 5'-phosphate", [(6, 11), (1, 16), (7, 5), (8, 8), (15, 1)]⟩
def c74721 : Species := ⟨"CHEBI:74721 N(2)-methylguanosine 5'-monophosphate residue", [(6, 11), (1, 14), (7, 5), (8, 7), (15, 1)]⟩
def c74722 : Species := ⟨"CHEBI:74722 N(2)-methylguanosine 5'-monophosphate", [(6, 11), (1, 16), (7, 5), (8, 8), (15, 1)]⟩
def c74724 : Species := ⟨"CHEBI:74724 5-methylcytidine 5'-monophosphate residue", [(6, 10), (1, 14), (7, 3), (8, 7), (15, 1)]⟩
def c74725 : Species := ⟨"CHEBI:74725 5-methylcytidine 5'-monophosphate", [(6, 10), (1, 16), (7, 3), (8, 8), (15, 1)]⟩
def c74730 : Species := ⟨"CHEBI:74730 N(3)-methylpseudouridine 5'-monophosphate residue", [(6, 10), (1, 13), (7, 2), (8, 8), (15, 1)]⟩
def c74731 : Species := ⟨"CHEBI:74731 N(3)-methylpseudouridine 5'-monophosphate", [(6, 10), (1, 15), (7, 2), (8, 9), (15, 1)]⟩
def c74735 : Species := ⟨"CHEBI:74735 N(1)-methyladenosine 5'-monophosphate residue", [(6, 11), (1, 14), (7, 5), (8, 6), (15, 1)]⟩
def c74736 : Species := ⟨"CHEBI:74736 N(1)-methyladenosine 5'-monophosphate", [(6, 11), (1, 16), (7, 5), (8, 7), (15, 1)]⟩
def c74744 : Species := ⟨"CHEBI:74744 N(6),N(6)-dimethyladenosine 5'-monophosphate residue", [(6, 14), (1, 22), (7, 5), (8, 6), (15, 1)]⟩
def c74748 : Species := ⟨"CHEBI:74748 2'-O-methylcytidine 5'-monophosphate residue", [(6, 12), (1, 20), (7, 3), (8, 7), (15, 1)]⟩
def c74769 : Species := ⟨"CHEBI:74769 2-methyladenosine 5'-monophosphate residue", [(6, 11), (1, 14), (7, 5), (8, 6), (15, 1)]⟩
def c74770 : Species := ⟨"CHEBI:74770 2-methyladenosine 5'-monophosphate", [(6, 11), (1, 16), (7, 5), (8, 7), (15, 1)]⟩
def c74771 : Species := ⟨"CHEBI:74771 N(3)-methyluridine 5'-monophosphate residue", [(6, 12), (1, 19), (7, 2), (8, 8), (15, 1)]⟩
def c74773 : Species := ⟨"CHEBI:74773 N(3)-methyluridine 5'-monophosphate", [(6, 10), (1, 15), (7, 2), (8, 9), (15, 1)]⟩
def c74777 : Species := ⟨"CHEBI:74777 N(4)-methylcytidine 5'-monophosphate residue", [(6, 10), (1, 14), (7, 3), (8, 7), (15, 1)]⟩
def c74778 : Species := ⟨"CHEBI:74778 N(4)-methylcytidine 5'-monophosphate", [(6, 10), (1, 16), (7, 3), (8, 8), (15, 1)]⟩
def c74781 : Species := ⟨"CHEBI:74781 5-carboxymethylaminomethyluridine 5'-monophosphate residue", [(6, 12), (1, 16), (7, 3), (8, 10), (15, 1)]⟩
def c74782 : Species := ⟨"CHEBI:74782 5-carboxymethylaminomethyluridine 5'-monophosphate", [(6, 12), (1, 18), (7, 3), (8, 11), (15, 1)]⟩
def c74784 : Species := ⟨"CHEBI:74784 5-carboxymethylaminomethyl-2'-O-methyluridine 5'-monophosphate residue", [(6, 13), (1, 18), (7, 3), (8, 10), (15, 1)]⟩
def c74785 : Species := ⟨"CHEBI:74785 5-carboxymethylaminomethyl-2'-O-methyluridine 5'-monophosphate", [(6, 13), (1, 20), (7, 3), (8, 11), (15, 1)]⟩
def c74786 : Species := ⟨"CHEBI:74786 N(2),N(2)-dimethylguanosine 5'-monophosphate residue", [(6, 12), (1, 16), (7, 5), (8, 7), (15, 1)]⟩
def c74787 : Species := ⟨"CHEBI:74787 8-methyladenosine 5'-monophosphate residue", [(6, 11), (1, 14), (7, 5), (8, 6), (15, 1)]⟩
def c74788 : Species := ⟨"CHEBI:74788 8-methyladenosine 5'-monophosphate", [(6, 11), (1, 16), (7, 5), (8, 7), (15, 1)]⟩
def c75077 : Species := ⟨"CHEBI:75077 N(1)-methylpseudouridine 5'-monophosphate residue", [(6, 10), (1, 13), (7, 2), (8, 8), (15, 1)]⟩
def c75078 : Species := ⟨"CHEBI:75078 N(1)-methylpseudouridine 5'-monophosphate", [(6, 10), (1, 15), (7, 2), (8, 9), (15, 1)]⟩
def c75079 : Species := ⟨"CHEBI:75079 N(3)-methylcytidine 5'-monophosphate residue", [(6, 12), (1, 20), (7, 3), (8, 7), (15, 1)]⟩
def c75083 : Species := ⟨"CHEBI:75083 N(3)-methylcytidine 5'-monophosphate", [(6, 10), (1, 16), (7, 3), (8, 8), (15, 1)]⟩
def c75649 : Species := ⟨"CHEBI:75649 5-(2-methoxy-2-oxoethyl)uridine 5'-monophosphate residue", [(6, 12), (1, 15), (7, 2), (8, 10), (15, 1)]⟩
def c75650 : Species := ⟨"CHEBI:75650 5-(2-methoxy-2-oxoethyl)uridine 5'-monophosphate", [(6, 12), (1, 17), (7, 2), (8, 11), (15, 1)]⟩
def c75657 : Species := ⟨"CHEBI:75657 5-(carboxymethyl)uridine 5'-monophosphate", [(6, 11), (1, 15), (7, 2), (8, 11), (15, 1)]⟩
def c75658 : Species := ⟨"CHEBI:75658 5-(carboxymethyl)uridine 5'-monophosphate residue", [(6, 13), (1, 19), (7, 2), (8, 10), (15, 1)]⟩
def c75714 : Species := ⟨"CHEBI:75714 dUMP residue", [(6, 9), (1, 11), (7, 2), (8, 7), (15, 1)]⟩
def c75715 : Species := ⟨"CHEBI:75715 dUMP 3'-end residue", [(6, 9), (1, 12), (7, 2), (8, 7), (15, 1)]⟩
def c75716 : Species := ⟨"CHEBI:75716 dUMP 5'-end residue", [(6, 9), (1, 12), (7, 2), (8, 8), (15, 1)]⟩
def c76241 : Species := ⟨"CHEBI:76241 O-(S-acylpantetheine-4'-phosphoryl)serine residue", [(6, 15), (1, 25), (7, 3), (8, 9), (15, 1), (16, 1), (1000, 1)]⟩
def c76242 : Species := ⟨"CHEBI:76242 O-(S-acylpantetheine-4'-phosphoryl)serine", [(6, 15), (1, 27), (7, 3), (8, 10), (15, 1), (16, 1), (1000, 1)]⟩
def c76778 : Species := ⟨"CHEBI:76778 IMP residue", [(6, 10), (1, 11), (7, 4), (8, 7), (15, 1)]⟩
def c77409 : Species := ⟨"CHEBI:77409 (3S)-3-hydroxy-L-lysine(1+)", [(6, 6), (1, 15), (7, 2), (8, 3), (0, 1)]⟩
def c78290 : Species := ⟨"CHEBI:78290 L-m-tyrosine zwitterion", [(6, 9), (1, 11), (7, 1), (8, 3)]⟩
def c82696 : Species := ⟨"CHEBI:82696 diphthine betaine residue", [(6, 13), (1, 20), (7, 4), (8, 3)]⟩
def c82748 : Species := ⟨"CHEBI:82748 cytidine 5'-monophosphate(1-) residue", [(6, 9), (1, 11), (7, 3), (8, 7), (15, 1), (0, -1)]⟩
def c83151 : Species := ⟨"CHEBI:83151 glycyl-AMP(1-) residue", [(6, 12), (1, 15), (7, 6), (8, 8), (15, 1), (0, -1)]⟩
def c83226 : Species := ⟨"CHEBI:83226 N(omega)-phospho-L-arginine(1-) residue", [(6, 6), (1, 12), (7, 4), (8, 4), (15, 1), (0, -1)]⟩
def c83228 : Species := ⟨"CHEBI:83228 L-alpha-amino acid residue", [(6, 2), (1, 2), (7, 1), (8, 1), (1000, 1)]⟩
def c83397 : Species := ⟨"CHEBI:83397 L-citrulline residue", [(6, 6), (1, 11), (7, 3), (8, 2)]⟩
def c83421 : Species := ⟨"CHEBI:83421 O-phospho-L-serine(2-) residue", [(6, 3), (1, 4), (7, 1), (8, 5), (15, 1), (0, -2)]⟩
def c83661 : Species := ⟨"CHEBI:83661 lysidine monophosphate", [(6, 15), (1, 26), (7, 5), (8, 9), (15, 1)]⟩
def c83662 : Species := ⟨"CHEBI:83662 lysidine monophosphate(1-)", [(6, 15), (1, 25), (7, 5), (8, 9), (15, 1), (0, -1)]⟩
def c83664 : Species := ⟨"CHEBI:83664 lysine monophosphate residue", [(6, 15), (1, 24), (7, 5), (8, 8), (15, 1)]⟩
def c83665 : Species := ⟨"CHEBI:83665 lysidine monophosphate zwitterion residue", [(6, 15), (1, 24), (7, 5), (8, 8), (15, 1)]⟩
def c83683 : Species := ⟨"CHEBI:83683 N-terminal N-acetyl-L-alanine residue", [(6, 5), (1, 8), (7, 1), (8, 2)]⟩
def c83690 : Species := ⟨"CHEBI:83690 N-terminal N-acetyl-L-serine residue", [(6, 5), (1, 8), (7, 1), (8, 3)]⟩
def c83981 : Species := ⟨"CHEBI:83981 3-hydroxyaspartic acid", [(6, 4), (1, 7), (7, 1), (8, 5)]⟩
def c85428 : Species := ⟨"CHEBI:85428 trans-3-hydroxy-L-proline residue", [(6, 5), (1, 7), (7, 1), (8, 2)]⟩
def c85445 : Species := ⟨"CHEBI:85445 2'-deoxyguanosine 5'-monophosphate(1-) residue", [(6, 10), (1, 11), (7, 5), (8, 6), (15, 1), (0, -1)]⟩
def c85452 : Species := ⟨"CHEBI:85452 2'-deoxycytidine 5'-monophosphate(1-) residue", [(6, 9), (1, 11), (7, 3), (8, 6), (15, 1), (0, -1)]⟩
def c85467 : Species := ⟨"CHEBI:85467 [4)-alpha-D-Glcp-(1->4)-alpha-D-Glcp-(1->4)-alpha-D-Glcp-(1->] residue", [(6, 18), (1, 30), (8, 15)]⟩
def c85621 : Species := ⟨"CHEBI:85621 L-3-oxoalanine residue", [(6, 3), (1, 3), (7, 1), (8, 2)]⟩
def c86019 : Species := ⟨"CHEBI:86019 S-[(2E,6E)-farnesyl]-L-cysteine residue", [(6, 18), (1, 29), (7, 1), (8, 1), (16, 1)]⟩
def c86021 : Species := ⟨"CHEBI:86021 S-geranylgeranyl-L-cysteine residue", [(6, 23), (1, 37), (7, 1), (8, 1), (16, 1)]⟩
def c87075 : Species := ⟨"CHEBI:87075 O-(N-acetyl-alpha-D-galactosaminyl)-L-threonine residue", [(6, 12), (1, 20), (7, 2), (8, 7)]⟩
def c87079 : Species := ⟨"CHEBI:87079 N-acetyl-beta-D-glucosaminyl-(1->3)-N-acetyl-alpha-D-galactosaminyl-L-serine residue", [(6, 19), (1, 31), (7, 3), (8, 12)]⟩
def c87167 : Species := ⟨"CHEBI:87167 S-[(2E,6E)-farnesyl]-L-cysteine methyl ester", [(6, 19), (1, 33), (7, 1), (8, 2), (16, 1)]⟩
def c87169 : Species := ⟨"CHEBI:87169 S-sulfo-L-cysteine(1-) residue", [(6, 3), (1, 4), (7, 1), (8, 4), (16, 2), (0, -1)]⟩
def c87215 : Species := ⟨"CHEBI:87215 N-terminal 5-oxo-L-proline residue", [(6, 5), (1, 6), (7, 1), (8, 2)]⟩
def c87260 : Species := ⟨"CHEBI:87260 O-[N-acetyl-beta-D-glucosaminyl-(1->3)-N-acetyl-alpha-D-galactosaminyl]-L-serine", [(6, 19), (1, 33), (7, 3), (8, 13)]⟩
def c89573 : Species := ⟨"CHEBI:89573 5-[(alpha-D-glucopyranosyl-(1->2)-beta-D-galactopyranosyl)oxy]-L-lysine", [(6, 18), (1, 34), (7, 2), (8, 13)]⟩
def c90510 : Species := ⟨"CHEBI:90510 S-[(2E,6E)-farnesyl]-L-cysteinate residue", [(6, 18), (1, 29), (7, 1), (8, 2), (16, 1), (0, -1)]⟩
def c90511 : Species := ⟨"CHEBI:90511 S-[(2E,6E)-farnesyl]-L-cysteine methyl ester residue", [(6, 19), (1, 32), (7, 1), (8, 2), (16, 1)]⟩
def c90516 : Species := ⟨"CHEBI:90516 L-leucinate residue", [(6, 6), (1, 11), (7, 1), (8, 2), (0, -1)]⟩
def c90615 : Species := ⟨"CHEBI:90615 2'-deoxyadenosine 5'-monophosphate(1-) residue", [(6, 10), (1, 11), (7, 5), (8, 5), (15, 1), (0, -1)]⟩
def c90837 : Species := ⟨"CHEBI:90837 3-O-(N-acetyl-beta-D-glucosaminyl)-L-serine", [(6, 11), (1, 20), (7, 2), (8, 8)]⟩
def c90838 : Species := ⟨"CHEBI:90838 O-(N-acetyl-beta-D-glucosaminyl)-L-serine residue", [(6, 11), (1, 18), (7, 2), (8, 7)]⟩
def c90839 : Species := ⟨"CHEBI:90839 3-O-(N-acetyl-beta-D-glucosaminyl)-L-threonine", [(6, 12), (1, 22), (7, 2), (8, 8)]⟩
def c90840 : Species := ⟨"CHEBI:90840 O-(N-acetyl-beta-D-glucosaminyl)-L-threonine residue", [(6, 12), (1, 20), (7, 2), (8, 7)]⟩
def c90860 : Species := ⟨"CHEBI:90860 4-hydroxy-L-proline residue", [(6, 5), (1, 7), (7, 1), (8, 2)]⟩
def c90870 : Species := ⟨"CHEBI:90870 3-iodo-L-tyrosine residue", [(6, 9), (1, 8), (53, 1), (7, 1), (8, 2)]⟩
def c90871 : Species := ⟨"CHEBI:90871 3,5-diiodo-L-tyrosine residue", [(6, 9), (1, 7), (53, 2), (7, 1), (8, 2)]⟩
def c90872 : Species := ⟨"CHEBI:90872 L-thyroxine residue", [(6, 15), (1, 9), (53, 4), (7, 1), (8, 3)]⟩
def c90873 : Species := ⟨"CHEBI:90873 dehydroalanine residue", [(6, 3), (1, 3), (7, 1), (8, 1)]⟩
def c90874 : Species := ⟨"CHEBI:90874 3,3',5-triiodo-L-thyronine residue", [(6, 15), (1, 10), (53, 3), (7, 1), (8, 3)]⟩
def c91176 : Species := ⟨"CHEBI:91176 deoxyhypusine residue", [(6, 10), (1, 21), (7, 3), (8, 1)]⟩
def c111511 : Species := ⟨"CHEBI:111511 (beta-D-glucopyranosyloxymethyl)deoxyuridine 5'-monophosphate", [(6, 16), (1, 25), (7, 2), (8, 14), (15, 1)]⟩
def c111513 : Species := ⟨"CHEBI:111513 (beta-D-glucopyranosyloxymethyl)deoxyuridine", [(6, 16), (1, 24), (7, 2), (8, 11)]⟩
def c111516 : Species := ⟨"CHEBI:111516 (beta-D-glucopyranosyloxymethyl)deoxyuridine residue", [(6, 16), (1, 22), (7, 2), (8, 10)]⟩
def c131623 : Species := ⟨"CHEBI:131623 N(6)-(2-carboxyethyl)-L-lysine", [(6, 9), (1, 18), (7, 2), (8, 4)]⟩
def c131624 : Species := ⟨"CHEBI:131624 N(6)-(2-carboxyethyl)-L-lysine residue", [(6, 9), (1, 16), (7, 2), (8, 4)]⟩
def c131803 : Species := ⟨"CHEBI:131803 L-allysine residue", [(6, 6), (1, 9), (7, 1), (8, 2)]⟩
def c133304 : Species := ⟨"CHEBI:133304 S-anthraniloyl-L-cysteine residue", [(6, 10), (1, 10), (7, 2), (8, 2), (16, 1)]⟩
def c133358 : Species := ⟨"CHEBI:133358 N(alpha)-acetyl-L-methionyl-L-asparaginyl residue", [(6, 11), (1, 18), (7, 3), (8, 4), (16, 1)]⟩
def c133362 : Species := ⟨"CHEBI:133362 N-acetyl-L-methionyl-L-glutaminyl residue", [(6, 12), (1, 20), (7, 3), (8, 4), (16, 1)]⟩
def c133369 : Species := ⟨"CHEBI:133369 N-acetylglycyl residue", [(6, 4), (1, 6), (7, 1), (8, 2)]⟩
def c133371 : Species := ⟨"CHEBI:133371 N-acetyl-L-valyl residue", [(6, 7), (1, 12), (7, 1), (8, 2)]⟩
def c133372 : Species := ⟨"CHEBI:133372 N-acetyl-L-cysteinyl residue", [(6, 5), (1, 8), (7, 1), (8, 2), (16, 1)]⟩
def c133375 : Species := ⟨"CHEBI:133375 N-acetyl-L-threonyl residue", [(6, 6), (1, 10), (7, 1), (8, 3)]⟩
def c133378 : Species := ⟨"CHEBI:133378 N-acetyl-L-methionyl-L-leucyl residue", [(6, 13), (1, 23), (7, 2), (8, 3), (16, 1)]⟩
def c133379 : Species := ⟨"CHEBI:133379 N-acetyl-L-methionyl-L-isoleucyl residue", [(6, 13), (1, 23), (7, 2), (8, 3), (16, 1)]⟩
def c133382 : Species := ⟨"CHEBI:133382 N-acetyl-L-methionyl-L-phenylalanyl residue", [(6, 16), (1, 21), (7, 2), (8, 3), (16, 1)]⟩
def c133384 : Species := ⟨"CHEBI:133384 N-acetyl-L-methionyl-L-tyrosyl residue", [(6, 16), (1, 21), (7, 2), (8, 4), (16, 1)]⟩
def c133386 : Species := ⟨"CHEBI:133386 N-acetyl-L-methionyl-L-tryptophyl residue", [(6, 18), (1, 22), (7, 3), (8, 3), (16, 1)]⟩
def c133399 : Species := ⟨"CHEBI:133399 N-acetyl-L-methionyl-L-alanyl residue", [(6, 10), (1, 17), (7, 2), (8, 3), (16, 1)]⟩
def c133400 : Species := ⟨"CHEBI:133400 N-acetyl-L-methionyl-L-seryl residue", [(6, 10), (1, 17), (7, 2), (8, 4), (16, 1)]⟩
def c133402 : Species := ⟨"CHEBI:133402 N-acetyl-L-methionyl-L-valyl residue", [(6, 12), (1, 21), (7, 2), (8, 3), (16, 1)]⟩
def c133404 : Species := ⟨"CHEBI:133404 N-acetyl-L-methionyl-L-threonyl residue", [(6, 11), (1, 19), (7, 2), (8, 4), (16, 1)]⟩
def c133414 : Species := ⟨"CHEBI:133414 N-acetyl-L-methionyl residue", [(6, 7), (1, 12), (7, 1), (8, 2), (16, 1)]⟩
def c133442 : Species := ⟨"CHEBI:133442 (5R)-5-hydroxy-L-lysine(1+) residue", [(6, 6), (1, 13), (7, 2), (8, 2), (0, 1)]⟩
def c133479 : Species := ⟨"CHEBI:133479 S-(long-chain fatty acyl)-L-cysteine residue", [(6, 4), (1, 4), (7, 1), (8, 2), (16, 1), (1000, 1)]⟩
def c133902 : Species := ⟨"CHEBI:133902 dUMP residue(1-)", [(6, 9), (1, 10), (7, 2), (8, 7), (15, 1), (0, -1)]⟩
def c134066 : Species := ⟨"CHEBI:134066 N(6)-(pyridoxal phosphate)-L-lysine", [(6, 14), (1, 22), (7, 3), (8, 7), (15, 1)]⟩
def c134208 : Species := ⟨"CHEBI:134208 N-acetyl-alpha-D-glucosaminyl-L-tyrosyl residue", [(6, 17), (1, 22), (7, 2), (8, 7)]⟩
def c134405 : Species := ⟨"CHEBI:134405 S-anthraniloyl-L-cysteine", [(6, 10), (1, 12), (7, 2), (8, 3), (16, 1)]⟩
def c134409 : Species := ⟨"CHEBI:134409 N(alpha)-acetyl-L-methionyl-L-asparagine", [(6, 11), (1, 19), (7, 3), (8, 5), (16, 1)]⟩
def c134471 : Species := ⟨"CHEBI:134471 N-acetyl-L-methionyl-L-glutamine", [(6, 12), (1, 21), (7, 3), (8, 5), (16, 1)]⟩
def c134477 : Species := ⟨"CHEBI:134477 N-acetyl-L-methionyl-L-leucine", [(6, 13), (1, 24), (7, 2), (8, 4), (16, 1)]⟩
def c134478 : Species := ⟨"CHEBI:134478 N-acetyl-L-methionyl-L-isoleucine", [(6, 13), (1, 24), (7, 2), (8, 4), (16, 1)]⟩
def c134481 : Species := ⟨"CHEBI:134481 N-acetyl-L-methionyl-L-phenylalanine", [(6, 16), (1, 22), (7, 2), (8, 4), (16, 1)]⟩
def c134482 : Species := ⟨"CHEBI:134482 N-acetyl-L-methionyl-L-tyrosine", [(6, 16), (1, 22), (7, 2), (8, 5), (16, 1)]⟩
def c134484 : Species := ⟨"CHEBI:134484 N-acetyl-L-methionyl-L-tryptophan", [(6, 18), (1, 23), (7, 3), (8, 4), (16, 1)]⟩
def c134489 : Species := ⟨"CHEBI:134489 N-acetyl-L-methionyl-L-alanine", [(6, 10), (1, 18), (7, 2), (8, 4), (16, 1)]⟩
def c134491 : Species := ⟨"CHEBI:134491 N-acetyl-L-methionyl-L-serine", [(6, 10), (1, 18), (7, 2), (8, 5), (16, 1)]⟩
def c134492 : Species := ⟨"CHEBI:134492 N-acetyl-L-methionyl-L-valine", [(6, 12), (1, 22), (7, 2), (8, 4), (16, 1)]⟩
def c134495 : Species := ⟨"CHEBI:134495 N-acetyl-L-methionyl-L-threonine", [(6, 11), (1, 20), (7, 2), (8, 5), (16, 1)]⟩
def c134526 : Species := ⟨"CHEBI:134526 S-(long-chain fatty acyl)-L-cysteine", [(6, 4), (1, 6), (7, 1), (8, 3), (16, 1), (1000, 1)]⟩
def c136688 : Species := ⟨"CHEBI:136688 N-acetyl-alpha-D-glucosaminyl-L-tyrosine", [(6, 17), (1, 24), (7, 2), (8, 8)]⟩
def c137319 : Species := ⟨"CHEBI:137319 4-phospho-L-aspartic acid residue", [(6, 4), (1, 6), (7, 1), (8, 6), (15, 1)]⟩
def c137321 : Species := ⟨"CHEBI:137321 O-(alpha-D-mannosyl)-L-serine residue", [(6, 9), (1, 15), (7, 1), (8, 7)]⟩
def c137323 : Species := ⟨"CHEBI:137323 O-(alpha-D-mannosyl)-L-threonine residue", [(6, 10), (1, 17), (7, 1), (8, 7)]⟩
def c137351 : Species := ⟨"CHEBI:137351 5-hydroxymethyldeoxycytidine 5'-monophosphate residue", [(6, 10), (1, 14), (7, 3), (8, 7), (15, 1)]⟩
def c137386 : Species := ⟨"CHEBI:137386 thymidine 5'-monophosphate(1-) residue", [(6, 10), (1, 12), (7, 2), (8, 7), (15, 1), (0, -1)]⟩
def c137949 : Species := ⟨"CHEBI:137949 O(3)-(beta-D-galactosyl-(1->3)-N-acetyl-alpha-D-galactosaminyl)-L-serine residue", [(6, 17), (1, 28), (7, 2), (8, 12)]⟩
def c137967 : Species := ⟨"CHEBI:137967 N(6)-acyl-L-lysine residue", [(6, 7), (1, 11), (7, 2), (8, 2), (1000, 1)]⟩
def c138659 : Species := ⟨"CHEBI:138659 5-[(alpha-D-glucopyranosyl-(1->2)-beta-D-galactopyranosyl)oxy]-L-lysine residue", [(6, 18), (1, 32), (7, 2), (8, 12)]⟩
def c138935 : Species := ⟨"CHEBI:138935 S-nitroso-L-cysteine", [(6, 3), (1, 6), (7, 2), (8, 3), (16, 1)]⟩
def c139231 : Species := ⟨"CHEBI:139231 5-methyldeoxycytidine 5'-monophosphate residue", [(6, 10), (1, 14), (7, 3), (8, 6), (15, 1)]⟩
def c139319 : Species := ⟨"CHEBI:139319 3-trisulfanyl-L-alanine residue", [(6, 3), (1, 5), (7, 1), (8, 1), (16, 3)]⟩
def c139364 : Species := ⟨"CHEBI:139364 piperacilloyl-L-lysine", [(6, 29), (1, 41), (7, 7), (8, 9), (16, 1)]⟩
def c139365 : Species := ⟨"CHEBI:139365 flucloxacilloyl-L-lysine", [(6, 25), (1, 31), (17, 1), (9, 1), (7, 5), (8, 7), (16, 1)]⟩
def c139366 : Species := ⟨"CHEBI:139366 amoxicilloyl-L-lysine", [(6, 22), (1, 33), (7, 5), (8, 7), (16, 1)]⟩
def c139367 : Species := ⟨"CHEBI:139367 benzylpenicilloyl-L-lysine", [(6, 22), (1, 32), (7, 4), (8, 6), (16, 1)]⟩
def c139368 : Species := ⟨"CHEBI:139368 aztreonyl-L-lysine", [(6, 19), (1, 31), (7, 7), (8, 10), (16, 2)]⟩
def c139487 : Species := ⟨"CHEBI:139487 piperacilloyl-L-lysine residue", [(6, 29), (1, 39), (7, 7), (8, 8), (16, 1)]⟩
def c139488 : Species := ⟨"CHEBI:139488 flucloxacilloyl-L-lysine residue", [(6, 25), (1, 29), (17, 1), (9, 1), (7, 5), (8, 6), (16, 1)]⟩
def c139489 : Species := ⟨"CHEBI:139489 amoxicillin-L-lysine residue", [(6, 22), (1, 31), (7, 5), (8, 6), (16, 1)]⟩
def c139490 : Species := ⟨"CHEBI:139490 benzylpenicilloyl-L-lysine residue", [(6, 22), (1, 30), (7, 4), (8, 5), (16, 1)]⟩
def c139491 : Species := ⟨"CHEBI:139491 aztreonyl-L-lysine residue", [(6, 19), (1, 29), (7, 7), (8, 9), (16, 2)]⟩
def c140449 : Species := ⟨"CHEBI:140449 [6)-beta-D-GlcpNAc-(1->] residue", [(6, 8), (1, 13), (7, 1), (8, 5)]⟩
def c140856 : Species := ⟨"CHEBI:140856 N-terminal N-acetyl-L-aspartate residue", [(6, 6), (1, 7), (7, 1), (8, 4), (0, -1)]⟩
def c140857 : Species := ⟨"CHEBI:140857 N-terminal N-acetyl-L-glutamate residue", [(6, 7), (1, 9), (7, 1), (8, 4), (0, -1)]⟩
def c140858 : Species := ⟨"CHEBI:140858 N-terminal N-acetyl-L-isoleucine residue", [(6, 8), (1, 14), (7, 1), (8, 2)]⟩
def c140859 : Species := ⟨"CHEBI:140859 N-terminal N-acetyl-L-proline residue", [(6, 7), (1, 10), (7, 1), (8, 2)]⟩
def c140860 : Species := ⟨"CHEBI:140860 N-terminal N-acetyl-L-tyrosine residue", [(6, 11), (1, 12), (7, 1), (8, 3)]⟩
def c141018 : Species := ⟨"CHEBI:141018 4-chloro-L-threonine residue", [(6, 4), (1, 6), (17, 1), (7, 1), (8, 2)]⟩
def c141025 : Species := ⟨"CHEBI:141025 O-acetyl-L-threonine residue", [(6, 6), (1, 9), (7, 1), (8, 3)]⟩
def c141127 : Species := ⟨"CHEBI:141127 (2S,3R)-3-geranyl-2,3-dihydro-2,N(alpha)-cyclo-L-tryptophan residue", [(6, 21), (1, 26), (7, 2), (8, 1)]⟩
def c141128 : Species := ⟨"CHEBI:141128 O-acetyl-L-serine residue", [(6, 5), (1, 7), (7, 1), (8, 3)]⟩
def c141453 : Species := ⟨"CHEBI:141453 2-thiocytidine 5'-monophosphate(1-) residue", [(6, 9), (1, 11), (7, 3), (8, 6), (15, 1), (16, 1), (0, -1)]⟩
def c141492 : Species := ⟨"CHEBI:141492 (3S)-3-hydroxy-L-lysine(1+) residue", [(6, 6), (1, 13), (7, 2), (8, 2), (0, 1)]⟩
def c141495 : Species := ⟨"CHEBI:141495 4-hydroxy-L-lysine(1+) residue", [(6, 6), (1, 13), (7, 2), (8, 2), (0, 1)]⟩
def c141496 : Species := ⟨"CHEBI:141496 4-hydroxy-L-lysine(1+)", [(6, 6), (1, 15), (7, 2), (8, 3), (0, 1)]⟩
def c141575 : Species := ⟨"CHEBI:141575 N(2)-(1-hydroxy-2-oxopropyl)-GMP(2-)", [(6, 13), (1, 16), (7, 5), (8, 10), (15, 1), (0, -2)]⟩
def c141576 : Species := ⟨"CHEBI:141576 N(2)-(1-hydroxy-2-oxoethyl)-GMP(2-)", [(6, 12), (1, 14), (7, 5), (8, 10), (15, 1), (0, -2)]⟩
def c141580 : Species := ⟨"CHEBI:141580 N(2)-(1-hydroxy-2-oxopropyl)-GMP(1-) residue", [(6, 13), (1, 15), (7, 5), (8, 9), (15, 1), (0, -1)]⟩
def c141581 : Species := ⟨"CHEBI:141581 N(2)-(1-hydroxy-2-oxoethyl)-GMP(1-) residue", [(6, 12), (1, 13), (7, 5), (8, 9), (15, 1), (0, -1)]⟩
def c141792 : Species := ⟨"CHEBI:141792 4-hydroxy-D-valine residue", [(6, 5), (1, 9), (7, 1), (8, 2)]⟩
def c141793 : Species := ⟨"CHEBI:141793 3-hydroxy-L-valine residue", [(6, 5), (1, 9), (7, 1), (8, 2)]⟩
def c141794 : Species := ⟨"CHEBI:141794 3-hydroxy-L-tryptophan residue", [(6, 11), (1, 10), (7, 2), (8, 2)]⟩
def c141809 : Species := ⟨"CHEBI:141809 2-hydroxy-L-proline residue", [(6, 5), (1, 7), (7, 1), (8, 2)]⟩
def c141815 : Species := ⟨"CHEBI:141815 3',4'-dihydroxy-L-phenylalanine residue", [(6, 9), (1, 9), (7, 1), (8, 3)]⟩
def c141825 : Species := ⟨"CHEBI:141825 4-hydroxy-L-leucine residue", [(6, 6), (1, 11), (7, 1), (8, 2)]⟩
def c141830 : Species := ⟨"CHEBI:141830 L-cysteate residue", [(6, 3), (1, 4), (7, 1), (8, 4), (16, 1), (0, -1)]⟩
def c141831 : Species := ⟨"CHEBI:141831 7-hydroxy-L-tryptophan residue", [(6, 11), (1, 10), (7, 2), (8, 2)]⟩
def c141835 : Species := ⟨"CHEBI:141835 3-hydroxy-L-proline residue", [(6, 5), (1, 7), (7, 1), (8, 2)]⟩
def c141841 : Species := ⟨"CHEBI:141841 3-hydroxy-L-phenylalanine residue", [(6, 9), (1, 9), (7, 1), (8, 2)]⟩
def c141843 : Species := ⟨"CHEBI:141843 (5S)-5-hydroxy-L-lysinium residue", [(6, 6), (1, 13), (7, 2), (8, 2), (0, 1)]⟩
def c141845 : Species := ⟨"CHEBI:141845 4-hydroxy-L-glutamate residue", [(6, 5), (1, 6), (7, 1), (8, 4), (0, -1)]⟩
def c142054 : Species := ⟨"CHEBI:142054 3-hydroxyaspartic acid residue", [(6, 4), (1, 5), (7, 1), (8, 4)]⟩
def c142395 : Species := ⟨"CHEBI:142395 3-hydroxy-L-tryptophan", [(6, 11), (1, 12), (7, 2), (8, 3)]⟩
def c142413 : Species := ⟨"CHEBI:142413 4-hydroxy-D-valine", [(6, 5), (1, 11), (7, 1), (8, 3)]⟩
def c142415 : Species := ⟨"CHEBI:142415 3-hydroxy-L-valine", [(6, 5), (1, 11), (7, 1), (8, 3)]⟩
def c142417 : Species := ⟨"CHEBI:142417 D-alpha-amino acid residue", [(6, 2), (1, 2), (7, 1), (8, 1), (1000, 1)]⟩
def c142718 : Species := ⟨"CHEBI:142718 N(2)-(ADP-D-ribosyl)-dGMP(4-)", [(6, 25), (1, 31), (7, 10), (8, 20), (15, 3), (0, -4)]⟩
def c142722 : Species := ⟨"CHEBI:142722 N(2)-(ADP-D-ribosyl)-dGMP(3-) residue", [(6, 25), (1, 30), (7, 10), (8, 19), (15, 3), (0, -3)]⟩
def c143140 : Species := ⟨"CHEBI:143140 glycyl-L-cysteine residue", [(6, 5), (1, 8), (7, 2), (8, 2), (16, 1)]⟩
def c143147 : Species := ⟨"CHEBI:143147 N-palmitoyl-L-cysteine residue", [(6, 19), (1, 36), (7, 1), (8, 2), (16, 1)]⟩
def c143279 : Species := ⟨"CHEBI:143279 O-(N-acetyl-alpha-D-glucosaminyl)-L-serine residue", [(6, 11), (1, 18), (7, 2), (8, 7)]⟩
def c143915 : Species := ⟨"CHEBI:143915 N(6)-(pyridoxal phosphate)-L-lysine(2-) residue", [(6, 14), (1, 18), (7, 3), (8, 6), (15, 1), (0, -2)]⟩
def c144030 : Species := ⟨"CHEBI:144030 2-hydroxy-L-proline", [(6, 5), (1, 9), (7, 1), (8, 3)]⟩
def c144031 : Species := ⟨"CHEBI:144031 4-hydroxy-L-leucine", [(6, 6), (1, 13), (7, 1), (8, 3)]⟩
def c144312 : Species := ⟨"CHEBI:144312 O-acetyl-L-threonine", [(6, 6), (1, 11), (7, 1), (8, 4)]⟩
def c144369 : Species := ⟨"CHEBI:144369 L-homocitrulline residue", [(6, 7), (1, 13), (7, 3), (8, 2)]⟩
def c144968 : Species := ⟨"CHEBI:144968 N(6)-(2-hydroxyisobutanoyl)-L-lysine residue", [(6, 10), (1, 18), (7, 2), (8, 3)]⟩
def c145324 : Species := ⟨"CHEBI:145324 N(6)-lactoyl-L-lysine residue", [(6, 9), (1, 16), (7, 2), (8, 3)]⟩
def c145328 : Species := ⟨"CHEBI:145328 (Z)-2,3-didehydroaspartic acid", [(6, 4), (1, 5), (7, 1), (8, 4)]⟩
def c145329 : Species := ⟨"CHEBI:145329 (Z)-2,3-didehydroaspartic acid residue", [(6, 4), (1, 3), (7, 1), (8, 3)]⟩
def c145390 : Species := ⟨"CHEBI:145390 N(6)-lactoyl-L-lysine", [(6, 9), (1, 18), (7, 2), (8, 4)]⟩
def c145391 : Species := ⟨"CHEBI:145391 N(6)-(2-hydroxyisobutanoyl)-L-lysine", [(6, 10), (1, 20), (7, 2), (8, 4)]⟩
def c145671 : Species := ⟨"CHEBI:145671 N,N-dimethyl-L-prolinium residue", [(6, 7), (1, 13), (7, 1), (8, 1), (0, 1)]⟩
def c145897 : Species := ⟨"CHEBI:145897 L-arginine amide(1+) residue", [(6, 6), (1, 15), (7, 5), (8, 1), (0, 1)]⟩
def c145904 : Species := ⟨"CHEBI:145904 L-glutamine amide residue", [(6, 5), (1, 10), (7, 3), (8, 2)]⟩
def c145913 : Species := ⟨"CHEBI:145913 L-methionine amide residue", [(6, 5), (1, 11), (7, 2), (8, 1), (16, 1)]⟩
def c145917 : Species := ⟨"CHEBI:145917 L-tryptophan amide residue", [(6, 11), (1, 12), (7, 3), (8, 1)]⟩
def c149494 : Species := ⟨"CHEBI:149494 S-nitroso-L-cysteine residue", [(6, 3), (1, 4), (7, 2), (8, 2), (16, 1)]⟩
def c155899 : Species := ⟨"CHEBI:155899 3-nitro-L-tyrosine residue", [(6, 9), (1, 8), (7, 2), (8, 4)]⟩
def c156064 : Species := ⟨"CHEBI:156064 N(6)-formyl-L-lysine residue", [(6, 7), (1, 12), (7, 2), (8, 2)]⟩
def c156065 : Species := ⟨"CHEBI:156065 L-methionine sulfone residue", [(6, 5), (1, 9), (7, 1), (8, 3), (16, 1)]⟩
def c156254 : Species := ⟨"CHEBI:156254 3-sulfino-L-alanyl residue", [(6, 3), (1, 6), (7, 1), (8, 3), (16, 1)]⟩
def c166866 : Species := ⟨"CHEBI:166866 S-[(5R)-5-hydroxy-L-lysyl]-L-methionine sulfilimine residue", [(6, 11), (1, 19), (7, 3), (8, 3), (16, 1)]⟩
def c166867 : Species := ⟨"CHEBI:166867 S-(L-lysyl)-L-methionine sulfilimine residue", [(6, 11), (1, 19), (7, 3), (8, 2), (16, 1)]⟩
def c167179 : Species := ⟨"CHEBI:167179 N-[2-(1H-imidazol-4-yl)ethyl]-L-glutamine residue", [(6, 10), (1, 14), (7, 4), (8, 2)]⟩
def c167628 : Species := ⟨"CHEBI:167628 O-methyl-L-threonine residue", [(6, 5), (1, 9), (7, 1), (8, 2)]⟩
def c177368 : Species := ⟨"CHEBI:177368 (2S,3R)-3-farnesyl-2,3-dihydro-2,N(alpha)-cyclo-L-tryptophan residue", [(6, 26), (1, 34), (7, 2), (8, 1)]⟩
def c183512 : Species := ⟨"CHEBI:183512 3-bromo-L-tyrosine residue", [(6, 9), (1, 8), (35, 1), (7, 1), (8, 2)]⟩
def c194223 : Species := ⟨"CHEBI:194223 N-terminal N-acetyl-L-leucyl residue", [(6, 8), (1, 14), (7, 1), (8, 2)]⟩
def c195204 : Species := ⟨"CHEBI:195204 N(alpha)-methyl-L-histidine residue", [(6, 7), (1, 9), (7, 3), (8, 1)]⟩
def c197458 : Species := ⟨"CHEBI:197458 N(6)-acetyl-N(6)-methyl-L-lysine", [(6, 9), (1, 18), (7, 2), (8, 3)]⟩
def c197459 : Species := ⟨"CHEBI:197459 N(6)-acetyl-N(6)-methyl-L-lysine residue", [(6, 9), (1, 16), (7, 2), (8, 2)]⟩
def c229519 : Species := ⟨"CHEBI:229519 3-trisulfanyl-L-alanine", [(6, 3), (1, 7), (7, 1), (8, 2), (16, 3)]⟩
def c229579 : Species := ⟨"CHEBI:229579 di-L-cysteinyl-trisulfide residue", [(6, 6), (1, 8), (7, 2), (8, 2), (16, 3)]⟩
def c233010 : Species := ⟨"CHEBI:233010 N-acetyl-alpha-L-Fucp-(1->3)-2-N-acetyl-4-N-(3R,5R)-dihydroxyhexanoyl-alpha-D-quip-(1->2)-alpha-L-Rhap", [(6, 28), (1, 49), (7, 3), (8, 15)]⟩
def c233051 : Species := ⟨"CHEBI:233051 [(4)-N-acetyl-alpha-L-Fucp-(1->3)-2-N-acetyl-4-N-(3R,5R)-dihydroxyhexanoyl-alpha-D-quip-(1->2)-alpha-L-Rhap-(1->)] residue", [(6, 28), (1, 47), (7, 3), (8, 15)]⟩
def c235404 : Species := ⟨"CHEBI:235404 L-2-aminoadipate(1-) residue", [(6, 6), (1, 8), (7, 1), (8, 3), (0, -1)]⟩
def c246422 : Species := ⟨"CHEBI:246422 dUMP(2-)", [(6, 9), (1, 11), (7, 2), (8, 8), (15, 1), (0, -2)]⟩
def c760776 : Species := ⟨"CHEBI:760776 L-thiocystine", [(6, 6), (1, 12), (7, 2), (8, 4), (16, 3)]⟩

-- R1 · CHEBI:29947 glycine residue from CHEBI:15428 glycine: RULE_AGREES
theorem pair_c29947_c15428 : Balanced [(-1, c15428), (1, c29947), (1, water)] := by decide
-- R1 · CHEBI:29950 L-cysteine residue from CHEBI:17561 L-cysteine: RULE_AGREES
theorem pair_c29950_c17561 : Balanced [(-1, c17561), (1, c29950), (1, water)] := by decide
-- R1 · CHEBI:32460 cysteine residue from CHEBI:15356 cysteine: RULE_AGREES
theorem pair_c32460_c15356 : Balanced [(-1, c15356), (1, c32460), (1, water)] := by decide
-- R1 · CHEBI:32461 cysteinate residue from CHEBI:32457 cysteinate(2-): RULE_DIFFERS_BY_HYDRONS
theorem pair_c32461_c32457 : ¬ Balanced [(-1, c32457), (1, c32461), (1, water)] ∧ Balanced ([(-1, c32457), (1, c32461), (1, water)] ++ [(-1, hydron)]) := by decide
-- R1 · CHEBI:29951 D-cysteine residue from CHEBI:16375 D-cysteine: RULE_AGREES
theorem pair_c29951_c16375 : Balanced [(-1, c16375), (1, c29951), (1, water)] := by decide
-- R1 · CHEBI:32741 cysteinyl radical residue from CHEBI:32740 cysteinyl radical: RULE_AGREES
theorem pair_c32741_c32740 : Balanced [(-1, c32740), (1, c32741), (1, water)] := by decide
-- R1 · CHEBI:33710 alpha-amino-acid residue from CHEBI:33704 alpha-amino acid: RULE_AGREES
theorem pair_c33710_c33704 : Balanced [(-1, c33704), (1, c33710), (1, water)] := by decide
-- R1 · CHEBI:46217 L-alanine residue from CHEBI:16977 L-alanine: RULE_AGREES
theorem pair_c46217_c16977 : Balanced [(-1, c16977), (1, c46217), (1, water)] := by decide
-- R1 · CHEBI:32739 D-cysteinyl radical residue from CHEBI:32738 D-cysteinyl radical: RULE_AGREES
theorem pair_c32739_c32738 : Balanced [(-1, c32738), (1, c32739), (1, water)] := by decide
-- R1 · CHEBI:32737 L-cysteinyl radical residue from CHEBI:32736 L-cysteinyl radical: RULE_AGREES
theorem pair_c32737_c32736 : Balanced [(-1, c32736), (1, c32737), (1, water)] := by decide
-- R1 · CHEBI:30019 L-selenomethionine residue from CHEBI:30021 L-selenomethionine: RULE_AGREES
theorem pair_c30019_c30021 : Balanced [(-1, c30021), (1, c30019), (1, water)] := by decide
-- R1 · CHEBI:30020 D-selenomethionine residue from CHEBI:30022 D-selenomethionine: RULE_AGREES
theorem pair_c30020_c30022 : Balanced [(-1, c30022), (1, c30020), (1, water)] := by decide
-- R1 · CHEBI:32441 alanine residue from CHEBI:16449 alanine: RULE_AGREES
theorem pair_c32441_c16449 : Balanced [(-1, c16449), (1, c32441), (1, water)] := by decide
-- R1 · CHEBI:29949 D-alanine residue from CHEBI:15570 D-alanine: RULE_AGREES
theorem pair_c29949_c15570 : Balanced [(-1, c15570), (1, c29949), (1, water)] := by decide
-- R1 · CHEBI:32470 aspartic acid residue from CHEBI:22660 aspartic acid: RULE_AGREES
theorem pair_c32470_c22660 : Balanced [(-1, c22660), (1, c32470), (1, water)] := by decide
-- R1 · CHEBI:29958 L-aspartic acid residue from CHEBI:17053 L-aspartic acid: RULE_AGREES
theorem pair_c29958_c17053 : Balanced [(-1, c17053), (1, c29958), (1, water)] := by decide
-- R1 · CHEBI:29961 L-aspartate residue from CHEBI:29991 L-aspartate(1-): RULE_AGREES
theorem pair_c29961_c29991 : Balanced [(-1, c29991), (1, c29961), (1, water)] := by decide
-- R1 · CHEBI:32471 aspartate residue from CHEBI:35391 aspartate(1-): RULE_AGREES
theorem pair_c32471_c35391 : Balanced [(-1, c35391), (1, c32471), (1, water)] := by decide
-- R1 · CHEBI:29962 D-aspartate residue from CHEBI:29990 D-aspartate(1-): RULE_AGREES
theorem pair_c29962_c29990 : Balanced [(-1, c29990), (1, c29962), (1, water)] := by decide
-- R1 · CHEBI:48094 D-aspartic acid residue from CHEBI:17364 D-aspartic acid: RULE_AGREES
theorem pair_c48094_c17364 : Balanced [(-1, c17364), (1, c48094), (1, water)] := by decide
-- R1 · CHEBI:32483 glutamic acid residue from CHEBI:18237 glutamic acid: RULE_AGREES
theorem pair_c32483_c18237 : Balanced [(-1, c18237), (1, c32483), (1, water)] := by decide
-- R1 · CHEBI:32484 glutamate residue from CHEBI:14321 glutamate(1-): RULE_AGREES
theorem pair_c32484_c14321 : Balanced [(-1, c14321), (1, c32484), (1, water)] := by decide
-- R1 · CHEBI:32722 glycyl radical residue from CHEBI:32721 glycyl radical: RULE_AGREES
theorem pair_c32722_c32721 : Balanced [(-1, c32721), (1, c32722), (1, water)] := by decide
-- R1 · CHEBI:29997 L-phenylalanine residue from CHEBI:17295 L-phenylalanine: RULE_AGREES
theorem pair_c29997_c17295 : Balanced [(-1, c17295), (1, c29997), (1, water)] := by decide
-- R1 · CHEBI:29996 D-phenylalanine residue from CHEBI:16998 D-phenylalanine: RULE_AGREES
theorem pair_c29996_c16998 : Balanced [(-1, c16998), (1, c29996), (1, water)] := by decide
-- R1 · CHEBI:32503 phenylalanine residue from CHEBI:28044 phenylalanine: RULE_AGREES
theorem pair_c32503_c28044 : Balanced [(-1, c28044), (1, c32503), (1, water)] := by decide
-- R1 · CHEBI:32536 histidinium residue from CHEBI:32531 histidinium(1+): RULE_AGREES
theorem pair_c32536_c32531 : Balanced [(-1, c32531), (1, c32536), (1, water)] := by decide
-- R1 · CHEBI:29981 D-histidinium residue from CHEBI:32526 D-histidinium(1+): RULE_AGREES
theorem pair_c29981_c32526 : Balanced [(-1, c32526), (1, c29981), (1, water)] := by decide
-- R1 · CHEBI:29982 L-histidinium residue from CHEBI:32513 L-histidinium(1+): RULE_AGREES
theorem pair_c29982_c32513 : Balanced [(-1, c32513), (1, c29982), (1, water)] := by decide
-- R1 · CHEBI:29979 L-histidine residue from CHEBI:15971 L-histidine: RULE_AGREES
theorem pair_c29979_c15971 : Balanced [(-1, c15971), (1, c29979), (1, water)] := by decide
-- R1 · CHEBI:29980 D-histidine residue from CHEBI:27947 D-histidine: RULE_AGREES
theorem pair_c29980_c27947 : Balanced [(-1, c27947), (1, c29980), (1, water)] := by decide
-- R1 · CHEBI:32535 histidine residue from CHEBI:27570 histidine: RULE_AGREES
theorem pair_c32535_c27570 : Balanced [(-1, c27570), (1, c32535), (1, water)] := by decide
-- R1 · CHEBI:30007 D-alloisoleucine residue from CHEBI:20899 D-alloisoleucine: RULE_AGREES
theorem pair_c30007_c20899 : Balanced [(-1, c20899), (1, c30007), (1, water)] := by decide
-- R1 · CHEBI:30008 L-alloisoleucine residue from CHEBI:43433 L-alloisoleucine: RULE_AGREES
theorem pair_c30008_c43433 : Balanced [(-1, c43433), (1, c30008), (1, water)] := by decide
-- R1 · CHEBI:32568 lysine residue from CHEBI:25094 lysine: RULE_AGREES
theorem pair_c32568_c25094 : Balanced [(-1, c25094), (1, c32568), (1, water)] := by decide
-- R1 · CHEBI:29968 D-lysine residue from CHEBI:16855 D-lysine: RULE_AGREES
theorem pair_c29968_c16855 : Balanced [(-1, c16855), (1, c29968), (1, water)] := by decide
-- R1 · CHEBI:29967 L-lysine residue from CHEBI:18019 L-lysine: RULE_AGREES
theorem pair_c29967_c18019 : Balanced [(-1, c18019), (1, c29967), (1, water)] := by decide
-- R1 · CHEBI:32579 lysinium residue from CHEBI:32564 lysinium(1+): RULE_AGREES
theorem pair_c32579_c32564 : Balanced [(-1, c32564), (1, c32579), (1, water)] := by decide
-- R1 · CHEBI:29970 D-lysinium residue from CHEBI:32557 D-lysinium(1+): RULE_AGREES
theorem pair_c29970_c32557 : Balanced [(-1, c32557), (1, c29970), (1, water)] := by decide
-- R1 · CHEBI:29969 L-lysinium residue from CHEBI:32551 L-lysinium(1+): RULE_AGREES
theorem pair_c29969_c32551 : Balanced [(-1, c32551), (1, c29969), (1, water)] := by decide
-- R1 · CHEBI:29954 L-tryptophan residue from CHEBI:16828 L-tryptophan: RULE_AGREES
theorem pair_c29954_c16828 : Balanced [(-1, c16828), (1, c29954), (1, water)] := by decide
-- R1 · CHEBI:46858 L-tyrosine residue from CHEBI:17895 L-tyrosine: RULE_AGREES
theorem pair_c46858_c17895 : Balanced [(-1, c17895), (1, c46858), (1, water)] := by decide
-- R1 · CHEBI:46045 L-topaquinone residue from CHEBI:36076 L-topaquinone: RULE_AGREES
theorem pair_c46045_c36076 : Balanced [(-1, c36076), (1, c46045), (1, water)] := by decide
-- R1 · CHEBI:32734 tryptophanyl radical cation residue from CHEBI:32729 tryptophanyl radical cation: RULE_AGREES
theorem pair_c32734_c32729 : Balanced [(-1, c32729), (1, c32734), (1, water)] := by decide
-- R1 · CHEBI:32726 D-tryptophanyl radical cation residue from CHEBI:32724 D-tryptophanyl radical cation: RULE_AGREES
theorem pair_c32726_c32724 : Balanced [(-1, c32724), (1, c32726), (1, water)] := by decide
-- R1 · CHEBI:32715 L-tryptophanyl radical cation residue from CHEBI:32713 L-tryptophanyl radical cation: RULE_AGREES
theorem pair_c32715_c32713 : Balanced [(-1, c32713), (1, c32715), (1, water)] := by decide
-- R1 · CHEBI:32733 tryptophanyl radical residue from CHEBI:32730 tryptophanyl radical: RULE_AGREES
theorem pair_c32733_c32730 : Balanced [(-1, c32730), (1, c32733), (1, water)] := by decide
-- R1 · CHEBI:32714 L-tryptophanyl radical residue from CHEBI:32712 L-tryptophanyl radical: RULE_AGREES
theorem pair_c32714_c32712 : Balanced [(-1, c32712), (1, c32714), (1, water)] := by decide
-- R1 · CHEBI:32725 D-tryptophanyl radical residue from CHEBI:32723 D-tryptophanyl radical: RULE_AGREES
theorem pair_c32725_c32723 : Balanced [(-1, c32723), (1, c32725), (1, water)] := by decide
-- R1 · CHEBI:32732 tryptophan residue from CHEBI:27897 tryptophan: RULE_AGREES
theorem pair_c32732_c27897 : Balanced [(-1, c27897), (1, c32732), (1, water)] := by decide
-- R1 · CHEBI:29955 D-tryptophan residue from CHEBI:16296 D-tryptophan: RULE_AGREES
theorem pair_c29955_c16296 : Balanced [(-1, c16296), (1, c29955), (1, water)] := by decide
-- R1 · CHEBI:32791 tyrosinyl radical residue from CHEBI:32783 tyrosinyl radical: RULE_AGREES
theorem pair_c32791_c32783 : Balanced [(-1, c32783), (1, c32791), (1, water)] := by decide
-- R1 · CHEBI:32766 L-tyrosinyl radical residue from CHEBI:32759 L-tyrosinyl radical: RULE_AGREES
theorem pair_c32766_c32759 : Balanced [(-1, c32759), (1, c32766), (1, water)] := by decide
-- R1 · CHEBI:32781 D-tyrosinyl radical residue from CHEBI:32777 D-tyrosinyl radical: RULE_AGREES
theorem pair_c32781_c32777 : Balanced [(-1, c32777), (1, c32781), (1, water)] := by decide
-- R1 · CHEBI:32792 tyrosinyl radical cation residue from CHEBI:32787 tyrosinyl radical cation: RULE_AGREES
theorem pair_c32792_c32787 : Balanced [(-1, c32787), (1, c32792), (1, water)] := by decide
-- R1 · CHEBI:32767 L-tyrosinyl radical cation residue from CHEBI:32763 L-tyrosinyl radical cation: RULE_AGREES
theorem pair_c32767_c32763 : Balanced [(-1, c32763), (1, c32767), (1, water)] := by decide
-- R1 · CHEBI:32782 D-tyrosinyl radical cation residue from CHEBI:32776 D-tyrosinyl radical cation: RULE_AGREES
theorem pair_c32782_c32776 : Balanced [(-1, c32776), (1, c32782), (1, water)] := by decide
-- R1 · CHEBI:29976 D-tyrosine residue from CHEBI:28479 D-tyrosine: RULE_AGREES
theorem pair_c29976_c28479 : Balanced [(-1, c28479), (1, c29976), (1, water)] := by decide
-- R1 · CHEBI:32789 tyrosine residue from CHEBI:18186 tyrosine: RULE_AGREES
theorem pair_c32789_c18186 : Balanced [(-1, c18186), (1, c32789), (1, water)] := by decide
-- R1 · CHEBI:32861 valine residue from CHEBI:27266 valine: RULE_AGREES
theorem pair_c32861_c27266 : Balanced [(-1, c27266), (1, c32861), (1, water)] := by decide
-- R1 · CHEBI:30015 L-valine residue from CHEBI:16414 L-valine: RULE_AGREES
theorem pair_c30015_c16414 : Balanced [(-1, c16414), (1, c30015), (1, water)] := by decide
-- R1 · CHEBI:50328 D-valine residue from CHEBI:27477 D-valine: RULE_AGREES
theorem pair_c50328_c27477 : Balanced [(-1, c27477), (1, c50328), (1, water)] := by decide
-- R1 · CHEBI:30013 L-threonine residue from CHEBI:16857 L-threonine: RULE_AGREES
theorem pair_c30013_c16857 : Balanced [(-1, c16857), (1, c30013), (1, water)] := by decide
-- R1 · CHEBI:30014 D-threonine residue from CHEBI:16398 D-threonine: RULE_AGREES
theorem pair_c30014_c16398 : Balanced [(-1, c16398), (1, c30014), (1, water)] := by decide
-- R1 · CHEBI:32835 threonine residue from CHEBI:26986 threonine: RULE_AGREES
theorem pair_c32835_c26986 : Balanced [(-1, c26986), (1, c32835), (1, water)] := by decide
-- R1 · CHEBI:29999 L-serine residue from CHEBI:17115 L-serine: RULE_AGREES
theorem pair_c29999_c17115 : Balanced [(-1, c17115), (1, c29999), (1, water)] := by decide
-- R1 · CHEBI:29998 D-serine residue from CHEBI:16523 D-serine: RULE_AGREES
theorem pair_c29998_c16523 : Balanced [(-1, c16523), (1, c29998), (1, water)] := by decide
-- R1 · CHEBI:32848 serine residue from CHEBI:17822 serine: RULE_AGREES
theorem pair_c32848_c17822 : Balanced [(-1, c17822), (1, c32848), (1, water)] := by decide
-- R1 · CHEBI:29953 D-arginine residue from CHEBI:15816 D-arginine: RULE_AGREES
theorem pair_c29953_c15816 : Balanced [(-1, c15816), (1, c29953), (1, water)] := by decide
-- R1 · CHEBI:29952 L-arginine residue from CHEBI:16467 L-arginine: RULE_AGREES
theorem pair_c29952_c16467 : Balanced [(-1, c16467), (1, c29952), (1, water)] := by decide
-- R1 · CHEBI:32700 arginine residue from CHEBI:29016 arginine: RULE_AGREES
theorem pair_c32700_c29016 : Balanced [(-1, c29016), (1, c32700), (1, water)] := by decide
-- R1 · CHEBI:29966 D-argininium residue from CHEBI:32689 D-argininium(1+): RULE_AGREES
theorem pair_c29966_c32689 : Balanced [(-1, c32689), (1, c29966), (1, water)] := by decide
-- R1 · CHEBI:29965 L-argininium residue from CHEBI:32682 L-argininium(1+): RULE_AGREES
theorem pair_c29965_c32682 : Balanced [(-1, c32682), (1, c29965), (1, water)] := by decide
-- R1 · CHEBI:32699 argininium residue from CHEBI:32696 argininium(1+): RULE_AGREES
theorem pair_c32699_c32696 : Balanced [(-1, c32696), (1, c32699), (1, water)] := by decide
-- R1 · CHEBI:30011 L-glutamine residue from CHEBI:18050 L-glutamine: RULE_AGREES
theorem pair_c30011_c18050 : Balanced [(-1, c18050), (1, c30011), (1, water)] := by decide
-- R1 · CHEBI:48097 D-glutamine residue from CHEBI:17061 D-glutamine: RULE_AGREES
theorem pair_c48097_c17061 : Balanced [(-1, c17061), (1, c48097), (1, water)] := by decide
-- R1 · CHEBI:32677 glutamine residue from CHEBI:28300 glutamine: RULE_AGREES
theorem pair_c32677_c28300 : Balanced [(-1, c28300), (1, c32677), (1, water)] := by decide
-- R1 · CHEBI:32664 asparagine residue from CHEBI:22653 asparagine: RULE_AGREES
theorem pair_c32664_c22653 : Balanced [(-1, c22653), (1, c32664), (1, water)] := by decide
-- R1 · CHEBI:50347 L-asparagine residue from CHEBI:17196 L-asparagine: RULE_AGREES
theorem pair_c50347_c17196 : Balanced [(-1, c17196), (1, c50347), (1, water)] := by decide
-- R1 · CHEBI:50349 D-asparagine residue from CHEBI:28159 D-asparagine: RULE_AGREES
theorem pair_c50349_c28159 : Balanced [(-1, c28159), (1, c50349), (1, water)] := by decide
-- R1 · CHEBI:16044 L-methionine residue from CHEBI:16643 L-methionine: RULE_AGREES
theorem pair_c16044_c16643 : Balanced [(-1, c16643), (1, c16044), (1, water)] := by decide
-- R1 · CHEBI:29984 D-methionine residue from CHEBI:16867 D-methionine: RULE_AGREES
theorem pair_c29984_c16867 : Balanced [(-1, c16867), (1, c29984), (1, water)] := by decide
-- R1 · CHEBI:32648 methionine residue from CHEBI:16811 methionine: RULE_AGREES
theorem pair_c32648_c16811 : Balanced [(-1, c16811), (1, c32648), (1, water)] := by decide
-- R1 · CHEBI:30018 D-proline residue from CHEBI:16313 D-proline: RULE_AGREES
theorem pair_c30018_c16313 : Balanced [(-1, c16313), (1, c30018), (1, water)] := by decide
-- R1 · CHEBI:50342 L-proline residue from CHEBI:17203 L-proline: RULE_AGREES
theorem pair_c50342_c17203 : Balanced [(-1, c17203), (1, c50342), (1, water)] := by decide
-- R1 · CHEBI:32874 proline residue from CHEBI:26271 proline: RULE_AGREES
theorem pair_c32874_c26271 : Balanced [(-1, c26271), (1, c32874), (1, water)] := by decide
-- R1 · CHEBI:30006 L-leucine residue from CHEBI:15603 L-leucine: RULE_AGREES
theorem pair_c30006_c15603 : Balanced [(-1, c15603), (1, c30006), (1, water)] := by decide
-- R1 · CHEBI:30005 D-leucine residue from CHEBI:28225 D-leucine: RULE_AGREES
theorem pair_c30005_c28225 : Balanced [(-1, c28225), (1, c30005), (1, water)] := by decide
-- R1 · CHEBI:32630 leucine residue from CHEBI:25017 leucine: RULE_AGREES
theorem pair_c32630_c25017 : Balanced [(-1, c25017), (1, c32630), (1, water)] := by decide
-- R1 · CHEBI:30009 L-isoleucine residue from CHEBI:17191 L-isoleucine: RULE_AGREES
theorem pair_c30009_c17191 : Balanced [(-1, c17191), (1, c30009), (1, water)] := by decide
-- R1 · CHEBI:30010 D-isoleucine residue from CHEBI:27730 D-isoleucine: RULE_AGREES
theorem pair_c30010_c27730 : Balanced [(-1, c27730), (1, c30010), (1, water)] := by decide
-- R1 · CHEBI:32615 isoleucine residue from CHEBI:24898 isoleucine: RULE_AGREES
theorem pair_c32615_c24898 : Balanced [(-1, c24898), (1, c32615), (1, water)] := by decide
-- R1 · CHEBI:30000 L-selenocysteine residue from CHEBI:16633 L-selenocysteine: RULE_AGREES
theorem pair_c30000_c16633 : Balanced [(-1, c16633), (1, c30000), (1, water)] := by decide
-- R1 · CHEBI:30002 D-selenocysteine residue from CHEBI:30001 D-selenocysteine: RULE_AGREES
theorem pair_c30002_c30001 : Balanced [(-1, c30001), (1, c30002), (1, water)] := by decide
-- R1 · CHEBI:32757 selenocysteine residue from CHEBI:9093 selenocysteine: RULE_AGREES
theorem pair_c32757_c9093 : Balanced [(-1, c9093), (1, c32757), (1, water)] := by decide
-- R1 · CHEBI:37629 desmosine residue from CHEBI:37628 desmosine: RULE_DIFFERS
theorem pair_c37629_c37628 : ¬ Balanced [(-1, c37628), (1, c37629), (1, water)] := by decide
-- R1 · CHEBI:29972 L-glutamic acid residue from CHEBI:16015 L-glutamic acid: RULE_AGREES
theorem pair_c29972_c16015 : Balanced [(-1, c16015), (1, c29972), (1, water)] := by decide
-- R1 · CHEBI:48096 D-glutamic acid residue from CHEBI:15966 D-glutamic acid: RULE_AGREES
theorem pair_c48096_c15966 : Balanced [(-1, c15966), (1, c48096), (1, water)] := by decide
-- R1 · CHEBI:44571 L-ornithine residue from CHEBI:15729 L-ornithine: RULE_AGREES
theorem pair_c44571_c15729 : Balanced [(-1, c15729), (1, c44571), (1, water)] := by decide
-- R1 · CHEBI:46928 ornithine residue from CHEBI:18257 ornithine: RULE_AGREES
theorem pair_c46928_c18257 : Balanced [(-1, c18257), (1, c46928), (1, water)] := by decide
-- R1 · CHEBI:40550 D-alpha-aminobutyric acid residue from CHEBI:28797 D-alpha-aminobutyric acid: RULE_AGREES
theorem pair_c40550_c28797 : Balanced [(-1, c28797), (1, c40550), (1, water)] := by decide
-- R1 · CHEBI:40545 L-alpha-aminobutyric acid residue from CHEBI:35619 L-alpha-aminobutyric acid: RULE_AGREES
theorem pair_c40545_c35619 : Balanced [(-1, c35619), (1, c40545), (1, water)] := by decide
-- R1 · CHEBI:16692 diphthamide residue from CHEBI:15949 diphthamide: RULE_AGREES
theorem pair_c16692_c15949 : Balanced [(-1, c15949), (1, c16692), (1, water)] := by decide
-- R1 · CHEBI:48230 diphthine residue from CHEBI:18054 diphthine: RULE_AGREES
theorem pair_c48230_c18054 : Balanced [(-1, c18054), (1, c48230), (1, water)] := by decide
-- R1 · CHEBI:41121 (3S)-3-hydroxy-L-aspartic acid residue from CHEBI:10696 (3S)-3-hydroxy-L-aspartic acid: RULE_AGREES
theorem pair_c41121_c10696 : Balanced [(-1, c10696), (1, c41121), (1, water)] := by decide
-- R2 · CHEBI:50300 thymidine 5'-monophosphate residue from CHEBI:17013 dTMP: RULE_DIFFERS_BY_HYDRONS
theorem pair_c50300_c17013 : ¬ Balanced [(-1, c17013), (1, c50300), (1, hydroxide)] ∧ Balanced ([(-1, c17013), (1, c50300), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R1 · CHEBI:45522 O-phospho-L-serine residue from CHEBI:15811 O-phospho-L-serine: RULE_AGREES
theorem pair_c45522_c15811 : Balanced [(-1, c15811), (1, c45522), (1, water)] := by decide
-- R1 · CHEBI:41834 L-2,4-diaminobutyric acid residue from CHEBI:48950 L-2,4-diaminobutyric acid: RULE_AGREES
theorem pair_c41834_c48950 : Balanced [(-1, c48950), (1, c41834), (1, water)] := by decide
-- R1 · CHEBI:41433 L-glutamic 5-semialdehyde residue from CHEBI:17232 L-glutamic 5-semialdehyde: RULE_AGREES
theorem pair_c41433_c17232 : Balanced [(-1, c17232), (1, c41433), (1, water)] := by decide
-- R1 · CHEBI:44120 L-methionine (S)-S-oxide residue from CHEBI:49031 L-methionine (S)-S-oxide: RULE_AGREES
theorem pair_c44120_c49031 : Balanced [(-1, c49031), (1, c44120), (1, water)] := by decide
-- R1 · CHEBI:45764 L-methionine (R)-S-oxide residue from CHEBI:49032 L-methionine (R)-S-oxide: RULE_AGREES
theorem pair_c45764_c49032 : Balanced [(-1, c49032), (1, c45764), (1, water)] := by decide
-- R1 · CHEBI:15989 L-methionine S-oxide residue from CHEBI:17016 L-methionine S-oxide: RULE_AGREES
theorem pair_c15989_c17016 : Balanced [(-1, c17016), (1, c15989), (1, water)] := by decide
-- R1 · CHEBI:49185 N(6)-carboxy-L-lysine residue from CHEBI:43575 N(6)-carboxy-L-lysine: RULE_AGREES
theorem pair_c49185_c43575 : Balanced [(-1, c43575), (1, c49185), (1, water)] := by decide
-- R1 · CHEBI:42155 3-amino-L-alanine residue from CHEBI:16303 3-amino-L-alanine: RULE_AGREES
theorem pair_c42155_c16303 : Balanced [(-1, c16303), (1, c42155), (1, water)] := by decide
-- R1 · CHEBI:50051 cystine residue from CHEBI:17376 cystine: RULE_DIFFERS
theorem pair_c50051_c17376 : ¬ Balanced [(-1, c17376), (1, c50051), (1, water)] := by decide
-- R1 · CHEBI:50058 L-cystine residue from CHEBI:16283 L-cystine: RULE_DIFFERS
theorem pair_c50058_c16283 : ¬ Balanced [(-1, c16283), (1, c50058), (1, water)] := by decide
-- R1 · CHEBI:50065 D-cystine residue from CHEBI:35494 D-cystine: RULE_DIFFERS
theorem pair_c50065_c35494 : ¬ Balanced [(-1, c35494), (1, c50065), (1, water)] := by decide
-- R1 · CHEBI:40599 2-aminoisobutyric acid residue from CHEBI:27971 2-aminoisobutyric acid: RULE_AGREES
theorem pair_c40599_c27971 : Balanced [(-1, c27971), (1, c40599), (1, water)] := by decide
-- R1 · CHEBI:30652 5-oxo-L-proline residue from CHEBI:18183 5-oxo-L-proline: RULE_AGREES
theorem pair_c30652_c18183 : Balanced [(-1, c18183), (1, c30652), (1, water)] := by decide
-- R2 · CHEBI:46470 uridine 5'-monophosphate residue from CHEBI:16695 uridine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c46470_c16695 : ¬ Balanced [(-1, c16695), (1, c46470), (1, hydroxide)] ∧ Balanced ([(-1, c16695), (1, c46470), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:50324 guanosine 5'-monophosphate residue from CHEBI:17345 guanosine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c50324_c17345 : ¬ Balanced [(-1, c17345), (1, c50324), (1, hydroxide)] ∧ Balanced ([(-1, c17345), (1, c50324), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:50306 adenosine 5'-monophosphate residue from CHEBI:16027 adenosine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c50306_c16027 : ¬ Balanced [(-1, c16027), (1, c50306), (1, hydroxide)] ∧ Balanced ([(-1, c16027), (1, c50306), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:50308 cytidine 5'-monophosphate residue from CHEBI:17361 cytidine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c50308_c17361 : ¬ Balanced [(-1, c17361), (1, c50308), (1, hydroxide)] ∧ Balanced ([(-1, c17361), (1, c50308), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:50321 2'-deoxycytidine 5'-monophosphate residue from CHEBI:15918 2'-deoxycytosine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c50321_c15918 : ¬ Balanced [(-1, c15918), (1, c50321), (1, hydroxide)] ∧ Balanced ([(-1, c15918), (1, c50321), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:50322 2'-deoxyguanosine 5'-monophosphate residue from CHEBI:16192 2'-deoxyguanosine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c50322_c16192 : ¬ Balanced [(-1, c16192), (1, c50322), (1, hydroxide)] ∧ Balanced ([(-1, c16192), (1, c50322), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:50323 2'-deoxyadenosine 5'-monophosphate residue from CHEBI:17713 2'-deoxyadenosine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c50323_c17713 : ¬ Balanced [(-1, c17713), (1, c50323), (1, hydroxide)] ∧ Balanced ([(-1, c17713), (1, c50323), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R1 · CHEBI:43903 N(pros)-methyl-L-histidine residue from CHEBI:27596 N(pros)-methyl-L-histidine: RULE_AGREES
theorem pair_c43903_c27596 : Balanced [(-1, c27596), (1, c43903), (1, water)] := by decide
-- R1 · CHEBI:16367 N(tele)-methyl-L-histidine residue from CHEBI:50599 N(tele)-methyl-L-histidine: RULE_AGREES
theorem pair_c16367_c50599 : Balanced [(-1, c50599), (1, c16367), (1, water)] := by decide
-- R1 · CHEBI:51448 cis-glycoluril residue from CHEBI:37083 cis-glycoluril: RULE_DIFFERS
theorem pair_c51448_c37083 : ¬ Balanced [(-1, c37083), (1, c51448), (1, water)] := by decide
-- R1 · CHEBI:51449 glycoluril residue from CHEBI:42946 glycoluril: RULE_DIFFERS
theorem pair_c51449_c42946 : ¬ Balanced [(-1, c42946), (1, c51449), (1, water)] := by decide
-- R1 · CHEBI:53015 N(6)-carboxymethyl-L-lysine residue from CHEBI:53014 N(6)-carboxymethyl-L-lysine: RULE_AGREES
theorem pair_c53015_c53014 : Balanced [(-1, c53014), (1, c53015), (1, water)] := by decide
-- R2 · CHEBI:53098 AMP 5'-end residue from CHEBI:16027 adenosine 5'-monophosphate: RULE_DIFFERS
theorem pair_c53098_c16027 : ¬ Balanced [(-1, c16027), (1, c53098), (1, hydroxide)] := by decide
-- R2 · CHEBI:53099 dAMP 5'-end residue from CHEBI:17713 2'-deoxyadenosine 5'-monophosphate: RULE_DIFFERS
theorem pair_c53099_c17713 : ¬ Balanced [(-1, c17713), (1, c53099), (1, hydroxide)] := by decide
-- R2 · CHEBI:53100 GMP 5'-end residue from CHEBI:17345 guanosine 5'-monophosphate: RULE_DIFFERS
theorem pair_c53100_c17345 : ¬ Balanced [(-1, c17345), (1, c53100), (1, hydroxide)] := by decide
-- R2 · CHEBI:53102 dTMP 5'-end residue from CHEBI:17013 dTMP: RULE_DIFFERS
theorem pair_c53102_c17013 : ¬ Balanced [(-1, c17013), (1, c53102), (1, hydroxide)] := by decide
-- R2 · CHEBI:53103 CMP 5'-end residue from CHEBI:17361 cytidine 5'-monophosphate: RULE_DIFFERS
theorem pair_c53103_c17361 : ¬ Balanced [(-1, c17361), (1, c53103), (1, hydroxide)] := by decide
-- R2 · CHEBI:53104 dCMP 5'-end residue from CHEBI:15918 2'-deoxycytosine 5'-monophosphate: RULE_DIFFERS
theorem pair_c53104_c15918 : ¬ Balanced [(-1, c15918), (1, c53104), (1, hydroxide)] := by decide
-- R2 · CHEBI:53105 UMP 5'-end residue from CHEBI:16695 uridine 5'-monophosphate: RULE_DIFFERS
theorem pair_c53105_c16695 : ¬ Balanced [(-1, c16695), (1, c53105), (1, hydroxide)] := by decide
-- R2 · CHEBI:53112 AMP 3'-end residue from CHEBI:16027 adenosine 5'-monophosphate: RULE_DIFFERS
theorem pair_c53112_c16027 : ¬ Balanced [(-1, c16027), (1, c53112), (1, hydroxide)] := by decide
-- R2 · CHEBI:53114 GMP 3'-end residue from CHEBI:17345 guanosine 5'-monophosphate: RULE_DIFFERS
theorem pair_c53114_c17345 : ¬ Balanced [(-1, c17345), (1, c53114), (1, hydroxide)] := by decide
-- R2 · CHEBI:53116 CMP 3'-end residue from CHEBI:17361 cytidine 5'-monophosphate: RULE_DIFFERS
theorem pair_c53116_c17361 : ¬ Balanced [(-1, c17361), (1, c53116), (1, hydroxide)] := by decide
-- R2 · CHEBI:53117 dGMP 3'-end residue from CHEBI:16192 2'-deoxyguanosine 5'-monophosphate: RULE_DIFFERS
theorem pair_c53117_c16192 : ¬ Balanced [(-1, c16192), (1, c53117), (1, hydroxide)] := by decide
-- R2 · CHEBI:53118 dTMP 3'-end residue from CHEBI:17013 dTMP: RULE_DIFFERS
theorem pair_c53118_c17013 : ¬ Balanced [(-1, c17013), (1, c53118), (1, hydroxide)] := by decide
-- R2 · CHEBI:53119 dCMP 3'-end residue from CHEBI:15918 2'-deoxycytosine 5'-monophosphate: RULE_DIFFERS
theorem pair_c53119_c15918 : ¬ Balanced [(-1, c15918), (1, c53119), (1, hydroxide)] := by decide
-- R2 · CHEBI:53120 UMP 3'-end residue from CHEBI:16695 uridine 5'-monophosphate: RULE_DIFFERS
theorem pair_c53120_c16695 : ¬ Balanced [(-1, c16695), (1, c53120), (1, hydroxide)] := by decide
-- R2 · CHEBI:53113 dAMP 3'-end residue from CHEBI:17713 2'-deoxyadenosine 5'-monophosphate: RULE_DIFFERS
theorem pair_c53113_c17713 : ¬ Balanced [(-1, c17713), (1, c53113), (1, hydroxide)] := by decide
-- R2 · CHEBI:53101 dGMP 5'-end residue from CHEBI:16192 2'-deoxyguanosine 5'-monophosphate: RULE_DIFFERS
theorem pair_c53101_c16192 : ¬ Balanced [(-1, c16192), (1, c53101), (1, hydroxide)] := by decide
-- R1 · CHEBI:53133 Se-methylselenocysteine residue from CHEBI:9068 Se-methylselenocysteine: RULE_AGREES
theorem pair_c53133_c9068 : Balanced [(-1, c9068), (1, c53133), (1, water)] := by decide
-- R1 · CHEBI:53134 Se-methyl-L-selenocysteine residue from CHEBI:27812 Se-methyl-L-selenocysteine: RULE_AGREES
theorem pair_c53134_c27812 : Balanced [(-1, c27812), (1, c53134), (1, water)] := by decide
-- R1 · CHEBI:53135 Se-methyl-D-selenocysteine residue from CHEBI:53125 Se-methyl-D-selenocysteine: RULE_AGREES
theorem pair_c53135_c53125 : Balanced [(-1, c53125), (1, c53135), (1, water)] := by decide
-- R1 · CHEBI:87075 O-(N-acetyl-alpha-D-galactosaminyl)-L-threonine residue from CHEBI:53609 O-(N-acetyl-alpha-D-galactosaminyl)-L-threonine: RULE_AGREES
theorem pair_c87075_c53609 : Balanced [(-1, c53609), (1, c87075), (1, water)] := by decide
-- R1 · CHEBI:53606 O-[N-acetyl-alpha-neuraminyl-(2->6)-N-acetyl-alpha-D-galactosaminyl]-L-serine residue from CHEBI:53610 O-[N-acetyl-alpha-neuraminyl-(2->6)-N-acetyl-alpha-D-galactosaminyl]-L-serine: RULE_DIFFERS
theorem pair_c53606_c53610 : ¬ Balanced [(-1, c53610), (1, c53606), (1, water)] := by decide
-- R1 · CHEBI:53607 O-[N-acetyl-alpha-neuraminyl-(2->6)-N-acetyl-alpha-D-galactosaminyl]-L-threonine residue from CHEBI:53611 O-[N-acetyl-alpha-neuraminyl-(2->6)-N-acetyl-alpha-D-galactosaminyl]-L-threonine: RULE_DIFFERS
theorem pair_c53607_c53611 : ¬ Balanced [(-1, c53611), (1, c53607), (1, water)] := by decide
-- R1 · CHEBI:61888 N-acetylglycine residue from CHEBI:40410 N-acetylglycine: RULE_AGREES
theorem pair_c61888_c40410 : Balanced [(-1, c40410), (1, c61888), (1, water)] := by decide
-- R1 · CHEBI:61896 N(omega),N(omega)-dimethyl-L-arginine residue from CHEBI:17929 N(omega),N(omega)-dimethyl-L-arginine: RULE_AGREES
theorem pair_c61896_c17929 : Balanced [(-1, c17929), (1, c61896), (1, water)] := by decide
-- R1 · CHEBI:61899 L-6'-bromotryptophan residue from CHEBI:47276 L-6'-bromotryptophan: RULE_DIFFERS
theorem pair_c61899_c47276 : ¬ Balanced [(-1, c47276), (1, c61899), (1, water)] := by decide
-- R1 · CHEBI:61916 N(omega),N'(omega)-dimethyl-L-argininyl residue from CHEBI:25682 N(omega),N'(omega)-dimethyl-L-arginine: RULE_AGREES
theorem pair_c61916_c25682 : Balanced [(-1, c25682), (1, c61916), (1, water)] := by decide
-- R1 · CHEBI:61920 N-acetyl-L-alanine residue from CHEBI:40992 N-acetyl-L-alanine: RULE_AGREES
theorem pair_c61920_c40992 : Balanced [(-1, c40992), (1, c61920), (1, water)] := by decide
-- R1 · CHEBI:61924 N-carboxy-L-methionine residue from CHEBI:41696 N-carboxy-L-methionine: RULE_AGREES
theorem pair_c61924_c41696 : Balanced [(-1, c41696), (1, c61924), (1, water)] := by decide
-- R1 · CHEBI:61928 N(6)-methyl-L-lysine residue from CHEBI:17604 N(6)-methyl-L-lysine: RULE_DIFFERS
theorem pair_c61928_c17604 : ¬ Balanced [(-1, c17604), (1, c61928), (1, water)] := by decide
-- R1 · CHEBI:61930 N(6)-acetyl-L-lysine residue from CHEBI:17752 N(6)-acetyl-L-lysine: RULE_AGREES
theorem pair_c61930_c17752 : Balanced [(-1, c17752), (1, c61930), (1, water)] := by decide
-- R1 · CHEBI:61939 gamma-carboxy-L-glutamic acid residue from CHEBI:41450 gamma-carboxy-L-glutamic acid: RULE_DIFFERS
theorem pair_c61939_c41450 : ¬ Balanced [(-1, c41450), (1, c61939), (1, water)] := by decide
-- R1 · CHEBI:61956 S-phospho-L-cysteine residue from CHEBI:22066 S-phospho-L-cysteine: RULE_AGREES
theorem pair_c61956_c22066 : Balanced [(-1, c22066), (1, c61956), (1, water)] := by decide
-- R1 · CHEBI:61960 N(4)-methyl-L-asparagine residue from CHEBI:44079 N(4)-methyl-L-asparagine: RULE_AGREES
theorem pair_c61960_c44079 : Balanced [(-1, c44079), (1, c61960), (1, water)] := by decide
-- R1 · CHEBI:61961 N(6),N(6),N(6)-trimethyl-L-lysine residue from CHEBI:17311 N(6),N(6),N(6)-trimethyl-L-lysine: RULE_AGREES
theorem pair_c61961_c17311 : Balanced [(-1, c17311), (1, c61961), (1, water)] := by decide
-- R1 · CHEBI:61962 S-oxy-L-cysteine residue from CHEBI:41630 S-oxy-L-cysteine: RULE_AGREES
theorem pair_c61962_c41630 : Balanced [(-1, c41630), (1, c61962), (1, water)] := by decide
-- R1 · CHEBI:61963 3-disulfanyl-L-alanine residue from CHEBI:28839 3-disulfanyl-L-alanine: RULE_AGREES
theorem pair_c61963_c28839 : Balanced [(-1, c28839), (1, c61963), (1, water)] := by decide
-- R1 · CHEBI:61964 L-cysteine-S-dioxide residue from CHEBI:41721 L-cysteine-S-dioxide: RULE_AGREES
theorem pair_c61964_c41721 : Balanced [(-1, c41721), (1, c61964), (1, water)] := by decide
-- R1 · CHEBI:61965 trans-4-hydroxy-L-proline residue from CHEBI:18095 trans-4-hydroxy-L-proline: RULE_AGREES
theorem pair_c61965_c18095 : Balanced [(-1, c18095), (1, c61965), (1, water)] := by decide
-- R1 · CHEBI:61967 3-sulfino-L-alanine residue from CHEBI:16345 3-sulfino-L-alanine: RULE_AGREES
theorem pair_c61967_c16345 : Balanced [(-1, c16345), (1, c61967), (1, water)] := by decide
-- R1 · CHEBI:61969 N(6),N(6)-dimethyl-L-lysine residue from CHEBI:43997 N(6),N(6)-dimethyl-L-lysine: RULE_AGREES
theorem pair_c61969_c43997 : Balanced [(-1, c43997), (1, c61969), (1, water)] := by decide
-- R1 · CHEBI:61971 O-phospho-L-threonine residue from CHEBI:37525 O-phospho-L-threonine: RULE_AGREES
theorem pair_c61971_c37525 : Balanced [(-1, c37525), (1, c61971), (1, water)] := by decide
-- R1 · CHEBI:61972 O(4)-phospho-L-tyrosine residue from CHEBI:37788 O(4)-phospho-L-tyrosine: RULE_AGREES
theorem pair_c61972_c37788 : Balanced [(-1, c37788), (1, c61972), (1, water)] := by decide
-- R1 · CHEBI:61973 S-hydroxy-L-cysteine residue from CHEBI:41710 S-hydroxy-L-cysteine: RULE_AGREES
theorem pair_c61973_c41710 : Balanced [(-1, c41710), (1, c61973), (1, water)] := by decide
-- R1 · CHEBI:61974 3-sulfino-L-alanine(1-) residue from CHEBI:61085 3-sulfino-L-alanine(1-): RULE_AGREES
theorem pair_c61974_c61085 : Balanced [(-1, c61085), (1, c61974), (1, water)] := by decide
-- R1 · CHEBI:61977 O-phosphonato-L-threonine(2-) residue from CHEBI:58675 O-phosphonato-L-threonine(2-): RULE_AGREES
theorem pair_c61977_c58675 : Balanced [(-1, c58675), (1, c61977), (1, water)] := by decide
-- R1 · CHEBI:61979 4-methyl-2-pyrroline-5-carboxylic acid residue from CHEBI:41149 4-methyl-2-pyrroline-5-carboxylic acid: RULE_AGREES
theorem pair_c61979_c41149 : Balanced [(-1, c41149), (1, c61979), (1, water)] := by decide
-- R1 · CHEBI:61980 3-selenino-L-alanine residue from CHEBI:28454 3-selenino-L-alanine: RULE_AGREES
theorem pair_c61980_c28454 : Balanced [(-1, c28454), (1, c61980), (1, water)] := by decide
-- R1 · CHEBI:62866 2-methylthio-N(6)-(Delta(2)-isopentenyl)adenosine residue from CHEBI:62875 2-methylthio-N(6)-(Delta(2)-isopentenyl)adenosine: RULE_AGREES
theorem pair_c62866_c62875 : Balanced [(-1, c62875), (1, c62866), (1, water)] := by decide
-- R1 · CHEBI:62836 2-methylthio-N(6)-(cis-4-hydroxy-Delta(2)-isopentenyl)adenosine residue from CHEBI:62879 2-methylthio-N(6)-(cis-4-hydroxy-Delta(2)-isopentenyl)adenosine: RULE_AGREES
theorem pair_c62836_c62879 : Balanced [(-1, c62879), (1, c62836), (1, water)] := by decide
-- R1 · CHEBI:62884 N(6)-(Delta(2)-isopentenyl)adenosine residue from CHEBI:62881 N(6)-(Delta(2)-isopentenyl)adenosine: RULE_AGREES
theorem pair_c62884_c62881 : Balanced [(-1, c62881), (1, c62884), (1, water)] := by decide
-- R1 · CHEBI:62885 adenosine residue from CHEBI:16335 adenosine: RULE_AGREES
theorem pair_c62885_c16335 : Balanced [(-1, c16335), (1, c62885), (1, water)] := by decide
-- R1 · CHEBI:61884 N-methyl-L-phenylalanine residue from CHEBI:43980 N-methyl-L-phenylalanine: RULE_AGREES
theorem pair_c61884_c43980 : Balanced [(-1, c43980), (1, c61884), (1, water)] := by decide
-- R1 · CHEBI:61891 N(5)-methyl-L-glutamine residue from CHEBI:17592 N(5)-methyl-L-glutamine: RULE_AGREES
theorem pair_c61891_c17592 : Balanced [(-1, c17592), (1, c61891), (1, water)] := by decide
-- R1 · CHEBI:64299 queuosine residue from CHEBI:60193 queuosine: RULE_AGREES
theorem pair_c64299_c60193 : Balanced [(-1, c60193), (1, c64299), (1, water)] := by decide
-- R1 · CHEBI:64300 epoxyqueuosine residue from CHEBI:63792 epoxyqueuosine: RULE_AGREES
theorem pair_c64300_c63792 : Balanced [(-1, c63792), (1, c64300), (1, water)] := by decide
-- R1 · CHEBI:64654 guanosine residue from CHEBI:16750 guanosine: RULE_AGREES
theorem pair_c64654_c16750 : Balanced [(-1, c16750), (1, c64654), (1, water)] := by decide
-- R1 · CHEBI:64655 2'-O-methylguanosine residue from CHEBI:19229 2'-O-methylguanosine: RULE_AGREES
theorem pair_c64655_c19229 : Balanced [(-1, c19229), (1, c64655), (1, water)] := by decide
-- R1 · CHEBI:64656 cytidine residue from CHEBI:17562 cytidine: RULE_AGREES
theorem pair_c64656_c17562 : Balanced [(-1, c17562), (1, c64656), (1, water)] := by decide
-- R1 · CHEBI:64657 2'-O-methylcytidine residue from CHEBI:19228 2'-O-methylcytidine: RULE_AGREES
theorem pair_c64657_c19228 : Balanced [(-1, c19228), (1, c64657), (1, water)] := by decide
-- R1 · CHEBI:64639 O-(alpha-D-mannose-1-phosphoryl)-L-serine residue from CHEBI:64679 O-(alpha-D-mannose-1-phosphoryl)-L-serine: RULE_AGREES
theorem pair_c64639_c64679 : Balanced [(-1, c64679), (1, c64639), (1, water)] := by decide
-- R1 · CHEBI:64640 hypusine residue from CHEBI:21858 hypusine: RULE_AGREES
theorem pair_c64640_c21858 : Balanced [(-1, c21858), (1, c64640), (1, water)] := by decide
-- R1 · CHEBI:64891 O-(pantetheine-4'-phosphoryl)serine residue from CHEBI:64896 O-(pantetheine-4'-phosphoryl)serine: RULE_AGREES
theorem pair_c64891_c64896 : Balanced [(-1, c64896), (1, c64891), (1, water)] := by decide
-- R1 · CHEBI:64936 N(pros)-phospho-L-histidine residue from CHEBI:64938 N(pros)-phospho-L-histidine: RULE_AGREES
theorem pair_c64936_c64938 : Balanced [(-1, c64938), (1, c64936), (1, water)] := by decide
-- R1 · CHEBI:65127 erythro-L-hydroxyallysine residue from CHEBI:65126 erythro-L-hydroxyallysine: RULE_DIFFERS
theorem pair_c65127_c65126 : ¬ Balanced [(-1, c65126), (1, c65127), (1, water)] := by decide
-- R1 · CHEBI:65237 L-homomethionine residue from CHEBI:50708 L-homomethionine: RULE_DIFFERS
theorem pair_c65237_c50708 : ¬ Balanced [(-1, c50708), (1, c65237), (1, water)] := by decide
-- R1 · CHEBI:65270 [4)-D-GlcpNS-(1->](1-) residue from CHEBI:57868 N-sulfo-D-glucosamine(1-): RULE_AGREES
theorem pair_c65270_c57868 : Balanced [(-1, c57868), (1, c65270), (1, water)] := by decide
-- R1 · CHEBI:65275 [4)-D-GlcpNS-(1->] residue from CHEBI:16702 N-sulfo-D-glucosamine: RULE_AGREES
theorem pair_c65275_c16702 : Balanced [(-1, c16702), (1, c65275), (1, water)] := by decide
-- R1 · CHEBI:65272 [4)-D-GlcpN-(1->] residue from CHEBI:47977 2-amino-2-deoxy-D-glucopyranose: RULE_AGREES
theorem pair_c65272_c47977 : Balanced [(-1, c47977), (1, c65272), (1, water)] := by decide
-- R1 · CHEBI:65271 [4)-D-GlcpN-(1->](1+) residue from CHEBI:58723 2-ammonio-2-deoxy-D-glucopyranose: RULE_DIFFERS
theorem pair_c65271_c58723 : ¬ Balanced [(-1, c58723), (1, c65271), (1, water)] := by decide
-- R1 · CHEBI:71250 N(6)-(glycylglycyl)-L-lysine residue from CHEBI:71254 N(6)-(glycylglycyl)-L-lysine: RULE_DIFFERS
theorem pair_c71250_c71254 : ¬ Balanced [(-1, c71254), (1, c71250), (1, water)] := by decide
-- R1 · CHEBI:73265 archaeosine residue from CHEBI:73271 archaeosine: RULE_AGREES
theorem pair_c73265_c73271 : Balanced [(-1, c73271), (1, c73265), (1, water)] := by decide
-- R1 · CHEBI:73547 2-thio-N(6)-(Delta(2)-isopentenyl)adenosine residue from CHEBI:73551 2-thio-N(6)-(Delta(2)-isopentenyl)adenosine: RULE_AGREES
theorem pair_c73547_c73551 : Balanced [(-1, c73551), (1, c73547), (1, water)] := by decide
-- R2 · CHEBI:73552 7-[(3S-amino)-3-carboxypropyl]wyosine 5'-monophosphate residue from CHEBI:73553 7-(3-amino-3-carboxypropyl)wyosine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c73552_c73553 : ¬ Balanced [(-1, c73553), (1, c73552), (1, hydroxide)] ∧ Balanced ([(-1, c73553), (1, c73552), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:73543 7-[(3S)-3-amino-3-carboxypropyl]wyosine 5'-monophosphate(1-) residue from CHEBI:73555 7-(3-amino-3-carboxypropyl)wyosine 5'-monophosphate zwitterion: RULE_DIFFERS
theorem pair_c73543_c73555 : ¬ Balanced [(-1, c73555), (1, c73543), (1, hydroxide)] := by decide
-- R2 · CHEBI:73556 4-demethyl-7-(3-amino-3-carboxypropyl)wyosine 5'-monophosphate residue from CHEBI:73557 4-demethyl-7-(3-amino-3-carboxypropyl)wyosine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c73556_c73557 : ¬ Balanced [(-1, c73557), (1, c73556), (1, hydroxide)] ∧ Balanced ([(-1, c73557), (1, c73556), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:73550 4-demethyl-7-(3-amino-3-carboxypropyl)wyosine 5'-monophosphate(1-) residue from CHEBI:73559 4-demethyl-7-(3-amino-3-carboxypropyl)wyosine 5'-monophosphate zwitterion: RULE_DIFFERS_BY_HYDRONS
theorem pair_c73550_c73559 : ¬ Balanced [(-1, c73559), (1, c73550), (1, hydroxide)] ∧ Balanced ([(-1, c73559), (1, c73550), (1, hydroxide)] ++ [(2, hydron)]) := by decide
-- R1 · CHEBI:73599 3-methylthioaspartate residue from CHEBI:73620 3-methylthioaspartate(1-): RULE_AGREES
theorem pair_c73599_c73620 : Balanced [(-1, c73620), (1, c73599), (1, water)] := by decide
-- R1 · CHEBI:73619 3-methylthioaspartic acid residue from CHEBI:73621 3-methylthioaspartic acid: RULE_AGREES
theorem pair_c73619_c73621 : Balanced [(-1, c73621), (1, c73619), (1, water)] := by decide
-- R2 · CHEBI:73624 7-(2-hydroxy-3-amino-3-carboxypropyl)wyosine 5'-monophosphate residue from CHEBI:73625 7-(2-hydroxy-3-amino-3-carboxypropyl)wyosine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c73624_c73625 : ¬ Balanced [(-1, c73625), (1, c73624), (1, hydroxide)] ∧ Balanced ([(-1, c73625), (1, c73624), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:73603 7-(2-hydroxy-3-amino-3-carboxypropyl)wyosine 5'-monophosphate(1-) residue from CHEBI:73626 7-(2-hydroxy-3-amino-3-carboxypropyl)wyosine 5'-monophosphate zwitterion: RULE_DIFFERS
theorem pair_c73603_c73626 : ¬ Balanced [(-1, c73626), (1, c73603), (1, hydroxide)] := by decide
-- R1 · CHEBI:20252 cysteine tryptophylquinone residue from CHEBI:73670 cysteine tryptophylquinone: RULE_DIFFERS
theorem pair_c20252_c73670 : ¬ Balanced [(-1, c73670), (1, c20252), (1, water)] := by decide
-- R1 · CHEBI:73743 2-(3-amino-3-carboxypropyl)-L-histidine zwitterion residue from CHEBI:58031 2-(3-amino-3-carboxypropyl)-L-histidine dizwitterion: RULE_AGREES
theorem pair_c73743_c58031 : Balanced [(-1, c58031), (1, c73743), (1, water)] := by decide
-- R1 · CHEBI:73744 2-[3-carboxylato-3-(methylammonio)propyl]-L-histidine residue from CHEBI:57784 2-[3-carboxylato-3-(methylammonio)propyl]-L-histidine dizwitterion: RULE_AGREES
theorem pair_c73744_c57784 : Balanced [(-1, c57784), (1, c73744), (1, water)] := by decide
-- R1 · CHEBI:73745 2-[3-carboxylato-3-(dimethylammonio)propyl]-L-histidine residue from CHEBI:73763 2-[3-carboxylato-3-(dimethylammonio)propyl]-L-histidine dizwitterion: RULE_AGREES
theorem pair_c73745_c73763 : Balanced [(-1, c73763), (1, c73745), (1, water)] := by decide
-- R1 · CHEBI:73746 2-[3-carboxylato-3-(trimethylammonio)propyl]-L-histidine residue from CHEBI:73766 2-[3-carboxylato-3-(trimethylammonio)propyl]-L-histidine: RULE_AGREES
theorem pair_c73746_c73766 : Balanced [(-1, c73766), (1, c73746), (1, water)] := by decide
-- R1 · CHEBI:73747 uridine residue from CHEBI:16704 uridine: RULE_AGREES
theorem pair_c73747_c16704 : Balanced [(-1, c16704), (1, c73747), (1, water)] := by decide
-- R1 · CHEBI:73767 5-aminomethyl-2-thiouridine residue from CHEBI:73768 5-aminomethyl-2-thiouridine: RULE_DIFFERS
theorem pair_c73767_c73768 : ¬ Balanced [(-1, c73768), (1, c73767), (1, water)] := by decide
-- R1 · CHEBI:73748 5-aminomethyl-2-thiouridine residue(1+) from CHEBI:73769 5-aminomethyl-2-thiouridine(1+): RULE_AGREES
theorem pair_c73748_c73769 : Balanced [(-1, c73769), (1, c73748), (1, water)] := by decide
-- R1 · CHEBI:73995 2-[(3S)-3-amino-3-carboxypropyl]-L-histidine zwitterion residue from CHEBI:74042 2-[(3S)-3-amino-3-carboxypropyl]-L-histidine dizwitterion: RULE_AGREES
theorem pair_c73995_c74042 : Balanced [(-1, c74042), (1, c73995), (1, water)] := by decide
-- R1 · CHEBI:20489 5'-(N(6)-L-lysine)-L-tyrosylquinone residue from CHEBI:73669 5'-(N(6)-L-lysine)-L-tyrosylquinone: RULE_DIFFERS
theorem pair_c20489_c73669 : ¬ Balanced [(-1, c73669), (1, c20489), (1, water)] := by decide
-- R1 · CHEBI:74151 S-palmitoyl-L-cysteine residue from CHEBI:22065 S-palmitoyl-L-cysteine: RULE_AGREES
theorem pair_c74151_c22065 : Balanced [(-1, c22065), (1, c74151), (1, water)] := by decide
-- R2 · CHEBI:74267 N(1)-methylguanosine 5'-monophosphate residue from CHEBI:74268 N(1)-methylguanosine 5'-monophosphate: RULE_DIFFERS
theorem pair_c74267_c74268 : ¬ Balanced [(-1, c74268), (1, c74267), (1, hydroxide)] := by decide
-- R2 · CHEBI:74271 4-demethylwyosine 5'-monophosphate residue from CHEBI:74273 4-demethylwyosine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74271_c74273 : ¬ Balanced [(-1, c74273), (1, c74271), (1, hydroxide)] ∧ Balanced ([(-1, c74273), (1, c74271), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74301 wybutosine 5'-monophosphate residue from CHEBI:74300 wybutosine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74301_c74300 : ¬ Balanced [(-1, c74300), (1, c74301), (1, hydroxide)] ∧ Balanced ([(-1, c74300), (1, c74301), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74302 beta-hydroxywybutosine 5'-monophosphate residue from CHEBI:73622 beta-hydroxywybutosine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74302_c73622 : ¬ Balanced [(-1, c73622), (1, c74302), (1, hydroxide)] ∧ Balanced ([(-1, c73622), (1, c74302), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R1 · CHEBI:74346 FMN-L-threonine residue from CHEBI:74347 FMN-L-threonine: RULE_AGREES
theorem pair_c74346_c74347 : Balanced [(-1, c74347), (1, c74346), (1, water)] := by decide
-- R1 · CHEBI:74444 7-[(3S)-(3-amino-3-methoxycarbonyl)propyl]wyosine 5'-phosphate residue from CHEBI:74446 7-[(3S)-(3-amino-3-methoxycarbonyl)propyl]wyosine 5'-phosphate: RULE_AGREES
theorem pair_c74444_c74446 : Balanced [(-1, c74446), (1, c74444), (1, water)] := by decide
-- R2 · CHEBI:74636 N(6)-L-threonylcarbamoyladenine 5'-monophosphate residue from CHEBI:74637 N(6)-L-threonylcarbamoyladenine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74636_c74637 : ¬ Balanced [(-1, c74637), (1, c74636), (1, hydroxide)] ∧ Balanced ([(-1, c74637), (1, c74636), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74638 N(6)-dimethylallyladenine 5'-monophosphate residue from CHEBI:15819 N(6)-(dimethylallyl)adenosine 5'-monophosphate: RULE_DIFFERS
theorem pair_c74638_c15819 : ¬ Balanced [(-1, c15819), (1, c74638), (1, hydroxide)] := by decide
-- R2 · CHEBI:74642 2-thio-N(6)-dimethylallyladenine 5'-monophosphate residue from CHEBI:74643 2-thio-N(6)-dimethylallyladenine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74642_c74643 : ¬ Balanced [(-1, c74643), (1, c74642), (1, hydroxide)] ∧ Balanced ([(-1, c74643), (1, c74642), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74645 2-methylthio-N(6)-dimethylallyladenine 5'-monophosphate residue from CHEBI:74646 2-methylthio-N(6)-dimethylallyladenine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74645_c74646 : ¬ Balanced [(-1, c74646), (1, c74645), (1, hydroxide)] ∧ Balanced ([(-1, c74646), (1, c74645), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74648 2-thio-N(6)-L-threonylcarbamoyladenine 5'-monophosphate residue from CHEBI:74649 2-thio-N(6)-L-threonylcarbamoyladenine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74648_c74649 : ¬ Balanced [(-1, c74649), (1, c74648), (1, hydroxide)] ∧ Balanced ([(-1, c74649), (1, c74648), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R1 · CHEBI:74652 3-thio-L-aspartic acid residue from CHEBI:74653 3-thio-L-aspartic acid: RULE_AGREES
theorem pair_c74652_c74653 : Balanced [(-1, c74653), (1, c74652), (1, water)] := by decide
-- R2 · CHEBI:74672 5,6-dihydrouridine 5'-monophosphate residue from CHEBI:74673 5,6-dihydrouridine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74672_c74673 : ¬ Balanced [(-1, c74673), (1, c74672), (1, hydroxide)] ∧ Balanced ([(-1, c74673), (1, c74672), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74674 2'-O-methylguanosine 5'-monophosphate residue from CHEBI:44638 2'-O-methylguanosine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74674_c44638 : ¬ Balanced [(-1, c44638), (1, c74674), (1, hydroxide)] ∧ Balanced ([(-1, c44638), (1, c74674), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74676 N(6)-methyladenosine 5'-monophosphate residue from CHEBI:40196 N(6)-methyl-AMP: RULE_DIFFERS
theorem pair_c74676_c40196 : ¬ Balanced [(-1, c40196), (1, c74676), (1, hydroxide)] := by decide
-- R2 · CHEBI:74677 5-aminomethyl-2-thiouridine 5'-monophosphate residue from CHEBI:74678 5-aminomethyl-2-thiouridine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74677_c74678 : ¬ Balanced [(-1, c74678), (1, c74677), (1, hydroxide)] ∧ Balanced ([(-1, c74678), (1, c74677), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74679 5-methylaminomethyl-2-thiouridine 5'-monophosphate residue from CHEBI:74680 5-methylaminomethyl-2-thiouridine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74679_c74680 : ¬ Balanced [(-1, c74680), (1, c74679), (1, hydroxide)] ∧ Balanced ([(-1, c74680), (1, c74679), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74681 2'-O-methyladenosine 5'-monophosphate residue from CHEBI:40460 2'-O-methyladenosine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74681_c40460 : ¬ Balanced [(-1, c40460), (1, c74681), (1, hydroxide)] ∧ Balanced ([(-1, c40460), (1, c74681), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74685 2'-O-methyluridine 5'-monophosphate residue from CHEBI:44642 2'-O-methyluridine 5'-monophosphate: RULE_DIFFERS
theorem pair_c74685_c44642 : ¬ Balanced [(-1, c44642), (1, c74685), (1, hydroxide)] := by decide
-- R1 · CHEBI:74480 N(7)-methylguanosine 5'-phosphate zwitterion residue from CHEBI:74720 N(7)-methylguanosine 5'-phosphate: RULE_AGREES
theorem pair_c74480_c74720 : Balanced [(-1, c74720), (1, c74480), (1, water)] := by decide
-- R2 · CHEBI:74721 N(2)-methylguanosine 5'-monophosphate residue from CHEBI:74722 N(2)-methylguanosine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74721_c74722 : ¬ Balanced [(-1, c74722), (1, c74721), (1, hydroxide)] ∧ Balanced ([(-1, c74722), (1, c74721), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74724 5-methylcytidine 5'-monophosphate residue from CHEBI:74725 5-methylcytidine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74724_c74725 : ¬ Balanced [(-1, c74725), (1, c74724), (1, hydroxide)] ∧ Balanced ([(-1, c74725), (1, c74724), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74730 N(3)-methylpseudouridine 5'-monophosphate residue from CHEBI:74731 N(3)-methylpseudouridine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74730_c74731 : ¬ Balanced [(-1, c74731), (1, c74730), (1, hydroxide)] ∧ Balanced ([(-1, c74731), (1, c74730), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74735 N(1)-methyladenosine 5'-monophosphate residue from CHEBI:74736 N(1)-methyladenosine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74735_c74736 : ¬ Balanced [(-1, c74736), (1, c74735), (1, hydroxide)] ∧ Balanced ([(-1, c74736), (1, c74735), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74744 N(6),N(6)-dimethyladenosine 5'-monophosphate residue from CHEBI:43986 N(6),N(6)-dimethyl-AMP: RULE_DIFFERS
theorem pair_c74744_c43986 : ¬ Balanced [(-1, c43986), (1, c74744), (1, hydroxide)] := by decide
-- R2 · CHEBI:74748 2'-O-methylcytidine 5'-monophosphate residue from CHEBI:44666 2'-O-methylcytidine 5'-monophosphate: RULE_DIFFERS
theorem pair_c74748_c44666 : ¬ Balanced [(-1, c44666), (1, c74748), (1, hydroxide)] := by decide
-- R2 · CHEBI:74769 2-methyladenosine 5'-monophosphate residue from CHEBI:74770 2-methyladenosine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74769_c74770 : ¬ Balanced [(-1, c74770), (1, c74769), (1, hydroxide)] ∧ Balanced ([(-1, c74770), (1, c74769), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74771 N(3)-methyluridine 5'-monophosphate residue from CHEBI:74773 N(3)-methyluridine 5'-monophosphate: RULE_DIFFERS
theorem pair_c74771_c74773 : ¬ Balanced [(-1, c74773), (1, c74771), (1, hydroxide)] := by decide
-- R2 · CHEBI:74777 N(4)-methylcytidine 5'-monophosphate residue from CHEBI:74778 N(4)-methylcytidine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74777_c74778 : ¬ Balanced [(-1, c74778), (1, c74777), (1, hydroxide)] ∧ Balanced ([(-1, c74778), (1, c74777), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74781 5-carboxymethylaminomethyluridine 5'-monophosphate residue from CHEBI:74782 5-carboxymethylaminomethyluridine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74781_c74782 : ¬ Balanced [(-1, c74782), (1, c74781), (1, hydroxide)] ∧ Balanced ([(-1, c74782), (1, c74781), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74784 5-carboxymethylaminomethyl-2'-O-methyluridine 5'-monophosphate residue from CHEBI:74785 5-carboxymethylaminomethyl-2'-O-methyluridine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74784_c74785 : ¬ Balanced [(-1, c74785), (1, c74784), (1, hydroxide)] ∧ Balanced ([(-1, c74785), (1, c74784), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74786 N(2),N(2)-dimethylguanosine 5'-monophosphate residue from CHEBI:43967 N(2),N(2)-dimethylguanosine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74786_c43967 : ¬ Balanced [(-1, c43967), (1, c74786), (1, hydroxide)] ∧ Balanced ([(-1, c43967), (1, c74786), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:74787 8-methyladenosine 5'-monophosphate residue from CHEBI:74788 8-methyladenosine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c74787_c74788 : ¬ Balanced [(-1, c74788), (1, c74787), (1, hydroxide)] ∧ Balanced ([(-1, c74788), (1, c74787), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R1 · CHEBI:65320 pseudouridine 5'-phosphate residue from CHEBI:18116 pseudouridine 5'-phosphate: RULE_DIFFERS
theorem pair_c65320_c18116 : ¬ Balanced [(-1, c18116), (1, c65320), (1, water)] := by decide
-- R2 · CHEBI:75077 N(1)-methylpseudouridine 5'-monophosphate residue from CHEBI:75078 N(1)-methylpseudouridine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c75077_c75078 : ¬ Balanced [(-1, c75078), (1, c75077), (1, hydroxide)] ∧ Balanced ([(-1, c75078), (1, c75077), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:75079 N(3)-methylcytidine 5'-monophosphate residue from CHEBI:75083 N(3)-methylcytidine 5'-monophosphate: RULE_DIFFERS
theorem pair_c75079_c75083 : ¬ Balanced [(-1, c75083), (1, c75079), (1, hydroxide)] := by decide
-- R2 · CHEBI:75649 5-(2-methoxy-2-oxoethyl)uridine 5'-monophosphate residue from CHEBI:75650 5-(2-methoxy-2-oxoethyl)uridine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c75649_c75650 : ¬ Balanced [(-1, c75650), (1, c75649), (1, hydroxide)] ∧ Balanced ([(-1, c75650), (1, c75649), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:75658 5-(carboxymethyl)uridine 5'-monophosphate residue from CHEBI:75657 5-(carboxymethyl)uridine 5'-monophosphate: RULE_DIFFERS
theorem pair_c75658_c75657 : ¬ Balanced [(-1, c75657), (1, c75658), (1, hydroxide)] := by decide
-- R2 · CHEBI:75714 dUMP residue from CHEBI:17622 dUMP: RULE_DIFFERS_BY_HYDRONS
theorem pair_c75714_c17622 : ¬ Balanced [(-1, c17622), (1, c75714), (1, hydroxide)] ∧ Balanced ([(-1, c17622), (1, c75714), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:75716 dUMP 5'-end residue from CHEBI:17622 dUMP: RULE_DIFFERS
theorem pair_c75716_c17622 : ¬ Balanced [(-1, c17622), (1, c75716), (1, hydroxide)] := by decide
-- R2 · CHEBI:75715 dUMP 3'-end residue from CHEBI:17622 dUMP: RULE_DIFFERS
theorem pair_c75715_c17622 : ¬ Balanced [(-1, c17622), (1, c75715), (1, hydroxide)] := by decide
-- R1 · CHEBI:76241 O-(S-acylpantetheine-4'-phosphoryl)serine residue from CHEBI:76242 O-(S-acylpantetheine-4'-phosphoryl)serine: RULE_AGREES
theorem pair_c76241_c76242 : Balanced [(-1, c76242), (1, c76241), (1, water)] := by decide
-- R2 · CHEBI:76778 IMP residue from CHEBI:17202 IMP: RULE_DIFFERS_BY_HYDRONS
theorem pair_c76778_c17202 : ¬ Balanced [(-1, c17202), (1, c76778), (1, hydroxide)] ∧ Balanced ([(-1, c17202), (1, c76778), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:82748 cytidine 5'-monophosphate(1-) residue from CHEBI:60377 cytidine 5'-monophosphate(2-): RULE_AGREES
theorem pair_c82748_c60377 : Balanced [(-1, c60377), (1, c82748), (1, hydroxide)] := by decide
-- R1 · CHEBI:61978 O(4)-phosphonato-L-tyrosine(2-) residue from CHEBI:62338 O(4)-phosphonato-L-tyrosine(2-): RULE_AGREES
theorem pair_c61978_c62338 : Balanced [(-1, c62338), (1, c61978), (1, water)] := by decide
-- R1 · CHEBI:82696 diphthine betaine residue from CHEBI:18054 diphthine: RULE_DIFFERS_BY_HYDRONS
theorem pair_c82696_c18054 : ¬ Balanced [(-1, c18054), (1, c82696), (1, water)] ∧ Balanced ([(-1, c18054), (1, c82696), (1, water)] ++ [(1, hydron)]) := by decide
-- R1 · CHEBI:83397 L-citrulline residue from CHEBI:16349 L-citrulline: RULE_AGREES
theorem pair_c83397_c16349 : Balanced [(-1, c16349), (1, c83397), (1, water)] := by decide
-- R2 · CHEBI:83664 lysine monophosphate residue from CHEBI:83661 lysidine monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c83664_c83661 : ¬ Balanced [(-1, c83661), (1, c83664), (1, hydroxide)] ∧ Balanced ([(-1, c83661), (1, c83664), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R2 · CHEBI:83665 lysidine monophosphate zwitterion residue from CHEBI:83662 lysidine monophosphate(1-): RULE_AGREES
theorem pair_c83665_c83662 : Balanced [(-1, c83662), (1, c83665), (1, hydroxide)] := by decide
-- R1 · CHEBI:83683 N-terminal N-acetyl-L-alanine residue from CHEBI:40992 N-acetyl-L-alanine: RULE_DIFFERS
theorem pair_c83683_c40992 : ¬ Balanced [(-1, c40992), (1, c83683), (1, water)] := by decide
-- R1 · CHEBI:83690 N-terminal N-acetyl-L-serine residue from CHEBI:45441 N-acetyl-L-serine: RULE_DIFFERS
theorem pair_c83690_c45441 : ¬ Balanced [(-1, c45441), (1, c83690), (1, water)] := by decide
-- R2 · CHEBI:83151 glycyl-AMP(1-) residue from CHEBI:64846 glycyl-AMP(1-): RULE_DIFFERS
theorem pair_c83151_c64846 : ¬ Balanced [(-1, c64846), (1, c83151), (1, hydroxide)] := by decide
-- R1 · CHEBI:83226 N(omega)-phospho-L-arginine(1-) residue from CHEBI:58477 N(omega)-phosphonato-L-arginine: RULE_AGREES
theorem pair_c83226_c58477 : Balanced [(-1, c58477), (1, c83226), (1, water)] := by decide
-- R1 · CHEBI:83421 O-phospho-L-serine(2-) residue from CHEBI:57524 O-phosphonato-L-serine(2-): RULE_AGREES
theorem pair_c83421_c57524 : Balanced [(-1, c57524), (1, c83421), (1, water)] := by decide
-- R1 · CHEBI:85428 trans-3-hydroxy-L-proline residue from CHEBI:16889 trans-3-hydroxy-L-proline: RULE_AGREES
theorem pair_c85428_c16889 : Balanced [(-1, c16889), (1, c85428), (1, water)] := by decide
-- R2 · CHEBI:85445 2'-deoxyguanosine 5'-monophosphate(1-) residue from CHEBI:57673 2'-deoxyguanosine 5'-monophosphate(2-): RULE_AGREES
theorem pair_c85445_c57673 : Balanced [(-1, c57673), (1, c85445), (1, hydroxide)] := by decide
-- R1 · CHEBI:85467 [4)-alpha-D-Glcp-(1->4)-alpha-D-Glcp-(1->4)-alpha-D-Glcp-(1->] residue from CHEBI:27931 alpha-maltotriose: RULE_AGREES
theorem pair_c85467_c27931 : Balanced [(-1, c27931), (1, c85467), (1, water)] := by decide
-- R2 · CHEBI:85452 2'-deoxycytidine 5'-monophosphate(1-) residue from CHEBI:57566 2'-deoxycytosine 5'-monophosphate(2-): RULE_AGREES
theorem pair_c85452_c57566 : Balanced [(-1, c57566), (1, c85452), (1, hydroxide)] := by decide
-- R1 · CHEBI:86019 S-[(2E,6E)-farnesyl]-L-cysteine residue from CHEBI:62197 S-[(2E,6E)-farnesyl]-L-cysteine: RULE_AGREES
theorem pair_c86019_c62197 : Balanced [(-1, c62197), (1, c86019), (1, water)] := by decide
-- R1 · CHEBI:86021 S-geranylgeranyl-L-cysteine residue from CHEBI:22046 S-geranylgeranyl-L-cysteine: RULE_AGREES
theorem pair_c86021_c22046 : Balanced [(-1, c22046), (1, c86021), (1, water)] := by decide
-- R1 · CHEBI:87215 N-terminal 5-oxo-L-proline residue from CHEBI:18183 5-oxo-L-proline: RULE_DIFFERS
theorem pair_c87215_c18183 : ¬ Balanced [(-1, c18183), (1, c87215), (1, water)] := by decide
-- R1 · CHEBI:53604 O-(N-acetyl-alpha-D-galactosaminyl)-L-serine residue from CHEBI:53608 O-(N-acetyl-alpha-D-galactosaminyl)-L-serine: RULE_AGREES
theorem pair_c53604_c53608 : Balanced [(-1, c53608), (1, c53604), (1, water)] := by decide
-- R1 · CHEBI:87079 N-acetyl-beta-D-glucosaminyl-(1->3)-N-acetyl-alpha-D-galactosaminyl-L-serine residue from CHEBI:87260 O-[N-acetyl-beta-D-glucosaminyl-(1->3)-N-acetyl-alpha-D-galactosaminyl]-L-serine: RULE_AGREES
theorem pair_c87079_c87260 : Balanced [(-1, c87260), (1, c87079), (1, water)] := by decide
-- R1 · CHEBI:87169 S-sulfo-L-cysteine(1-) residue from CHEBI:62225 S-sulfo-L-cysteinate(1-): RULE_AGREES
theorem pair_c87169_c62225 : Balanced [(-1, c62225), (1, c87169), (1, water)] := by decide
-- R1 · CHEBI:90516 L-leucinate residue from CHEBI:32619 L-leucinate: RULE_DIFFERS
theorem pair_c90516_c32619 : ¬ Balanced [(-1, c32619), (1, c90516), (1, water)] := by decide
-- R1 · CHEBI:90511 S-[(2E,6E)-farnesyl]-L-cysteine methyl ester residue from CHEBI:87167 S-[(2E,6E)-farnesyl]-L-cysteine methyl ester: RULE_DIFFERS
theorem pair_c90511_c87167 : ¬ Balanced [(-1, c87167), (1, c90511), (1, water)] := by decide
-- R1 · CHEBI:90510 S-[(2E,6E)-farnesyl]-L-cysteinate residue from CHEBI:62141 S-[(2E,6E)-farnesyl]-L-cysteine zwitterion: RULE_DIFFERS
theorem pair_c90510_c62141 : ¬ Balanced [(-1, c62141), (1, c90510), (1, water)] := by decide
-- R2 · CHEBI:90615 2'-deoxyadenosine 5'-monophosphate(1-) residue from CHEBI:58245 2'-deoxyadenosine 5'-monophosphate(2-): RULE_AGREES
theorem pair_c90615_c58245 : Balanced [(-1, c58245), (1, c90615), (1, hydroxide)] := by decide
-- R1 · CHEBI:90840 O-(N-acetyl-beta-D-glucosaminyl)-L-threonine residue from CHEBI:90839 3-O-(N-acetyl-beta-D-glucosaminyl)-L-threonine: RULE_AGREES
theorem pair_c90840_c90839 : Balanced [(-1, c90839), (1, c90840), (1, water)] := by decide
-- R1 · CHEBI:90838 O-(N-acetyl-beta-D-glucosaminyl)-L-serine residue from CHEBI:90837 3-O-(N-acetyl-beta-D-glucosaminyl)-L-serine: RULE_AGREES
theorem pair_c90838_c90837 : Balanced [(-1, c90837), (1, c90838), (1, water)] := by decide
-- R1 · CHEBI:90860 4-hydroxy-L-proline residue from CHEBI:18240 4-hydroxy-L-proline: RULE_AGREES
theorem pair_c90860_c18240 : Balanced [(-1, c18240), (1, c90860), (1, water)] := by decide
-- R1 · CHEBI:90871 3,5-diiodo-L-tyrosine residue from CHEBI:15768 3,5-diiodo-L-tyrosine: RULE_AGREES
theorem pair_c90871_c15768 : Balanced [(-1, c15768), (1, c90871), (1, water)] := by decide
-- R1 · CHEBI:90870 3-iodo-L-tyrosine residue from CHEBI:27847 3-iodo-L-tyrosine: RULE_AGREES
theorem pair_c90870_c27847 : Balanced [(-1, c27847), (1, c90870), (1, water)] := by decide
-- R1 · CHEBI:90872 L-thyroxine residue from CHEBI:18332 L-thyroxine: RULE_AGREES
theorem pair_c90872_c18332 : Balanced [(-1, c18332), (1, c90872), (1, water)] := by decide
-- R1 · CHEBI:90874 3,3',5-triiodo-L-thyronine residue from CHEBI:18258 3,3',5-triiodo-L-thyronine: RULE_AGREES
theorem pair_c90874_c18258 : Balanced [(-1, c18258), (1, c90874), (1, water)] := by decide
-- R1 · CHEBI:90873 dehydroalanine residue from CHEBI:17123 2-aminoacrylic acid: RULE_AGREES
theorem pair_c90873_c17123 : Balanced [(-1, c17123), (1, c90873), (1, water)] := by decide
-- R1 · CHEBI:91176 deoxyhypusine residue from CHEBI:50038 deoxyhypusine: RULE_AGREES
theorem pair_c91176_c50038 : Balanced [(-1, c50038), (1, c91176), (1, water)] := by decide
-- R2 · CHEBI:61265 (beta-D-glucopyranosyloxymethyl)deoxyuridine 5'-monophosphate residue from CHEBI:111511 (beta-D-glucopyranosyloxymethyl)deoxyuridine 5'-monophosphate: RULE_DIFFERS_BY_HYDRONS
theorem pair_c61265_c111511 : ¬ Balanced [(-1, c111511), (1, c61265), (1, hydroxide)] ∧ Balanced ([(-1, c111511), (1, c61265), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R1 · CHEBI:111516 (beta-D-glucopyranosyloxymethyl)deoxyuridine residue from CHEBI:111513 (beta-D-glucopyranosyloxymethyl)deoxyuridine: RULE_AGREES
theorem pair_c111516_c111513 : Balanced [(-1, c111513), (1, c111516), (1, water)] := by decide
-- R1 · CHEBI:131624 N(6)-(2-carboxyethyl)-L-lysine residue from CHEBI:131623 N(6)-(2-carboxyethyl)-L-lysine: RULE_DIFFERS
theorem pair_c131624_c131623 : ¬ Balanced [(-1, c131623), (1, c131624), (1, water)] := by decide
-- R1 · CHEBI:131803 L-allysine residue from CHEBI:17917 L-allysine: RULE_AGREES
theorem pair_c131803_c17917 : Balanced [(-1, c17917), (1, c131803), (1, water)] := by decide
-- R2 · CHEBI:133902 dUMP residue(1-) from CHEBI:246422 dUMP(2-): RULE_AGREES
theorem pair_c133902_c246422 : Balanced [(-1, c246422), (1, c133902), (1, hydroxide)] := by decide
-- R1 · CHEBI:133304 S-anthraniloyl-L-cysteine residue from CHEBI:134405 S-anthraniloyl-L-cysteine: RULE_AGREES
theorem pair_c133304_c134405 : Balanced [(-1, c134405), (1, c133304), (1, water)] := by decide
-- R1 · CHEBI:133358 N(alpha)-acetyl-L-methionyl-L-asparaginyl residue from CHEBI:134409 N(alpha)-acetyl-L-methionyl-L-asparagine: RULE_DIFFERS
theorem pair_c133358_c134409 : ¬ Balanced [(-1, c134409), (1, c133358), (1, water)] := by decide
-- R1 · CHEBI:133362 N-acetyl-L-methionyl-L-glutaminyl residue from CHEBI:134471 N-acetyl-L-methionyl-L-glutamine: RULE_DIFFERS
theorem pair_c133362_c134471 : ¬ Balanced [(-1, c134471), (1, c133362), (1, water)] := by decide
-- R1 · CHEBI:133369 N-acetylglycyl residue from CHEBI:40410 N-acetylglycine: RULE_DIFFERS
theorem pair_c133369_c40410 : ¬ Balanced [(-1, c40410), (1, c133369), (1, water)] := by decide
-- R1 · CHEBI:133371 N-acetyl-L-valyl residue from CHEBI:21565 N-acetyl-L-valine: RULE_DIFFERS
theorem pair_c133371_c21565 : ¬ Balanced [(-1, c21565), (1, c133371), (1, water)] := by decide
-- R1 · CHEBI:133372 N-acetyl-L-cysteinyl residue from CHEBI:28939 N-acetyl-L-cysteine: RULE_DIFFERS
theorem pair_c133372_c28939 : ¬ Balanced [(-1, c28939), (1, c133372), (1, water)] := by decide
-- R1 · CHEBI:133375 N-acetyl-L-threonyl residue from CHEBI:45826 N-acetyl-L-threonine: RULE_DIFFERS
theorem pair_c133375_c45826 : ¬ Balanced [(-1, c45826), (1, c133375), (1, water)] := by decide
-- R1 · CHEBI:133378 N-acetyl-L-methionyl-L-leucyl residue from CHEBI:134477 N-acetyl-L-methionyl-L-leucine: RULE_DIFFERS
theorem pair_c133378_c134477 : ¬ Balanced [(-1, c134477), (1, c133378), (1, water)] := by decide
-- R1 · CHEBI:133379 N-acetyl-L-methionyl-L-isoleucyl residue from CHEBI:134478 N-acetyl-L-methionyl-L-isoleucine: RULE_DIFFERS
theorem pair_c133379_c134478 : ¬ Balanced [(-1, c134478), (1, c133379), (1, water)] := by decide
-- R1 · CHEBI:133382 N-acetyl-L-methionyl-L-phenylalanyl residue from CHEBI:134481 N-acetyl-L-methionyl-L-phenylalanine: RULE_DIFFERS
theorem pair_c133382_c134481 : ¬ Balanced [(-1, c134481), (1, c133382), (1, water)] := by decide
-- R1 · CHEBI:133384 N-acetyl-L-methionyl-L-tyrosyl residue from CHEBI:134482 N-acetyl-L-methionyl-L-tyrosine: RULE_DIFFERS
theorem pair_c133384_c134482 : ¬ Balanced [(-1, c134482), (1, c133384), (1, water)] := by decide
-- R1 · CHEBI:133386 N-acetyl-L-methionyl-L-tryptophyl residue from CHEBI:134484 N-acetyl-L-methionyl-L-tryptophan: RULE_DIFFERS
theorem pair_c133386_c134484 : ¬ Balanced [(-1, c134484), (1, c133386), (1, water)] := by decide
-- R1 · CHEBI:133399 N-acetyl-L-methionyl-L-alanyl residue from CHEBI:134489 N-acetyl-L-methionyl-L-alanine: RULE_DIFFERS
theorem pair_c133399_c134489 : ¬ Balanced [(-1, c134489), (1, c133399), (1, water)] := by decide
-- R1 · CHEBI:133400 N-acetyl-L-methionyl-L-seryl residue from CHEBI:134491 N-acetyl-L-methionyl-L-serine: RULE_DIFFERS
theorem pair_c133400_c134491 : ¬ Balanced [(-1, c134491), (1, c133400), (1, water)] := by decide
-- R1 · CHEBI:133402 N-acetyl-L-methionyl-L-valyl residue from CHEBI:134492 N-acetyl-L-methionyl-L-valine: RULE_DIFFERS
theorem pair_c133402_c134492 : ¬ Balanced [(-1, c134492), (1, c133402), (1, water)] := by decide
-- R1 · CHEBI:133404 N-acetyl-L-methionyl-L-threonyl residue from CHEBI:134495 N-acetyl-L-methionyl-L-threonine: RULE_DIFFERS
theorem pair_c133404_c134495 : ¬ Balanced [(-1, c134495), (1, c133404), (1, water)] := by decide
-- R1 · CHEBI:133414 N-acetyl-L-methionyl residue from CHEBI:21557 N-acetyl-L-methionine: RULE_DIFFERS
theorem pair_c133414_c21557 : ¬ Balanced [(-1, c21557), (1, c133414), (1, water)] := by decide
-- R1 · CHEBI:133479 S-(long-chain fatty acyl)-L-cysteine residue from CHEBI:134526 S-(long-chain fatty acyl)-L-cysteine: RULE_AGREES
theorem pair_c133479_c134526 : Balanced [(-1, c134526), (1, c133479), (1, water)] := by decide
-- R1 · CHEBI:134208 N-acetyl-alpha-D-glucosaminyl-L-tyrosyl residue from CHEBI:136688 N-acetyl-alpha-D-glucosaminyl-L-tyrosine: RULE_AGREES
theorem pair_c134208_c136688 : Balanced [(-1, c136688), (1, c134208), (1, water)] := by decide
-- R2 · CHEBI:137386 thymidine 5'-monophosphate(1-) residue from CHEBI:63528 dTMP(2-): RULE_AGREES
theorem pair_c137386_c63528 : Balanced [(-1, c63528), (1, c137386), (1, hydroxide)] := by decide
-- R1 · CHEBI:137321 O-(alpha-D-mannosyl)-L-serine residue from CHEBI:37556 O-(alpha-D-mannosyl)-L-serine: RULE_AGREES
theorem pair_c137321_c37556 : Balanced [(-1, c37556), (1, c137321), (1, water)] := by decide
-- R1 · CHEBI:137323 O-(alpha-D-mannosyl)-L-threonine residue from CHEBI:37557 O-(alpha-D-mannosyl)-L-threonine: RULE_AGREES
theorem pair_c137323_c37557 : Balanced [(-1, c37557), (1, c137323), (1, water)] := by decide
-- R1 · CHEBI:137319 4-phospho-L-aspartic acid residue from CHEBI:15836 4-phospho-L-aspartic acid: RULE_AGREES
theorem pair_c137319_c15836 : Balanced [(-1, c15836), (1, c137319), (1, water)] := by decide
-- R2 · CHEBI:137351 5-hydroxymethyldeoxycytidine 5'-monophosphate residue from CHEBI:16952 5-hydroxymethyldeoxycytidylic acid: RULE_DIFFERS_BY_HYDRONS
theorem pair_c137351_c16952 : ¬ Balanced [(-1, c16952), (1, c137351), (1, hydroxide)] ∧ Balanced ([(-1, c16952), (1, c137351), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R1 · CHEBI:85621 L-3-oxoalanine residue from CHEBI:37012 L-3-oxoalanine: RULE_AGREES
theorem pair_c85621_c37012 : Balanced [(-1, c37012), (1, c85621), (1, water)] := by decide
-- R1 · CHEBI:83228 L-alpha-amino acid residue from CHEBI:15705 L-alpha-amino acid: RULE_AGREES
theorem pair_c83228_c15705 : Balanced [(-1, c15705), (1, c83228), (1, water)] := by decide
-- R1 · CHEBI:137949 O(3)-(beta-D-galactosyl-(1->3)-N-acetyl-alpha-D-galactosaminyl)-L-serine residue from CHEBI:62464 O-(3-O-beta-D-galactosyl-N-acetyl-alpha-D-galactosaminyl)-L-serine: RULE_AGREES
theorem pair_c137949_c62464 : Balanced [(-1, c62464), (1, c137949), (1, water)] := by decide
-- R1 · CHEBI:137967 N(6)-acyl-L-lysine residue from CHEBI:16232 N(6)-acyl-L-lysine: RULE_AGREES
theorem pair_c137967_c16232 : Balanced [(-1, c16232), (1, c137967), (1, water)] := by decide
-- R1 · CHEBI:138659 5-[(alpha-D-glucopyranosyl-(1->2)-beta-D-galactopyranosyl)oxy]-L-lysine residue from CHEBI:89573 5-[(alpha-D-glucopyranosyl-(1->2)-beta-D-galactopyranosyl)oxy]-L-lysine: RULE_AGREES
theorem pair_c138659_c89573 : Balanced [(-1, c89573), (1, c138659), (1, water)] := by decide
-- R2 · CHEBI:139231 5-methyldeoxycytidine 5'-monophosphate residue from CHEBI:16764 2'-deoxy-5-methyl-5'-cytidylic acid: RULE_DIFFERS_BY_HYDRONS
theorem pair_c139231_c16764 : ¬ Balanced [(-1, c16764), (1, c139231), (1, hydroxide)] ∧ Balanced ([(-1, c16764), (1, c139231), (1, hydroxide)] ++ [(1, hydron)]) := by decide
-- R1 · CHEBI:139487 piperacilloyl-L-lysine residue from CHEBI:139364 piperacilloyl-L-lysine: RULE_AGREES
theorem pair_c139487_c139364 : Balanced [(-1, c139364), (1, c139487), (1, water)] := by decide
-- R1 · CHEBI:139488 flucloxacilloyl-L-lysine residue from CHEBI:139365 flucloxacilloyl-L-lysine: RULE_AGREES
theorem pair_c139488_c139365 : Balanced [(-1, c139365), (1, c139488), (1, water)] := by decide
-- R1 · CHEBI:139489 amoxicillin-L-lysine residue from CHEBI:139366 amoxicilloyl-L-lysine: RULE_AGREES
theorem pair_c139489_c139366 : Balanced [(-1, c139366), (1, c139489), (1, water)] := by decide
-- R1 · CHEBI:139490 benzylpenicilloyl-L-lysine residue from CHEBI:139367 benzylpenicilloyl-L-lysine: RULE_AGREES
theorem pair_c139490_c139367 : Balanced [(-1, c139367), (1, c139490), (1, water)] := by decide
-- R1 · CHEBI:139491 aztreonyl-L-lysine residue from CHEBI:139368 aztreonyl-L-lysine: RULE_AGREES
theorem pair_c139491_c139368 : Balanced [(-1, c139368), (1, c139491), (1, water)] := by decide
-- R1 · CHEBI:140449 [6)-beta-D-GlcpNAc-(1->] residue from CHEBI:28009 N-acetyl-beta-D-glucosamine: RULE_AGREES
theorem pair_c140449_c28009 : Balanced [(-1, c28009), (1, c140449), (1, water)] := by decide
-- R1 · CHEBI:140856 N-terminal N-acetyl-L-aspartate residue from CHEBI:16953 N-acetyl-L-aspartate(2-): RULE_DIFFERS
theorem pair_c140856_c16953 : ¬ Balanced [(-1, c16953), (1, c140856), (1, water)] := by decide
-- R1 · CHEBI:140857 N-terminal N-acetyl-L-glutamate residue from CHEBI:44337 N-acetyl-L-glutamate(2-): RULE_DIFFERS
theorem pair_c140857_c44337 : ¬ Balanced [(-1, c44337), (1, c140857), (1, water)] := by decide
-- R1 · CHEBI:140858 N-terminal N-acetyl-L-isoleucine residue from CHEBI:21555 N-acetyl-L-isoleucine: RULE_DIFFERS
theorem pair_c140858_c21555 : ¬ Balanced [(-1, c21555), (1, c140858), (1, water)] := by decide
-- R1 · CHEBI:140859 N-terminal N-acetyl-L-proline residue from CHEBI:21560 N-acetyl-L-proline: RULE_DIFFERS
theorem pair_c140859_c21560 : ¬ Balanced [(-1, c21560), (1, c140859), (1, water)] := by decide
-- R1 · CHEBI:140860 N-terminal N-acetyl-L-tyrosine residue from CHEBI:21563 N-acetyl-L-tyrosine: RULE_DIFFERS
theorem pair_c140860_c21563 : ¬ Balanced [(-1, c21563), (1, c140860), (1, water)] := by decide
-- R1 · CHEBI:141128 O-acetyl-L-serine residue from CHEBI:17981 O-acetyl-L-serine: RULE_AGREES
theorem pair_c141128_c17981 : Balanced [(-1, c17981), (1, c141128), (1, water)] := by decide
-- R1 · CHEBI:141018 4-chloro-L-threonine residue from CHEBI:49549 4-chloro-L-threonine: RULE_AGREES
theorem pair_c141018_c49549 : Balanced [(-1, c49549), (1, c141018), (1, water)] := by decide
-- R1 · CHEBI:141127 (2S,3R)-3-geranyl-2,3-dihydro-2,N(alpha)-cyclo-L-tryptophan residue from CHEBI:35304 (2S,3R)-3-geranyl-2,3-dihydro-2,N(alpha)-cyclo-L-tryptophan: RULE_AGREES
theorem pair_c141127_c35304 : Balanced [(-1, c35304), (1, c141127), (1, water)] := by decide
-- R2 · CHEBI:141453 2-thiocytidine 5'-monophosphate(1-) residue from CHEBI:60377 cytidine 5'-monophosphate(2-): RULE_DIFFERS
theorem pair_c141453_c60377 : ¬ Balanced [(-1, c60377), (1, c141453), (1, hydroxide)] := by decide
-- R1 · CHEBI:141492 (3S)-3-hydroxy-L-lysine(1+) residue from CHEBI:77409 (3S)-3-hydroxy-L-lysine(1+): RULE_AGREES
theorem pair_c141492_c77409 : Balanced [(-1, c77409), (1, c141492), (1, water)] := by decide
-- R1 · CHEBI:141495 4-hydroxy-L-lysine(1+) residue from CHEBI:141496 4-hydroxy-L-lysine(1+): RULE_AGREES
theorem pair_c141495_c141496 : Balanced [(-1, c141496), (1, c141495), (1, water)] := by decide
-- R2 · CHEBI:141580 N(2)-(1-hydroxy-2-oxopropyl)-GMP(1-) residue from CHEBI:141575 N(2)-(1-hydroxy-2-oxopropyl)-GMP(2-): RULE_AGREES
theorem pair_c141580_c141575 : Balanced [(-1, c141575), (1, c141580), (1, hydroxide)] := by decide
-- R2 · CHEBI:141581 N(2)-(1-hydroxy-2-oxoethyl)-GMP(1-) residue from CHEBI:141576 N(2)-(1-hydroxy-2-oxoethyl)-GMP(2-): RULE_AGREES
theorem pair_c141581_c141576 : Balanced [(-1, c141576), (1, c141581), (1, hydroxide)] := by decide
-- R1 · CHEBI:141815 3',4'-dihydroxy-L-phenylalanine residue from CHEBI:67012 L-dopa(1-): RULE_DIFFERS_BY_HYDRONS
theorem pair_c141815_c67012 : ¬ Balanced [(-1, c67012), (1, c141815), (1, water)] ∧ Balanced ([(-1, c67012), (1, c141815), (1, water)] ++ [(-1, hydron)]) := by decide
-- R1 · CHEBI:141830 L-cysteate residue from CHEBI:58090 L-cysteate(1-): RULE_AGREES
theorem pair_c141830_c58090 : Balanced [(-1, c58090), (1, c141830), (1, water)] := by decide
-- R1 · CHEBI:141831 7-hydroxy-L-tryptophan residue from CHEBI:49348 7-hydroxy-L-tryptophan: RULE_AGREES
theorem pair_c141831_c49348 : Balanced [(-1, c49348), (1, c141831), (1, water)] := by decide
-- R1 · CHEBI:141835 3-hydroxy-L-proline residue from CHEBI:20056 3-hydroxy-L-proline: RULE_AGREES
theorem pair_c141835_c20056 : Balanced [(-1, c20056), (1, c141835), (1, water)] := by decide
-- R1 · CHEBI:141841 3-hydroxy-L-phenylalanine residue from CHEBI:78290 L-m-tyrosine zwitterion: RULE_AGREES
theorem pair_c141841_c78290 : Balanced [(-1, c78290), (1, c141841), (1, water)] := by decide
-- R1 · CHEBI:141843 (5S)-5-hydroxy-L-lysinium residue from CHEBI:64035 threo-5-hydroxy-L-lysine: RULE_DIFFERS_BY_HYDRONS
theorem pair_c141843_c64035 : ¬ Balanced [(-1, c64035), (1, c141843), (1, water)] ∧ Balanced ([(-1, c64035), (1, c141843), (1, water)] ++ [(-1, hydron)]) := by decide
-- R1 · CHEBI:141845 4-hydroxy-L-glutamate residue from CHEBI:16338 4-hydroxy-L-glutamate(2-): RULE_DIFFERS_BY_HYDRONS
theorem pair_c141845_c16338 : ¬ Balanced [(-1, c16338), (1, c141845), (1, water)] ∧ Balanced ([(-1, c16338), (1, c141845), (1, water)] ++ [(-1, hydron)]) := by decide
-- R1 · CHEBI:141845 4-hydroxy-L-glutamate residue from CHEBI:32812 4-hydroxy-L-glutamate(1-): RULE_AGREES
theorem pair_c141845_c32812 : Balanced [(-1, c32812), (1, c141845), (1, water)] := by decide
-- R1 · CHEBI:142054 3-hydroxyaspartic acid residue from CHEBI:83981 3-hydroxyaspartic acid: RULE_AGREES
theorem pair_c142054_c83981 : Balanced [(-1, c83981), (1, c142054), (1, water)] := by decide
-- R1 · CHEBI:141794 3-hydroxy-L-tryptophan residue from CHEBI:142395 3-hydroxy-L-tryptophan: RULE_AGREES
theorem pair_c141794_c142395 : Balanced [(-1, c142395), (1, c141794), (1, water)] := by decide
-- R1 · CHEBI:141793 3-hydroxy-L-valine residue from CHEBI:142415 3-hydroxy-L-valine: RULE_AGREES
theorem pair_c141793_c142415 : Balanced [(-1, c142415), (1, c141793), (1, water)] := by decide
-- R1 · CHEBI:142417 D-alpha-amino acid residue from CHEBI:16733 D-alpha-amino acid: RULE_AGREES
theorem pair_c142417_c16733 : Balanced [(-1, c16733), (1, c142417), (1, water)] := by decide
-- R1 · CHEBI:141792 4-hydroxy-D-valine residue from CHEBI:142413 4-hydroxy-D-valine: RULE_AGREES
theorem pair_c141792_c142413 : Balanced [(-1, c142413), (1, c141792), (1, water)] := by decide
-- R1 · CHEBI:143279 O-(N-acetyl-alpha-D-glucosaminyl)-L-serine residue from CHEBI:53608 O-(N-acetyl-alpha-D-galactosaminyl)-L-serine: RULE_AGREES
theorem pair_c143279_c53608 : Balanced [(-1, c53608), (1, c143279), (1, water)] := by decide
-- R1 · CHEBI:143140 glycyl-L-cysteine residue from CHEBI:73890 Gly-Cys: RULE_AGREES
theorem pair_c143140_c73890 : Balanced [(-1, c73890), (1, c143140), (1, water)] := by decide
-- R1 · CHEBI:141809 2-hydroxy-L-proline residue from CHEBI:144030 2-hydroxy-L-proline: RULE_AGREES
theorem pair_c141809_c144030 : Balanced [(-1, c144030), (1, c141809), (1, water)] := by decide
-- R1 · CHEBI:141825 4-hydroxy-L-leucine residue from CHEBI:144031 4-hydroxy-L-leucine: RULE_AGREES
theorem pair_c141825_c144031 : Balanced [(-1, c144031), (1, c141825), (1, water)] := by decide
-- R1 · CHEBI:141025 O-acetyl-L-threonine residue from CHEBI:144312 O-acetyl-L-threonine: RULE_AGREES
theorem pair_c141025_c144312 : Balanced [(-1, c144312), (1, c141025), (1, water)] := by decide
-- R1 · CHEBI:143147 N-palmitoyl-L-cysteine residue from CHEBI:21780 N-palmitoyl-L-cysteine: RULE_DIFFERS
theorem pair_c143147_c21780 : ¬ Balanced [(-1, c21780), (1, c143147), (1, water)] := by decide
-- R1 · CHEBI:144369 L-homocitrulline residue from CHEBI:17443 L-homocitrulline: RULE_AGREES
theorem pair_c144369_c17443 : Balanced [(-1, c17443), (1, c144369), (1, water)] := by decide
-- R1 · CHEBI:145329 (Z)-2,3-didehydroaspartic acid residue from CHEBI:145328 (Z)-2,3-didehydroaspartic acid: RULE_AGREES
theorem pair_c145329_c145328 : Balanced [(-1, c145328), (1, c145329), (1, water)] := by decide
-- R1 · CHEBI:145324 N(6)-lactoyl-L-lysine residue from CHEBI:145390 N(6)-lactoyl-L-lysine: RULE_AGREES
theorem pair_c145324_c145390 : Balanced [(-1, c145390), (1, c145324), (1, water)] := by decide
-- R1 · CHEBI:144968 N(6)-(2-hydroxyisobutanoyl)-L-lysine residue from CHEBI:145391 N(6)-(2-hydroxyisobutanoyl)-L-lysine: RULE_AGREES
theorem pair_c144968_c145391 : Balanced [(-1, c145391), (1, c144968), (1, water)] := by decide
-- R1 · CHEBI:145671 N,N-dimethyl-L-prolinium residue from CHEBI:44813 N,N-dimethyl-L-prolinium: RULE_DIFFERS
theorem pair_c145671_c44813 : ¬ Balanced [(-1, c44813), (1, c145671), (1, water)] := by decide
-- R1 · CHEBI:145897 L-arginine amide(1+) residue from CHEBI:40477 L-arginine amide(1+): RULE_DIFFERS
theorem pair_c145897_c40477 : ¬ Balanced [(-1, c40477), (1, c145897), (1, water)] := by decide
-- R1 · CHEBI:145904 L-glutamine amide residue from CHEBI:21309 L-glutamine amide: RULE_DIFFERS
theorem pair_c145904_c21309 : ¬ Balanced [(-1, c21309), (1, c145904), (1, water)] := by decide
-- R1 · CHEBI:145913 L-methionine amide residue from CHEBI:21362 L-methioninamide: RULE_DIFFERS
theorem pair_c145913_c21362 : ¬ Balanced [(-1, c21362), (1, c145913), (1, water)] := by decide
-- R1 · CHEBI:145917 L-tryptophan amide residue from CHEBI:16533 L-tryptophanamide: RULE_DIFFERS
theorem pair_c145917_c16533 : ¬ Balanced [(-1, c16533), (1, c145917), (1, water)] := by decide
-- R1 · CHEBI:143915 N(6)-(pyridoxal phosphate)-L-lysine(2-) residue from CHEBI:134066 N(6)-(pyridoxal phosphate)-L-lysine: RULE_DIFFERS_BY_HYDRONS
theorem pair_c143915_c134066 : ¬ Balanced [(-1, c134066), (1, c143915), (1, water)] ∧ Balanced ([(-1, c134066), (1, c143915), (1, water)] ++ [(2, hydron)]) := by decide
-- R1 · CHEBI:149494 S-nitroso-L-cysteine residue from CHEBI:138935 S-nitroso-L-cysteine: RULE_AGREES
theorem pair_c149494_c138935 : Balanced [(-1, c138935), (1, c149494), (1, water)] := by decide
-- R1 · CHEBI:155899 3-nitro-L-tyrosine residue from CHEBI:44454 3-nitro-L-tyrosine: RULE_AGREES
theorem pair_c155899_c44454 : Balanced [(-1, c44454), (1, c155899), (1, water)] := by decide
-- R1 · CHEBI:156064 N(6)-formyl-L-lysine residue from CHEBI:21884 N(6)-formyl-L-lysine: RULE_AGREES
theorem pair_c156064_c21884 : Balanced [(-1, c21884), (1, c156064), (1, water)] := by decide
-- R1 · CHEBI:156065 L-methionine sulfone residue from CHEBI:21363 L-methionine sulfone: RULE_AGREES
theorem pair_c156065_c21363 : Balanced [(-1, c21363), (1, c156065), (1, water)] := by decide
-- R1 · CHEBI:156254 3-sulfino-L-alanyl residue from CHEBI:61085 3-sulfino-L-alanine(1-): RULE_DIFFERS
theorem pair_c156254_c61085 : ¬ Balanced [(-1, c61085), (1, c156254), (1, water)] := by decide
-- R1 · CHEBI:166866 S-[(5R)-5-hydroxy-L-lysyl]-L-methionine sulfilimine residue from CHEBI:16044 L-methionine residue: RULE_DIFFERS
theorem pair_c166866_c16044 : ¬ Balanced [(-1, c16044), (1, c166866), (1, water)] := by decide
-- R1 · CHEBI:166866 S-[(5R)-5-hydroxy-L-lysyl]-L-methionine sulfilimine residue from CHEBI:133442 (5R)-5-hydroxy-L-lysine(1+) residue: RULE_DIFFERS
theorem pair_c166866_c133442 : ¬ Balanced [(-1, c133442), (1, c166866), (1, water)] := by decide
-- R1 · CHEBI:166867 S-(L-lysyl)-L-methionine sulfilimine residue from CHEBI:29969 L-lysinium residue: RULE_DIFFERS
theorem pair_c166867_c29969 : ¬ Balanced [(-1, c29969), (1, c166867), (1, water)] := by decide
-- R1 · CHEBI:166867 S-(L-lysyl)-L-methionine sulfilimine residue from CHEBI:16044 L-methionine residue: RULE_DIFFERS
theorem pair_c166867_c16044 : ¬ Balanced [(-1, c16044), (1, c166867), (1, water)] := by decide
-- R1 · CHEBI:167628 O-methyl-L-threonine residue from CHEBI:44514 O-methyl-L-threonine: RULE_AGREES
theorem pair_c167628_c44514 : Balanced [(-1, c44514), (1, c167628), (1, water)] := by decide
-- R1 · CHEBI:167179 N-[2-(1H-imidazol-4-yl)ethyl]-L-glutamine residue from CHEBI:30307 N(alpha)-gamma-L-glutamylhistamine: RULE_AGREES
theorem pair_c167179_c30307 : Balanced [(-1, c30307), (1, c167179), (1, water)] := by decide
-- R1 · CHEBI:177368 (2S,3R)-3-farnesyl-2,3-dihydro-2,N(alpha)-cyclo-L-tryptophan residue from CHEBI:52950 (2S,3R)-3-farnesyl-2,3-dihydro-2,N(alpha)-cyclo-L-tryptophan: RULE_AGREES
theorem pair_c177368_c52950 : Balanced [(-1, c52950), (1, c177368), (1, water)] := by decide
-- R1 · CHEBI:183512 3-bromo-L-tyrosine residue from CHEBI:53668 3-bromo-L-tyrosine: RULE_AGREES
theorem pair_c183512_c53668 : Balanced [(-1, c53668), (1, c183512), (1, water)] := by decide
-- R2 · CHEBI:142722 N(2)-(ADP-D-ribosyl)-dGMP(3-) residue from CHEBI:142718 N(2)-(ADP-D-ribosyl)-dGMP(4-): RULE_AGREES
theorem pair_c142722_c142718 : Balanced [(-1, c142718), (1, c142722), (1, hydroxide)] := by decide
-- R1 · CHEBI:194223 N-terminal N-acetyl-L-leucyl residue from CHEBI:17786 N-acetyl-L-leucine: RULE_DIFFERS
theorem pair_c194223_c17786 : ¬ Balanced [(-1, c17786), (1, c194223), (1, water)] := by decide
-- R1 · CHEBI:195204 N(alpha)-methyl-L-histidine residue from CHEBI:50601 N(alpha)-methyl-L-histidine: RULE_AGREES
theorem pair_c195204_c50601 : Balanced [(-1, c50601), (1, c195204), (1, water)] := by decide
-- R1 · CHEBI:197459 N(6)-acetyl-N(6)-methyl-L-lysine residue from CHEBI:197458 N(6)-acetyl-N(6)-methyl-L-lysine: RULE_AGREES
theorem pair_c197459_c197458 : Balanced [(-1, c197458), (1, c197459), (1, water)] := by decide
-- R1 · CHEBI:139319 3-trisulfanyl-L-alanine residue from CHEBI:229519 3-trisulfanyl-L-alanine: RULE_AGREES
theorem pair_c139319_c229519 : Balanced [(-1, c229519), (1, c139319), (1, water)] := by decide
-- R1 · CHEBI:233051 [(4)-N-acetyl-alpha-L-Fucp-(1->3)-2-N-acetyl-4-N-(3R,5R)-dihydroxyhexanoyl-alpha-D-quip-(1->2)-alpha-L-Rhap-(1->)] residue from CHEBI:233010 N-acetyl-alpha-L-Fucp-(1->3)-2-N-acetyl-4-N-(3R,5R)-dihydroxyhexanoyl-alpha-D-quip-(1->2)-alpha-L-Rhap: RULE_DIFFERS
theorem pair_c233051_c233010 : ¬ Balanced [(-1, c233010), (1, c233051), (1, water)] := by decide
-- R1 · CHEBI:235404 L-2-aminoadipate(1-) residue from CHEBI:58672 L-2-aminoadipate(1-): RULE_AGREES
theorem pair_c235404_c58672 : Balanced [(-1, c58672), (1, c235404), (1, water)] := by decide
-- R1 · CHEBI:229579 di-L-cysteinyl-trisulfide residue from CHEBI:760776 L-thiocystine: RULE_DIFFERS
theorem pair_c229579_c760776 : ¬ Balanced [(-1, c760776), (1, c229579), (1, water)] := by decide

end BioCore.Damage.RuleTest
