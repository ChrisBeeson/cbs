#!/usr/bin/env python3
"""
CBS Spec Validator - validates cell specifications and bus communication patterns.
Focuses on ensuring proper bus usage rather than strict isolation guards.
"""
import os, re, sys

REQUIRED = ["id","name","version","language","category","purpose"]

def parse_dna(md_path):
    data = {"interface": {"subjects": {"subscribe": [], "publish": []}}}
    with open(md_path, 'r', encoding='utf-8') as f:
        for line in f:
            m = re.match(r"\*\*(.+?)\*\*:\s*(.+)\s*$", line)
            if m:
                key = m.group(1).strip().lower()
                val = m.group(2).strip()
                if key in REQUIRED:
                    data[key] = val
            if re.search(r"^-\s*subscribe:\s*(.+)$", line):
                subj = re.sub(r"^-\s*subscribe:\s*", "", line).strip()
                data["interface"]["subjects"]["subscribe"].append(subj)
            if re.search(r"^-\s*publish:\s*(.+)$", line):
                subj = re.sub(r"^-\s*publish:\s*", "", line).strip()
                data["interface"]["subjects"]["publish"].append(subj)
            if re.search(r"^-\s*envelope:\s*(.+)$", line):
                env = re.sub(r"^-\s*envelope:\s*", "", line).strip()
                data["interface"]["envelope"] = env
    return data

def validate(d):
    missing = [k for k in REQUIRED if not d.get(k)]
    errors = []
    if missing:
        errors.append(f"missing: {', '.join(missing)}")
    
    # Bus communication validation
    subjects = d.get("interface",{}).get("subjects",{})
    all_subjects = subjects.get("subscribe",[]) + subjects.get("publish",[])
    
    for subj in all_subjects:
        if not subj.startswith("cbs."):
            errors.append(f"bad subject (must start with 'cbs.'): {subj}")
    
    # Ensure cells have proper bus interface
    if not all_subjects:
        errors.append("no bus subjects defined - cells must communicate via bus")
    
    return errors


def main():
    root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    dna_files = []
    for base in ("applications", "shared_cells"):
        base_path = os.path.join(root, base)
        if not os.path.isdir(base_path):
            continue
        for dirpath, _, filenames in os.walk(base_path):
            if os.path.basename(dirpath) == "ai":
                if "spec.md" in filenames:
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
