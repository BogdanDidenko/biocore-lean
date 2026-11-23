#!/usr/bin/env python3
"""Paste the sequence literals of the three named genes into the hand-written Chain.lean.

usage: gn_fill_chain.py <gn_s1_classified.jsonl.gz> <Chain.lean.template> <Chain.lean> <MANE version>
Only the literals come from here; the statements and proofs are in the template.
"""
import gzip, json, sys

src, template, dest, mane = sys.argv[1:5]
recs = [json.loads(l) for l in gzip.open(src, "rt", encoding="utf-8")]
text = open(template, encoding="utf-8").read().replace("@MANE_VERSION@", mane)
for sym in ("INS", "TP53", "BRCA1"):
    hits = [r for r in recs if r["group"] == "SELECT" and r["gene"] == sym]
    assert len(hits) == 1, (sym, len(hits))
    r = hits[0]
    assert r["expressible"] and r["strand"] == "+", (sym, r["ne_reasons"])
    if r["cls"] != "ACCEPTED_EQUAL":
        raise SystemExit("%s is %s at level X: the template's statement `.ok protein` does not apply; edit by hand" % (sym, r["cls"]))
    dna = r["cds_stretch"]
    assert set(dna) <= set("ACGT")
    rna = dna.replace("T", "U")
    prot = r["translation"]
    lit = lambda s: "[" + ", ".join("." + ch for ch in s) + "]"
    for key, val in (("ID", r["id"]), ("LOC", r["cds_location_raw"]), ("NT", str(len(dna))), ("AA", str(len(prot))),
                     ("DNA", lit(dna)), ("RNA", lit(rna)), ("PROT", lit(prot))):
        text = text.replace("@%s_%s@" % (sym, key), val)
assert "@" not in text.replace("@[", ""), "unfilled placeholder"
open(dest, "w", encoding="utf-8").write(text)
print("written", dest)
