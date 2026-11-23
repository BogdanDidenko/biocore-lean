#!/usr/bin/env python3
"""Gene library (track gn), Kaggle level-K sessions: one Lean module per record, built with `lake build`
in batches, in the order of gn_choices.md 8.5. Level K means: the module was compiled by Lean 4.36.0
(elaborated and accepted by its kernel) and `#print axioms` shows only standard axioms.
"""
import argparse, glob, gzip, hashlib, json, os, re, shutil, signal, subprocess, sys, threading, time, collections

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gn_common as C
import gn_lean_gen as G

ap = argparse.ArgumentParser()
ap.add_argument("--biocore", required=True)
ap.add_argument("--work", required=True)
ap.add_argument("--out", required=True)
ap.add_argument("--s1", default=None, help="directory with the session-1 outputs (default: searched under /kaggle/input)")
ap.add_argument("--prev", nargs="*", default=None, help="directories with earlier level-K session outputs")
ap.add_argument("--label", required=True)
ap.add_argument("--primary", required=True, choices=["M1", "M2", "M3"])
ap.add_argument("--lstar", type=int, default=None)
ap.add_argument("--batch-size", type=int, default=250)
ap.add_argument("--session-budget-s", type=float, default=16500)
ap.add_argument("--cum-prev-s", type=float, default=0.0)
ap.add_argument("--cum-limit-s", type=float, default=9.5 * 3600)
ap.add_argument("--record-timeout-s", type=float, default=3600)
ap.add_argument("--max-batches", type=int, default=None, help="stop after this many batches (rehearsal session)")
ap.add_argument("--lean-bin", default=None, help="development only")
ap.add_argument("--qualified-literals", action="store_true", help="write DNt.A / AA.M instead of .A / .M")
ap.add_argument("--no-source-recheck", action="store_true", help="development only")
args = ap.parse_args()
BC, WORK, OUT = os.path.abspath(args.biocore), os.path.abspath(args.work), os.path.abspath(args.out)
os.makedirs(WORK, exist_ok=True)
os.makedirs(OUT, exist_ok=True)
LBL = args.label
G.QUALIFIED = bool(args.qualified_literals)
C.set_log(os.path.join(OUT, "gn_%s_log.txt" % LBL))
C.log("level-K session", LBL, "start; machine:", json.dumps(C.machine_info()))
STD = {"propext", "Quot.sound", "Classical.choice"}
LAKE = ["lake", "-f", "lakefile_gn.toml"]

s1 = args.s1
if s1 is None:
    c = glob.glob("/kaggle/input/**/gn_s1_classified.jsonl.gz", recursive=True)
    assert len(c) == 1, c
    s1 = os.path.dirname(c[0])
s1meta = json.load(open(os.path.join(s1, "gn_s1_meta.json")))
meta = {"label": LBL, "machine": C.machine_info(), "started_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "args": vars(args), "s1_dir": s1}

ok, lines = C.check_kernel_hashes(BC)
open(os.path.join(OUT, "gn_%s_kernel_check.txt" % LBL), "w").write("\n".join(lines) + "\n")
if not ok:
    raise SystemExit("frozen kernel files differ from KERNEL_SHA256.txt: stop")
if args.lean_bin:
    LEAN_BIN, lean_info = args.lean_bin, {"development_local_toolchain": True}
else:
    LEAN_BIN, lean_info = C.setup_lean(WORK, expected_sha256=s1meta["lean"]["sha256"])
meta["lean"] = lean_info
ENV = dict(os.environ, PATH=LEAN_BIN + ":" + os.environ["PATH"])
BLOG = os.path.join(OUT, "gn_%s_build_log.txt" % LBL)
rc, out, secs = C.run(["lake", "build"], BC, ENV, log_path=BLOG)
meta["kernel_build"] = {"exit": rc, "seconds": round(secs, 2)}
C.log("frozen kernel `lake build`: exit", rc, "%.1f s" % secs)
if rc != 0:
    raise SystemExit("the frozen kernel does not build: stop (no patch)")
rc, out, secs = C.run(LAKE + ["build", "+BioCore.Library.Genes.Pack"], BC, ENV, log_path=BLOG)
if rc != 0:
    raise SystemExit("Pack.lean does not build")

# sources: re-download and compare with session 1 (gn_choices.md section 2)
if not args.no_source_recheck:
    SRC = os.path.join(WORK, "src")
    os.makedirs(SRC, exist_ok=True)
    recheck = {}
    for name, info in s1meta["sources"].items():
        if name == "MANE_current_listing.html":
            continue
        got = C.download(info["url"], os.path.join(SRC, name))
        recheck[name] = {"sha256": got["sha256"], "same_as_session_1": got["sha256"] == info["sha256"]}
        if got["sha256"] != info["sha256"]:
            meta["source_recheck"] = recheck
            json.dump(meta, open(os.path.join(OUT, "gn_%s_meta.json" % LBL), "w"), indent=1)
            raise SystemExit("source %s changed since session 1 (sha256 %s, was %s): stop" % (name, got["sha256"], info["sha256"]))
    meta["source_recheck"] = recheck
    C.log("all sources identical to session 1")

records = [json.loads(l) for l in gzip.open(os.path.join(s1, "gn_s1_classified.jsonl.gz"), "rt", encoding="utf-8")]
for r in records:
    assert r["sha256_id"] == hashlib.sha256(r["id"].encode("utf-8")).hexdigest()
expr = [r for r in records if r["expressible"]]
first = sorted((r for r in expr if r["cls"] != "ACCEPTED_EQUAL"), key=lambda r: r["sha256_id"])
rest = sorted((r for r in expr if r["cls"] == "ACCEPTED_EQUAL"), key=lambda r: r["sha256_id"])
order = first + rest
assert len(order) == len(expr) and len(set(r["id"] for r in order)) == len(order)
for i, r in enumerate(order):
    r["k_order"] = i
C.log("records with a level-K statement:", len(order), "| not ACCEPTED_EQUAL first:", len(first), "| then:", len(rest))
meta["n_statements_total"] = len(order)
meta["n_first_part"] = len(first)

# earlier sessions
done = {}
prev_dirs = args.prev
if prev_dirs is None:
    prev_dirs = sorted(set(os.path.dirname(p) for p in glob.glob("/kaggle/input/**/gn_k*_batch_*.json", recursive=True)))
for d in prev_dirs:
    for p in sorted(glob.glob(os.path.join(d, "gn_k*_batch_*.json"))):
        for row in json.load(open(p))["rows"]:
            done[row["id"]] = row
C.log("earlier sessions:", prev_dirs, "records already finished:", len(done))
meta["prev_dirs"] = prev_dirs
meta["n_done_before"] = len(done)
todo = [r for r in order if r["id"] not in done]

GDIR = os.path.join(BC, "BioCore", "Library", "Genes")
RDIR = os.path.join(GDIR, "Rec")
BDIR = os.path.join(GDIR, "Batch")
os.makedirs(RDIR, exist_ok=True)
os.makedirs(BDIR, exist_ok=True)
LOGZ = gzip.open(os.path.join(OUT, "gn_%s_lake_logs.txt.gz" % LBL), "at", encoding="utf-8")


def lake_build(target, timeout):
    """One `lake build`; returns (rc, text, wall, timed_out)."""
    t = time.time()
    p = subprocess.Popen(LAKE + ["build", target], cwd=BC, env=ENV, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                         text=True, start_new_session=True)
    timed = {"v": False}

    def kill():
        timed["v"] = True
        try:
            os.killpg(p.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
    tm = threading.Timer(timeout, kill)
    tm.start()
    text = p.stdout.read()
    rc = p.wait()
    tm.cancel()
    wall = time.time() - t
    LOGZ.write("\n$ lake build %s  (exit %s, %.1f s, timed_out %s)\n%s\n" % (target, rc, wall, timed["v"], text))
    LOGZ.flush()
    return rc, text, wall, timed["v"]


def first_method(r):
    if args.lstar is not None and len(r["cds_stretch"]) >= args.lstar:
        return "M3"
    return args.primary


def write_module(r, method):
    src, thms = G.module_source(r, method, noncomputable=True)
    x = G.ident(r["id"])
    open(os.path.join(RDIR, x + ".lean"), "w", encoding="utf-8").write(src)
    return G.MOD_PREFIX + x, ["BioCore.Genes." + t for t in thms], len(src)


def judge(parsed, mod, thms):
    v = parsed.get(mod)
    if v is None:
        return False, None, "no build line for the module", {}
    ax = v["axioms"]
    msg = ""
    good = v["mark"] in ("\u2714", "\u2139") and v["action"] in ("Built", "Replayed")
    if not good:
        msg = "lake: %s %s | %s" % (v["mark"], v["action"], " ".join(v["messages"])[:1500])
    elif set(ax) != set(thms):
        good, msg = False, "axioms lines for %r, expected %r" % (sorted(ax), thms)
    elif not all(set(a) <= STD for a in ax.values()):
        good, msg = False, "axioms outside the standard three: %r" % ax
    return good, v["seconds"], msg, ax


def run_batch(bi, recs):
    name = "%s_B%05d" % (LBL, bi)
    info = {}
    for r in recs:
        m = first_method(r)
        mod, thms, nbytes = write_module(r, m)
        info[r["id"]] = {"id": r["id"], "k_order": r["k_order"], "batch": name, "module": mod, "theorems": thms,
                         "cls": r["cls"], "cds_len": len(r["cds_stretch"]), "attempts": [], "method": m, "source_bytes": nbytes}
    root_path = os.path.join(BDIR, name + ".lean")
    open(root_path, "w").write(G.batch_root_source([info[r["id"]]["module"] for r in recs]))
    target = "+BioCore.Library.Genes.Batch." + name
    rc, text, wall, timed = lake_build(target, args.record_timeout_s + 1800)
    parsed = G.parse_lake_log(text)
    failed = []
    for r in recs:
        d = info[r["id"]]
        good, secs, msg, ax = judge(parsed, d["module"], d["theorems"])
        if timed and not good:
            msg = "batch build was cut at the time limit; " + msg
        d["attempts"].append({"method": d["method"], "ok": good, "seconds": secs, "message": msg, "in_batch": True})
        if good:
            d.update({"status": "OK", "seconds": secs, "axioms": ax})
        else:
            failed.append(r)
    for r in failed:
        d = info[r["id"]]
        tried = d["method"]
        seq = ([tried] if timed else []) + [m for m in ("M2", "M3") if m != tried]
        d["status"] = "FAILED"
        for m in seq:
            mod, thms, nbytes = write_module(r, m)
            rc1, text1, wall1, timed1 = lake_build("+" + mod, args.record_timeout_s)
            good, secs, msg, ax = judge(G.parse_lake_log(text1), mod, thms)
            if timed1:
                msg = "time limit of %.0f s reached; %s" % (args.record_timeout_s, msg)
            d["attempts"].append({"method": m, "ok": good, "seconds": secs if secs is not None else round(wall1, 1), "message": msg, "in_batch": False})
            if good:
                d.update({"status": "OK", "seconds": secs, "axioms": ax, "method": m, "theorems": thms, "source_bytes": nbytes})
                break
        if d["status"] == "FAILED":
            d.update({"seconds": None, "axioms": {}})
            C.log("FAILED", r["id"], [a["message"][:300] for a in d["attempts"]])
    okmods = [info[r["id"]]["module"] for r in recs if info[r["id"]]["status"] == "OK"]
    root_ok = True
    if failed or rc != 0:
        open(root_path, "w").write(G.batch_root_source(okmods))
        rc2, text2, wall2, timed2 = lake_build(target, 3600)
        root_ok = (rc2 == 0)
        wall += wall2
    rows = [info[r["id"]] for r in recs]
    res = {"batch": name, "label": LBL, "n": len(rows), "n_ok": sum(1 for x in rows if x["status"] == "OK"),
           "n_failed": sum(1 for x in rows if x["status"] == "FAILED"), "wall_seconds": round(wall, 2),
           "batch_root_built": root_ok, "rows": rows}
    tmp = os.path.join(OUT, "gn_%s_batch_%05d.json.tmp" % (LBL, bi))
    json.dump(res, open(tmp, "w"))
    os.replace(tmp, os.path.join(OUT, "gn_%s_batch_%05d.json" % (LBL, bi)))
    return res


B = args.batch_size
batches = [todo[i:i + B] for i in range(0, len(todo), B)]
C.log("to do in this and later sessions:", len(todo), "records in", len(batches), "batches of", B)
session_rows = []
last = 0.0
stopped = None
t_k0 = time.time()
for bi, recs in enumerate(batches):
    elapsed = time.time() - C.T0
    if args.max_batches is not None and bi >= args.max_batches:
        stopped = "development limit"
        break
    if elapsed + 1.5 * last > args.session_budget_s:
        stopped = "session budget"
        break
    if args.cum_prev_s + elapsed > args.cum_limit_s:
        stopped = "cumulative level-K budget"
        break
    res = run_batch(bi, recs)
    last = res["wall_seconds"]
    session_rows += res["rows"]
    free_gb = shutil.disk_usage(BC).free / 1e9
    C.log("batch", res["batch"], "n", res["n"], "ok", res["n_ok"], "failed", res["n_failed"], "wall %.1f s" % res["wall_seconds"],
          "root built", res["batch_root_built"], "| done %d/%d" % (len(done) + len(session_rows), len(order)), "| free disk %.1f GB" % free_gb)
    if free_gb < 4:
        stopped = "disk"
        break
k_time = time.time() - t_k0
meta["stopped_because"] = stopped or "all records done"
meta["n_done_in_session"] = len(session_rows)
meta["n_ok_in_session"] = sum(1 for x in session_rows if x["status"] == "OK")
meta["n_failed_in_session"] = sum(1 for x in session_rows if x["status"] == "FAILED")
meta["batch_loop_seconds"] = round(k_time, 1)
C.log("batch loop finished:", meta["stopped_because"], "| in session:", len(session_rows), "ok", meta["n_ok_in_session"], "failed", meta["n_failed_in_session"])
json.dump(meta, open(os.path.join(OUT, "gn_%s_meta.json" % LBL), "w"), indent=1)

all_done = dict(done)
for x in session_rows:
    all_done[x["id"]] = x
complete = (len(all_done) == len(order))
meta["complete_after_session"] = complete

# ---- negative controls: false statements that the kernel must refuse (not part of the library)
NEG = os.path.join(BC, "neg_controls")
os.makedirs(NEG, exist_ok=True)
neg_rows = []
neg_eq = rest[:3]
neg_rej = [r for r in first if r["cls"] == "REJECTED" and set(r["translation"]) <= set(G.AAORD)][:3]
for kind, rs in (("wrong last residue claimed for an ACCEPTED_EQUAL record", neg_eq),
                 ("REJECTED record claimed to decode to the annotated protein", neg_rej)):
    for r in rs:
        r2 = dict(r)
        if r["cls"] == "ACCEPTED_EQUAL":
            t = r["translation"]
            r2["translation"] = t[:-1] + ("A" if t[-1] != "A" else "G")
        else:
            r2["cls"] = "ACCEPTED_EQUAL"
        src, thms = G.module_source(r2, args.primary, noncomputable=True)
        path = os.path.join(NEG, G.ident(r["id"]) + ".lean")
        open(path, "w", encoding="utf-8").write(src.replace("GENERATED by", "NEGATIVE CONTROL (a false statement, must be refused). GENERATED by"))
        rc, out, secs = C.run(LAKE + ["env", "lean", "-s", "8000000", os.path.relpath(path, BC)], BC, ENV)
        neg_rows.append({"id": r["id"], "kind": kind, "exit": rc, "refused": rc != 0, "proved_false": "is false" in out,
                         "seconds": round(secs, 2), "message": out[:600]})
json.dump(neg_rows, open(os.path.join(OUT, "gn_%s_neg_controls.json" % LBL), "w"), indent=1)
meta["neg_controls"] = {"n": len(neg_rows), "refused": sum(1 for x in neg_rows if x["refused"])}
C.log("negative controls refused:", meta["neg_controls"])

# ---- extra statements that need no kernel change: stop codon completed by 3' adenines (reported separately)
import gn_pydecode as PD
STOP_HEAD = """
/-!
# BioCore.Library.Genes.StopCompletion  (GENERATED by tools/gn_stage2.py; level K)

Records whose annotated coding stretch ends inside the stop codon (the flat file says the stop codon is
completed by the adenines added to the 3' end of the mRNA). The kernel rejects the stretch as annotated
(`notWholeCodons`, proved in the record's own module). Here the same stretch, transcribed and followed by
the stated number of adenines, is decoded by the unchanged kernel to the annotated protein.
No kernel change and no new definition is used: the statement is about a longer RNA.
-/
set_option maxRecDepth 100000000
set_option maxHeartbeats 0
namespace BioCore.Genes
open BioCore

"""
comp = [r for r in first if r["cls"] == "REJECTED" and r["x_reason"] == "notWholeCodons" and "incomplete_stop_codon" in r["explanation_categories"]
        and set(r["translation"]) <= set(G.AAORD)]
comp_rows = []
if comp:
    gc_path = os.path.join(BC, "sources", "ncbi_gc.prt")
    tabs = {"std": PD.read_gc_prt(gc_path, 1), "mito": PD.read_gc_prt(gc_path, 2)}
    imports = ["import BioCore"]
    body = []
    for r in comp:
        x = G.ident(r["id"])
        n = len(r["cds_stretch"])
        k = (3 - n % 3) % 3
        coding = r["cds_stretch"] if r["strand"] == "+" else "".join(PD.COMP[c] for c in reversed(r["cds_stretch"]))
        v = PD.decode(tabs[r["code"]], coding + "A" * k, "+")
        py_equal = (v[0] == "ok" and v[3] == r["translation"])
        row = {"id": r["id"], "gene": r["gene"], "group": r["group"], "cds_len": n, "adenines_added": k,
               "python_completed_equals_annotation": py_equal, "theorem": "BioCore.Genes.%s.completed" % x}
        comp_rows.append(row)
        if not py_equal:
            continue
        if not os.path.exists(os.path.join(RDIR, x + ".lean")):
            write_module(r, args.primary)
        imports.append("import %s%s" % (G.MOD_PREFIX, x))
        code = {"std": "standardCode", "mito": "vertMitoCode"}[r["code"]]
        tail = "[" + ", ".join(["RNt.A"] * k) + "]"
        body.append("/-- %s (%s): the annotated stretch has %d bases; with %d adenine%s added at the 3' end it decodes to the annotated protein. -/"
                    % (r["id"], r["gene"], n, k, "" if k == 1 else "s"))
        body.append("theorem %s.completed : decodeCDS %s (transcribe %s.cds ++ %s) = .ok %s.annotated := by decide +kernel" % (x, code, x, tail, x))
        body.append("#print axioms %s.completed" % x)
    src = "\n".join(imports) + STOP_HEAD + "\n".join(body) + "\n\nend BioCore.Genes\n"
    open(os.path.join(GDIR, "StopCompletion.lean"), "w", encoding="utf-8").write(src)
    rc, text, wall, timed = lake_build("+BioCore.Library.Genes.StopCompletion", 3600)
    parsed = G.parse_lake_log(text)
    v = parsed.get("BioCore.Library.Genes.StopCompletion", {})
    for row in comp_rows:
        row["built"] = (rc == 0)
        row["axioms"] = v.get("axioms", {}).get(row["theorem"])
    meta["stop_completion"] = {"exit": rc, "wall_seconds": round(wall, 2), "n": len(comp_rows), "tail": text[-800:] if rc != 0 else ""}
    C.log("StopCompletion.lean: exit", rc, "%.1f s" % wall, "records", len(comp_rows))
json.dump(comp_rows, open(os.path.join(OUT, "gn_%s_stop_completion.json" % LBL), "w"), indent=1)

# ---- hand-written file and its audit (if the file is present in this session's tree)
chain = os.path.join(GDIR, "Chain.lean")
if os.path.exists(chain):
    rc, text, wall, timed = lake_build("+BioCore.Library.Genes.Chain", 3600)
    meta["chain_build"] = {"exit": rc, "wall_seconds": round(wall, 2), "tail": text[-1500:]}
    C.log("hand-written Chain.lean: exit", rc, "%.1f s" % wall)
    aud = os.path.join(BC, "GenesAudit.lean")
    if rc == 0 and os.path.exists(aud):
        rc, out, secs = C.run(LAKE + ["env", "lean", "GenesAudit.lean"], BC, ENV)
        open(os.path.join(OUT, "gn_%s_audit_handwritten.txt" % LBL), "w").write(out)
        meta["chain_audit_exit"] = rc

# ---- declared axioms sample (gn_choices.md section 9), re-queried from the compiled modules of this session
acc = sorted((x for x in all_done.values() if x["status"] == "OK"),
             key=lambda x: hashlib.sha256(("gn-axioms-sample-v1|" + x["id"]).encode("utf-8")).hexdigest())
sample = acc[:200]
here = set(x["id"] for x in session_rows)
samp_here = [x for x in sample if x["id"] in here]
meta["axioms_sample_size"] = len(sample)
meta["axioms_sample_in_session"] = len(samp_here)
if samp_here:
    src = "".join("import %s\n" % x["module"] for x in samp_here) + "".join("#print axioms %s\n" % t for x in samp_here for t in x["theorems"])
    open(os.path.join(BC, "GenesAuditSample.lean"), "w").write(src)
    rc, out, secs = C.run(LAKE + ["env", "lean", "-s", "8000000", "GenesAuditSample.lean"], BC, ENV)
    open(os.path.join(OUT, "gn_%s_audit_sample.txt" % LBL), "w").write(out)
    json.dump([x["id"] for x in sample], open(os.path.join(OUT, "gn_%s_audit_sample_ids.json" % LBL), "w"))
    meta["axioms_sample_audit_exit"] = rc
    C.log("axioms sample audit: exit", rc, "records", len(samp_here), "%.1f s" % secs)

# ---- root file of the library; built as a whole only if every batch was built in this session
names = sorted(os.path.splitext(f)[0] for f in os.listdir(BDIR) if f.startswith(LBL + "_B"))
root_src = "import BioCore\nimport BioCore.Library.Genes.Pack\n" + ("import BioCore.Library.Genes.Chain\n" if os.path.exists(chain) else "") \
    + ("import BioCore.Library.Genes.StopCompletion\n" if os.path.exists(os.path.join(GDIR, "StopCompletion.lean")) else "") \
    + "".join("import BioCore.Library.Genes.Batch.%s\n" % n for n in names)
open(os.path.join(BC, "BioCoreLibraryGenes_%s.lean" % LBL), "w").write(root_src)
if complete and not done and not stopped:
    open(os.path.join(BC, "BioCoreLibraryGenes.lean"), "w").write(root_src)
    rc, text, wall, timed = lake_build("BioCoreLibraryGenes", 3600)
    meta["whole_library_root_build"] = {"exit": rc, "wall_seconds": round(wall, 2), "tail": text[-600:]}
    C.log("whole library root `lake build BioCoreLibraryGenes`: exit", rc, "%.1f s" % wall)
try:
    du = subprocess.check_output(["du", "-sm", os.path.join(BC, ".lake", "build")], text=True).split()[0]
    meta["build_dir_mb"] = int(du)
except Exception as e:
    meta["build_dir_mb"] = repr(e)

# ---- sources of this session
LOGZ.close()
tar = os.path.join(OUT, "gn_%s_lean_sources.tgz" % LBL)
members = ["BioCore/Library/Genes", "lakefile_gn.toml", "tools"] + [f for f in os.listdir(BC) if f.startswith("BioCoreLibraryGenes") or f.startswith("GenesAudit")]
subprocess.check_call(["tar", "-czf", tar, "-C", BC] + members)
meta["sources_tgz_bytes"] = os.path.getsize(tar)
meta["finished_utc"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
meta["session_seconds"] = round(time.time() - C.T0, 1)
meta["cum_level_k_session_seconds"] = round(args.cum_prev_s + (time.time() - C.T0), 1)
json.dump(meta, open(os.path.join(OUT, "gn_%s_meta.json" % LBL), "w"), indent=1)
C.log("session", LBL, "done;", json.dumps({k: meta[k] for k in ("stopped_because", "n_done_in_session", "n_ok_in_session", "n_failed_in_session", "session_seconds", "complete_after_session")}))
