#!/usr/bin/env python3
"""
CBS Spec Validator - validates cell specifications and bus communication patterns.
Focuses on ensuring proper bus usage rather than strict isolation guards.
"""
import os, re, sys

REQUIRED = ["id","name","version","language","category","purpose"]

def _strip_md_value(s: str) -> str:
    # remove wrapping backticks and bold markers
    s = s.strip()
    if s.startswith("`") and s.endswith("`") and len(s) >= 2:
        s = s[1:-1]
    return s.strip()


def parse_dna(md_path):
    data = {"interface": {"subjects": {"subscribe": [], "publish": []}}}
    bold_kv = re.compile(r"^\s*-?\s*\*\*(.+?)\*\*:\s*(.+?)\s*$", re.IGNORECASE)
    subscribe_re = re.compile(r"^\s*-\s*(?:\*\*)?subscribe(?:\*\*)?\s*:\s*`?(.+?)`?\s*$", re.IGNORECASE)
    publish_re = re.compile(r"^\s*-\s*(?:\*\*)?publish(?:\*\*)?\s*:\s*`?(.+?)`?\s*$", re.IGNORECASE)
    envelope_re = re.compile(r"^\s*-\s*(?:\*\*)?envelope(?:\*\*)?\s*:\s*(.+?)\s*$", re.IGNORECASE)

    with open(md_path, 'r', encoding='utf-8') as f:
        for raw in f:
            line = raw.rstrip("\n")
            m = bold_kv.match(line)
            if m:
                key = m.group(1).strip().lower()
                val = _strip_md_value(m.group(2))
                if key in REQUIRED:
                    data[key] = val
                continue

            m = subscribe_re.match(line)
            if m:
                data["interface"]["subjects"]["subscribe"].append(_strip_md_value(m.group(1)))
                continue

            m = publish_re.match(line)
            if m:
                data["interface"]["subjects"]["publish"].append(_strip_md_value(m.group(1)))
                continue

            m = envelope_re.match(line)
            if m:
                data["interface"]["envelope"] = _strip_md_value(m.group(1))
                continue

    return data

def validate(d):
    errors = []
    missing = [k for k in REQUIRED if not d.get(k)]
    if missing:
        errors.append(f"missing: {', '.join(missing)}")

    subjects = d.get("interface", {}).get("subjects", {})
    all_subjects = subjects.get("subscribe", []) + subjects.get("publish", [])

    # strict subject regex: cbs.{service}.{verb} (snake_case); allow * and {verb}; special-case cbs.>
    subject_re = re.compile(r"^(cbs\.[a-z0-9_]+\.[a-z0-9_\*\{\}]+(\..*)?|cbs\.>)$")
    for subj in all_subjects:
        s = subj.strip()
        if not s:
            continue
        if not s.startswith("cbs."):
            errors.append(f"bad subject (must start with 'cbs.'): {s}")
            continue
        if not subject_re.match(s):
            errors.append(f"invalid subject format (use cbs.service.verb snake_case): {s}")

    if not all_subjects:
        errors.append("no bus subjects defined - cells must communicate via bus")

    return errors


def main():
    root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    dna_files = []
    bases = [
        os.path.join(root, "applications"),
        os.path.join(root, "examples", "applications"),
        os.path.join(root, "shared_cells"),
    ]
    for base_path in bases:
        if not os.path.isdir(base_path):
            continue
        for dirpath, _, filenames in os.walk(base_path):
            if os.path.basename(dirpath) == "ai" and "spec.md" in filenames:
                dna_files.append(os.path.join(dirpath, "spec.md"))

    if not dna_files:
        print("No spec.md files found.")
        return 0

    failed = 0
    for md in dna_files:
        d = parse_dna(md)
        errs = validate(d)
        if errs:
            failed += 1
            print(f"FAIL {md}")
            for e in errs:
                print(f"  - {e}")
        else:
            print(f"OK   {md}")
    return 1 if failed else 0

if __name__ == "__main__":
    sys.exit(main())
