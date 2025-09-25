#!/usr/bin/env python3
import argparse, os, re, sys, json

REQUIRED = ["id","language","category"]

def parse_spec(md_path):
    data = {"interface": {"subjects": {"subscribe": [], "publish": []}}}
    bkv = re.compile(r"^\s*-?\s*\*\*(.+?)\*\*:\s*(.+?)\s*$", re.IGNORECASE)
    sub_re = re.compile(r"^\s*-\s*(?:\*\*)?subscribe(?:\*\*)?\s*:\s*`?(.+?)`?\s*$", re.IGNORECASE)
    pub_re = re.compile(r"^\s*-\s*(?:\*\*)?publish(?:\*\*)?\s*:\s*`?(.+?)`?\s*$", re.IGNORECASE)
    with open(md_path, 'r', encoding='utf-8') as f:
        for ln in f:
            m = bkv.match(ln)
            if m:
                k = m.group(1).strip().lower(); v = m.group(2).strip().strip('`')
                data[k] = v; continue
            m = sub_re.match(ln)
            if m: data["interface"]["subjects"]["subscribe"].append(m.group(1).strip()); continue
            m = pub_re.match(ln)
            if m: data["interface"]["subjects"]["publish"].append(m.group(1).strip()); continue
    return data

def ensure_required(d):
    missing = [k for k in REQUIRED if not d.get(k)]
    if missing: raise SystemExit(f"Spec missing fields: {', '.join(missing)}")

def write_file(path, content, apply):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if apply and os.path.exists(path):
        os.replace(path, path+".bak")
    if apply:
        with open(path, 'w', encoding='utf-8') as f: f.write(content)
    return path

def gen_dart(cell_id, subjects):
    cls = ''.join([p.capitalize() for p in cell_id.split('_')]) + "Cell"
    subs = subjects or [f"cbs.{cell_id}.process"]
    handlers = '\n'.join([f"    await bus.subscribe('{s}', _handle);" for s in subs])
    return f"""import 'dart:async';\nimport 'package:cbs_sdk/cbs_sdk.dart';\n\nclass {cls} implements Cell {{\n  @override\n  String get id => '{cell_id}';\n\n  @override\n  List<String> get subjects => {json.dumps(subs)};\n\n  @override\n  Future<void> register(Bus bus) async {{\n{handlers}\n  }}\n\n  Future<Envelope> _handle(Envelope envelope) async {{\n    // TODO: implement from spec\n    return envelope.createResponse({{ 'ok': true }});\n  }}\n}}\n"""

def gen_rust(cell_id, subjects):
    struct = ''.join([p.capitalize() for p in cell_id.split('_')]) + "Cell"
    subs = subjects or [f"cbs.{cell_id}.process"]
    sub_lines = "\n        ".join([f"bus.subscribe(\"{s}\", Box::new(|env| {{ Box::pin(async move {{ Ok(env) }}) }})).await?;" for s in subs])
    return f"""use async_trait::async_trait;\nuse body_core::{{BodyBus, BusError, Cell, Envelope}};\n\npub struct {struct} {{ id: String }}\n\nimpl {struct} {{\n    pub fn new() -> Self {{ Self {{ id: \"{cell_id}\".into() }} }}\n}}\n\n#[async_trait]\nimpl Cell for {struct} {{\n    fn id(&self) -> &str {{ &self.id }}\n    fn subjects(&self) -> Vec<String> {{ vec![{', '.join([f'\"{s}\"' for s in subs])}] }}\n    async fn register(&self, bus: &dyn BodyBus) -> Result<(), BusError> {{\n        {sub_lines}\n        Ok(())\n    }}\n}}\n"""

def main():
    ap = argparse.ArgumentParser(description="Generate cell code from .cbs-spec/spec.md")
    ap.add_argument("spec", help="Path to .cbs-spec/spec.md or cell dir containing it")
    ap.add_argument("--apply", action="store_true", help="Write files (default dry-run)")
    args = ap.parse_args()

    spec_path = args.spec
    if os.path.isdir(spec_path): spec_path = os.path.join(spec_path, "ai", "spec.md")
    if not os.path.isfile(spec_path): raise SystemExit(f"Spec not found: {spec_path}")

    d = parse_spec(spec_path)
    ensure_required(d)
    cell_id = d["id"].strip()
    lang = d["language"].strip().lower()
    subs = d.get("interface",{}).get("subjects",{}).get("subscribe",[])

    cell_dir = os.path.abspath(os.path.join(os.path.dirname(spec_path), ".."))
    out = {}
    if lang == "dart":
        lib = os.path.join(cell_dir, "lib", f"{cell_id}_cell.dart")
        out[lib] = gen_dart(cell_id, subs)
    elif lang == "rust":
        lib = os.path.join(cell_dir, "lib", f"{cell_id}.rs")
        out[lib] = gen_rust(cell_id, subs)
    else:
        raise SystemExit(f"Unsupported language: {lang}")

    print("Planned outputs:")
    for p in out:
        print(f"  {p}")
    if not args.apply:
        print("(dry-run) use --apply to write files; existing files get .bak backups")
        return
    for p, content in out.items():
        write_file(p, content, True)
        print(f"wrote {p}")

if __name__ == "__main__":
    main()


