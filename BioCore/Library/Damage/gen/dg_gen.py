#!/usr/bin/env python3
"""Generator of the damage and repair library (track dg). Lives in BioCore/Library/Damage/gen/.

Writes, under BioCore/Library/Damage/ of a BioCore tree:
  Species.lean      species used by the library (namespace BioCore.Damage.Sp), incl. rule-derived ones
  Rx<kk>.lean       the Rhea release 143 records of the damage and repair classes, restated and proved
  RxAll.lean        lists of those records and "every member is balanced"
  RuleTest.lean     test of the residue rules R1 and R2 against ChEBI pairs (namespace ...RuleTest)
  Bridge.lean       equality with the reaction library, and the check that named species occur in no
                    Rhea record (imports BioCore.Library.Reactions.All; built on the remote machine)
and, into --out: dg_species.csv, dg_rule_pairs.csv, dg_rx_rows.csv.

Inputs (nothing is typed from memory):
  --repo   repository tree (results/rx_species.tsv, BioCore/Data/Monomers.lean,
           BioCore/Library/Reactions/Species*.lean and Chunk*.lean)
  --rx     rx_results.parquet (Rhea release 143 master reactions, ChEBI terms, classes of outcome)
  --rc     rc_assignment.parquet (event classes per Rhea record)
  --chebi  directory with ChEBI release 257 flat files compounds.tsv.gz, chemical_data.tsv.gz,
           relation.tsv.gz
  gen/extra_species.tsv, gen/rule_species.tsv, gen/avoid_names.txt (hand-kept lists next to this file)
The script predicts balance in Python (level X); only the Lean kernel's acceptance counts.
No record is dropped or shortened because of its length.
"""
import argparse, csv, json, os, re, sys
from collections import OrderedDict
import pandas as pd

HERE = os.path.dirname(os.path.abspath(__file__))
ELEMS = ("H He Li Be B C N O F Ne Na Mg Al Si P S Cl Ar K Ca Sc Ti V Cr Mn Fe Co Ni Cu Zn Ga Ge As Se Br Kr "
         "Rb Sr Y Zr Nb Mo Tc Ru Rh Pd Ag Cd In Sn Sb Te I Xe Cs Ba La Ce Pr Nd Pm Sm Eu Gd Tb Dy Ho Er Tm Yb "
         "Lu Hf Ta W Re Os Ir Pt Au Hg Tl Pb Bi Po At Rn Fr Ra Ac Th Pa U Np Pu Am Cm Bk Cf Es Fm Md No Lr Rf "
         "Db Sg Bh Hs Mt Ds Rg Cn Nh Fl Mc Lv Ts Og").split()
QTY = {s: i + 1 for i, s in enumerate(ELEMS)}
QTY.update({"R": 1000, "X": 1001, "A": 1002})   # generic group, halogen, hydrogen acceptor (rx_choices + amendment 1)
TOK = re.compile(r"([A-Z][a-z]?)(\d*)")
SCOPE = ["C%d" % i for i in range(19, 30)] + ["C31", "C32"]
CHUNK = 300

def parse_formula(f):
    f = f.strip()
    if any(ch in "()[]{}" for ch in f):
        return None
    c = OrderedDict()
    for part in f.split("."):
        m = re.match(r"[1-9]\d*", part)
        mult, pos = (int(m.group()), m.end()) if m else (1, 0)
        if pos >= len(part):
            return None
        while pos < len(part):
            mt = TOK.match(part, pos)
            if not mt:
                return None
            s, n = mt.groups()
            if s not in QTY or n.startswith("0"):
                return None
            c[s] = c.get(s, 0) + mult * (int(n) if n else 1)
            pos = mt.end()
    return c

def lean_name_string(acc, nm):
    s = f"{acc} {nm}".replace("\\", "").replace('"', "'")
    return "".join(ch if 0x20 <= ord(ch) <= 0x7E else "?" for ch in s)

def pairs_text(comp, charge):
    items = [f"({QTY[s]}, {n})" for s, n in comp.items() if n != 0]
    if charge != 0:
        items.append(f"(0, {charge})")
    return ", ".join(items)

def rassoc(xs):
    return xs[0] if len(xs) == 1 else f"{xs[0]} ++ ({rassoc(xs[1:])})"

def hill(comp):
    keys = list(comp)
    order = ([k for k in ("C", "H") if k in keys] + sorted(k for k in keys if k not in ("C", "H"))) if "C" in keys else sorted(keys)
    return "".join(f"{k}{comp[k] if comp[k] != 1 else ''}" for k in order if comp[k] != 0)

ap = argparse.ArgumentParser()
ap.add_argument("--repo", required=True); ap.add_argument("--rx", required=True)
ap.add_argument("--rc", required=True); ap.add_argument("--chebi", required=True)
ap.add_argument("--out", required=True)
a = ap.parse_args()
csv.field_size_limit(10**9)
OUT = os.path.join(a.repo, "BioCore/Library/Damage")
os.makedirs(a.out, exist_ok=True)

comp = pd.read_csv(os.path.join(a.chebi, "compounds.tsv.gz"), sep="\t", dtype=str, quoting=csv.QUOTE_NONE)
chem = pd.read_csv(os.path.join(a.chebi, "chemical_data.tsv.gz"), sep="\t", dtype=str, quoting=csv.QUOTE_NONE)
rel = pd.read_csv(os.path.join(a.chebi, "relation.tsv.gz"), sep="\t", dtype=str, quoting=csv.QUOTE_NONE)
by_acc = {r.chebi_accession: r for r in comp.itertuples()}
by_id = {r.id: r for r in comp.itertuples()}
chem_by = {}
for r in chem.itertuples():
    if isinstance(r.formula, str) and r.formula.strip():
        chem_by.setdefault(r.compound_id, []).append(r)

def chebi_species(acc):
    """The lookup rule of rx_choices.md section 5, unchanged."""
    row = by_acc.get(acc)
    if row is None:
        return dict(acc=acc, ok=False, reason="chebi_id_absent", name="")
    name = row.ascii_name if isinstance(row.ascii_name, str) and row.ascii_name else row.name
    rows = chem_by.get(row.id, [])
    if not rows:
        return dict(acc=acc, ok=False, reason="chebi_no_formula", name=name)
    texts = sorted({(r.formula.strip(), str(r.charge).strip()) for r in rows})
    parsed = [(parse_formula(f), int(c) if re.fullmatch(r"[+-]?\d+", c) else None) for f, c in texts]
    if len(texts) > 1:
        ok = all(p is not None and q is not None for p, q in parsed)
        if not (ok and len({(tuple(sorted(p.items())), q) for p, q in parsed}) == 1):
            return dict(acc=acc, ok=False, reason="chebi_ambiguous_data", name=name)
    p, q = parsed[0]
    if q is None:
        return dict(acc=acc, ok=False, reason="chebi_no_charge", name=name)
    if p is None:
        return dict(acc=acc, ok=False, reason="formula_not_in_grammar", name=name)
    return dict(acc=acc, ok=True, name=name, comp=p, charge=q, formula=texts[0][0])

# species text of the reaction library (identical text is reused) and of the kernel
LIBLINE = {}
libdir = os.path.join(a.repo, "BioCore/Library/Reactions")
for fn in sorted(os.listdir(libdir)):
    if re.fullmatch(r"Species\d+\.lean", fn):
        for line in open(os.path.join(libdir, fn), encoding="utf-8"):
            mt = re.match(r'def (c\d+) : Species := ⟨"(.*)", \[(.*)\]⟩\s*$', line)
            if mt:
                LIBLINE[mt.group(1)] = (mt.group(2), mt.group(3))
KERNEL = set(re.findall(r"^def (c\d+) : Species", open(os.path.join(a.repo, "BioCore/Data/Monomers.lean"), encoding="utf-8").read(), re.M))
rxsp = pd.read_csv(os.path.join(a.repo, "results/rx_species.tsv"), sep="\t", dtype=str, quoting=csv.QUOTE_NONE).set_index("chebi")

SPECIES = OrderedDict()   # lean ident -> dict
def need(acc, why=""):
    ident = "c" + acc.split(":")[1]
    if ident in SPECIES:
        return ident
    if ident in KERNEL:
        s = chebi_species(acc)
        SPECIES[ident] = dict(ident=ident, acc=acc, kind="kernel", name=s["name"], formula=s["formula"], charge=s["charge"],
                              line=f"abbrev {ident} : Species := BioCore.Chebi.{ident}",
                              src="kernel data, BioCore/Data/Monomers.lean (ChEBI release 257)", comp=s["comp"])
    elif ident in LIBLINE:
        nm, prs = LIBLINE[ident]
        s = chebi_species(acc)
        assert s["ok"] and pairs_text(s["comp"], s["charge"]) == prs and lean_name_string(acc, s["name"]) == nm, (acc, s, prs, nm)
        SPECIES[ident] = dict(ident=ident, acc=acc, kind="reaction library", name=s["name"], formula=s["formula"], charge=s["charge"],
                              line=f'def {ident} : Species := ⟨"{nm}", [{prs}]⟩',
                              src="ChEBI release 257, same text as the reaction library (results/rx_species.tsv)", comp=s["comp"])
    else:
        s = chebi_species(acc)
        if not s["ok"]:
            raise SystemExit(f"species {acc} not usable: {s}")
        SPECIES[ident] = dict(ident=ident, acc=acc, kind="flat files", name=s["name"], formula=s["formula"], charge=s["charge"],
                              line=f'def {ident} : Species := ⟨"{lean_name_string(acc, s["name"])}", [{pairs_text(s["comp"], s["charge"])}]⟩',
                              src="ChEBI release 257 flat files (chemical_data.tsv.gz, compounds.tsv.gz); not in a Rhea record", comp=s["comp"])
    return ident

# ---------------------------------------------------------------- Rhea records in scope
rx = pd.read_parquet(a.rx); rc = pd.read_parquet(a.rc)
rc["dcls"] = rc.class_ids.fillna("").apply(lambda s: [c for c in s.split(";") if c in SCOPE])
sc = rc[rc.dcls.apply(len) > 0][["rhea_id", "dcls", "matched_condition"]].merge(rx, on="rhea_id").sort_values("rhea_id").rename(columns={"class": "rl_class"})
assert len(sc) == 906, len(sc)
# definitions of the reaction library, for a text comparison (level X)
LIBRX = {}
for fn in sorted(os.listdir(libdir)):
    if re.fullmatch(r"Chunk\d+\.lean", fn):
        for line in open(os.path.join(libdir, fn), encoding="utf-8"):
            mt = re.match(r"def (rhea_\d+) : FSum := (\[.*\])\s*$", line)
            if mt:
                LIBRX[mt.group(1)] = (fn[:-5], mt.group(2))
rx_rows, rx_defs = [], []
for r in sc.itertuples():
    row = dict(rhea_id=r.rhea_id, classes=";".join(r.dcls), ec=r.ec or "", status=r.rhea_status, equation=r.equation,
               reaction_library_class=r.rl_class, reaction_library_reason=r.reason_code, reaction_library_theorem=r.theorem or "")
    if r.rl_class != "PROVED_BALANCED":
        row.update(outcome="NOT_EXPRESSIBLE", level="", theorem="", file="")
        rx_rows.append(row); continue
    terms = json.loads(r.terms)
    body = "[" + ", ".join(f"({c}, {need(acc)})" for c, acc in terms) + "]"
    name = f"rhea_{r.rhea_id}"
    assert name in LIBRX and LIBRX[name][1] == body, (name, body, LIBRX.get(name))
    eq = r.equation.replace("-/", "- /")
    rx_defs.append((name, body, f"RHEA:{r.rhea_id} ({';'.join(r.dcls)}{'; EC ' + r.ec if r.ec else ''}): {eq}"))
    row.update(outcome="PROVED_BALANCED", level="K", theorem=f"BioCore.Damage.Rx.{name}_balanced", same_text_as_reaction_library_X=True,
               reaction_library_chunk=LIBRX[name][0])
    rx_rows.append(row)

# ---------------------------------------------------------------- hand-kept lists
extra = pd.read_csv(os.path.join(HERE, "extra_species.tsv"), sep="\t", dtype=str, comment="#").fillna("")
for r in extra.itertuples():
    need(r.chebi, r.note)
rules = pd.read_csv(os.path.join(HERE, "rule_species.tsv"), sep="\t", dtype=str, comment="#").fillna("")
WATER = {"H": 2, "O": 1}
RULE = []
for r in rules.itertuples():
    if r.rule == "R3":
        base = chebi_species(r.chebi); assert base["ok"]
        c = OrderedDict(base["comp"]); c["H"] -= 2; c["O"] -= 1; q = base["charge"]; tag = "[rule R3 from " + r.chebi + "]"
    elif r.rule.startswith("R1"):
        k = int(r.rule[3:]) if r.rule.startswith("R1x") else 1
        base = chebi_species(r.chebi); assert base["ok"], r.chebi
        c = OrderedDict(base["comp"]); c["H"] -= 2 * k; c["O"] -= k; q = base["charge"]
        tag = f"[rule R1{' x' + str(k) if k > 1 else ''} from {r.chebi}]"
    elif r.rule == "R2":
        base = chebi_species(r.chebi); assert base["ok"] and base["charge"] == -2, r.chebi
        c = OrderedDict(base["comp"]); c["H"] -= 1; c["O"] -= 1; q = base["charge"] + 1; tag = "[rule R2 from " + r.chebi + "]"
    else:
        raise SystemExit("unknown rule " + r.rule)
    assert all(v >= 0 for v in c.values())
    nm = f"{r.display} {tag}"
    need(r.chebi, "free compound of a rule-derived species")
    RULE.append(dict(ident=r.ident, rule=r.rule, free=r.chebi, free_name=base["name"], free_formula=base["formula"], free_charge=base["charge"],
                     name=nm, formula=hill(c), charge=q,
                     line=f'def {r.ident} : Species := ⟨"{nm}", [{pairs_text(c, q)}]⟩'))

# ---------------------------------------------------------------- write Species.lean
HDR = ("GENERATED FILE (BioCore/Library/Damage/gen/dg_gen.py, track dg). Each definition is data copied from the\n"
       "named source; the kernel checks what follows from it, not that it describes the molecule.\n"
       "Pairs are (quantity, amount): 0 is charge, 1..118 atomic numbers, 1000 the generic group R, 1001 the generic halogen X,\n"
       "1002 the generic hydrogen acceptor A (rx_choices_amendment_1.md).")
def ordkey(i): return int(i[1:])
L = ["import BioCore.CentralDogma", "/-!", "# BioCore.Library.Damage.Species", "", HDR,
     "Sources: ChEBI release 257 (CC BY 4.0, http://www.ebi.ac.uk/chebi). Species already in the reaction library have the same",
     "text as `results/rx_species.tsv`; species of the kernel are the kernel's constants; the others are read from the flat files.",
     "RULE-DERIVED species (section at the end) are NOT ChEBI entries: their formula is computed from a ChEBI free compound by the",
     "rule named in the name string (dg_choices.md section 3), and every statement that uses one depends on that rule.", "-/",
     "namespace BioCore.Damage.Sp", "open BioCore", ""]
for ident in sorted(SPECIES, key=ordkey):
    s = SPECIES[ident]
    L.append(f'{s["line"]}  -- {s["acc"]}, formula {s["formula"]}, charge {s["charge"]}; {s["src"]}')
L += ["", "/-! ## Rule-derived species (not ChEBI entries) -/", ""]
for s in RULE:
    L.append(f'/-- RULE-DERIVED ({s["rule"]}) from {s["free"]} {s["free_name"]} ({s["free_formula"]}, charge {s["free_charge"]}): {s["formula"]}, charge {s["charge"]}. -/')
    L.append(s["line"])
L += ["", "end BioCore.Damage.Sp", ""]
open(os.path.join(OUT, "Species.lean"), "w", encoding="utf-8").write("\n".join(L))

# ---------------------------------------------------------------- write Rx files
files = []
for k in range(0, len(rx_defs), CHUNK):
    fn = f"Rx{k // CHUNK + 1:02d}"
    files.append(fn)
    part = rx_defs[k:k + CHUNK]
    L = ["import BioCore.Library.Damage.Species", "import BioCore.Library.Damage.Basic", "/-!", f"# BioCore.Library.Damage.{fn}", "", HDR,
         "Rhea release 143 master records (CC BY 4.0, https://www.rhea-db.org) that the census assigned to the damage and repair",
         "classes C19-C29, C31, C32, restated with the term lists of the reaction library (`rx_results.parquet`, column `terms`).",
         "`Bridge.lean` proves each definition equal to `BioCore.Rhea.rhea_<id>`. A negative coefficient is the left side.",
         "Agreement with the reaction library is the expected outcome, not a finding.", "-/",
         "namespace BioCore.Damage.Rx", "open BioCore BioCore.Damage BioCore.Damage.Sp", ""]
    for name, body, doc in part:
        L.append(f"/-- {doc} -/")
        L.append(f"def {name} : FSum := {body}")
        L.append(f"theorem {name}_balanced : Balanced {name} := by decide")
    L.append("")
    bnames = []
    for b in range(0, len(part), 25):
        sub = part[b:b + 25]
        bn = f"list_{fn}_b{b // 25:02d}"
        bnames.append(bn)
        L.append(f"def {bn} : List FSum := [{', '.join(n for n, _, _ in sub)}]")
        proof = "bal_nil"
        for n, _, _ in reversed(sub):
            proof = f"bal_cons {n}_balanced ({proof})"
        L.append(f"theorem {bn}_balanced : ∀ r ∈ {bn}, Balanced r := {proof}")
    L += ["", f"def list_{fn} : List FSum := {rassoc(bnames)}", ""]
    proof = f"{bnames[-1]}_balanced"
    for bn in reversed(bnames[:-1]):
        proof = f"bal_append {bn}_balanced ({proof})"
    L += [f"theorem list_{fn}_balanced : ∀ r ∈ list_{fn}, Balanced r :=", f"  {proof}", "", "end BioCore.Damage.Rx", ""]
    open(os.path.join(OUT, fn + ".lean"), "w", encoding="utf-8").write("\n".join(L))
    for n, _, _ in part:
        for row in rx_rows:
            if row.get("theorem", "").endswith("." + n + "_balanced"):
                row["file"] = fn
L = [f"import BioCore.Library.Damage.{f}" for f in files] + ["/-!", "# BioCore.Library.Damage.RxAll", "", "GENERATED. All Rhea records of the damage and repair classes that the kernel proves balanced.", "-/",
     "namespace BioCore.Damage.Rx", "open BioCore BioCore.Damage", ""]
expr = rassoc([f"list_{f}" for f in files])
L.append(f"def rxAll : List FSum := {expr}")
proof = f"list_{files[-1]}_balanced"
for f in reversed(files[:-1]):
    proof = f"bal_append list_{f}_balanced ({proof})"
L += [f"theorem rxAll_balanced : ∀ r ∈ rxAll, Balanced r := {proof}",
      f"theorem rxAll_length : rxAll.length = {len(rx_defs)} := by decide +kernel", "", "end BioCore.Damage.Rx", ""]
open(os.path.join(OUT, "RxAll.lean"), "w", encoding="utf-8").write("\n".join(L))

# ---------------------------------------------------------------- rule test (R1, R2) on ChEBI pairs
r10 = rel[rel.relation_type_id == "10"]
def nm_of(cid):
    r = by_id.get(cid)
    return None if r is None else (r.ascii_name if isinstance(r.ascii_name, str) and r.ascii_name else r.name)
pairs, RT = [], OrderedDict()
def rt_need(acc):
    ident = "c" + acc.split(":")[1]
    if ident not in RT:
        s = chebi_species(acc)
        RT[ident] = f'def {ident} : Species := ⟨"{lean_name_string(acc, s["name"])}", [{pairs_text(s["comp"], s["charge"])}]⟩'
    return ident
for r in r10.itertuples():
    x, y = by_id.get(r.init_id), by_id.get(r.final_id)
    xn = nm_of(r.init_id)
    if x is None or not isinstance(xn, str) or not re.search(r"residue(\(\d*[+-]\))?$", xn):
        continue
    row = dict(residue=x.chebi_accession, residue_name=xn, free=y.chebi_accession if y is not None else "", free_name=nm_of(r.final_id) if y is not None else "",
               relation_status=r.status_id)
    if y is None:
        row.update(outcome="NOT_TESTED", reason="free compound id absent"); pairs.append(row); continue
    sx, sy = chebi_species(x.chebi_accession), chebi_species(y.chebi_accession)
    if not (sx["ok"] and sy["ok"]):
        row.update(outcome="NOT_TESTED", reason="; ".join(f"{s['acc']}: {s['reason']}" for s in (sx, sy) if not s["ok"])); pairs.append(row); continue
    rule = "R2" if re.search(r"monophosphate|\b[A-Za-z0-9]*MP\b", xn) else "R1"
    leave = {"H": 2, "O": 1} if rule == "R1" else {"H": 1, "O": 1}
    lq = 0 if rule == "R1" else -1
    diff = {}
    for k in set(sx["comp"]) | set(sy["comp"]) | set(leave):
        d = sx["comp"].get(k, 0) + leave.get(k, 0) - sy["comp"].get(k, 0)
        if d: diff[k] = d
    dq = sx["charge"] + lq - sy["charge"]
    ix, iy = rt_need(x.chebi_accession), rt_need(y.chebi_accession)
    base = f"[(-1, {iy}), (1, {ix}), (1, {'water' if rule == 'R1' else 'hydroxide'})]"
    row.update(rule=rule, residue_formula=sx["formula"], residue_charge=sx["charge"], free_formula=sy["formula"], free_charge=sy["charge"],
               imbalance_X=";".join(f"{k}{v:+d}" for k, v in sorted(diff.items())) + (f";charge{dq:+d}" if dq else ""))
    tn = f"pair_{ix}_{iy}"
    if not diff and dq == 0:
        row.update(outcome="RULE_AGREES", lean=f"theorem {tn} : Balanced {base} := by decide")
    elif set(diff) <= {"H"} and diff.get("H", 0) == dq:
        k = -dq
        row.update(outcome="RULE_DIFFERS_BY_HYDRONS", hydrons=k,
                   lean=f"theorem {tn} : ¬ Balanced {base} ∧ Balanced ({base} ++ [({k}, hydron)]) := by decide")
    else:
        row.update(outcome="RULE_DIFFERS", lean=f"theorem {tn} : ¬ Balanced {base} := by decide")
    row.update(level="K", theorem=f"BioCore.Damage.RuleTest.{tn}")
    pairs.append(row)
L = ["import BioCore.Library.Damage.Basic", "/-!", "# BioCore.Library.Damage.RuleTest", "", HDR,
     "Test of the data rules R1 and R2 (dg_choices.md section 3) against every ChEBI release 257 pair `X is substituent group from Y`",
     "in which X is a residue and both entries have a formula. R1: residue = free compound - H2O, same charge. R2 (nucleoside",
     "monophosphate residues): residue = free compound - hydroxide. One theorem per pair: the rule reaction is balanced, or it is not",
     "balanced but becomes balanced with the stated number of hydrons (the two entries are in different protonation states), or it is",
     "not balanced. Species are restated here in their own namespace.", "-/",
     "namespace BioCore.Damage.RuleTest", "open BioCore", "",
     "abbrev water : Species := BioCore.Chebi.c15377", "abbrev hydron : Species := BioCore.Chebi.c15378",
     'def hydroxide : Species := ⟨"CHEBI:16234 hydroxide", [(1, 1), (8, 1), (0, -1)]⟩  -- ChEBI release 257 flat files', ""]
hx = chebi_species("CHEBI:16234"); assert hx["ok"] and pairs_text(hx["comp"], hx["charge"]) == "(1, 1), (8, 1), (0, -1)", hx
for ident in sorted(RT, key=ordkey):
    L.append(RT[ident])
L.append("")
for row in pairs:
    if "lean" in row:
        L.append(f"/-- {row['rule']} · {row['residue']} {row['residue_name']} from {row['free']} {row['free_name']}: {row['outcome']}. -/".replace("-/ ", "- / ") if False else
                 f"-- {row['rule']} · {row['residue']} {row['residue_name']} from {row['free']} {row['free_name']}: {row['outcome']}")
        L.append(row["lean"])
L += ["", "end BioCore.Damage.RuleTest", ""]
open(os.path.join(OUT, "RuleTest.lean"), "w", encoding="utf-8").write("\n".join(L))

# ---------------------------------------------------------------- tables
sprows = [dict(lean_ident="BioCore.Damage.Sp." + s["ident"], chebi=s["acc"], name=s["name"], formula=s["formula"], charge=s["charge"],
               origin=s["kind"], rule="", free_compound="") for s in (SPECIES[i] for i in sorted(SPECIES, key=ordkey))]
sprows += [dict(lean_ident="BioCore.Damage.Sp." + s["ident"], chebi="", name=s["name"], formula=s["formula"], charge=s["charge"],
                origin="RULE-DERIVED (not a ChEBI entry)", rule=s["rule"], free_compound=s["free"]) for s in RULE]
pd.DataFrame(sprows).to_csv(os.path.join(a.out, "dg_species.csv"), index=False)
pd.DataFrame(pairs).drop(columns=["lean"], errors="ignore").to_csv(os.path.join(a.out, "dg_rule_pairs.csv"), index=False)
pd.DataFrame(rx_rows).to_csv(os.path.join(a.out, "dg_rx_rows.csv"), index=False)
print("species", len(SPECIES), "rule-derived", len(RULE), "rhea defs", len(rx_defs), "files", files)
print("rule pairs", pd.DataFrame(pairs).outcome.value_counts().to_dict())
