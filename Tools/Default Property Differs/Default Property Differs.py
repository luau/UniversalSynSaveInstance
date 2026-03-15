import os, sys

p = os.path.dirname(os.path.abspath(__file__))
while p != os.path.dirname(p) and not os.path.exists(os.path.join(p, "common")):
    p = os.path.dirname(p)
sys.path.insert(0, os.path.join(p, "common"))
from dump_utils import write_dump_file, get_api_response

def build_map(data):
    props = {}
    for cls in data["Classes"]:
        cn = cls.get("Name")
        if not cn: continue
        for m in cls.get("Members", []):
            if m.get("MemberType") == "Property":
                props[f"{cn}.{m.get('Name')}"] = m.get("Default")
    return props

def compare(vh=None):
    r1, h1 = get_api_response(vh, api_version="v1")
    r2, h2 = get_api_response(vh, api_version="v2")
    p1, p2 = build_map(r1.json()), build_map(r2.json())
    keys = sorted(set(p1.keys()) | set(p2.keys()))
    out = f"Version v1: {h1}\nVersion v2: {h2}\n" + "=" * 80 + "\n\n"
    only1, only2, diff, same = [], [], [], []
    for k in keys:
        v1, v2 = p1.get(k), p2.get(k)
        if v1 is not None and v2 is None: only1.append((k, v1))
        elif v2 is not None and v1 is None: only2.append((k, v2))
        elif v1 != v2 and not  (v1.startswith("__api_dump_") and v2.startswith("__api_dump_")): diff.append((k, v1, v2))
        else: same.append(k)
    
    if only1:
        out += f"\nOnly in v1 ({len(only1)}):\n" + "-" * 40 + "\n"
        for k, d in only1: out += f"  {k} = {repr(d)[:60]}\n"
    if only2:
        out += f"\nOnly in v2 ({len(only2)}):\n" + "-" * 40 + "\n"
        for k, d in only2: out += f"  {k} = {repr(d)[:60]}\n"
    if diff:
        out += f"\nDifferent Default values ({len(diff)}):\n" + "-" * 40 + "\n"
        for k, d1, d2 in diff: out += f"  {k}\n    v1: {repr(d1)[:40]}\n    v2: {repr(d2)[:40]}\n"
    
    out += f"\n" + "=" * 80 + f"\nSummary:\n  Total: {len(keys)}\n  Same: {len(same)}\n  Different: {len(diff)}\n  Only v1: {len(only1)}\n  Only v2: {len(only2)}\n"
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