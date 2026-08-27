import os
import sys

p = os.path.dirname(os.path.abspath(__file__))
while p != os.path.dirname(p) and not os.path.exists(os.path.join(p, "common")):
    p = os.path.dirname(p)
sys.path.insert(0, os.path.join(p, "common"))
from dump_utils import write_dump_file, get_api_response


def get_markers(member):
    markers = []
    ser = member.get("Serialization", {})
    if ser.get("CanSave"):
        markers.append("{CanSave}")
    if ser.get("CanLoad"):
        markers.append("{CanLoad}")
    if "NotScriptable" in member.get("Tags", []):
        markers.append("{NotScriptable}")
    return markers


if __name__ == "__main__":
    try:
        resp, vh = get_api_response(sys.argv[1] if len(sys.argv) > 1 else None)
        data = resp.json()

        classes = {}
        for cls in data["Classes"]:
            props = {}
            for m in cls.get("Members", []):
                if m.get("MemberType") == "Property":
                    n = m["Name"]
                    props[n[0].lower() + n[1:]] = m
            classes[cls["Name"]] = {"super": cls.get("Superclass") or None, "props": props}

        lines = ["=== SHADOWING ==="]
        total = 0
        for cls_name, info in sorted(classes.items()):
            props_out = []
            for pname, member in info["props"].items():
                cur, seen = info, set()
                while cur and cur["super"] and cur["super"] not in seen:
                    seen.add(cur["super"])
                    parent_name = cur["super"]
                    parent = classes.get(parent_name)
                    if not parent:
                        break
                    shadowed = parent["props"].get(pname[0].lower() + pname[1:])
                    if shadowed is not None:
                        vt = member.get("ValueType", {}).get("Name")
                        markers = get_markers(member)
                        props_out.append(
                            f"{cls_name}.{member['Name']} ({vt}) {' '.join(markers)}".rstrip()
                            + f"\tshadows {parent_name}.{shadowed['Name']}"
                        )
                        # break  # a deeper ancestor match would be shadowed by this nearer one anyway
                    cur = parent
            if props_out:
                lines.extend(props_out)
                lines.append("")  # extra newline between classes
                total += len(props_out)

        content = "\n".join(lines) + "\n"
        full = f"{vh}\n\nTRY TO MAKE NOTSCRIPTABLEFIXES FALLBACKS FOR THESE AS THEY CAN BE USEFUL\n\n{content}"
        print(content)
        write_dump_file(full, "Dump", os.path.dirname(__file__))
    except Exception as e:
        print(f"Error: {e}")
        import traceback

        traceback.print_exc()
