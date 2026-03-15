import os, sys, json

p = os.path.dirname(os.path.abspath(__file__))
while p != os.path.dirname(p) and not os.path.exists(os.path.join(p, "common")):
    p = os.path.dirname(p)
sys.path.insert(0, os.path.join(p, "common"))
from dump_utils import write_dump_file, get_api_response

def _tag_key(t):
    """Sort key for mixed tag lists: strings first, then dicts by JSON"""
    if isinstance(t, str): return (0, t, "")
    if isinstance(t, dict): return (1, "", json.dumps(t, sort_keys=True))
    return (2, str(t), "")

def normalize_tags(t):
    if not isinstance(t, list): return []
    return sorted(t, key=_tag_key)

def get_tags(data):
    tags = {}
    for c in data["Classes"]:
        cn = c.get("Name")
        if not cn: continue
        ct = c.get("Tags", [])
        tags[cn] = {"cmp": normalize_tags(ct), "raw": ct}
        for m in c.get("Members", []):
            mn, mt = m.get("Name"), m.get("MemberType")
            if mt in ("Property", "Function", "Event", "Callback"):
                key = f"{cn}.{mn}"
                t = m.get("Tags", [])
                tags[key] = {"cmp": normalize_tags(t), "type": mt, "raw": t}
    return tags

def compare(vh=None):
    r1, h1 = get_api_response(vh, api_version="v1")
    r2, h2 = get_api_response(vh, api_version="v2")
    t1, t2 = get_tags(r1.json()), get_tags(r2.json())
    keys = sorted(set(t1.keys()) | set(t2.keys()))
    out = f"Version v1: {h1}\nVersion v2: {h2}\n" + "=" * 80 + "\n\n"
    
    only1, only2, diff = [], [], []
    for k in keys:
        v1, v2 = t1.get(k), t2.get(k)
        if v1 and not v2: only1.append((k, v1["raw"]))
        elif v2 and not v1: only2.append((k, v2["raw"]))
        elif v1 and v2 and v1["cmp"] != v2["cmp"]:
            diff.append((k, v1["raw"], v2["raw"]))
    
    if only1:
        out += f"\nOnly in v1 ({len(only1)}):\n" + "-" * 40 + "\n"
        for k, v in only1: out += f"  {k} = {v}\n"
    if only2:
        out += f"\nOnly in v2 ({len(only2)}):\n" + "-" * 40 + "\n"
        for k, v in only2: out += f"  {k} = {v}\n"
    if diff:
        out += f"\nDifferent Tags ({len(diff)}):\n" + "-" * 40 + "\n"
        for k, t1v, t2v in diff:
            out += f"  {k}\n    v1: {t1v}\n    v2: {t2v}\n"
    
    out += f"\n" + "=" * 80 + f"\nSummary:\n  Total: {len(keys)}\n  Same: {len(keys) - len(only1) - len(only2) - len(diff)}\n  Different: {len(diff)}\n  Only v1: {len(only1)}\n  Only v2: {len(only2)}\n"
    return out

if __name__ == "__main__":
    try:
        content = compare(sys.argv[1] if len(sys.argv) > 1 else None)
        print(content)
        write_dump_file(content, "Dump", os.path.dirname(__file__))
    except Exception as e:
        print(f"Error: {e}")
        import traceback; traceback.print_exc()
        sys.exit(1)