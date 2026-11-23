#!/usr/bin/env python3
"""Generate BioCore/Data/Monomers.lean and BioCore/Data/GeneticCodes.lean.

Inputs (not part of the trusted kernel; this script only copies data into Lean terms):
  --chebi-chemical  chemical_data.tsv.gz   (ChEBI flat files, release 257)
  --chebi-compounds compounds.tsv.gz
  --gc              gc.prt                 (NCBI genetic codes, version 4.6)
The choice of ChEBI entry for each building block is the table MONOMERS below.
"""
import argparse, re, sys
import pandas as pd

ELEMS = ("H He Li Be B C N O F Ne Na Mg Al Si P S Cl Ar K Ca Sc Ti V Cr Mn Fe Co Ni Cu Zn Ga Ge As Se Br Kr "
         "Rb Sr Y Zr Nb Mo Tc Ru Rh Pd Ag Cd In Sn Sb Te I Xe Cs Ba La Ce Pr Nd Pm Sm Eu Gd Tb Dy Ho Er Tm Yb "
         "Lu Hf Ta W Re Os Ir Pt Au Hg Tl Pb Bi Po At Rn Fr Ra Ac Th Pa U Np Pu Am Cm Bk Cf Es Fm Md No Lr Rf "
         "Db Sg Bh Hs Mt Ds Rg Cn Nh Fl Mc Lv Ts Og").split()
assert len(ELEMS) == 118 and len(set(ELEMS)) == 118
Z = {s: i + 1 for i, s in enumerate(ELEMS)}
TOK = re.compile(r"([A-Z][a-z]?)(\d*)")

MONOMERS = {
    "RNA": {"A": ("CHEBI:30616", "CHEBI:74411"), "C": ("CHEBI:37563", "CHEBI:82748"),
            "G": ("CHEBI:37565", "CHEBI:74269"), "U": ("CHEBI:46398", "CHEBI:65315")},
    "DNA": {"A": ("CHEBI:61404", "CHEBI:90615"), "C": ("CHEBI:61481", "CHEBI:85452"),
            "G": ("CHEBI:61429", "CHEBI:85445"), "T": ("CHEBI:37568", "CHEBI:137386")},
    "AA": {"A": ("CHEBI:57972", "CHEBI:46217"), "R": ("CHEBI:32682", "CHEBI:29965"),
           "N": ("CHEBI:58048", "CHEBI:50347"), "D": ("CHEBI:29991", "CHEBI:29961"),
           "C": ("CHEBI:35235", "CHEBI:29950"), "Q": ("CHEBI:58359", "CHEBI:30011"),
           "E": ("CHEBI:29985", "CHEBI:29973"), "G": ("CHEBI:57305", "CHEBI:29947"),
           "H": ("CHEBI:57595", "CHEBI:29979"), "I": ("CHEBI:58045", "CHEBI:30009"),
           "L": ("CHEBI:57427", "CHEBI:30006"), "K": ("CHEBI:32551", "CHEBI:29969"),
           "M": ("CHEBI:57844", "CHEBI:16044"), "F": ("CHEBI:58095", "CHEBI:29997"),
           "P": ("CHEBI:60039", "CHEBI:50342"), "S": ("CHEBI:33384", "CHEBI:29999"),
           "T": ("CHEBI:57926", "CHEBI:30013"), "W": ("CHEBI:57912", "CHEBI:29954"),
           "Y": ("CHEBI:58315", "CHEBI:46858"), "V": ("CHEBI:57762", "CHEBI:30015"),
           "U": ("CHEBI:57843", "CHEBI:30000")},
}
OTHER = ["CHEBI:33019", "CHEBI:15377", "CHEBI:15378"]


def parse_formula(f):
    """Plain formulas only (element symbols with counts); None if anything else appears."""
    pos, out = 0, {}
    while pos < len(f):
        mt = TOK.match(f, pos)
        if not mt or mt.group(1) not in Z:
            return None
        out[mt.group(1)] = out.get(mt.group(1), 0) + int(mt.group(2) or 1)
        pos = mt.end()
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--chebi-chemical", required=True)
    ap.add_argument("--chebi-compounds", required=True)
    ap.add_argument("--gc", required=True)
    ap.add_argument("--out", default="BioCore/Data")
    ap.add_argument("--table", default="data_monomers_chebi257.tsv")
    a = ap.parse_args()
    cd = pd.read_csv(a.chebi_chemical, sep="\t", dtype=str)
    cp = pd.read_csv(a.chebi_compounds, sep="\t", dtype=str)
    m = cp.merge(cd[["compound_id", "formula", "charge"]], left_on="id", right_on="compound_id", how="left")
    m["an"] = m.ascii_name.fillna(m.name)
    chem = m.drop_duplicates("chebi_accession").set_index("chebi_accession")
    ids = sorted({x for d in MONOMERS.values() for pr in d.values() for x in pr} | set(OTHER),
                 key=lambda s: int(s.split(":")[1]))
    lines = ["import BioCore.Core", "/-!", "# BioCore.Data.Monomers", "",
             "GENERATED FILE. Species used by the polymer chemistry, copied from ChEBI release 257",
             "(flat files chemical_data.tsv.gz and compounds.tsv.gz of 2026-11-05; ChEBI data are CC BY 4.0,",
             "http://www.ebi.ac.uk/chebi). Each line is a data axiom: the kernel checks what follows from these",
             "formulas and charges, not that they describe the real molecule.",
             "Pairs are (quantity, amount): quantity 0 is charge, otherwise the atomic number.", "-/",
             "namespace BioCore.Chebi", ""]
    table = []
    for acc in ids:
        row = chem.loc[acc]
        comp = parse_formula(row.formula)
        if comp is None:
            sys.exit(f"formula of {acc} is not a plain formula: {row.formula}")
        q = int(row.charge)
        pairs = [(Z[e], n) for e, n in comp.items()] + ([(0, q)] if q != 0 else [])
        nm = f"{acc} {row.an}".replace("\\", "").replace('"', "'")
        lst = ", ".join(f"({k}, {n})" for k, n in pairs)
        lines.append(f'def c{acc.split(":")[1]} : Species := ⟨"{nm}", [{lst}]⟩')
        table.append(dict(chebi=acc, name=row.an, formula=row.formula, charge=q))
    lines += ["", "end BioCore.Chebi", ""]
    open(f"{a.out}/Monomers.lean", "w").write("\n".join(lines))
    pd.DataFrame(table).to_csv(a.table, sep="\t", index=False)

    gc = open(a.gc).read()
    blocks = re.findall(r'\{\s*name "([^"]+)"(?:\s*,\s*name "[^"]+")*\s*,\s*id (\d+)\s*,\s*ncbieaa\s+"([^"]+)",'
                        r'\s*sncbieaa\s+"([^"]+)"\s*-- Base1\s+(\S+)\s*-- Base2\s+(\S+)\s*-- Base3\s+(\S+)', gc)
    codes = {int(b[1]): b for b in blocks}
    for i in (1, 2):
        assert codes[i][4] == "T" * 16 + "C" * 16 + "A" * 16 + "G" * 16
        assert codes[i][5] == ("T" * 4 + "C" * 4 + "A" * 4 + "G" * 4) * 4 and codes[i][6] == "TCAG" * 16
    row = lambda s: ", ".join("none" if ch == "*" else f"some .{ch}" for ch in s)
    chars = lambda s: ", ".join(f"'{ch}'" for ch in s)
    starts = lambda s: ", ".join("true" if ch == "M" else "false" for ch in s)
    out = ["import BioCore.Sequence", "/-!", "# BioCore.Data.GeneticCodes", "",
           "GENERATED FILE from NCBI `gc.prt` version 4.6 (ftp.ncbi.nlm.nih.gov/entrez/misc/data/gc.prt).",
           "Codon order is the NCBI order: first base T,C,A,G; then second base; then third base.",
           "`none` is a stop codon. The `…_is_ncbi` theorems check each row against the NCBI letters.", "-/",
           "namespace BioCore", ""]
    for cid, nm in ((1, "standard"), (2, "vertMito")):
        c = codes[cid]
        out += [f"/-- NCBI translation table {cid}: {c[0].strip()}. -/",
                f"def {nm}Row : List (Option AA) := [{row(c[2])}]",
                f"def {nm}Starts : List Bool := [{starts(c[3])}]",
                f"def {nm}Code : GeneticCode := GeneticCode.ofRows {nm}Row {nm}Starts",
                f"theorem {nm}Row_length : {nm}Row.length = 64 := by decide",
                f"theorem {nm}Starts_length : {nm}Starts.length = 64 := by decide",
                f"theorem {nm}Row_is_ncbi : {nm}Row.map AA.letter = [{chars(c[2])}] := by decide", ""]
    out += ["end BioCore", ""]
    open(f"{a.out}/GeneticCodes.lean", "w").write("\n".join(out))


if __name__ == "__main__":
    main()
