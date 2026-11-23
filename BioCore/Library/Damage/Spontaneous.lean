import BioCore.Library.Damage.Species
import BioCore.Library.Damage.Basic
/-!
# BioCore.Library.Damage.Spontaneous

GENERATED FILE (gen/dg_spont.py; the reaction data are hand-kept in that script). Spontaneous damage reactions that Rhea
release 143 does not hold as records, written with ChEBI release 257 species (rule-derived species are marked in their
names) and proved balanced. Each docstring names the source for the claim that the reaction occurs without an enzyme.
THAT CLAIM IS AN ASSUMPTION copied from the source; the kernel checks only the element and charge balance.
Read depth of every PubMed source: abstract, unless the docstring says otherwise.
For each reaction: `Balanced`, one false variant, and the proof that the false variant is refused. Reactions that are
unbalanced as usually written are kept, with the proof that they are unbalanced, next to their corrected form.
-/
namespace BioCore.Damage.Spont
open BioCore BioCore.Damage BioCore.Damage.Sp

/-- C20 · methionine to the sulfoxide by hydrogen peroxide.
Source (no enzyme): PMID:8986759 (Levine 1996; abstract: oxidants react readily with methionine to form the sulfoxide; hydrogen peroxide on a protein in vitro).
Reaction: L-methionine residue + hydrogen peroxide = L-methionine S-oxide residue + water -/
def met_sulfoxide : FSum :=
  [(-1, c16044), (-1, c16240), (1, c15989), (1, c15377)]
theorem met_sulfoxide_balanced : Balanced met_sulfoxide := by decide
/-- False variant of `met_sulfoxide`: water left out.
Written: L-methionine residue + hydrogen peroxide = L-methionine S-oxide residue -/
def met_sulfoxide_false : FSum :=
  [(-1, c16044), (-1, c16240), (1, c15989)]
theorem met_sulfoxide_false_refused : ¬ Balanced met_sulfoxide_false := by decide

/-- C20 · methionine to the (S)-sulfoxide (the diastereomer reduced by MsrA).
Source (no enzyme): PMID:8986759 (Levine 1996; abstract: oxidants react readily with methionine to form the sulfoxide; hydrogen peroxide on a protein in vitro).
Reaction: L-methionine residue + hydrogen peroxide = L-methionine (S)-S-oxide residue + water -/
def met_S_sulfoxide : FSum :=
  [(-1, c16044), (-1, c16240), (1, c44120), (1, c15377)]
theorem met_S_sulfoxide_balanced : Balanced met_S_sulfoxide := by decide
/-- False variant of `met_S_sulfoxide`: dioxygen instead of hydrogen peroxide.
Written: L-methionine residue + dioxygen = L-methionine (S)-S-oxide residue + water -/
def met_S_sulfoxide_false : FSum :=
  [(-1, c16044), (-1, c15379), (1, c44120), (1, c15377)]
theorem met_S_sulfoxide_false_refused : ¬ Balanced met_S_sulfoxide_false := by decide

/-- C20 · methionine to the (R)-sulfoxide (the diastereomer reduced by MsrB).
Source (no enzyme): PMID:8986759 (Levine 1996; abstract: oxidants react readily with methionine to form the sulfoxide; hydrogen peroxide on a protein in vitro).
Reaction: L-methionine residue + hydrogen peroxide = L-methionine (R)-S-oxide residue + water -/
def met_R_sulfoxide : FSum :=
  [(-1, c16044), (-1, c16240), (1, c45764), (1, c15377)]
theorem met_R_sulfoxide_balanced : Balanced met_R_sulfoxide := by decide
/-- False variant of `met_R_sulfoxide`: two waters.
Written: L-methionine residue + hydrogen peroxide = L-methionine (R)-S-oxide residue + 2 water -/
def met_R_sulfoxide_false : FSum :=
  [(-1, c16044), (-1, c16240), (1, c45764), (2, c15377)]
theorem met_R_sulfoxide_false_refused : ¬ Balanced met_R_sulfoxide_false := by decide

/-- C20 · methionine sulfoxide to the sulfone.
Source (no enzyme): PMID:32702142 (Castano 2021; abstract: photosensitized oxidation gives the sulfoxide and the sulfone); PMID:32530275 (Hinterholzer 2020; abstract: sulfone identified among oxidation products of antibodies). The oxidant is written as hydrogen peroxide; where the source names another oxidant or none, this choice is an assumption of the library.
Reaction: L-methionine S-oxide residue + hydrogen peroxide = L-methionine sulfone residue + water -/
def met_sulfone : FSum :=
  [(-1, c15989), (-1, c16240), (1, c156065), (1, c15377)]
theorem met_sulfone_balanced : Balanced met_sulfone := by decide
/-- False variant of `met_sulfone`: water left out.
Written: L-methionine S-oxide residue + hydrogen peroxide = L-methionine sulfone residue -/
def met_sulfone_false : FSum :=
  [(-1, c15989), (-1, c16240), (1, c156065)]
theorem met_sulfone_false_refused : ¬ Balanced met_sulfone_false := by decide

/-- C21 · cysteine to the sulfenic acid by hydrogen peroxide.
Source (no enzyme): PMID:12924939 (Carballal 2003; abstract: albumin Cys34 thiol + H2O2 gives the sulfenic acid, 1:1).
Reaction: L-cysteine residue + hydrogen peroxide = S-hydroxy-L-cysteine residue + water -/
def cys_sulfenic : FSum :=
  [(-1, c29950), (-1, c16240), (1, c61973), (1, c15377)]
theorem cys_sulfenic_balanced : Balanced cys_sulfenic := by decide
/-- False variant of `cys_sulfenic`: dioxygen instead of hydrogen peroxide.
Written: L-cysteine residue + dioxygen = S-hydroxy-L-cysteine residue + water -/
def cys_sulfenic_false : FSum :=
  [(-1, c29950), (-1, c15379), (1, c61973), (1, c15377)]
theorem cys_sulfenic_false_refused : ¬ Balanced cys_sulfenic_false := by decide

/-- C21 · sulfenic to sulfinic acid as usually written (no hydron), with ChEBI's sulfinate(1-) residue.
Source (no enzyme): PMID:33515755 (Turell 2021; abstract: with H2O2 the sulfenic acid is further oxidized to sulfinic and sulfonic acid); PMID:19737009 (Hugo 2009; abstract).
Reaction: S-hydroxy-L-cysteine residue + hydrogen peroxide = 3-sulfino-L-alanine(1-) residue + water -/
def cys_sulfinic_as_written : FSum :=
  [(-1, c61973), (-1, c16240), (1, c61974), (1, c15377)]
/-- **Proved unbalanced as written.** -/
theorem cys_sulfinic_as_written_unbalanced : ¬ Balanced cys_sulfinic_as_written := by decide

/-- C21 · sulfenic to sulfinic acid, corrected: one hydron released.
Source (no enzyme): PMID:33515755 (Turell 2021; abstract: with H2O2 the sulfenic acid is further oxidized to sulfinic and sulfonic acid); PMID:19737009 (Hugo 2009; abstract).
Reaction: S-hydroxy-L-cysteine residue + hydrogen peroxide = 3-sulfino-L-alanine(1-) residue + water + hydron -/
def cys_sulfinic : FSum :=
  [(-1, c61973), (-1, c16240), (1, c61974), (1, c15377), (1, c15378)]
theorem cys_sulfinic_balanced : Balanced cys_sulfinic := by decide
/-- False variant of `cys_sulfinic`: hydron left out (the usual way of writing it).
Written: S-hydroxy-L-cysteine residue + hydrogen peroxide = 3-sulfino-L-alanine(1-) residue + water -/
def cys_sulfinic_false : FSum :=
  [(-1, c61973), (-1, c16240), (1, c61974), (1, c15377)]
theorem cys_sulfinic_false_refused : ¬ Balanced cys_sulfinic_false := by decide

/-- C21 · sulfenic to sulfinic acid with the uncharged residue CHEBI:61967.
Source (no enzyme): PMID:33515755 (Turell 2021; abstract: with H2O2 the sulfenic acid is further oxidized to sulfinic and sulfonic acid); PMID:19737009 (Hugo 2009; abstract).
Reaction: S-hydroxy-L-cysteine residue + hydrogen peroxide = 3-sulfino-L-alanine residue + water -/
def cys_sulfinic_neutral : FSum :=
  [(-1, c61973), (-1, c16240), (1, c61967), (1, c15377)]
theorem cys_sulfinic_neutral_balanced : Balanced cys_sulfinic_neutral := by decide
/-- False variant of `cys_sulfinic_neutral`: water left out.
Written: S-hydroxy-L-cysteine residue + hydrogen peroxide = 3-sulfino-L-alanine residue -/
def cys_sulfinic_neutral_false : FSum :=
  [(-1, c61973), (-1, c16240), (1, c61967)]
theorem cys_sulfinic_neutral_false_refused : ¬ Balanced cys_sulfinic_neutral_false := by decide

/-- C21 · sulfinic to sulfonic acid (cysteate residue).
Source (no enzyme): PMID:33515755 (Turell 2021; abstract: with H2O2 the sulfenic acid is further oxidized to sulfinic and sulfonic acid); PMID:19737009 (Hugo 2009; abstract).
Reaction: 3-sulfino-L-alanine(1-) residue + hydrogen peroxide = L-cysteate residue + water -/
def cys_sulfonic : FSum :=
  [(-1, c61974), (-1, c16240), (1, c141830), (1, c15377)]
theorem cys_sulfonic_balanced : Balanced cys_sulfonic := by decide
/-- False variant of `cys_sulfonic`: water left out.
Written: 3-sulfino-L-alanine(1-) residue + hydrogen peroxide = L-cysteate residue -/
def cys_sulfonic_false : FSum :=
  [(-1, c61974), (-1, c16240), (1, c141830)]
theorem cys_sulfonic_false_refused : ¬ Balanced cys_sulfonic_false := by decide

/-- C25 · asparagine to the succinimide, ammonium released.
Source (no enzyme): PMID:3805008 (Geiger 1987; abstract: spontaneous deamidation, isomerization and racemization through a succinimide in peptides at pH 7.4, 37 C). The succinimide residue is rule-derived (R3).
Reaction: L-asparagine residue + hydron = L-aspartyl succinimide residue [rule R3 from CHEBI:29958] + ammonium -/
def asn_succinimide : FSum :=
  [(-1, c50347), (-1, c15378), (1, r3_29958), (1, c28938)]
theorem asn_succinimide_balanced : Balanced asn_succinimide := by decide
/-- False variant of `asn_succinimide`: hydron left out.
Written: L-asparagine residue = L-aspartyl succinimide residue [rule R3 from CHEBI:29958] + ammonium -/
def asn_succinimide_false : FSum :=
  [(-1, c50347), (1, r3_29958), (1, c28938)]
theorem asn_succinimide_false_refused : ¬ Balanced asn_succinimide_false := by decide

/-- C25 · hydrolysis of the succinimide to aspartate.
Source (no enzyme): PMID:3805008 (Geiger 1987; abstract: spontaneous deamidation, isomerization and racemization through a succinimide in peptides at pH 7.4, 37 C). The succinimide residue is rule-derived (R3).
Reaction: L-aspartyl succinimide residue [rule R3 from CHEBI:29958] + water = L-aspartate residue + hydron -/
def succinimide_asp : FSum :=
  [(-1, r3_29958), (-1, c15377), (1, c29961), (1, c15378)]
theorem succinimide_asp_balanced : Balanced succinimide_asp := by decide
/-- False variant of `succinimide_asp`: water left out.
Written: L-aspartyl succinimide residue [rule R3 from CHEBI:29958] = L-aspartate residue + hydron -/
def succinimide_asp_false : FSum :=
  [(-1, r3_29958), (1, c29961), (1, c15378)]
theorem succinimide_asp_false_refused : ¬ Balanced succinimide_asp_false := by decide

/-- C25 · hydrolysis of the succinimide to isoaspartate.
Source (no enzyme): PMID:3805008 (Geiger 1987; abstract: spontaneous deamidation, isomerization and racemization through a succinimide in peptides at pH 7.4, 37 C). The succinimide residue is rule-derived (R3).
Reaction: L-aspartyl succinimide residue [rule R3 from CHEBI:29958] + water = L-beta-isoaspartate residue + hydron -/
def succinimide_isoasp : FSum :=
  [(-1, r3_29958), (-1, c15377), (1, c90596), (1, c15378)]
theorem succinimide_isoasp_balanced : Balanced succinimide_isoasp := by decide
/-- False variant of `succinimide_isoasp`: hydron left out.
Written: L-aspartyl succinimide residue [rule R3 from CHEBI:29958] + water = L-beta-isoaspartate residue -/
def succinimide_isoasp_false : FSum :=
  [(-1, r3_29958), (-1, c15377), (1, c90596)]
theorem succinimide_isoasp_false_refused : ¬ Balanced succinimide_isoasp_false := by decide

/-- C25 · deamidation of asparagine to isoaspartate (net).
Source (no enzyme): PMID:3805008 (Geiger 1987; abstract: spontaneous deamidation, isomerization and racemization through a succinimide in peptides at pH 7.4, 37 C).
Reaction: L-asparagine residue + water = L-beta-isoaspartate residue + ammonium -/
def asn_isoasp : FSum :=
  [(-1, c50347), (-1, c15377), (1, c90596), (1, c28938)]
theorem asn_isoasp_balanced : Balanced asn_isoasp := by decide
/-- False variant of `asn_isoasp`: ammonia instead of ammonium.
Written: L-asparagine residue + water = L-beta-isoaspartate residue + ammonia -/
def asn_isoasp_false : FSum :=
  [(-1, c50347), (-1, c15377), (1, c90596), (1, c16134)]
theorem asn_isoasp_false_refused : ¬ Balanced asn_isoasp_false := by decide

/-- C25 · aspartate to the succinimide (first step of isomerisation).
Source (no enzyme): PMID:3805008 (Geiger 1987; abstract: spontaneous deamidation, isomerization and racemization through a succinimide in peptides at pH 7.4, 37 C). The succinimide residue is rule-derived (R3).
Reaction: L-aspartate residue + hydron = L-aspartyl succinimide residue [rule R3 from CHEBI:29958] + water -/
def asp_succinimide : FSum :=
  [(-1, c29961), (-1, c15378), (1, r3_29958), (1, c15377)]
theorem asp_succinimide_balanced : Balanced asp_succinimide := by decide
/-- False variant of `asp_succinimide`: hydron left out.
Written: L-aspartate residue = L-aspartyl succinimide residue [rule R3 from CHEBI:29958] + water -/
def asp_succinimide_false : FSum :=
  [(-1, c29961), (1, r3_29958), (1, c15377)]
theorem asp_succinimide_false_refused : ¬ Balanced asp_succinimide_false := by decide

/-- C25 · isomerisation of aspartate to isoaspartate (net; no change of formula).
Source (no enzyme): PMID:3805008 (Geiger 1987; abstract: spontaneous deamidation, isomerization and racemization through a succinimide in peptides at pH 7.4, 37 C).
Reaction: L-aspartate residue = L-beta-isoaspartate residue -/
def asp_isoasp : FSum :=
  [(-1, c29961), (1, c90596)]
theorem asp_isoasp_balanced : Balanced asp_isoasp := by decide
/-- False variant of `asp_isoasp`: product written as the uncharged aspartic acid residue.
Written: L-aspartate residue = L-aspartic acid residue -/
def asp_isoasp_false : FSum :=
  [(-1, c29961), (1, c29958)]
theorem asp_isoasp_false_refused : ¬ Balanced asp_isoasp_false := by decide

/-- C26 · L-aspartate residue to D-aspartate residue (no change of formula).
Source (no enzyme): PMID:1059082 (Helfman 1975; abstract: aspartic acid racemization in tooth enamel of living humans); PMID:3805008 (abstract).
Reaction: L-aspartate residue = D-aspartate residue -/
def asp_racemization : FSum :=
  [(-1, c29961), (1, c29962)]
theorem asp_racemization_balanced : Balanced asp_racemization := by decide
/-- False variant of `asp_racemization`: product written as the uncharged D-aspartic acid residue.
Written: L-aspartate residue = D-aspartic acid residue -/
def asp_racemization_false : FSum :=
  [(-1, c29961), (1, c48094)]
theorem asp_racemization_false_refused : ¬ Balanced asp_racemization_false := by decide

/-- C19 · first glycation step on an N-terminal valine (as in HbA1c): Amadori product.
Source (no enzyme): PMID:3930480 (Lowrey 1985; abstract: HbA1c forms by nonenzymatic addition of glucose to the alpha-amino group of the beta chain, condensation then Amadori rearrangement). The product residue is rule-derived (R1) from ChEBI's free fructosyl valine.
Reaction: L-valine residue + aldehydo-D-glucose = N-(1-deoxy-D-fructos-1-yl)-L-valine N-terminal residue [rule R1 from CHEBI:178071] + water -/
def glycation_nterm_valine : FSum :=
  [(-1, c30015), (-1, c42758), (1, r1_178071), (1, c15377)]
theorem glycation_nterm_valine_balanced : Balanced glycation_nterm_valine := by decide
/-- False variant of `glycation_nterm_valine`: water left out.
Written: L-valine residue + aldehydo-D-glucose = N-(1-deoxy-D-fructos-1-yl)-L-valine N-terminal residue [rule R1 from CHEBI:178071] -/
def glycation_nterm_valine_false : FSum :=
  [(-1, c30015), (-1, c42758), (1, r1_178071)]
theorem glycation_nterm_valine_false_refused : ¬ Balanced glycation_nterm_valine_false := by decide

/-- C19 · carboxymethyl-lysine from glyoxal.
Source (no enzyme): PMID:7730303 (Glomb 1995; abstract: carboxymethyl-lysine forms from glyoxal and protein under physiological conditions, not dependent on oxidation).
Reaction: L-lysinium residue + glyoxal = N(6)-carboxymethyl-L-lysine residue + hydron -/
def cml_from_glyoxal : FSum :=
  [(-1, c29969), (-1, c34779), (1, c53015), (1, c15378)]
theorem cml_from_glyoxal_balanced : Balanced cml_from_glyoxal := by decide
/-- False variant of `cml_from_glyoxal`: hydron left out.
Written: L-lysinium residue + glyoxal = N(6)-carboxymethyl-L-lysine residue -/
def cml_from_glyoxal_false : FSum :=
  [(-1, c29969), (-1, c34779), (1, c53015)]
theorem cml_from_glyoxal_false_refused : ¬ Balanced cml_from_glyoxal_false := by decide

/-- C19 · oxidative cleavage of fructosyl-lysine to carboxymethyl-lysine and erythronate.
Source (no enzyme): PMID:3082871 (Ahmed 1986; abstract: oxidative cleavage of fructoselysine gives carboxymethyl-lysine and erythronic acid; not formed under nitrogen). Dioxygen as the oxidant follows the source (no product under nitrogen); the hydron count is fixed by the ChEBI charge states.
Reaction: N(6)-(D-fructosyl)-L-lysinium residue + dioxygen = N(6)-carboxymethyl-L-lysine residue + D-erythronate + 2 hydron -/
def cml_from_fructosyl_lysine : FSum :=
  [(-1, c143253), (-1, c15379), (1, c53015), (1, c136591), (2, c15378)]
theorem cml_from_fructosyl_lysine_balanced : Balanced cml_from_fructosyl_lysine := by decide
/-- False variant of `cml_from_fructosyl_lysine`: no oxidant.
Written: N(6)-(D-fructosyl)-L-lysinium residue = N(6)-carboxymethyl-L-lysine residue + D-erythronate + 2 hydron -/
def cml_from_fructosyl_lysine_false : FSum :=
  [(-1, c143253), (1, c53015), (1, c136591), (2, c15378)]
theorem cml_from_fructosyl_lysine_false_refused : ¬ Balanced cml_from_fructosyl_lysine_false := by decide

/-- C19 · pentosidine from lysine, arginine and ribose written as a pure condensation.
Source (no enzyme): PMID:2513322 (Sell 1989; abstract: pentosidine, a lysine and an arginine residue cross-linked by a pentose, made in vitro by the nonenzymatic reaction of ribose with lysine and arginine residues). The crosslink species is rule-derived (R1 x2). Two hydrogens are left over: the formulas require an oxidant.
Reaction: L-lysinium residue + L-argininium residue + aldehydo-D-ribose = pentosidine crosslink of two residues [rule R1 x2 from CHEBI:59951] + 5 water + 2 hydron -/
def pentosidine_no_oxidant : FSum :=
  [(-1, c29969), (-1, c29965), (-1, c47014), (1, r1x2_59951), (5, c15377), (2, c15378)]
/-- **Proved unbalanced as written.** -/
theorem pentosidine_no_oxidant_unbalanced : ¬ Balanced pentosidine_no_oxidant := by decide

/-- C19 · pentosidine from lysine, arginine and ribose with dioxygen reduced to hydrogen peroxide.
Source (no enzyme): PMID:2513322 (Sell 1989; abstract: pentosidine, a lysine and an arginine residue cross-linked by a pentose, made in vitro by the nonenzymatic reaction of ribose with lysine and arginine residues). The crosslink species is rule-derived (R1 x2). That an oxidation is needed is proved (`pentosidine_no_oxidant_unbalanced`); WHICH oxidant acts, and that it ends as hydrogen peroxide, is an assumption of the library, not a statement of the source.
Reaction: L-lysinium residue + L-argininium residue + aldehydo-D-ribose + dioxygen = pentosidine crosslink of two residues [rule R1 x2 from CHEBI:59951] + 5 water + hydrogen peroxide + 2 hydron -/
def pentosidine : FSum :=
  [(-1, c29969), (-1, c29965), (-1, c47014), (-1, c15379), (1, r1x2_59951), (5, c15377), (1, c16240), (2, c15378)]
theorem pentosidine_balanced : Balanced pentosidine := by decide
/-- False variant of `pentosidine`: four waters instead of five.
Written: L-lysinium residue + L-argininium residue + aldehydo-D-ribose + dioxygen = pentosidine crosslink of two residues [rule R1 x2 from CHEBI:59951] + 4 water + hydrogen peroxide + 2 hydron -/
def pentosidine_false : FSum :=
  [(-1, c29969), (-1, c29965), (-1, c47014), (-1, c15379), (1, r1x2_59951), (4, c15377), (1, c16240), (2, c15378)]
theorem pentosidine_false_refused : ¬ Balanced pentosidine_false := by decide

/-- C27 · urea dissociates to cyanate and ammonium.
Source (no enzyme): PMID:8544421 (Stim 1995; abstract: carbamylated haemoglobin forms by reaction with cyanate, a product of urea dissociation; measured as valine hydantoin); PMID:965383 (Slebe 1976; abstract: carbamylation of lysyl residues by KNCO).
Reaction: urea = cyanate + ammonium -/
def urea_to_cyanate : FSum :=
  [(-1, c16199), (1, c29195), (1, c28938)]
theorem urea_to_cyanate_balanced : Balanced urea_to_cyanate := by decide
/-- False variant of `urea_to_cyanate`: ammonia instead of ammonium.
Written: urea = cyanate + ammonia -/
def urea_to_cyanate_false : FSum :=
  [(-1, c16199), (1, c29195), (1, c16134)]
theorem urea_to_cyanate_false_refused : ¬ Balanced urea_to_cyanate_false := by decide

/-- C27 · isocyanic acid + lysine = homocitrulline, with ChEBI's lysinium(1+) residue, as usually written.
Source (no enzyme): PMID:8544421 (Stim 1995; abstract: carbamylated haemoglobin forms by reaction with cyanate, a product of urea dissociation; measured as valine hydantoin); PMID:965383 (Slebe 1976; abstract: carbamylation of lysyl residues by KNCO).
Reaction: isocyanic acid + L-lysinium residue = L-homocitrulline residue -/
def carbamylation_as_written : FSum :=
  [(-1, c29202), (-1, c29969), (1, c144369)]
/-- **Proved unbalanced as written.** -/
theorem carbamylation_as_written_unbalanced : ¬ Balanced carbamylation_as_written := by decide

/-- C27 · carbamylation of lysine, corrected: one hydron released.
Source (no enzyme): PMID:8544421 (Stim 1995; abstract: carbamylated haemoglobin forms by reaction with cyanate, a product of urea dissociation; measured as valine hydantoin); PMID:965383 (Slebe 1976; abstract: carbamylation of lysyl residues by KNCO).
Reaction: isocyanic acid + L-lysinium residue = L-homocitrulline residue + hydron -/
def carbamylation : FSum :=
  [(-1, c29202), (-1, c29969), (1, c144369), (1, c15378)]
theorem carbamylation_balanced : Balanced carbamylation := by decide
/-- False variant of `carbamylation`: hydron left out (the usual form).
Written: isocyanic acid + L-lysinium residue = L-homocitrulline residue -/
def carbamylation_false : FSum :=
  [(-1, c29202), (-1, c29969), (1, c144369)]
theorem carbamylation_false_refused : ¬ Balanced carbamylation_false := by decide

/-- C27 · carbamylation of lysine written with cyanate(1-).
Source (no enzyme): PMID:8544421 (Stim 1995; abstract: carbamylated haemoglobin forms by reaction with cyanate, a product of urea dissociation; measured as valine hydantoin); PMID:965383 (Slebe 1976; abstract: carbamylation of lysyl residues by KNCO).
Reaction: cyanate + L-lysinium residue = L-homocitrulline residue -/
def carbamylation_by_cyanate : FSum :=
  [(-1, c29195), (-1, c29969), (1, c144369)]
theorem carbamylation_by_cyanate_balanced : Balanced carbamylation_by_cyanate := by decide
/-- False variant of `carbamylation_by_cyanate`: isocyanic acid instead of cyanate.
Written: isocyanic acid + L-lysinium residue = L-homocitrulline residue -/
def carbamylation_by_cyanate_false : FSum :=
  [(-1, c29202), (-1, c29969), (1, c144369)]
theorem carbamylation_by_cyanate_false_refused : ¬ Balanced carbamylation_by_cyanate_false := by decide

/-- C27 · carbamylation of an N-terminal valine (as in carbamylated haemoglobin).
Source (no enzyme): PMID:8544421 (Stim 1995; abstract: carbamylated haemoglobin forms by reaction with cyanate, a product of urea dissociation; measured as valine hydantoin); PMID:965383 (Slebe 1976; abstract: carbamylation of lysyl residues by KNCO). The product residue is rule-derived (R1) from ChEBI's free N-carbamoyl-L-valine.
Reaction: L-valine residue + isocyanic acid = N-carbamoyl-L-valine N-terminal residue [rule R1 from CHEBI:49054] -/
def carbamylation_nterm_valine : FSum :=
  [(-1, c30015), (-1, c29202), (1, r1_49054)]
theorem carbamylation_nterm_valine_balanced : Balanced carbamylation_nterm_valine := by decide
/-- False variant of `carbamylation_nterm_valine`: a water written as released.
Written: L-valine residue + isocyanic acid = N-carbamoyl-L-valine N-terminal residue [rule R1 from CHEBI:49054] + water -/
def carbamylation_nterm_valine_false : FSum :=
  [(-1, c30015), (-1, c29202), (1, r1_49054), (1, c15377)]
theorem carbamylation_nterm_valine_false_refused : ¬ Balanced carbamylation_nterm_valine_false := by decide

/-- C23 · tyrosine + nitrogen dioxide = 3-nitrotyrosine, the shortest form.
Source (no enzyme): PMID:15020765 (Radi 2004; abstract: oxidation of tyrosine to the tyrosyl radical followed by reaction with nitrogen dioxide gives 3-nitrotyrosine); PMID:32016371 (Campolo 2020; abstract).
Reaction: L-tyrosine residue + nitrogen dioxide = 3-nitro-L-tyrosine residue -/
def nitration_as_written : FSum :=
  [(-1, c46858), (-1, c33101), (1, c155899)]
/-- **Proved unbalanced as written.** -/
theorem nitration_as_written_unbalanced : ¬ Balanced nitration_as_written := by decide

/-- C23 · nitration by two nitrogen dioxide radicals, nitrite and a hydron released.
Source (no enzyme): PMID:15020765 (Radi 2004; abstract: oxidation of tyrosine to the tyrosyl radical followed by reaction with nitrogen dioxide gives 3-nitrotyrosine); PMID:32016371 (Campolo 2020; abstract).
Reaction: L-tyrosine residue + 2 nitrogen dioxide = 3-nitro-L-tyrosine residue + nitrite + hydron -/
def nitration_two_no2 : FSum :=
  [(-1, c46858), (-2, c33101), (1, c155899), (1, c16301), (1, c15378)]
theorem nitration_two_no2_balanced : Balanced nitration_two_no2 := by decide
/-- False variant of `nitration_two_no2`: one nitrogen dioxide instead of two.
Written: L-tyrosine residue + nitrogen dioxide = 3-nitro-L-tyrosine residue + nitrite + hydron -/
def nitration_two_no2_false : FSum :=
  [(-1, c46858), (-1, c33101), (1, c155899), (1, c16301), (1, c15378)]
theorem nitration_two_no2_false_refused : ¬ Balanced nitration_two_no2_false := by decide

/-- C23 · hydroxyl radical abstracts a hydrogen atom from tyrosine.
Source (no enzyme): PMID:15020765 (Radi 2004; abstract: oxidation of tyrosine to the tyrosyl radical followed by reaction with nitrogen dioxide gives 3-nitrotyrosine); PMID:32016371 (Campolo 2020; abstract).
Reaction: L-tyrosine residue + hydroxyl = L-tyrosinyl radical residue + water -/
def tyrosyl_radical_formation : FSum :=
  [(-1, c46858), (-1, c29191), (1, c32766), (1, c15377)]
theorem tyrosyl_radical_formation_balanced : Balanced tyrosyl_radical_formation := by decide
/-- False variant of `tyrosyl_radical_formation`: water left out.
Written: L-tyrosine residue + hydroxyl = L-tyrosinyl radical residue -/
def tyrosyl_radical_formation_false : FSum :=
  [(-1, c46858), (-1, c29191), (1, c32766)]
theorem tyrosyl_radical_formation_false_refused : ¬ Balanced tyrosyl_radical_formation_false := by decide

/-- C23 · tyrosyl radical + nitrogen dioxide = 3-nitrotyrosine.
Source (no enzyme): PMID:15020765 (Radi 2004; abstract: oxidation of tyrosine to the tyrosyl radical followed by reaction with nitrogen dioxide gives 3-nitrotyrosine); PMID:32016371 (Campolo 2020; abstract).
Reaction: L-tyrosinyl radical residue + nitrogen dioxide = 3-nitro-L-tyrosine residue -/
def radical_coupling_with_no2 : FSum :=
  [(-1, c32766), (-1, c33101), (1, c155899)]
theorem radical_coupling_with_no2_balanced : Balanced radical_coupling_with_no2 := by decide
/-- False variant of `radical_coupling_with_no2`: nitric oxide instead of nitrogen dioxide.
Written: L-tyrosinyl radical residue + nitric oxide = 3-nitro-L-tyrosine residue -/
def radical_coupling_with_no2_false : FSum :=
  [(-1, c32766), (-1, c16480), (1, c155899)]
theorem radical_coupling_with_no2_false_refused : ¬ Balanced radical_coupling_with_no2_false := by decide

/-- C23 · peroxynitrite + hydron = peroxynitrous acid.
Source (no enzyme): PMID:15020765 (Radi 2004; abstract: oxidation of tyrosine to the tyrosyl radical followed by reaction with nitrogen dioxide gives 3-nitrotyrosine); PMID:32016371 (Campolo 2020; abstract).
Reaction: peroxynitrite + hydron = peroxynitrous acid -/
def peroxynitrite_protonation : FSum :=
  [(-1, c25941), (-1, c15378), (1, c25942)]
theorem peroxynitrite_protonation_balanced : Balanced peroxynitrite_protonation := by decide
/-- False variant of `peroxynitrite_protonation`: hydron left out.
Written: peroxynitrite = peroxynitrous acid -/
def peroxynitrite_protonation_false : FSum :=
  [(-1, c25941), (1, c25942)]
theorem peroxynitrite_protonation_false_refused : ¬ Balanced peroxynitrite_protonation_false := by decide

/-- C23 · peroxynitrous acid = hydroxyl + nitrogen dioxide.
Source (no enzyme): PMID:15020765 (Radi 2004; abstract: oxidation of tyrosine to the tyrosyl radical followed by reaction with nitrogen dioxide gives 3-nitrotyrosine); PMID:32016371 (Campolo 2020; abstract).
Reaction: peroxynitrous acid = hydroxyl + nitrogen dioxide -/
def peroxynitrous_acid_homolysis : FSum :=
  [(-1, c25942), (1, c29191), (1, c33101)]
theorem peroxynitrous_acid_homolysis_balanced : Balanced peroxynitrous_acid_homolysis := by decide
/-- False variant of `peroxynitrous_acid_homolysis`: the anion instead of the acid.
Written: peroxynitrite = hydroxyl + nitrogen dioxide -/
def peroxynitrous_acid_homolysis_false : FSum :=
  [(-1, c25941), (1, c29191), (1, c33101)]
theorem peroxynitrous_acid_homolysis_false_refused : ¬ Balanced peroxynitrous_acid_homolysis_false := by decide

/-- C23 · net nitration by peroxynitrite.
Source (no enzyme): PMID:15020765 (Radi 2004; abstract: oxidation of tyrosine to the tyrosyl radical followed by reaction with nitrogen dioxide gives 3-nitrotyrosine); PMID:32016371 (Campolo 2020; abstract).
Reaction: L-tyrosine residue + peroxynitrite + hydron = 3-nitro-L-tyrosine residue + water -/
def nitration_by_peroxynitrite : FSum :=
  [(-1, c46858), (-1, c25941), (-1, c15378), (1, c155899), (1, c15377)]
theorem nitration_by_peroxynitrite_balanced : Balanced nitration_by_peroxynitrite := by decide
/-- False variant of `nitration_by_peroxynitrite`: hydron left out.
Written: L-tyrosine residue + peroxynitrite = 3-nitro-L-tyrosine residue + water -/
def nitration_by_peroxynitrite_false : FSum :=
  [(-1, c46858), (-1, c25941), (1, c155899), (1, c15377)]
theorem nitration_by_peroxynitrite_false_refused : ¬ Balanced nitration_by_peroxynitrite_false := by decide

/-- C23 · two tyrosine residues = dityrosine crosslink, the two hydrogens left out.
Source (no enzyme): PMID:9013599 (Leeuwenburgh 1997; abstract: tyrosyl radical forms o,o'-dityrosine cross-links; also formed by hydroxyl radical); PMID:8390491 (Heinecke 1993; abstract: the radical can be generated by myeloperoxidase, an enzyme). The crosslink species is rule-derived (R1 x2).
Reaction: 2 L-tyrosine residue = LL-dityrosine crosslink of two residues [rule R1 x2 from CHEBI:50609] -/
def dityrosine_as_written : FSum :=
  [(-2, c46858), (1, r1x2_50609)]
/-- **Proved unbalanced as written.** -/
theorem dityrosine_as_written_unbalanced : ¬ Balanced dityrosine_as_written := by decide

/-- C23 · two tyrosyl radical residues = dityrosine crosslink.
Source (no enzyme): PMID:9013599 (Leeuwenburgh 1997; abstract: tyrosyl radical forms o,o'-dityrosine cross-links; also formed by hydroxyl radical); PMID:8390491 (Heinecke 1993; abstract: the radical can be generated by myeloperoxidase, an enzyme). The crosslink species is rule-derived (R1 x2).
Reaction: 2 L-tyrosinyl radical residue = LL-dityrosine crosslink of two residues [rule R1 x2 from CHEBI:50609] -/
def dityrosine_radical_coupling : FSum :=
  [(-2, c32766), (1, r1x2_50609)]
theorem dityrosine_radical_coupling_balanced : Balanced dityrosine_radical_coupling := by decide
/-- False variant of `dityrosine_radical_coupling`: one radical and one intact tyrosine.
Written: L-tyrosinyl radical residue + L-tyrosine residue = LL-dityrosine crosslink of two residues [rule R1 x2 from CHEBI:50609] -/
def dityrosine_radical_coupling_false : FSum :=
  [(-1, c32766), (-1, c46858), (1, r1x2_50609)]
theorem dityrosine_radical_coupling_false_refused : ¬ Balanced dityrosine_radical_coupling_false := by decide

/-- C23 · two tyrosine residues + hydrogen peroxide = dityrosine crosslink + 2 water (net).
Source (no enzyme): PMID:9013599 (Leeuwenburgh 1997; abstract: tyrosyl radical forms o,o'-dityrosine cross-links; also formed by hydroxyl radical); PMID:8390491 (Heinecke 1993; abstract: the radical can be generated by myeloperoxidase, an enzyme). The crosslink species is rule-derived (R1 x2). The oxidant is written as hydrogen peroxide; where the source names another oxidant or none, this choice is an assumption of the library.
Reaction: 2 L-tyrosine residue + hydrogen peroxide = LL-dityrosine crosslink of two residues [rule R1 x2 from CHEBI:50609] + 2 water -/
def dityrosine_by_h2o2 : FSum :=
  [(-2, c46858), (-1, c16240), (1, r1x2_50609), (2, c15377)]
theorem dityrosine_by_h2o2_balanced : Balanced dityrosine_by_h2o2 := by decide
/-- False variant of `dityrosine_by_h2o2`: one water instead of two.
Written: 2 L-tyrosine residue + hydrogen peroxide = LL-dityrosine crosslink of two residues [rule R1 x2 from CHEBI:50609] + water -/
def dityrosine_by_h2o2_false : FSum :=
  [(-2, c46858), (-1, c16240), (1, r1x2_50609), (1, c15377)]
theorem dityrosine_by_h2o2_false_refused : ¬ Balanced dityrosine_by_h2o2_false := by decide

/-- C22 · lysine to allysine (aminoadipic semialdehyde) by oxidation, ammonium released.
Source (no enzyme): PMID:11120890 (Requena 2001; abstract: glutamic and aminoadipic semialdehydes are the main carbonyl products of metal-catalyzed oxidation of proteins in vitro). The oxidant is written as hydrogen peroxide; where the source names another oxidant or none, this choice is an assumption of the library. The source names the semialdehyde; ammonium as the leaving group is fixed by the formulas given the oxidant.
Reaction: L-lysinium residue + hydrogen peroxide = L-allysine residue + ammonium + water -/
def lys_to_allysine : FSum :=
  [(-1, c29969), (-1, c16240), (1, c131803), (1, c28938), (1, c15377)]
theorem lys_to_allysine_balanced : Balanced lys_to_allysine := by decide
/-- False variant of `lys_to_allysine`: water left out.
Written: L-lysinium residue + hydrogen peroxide = L-allysine residue + ammonium -/
def lys_to_allysine_false : FSum :=
  [(-1, c29969), (-1, c16240), (1, c131803), (1, c28938)]
theorem lys_to_allysine_false_refused : ¬ Balanced lys_to_allysine_false := by decide

/-- C22 · arginine to glutamic semialdehyde by oxidation, guanidinium released.
Source (no enzyme): PMID:11120890 (Requena 2001; abstract: glutamic and aminoadipic semialdehydes are the main carbonyl products of metal-catalyzed oxidation of proteins in vitro). The oxidant is written as hydrogen peroxide; where the source names another oxidant or none, this choice is an assumption of the library. The source names the semialdehyde only; guanidinium as the leaving group is an assumption of the library.
Reaction: L-argininium residue + hydrogen peroxide = L-glutamic 5-semialdehyde residue + guanidinium + water -/
def arg_to_glutamic_semialdehyde : FSum :=
  [(-1, c29965), (-1, c16240), (1, c41433), (1, c30087), (1, c15377)]
theorem arg_to_glutamic_semialdehyde_balanced : Balanced arg_to_glutamic_semialdehyde := by decide
/-- False variant of `arg_to_glutamic_semialdehyde`: water left out.
Written: L-argininium residue + hydrogen peroxide = L-glutamic 5-semialdehyde residue + guanidinium -/
def arg_to_glutamic_semialdehyde_false : FSum :=
  [(-1, c29965), (-1, c16240), (1, c41433), (1, c30087)]
theorem arg_to_glutamic_semialdehyde_false_refused : ¬ Balanced arg_to_glutamic_semialdehyde_false := by decide

/-- C22 · proline to glutamic semialdehyde by oxidation.
Source (no enzyme): PMID:11120890 (Requena 2001; abstract: glutamic and aminoadipic semialdehydes are the main carbonyl products of metal-catalyzed oxidation of proteins in vitro). The oxidant is written as hydrogen peroxide; where the source names another oxidant or none, this choice is an assumption of the library.
Reaction: L-proline residue + hydrogen peroxide = L-glutamic 5-semialdehyde residue + water -/
def pro_to_glutamic_semialdehyde : FSum :=
  [(-1, c50342), (-1, c16240), (1, c41433), (1, c15377)]
theorem pro_to_glutamic_semialdehyde_balanced : Balanced pro_to_glutamic_semialdehyde := by decide
/-- False variant of `pro_to_glutamic_semialdehyde`: dioxygen instead of hydrogen peroxide.
Written: L-proline residue + dioxygen = L-glutamic 5-semialdehyde residue + water -/
def pro_to_glutamic_semialdehyde_false : FSum :=
  [(-1, c50342), (-1, c15379), (1, c41433), (1, c15377)]
theorem pro_to_glutamic_semialdehyde_false_refused : ¬ Balanced pro_to_glutamic_semialdehyde_false := by decide

/-- C29 · 4-hydroxynonenal adds to a cysteine residue (Michael adduct).
Source (no enzyme): PMID:19692331 (Wakita 2009; abstract: 4-hydroxy-2-nonenal reacts with cysteine residues to a Michael addition adduct); PMID:19610654 (LoPachin 2009; abstract). The adduct residue is rule-derived (R1) from ChEBI's free adduct CHEBI:747433.
Reaction: L-cysteine residue + (E)-4-hydroxynon-2-enal = S-(4-hydroxynonanal-3-yl)-L-cysteine residue [rule R1 from CHEBI:747433] -/
def hne_cysteine_residue : FSum :=
  [(-1, c29950), (-1, c58968), (1, r1_747433)]
theorem hne_cysteine_residue_balanced : Balanced hne_cysteine_residue := by decide
/-- False variant of `hne_cysteine_residue`: a water written as released.
Written: L-cysteine residue + (E)-4-hydroxynon-2-enal = S-(4-hydroxynonanal-3-yl)-L-cysteine residue [rule R1 from CHEBI:747433] + water -/
def hne_cysteine_residue_false : FSum :=
  [(-1, c29950), (-1, c58968), (1, r1_747433), (1, c15377)]
theorem hne_cysteine_residue_false_refused : ¬ Balanced hne_cysteine_residue_false := by decide

/-- C29 · 4-hydroxynonenal adds to free cysteine (both species are ChEBI entries).
Source (no enzyme): PMID:19692331 (Wakita 2009; abstract: 4-hydroxy-2-nonenal reacts with cysteine residues to a Michael addition adduct); PMID:19610654 (LoPachin 2009; abstract).
Reaction: L-cysteine zwitterion + (E)-4-hydroxynon-2-enal = S-(4-hydroxynonanal-3-yl)-L-cysteine zwitterion -/
def hne_cysteine_free : FSum :=
  [(-1, c35235), (-1, c58968), (1, c747433)]
theorem hne_cysteine_free_balanced : Balanced hne_cysteine_free := by decide
/-- False variant of `hne_cysteine_free`: a water written as released.
Written: L-cysteine zwitterion + (E)-4-hydroxynon-2-enal = S-(4-hydroxynonanal-3-yl)-L-cysteine zwitterion + water -/
def hne_cysteine_free_false : FSum :=
  [(-1, c35235), (-1, c58968), (1, c747433), (1, c15377)]
theorem hne_cysteine_free_false_refused : ¬ Balanced hne_cysteine_free_false := by decide

/-- C31 · 5-methylcytosine to thymine in DNA.
Source (no enzyme): PMID:8152929 (Shen 1994; abstract: rate constants of spontaneous hydrolytic deamination of 5-methylcytosine and cytosine in double-stranded DNA at 37 C); PMID:2185829 (Frederico 1990; abstract).
Reaction: 5-methyl dCMP(1-) residue + water + hydron = thymidine 5'-monophosphate(1-) residue + ammonium -/
def methylcytosine_deamination : FSum :=
  [(-1, c85454), (-1, c15377), (-1, c15378), (1, c137386), (1, c28938)]
theorem methylcytosine_deamination_balanced : Balanced methylcytosine_deamination := by decide
/-- False variant of `methylcytosine_deamination`: hydron left out.
Written: 5-methyl dCMP(1-) residue + water = thymidine 5'-monophosphate(1-) residue + ammonium -/
def methylcytosine_deamination_false : FSum :=
  [(-1, c85454), (-1, c15377), (1, c137386), (1, c28938)]
theorem methylcytosine_deamination_false_refused : ¬ Balanced methylcytosine_deamination_false := by decide

/-- C31 · loss of adenine from DNA: abasic site.
Source (no enzyme): PMID:4626532 (Lindahl 1972; TITLE ONLY, the PubMed record has no abstract: 'Rate of depurination of native deoxyribonucleic acid'); PMID:8469282 (Lindahl 1993; abstract: hydrolysis of DNA occurs at significant rates in vivo); time-scale table row ts00118.
Reaction: 2'-deoxyadenosine 5'-monophosphate(1-) residue + water = 2'-deoxyribose 5'-monophosphate(1-) residue + adenine -/
def depurination_adenine : FSum :=
  [(-1, c90615), (-1, c15377), (1, c139095), (1, c16708)]
theorem depurination_adenine_balanced : Balanced depurination_adenine := by decide
/-- False variant of `depurination_adenine`: water left out.
Written: 2'-deoxyadenosine 5'-monophosphate(1-) residue = 2'-deoxyribose 5'-monophosphate(1-) residue + adenine -/
def depurination_adenine_false : FSum :=
  [(-1, c90615), (1, c139095), (1, c16708)]
theorem depurination_adenine_false_refused : ¬ Balanced depurination_adenine_false := by decide

/-- C31 · loss of guanine from DNA: abasic site.
Source (no enzyme): PMID:4626532 (Lindahl 1972; TITLE ONLY, the PubMed record has no abstract: 'Rate of depurination of native deoxyribonucleic acid'); PMID:8469282 (Lindahl 1993; abstract: hydrolysis of DNA occurs at significant rates in vivo); time-scale table row ts00118.
Reaction: 2'-deoxyguanosine 5'-monophosphate(1-) residue + water = 2'-deoxyribose 5'-monophosphate(1-) residue + guanine -/
def depurination_guanine : FSum :=
  [(-1, c85445), (-1, c15377), (1, c139095), (1, c16235)]
theorem depurination_guanine_balanced : Balanced depurination_guanine := by decide
/-- False variant of `depurination_guanine`: adenine written as the base released.
Written: 2'-deoxyguanosine 5'-monophosphate(1-) residue + water = 2'-deoxyribose 5'-monophosphate(1-) residue + adenine -/
def depurination_guanine_false : FSum :=
  [(-1, c85445), (-1, c15377), (1, c139095), (1, c16708)]
theorem depurination_guanine_false_refused : ¬ Balanced depurination_guanine_false := by decide

/-- C31 · guanine to 8-oxoguanine on the free nucleotide (both species are ChEBI entries).
Source (no enzyme): PMID:1656061 (Kasai 1991; abstract: the C-8 position of guanine in DNA is hydroxylated by oxygen-radical-producing agents in vitro and in vivo); PMID:3757945 (Kasai 1986; abstract). The oxidant is written as hydrogen peroxide; where the source names another oxidant or none, this choice is an assumption of the library.
Reaction: 2'-deoxyguanosine 5'-monophosphate(2-) + hydrogen peroxide = 8-oxo-dGMP(2-) + water -/
def guanine_oxidation_free : FSum :=
  [(-1, c57673), (-1, c16240), (1, c63224), (1, c15377)]
theorem guanine_oxidation_free_balanced : Balanced guanine_oxidation_free := by decide
/-- False variant of `guanine_oxidation_free`: water left out.
Written: 2'-deoxyguanosine 5'-monophosphate(2-) + hydrogen peroxide = 8-oxo-dGMP(2-) -/
def guanine_oxidation_free_false : FSum :=
  [(-1, c57673), (-1, c16240), (1, c63224)]
theorem guanine_oxidation_free_false_refused : ¬ Balanced guanine_oxidation_free_false := by decide

/-- C31 · guanine to 8-oxoguanine inside a strand.
Source (no enzyme): PMID:1656061 (Kasai 1991; abstract: the C-8 position of guanine in DNA is hydroxylated by oxygen-radical-producing agents in vitro and in vivo); PMID:3757945 (Kasai 1986; abstract). The oxidant is written as hydrogen peroxide; where the source names another oxidant or none, this choice is an assumption of the library. The 8-oxo residue is rule-derived (R2) from ChEBI's 8-oxo-dGMP(2-).
Reaction: 2'-deoxyguanosine 5'-monophosphate(1-) residue + hydrogen peroxide = 8-oxo-2'-deoxyguanosine 5'-monophosphate(1-) residue [rule R2 from CHEBI:63224] + water -/
def guanine_oxidation_dna : FSum :=
  [(-1, c85445), (-1, c16240), (1, r2_63224), (1, c15377)]
theorem guanine_oxidation_dna_balanced : Balanced guanine_oxidation_dna := by decide
/-- False variant of `guanine_oxidation_dna`: dioxygen instead of hydrogen peroxide.
Written: 2'-deoxyguanosine 5'-monophosphate(1-) residue + dioxygen = 8-oxo-2'-deoxyguanosine 5'-monophosphate(1-) residue [rule R2 from CHEBI:63224] + water -/
def guanine_oxidation_dna_false : FSum :=
  [(-1, c85445), (-1, c15379), (1, r2_63224), (1, c15377)]
theorem guanine_oxidation_dna_false_refused : ¬ Balanced guanine_oxidation_dna_false := by decide

/-- C31 · two adjacent thymidines to the cyclobutane dimer (the reverse of RHEA:10672; no change of formula).
Source (no enzyme): PMID:29405222 (Cadet 2018; abstract: UVB leads to cyclobutane pyrimidine dimers and pyrimidine (6-4) pyrimidone photoproducts).
Reaction: thymidine dimer(2-) residue = cyclobutadithymidine(2-) residue -/
def cyclobutane_dimer : FSum :=
  [(-1, c139519), (1, c65263)]
theorem cyclobutane_dimer_balanced : Balanced cyclobutane_dimer := by decide
/-- False variant of `cyclobutane_dimer`: a hydron written as released.
Written: thymidine dimer(2-) residue = cyclobutadithymidine(2-) residue + hydron -/
def cyclobutane_dimer_false : FSum :=
  [(-1, c139519), (1, c65263), (1, c15378)]
theorem cyclobutane_dimer_false_refused : ¬ Balanced cyclobutane_dimer_false := by decide

/-- C31 · two adjacent thymidines to the (6-4) photoproduct (the reverse of RHEA:62232; no change of formula).
Source (no enzyme): PMID:29405222 (Cadet 2018; abstract: UVB leads to cyclobutane pyrimidine dimers and pyrimidine (6-4) pyrimidone photoproducts).
Reaction: thymidine dimer(2-) residue = thymidine(6-4)thymidine(2-) residue -/
def six_four_photoproduct : FSum :=
  [(-1, c139519), (1, c145571)]
theorem six_four_photoproduct_balanced : Balanced six_four_photoproduct := by decide
/-- False variant of `six_four_photoproduct`: a water written as taken up.
Written: thymidine dimer(2-) residue + water = thymidine(6-4)thymidine(2-) residue -/
def six_four_photoproduct_false : FSum :=
  [(-1, c139519), (-1, c15377), (1, c145571)]
theorem six_four_photoproduct_false_refused : ¬ Balanced six_four_photoproduct_false := by decide

/-- The spontaneous reactions of this file that are proved balanced, in the direction written. -/
def spont : List FSum :=
  [met_sulfoxide, met_S_sulfoxide, met_R_sulfoxide, met_sulfone, cys_sulfenic, cys_sulfinic, cys_sulfinic_neutral, cys_sulfonic, asn_succinimide, succinimide_asp, succinimide_isoasp, asn_isoasp, asp_succinimide, asp_isoasp, asp_racemization, glycation_nterm_valine, cml_from_glyoxal, cml_from_fructosyl_lysine, pentosidine, urea_to_cyanate, carbamylation, carbamylation_by_cyanate, carbamylation_nterm_valine, nitration_two_no2, tyrosyl_radical_formation, radical_coupling_with_no2, peroxynitrite_protonation, peroxynitrous_acid_homolysis, nitration_by_peroxynitrite, dityrosine_radical_coupling, dityrosine_by_h2o2, lys_to_allysine, arg_to_glutamic_semialdehyde, pro_to_glutamic_semialdehyde, hne_cysteine_residue, hne_cysteine_free, methylcytosine_deamination, depurination_adenine, depurination_guanine, guanine_oxidation_free, guanine_oxidation_dna, cyclobutane_dimer, six_four_photoproduct]
theorem spont_balanced : ∀ r ∈ spont, Balanced r :=
  bal_cons met_sulfoxide_balanced (bal_cons met_S_sulfoxide_balanced (bal_cons met_R_sulfoxide_balanced (bal_cons met_sulfone_balanced (bal_cons cys_sulfenic_balanced (bal_cons cys_sulfinic_balanced (bal_cons cys_sulfinic_neutral_balanced (bal_cons cys_sulfonic_balanced (bal_cons asn_succinimide_balanced (bal_cons succinimide_asp_balanced (bal_cons succinimide_isoasp_balanced (bal_cons asn_isoasp_balanced (bal_cons asp_succinimide_balanced (bal_cons asp_isoasp_balanced (bal_cons asp_racemization_balanced (bal_cons glycation_nterm_valine_balanced (bal_cons cml_from_glyoxal_balanced (bal_cons cml_from_fructosyl_lysine_balanced (bal_cons pentosidine_balanced (bal_cons urea_to_cyanate_balanced (bal_cons carbamylation_balanced (bal_cons carbamylation_by_cyanate_balanced (bal_cons carbamylation_nterm_valine_balanced (bal_cons nitration_two_no2_balanced (bal_cons tyrosyl_radical_formation_balanced (bal_cons radical_coupling_with_no2_balanced (bal_cons peroxynitrite_protonation_balanced (bal_cons peroxynitrous_acid_homolysis_balanced (bal_cons nitration_by_peroxynitrite_balanced (bal_cons dityrosine_radical_coupling_balanced (bal_cons dityrosine_by_h2o2_balanced (bal_cons lys_to_allysine_balanced (bal_cons arg_to_glutamic_semialdehyde_balanced (bal_cons pro_to_glutamic_semialdehyde_balanced (bal_cons hne_cysteine_residue_balanced (bal_cons hne_cysteine_free_balanced (bal_cons methylcytosine_deamination_balanced (bal_cons depurination_adenine_balanced (bal_cons depurination_guanine_balanced (bal_cons guanine_oxidation_free_balanced (bal_cons guanine_oxidation_dna_balanced (bal_cons cyclobutane_dimer_balanced (bal_cons six_four_photoproduct_balanced (bal_nil)))))))))))))))))))))))))))))))))))))))))))

end BioCore.Damage.Spont
