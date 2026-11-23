#!/usr/bin/env python3
"""rx_gen.py — track "Reactions": read Rhea (RDF) and ChEBI release 257, classify every master reaction
under the grammar of rx_choices.md, and write the Lean library BioCore/Library/Reactions/.

UNTRUSTED: this program only copies data into Lean terms and predicts which statement to emit.
Whether a statement holds is decided by the Lean kernel. Everything computed here is level X.
"""
import argparse, csv, gzip, hashlib, importlib.util, json, os, re, sys
from collections import defaultdict, OrderedDict
import xml.etree.ElementTree as ET

RH = "http://rdf.rhea-db.org/"
RDFS = "http://www.w3.org/2000/01/rdf-schema#"
RDF = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
PURL = "http://purl.obolibrary.org/obo/CHEBI_"
PREFIX = {RH: "rh:", RDFS: "rdfs:", RDF: "rdf:"}
REASONS = ["malformed_record", "symbolic_coefficient", "non_integer_coefficient", "polymer_participant",
           "generic_without_reactive_part", "participant_without_chebi_id", "chebi_id_absent",
           "chebi_no_formula", "chebi_ambiguous_data", "chebi_no_charge", "formula_has_brackets",
           "formula_unknown_token", "kernel_did_not_accept"]
PSEUDO = OrderedDict([("R", 1000), ("X", 1001), ("A", 1002)])
PSEUDO_FROZEN = ("R", "X")   # rx_choices.md; "A" was added by rx_choices_amendment_1.md
TOK = re.compile(r"([A-Z][a-z]?)(\d*)")
CHUNK = 300
SPECIES_PER_FILE = 2000
BLOCK = 20
AUDIT_SEED = "rx-audit-2026-11-21:"
AUDIT_N = 400
LIBDIR = "BioCore/Library/Reactions"
MOD = "BioCore.Library.Reactions"


def load_elements(kernel_root):
    spec = importlib.util.spec_from_file_location("gen_data", os.path.join(kernel_root, "tools", "gen_data.py"))
    m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
    assert len(m.ELEMS) == 118 and len(set(m.ELEMS)) == 118
    return dict(m.Z)


def short(tag):
    if tag.startswith("{"):
        uri, local = tag[1:].split("}")
        return PREFIX.get(uri, uri) + local
    return tag


def obj(res):
    if res.startswith(RH):
        return res[len(RH):]
    if res.startswith(PURL):
        return "CHEBI:" + res[len(PURL):]
    return res


def load_rdf(path):
    T = defaultdict(lambda: defaultdict(list))
    with gzip.open(path, "rb") as f:
        for ev, el in ET.iterparse(f, events=("end",)):
            if el.tag == "{%s}Description" % RDF:
                s = obj(el.attrib["{%s}about" % RDF])
                d = T[s]
                for ch in el:
                    res = ch.attrib.get("{%s}resource" % RDF)
                    v = obj(res) if res is not None else (ch.text or "")
                    lst = d[short(ch.tag)]
                    if v not in lst:  # RDF is a set of triples: an identical repeated triple is one triple
                        lst.append(v)
                el.clear()
    return T


def read_tsv(path, log):
    """Rows of a TSV as dicts. Plain tab-splitting if every line has the header's number of fields,
    otherwise the csv module's default quoting; which one was used is logged."""
    op = gzip.open if path.endswith(".gz") else open
    with op(path, "rt", encoding="utf-8", newline="") as f:
        lines = f.read().split("\n")
    if lines and lines[-1] == "":
        lines.pop()
    hdr = lines[0].rstrip("\r").split("\t")
    rows = [ln.rstrip("\r").split("\t") for ln in lines[1:]]
    bad = sum(1 for r in rows if len(r) != len(hdr))
    if bad == 0:
        log(f"read_tsv {os.path.basename(path)}: plain tab split, {len(rows)} rows, {len(hdr)} columns")
        return [dict(zip(hdr, r)) for r in rows]
    with op(path, "rt", encoding="utf-8", newline="") as f:
        rd = csv.reader(f, delimiter="\t")
        hdr = next(rd); rows = list(rd)
    bad2 = sum(1 for r in rows if len(r) != len(hdr))
    log(f"read_tsv {os.path.basename(path)}: {bad} lines with another field count under plain split; "
        f"csv quoting used, {len(rows)} rows, {bad2} rows with another field count")
    if bad2:
        raise SystemExit(f"cannot read {path} consistently")
    return [dict(zip(hdr, r)) for r in rows]


def parse_formula(f, QTY):
    """-> (composition OrderedDict symbol->amount, None) or (None, (reason_code, detail))."""
    f = f.strip()
    for ch in f:
        if ch in "()[]{}":
            return None, ("formula_has_brackets", f)
    comp = OrderedDict()
    for part in f.split("."):
        m = re.match(r"[1-9]\d*", part)
        mult, pos = (int(m.group()), m.end()) if m else (1, 0)
        if pos >= len(part):
            return None, ("formula_unknown_token", f"empty part in {f!r}")
        while pos < len(part):
            mt = TOK.match(part, pos)
            if not mt:
                return None, ("formula_unknown_token", f"{part[pos:pos + 12]!r} in {f!r}")
            sym, cnt = mt.groups()
            if sym not in QTY:
                return None, ("formula_unknown_token", f"symbol {sym!r} in {f!r}")
            if cnt.startswith("0"):
                return None, ("formula_unknown_token", f"count {cnt!r} in {f!r}")
            comp[sym] = comp.get(sym, 0) + mult * (int(cnt) if cnt else 1)
            pos = mt.end()
    return comp, None


def lean_name_string(acc, nm):
    s = f"{acc} {nm}".replace("\\", "").replace('"', "'")
    return "".join(ch if 0x20 <= ord(ch) <= 0x7E else "?" for ch in s)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True)
    ap.add_argument("--kernel", required=True, help="root of the frozen kernel checkout (read only)")
    ap.add_argument("--out", required=True, help="root under which BioCore/Library/Reactions is written")
    ap.add_argument("--tables", required=True)
    ap.add_argument("--overrides", default=None)
    ap.add_argument("--tactic", default="decide")
    a = ap.parse_args()
    os.makedirs(a.tables, exist_ok=True)
    logf = open(os.path.join(a.tables, "rx_gen_log.txt"), "w")

    def log(*x):
        s = " ".join(str(v) for v in x); print(s); logf.write(s + "\n"); logf.flush()

    Z = load_elements(a.kernel)
    QTY = dict(Z); QTY.update(PSEUDO)
    QNAME = {v: k for k, v in QTY.items()}; QNAME[0] = "charge"
    assert len(QNAME) == len(QTY) + 1 == 122, "quantity map must be injective"
    QTY_FROZEN = {k: v for k, v in QTY.items() if k in Z or k in PSEUDO_FROZEN}
    assert all(1 <= v <= 118 for v in Z.values()) and all(v >= 1000 for v in PSEUDO.values())
    overrides = json.load(open(a.overrides)) if a.overrides else {}

    # ---------------- ChEBI release 257
    comp_rows = read_tsv(os.path.join(a.src, "chebi_compounds.tsv.gz"), log)
    chem_rows = read_tsv(os.path.join(a.src, "chebi_chemical_data.tsv.gz"), log)
    by_acc = {}
    for r in comp_rows:
        acc = r["chebi_accession"]
        assert acc not in by_acc, f"duplicate accession {acc}"
        by_acc[acc] = r
    chem_by_cid = defaultdict(list)
    for r in chem_rows:
        chem_by_cid[r["compound_id"]].append(r)
    secondary = set()
    p2 = os.path.join(a.src, "chebi_secondary_ids.tsv.gz")
    if os.path.exists(p2):
        srows = read_tsv(p2, log)
        log("secondary_ids columns", list(srows[0].keys()) if srows else [])
        for r in srows:
            for v in r.values():
                if re.fullmatch(r"\d+", v or ""):
                    secondary.add("CHEBI:" + v)
                elif re.fullmatch(r"CHEBI:\d+", v or ""):
                    secondary.add(v)
    log(f"ChEBI: {len(by_acc)} accessions, {len(chem_rows)} chemical_data rows")

    species_cache = {}

    def species(acc):
        """-> dict(ok, reason, detail, comp, charge, formula_text, name, flags)"""
        if acc in species_cache:
            return species_cache[acc]
        out = dict(acc=acc, ok=False, reason=None, detail="", comp=None, charge=None, formula="", charge_text="",
                   name="", rows_agree_after_parsing=False, in_secondary_ids=acc in secondary,
                   frozen_reason=None, frozen_detail="")
        row = by_acc.get(acc)
        if row is None:
            out.update(reason="chebi_id_absent", detail=acc + (" (listed in secondary_ids)" if acc in secondary else ""))
        else:
            out["name"] = row.get("ascii_name") or row.get("name") or ""
            rows = [r for r in chem_by_cid.get(row["id"], []) if r["formula"].strip() != ""]
            if not rows:
                out.update(reason="chebi_no_formula", detail=acc)
            else:
                texts = sorted({(r["formula"].strip(), r["charge"].strip()) for r in rows})
                out["formula"], out["charge_text"] = " | ".join(t[0] for t in texts), " | ".join(t[1] for t in texts)
                parsed = []
                for ftxt, ctxt in texts:
                    comp, err = parse_formula(ftxt, QTY)
                    q = int(ctxt) if re.fullmatch(r"[+-]?\d+", ctxt) else None
                    parsed.append((comp, err, q))
                if len(texts) > 1:
                    allok = all(c is not None and q is not None for c, e, q in parsed)
                    same = allok and len({(tuple(sorted(c.items())), q) for c, e, q in parsed}) == 1
                    if not same:
                        out.update(reason="chebi_ambiguous_data", detail=f"{acc}: {texts}")
                    else:
                        out["rows_agree_after_parsing"] = True
                if out["reason"] is None:
                    comp, err, q = parsed[0]
                    if q is None:
                        out.update(reason="chebi_no_charge", detail=f"{acc}: charge {texts[0][1]!r}")
                    elif err is not None:
                        out.update(reason=err[0], detail=f"{acc}: {err[1]}")
                    else:
                        out.update(ok=True, comp=comp, charge=q)
                        # classification under the unamended rx_choices.md (symbols R and X only)
                        if len(texts) == 1:
                            cf, ef = parse_formula(texts[0][0], QTY_FROZEN)
                            if ef is not None:
                                out.update(frozen_reason=ef[0], frozen_detail=f"{acc}: {ef[1]}")
                        else:
                            pf = [parse_formula(ft, QTY_FROZEN) for ft, _ in texts]
                            if any(e is not None for _, e in pf):
                                out.update(frozen_reason="chebi_ambiguous_data", frozen_detail=f"{acc}: {texts}")
        species_cache[acc] = out
        return out

    # ---------------- Rhea
    T = load_rdf(os.path.join(a.src, "rhea.rdf.gz"))
    log(f"RDF subjects: {len(T)}")
    coef_of = {}
    for s, d in T.items():
        if s.startswith("contains") and "rh:coefficient" in d:
            coef_of["rh:" + s] = d["rh:coefficient"][0]
    log("coefficient predicates:", json.dumps(coef_of, sort_keys=True))
    drows = read_tsv(os.path.join(a.src, "rhea-directions.tsv"), log)
    masters = [r["RHEA_ID_MASTER"] for r in drows]
    assert len(set(masters)) == len(masters), "duplicate master id"
    rdf_masters = {s for s, d in T.items() if "Reaction" in d.get("rdfs:subClassOf", []) and re.fullmatch(r"\d+", s)}
    outside = sorted(rdf_masters - set(masters), key=int)
    log(f"scope: {len(masters)} master reactions in rhea-directions.tsv; RDF masters: {len(rdf_masters)}; "
        f"RDF masters outside scope: {len(outside)}; in scope but not an RDF master: {len(set(masters) - rdf_masters)}")
    json.dump(dict(rdf_masters_outside_scope=outside,
                   outside_status={m: T[m].get("rh:status", [""])[0] for m in outside}),
              open(os.path.join(a.tables, "rx_outside_scope.json"), "w"))
    # txt equations (diagnostic)
    txt_eq = {}
    ptxt = os.path.join(a.src, "rhea-reactions.txt.gz")
    if os.path.exists(ptxt):
        cur = None
        with gzip.open(ptxt, "rt", encoding="utf-8") as f:
            for line in f:
                if line.startswith("ENTRY"):
                    cur = line.split()[1].replace("RHEA:", "")
                elif line.startswith("EQUATION") and cur:
                    txt_eq[cur] = line[len("EQUATION"):].strip()

    def txt_multiset(eq):
        m = re.split(r"\s(=|=>|<=>)\s", eq)
        if len(m) != 3:
            return None
        res = []
        for side, text in (("L", m[0]), ("R", m[2])):
            for term in text.split(" + "):
                toks = term.strip().split(" ")
                if len(toks) == 1:
                    c, ids = "1", toks[0]
                elif len(toks) == 2:
                    c, ids = toks
                else:
                    return None
                for i in ids.split(","):
                    res.append((side, c, i))
        return sorted(res)

    LOC_ORDER = {"": 0, "In": 1, "Out": 2}
    records = []
    used_species = OrderedDict()
    for mid, drow in zip(masters, drows):
        rec = OrderedDict(rhea_id=int(mid), rhea_id_lr=drow.get("RHEA_ID_LR", ""), rhea_id_rl=drow.get("RHEA_ID_RL", ""),
                          rhea_id_bi=drow.get("RHEA_ID_BI", ""))
        d = T.get(mid)
        reasons = []  # (code, detail)
        frozen_only = []  # reasons that apply under the unamended rx_choices.md only
        terms = []    # (signed coefficient, chebi acc)
        parts = []    # participant descriptions
        rec["equation"] = (d.get("rdfs:label", [""])[0] if d else "")
        rec["rhea_status"] = (d.get("rh:status", [""])[0] if d else "")
        rec["rhea_is_transport"] = (d.get("rh:isTransport", [""])[0] if d else "")
        rec["rhea_is_chemically_balanced"] = (d.get("rh:isChemicallyBalanced", [""])[0] if d else "")
        rec["ec"] = ";".join(x.rsplit("/", 1)[-1] for x in d.get("rh:ec", [])) if d else ""
        has_loc = macro = False
        if d is None:
            reasons.append(("malformed_record", "no RDF description"))
        else:
            sides = d.get("rh:side", [])
            if sorted(sides) != [mid + "_L", mid + "_R"]:
                reasons.append(("malformed_record", f"sides {sides}"))
            else:
                for side, sign in ((mid + "_L", -1), (mid + "_R", 1)):
                    sd = T.get(side, {})
                    specific = [(p, o) for p in sd if p.startswith("rh:contains") and p != "rh:contains" for o in sd[p]]
                    if sorted(o for _, o in specific) != sorted(sd.get("rh:contains", [])):
                        reasons.append(("malformed_record", f"{side}: contains predicates do not match"))
                    if not specific:
                        reasons.append(("malformed_record", f"{side}: no participant"))
                    plist = []
                    for p, part in specific:
                        pd_ = T.get(part, {})
                        comps = pd_.get("rh:compound", [])
                        loc = (pd_.get("rh:location", [""]) or [""])[0]
                        if len(comps) != 1:
                            reasons.append(("malformed_record", f"{part}: compound {comps}"))
                            continue
                        cnum = re.fullmatch(r"Compound_(\d+)", comps[0])
                        plist.append((int(cnum.group(1)) if cnum else 10**12, LOC_ORDER.get(loc, 9), p, part, comps[0], loc))
                    for _, _, p, part, comp, loc in sorted(plist):
                        ctext = coef_of.get(p, p).strip()
                        k = None
                        if re.fullmatch(r"\d+", ctext):
                            k = int(ctext)
                            if k <= 0:
                                reasons.append(("non_integer_coefficient", f"{part}: {ctext}")); k = None
                        elif re.fullmatch(r"\d+[./]\d+", ctext):
                            reasons.append(("non_integer_coefficient", f"{part}: {ctext}"))
                        else:
                            reasons.append(("symbolic_coefficient", f"{part}: {ctext}"))
                        if loc:
                            has_loc = True
                        cd = T.get(comp, {})
                        subs = cd.get("rdfs:subClassOf", [])
                        acc_r = (cd.get("rh:accession", [""]) or [""])[0]
                        ids = []
                        if "Polymer" in subs:
                            kind = "polymer"
                            reasons.append(("polymer_participant", f"{acc_r} {cd.get('rh:name', [''])[0]} index "
                                            f"{cd.get('rh:polymerizationIndex', [''])[0]}"))
                        elif any(s.startswith("Generic") for s in subs):
                            kind = "generic"
                            rps = sorted(cd.get("rh:reactivePart", []),
                                         key=lambda s: (int(re.search(r"(\d+)$", s).group(1)) if re.search(r"(\d+)$", s) else 0, s))
                            if not rps:
                                reasons.append(("generic_without_reactive_part", f"{acc_r} {cd.get('rh:name', [''])[0]}"))
                            macro = True
                            for rp in rps:
                                rd = T.get(rp, {})
                                cid = next((x for x in rd.get("rh:chebi", []) + rd.get("rh:accession", [])
                                            if re.fullmatch(r"CHEBI:\d+", x)), None)
                                if cid is None:
                                    reasons.append(("participant_without_chebi_id", f"{rp} of {acc_r}"))
                                else:
                                    ids.append((cid, rd))
                        elif "SmallMolecule" in subs:
                            kind = "small"
                            cid = next((x for x in cd.get("rh:chebi", []) + cd.get("rh:accession", [])
                                        if re.fullmatch(r"CHEBI:\d+", x)), None)
                            if cid is None:
                                reasons.append(("participant_without_chebi_id", f"{comp} {acc_r}"))
                            else:
                                ids.append((cid, cd))
                        else:
                            kind = "other"
                            reasons.append(("participant_without_chebi_id", f"{comp} {acc_r} kind {subs}"))
                        parts.append(dict(side="L" if sign < 0 else "R", coefficient=ctext, compound=comp, accession=acc_r,
                                          kind=kind, location=loc, chebi=[i for i, _ in ids]))
                        for cid, rd in ids:
                            sp = species(cid)
                            sp.setdefault("rhea_formula", (rd.get("rh:formula", [""]) or [""])[0])
                            sp.setdefault("rhea_charge", (rd.get("rh:charge", [""]) or [""])[0])
                            used_species[cid] = sp
                            if not sp["ok"]:
                                reasons.append((sp["reason"], sp["detail"]))
                            elif sp["frozen_reason"]:
                                frozen_only.append((sp["frozen_reason"], sp["frozen_detail"]))
                            if k is not None:
                                terms.append((sign * k, cid))
        codes = sorted({c for c, _ in reasons}, key=REASONS.index)
        rec["n_participants"] = len(parts)
        rec["n_terms"] = len(terms)
        rec["participants"] = json.dumps(parts)
        rec["all_reasons"] = ";".join(codes)
        rec["reason_detail"] = " || ".join(sorted({f"{c}: {dt}" for c, dt in reasons}))
        rec["reason_code"] = codes[0] if codes else ""
        rec["expressible"] = not codes
        fcodes = sorted({c for c, _ in reasons + frozen_only}, key=REASONS.index)
        rec["frozen_expressible"] = not fcodes
        rec["frozen_reason_code"] = fcodes[0] if fcodes else ""
        rec["frozen_all_reasons"] = ";".join(fcodes)
        rec["frozen_reason_detail"] = " || ".join(sorted({f"{c}: {dt}" for c, dt in reasons + frozen_only}))
        rec["flag_amendment1_symbol_A"] = (not codes) and bool(fcodes)
        rec["flag_compartments_ignored"] = has_loc
        rec["flag_macromolecule_reactive_part"] = macro
        rec["_terms"] = terms
        eq = txt_eq.get(mid)
        rec["txt_equation"] = eq or ""
        ms = txt_multiset(eq) if eq else None
        mine = sorted((pp["side"], pp["coefficient"], i) for pp in parts for i in pp["chebi"])
        rec["txt_agrees"] = "" if ms is None else str(ms == mine)
        records.append(rec)

    # ---------------- pre-check (level X) and statements
    for rec in records:
        rec["flag_pseudo_quantity"] = False
        rec["flag_chebi_rows_agree_after_parsing"] = False
        rec["flag_chebi257_differs_from_rhea_copy"] = False
        rec["imbalance"] = ""; rec["imbalance_abs_sum"] = None; rec["n_quantities_off"] = None
        rec["generator_prediction"] = ""; rec["statement"] = ""; rec["tactic"] = ""; rec["theorem"] = ""
        if not rec["expressible"]:
            continue
        net = defaultdict(int)
        for c, acc in rec["_terms"]:
            sp = used_species[acc]
            for sym, n in sp["comp"].items():
                net[QTY[sym]] += c * n
                if sym in PSEUDO:
                    rec["flag_pseudo_quantity"] = True
            net[0] += c * sp["charge"]
            if sp["rows_agree_after_parsing"]:
                rec["flag_chebi_rows_agree_after_parsing"] = True
        off = OrderedDict((QNAME[q], v) for q, v in sorted(net.items()) if v != 0)
        rec["generator_prediction"] = "unbalanced" if off else "balanced"
        rec["imbalance"] = json.dumps(off) if off else ""
        rec["imbalance_abs_sum"] = sum(abs(v) for v in off.values())
        rec["n_quantities_off"] = len(off)
        ov = overrides.get(str(rec["rhea_id"]), {})
        rec["statement"] = ov.get("statement", rec["generator_prediction"])
        rec["tactic"] = ov.get("tactic", a.tactic)
        if rec["statement"] == "none":
            rec["expressible"] = False
            rec["reason_code"] = rec["all_reasons"] = "kernel_did_not_accept"
            rec["reason_detail"] = ov.get("detail", "")
            if rec["frozen_expressible"]:
                rec["frozen_expressible"] = False
                rec["frozen_reason_code"] = rec["frozen_all_reasons"] = "kernel_did_not_accept"
        else:
            rec["theorem"] = f"rhea_{rec['rhea_id']}_{rec['statement']}"

    # Rhea-copy comparison (diagnostic)
    def rhea_copy(sp):
        f = re.sub(r"<[^>]+>", "", sp.get("rhea_formula", "") or "")
        comp, err = parse_formula(f, QTY) if f else (None, ("none", ""))
        ch = sp.get("rhea_charge", "") or ""
        q = int(ch) if re.fullmatch(r"[+-]?\d+", ch.strip()) else None
        return comp, q
    for acc, sp in used_species.items():
        sp["differs_from_rhea_copy"] = ""
        if sp["ok"]:
            comp, q = rhea_copy(sp)
            if comp is None or q is None:
                sp["differs_from_rhea_copy"] = "rhea_copy_unparsed"
            else:
                sp["differs_from_rhea_copy"] = str(not (dict(comp) == dict(sp["comp"]) and q == sp["charge"]))
    for rec in records:
        if rec["expressible"]:
            rec["flag_chebi257_differs_from_rhea_copy"] = any(
                used_species[acc]["differs_from_rhea_copy"] == "True" for _, acc in rec["_terms"])

    # ---------------- Lean: species
    root = os.path.join(a.out, LIBDIR)
    os.makedirs(root, exist_ok=True)
    for fn in os.listdir(root):
        if re.fullmatch(r"(Species\d*|Chunk\d+|Balanced|All|KernelSpecies)\.lean", fn):
            os.remove(os.path.join(root, fn))
    ok_species = sorted((acc for acc, sp in used_species.items() if sp["ok"]), key=lambda s: int(s.split(":")[1]))
    lname = lambda acc: "c" + acc.split(":")[1]
    sp_lines = {}
    for acc in ok_species:
        sp = used_species[acc]
        pairs = [(QTY[s], n) for s, n in sp["comp"].items()] + ([(0, sp["charge"])] if sp["charge"] != 0 else [])
        sp["lean_pairs"] = pairs
        sp["lean_string"] = lean_name_string(acc, sp["name"])
        sp_lines[acc] = (f'def {lname(acc)} : Species := ⟨"{sp["lean_string"]}", '
                         f'[{", ".join(f"({k}, {n})" for k, n in pairs)}]⟩')
    assert len({used_species[x]["lean_string"] for x in ok_species}) == len(ok_species), "species names must be distinct"
    HEAD = ("GENERATED FILE (tools/rx_gen.py). Source: Rhea release 143 (reactions, CC BY 4.0, https://www.rhea-db.org) and\n"
            "ChEBI release 257 (formulas and charges, CC BY 4.0, http://www.ebi.ac.uk/chebi). Each definition is a data\n"
            "axiom copied from those files; the kernel checks what follows from it, not that it describes the molecule.\n"
            "Pairs are (quantity, amount): 0 is charge, 1..118 atomic numbers, 1000 the generic group R, 1001 the generic halogen X,\n"
            "1002 the generic hydrogen acceptor A (rx_choices_amendment_1.md).")
    sfiles = []
    for i in range(0, len(ok_species), SPECIES_PER_FILE):
        name = f"Species{i // SPECIES_PER_FILE:02d}"
        L = ["import BioCore.Core", "/-!", f"# {MOD}.{name}", "", HEAD, "-/", "namespace BioCore.Rhea", ""]
        L += [sp_lines[acc] for acc in ok_species[i:i + SPECIES_PER_FILE]]
        L += ["", "end BioCore.Rhea", ""]
        open(os.path.join(root, name + ".lean"), "w").write("\n".join(L)); sfiles.append(name)
    open(os.path.join(root, "Species.lean"), "w").write(
        "".join(f"import {MOD}.{n}\n" for n in sfiles) + "/-! GENERATED: all species of the reaction library. -/\n")

    # ---------------- Lean: chunks
    expr = sorted((r for r in records if r["expressible"]), key=lambda r: r["rhea_id"])
    manifest = OrderedDict()
    chunk_names = []
    for i in range(0, len(expr), CHUNK):
        cname = f"Chunk{i // CHUNK + 1:04d}"; chunk_names.append(cname)
        L = [f"import {MOD}.Species", f"import {MOD}.Basic", "/-!", f"# {MOD}.{cname}", "", HEAD,
             "A negative coefficient is the left side of the Rhea equation. One theorem per reaction; the statement",
             "was predicted by the generator and is accepted or rejected by the kernel.", "-/",
             "namespace BioCore.Rhea", "open BioCore", ""]
        entries = []
        bal = []
        for r in expr[i:i + CHUNK]:
            rid = r["rhea_id"]; r["chunk"] = cname
            body = ", ".join(f"({c}, {lname(acc)})" for c, acc in r["_terms"])
            L.append(f"def rhea_{rid} : FSum := [{body}]")
            stmt = f"Balanced rhea_{rid}" if r["statement"] == "balanced" else f"¬ Balanced rhea_{rid}"
            pre = ""
            if r["tactic"] == "decide +kernel +opts":
                pre, tac = "set_option maxRecDepth 100000 in set_option maxHeartbeats 0 in ", "decide +kernel"
            else:
                tac = r["tactic"]
            L.append(f"{pre}theorem {r['theorem']} : {stmt} := by {tac}")
            entries.append(dict(rhea_id=rid, theorem=r["theorem"], line="\n".join(L).count("\n") + 1))
            if r["statement"] == "balanced":
                bal.append(rid)
        L.append("")
        blocks = []
        for j in range(0, len(bal), BLOCK):
            b = f"balanced_{cname}_b{j // BLOCK:02d}"; blocks.append(b)
            ids = bal[j:j + BLOCK]
            L.append(f"def {b} : List FSum := [{', '.join(f'rhea_{x}' for x in ids)}]")
            proof = "bal_nil"
            for x in reversed(ids):
                proof = f"bal_cons rhea_{x}_balanced ({proof})"
            L.append(f"theorem {b}_all : ∀ r ∈ {b}, Balanced r := {proof}")
        lst, proof = "[]", "bal_nil"
        for b in reversed(blocks):
            lst = f"{b} ++ ({lst})"; proof = f"bal_append {b}_all ({proof})"
        L.append(f"/-- The reactions of this file that are proved balanced. -/")
        L.append(f"def balanced_{cname} : List FSum := {lst}")
        L.append(f"theorem balanced_{cname}_all : ∀ r ∈ balanced_{cname}, Balanced r := {proof}")
        L += ["", "end BioCore.Rhea", ""]
        text = "\n".join(L)
        open(os.path.join(root, cname + ".lean"), "w").write(text)
        manifest[cname] = dict(sha256=hashlib.sha256(text.encode()).hexdigest(), theorems=entries, n_balanced=len(bal))
    for r in records:
        r.setdefault("chunk", "")
    lst, proof = "[]", "bal_nil"
    for cname in reversed(chunk_names):
        lst = f"balanced_{cname} ++ ({lst})"; proof = f"bal_append balanced_{cname}_all ({proof})"
    open(os.path.join(root, "Balanced.lean"), "w").write(
        "".join(f"import {MOD}.{c}\n" for c in chunk_names) + f"import {MOD}.Basic\n" +
        "/-! GENERATED: every reaction of the library that has a `_balanced` theorem, as one list. -/\n"
        "namespace BioCore.Rhea\nopen BioCore\n\n"
        f"def balancedLibrary : List FSum := {lst}\n\n"
        "/-- Every member of `balancedLibrary` is balanced (assembled from the per-reaction theorems). -/\n"
        f"theorem balancedLibrary_all : ∀ r ∈ balancedLibrary, Balanced r := {proof}\n\nend BioCore.Rhea\n")

    # ---------------- Lean: kernel species agree with library species
    ktext = open(os.path.join(a.kernel, "BioCore", "Data", "Monomers.lean"), encoding="utf-8").read()
    kdefs = re.findall(r'^def (c\d+) : Species := ⟨"(.*)", \[(.*)\]⟩$', ktext, re.M)
    krows, KL = [], [f"import BioCore.Data.Monomers", f"import {MOD}.Species",
                     "/-! GENERATED: a species of the kernel (`BioCore.Chebi`) and the library species with the same",
                     "ChEBI accession (`BioCore.Rhea`) are the same term, wherever the library has that accession. -/",
                     "namespace BioCore.Rhea", ""]
    for nm, s, pairs in kdefs:
        acc = "CHEBI:" + nm[1:]
        sp = used_species.get(acc)
        if sp is None or not sp["ok"]:
            krows.append(dict(chebi=acc, in_library=False, same=""))
            continue
        mine = ", ".join(f"({k}, {n})" for k, n in sp["lean_pairs"])
        same = (s == sp["lean_string"] and pairs == mine)
        krows.append(dict(chebi=acc, in_library=True, same=same, kernel=f"{s} [{pairs}]", library=f"{sp['lean_string']} [{mine}]"))
        if same:
            KL.append(f"theorem kernel_{nm} : BioCore.Chebi.{nm} = {nm} := rfl")
    KL += ["", "end BioCore.Rhea", ""]
    open(os.path.join(root, "KernelSpecies.lean"), "w").write("\n".join(KL))
    json.dump(krows, open(os.path.join(a.tables, "rx_kernel_species_check.json"), "w"), indent=1)

    hand = [n for n in ("Statements",) if os.path.exists(os.path.join(root, n + ".lean"))]
    open(os.path.join(root, "All.lean"), "w").write(
        f"import {MOD}.Basic\nimport {MOD}.Species\n" + "".join(f"import {MOD}.{c}\n" for c in chunk_names) +
        f"import {MOD}.Balanced\nimport {MOD}.KernelSpecies\n" + "".join(f"import {MOD}.{n}\n" for n in hand) +
        "/-! GENERATED: root of the reaction library. Build: `lake build +BioCore.Library.Reactions.All`. -/\n")

    # ---------------- audit sample
    gen_thms = [r["theorem"] for r in expr]
    order = sorted(gen_thms, key=lambda n: hashlib.sha256((AUDIT_SEED + n).encode()).hexdigest())
    sample = order[:AUDIT_N]
    json.dump(dict(seed=AUDIT_SEED, n=len(sample), sample=sample), open(os.path.join(a.tables, "rx_audit_sample.json"), "w"))

    # ---------------- tables
    json.dump(manifest, open(os.path.join(a.tables, "rx_chunk_manifest.json"), "w"))
    with open(os.path.join(a.tables, "rx_gen_records.jsonl"), "w") as f:
        for r in records:
            o = {k: v for k, v in r.items() if k != "_terms"}
            o["terms"] = json.dumps(r["_terms"])
            f.write(json.dumps(o) + "\n")
    with open(os.path.join(a.tables, "rx_species.tsv"), "w") as f:
        f.write("chebi\tlean_name\tok\treason\tname\tformula_text\tcharge_text\tlean_pairs\trows_agree_after_parsing\t"
                "in_secondary_ids\trhea_formula\trhea_charge\tdiffers_from_rhea_copy\n")
        for acc in sorted(used_species, key=lambda s: int(s.split(":")[1])):
            sp = used_species[acc]
            f.write("\t".join(str(x).replace("\t", " ").replace("\n", " ") for x in (
                acc, lname(acc) if sp["ok"] else "", sp["ok"], sp["reason"] or "", sp["name"], sp["formula"], sp["charge_text"],
                sp.get("lean_pairs", ""), sp["rows_agree_after_parsing"], sp["in_secondary_ids"],
                sp.get("rhea_formula", ""), sp.get("rhea_charge", ""), sp.get("differs_from_rhea_copy", ""))) + "\n")
    n = len(records); ne = len(expr)
    log(f"records {n}; expressible {ne}; not expressible {n - ne}; chunks {len(chunk_names)}; "
        f"species used {len(used_species)}; species emitted {len(ok_species)}; species files {len(sfiles)}")
    assert ne + sum(1 for r in records if not r["expressible"]) == n == len(masters)
    log("generator prediction counts (level X):",
        json.dumps({k: sum(1 for r in expr if r["generator_prediction"] == k) for k in ("balanced", "unbalanced")}))
    cnt = defaultdict(int)
    for r in records:
        if not r["expressible"]:
            cnt[r["reason_code"]] += 1
    log("not expressible by primary reason:", json.dumps(dict(sorted(cnt.items(), key=lambda kv: REASONS.index(kv[0])))))
    cnt = defaultdict(int)
    for r in records:
        if not r["frozen_expressible"]:
            cnt[r["frozen_reason_code"]] += 1
    log("under the unamended rx_choices.md: expressible", sum(1 for r in records if r["frozen_expressible"]),
        "not expressible by primary reason:", json.dumps(dict(sorted(cnt.items(), key=lambda kv: REASONS.index(kv[0])))))
    log("DONE rx_gen")


if __name__ == "__main__":
    main()
