#!/usr/bin/env python3
"""Gene library (track gn), Kaggle session 1: sources, parsing, expressibility, level X (Lean program),
independent Python re-implementation, optional Biopython, and the 20-record timing set.

Follows gn_choices.md. Everything here is level X except the timing set, whose modules are level K
statements built to measure cost. No record is skipped: assertions check that classes sum to the scope.
"""
import argparse, gzip, hashlib, json, os, re, subprocess, sys, time, collections, shutil

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gn_common as C
import gn_parse as P
import gn_pydecode as PD
import gn_lean_gen as G

ap = argparse.ArgumentParser()
ap.add_argument("--biocore", required=True)
ap.add_argument("--work", required=True)
ap.add_argument("--out", required=True)
ap.add_argument("--skip-timing", action="store_true")
ap.add_argument("--local-sources", default=None, help="development only: directory with already fetched sources")
ap.add_argument("--lean-bin", default=None, help="development only: existing Lean bin directory")
args = ap.parse_args()
BC, WORK, OUT = os.path.abspath(args.biocore), os.path.abspath(args.work), os.path.abspath(args.out)
os.makedirs(WORK, exist_ok=True)
os.makedirs(OUT, exist_ok=True)
C.set_log(os.path.join(OUT, "gn_s1_log.txt"))
C.log("session 1 start; machine:", json.dumps(C.machine_info()))
meta = {"machine": C.machine_info(), "started_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())}
meta["choices_sha256"] = C.sha256_file(os.path.join(BC, "gn_choices.md")) if os.path.exists(os.path.join(BC, "gn_choices.md")) else None

# ---- 1. frozen kernel hashes
ok, lines = C.check_kernel_hashes(BC)
open(os.path.join(OUT, "gn_s1_kernel_check.txt"), "w").write("\n".join(lines) + "\n")
C.log("kernel hashes all OK:", ok)
if not ok:
    raise SystemExit("frozen kernel files differ from KERNEL_SHA256.txt: stop")

# ---- 2. Lean
if args.lean_bin:
    LEAN_BIN, lean_info = args.lean_bin, {"development_local_toolchain": args.lean_bin}
else:
    LEAN_BIN, lean_info = C.setup_lean(WORK)
meta["lean"] = lean_info
ENV = dict(os.environ, PATH=LEAN_BIN + ":" + os.environ["PATH"])
BLOG = os.path.join(OUT, "gn_s1_build_log.txt")
rc, out, secs = C.run(["lake", "build"], BC, ENV, log_path=BLOG)
C.log("frozen kernel `lake build`: exit", rc, "%.1f s" % secs)
meta["kernel_build"] = {"exit": rc, "seconds": round(secs, 2)}
if rc != 0:
    raise SystemExit("the frozen kernel does not build: stop (no patch)")
rc, out, secs = C.run(["lake", "env", "lean", "Audit.lean"], BC, ENV, log_path=BLOG)
meta["kernel_audit_exit"] = rc
rc, out, secs = C.run(["lake", "-f", "lakefile_gn.toml", "build", "+BioCore.Library.Genes.Pack", "gn_decode"], BC, ENV, log_path=BLOG)
C.log("library support files and level-X program build: exit", rc, "%.1f s" % secs)
meta["support_build"] = {"exit": rc, "seconds": round(secs, 2)}
if rc != 0:
    raise SystemExit("the gene-library support files do not build")

# ---- 3. sources
SRC = os.path.join(WORK, "src")
os.makedirs(SRC, exist_ok=True)
sources = {}
if args.local_sources:
    for f in os.listdir(args.local_sources):
        shutil.copy(os.path.join(args.local_sources, f), os.path.join(SRC, f))
        sources[f] = {"file": f, "sha256": C.sha256_file(os.path.join(SRC, f)), "development_local_copy": True}
    versions_txt = open(os.path.join(SRC, "README_versions.txt")).read()
else:
    sources["README_versions.txt"] = C.download(C.MANE_DIR + "README_versions.txt", os.path.join(SRC, "README_versions.txt"))
    versions_txt = open(os.path.join(SRC, "README_versions.txt")).read()
m = re.search(r"MANE Version\s+(\S+)", versions_txt)
MANE_VERSION = m.group(1)
C.log("MANE release:", MANE_VERSION, "|", versions_txt.replace("\n", " | "))
GB_NAME = "MANE.GRCh38.v%s.refseq_rna.gbff.gz" % MANE_VERSION
SUM_NAME = "MANE.GRCh38.v%s.summary.txt.gz" % MANE_VERSION
if not args.local_sources:
    sources[GB_NAME] = C.download(C.MANE_DIR + GB_NAME, os.path.join(SRC, GB_NAME))
    sources[SUM_NAME] = C.download(C.MANE_DIR + SUM_NAME, os.path.join(SRC, SUM_NAME))
    sources["NC_012920.1.gb"] = C.download(C.MITO_URL, os.path.join(SRC, "NC_012920.1.gb"))
    sources["gc.prt"] = C.download(C.GC_URL, os.path.join(SRC, "gc.prt"))
    # the directory listing, for the record
    try:
        sources["MANE_current_listing.html"] = C.download(C.MANE_DIR, os.path.join(SRC, "MANE_current_listing.html"))
    except Exception as e:
        C.log("listing not saved:", repr(e))
meta["mane_version"] = MANE_VERSION
meta["mane_versions_file"] = versions_txt
kernel_gc = None
for l in open(os.path.join(BC, "sources", "SOURCE_SHA256.txt")):
    if l.strip().endswith("gc.prt"):
        kernel_gc = l.split()[0]
meta["gc_prt_sha256_kernel_archive"] = kernel_gc
meta["gc_prt_sha256_downloaded"] = sources["gc.prt"]["sha256"]
meta["gc_prt_same_as_kernel_archive"] = (kernel_gc == sources["gc.prt"]["sha256"])
C.log("gc.prt same file as in the kernel archive:", meta["gc_prt_same_as_kernel_archive"])
meta["sources"] = sources
json.dump(meta, open(os.path.join(OUT, "gn_s1_meta.json"), "w"), indent=1)

# ---- 4. parsing
header, summary = P.read_summary(os.path.join(SRC, SUM_NAME))
C.log("summary rows:", len(summary), "columns:", header)
status_counts = collections.Counter(r["MANE_status"] for r in summary)
C.log("MANE_status counts:", dict(status_counts))
GROUP = {"MANE Select": "SELECT", "MANE Plus Clinical": "PLUS_CLINICAL"}

flat = {}
dup_flat = []
n_flat = 0
for lines in P.iter_raw_records(os.path.join(SRC, GB_NAME)):
    rec = P.parse_record(lines)
    n_flat += 1
    v = rec["version"]
    if v in flat:
        dup_flat.append(v)
        if flat[v]["seq"] != rec["seq"]:
            raise SystemExit("two flat-file records with version %s and different sequences" % v)
        continue
    flat[v] = rec
C.log("flat-file records:", n_flat, "distinct versions:", len(flat), "duplicates:", len(dup_flat))
for v, rec in flat.items():
    if rec["locus_len"] is not None and rec["locus_len"] != len(rec["seq"]):
        raise SystemExit("record %s: LOCUS says %s bp, ORIGIN has %d letters" % (v, rec["locus_len"], len(rec["seq"])))

records = []
seen_ids = collections.Counter()
for row in summary:
    rid = row["RefSeq_nuc"]
    seen_ids[rid] += 1
    group = GROUP.get(row["MANE_status"], "OTHER_" + re.sub(r"\W+", "_", row["MANE_status"]))
    r = {"id": rid, "group": group, "mane_status": row["MANE_status"], "gene": row["symbol"], "gene_id": row["NCBI_GeneID"],
         "hgnc_id": row["HGNC_ID"], "ensembl_nuc": row["Ensembl_nuc"], "refseq_prot": row["RefSeq_prot"],
         "accession": rid.split(".")[0], "version": rid.split(".")[1] if "." in rid else "",
         "code": "std", "source_label": "MANE %s, %s" % (MANE_VERSION, GB_NAME)}
    rec = flat.get(rid)
    if rec is None:
        r.update({"record_len": None, "n_cds_features": None, "cds_location_raw": "", "strand": "+", "cds_stretch": "",
                  "translation": None, "ne_reasons": ["NO_FLATFILE_RECORD"], "explanation_categories": ["none_given"],
                  "explanation_quotes": {}, "annotated_len": None, "codon_start": None, "protein_id": None,
                  "gene_in_flatfile": None, "product": None, "cds_start": None, "cds_end": None, "non_acgt": [],
                  "transl_table": None})
    else:
        cds = [f for f in rec["features"] if f[0] == "CDS"]
        r["record_len"] = len(rec["seq"])
        r["n_cds_features"] = len(cds)
        if len(cds) == 1:
            r.update(P.cds_record(rec, cds[0], genome=False))
        else:
            r.update({"cds_location_raw": " | ".join(f[1] for f in cds), "strand": "+", "cds_stretch": "", "translation": None,
                      "ne_reasons": ["CDS_FEATURE_COUNT_%d" % len(cds)], "explanation_categories": ["none_given"],
                      "explanation_quotes": {"RefSeq-Attributes": rec["attributes"]} if rec["attributes"] else {},
                      "annotated_len": None, "codon_start": None, "protein_id": None, "gene_in_flatfile": None,
                      "product": None, "cds_start": None, "cds_end": None, "non_acgt": [], "transl_table": None})
    records.append(r)
dups = {k: v for k, v in seen_ids.items() if v > 1}
if dups:
    raise SystemExit("summary has repeated RefSeq_nuc values: %r" % dups)
in_summary = set(seen_ids)
out_of_scope = sorted(v for v in flat if v not in in_summary)
with open(os.path.join(OUT, "gn_s1_flatfile_not_in_summary.tsv"), "w") as fh:
    fh.write("version\tlength\tdefinition\n")
    for v in out_of_scope:
        fh.write("%s\t%d\t%s\n" % (v, len(flat[v]["seq"]), flat[v]["definition"]))
C.log("flat-file records not in the summary (outside the scope):", len(out_of_scope))

# mitochondrial genome
mito_recs = [P.parse_record(l) for l in P.iter_raw_records(os.path.join(SRC, "NC_012920.1.gb"))]
assert len(mito_recs) == 1 and mito_recs[0]["version"] == "NC_012920.1", [m["version"] for m in mito_recs]
mrec = mito_recs[0]
assert mrec["locus_len"] == len(mrec["seq"]), (mrec["locus_len"], len(mrec["seq"]))
mito_cds = [f for f in mrec["features"] if f[0] == "CDS"]
C.log("mitochondrial CDS features:", len(mito_cds))
meta["mito_cds_features"] = len(mito_cds)
mito_ids = collections.Counter()
for f in mito_cds:
    d = P.cds_record(mrec, f, genome=True)
    gene = d["gene_in_flatfile"] or ("CDS_%s" % re.sub(r"\W+", "_", f[1]))
    rid = "NC_012920.1:%s" % gene
    mito_ids[rid] += 1
    r = {"id": rid, "group": "MITO", "mane_status": "", "gene": gene, "gene_id": "", "hgnc_id": "", "ensembl_nuc": "",
         "refseq_prot": d["protein_id"] or "", "accession": "NC_012920", "version": "1", "code": "mito",
         "source_label": "RefSeq NC_012920.1 through E-utilities", "record_len": len(mrec["seq"]), "n_cds_features": 1}
    r.update(d)
    records.append(r)
assert max(mito_ids.values()) == 1, mito_ids
ids = [r["id"] for r in records]
assert len(set(ids)) == len(ids)
assert len(set(G.ident(i) for i in ids)) == len(ids), "Lean identifiers are not unique"
SCOPE = len(records)
group_counts = collections.Counter(r["group"] for r in records)
C.log("scope:", SCOPE, dict(group_counts))

for r in records:
    r["expressible"] = (len(r["ne_reasons"]) == 0)
    r["cds_len"] = len(r["cds_stretch"]) if r["expressible"] else None
    r["annotation_outside_alphabet"] = (r["translation"] is not None and not set(r["translation"]) <= P.KERNEL_AA)
    r["sha256_id"] = hashlib.sha256(r["id"].encode("utf-8")).hexdigest()

with gzip.open(os.path.join(OUT, "gn_records.jsonl.gz"), "wt", encoding="utf-8") as fh:
    for r in records:
        fh.write(json.dumps(r) + "\n")

# ---- 5. level X: the Lean program
expr = [r for r in records if r["expressible"]]
xin = os.path.join(WORK, "gn_x_input.tsv")
with open(xin, "w") as fh:
    for r in expr:
        fh.write("%s\t%s\t%s\t%s\n" % (r["id"], r["code"], r["strand"], r["cds_stretch"]))
xout = os.path.join(WORK, "gn_x_lean_output.tsv")
t = time.time()
p = subprocess.run("ulimit -s unlimited 2>/dev/null || ulimit -s 1000000 2>/dev/null; lake -f lakefile_gn.toml exe gn_decode %s %s" % (xin, xout),
                   shell=True, cwd=BC, env=ENV, capture_output=True, text=True, executable="/bin/bash")
meta["level_x_program"] = {"exit": p.returncode, "seconds": round(time.time() - t, 2), "stdout": p.stdout[-500:], "stderr": p.stderr[-2000:]}
C.log("level-X Lean program: exit", p.returncode, "%.1f s" % (time.time() - t), p.stdout.strip()[-200:], p.stderr.strip()[-300:])
if p.returncode != 0:
    raise SystemExit("the level-X Lean program failed")
for src in (xin, xout):
    with open(src, "rb") as a, gzip.open(os.path.join(OUT, os.path.basename(src) + ".gz"), "wb") as b:
        shutil.copyfileobj(a, b)
lean_x = {}
for line in open(xout, encoding="utf-8"):
    f = line.rstrip("\n").split("\t")
    assert len(f) == 6, f[:5]
    assert f[0] not in lean_x
    lean_x[f[0]] = f
assert set(lean_x) == set(r["id"] for r in expr), "the Lean program did not return exactly the records given"

# ---- 6. independent Python re-implementation
tables = {"std": PD.read_gc_prt(os.path.join(SRC, "gc.prt"), 1), "mito": PD.read_gc_prt(os.path.join(SRC, "gc.prt"), 2)}
meta["gc_tables"] = {k: {"names": v["names"], "ncbieaa": v["ncbieaa"], "sncbieaa": v["sncbieaa"]} for k, v in tables.items()}
py_x = {}
with gzip.open(os.path.join(OUT, "gn_x_python.tsv.gz"), "wt") as fh:
    for r in expr:
        v = PD.decode(tables[r["code"]], r["cds_stretch"], r["strand"])
        py_x[r["id"]] = v
        fh.write("%s\t%s\t%s\t%s\t%s\n" % ((r["id"],) + v))

# ---- 7. classes
agree = disagree = 0
dis_list = []
for r in records:
    if not r["expressible"]:
        r.update({"cls": "NOT_EXPRESSIBLE", "ne_reason": r["ne_reasons"][0], "x_verdict": "", "x_reason": "", "x_pos": "",
                  "x_protein": "", "x_nbases": None, "py_verdict": "", "py_reason": "", "py_pos": "", "py_protein": "",
                  "x_py_agree": None})
        continue
    f = lean_x[r["id"]]
    if f[2] == "ERROR":
        raise SystemExit("the Lean program reported ERROR for %s: %s" % (r["id"], f[3]))
    assert int(f[1]) == len(r["cds_stretch"]), (r["id"], f[1])
    r.update({"x_nbases": int(f[1]), "x_verdict": f[2], "x_reason": f[3], "x_pos": f[4], "x_protein": f[5], "ne_reason": ""})
    v = py_x[r["id"]]
    r.update({"py_verdict": v[0], "py_reason": v[1], "py_pos": v[2], "py_protein": v[3]})
    same = (tuple(f[2:6]) == tuple(v))
    r["x_py_agree"] = same
    if same:
        agree += 1
    else:
        disagree += 1
        dis_list.append({"id": r["id"], "lean": f[2:6], "python": list(v)})
    if f[2] == "ok":
        r["cls"] = "ACCEPTED_EQUAL" if f[5] == r["translation"] else "ACCEPTED_DIFFERENT"
    elif f[2] == "rejected":
        r["cls"] = "REJECTED"
    else:
        raise SystemExit("unknown verdict %r" % f[2])
C.log("Lean program vs Python: agree", agree, "disagree", disagree, "of", len(expr))
json.dump(dis_list, open(os.path.join(OUT, "gn_x_disagreements.json"), "w"), indent=1)

# diagnostics (level X, Python)
for r in records:
    r["diag_transl_except_at_stop"] = None
    r["diag_first_codon"] = None
    r["diag_len_mod3"] = None
    if not r["expressible"]:
        continue
    s = r["cds_stretch"] if r["strand"] == "+" else "".join(PD.COMP[c] for c in reversed(r["cds_stretch"]))
    r["diag_first_codon"] = s[:3]
    r["diag_len_mod3"] = len(s) % 3
    if r["cls"] == "REJECTED" and r["x_reason"] == "internalStop":
        i = int(r["x_pos"])
        a = r["cds_start"] + 3 * i
        want = "(pos:%d..%d," % (a, a + 2)
        r["diag_transl_except_at_stop"] = any(v.replace(" ", "").startswith(want) for v in r["explanation_quotes"].get("transl_except", []))
        r["diag_stop_codon"] = s[3 * i:3 * i + 3]

cls_counts = collections.Counter(r["cls"] for r in records)
by_group = collections.Counter((r["group"], r["cls"]) for r in records)
assert sum(cls_counts.values()) == SCOPE
for g, n in group_counts.items():
    assert sum(v for (gg, c), v in by_group.items() if gg == g) == n
C.log("classes:", dict(cls_counts))
C.log("by group:", {"%s/%s" % k: v for k, v in sorted(by_group.items())})
meta["scope"] = SCOPE
meta["group_counts"] = dict(group_counts)
meta["class_counts"] = dict(cls_counts)
meta["class_by_group"] = {"%s/%s" % k: v for k, v in sorted(by_group.items())}
meta["x_python_agree"] = agree
meta["x_python_disagree"] = disagree
meta["n_expressible"] = len(expr)
meta["flatfile_records"] = n_flat
meta["flatfile_not_in_summary"] = len(out_of_scope)
meta["mane_status_counts"] = dict(status_counts)
json.dump(meta, open(os.path.join(OUT, "gn_s1_meta.json"), "w"), indent=1)

with gzip.open(os.path.join(OUT, "gn_s1_classified.jsonl.gz"), "wt", encoding="utf-8") as fh:
    for r in records:
        fh.write(json.dumps(r) + "\n")

# ---- 8. Biopython: third opinion and parser cross-check (reported separately; changes no class)
bio = {"available": False}
try:
    try:
        import Bio
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-q", "biopython"])
        import Bio
    from Bio import SeqIO
    from Bio.Seq import Seq
    import warnings
    warnings.simplefilter("ignore")
    bio = {"available": True, "version": Bio.__version__}
    brecs = {}
    with gzip.open(os.path.join(SRC, GB_NAME), "rt") as fh:
        for br in SeqIO.parse(fh, "genbank"):
            brecs[br.id] = br
    brecs["NC_012920.1"] = SeqIO.read(os.path.join(SRC, "NC_012920.1.gb"), "genbank")
    bio["records_parsed"] = len(brecs)
    parse_checked = parse_mismatch = 0
    tr_checked = tr_mismatch = 0
    mism = []
    mito_feats = {}
    for f in brecs["NC_012920.1"].features:
        if f.type == "CDS":
            mito_feats["NC_012920.1:%s" % f.qualifiers.get("gene", ["?"])[0]] = f
    with gzip.open(os.path.join(OUT, "gn_x_biopython.tsv.gz"), "wt") as out:
        out.write("id\tparse_same\ttranslate_same\tbio_first_aa\tbio_translation\n")
        for r in records:
            if r["group"] == "MITO":
                br, feats = brecs["NC_012920.1"], [mito_feats.get(r["id"])]
            else:
                br = brecs.get(r["id"])
                feats = [f for f in br.features if f.type == "CDS"] if br is not None else []
            if br is None or len(feats) != 1 or feats[0] is None:
                same = (not r["expressible"]) and (r["n_cds_features"] in (None,) or r["n_cds_features"] != 1 or br is None)
                out.write("%s\t%s\t\t\t\n" % (r["id"], "no_single_CDS_both" if same else "MISMATCH_feature_count"))
                parse_checked += 1
                if not same:
                    parse_mismatch += 1
                    mism.append({"id": r["id"], "what": "feature count"})
                continue
            f = feats[0]
            btr = f.qualifiers.get("translation", [None])[0]
            ok_parse = (btr == r["translation"]) and (len(br.seq) == r["record_len"])
            bseq = None
            if r["expressible"]:
                bseq = str(f.extract(br.seq)).upper()
                mine = r["cds_stretch"] if r["strand"] == "+" else "".join(PD.COMP[c] for c in reversed(r["cds_stretch"]))
                ok_parse = ok_parse and (bseq == mine)
            parse_checked += 1
            if not ok_parse:
                parse_mismatch += 1
                mism.append({"id": r["id"], "what": "translation, length or stretch"})
            tsame, first, btrans = "", "", ""
            if r["expressible"] and r["x_verdict"] == "ok":
                btrans = str(Seq(bseq).translate(table=1 if r["code"] == "std" else 2))
                first = btrans[:1]
                tsame = (btrans[1:] == r["x_protein"][1:] + "*")
                tr_checked += 1
                if not tsame:
                    tr_mismatch += 1
                    mism.append({"id": r["id"], "what": "translate differs from kernel protein"})
            out.write("%s\t%s\t%s\t%s\t%s\n" % (r["id"], ok_parse, tsame, first, btrans))
    bio.update({"parse_checked": parse_checked, "parse_mismatch": parse_mismatch, "translate_checked": tr_checked,
                "translate_mismatch": tr_mismatch, "mismatches": mism})
    C.log("Biopython", bio["version"], "parse checked", parse_checked, "mismatch", parse_mismatch,
          "| translate checked", tr_checked, "mismatch", tr_mismatch)
except Exception as e:
    import traceback
    bio["error"] = traceback.format_exc()
    C.log("Biopython step failed (reported, no class depends on it):", repr(e))
meta["biopython"] = bio
json.dump(meta, open(os.path.join(OUT, "gn_s1_meta.json"), "w"), indent=1)

# ---- 9. timing set (gn_choices.md 8.3)
if not args.skip_timing:
    sel = sorted((r for r in records if r["group"] == "SELECT" and r["expressible"]), key=lambda r: (len(r["cds_stretch"]), r["id"]))
    N = len(sel)
    ranks = [round(i * (N - 1) / 19) for i in range(20)]
    assert len(set(ranks)) == 20
    tset = [sel[k] for k in ranks]
    C.log("timing set:", [(r["id"], len(r["cds_stretch"]), r["cls"]) for r in tset])
    TDIR = os.path.join(BC, "BioCore", "Library", "Genes", "Timing")
    lean_path = os.path.join(BC, ".lake", "build", "lib", "lean")
    TENV = dict(ENV, LEAN_PATH=lean_path)
    timing = []
    tf = open(os.path.join(OUT, "gn_timing.jsonl"), "w")
    for method in ("M2", "M1", "M3"):
        os.makedirs(os.path.join(TDIR, method), exist_ok=True)
        for k, r in zip(ranks, tset):
            src, thms = G.module_source(r, method)
            path = os.path.join(TDIR, method, G.ident(r["id"]) + ".lean")
            open(path, "w").write(src)
            res = C.run_limited(["lean", "-s", "8000000", path], BC, TENV, 3600)
            ax = dict((a, [s.strip() for s in b.split(",") if s.strip()]) for a, b in G.AX_LINE.findall(res["out"]))
            okk = (res["rc"] == 0 and not res["timed_out"] and len(ax) == len(thms)
                   and all(set(v) <= {"propext", "Quot.sound", "Classical.choice"} for v in ax.values()))
            row = {"id": r["id"], "rank": k, "cds_len": len(r["cds_stretch"]), "cls": r["cls"], "method": method,
                   "ok": okk, "rc": res["rc"], "timed_out": res["timed_out"], "seconds": res["seconds"],
                   "user_s": res["user_s"], "sys_s": res["sys_s"], "maxrss_kb": res["maxrss_kb"], "axioms": ax,
                   "source_bytes": len(src), "message": res["out"][-1500:]}
            timing.append(row)
            tf.write(json.dumps(row) + "\n")
            tf.flush()
            C.log("timing", method, r["id"], "len", len(r["cds_stretch"]), "ok", okk, "%.2f s" % res["seconds"],
                  "rss %.0f MB" % (res["maxrss_kb"] / 1024))
    tf.close()
    # the same 20 records, method M2, through the batch driver (lake, parallel jobs)
    RDIR = os.path.join(BC, "BioCore", "Library", "Genes", "Rec")
    os.makedirs(RDIR, exist_ok=True)
    os.makedirs(os.path.join(BC, "BioCore", "Library", "Genes", "Batch"), exist_ok=True)
    mods = []
    for r in tset:
        src, thms = G.module_source(r, "M2")
        open(os.path.join(RDIR, G.ident(r["id"]) + ".lean"), "w").write(src)
        mods.append(G.MOD_PREFIX + G.ident(r["id"]))
    open(os.path.join(BC, "BioCore", "Library", "Genes", "Batch", "Timing20.lean"), "w").write(G.batch_root_source(mods))
    t = time.time()
    p = subprocess.run(["lake", "-f", "lakefile_gn.toml", "build", "+BioCore.Library.Genes.Batch.Timing20"], cwd=BC, env=ENV,
                       capture_output=True, text=True)
    wall = time.time() - t
    open(os.path.join(OUT, "gn_timing_lake_batch_log.txt"), "w").write(p.stdout + p.stderr)
    parsed = G.parse_lake_log(p.stdout + p.stderr)
    lake_rows = []
    for r, mname in zip(tset, mods):
        v = parsed.get(mname, {})
        lake_rows.append({"id": r["id"], "cds_len": len(r["cds_stretch"]), "mark": v.get("mark"), "action": v.get("action"),
                          "seconds": v.get("seconds"), "time_text": v.get("time_text"), "axioms": v.get("axioms")})
    json.dump({"exit": p.returncode, "wall_seconds": round(wall, 2), "rows": lake_rows}, open(os.path.join(OUT, "gn_timing_lake_batch.json"), "w"), indent=1)
    C.log("lake batch of the 20 timing records (M2): exit", p.returncode, "wall %.1f s" % wall)
    subprocess.check_call(["tar", "-czf", os.path.join(OUT, "gn_timing_modules.tgz"), "-C", BC, "BioCore/Library/Genes/Timing", "BioCore/Library/Genes/Rec", "BioCore/Library/Genes/Batch"])

meta["finished_utc"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
meta["session_seconds"] = round(time.time() - C.T0, 1)
json.dump(meta, open(os.path.join(OUT, "gn_s1_meta.json"), "w"), indent=1)
C.log("session 1 done")
