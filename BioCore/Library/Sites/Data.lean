import BioCore.CentralDogma
/-!
# BioCore.Library.Sites.Data

GENERATED FILE (first produced by the prototype generator BioCore/Library/Events/Identity/gen/ip_gen.py; ported unchanged apart from the namespace). Each definition is data copied from the
named source; the kernel checks what follows from it, not that it describes the molecule.
Pairs are (quantity, amount): 0 is charge, 1..118 atomic numbers, 1000 the generic group R.
Species are restated here (not imported from the reaction library, whose build takes about 23 minutes);
the text of each definition is the one in `results/rx_species.tsv` where the species is there.
-/
namespace BioCore.Sites.Sp
open BioCore

def c4167 : Species := ⟨"CHEBI:4167 D-glucopyranose", [(6, 6), (1, 12), (8, 6)]⟩  -- CHEBI:4167, formula C6H12O6, charge 0; ChEBI release 257 via results/rx_species.tsv
abbrev c15377 : Species := BioCore.Chebi.c15377  -- kernel data, BioCore/Data/Monomers.lean (ChEBI release 257)
abbrev c15378 : Species := BioCore.Chebi.c15378  -- kernel data, BioCore/Data/Monomers.lean (ChEBI release 257)
def c15379 : Species := ⟨"CHEBI:15379 dioxygen", [(8, 2)]⟩  -- CHEBI:15379, formula O2, charge 0; ChEBI release 257 via results/rx_species.tsv
abbrev c16044 : Species := BioCore.Chebi.c16044  -- kernel data, BioCore/Data/Monomers.lean (ChEBI release 257)
def c16240 : Species := ⟨"CHEBI:16240 hydrogen peroxide", [(1, 2), (8, 2)]⟩  -- CHEBI:16240, formula H2O2, charge 0; ChEBI release 257 via results/rx_species.tsv
def c16526 : Species := ⟨"CHEBI:16526 carbon dioxide", [(6, 1), (8, 2)]⟩  -- CHEBI:16526, formula CO2, charge 0; ChEBI release 257 via results/rx_species.tsv
def c16792 : Species := ⟨"CHEBI:16792 oxidized Photinus luciferin", [(6, 10), (1, 6), (7, 2), (8, 2), (16, 2)]⟩  -- CHEBI:16792, formula C10H6N2O2S2, charge 0; ChEBI release 257 via results/rx_species.tsv
def c16810 : Species := ⟨"CHEBI:16810 2-oxoglutarate(2-)", [(6, 5), (1, 4), (8, 5), (0, -2)]⟩  -- CHEBI:16810, formula C5H4O5, charge -2; ChEBI release 257 via results/rx_species.tsv
def c16842 : Species := ⟨"CHEBI:16842 formaldehyde", [(6, 1), (1, 2), (8, 1)]⟩  -- CHEBI:16842, formula CH2O, charge 0; ChEBI release 257 via results/rx_species.tsv
def c17154 : Species := ⟨"CHEBI:17154 nicotinamide", [(6, 6), (1, 6), (7, 2), (8, 1)]⟩  -- CHEBI:17154, formula C6H6N2O, charge 0; ChEBI release 257 via results/rx_species.tsv
def c28645 : Species := ⟨"CHEBI:28645 beta-D-fructofuranose", [(6, 6), (1, 12), (8, 6)]⟩  -- CHEBI:28645, formula C6H12O6, charge 0; ChEBI release 257 via results/rx_species.tsv
def c29101 : Species := ⟨"CHEBI:29101 sodium(1+)", [(11, 1), (0, 1)]⟩  -- CHEBI:29101, formula Na, charge 1; ChEBI release 257 via results/rx_species.tsv
def c29103 : Species := ⟨"CHEBI:29103 potassium(1+)", [(19, 1), (0, 1)]⟩  -- CHEBI:29103, formula K, charge 1; ChEBI release 257 via results/rx_species.tsv
def c29108 : Species := ⟨"CHEBI:29108 calcium(2+)", [(20, 1), (0, 2)]⟩  -- CHEBI:29108, formula Ca, charge 2; ChEBI release 257 via results/rx_species.tsv
abbrev c29950 : Species := BioCore.Chebi.c29950  -- kernel data, BioCore/Data/Monomers.lean (ChEBI release 257)
abbrev c29965 : Species := BioCore.Chebi.c29965  -- kernel data, BioCore/Data/Monomers.lean (ChEBI release 257)
abbrev c29969 : Species := BioCore.Chebi.c29969  -- kernel data, BioCore/Data/Monomers.lean (ChEBI release 257)
abbrev c29999 : Species := BioCore.Chebi.c29999  -- kernel data, BioCore/Data/Monomers.lean (ChEBI release 257)
abbrev c30013 : Species := BioCore.Chebi.c30013  -- kernel data, BioCore/Data/Monomers.lean (ChEBI release 257)
def c30031 : Species := ⟨"CHEBI:30031 succinate(2-)", [(6, 4), (1, 4), (8, 4), (0, -2)]⟩  -- CHEBI:30031, formula C4H4O4, charge -2; ChEBI release 257 via results/rx_species.tsv
def c30089 : Species := ⟨"CHEBI:30089 acetate", [(6, 2), (1, 3), (8, 2), (0, -1)]⟩  -- CHEBI:30089, formula C2H3O2, charge -1; ChEBI release 257 via results/rx_species.tsv
-- CHEBI:30212: no formula in ChEBI release 257 (not defined here)
abbrev c30616 : Species := BioCore.Chebi.c30616  -- kernel data, BioCore/Data/Monomers.lean (ChEBI release 257)
abbrev c33019 : Species := BioCore.Chebi.c33019  -- kernel data, BioCore/Data/Monomers.lean (ChEBI release 257)
def c34779 : Species := ⟨"CHEBI:34779 glyoxal", [(6, 2), (1, 2), (8, 2)]⟩  -- CHEBI:34779, formula C2H2O2, charge 0; ChEBI release 257 via results/rx_species.tsv
abbrev c37565 : Species := BioCore.Chebi.c37565  -- kernel data, BioCore/Data/Monomers.lean (ChEBI release 257)
def c43474 : Species := ⟨"CHEBI:43474 hydrogenphosphate", [(1, 1), (8, 4), (15, 1), (0, -2)]⟩  -- CHEBI:43474, formula HO4P, charge -2; ChEBI release 257 via results/rx_species.tsv
def c44120 : Species := ⟨"CHEBI:44120 L-methionine (S)-S-oxide residue", [(6, 5), (1, 9), (7, 1), (8, 2), (16, 1)]⟩  -- CHEBI:44120, formula C5H9NO2S, charge 0; ChEBI release 257 via results/rx_species.tsv
abbrev c46858 : Species := BioCore.Chebi.c46858  -- kernel data, BioCore/Data/Monomers.lean (ChEBI release 257)
def c50058 : Species := ⟨"CHEBI:50058 L-cystine residue", [(6, 6), (1, 8), (7, 2), (8, 2), (16, 2)]⟩  -- CHEBI:50058, formula C6H8N2O2S2, charge 0; ChEBI release 257 via results/rx_species.tsv
abbrev c50347 : Species := BioCore.Chebi.c50347  -- kernel data, BioCore/Data/Monomers.lean (ChEBI release 257)
def c50607 : Species := ⟨"CHEBI:50607 dityrosine", [(6, 18), (1, 20), (7, 2), (8, 6)]⟩  -- CHEBI:50607, formula C18H20N2O6, charge 0; ChEBI release 257 flat files (chemical_data.tsv.gz, compounds.tsv.gz)
def c53014 : Species := ⟨"CHEBI:53014 N6-carboxymethyl-L-lysine", [(6, 8), (1, 16), (7, 2), (8, 4)]⟩  -- CHEBI:53014, formula C8H16N2O4, charge 0; ChEBI release 257 flat files (chemical_data.tsv.gz, compounds.tsv.gz)
def c53015 : Species := ⟨"CHEBI:53015 N6-carboxymethyl-L-lysine residue", [(6, 8), (1, 14), (7, 2), (8, 3)]⟩  -- CHEBI:53015, formula C8H14N2O3, charge 0; ChEBI release 257 flat files (chemical_data.tsv.gz, compounds.tsv.gz)
def c57287 : Species := ⟨"CHEBI:57287 coenzyme A(4-)", [(6, 21), (1, 32), (7, 7), (8, 16), (15, 3), (16, 1), (0, -4)]⟩  -- CHEBI:57287, formula C21H32N7O16P3S, charge -4; ChEBI release 257 via results/rx_species.tsv
def c57288 : Species := ⟨"CHEBI:57288 acetyl-CoA(4-)", [(6, 23), (1, 34), (7, 7), (8, 17), (15, 3), (16, 1), (0, -4)]⟩  -- CHEBI:57288, formula C23H34N7O17P3S, charge -4; ChEBI release 257 via results/rx_species.tsv
def c57292 : Species := ⟨"CHEBI:57292 succinyl-CoA(5-)", [(6, 25), (1, 35), (7, 7), (8, 19), (15, 3), (16, 1), (0, -5)]⟩  -- CHEBI:57292, formula C25H35N7O19P3S, charge -5; ChEBI release 257 via results/rx_species.tsv
def c57540 : Species := ⟨"CHEBI:57540 NAD(1-)", [(6, 21), (1, 26), (7, 7), (8, 14), (15, 2), (0, -1)]⟩  -- CHEBI:57540, formula C21H26N7O14P2, charge -1; ChEBI release 257 via results/rx_species.tsv
def c57705 : Species := ⟨"CHEBI:57705 UDP-N-acetyl-alpha-D-glucosamine(2-)", [(6, 17), (1, 25), (7, 3), (8, 17), (15, 2), (0, -2)]⟩  -- CHEBI:57705, formula C17H25N3O17P2, charge -2; ChEBI release 257 via results/rx_species.tsv
def c57856 : Species := ⟨"CHEBI:57856 S-adenosyl-L-homocysteine zwitterion", [(6, 14), (1, 20), (7, 6), (8, 5), (16, 1)]⟩  -- CHEBI:57856, formula C14H20N6O5S, charge 0; ChEBI release 257 via results/rx_species.tsv
def c57930 : Species := ⟨"CHEBI:57930 nucleoside 5'-diphosphate(3-)", [(6, 5), (1, 8), (8, 10), (15, 2), (1000, 1), (0, -3)]⟩  -- CHEBI:57930, formula C5H8O10P2R, charge -3; ChEBI release 257 via results/rx_species.tsv
def c57945 : Species := ⟨"CHEBI:57945 NADH(2-)", [(6, 21), (1, 27), (7, 7), (8, 14), (15, 2), (0, -2)]⟩  -- CHEBI:57945, formula C21H27N7O14P2, charge -2; ChEBI release 257 via results/rx_species.tsv
def c58038 : Species := ⟨"CHEBI:58038 Photinus luciferin(1-)", [(6, 11), (1, 7), (7, 2), (8, 3), (16, 2), (0, -1)]⟩  -- CHEBI:58038, formula C11H7N2O3S2, charge -1; ChEBI release 257 via results/rx_species.tsv
def c58052 : Species := ⟨"CHEBI:58052 UDP-alpha-D-glucuronate(3-)", [(6, 15), (1, 19), (7, 2), (8, 18), (15, 2), (0, -3)]⟩  -- CHEBI:58052, formula C15H19N2O18P2, charge -3; ChEBI release 257 via results/rx_species.tsv
def c58189 : Species := ⟨"CHEBI:58189 GDP(3-)", [(6, 10), (1, 12), (7, 5), (8, 11), (15, 2), (0, -3)]⟩  -- CHEBI:58189, formula C10H12N5O11P2, charge -3; ChEBI release 257 via results/rx_species.tsv
def c58223 : Species := ⟨"CHEBI:58223 UDP(3-)", [(6, 9), (1, 11), (7, 2), (8, 12), (15, 2), (0, -3)]⟩  -- CHEBI:58223, formula C9H11N2O12P2, charge -3; ChEBI release 257 via results/rx_species.tsv
abbrev c58315 : Species := BioCore.Chebi.c58315  -- kernel data, BioCore/Data/Monomers.lean (ChEBI release 257)
def c58885 : Species := ⟨"CHEBI:58885 UDP-alpha-D-glucose(2-)", [(6, 15), (1, 22), (7, 2), (8, 17), (15, 2), (0, -2)]⟩  -- CHEBI:58885, formula C15H22N2O17P2, charge -2; ChEBI release 257 via results/rx_species.tsv
def c59789 : Species := ⟨"CHEBI:59789 S-adenosyl-L-methionine zwitterion", [(6, 15), (1, 23), (7, 6), (8, 5), (16, 1), (0, 1)]⟩  -- CHEBI:59789, formula C15H23N6O5S, charge 1; ChEBI release 257 via results/rx_species.tsv
def c59951 : Species := ⟨"CHEBI:59951 pentosidine", [(6, 17), (1, 26), (7, 6), (8, 4)]⟩  -- CHEBI:59951, formula C17H26N6O4, charge 0; ChEBI release 257 flat files (chemical_data.tsv.gz, compounds.tsv.gz)
def c61929 : Species := ⟨"CHEBI:61929 N(6)-methyl-L-lysinium residue", [(6, 7), (1, 15), (7, 2), (8, 1), (0, 1)]⟩  -- CHEBI:61929, formula C7H15N2O, charge 1; ChEBI release 257 via results/rx_species.tsv
def c61930 : Species := ⟨"CHEBI:61930 N(6)-acetyl-L-lysine residue", [(6, 8), (1, 14), (7, 2), (8, 2)]⟩  -- CHEBI:61930, formula C8H14N2O2, charge 0; ChEBI release 257 via results/rx_species.tsv
def c61977 : Species := ⟨"CHEBI:61977 O-phosphonato-L-threonine(2-) residue", [(6, 4), (1, 6), (7, 1), (8, 5), (15, 1), (0, -2)]⟩  -- CHEBI:61977, formula C4H6NO5P, charge -2; ChEBI release 257 via results/rx_species.tsv
def c61978 : Species := ⟨"CHEBI:61978 O(4)-phosphonato-L-tyrosine(2-) residue", [(6, 9), (1, 8), (7, 1), (8, 5), (15, 1), (0, -2)]⟩  -- CHEBI:61978, formula C9H8NO5P, charge -2; ChEBI release 257 via results/rx_species.tsv
def c64647 : Species := ⟨"CHEBI:64647 amyloid-β polypeptide 42", [(6, 203), (1, 311), (7, 55), (8, 60), (16, 1)]⟩  -- CHEBI:64647, formula C203H311N55O60S, charge 0; ChEBI release 257 flat files (chemical_data.tsv.gz, compounds.tsv.gz)
def c83421 : Species := ⟨"CHEBI:83421 O-phospho-L-serine(2-) residue", [(6, 3), (1, 4), (7, 1), (8, 5), (15, 1), (0, -2)]⟩  -- CHEBI:83421, formula C3H4NO5P, charge -2; ChEBI release 257 via results/rx_species.tsv
def c83767 : Species := ⟨"CHEBI:83767 2''-O-acetyl-ADP-D-ribose(2-)", [(6, 17), (1, 23), (7, 5), (8, 15), (15, 2), (0, -2)]⟩  -- CHEBI:83767, formula C17H23N5O15P2, charge -2; ChEBI release 257 via results/rx_species.tsv
def c83833 : Species := ⟨"CHEBI:83833 peptidylproline (omega=0) residue", [(6, 6), (1, 7), (7, 1), (8, 2)]⟩  -- CHEBI:83833, formula C6H7NO2, charge 0; ChEBI release 257 via results/rx_species.tsv
def c83834 : Species := ⟨"CHEBI:83834 peptidylproline (omega=180) residue", [(6, 6), (1, 7), (7, 1), (8, 2)]⟩  -- CHEBI:83834, formula C6H7NO2, charge 0; ChEBI release 257 via results/rx_species.tsv
def c87830 : Species := ⟨"CHEBI:87830 N(6)-succinyl-L-lysine(1-) residue", [(6, 10), (1, 15), (7, 2), (8, 4), (0, -1)]⟩  -- CHEBI:87830, formula C10H15N2O4, charge -1; ChEBI release 257 via results/rx_species.tsv
def c90838 : Species := ⟨"CHEBI:90838 O-(N-acetyl-beta-D-glucosaminyl)-L-serine residue", [(6, 11), (1, 18), (7, 2), (8, 7)]⟩  -- CHEBI:90838, formula C11H18N2O7, charge 0; ChEBI release 257 via results/rx_species.tsv
def c132529 : Species := ⟨"CHEBI:132529 N(4)-(oligosaccharide-(1->4)-N-acetyl-beta-D-glucosaminyl-(1->4)-N-acetyl-beta-D-glucosaminyl)-L-asparagine residue", [(6, 20), (1, 31), (7, 4), (8, 12), (1000, 1)]⟩  -- CHEBI:132529, formula C20H31N4O12R, charge 0; ChEBI release 257 via results/rx_species.tsv
def c142554 : Species := ⟨"CHEBI:142554 N(omega)-(ADP-D-ribosyl)-L-argininium(1-) residue", [(6, 21), (1, 32), (7, 9), (8, 14), (15, 2), (0, -1)]⟩  -- CHEBI:142554, formula C21H32N9O14P2, charge -1; ChEBI release 257 via results/rx_species.tsv
def c142556 : Species := ⟨"CHEBI:142556 O-(ADP-D-ribosyl)-L-serine(2-) residue", [(6, 18), (1, 24), (7, 6), (8, 15), (15, 2), (0, -2)]⟩  -- CHEBI:142556, formula C18H24N6O15P2, charge -2; ChEBI release 257 via results/rx_species.tsv
def c456215 : Species := ⟨"CHEBI:456215 adenosine 5'-monophosphate(2-)", [(6, 10), (1, 12), (7, 5), (8, 7), (15, 1), (0, -2)]⟩  -- CHEBI:456215, formula C10H12N5O7P, charge -2; ChEBI release 257 via results/rx_species.tsv
def c456216 : Species := ⟨"CHEBI:456216 ADP(3-)", [(6, 10), (1, 12), (7, 5), (8, 10), (15, 2), (0, -3)]⟩  -- CHEBI:456216, formula C10H12N5O10P2, charge -3; ChEBI release 257 via results/rx_species.tsv
def c506227 : Species := ⟨"CHEBI:506227 N-acetyl-D-glucosamine", [(6, 8), (1, 15), (7, 1), (8, 6)]⟩  -- CHEBI:506227, formula C8H15NO6, charge 0; ChEBI release 257 via results/rx_species.tsv

/-- RHEA:18353: 2 K(+)(out) + 3 Na(+)(in) + ATP + H2O = 2 K(+)(in) + 3 Na(+)(out) + ADP + phosphate + H(+). Terms as in the reaction library (`BioCore.Rhea.rhea_18353`); compartments are not in the terms. -/
def rhea_18353 : FSum := [(-1, c15377), (-3, c29101), (-2, c29103), (-1, c30616), (3, c29101), (1, c456216), (1, c15378), (2, c29103), (1, c43474)]
/-- RHEA:57720: ATP + H2O + 4 H(+)(in) = ADP + phosphate + 5 H(+)(out). Terms as in the reaction library (`BioCore.Rhea.rhea_57720`); compartments are not in the terms. -/
def rhea_57720 : FSum := [(-1, c15377), (-4, c15378), (-1, c30616), (1, c456216), (5, c15378), (1, c43474)]
/-- RHEA:29463: K(+)(in) = K(+)(out). Terms as in the reaction library (`BioCore.Rhea.rhea_29463`); compartments are not in the terms. -/
def rhea_29463 : FSum := [(-1, c29103), (1, c29103)]
/-- RHEA:60376: D-glucose(out) = D-glucose(in). Terms as in the reaction library (`BioCore.Rhea.rhea_60376`); compartments are not in the terms. -/
def rhea_60376 : FSum := [(-1, c4167), (1, c4167)]
/-- RHEA:19669: GTP + H2O = GDP + phosphate + H(+). Terms as in the reaction library (`BioCore.Rhea.rhea_19669`); compartments are not in the terms. -/
def rhea_19669 : FSum := [(-1, c15377), (-1, c37565), (1, c15378), (1, c58189), (1, c43474)]
/-- RHEA:13065: ATP + H2O = ADP + phosphate + H(+). Terms as in the reaction library (`BioCore.Rhea.rhea_13065`); compartments are not in the terms. -/
def rhea_13065 : FSum := [(-1, c15377), (-1, c30616), (1, c456216), (1, c15378), (1, c43474)]
/-- RHEA:16237: [protein]-peptidylproline (omega=180) = [protein]-peptidylproline (omega=0). Terms as in the reaction library (`BioCore.Rhea.rhea_16237`); compartments are not in the terms. -/
def rhea_16237 : FSum := [(-1, c83834), (1, c83833)]
/-- RHEA:18105: Ca(2+)(in) + ATP + H2O = Ca(2+)(out) + ADP + phosphate + H(+). Terms as in the reaction library (`BioCore.Rhea.rhea_18105`); compartments are not in the terms. -/
def rhea_18105 : FSum := [(-1, c15377), (-1, c29108), (-1, c30616), (1, c456216), (1, c29108), (1, c15378), (1, c43474)]

end BioCore.Sites.Sp
