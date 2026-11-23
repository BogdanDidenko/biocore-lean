#!/usr/bin/env python3
"""Independent re-implementation (level X) of the decoding rule, from the NCBI gc.prt tables.

It does not read any Lean file. Tables: rows `ncbieaa` and `sncbieaa` with the Base1/Base2/Base3
rows of gc.prt. Same result fields as the Lean program: verdict, reason, position, protein.
"""
import re


def read_gc_prt(path, table_id):
    text = open(path, encoding="utf-8").read()
    blocks = re.split(r"\n\s*\{", text)
    for b in blocks:
        if re.search(r"\bid\s+%d\s*," % table_id, b):
            aa = re.search(r'ncbieaa\s+"([^"]+)"', b).group(1)
            st = re.search(r'sncbieaa\s+"([^"]+)"', b).group(1)
            b1 = re.search(r"--\s*Base1\s+([TCAG]{64})", text).group(1)
            b2 = re.search(r"--\s*Base2\s+([TCAG]{64})", text).group(1)
            b3 = re.search(r"--\s*Base3\s+([TCAG]{64})", text).group(1)
            assert len(aa) == 64 and len(st) == 64
            names = re.findall(r'name\s+"([^"]+)"', b)
            code = {}
            starts = set()
            for i in range(64):
                codon = b1[i] + b2[i] + b3[i]
                code[codon] = aa[i]
                if st[i] == "M":
                    starts.add(codon)
            assert len(code) == 64
            return {"aa": code, "starts": starts, "names": names, "ncbieaa": aa, "sncbieaa": st}
    raise KeyError(table_id)


COMP = {"A": "T", "C": "G", "G": "C", "T": "A"}


def decode(table, stretch, strand="+"):
    """Return (verdict, reason, position, protein). `stretch` is DNA, letters A C G T."""
    s = stretch
    if strand == "-":
        s = "".join(COMP[ch] for ch in reversed(s))
    n = len(s)
    if n % 3 != 0:
        return ("rejected", "notWholeCodons", "", "")
    if n == 0:
        return ("rejected", "empty", "", "")
    ncod = n // 3
    if s[0:3] not in table["starts"]:
        return ("rejected", "badStart", "", "")
    prot = ["M"]
    k = 1
    while k < ncod:
        a = table["aa"][s[3 * k:3 * k + 3]]
        last = (k == ncod - 1)
        if a == "*":
            if last:
                return ("ok", "", "", "".join(prot))
            return ("rejected", "internalStop", str(k), "")
        if last:
            return ("rejected", "noStop", "", "")
        prot.append(a)
        k += 1
    return ("rejected", "noStop", "", "")
