import os, sys, re
p = os.path.dirname(os.path.abspath(__file__))
while p != os.path.dirname(p) and not os.path.exists(os.path.join(p, "common")):
    p = os.path.dirname(p)
sys.path.insert(0, os.path.join(p, "common"))
from dump_utils import write_dump_file, get_api_response, array_to_dictionary

def fetch(vh=None):
    resp, vh = get_api_response(vh)
    s = f"{vh}\n\n"
    filtered = []
    for c in resp.json()["Classes"]:
        cname = c["Name"]
        prev = len(s)
        enums = {}
        for m in c["Members"]:
            if m["MemberType"] != "Property": continue
            mname = m["Name"]
            ser = m["Serialization"]
            tags = array_to_dictionary(m.get("Tags")) if m.get("Tags") else {}
            raw = m.get("Tags", [])
            ns = tags.get("NotScriptable")
            if ser["CanLoad"] and ser["CanSave"] and ns:
                vt = m["ValueType"]
                vtn, vtc = vt["Name"], vt["Category"]
                if vtc == "Enum": enums[vtn] = mname
                s += f"{cname}.{mname} {{{vtn}}}"
                for t in raw:
                    if isinstance(t, dict): s += f" {{PreferredDescriptorName: {t.get('PreferredDescriptorName')}}}"
                s += "\n"
            if re.search(r"xml|internal|serial|replica", mname, re.I):
                ps = f"{cname}.{mname}"
                if not ns: ps += " {Scriptable}"
                if not (ser.get("CanLoad", True) and ser.get("CanSave", True)): ps += " {Serialize: False}"
                filtered.append(ps)
        for et, rm in enums.items():
            for m in c["Members"]:
                if m["Name"] != rm and m["MemberType"] == "Property":
                    vt = m["ValueType"]
                    if vt["Category"] == "Enum" and vt["Name"] == et:
                        s += f"{rm} -> {m['Name']} {{POTENTIAL PROXY}}\n"
        if len(s) > prev: s += "\n"
    if filtered: s += "\nPotential Proxy Properties:\n" + "\n".join(filtered) + "\n"
    return s

if __name__ == "__main__":
    try:
        content = fetch(sys.argv[1] if len(sys.argv) > 1 else None)
        print(content)
        write_dump_file(content, "Dump", os.path.dirname(__file__))
    except Exception as e:
        print(f"Error: {e}")