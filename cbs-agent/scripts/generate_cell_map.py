#!/usr/bin/env python3
"""
CBS Cell Map Generator - generates cell inventory and validates message contracts.
Ensures that published and subscribed subjects match across cells for consistent bus communication.
"""
import os, re, sys

def read_field(lines, key):
    for line in lines:
        if line.strip().lower().startswith(f"- **{key}**:"):
            return line.split(":", 1)[1].strip().strip("`").strip()
    return ""

def subjects(lines):
    subscribe, publish = [], []
    mode = None
    for line in lines:
        line = line.strip()
        if "subscribe" in line.lower() and ":" in line:
            mode = "subscribe"
            val = line.split(":", 1)[1].strip().strip("`").strip()
            if val: subscribe.append(val)
        elif "publish" in line.lower() and ":" in line:
            mode = "publish"
            val = line.split(":", 1)[1].strip().strip("`").strip()
            if val: publish.append(val)
        elif line.startswith("- ") and mode:
            val = line.strip("- ").strip().strip("`").strip()
            if val:
                if mode == "subscribe": subscribe.append(val)
                else: publish.append(val)
    return subscribe, publish

def write_app_map(app_root, app_name):
    cells = []
    cell_map_path = os.path.join(app_root, "ai", "cell_map.md")
    spec_files = []
    for dirpath, _, filenames in os.walk(os.path.join(app_root, "cells")):
        if os.path.basename(dirpath) == "ai" and "spec.md" in filenames:
            spec_files.append(os.path.join(dirpath, "spec.md"))
    
    if not spec_files:
        print(f"No cells found for {app_name}")
        return cells
    
    print(f"Found {len(spec_files)} cells in {app_name}")
    
    all_subscribe = {}
    all_publish = {}
    
    for spec_path in spec_files:
        with open(spec_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        cell_id = read_field(lines, "id")
        if not cell_id:
            cell_id = os.path.basename(os.path.dirname(os.path.dirname(spec_path)))
        
        name = read_field(lines, "name")
        category = read_field(lines, "category")
        purpose = read_field(lines, "purpose")
        subscribe, publish = subjects(lines)
        
        cells.append({
            "id": cell_id,
            "name": name,
            "category": category,
            "purpose": purpose,
            "subscribe": subscribe,
            "publish": publish,
            "path": os.path.relpath(os.path.dirname(spec_path), app_root)
        })
        
        for s in subscribe:
            all_subscribe.setdefault(s, []).append(cell_id)
        for p in publish:
            all_publish.setdefault(p, []).append(cell_id)
    
    # Validate message contracts
    errors = 0
    print("\n🔍 Validating message contracts for", app_name)
    for subj in all_publish:
        if subj not in all_subscribe and not subj.endswith('*') and '>' not in subj:
            publishers = ', '.join(all_publish[subj])
            print(f"  ⚠️  Subject '{subj}' published by {publishers} but no subscribers found")
            errors += 1
    for subj in all_subscribe:
        if subj not in all_publish and not subj.endswith('*') and '>' not in subj:
            subscribers = ', '.join(all_subscribe[subj])
            print(f"  ⚠️  Subject '{subj}' subscribed by {subscribers} but no publishers found")
            errors += 1
    
    if errors == 0:
        print("  ✅ All message contracts validated: Publishers and subscribers match")
    else:
        print(f"  ❌ Found {errors} message contract issues")
    
    # Write cell map
    with open(cell_map_path, 'w', encoding='utf-8') as f:
        f.write(f"# Cell Map - {app_name}\n\n")
        f.write(f"## Overview\n")
        f.write(f"- **Total Cells**: {len(cells)}\n")
        f.write(f"- **Generated**: {os.popen('date -u +%Y-%m-%dT%H:%M:%SZ').read().strip()}\n")
        f.write("\n## Cell Inventory\n\n")
        for cell in sorted(cells, key=lambda x: x['id']):
            f.write(f"### {cell['id']} ({cell['category']})\n")
            if cell['name'] and cell['name'] != cell['id']:
                f.write(f"- **Name**: {cell['name']}\n")
            f.write(f"- **Purpose**: {cell['purpose'] or 'Not specified'}\n")
            f.write(f"- **Path**: `{cell['path']}`\n")
            if cell['subscribe']:
                f.write(f"- **Subscribes**: {', '.join('`'+s+'`' for s in cell['subscribe'])}\n")
            if cell['publish']:
                f.write(f"- **Publishes**: {', '.join('`'+p+'`' for p in cell['publish'])}\n")
            f.write("\n")
        
        f.write("## Message Flow Summary\n\n")
        f.write("### Published Subjects\n")
        for subj in sorted(all_publish.keys()):
            publishers = ', '.join(all_publish[subj])
            subscribers = ', '.join(all_subscribe.get(subj, ["None"]))
            f.write(f"- **`{subj}`**\n")
            f.write(f"  - **Publishers**: {publishers}\n")
            f.write(f"  - **Subscribers**: {subscribers}\n")
        f.write("\n")
    
    print(f"Generated cell map: {cell_map_path}")
    if errors > 0:
        print(f"❌ Validation failed with {errors} message contract errors")
        sys.exit(1)
    return cells

def main():
    root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    apps = []
    for base_path in [os.path.join(root, "applications"), os.path.join(root, "examples", "applications")]:
        if not os.path.isdir(base_path):
            continue
        for app_dir in os.listdir(base_path):
            app_path = os.path.join(base_path, app_dir)
            if os.path.isdir(app_path):
                apps.append((app_path, app_dir))
    
    all_cells = []
    for app_path, app_name in apps:
        cells = write_app_map(app_path, app_name)
        all_cells.extend(cells)
        print()
    
    print(f"Total cells mapped: {len(all_cells)}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
