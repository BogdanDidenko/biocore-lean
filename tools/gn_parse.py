#!/usr/bin/env python3
"""Gene library (track gn): parsing of GenBank flat files and of the MANE summary file.

Own minimal parser (no external package). Rules are those of gn_choices.md, sections 3, 4 and 6.
Nothing is filtered, truncated or skipped: every record read is returned.
"""
import gzip, re, io

SIMPLE = re.compile(r"^(\d+)\.\.(\d+)$")
COMPL = re.compile(r"^complement\((\d+)\.\.(\d+)\)$")
KERNEL_AA = set("ARNDCQEGHILKMFPSTWYVU")


def open_text(path):
    if str(path).endswith(".gz"):
        return io.TextIOWrapper(gzip.open(path, "rb"), encoding="utf-8", newline="")
    return open(path, encoding="utf-8", newline="")


def iter_raw_records(path):
    """Yield the lines of each flat-file record (terminated by a line `//`)."""
    cur = []
    with open_text(path) as fh:
        for line in fh:
            line = line.rstrip("\r\n")
            if line.startswith("//"):
                if cur:
                    yield cur
                cur = []
            else:
                cur.append(line)
    if any(l.strip() for l in cur):
        yield cur


def parse_features(lines):
    """Feature table lines -> list of (key, location string, [(qualifier, value-or-None)])."""
    feats = []
    cur = None
    for line in lines:
        if not line.strip():
            continue
        if line[:5] == "     " and len(line) > 5 and line[5] != " ":
            key = line[5:21].strip()
            cur = {"key": key, "loc_lines": [line[21:].strip()], "qual_lines": []}
            feats.append(cur)
        elif cur is not None:
            cur["qual_lines"].append(line[21:] if len(line) > 21 else line.strip())
    out = []
    for f in feats:
        ql = f["qual_lines"]
        i = 0
        loc = f["loc_lines"][0]
        while i < len(ql) and not ql[i].startswith("/"):
            loc += ql[i].strip()
            i += 1
        quals = []
        name, val, is_open = None, None, False
        for l in ql[i:]:
            if l.startswith("/") and not is_open:
                if name is not None:
                    quals.append((name, val))
                m = re.match(r"^/([A-Za-z_0-9]+)(=(.*))?$", l)
                if m is None:
                    raise ValueError("unparsed qualifier line: %r" % l)
                name = m.group(1)
                val = m.group(3)
                parts = [val] if val is not None else None
            else:
                if name is None:
                    raise ValueError("continuation line without qualifier: %r" % l)
                parts.append(l)
                val = None
            if parts is not None:
                joined = ("" if name == "translation" else " ").join(p.strip() if name == "translation" else p.rstrip() for p in parts)
                val = joined
                is_open = val.startswith('"') and not (len(val) >= 2 and val.endswith('"') and val.count('"') % 2 == 0)
            else:
                is_open = False
            cur_parts = parts
        if name is not None:
            quals.append((name, val))
        clean = []
        for n, v in quals:
            if v is not None and len(v) >= 2 and v.startswith('"') and v.endswith('"'):
                v = v[1:-1].replace('""', '"')
            clean.append((n, v))
        out.append((f["key"], loc, clean))
    return out


def parse_record(lines):
    """One flat-file record -> dict with version, sequence, features, RefSeq attributes."""
    rec = {"locus": None, "version": None, "definition": "", "attributes": [], "features": [], "seq": ""}
    section = None
    feat_lines, comment_lines, origin = [], [], []
    for line in lines:
        if line and line[0] != " ":
            key = line[:12].strip()
            section = key
            if key == "LOCUS":
                rec["locus"] = line
            elif key == "VERSION":
                rec["version"] = line[12:].split()[0]
            elif key == "DEFINITION":
                rec["definition"] = line[12:].strip()
            elif key == "COMMENT":
                comment_lines.append(line[12:])
            continue
        if section == "FEATURES":
            feat_lines.append(line)
        elif section == "COMMENT":
            comment_lines.append(line[12:] if len(line) > 12 else "")
        elif section == "ORIGIN":
            origin.append(line)
        elif section == "DEFINITION":
            rec["definition"] += " " + line.strip()
    seq = "".join("".join(ch for ch in l if ch.isalpha()) for l in origin)
    rec["seq"] = seq
    m = re.match(r"^LOCUS\s+(\S+)\s+(\d+)\s+bp", rec["locus"] or "")
    rec["locus_len"] = int(m.group(2)) if m else None
    # RefSeq attributes block
    inside = False
    attrs = []
    for l in comment_lines:
        s = l.strip()
        if s == "##RefSeq-Attributes-START##":
            inside = True
            continue
        if s == "##RefSeq-Attributes-END##":
            inside = False
            continue
        if inside:
            if "::" in s:
                attrs.append(re.sub(r"\s+", " ", s))
            elif attrs:
                attrs[-1] += " " + s
            else:
                attrs.append(s)
    rec["attributes"] = attrs
    rec["features"] = parse_features(feat_lines)
    return rec


def location_parts(loc):
    """All INT..INT or INT pieces of a location string, for the informational annotated length."""
    n = 0
    for a, b in re.findall(r"(\d+)\.\.[<>]?(\d+)", loc):
        n += int(b) - int(a) + 1
    return n


def explanation(quals, loc, attrs):
    """Section 6 of gn_choices.md: verbatim quotes and rule-based categories."""
    q = {}
    for name in ("transl_except", "exception", "ribosomal_slippage", "note", "artificial_location", "pseudo"):
        vals = [("" if v is None else v) for n, v in quals if n == name]
        if vals:
            q[name] = vals
    cs = [v for n, v in quals if n == "codon_start"]
    if cs and cs[0] != "1":
        q["codon_start"] = cs
    q["location"] = [loc]
    if attrs:
        q["RefSeq-Attributes"] = list(attrs)
    cats = []
    te = q.get("transl_except", [])
    if any(re.search(r"aa:Sec\b", v) for v in te):
        cats.append("selenocysteine")
    if any(re.search(r"aa:TERM\b", v) for v in te):
        cats.append("incomplete_stop_codon")
    if any(not re.search(r"aa:(Sec|TERM)\b", v) for v in te):
        cats.append("other_transl_except")
    notes = q.get("note", [])
    exc = q.get("exception", [])
    places = notes + list(attrs)
    if any("non-aug" in t.lower() for t in places):
        cats.append("non_AUG_start")
    if "ribosomal_slippage" in q or any(("ribosomal slippage" in t.lower() or "ribosomal frameshift" in t.lower()) for t in places):
        cats.append("ribosomal_slippage")
    sentences = []
    for t in notes:
        sentences += t.split(";")
    sentences += exc + list(attrs)
    for s in sentences:
        sl = s.lower()
        if "readthrough" in sl and any(k in sl for k in ("stop codon", "translational", "uga", "uag", "uaa")):
            cats.append("stop_codon_readthrough")
            break
    if any("rna editing" in t.lower() for t in exc + places):
        cats.append("RNA_editing")
    for v in exc:
        vl = v.lower()
        covered = ("rna editing" in vl) or ("ribosomal slippage" in vl) or ("readthrough" in vl and any(k in vl for k in ("stop codon", "translational", "uga", "uag", "uaa")))
        if not covered:
            cats.append("other")
            break
    if not cats:
        cats.append("none_given")
    return cats, q


def cds_record(rec, feat, genome):
    """Apply the expressibility grammar (section 4) to one CDS feature of a parsed record."""
    key, loc, quals = feat
    d = {"cds_location_raw": loc, "codon_start": None, "translation": None, "protein_id": None,
         "gene_in_flatfile": None, "product": None, "cds_start": None, "cds_end": None, "strand": "+",
         "cds_stretch": "", "ne_reasons": [], "transl_table": None}
    for n, v in quals:
        if n == "codon_start" and d["codon_start"] is None:
            d["codon_start"] = v
        elif n == "translation" and d["translation"] is None:
            d["translation"] = v
        elif n == "protein_id" and d["protein_id"] is None:
            d["protein_id"] = v
        elif n == "gene" and d["gene_in_flatfile"] is None:
            d["gene_in_flatfile"] = v
        elif n == "product" and d["product"] is None:
            d["product"] = v
        elif n == "transl_table" and d["transl_table"] is None:
            d["transl_table"] = v
    reasons = []
    m = SIMPLE.match(loc)
    mc = COMPL.match(loc) if genome else None
    if m or mc:
        a, b = (int(x) for x in (m or mc).groups())
        d["cds_start"], d["cds_end"] = a, b
        d["strand"] = "+" if m else "-"
        if not (1 <= a <= b <= len(rec["seq"])):
            reasons.append("LOCATION_OTHER")
    elif "join(" in loc or "order(" in loc:
        reasons.append("LOCATION_JOIN")
    elif "<" in loc or ">" in loc:
        reasons.append("LOCATION_PARTIAL")
    else:
        reasons.append("LOCATION_OTHER")
    if ("<" in loc or ">" in loc) and "LOCATION_PARTIAL" not in reasons:
        reasons.append("LOCATION_PARTIAL")
    if d["codon_start"] not in (None, "1"):
        reasons.append("CODON_START_%s" % d["codon_start"])
    stretch = ""
    bad = []
    if d["cds_start"] is not None and "LOCATION_OTHER" not in reasons:
        stretch = rec["seq"][d["cds_start"] - 1:d["cds_end"]].upper()
        bad = [(i + 1, ch) for i, ch in enumerate(stretch) if ch not in "ACGT"]
        if bad:
            reasons.append("NON_ACGT")
    if d["translation"] is None:
        reasons.append("NO_TRANSLATION")
    d["non_acgt"] = bad
    d["cds_stretch"] = stretch
    d["annotated_len"] = location_parts(loc) if d["cds_start"] is None else d["cds_end"] - d["cds_start"] + 1
    d["ne_reasons"] = reasons
    cats, quotes = explanation(quals, loc, rec["attributes"])
    d["explanation_categories"] = cats
    d["explanation_quotes"] = quotes
    return d


def read_summary(path):
    rows = []
    with open_text(path) as fh:
        header = None
        for line in fh:
            line = line.rstrip("\r\n")
            if not line:
                continue
            f = line.split("\t")
            if header is None:
                header = [h.lstrip("#") for h in f]
                continue
            if len(f) != len(header):
                raise ValueError("summary row with %d fields, header has %d: %r" % (len(f), len(header), line))
            rows.append(dict(zip(header, f)))
    return header, rows
