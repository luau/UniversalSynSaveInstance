import os, sys, re

# Smart import: search up for 'common'
p = os.path.dirname(os.path.abspath(__file__))
while p != os.path.dirname(p) and not os.path.exists(os.path.join(p, "common")):
    p = os.path.dirname(p)
sys.path.insert(0, os.path.join(p, "common"))
from dump_utils import write_dump_file, get_api_response


def fetch(vh=None):
    resp, vh = get_api_response(vh, api_version="v2")
    out = f"{vh}\n\n"
    count = 0
    for cls in resp.json()["Classes"]:
        cname = cls.get("Name", "Unknown")
        added = False
        for m in cls.get("Members", []):
            if m.get("MemberType") != "Property":
                continue
            vt = m.get("ValueType", {})
            if not isinstance(vt, dict) or vt.get("Name") != "Content":
                continue
            # if not vt.get("Default"): continue
            default = m.get("Default")
            if "api_dump_" in default:
                continue
            default = re.sub(r"\s+", "", default)
            out += f"{cname}.{m['Name']} {{default: \"{default}\"}}"
            out += "\n"
            count += 1
            added = True
        if added:
            out += "\n"
    out += f"\n---\nTotal: {count}\n"
    return out


if __name__ == "__main__":
    try:
        c = fetch(sys.argv[1] if len(sys.argv) > 1 else None)
        print(c)
        write_dump_file(c, "Dump", os.path.dirname(__file__))
    except Exception as e:
        print(f"Error: {e}")
        import traceback

        traceback.print_exc()
        sys.exit(1)
