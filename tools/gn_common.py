#!/usr/bin/env python3
"""Gene library (track gn): shared helpers for the Kaggle sessions (download, hashes, Lean setup)."""
import hashlib, json, os, shutil, subprocess, sys, time, urllib.request, platform

LEAN_URL = "https://github.com/leanprover/lean4/releases/download/v4.36.0/lean-4.36.0-linux.tar.zst"
MANE_DIR = "https://ftp.ncbi.nlm.nih.gov/refseq/MANE/MANE_human/current/"
MITO_URL = ("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NC_012920.1"
            "&rettype=gbwithparts&retmode=text")
GC_URL = "https://ftp.ncbi.nlm.nih.gov/entrez/misc/data/gc.prt"

T0 = time.time()
_LOG = None


def set_log(path):
    global _LOG
    _LOG = open(path, "a", encoding="utf-8")


def log(*a):
    msg = "[%8.1fs] " % (time.time() - T0) + " ".join(str(x) for x in a)
    print(msg, flush=True)
    if _LOG:
        _LOG.write(msg + "\n")
        _LOG.flush()


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for blk in iter(lambda: fh.read(1 << 20), b""):
            h.update(blk)
    return h.hexdigest()


def download(url, dest, tries=6):
    """Download inside the session; returns dict(url, sha256, bytes, last_modified)."""
    last = None
    for k in range(tries):
        try:
            req = urllib.request.Request(url)
            with urllib.request.urlopen(req, timeout=300) as r, open(dest + ".part", "wb") as out:
                lm = r.headers.get("Last-Modified")
                shutil.copyfileobj(r, out, 1 << 20)
            os.replace(dest + ".part", dest)
            info = {"url": url, "file": os.path.basename(dest), "sha256": sha256_file(dest),
                    "bytes": os.path.getsize(dest), "last_modified": lm,
                    "downloaded_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())}
            log("downloaded", url, info["bytes"], "bytes sha256", info["sha256"])
            return info
        except Exception as e:  # network errors are retried inside the session
            last = e
            log("download failed (try %d): %s: %r" % (k + 1, url, e))
            time.sleep(10 * (k + 1))
    raise RuntimeError("could not download %s: %r" % (url, last))


def machine_info():
    info = {"platform": platform.platform(), "python": sys.version.split()[0], "nproc": os.cpu_count()}
    try:
        models = [l.split(":", 1)[1].strip() for l in open("/proc/cpuinfo") if l.startswith("model name")]
        info["cpu_model"] = sorted(set(models))
        info["cpu_logical"] = len(models)
        for l in open("/proc/meminfo"):
            if l.startswith("MemTotal"):
                info["mem_total_kb"] = int(l.split()[1])
    except Exception as e:
        info["cpuinfo_error"] = repr(e)
    return info


def setup_lean(work, expected_sha256=None):
    """Download the Lean release inside the session, verify, unpack; returns (bin dir, info)."""
    os.makedirs(work, exist_ok=True)
    tar = os.path.join(work, "lean-4.36.0-linux.tar.zst")
    info = download(LEAN_URL, tar)
    if expected_sha256 and info["sha256"] != expected_sha256:
        raise RuntimeError("Lean archive sha256 %s differs from the first session's %s" % (info["sha256"], expected_sha256))
    dest = os.path.join(work, "lean")
    os.makedirs(dest, exist_ok=True)
    if shutil.which("zstd"):
        subprocess.check_call(["tar", "--zstd", "-xf", tar, "-C", dest])
        info["unpacked_with"] = "tar --zstd"
    else:
        try:
            import zstandard
        except ImportError:
            subprocess.check_call([sys.executable, "-m", "pip", "install", "-q", "zstandard"])
            import zstandard
        import tarfile
        with open(tar, "rb") as fh:
            with zstandard.ZstdDecompressor().stream_reader(fh) as zr:
                with tarfile.open(fileobj=zr, mode="r|") as tf:
                    tf.extractall(dest)
        info["unpacked_with"] = "python zstandard"
    bins = [os.path.join(dest, d, "bin") for d in os.listdir(dest) if os.path.isdir(os.path.join(dest, d, "bin"))]
    assert len(bins) == 1, bins
    env = dict(os.environ, PATH=bins[0] + ":" + os.environ["PATH"])
    info["lean_version"] = subprocess.check_output(["lean", "--version"], env=env, text=True).strip()
    info["lake_version"] = subprocess.check_output(["lake", "--version"], env=env, text=True).strip()
    log("lean:", info["lean_version"])
    return bins[0], info


def check_kernel_hashes(biocore):
    """Re-check KERNEL_SHA256.txt; returns (all_ok, lines)."""
    lines, ok = [], True
    for l in open(os.path.join(biocore, "KERNEL_SHA256.txt")):
        l = l.strip()
        if not l:
            continue
        h, name = l.split(None, 1)
        got = sha256_file(os.path.join(biocore, name))
        good = (got == h)
        ok = ok and good
        lines.append("%s  %s  %s" % ("OK " if good else "BAD", name, got))
    return ok, lines


def run(cmd, cwd, env, timeout=None, log_path=None):
    t = time.time()
    p = subprocess.run(cmd, cwd=cwd, env=env, capture_output=True, text=True, timeout=timeout)
    out = p.stdout + p.stderr
    if log_path:
        with open(log_path, "a", encoding="utf-8") as fh:
            fh.write("$ %s\n(exit %d, %.1f s)\n%s\n" % (" ".join(cmd), p.returncode, time.time() - t, out))
    return p.returncode, out, time.time() - t


def run_limited(cmd, cwd, env, timeout):
    """Run one process; returns dict(rc, seconds, maxrss_kb, user_s, sys_s, out, timed_out)."""
    import threading, signal
    t = time.time()
    p = subprocess.Popen(cmd, cwd=cwd, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True,
                         start_new_session=True)
    timed = {"v": False}

    def kill():
        timed["v"] = True
        try:
            os.killpg(p.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
    timer = threading.Timer(timeout, kill)
    timer.start()
    out = p.stdout.read()
    _, status, ru = os.wait4(p.pid, 0)
    timer.cancel()
    rc = os.waitstatus_to_exitcode(status)
    p.returncode = rc
    return {"rc": rc, "seconds": round(time.time() - t, 3), "maxrss_kb": ru.ru_maxrss, "user_s": round(ru.ru_utime, 3),
            "sys_s": round(ru.ru_stime, 3), "out": out, "timed_out": timed["v"]}
