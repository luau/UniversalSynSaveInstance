import os, sys
p = os.path.dirname(os.path.abspath(__file__))
while p != os.path.dirname(p) and not os.path.exists(os.path.join(p, "common")):
    p = os.path.dirname(p)
sys.path.insert(0, os.path.join(p, "common"))
from dump_utils import write_dump_file, get_api_response, array_to_dictionary

BLACKLIST = {"Axes", "bool", "BrickColor", "CFrame", "Color3", "ColorSequence", "Content", "ContentId", "double", "Faces", "float", "Font", "int", "int64", "NumberRange", "NumberSequence", "PhysicalProperties", "Ray", "Rect", "string", "UDim", "UDim2", "Vector2", "Vector3"}

def fetch(vh=None):
    resp, vh = get_api_response(vh, api_version="v2")
    classes = resp.json()["Classes"]
    s = f"{vh}\n\n"
    hierarchy, nc_classes, c_classes, props_dict = {}, set(), set(), {}
    ns_types, ns_props = set(), []

    for c in classes:
        name = c["Name"]
        tags = array_to_dictionary(c.get("Tags")) if c.get("Tags") else {}
        if tags.get("NotCreatable"): nc_classes.add(name)
        else: c_classes.add(name)
        hierarchy[name] = {"super": c["Superclass"], "tags": tags}
        p_names = set()
        for m in c["Members"]:
            if m["MemberType"] == "Property":
                p_names.add(m["Name"])
                m_tags = array_to_dictionary(m.get("Tags")) if m.get("Tags") else {}
                if m_tags.get("NotScriptable"):
                    vt = m["ValueType"]
                    if vt["Category"] not in ["Enum", "Class"] and vt["Name"] not in BLACKLIST:
                        ns_types.add(vt["Name"])
                        ns_props.append(f"{name}.{m['Name']}")
        props_dict[name] = p_names

    def has_ancestor(name, target_set, visited=None):
        if visited is None: visited = set()
        if name in visited or name not in hierarchy: return False
        visited.add(name)
        sup = hierarchy[name]["super"]
        if not sup or sup in ["Instance", "Object"]: return False
        if sup in target_set: return True
        return has_ancestor(sup, target_set, visited)

    nc_with_c_anc = [n for n in nc_classes if has_ancestor(n, c_classes)]
    c_with_nc_anc = [n for n in c_classes if has_ancestor(n, nc_classes)]
    
    p2c = {}
    for n in hierarchy:
        sup = hierarchy[n]["super"]
        if sup: p2c.setdefault(sup, []).append(n)
    
    siblings = {}
    for sup, children in p2c.items():
        if sup in ["Instance", "Object"]: continue
        nc_children = [x for x in children if x in nc_classes]
        c_children = [x for x in children if x in c_classes]
        if nc_children and c_children:
            for nc in nc_children:
                siblings.setdefault(nc, []).extend(c_children)
    for k in siblings: siblings[k] = list(set(siblings[k]))

    for c in classes:
        name = c["Name"]
        tags = array_to_dictionary(c.get("Tags")) if c.get("Tags") else {}
        prev = len(s)
        for m in c["Members"]:
            if m["MemberType"] == "Property":
                pname = m["Name"]
                m_tags = array_to_dictionary(m.get("Tags")) if m.get("Tags") else {}
                raw_tags = m.get("Tags", [])
                ser = m["Serialization"]
                vt = m["ValueType"]
                tags_out = []
                
               
                if vt["Name"] in ns_types and vt["Category"] not in ["Enum", "Class"] and not m_tags.get("NotScriptable") and vt["Name"] not in BLACKLIST:
                    tags_out.append(f"{{Uses NotScriptable Type without the tag - {vt['Name']}}}")
                if m_tags.get("WriteOnly"):
                    tags_out.append("{WriteOnly}" if m_tags.get("NotScriptable") else "{Has WriteOnly without NotScriptable}")
                if ser["CanLoad"] or ser["CanSave"]:
                    if ser["CanLoad"] and not ser["CanSave"]: tags_out.append("{CanLoad Only}")
                    elif ser["CanSave"] and not ser["CanLoad"]: tags_out.append("{CanSave Only}")
                    if m_tags.get("Deprecated"):
                        d = "{Deprecated}" + (" {CanSave}" if ser["CanSave"] else "")
                        tags_out.append(d)
                        
                pref = None
                for t in raw_tags:
                    if isinstance(t, dict): pref = t.get("PreferredDescriptorName"); break
                if pref and pref not in props_dict.get(name, set()):
                    tags_out.append(f"{{PreferredDescriptorName: {pref} (NOT FOUND)}}")
                elif pref:
                    tags_out.append(f"{{PreferredDescriptorName: {pref}}}")

                if tags_out:
                    s += f"{name}.{pname} {' '.join(tags_out)}\n"
        
        if tags.get("NotCreatable"):
            for m in c["Members"]:
                if m["MemberType"] == "Property":
                    val = m.get("Default")
                    if val != "__api_dump_class_not_creatable__" and "__api_dump_" not in val:
                        s += f"{name} is NotCreatable but {name}.{m['Name']} has default: \"{val}\"\n"
                        break
        if len(s) > prev: s += "\n"

    s += "=" * 50 + "\nNOTSCRIPTABLE VALUE TYPE ANALYSIS\n" + "=" * 50 + "\n"
    s += f"ValueTypes found exclusively in NotScriptable properties: {len(ns_types)}\n"
    for t in sorted(ns_types): s += f"  - {t}\n"
    s += f"\nProperties with NotScriptable tag: {len(ns_props)}\n"
    for p in sorted(ns_props): s += f"  - {p}\n"
    
    s += "\n" + "=" * 50 + "\nPREFERREDDESCRIPTORNAME ANALYSIS\n" + "=" * 50 + "\n"
    pref_count, invalid_pref = 0, 0
    for c in classes:
        for m in c["Members"]:
            if m["MemberType"] == "Property":
                for t in m.get("Tags", []):
                    if isinstance(t, dict):
                        pref_count += 1
                        if t.get("PreferredDescriptorName") not in props_dict.get(c["Name"], set()):
                            invalid_pref += 1
    s += f"Properties using PreferredDescriptorName: {pref_count}\n"
    s += f"Properties with PreferredDescriptorName pointing to non-existent property: {invalid_pref}\n"
    if invalid_pref > 0:
        s += "\nDetailed list:\n"
        for c in classes:
            for m in c["Members"]:
                if m["MemberType"] == "Property":
                    for t in m.get("Tags", []):
                        if isinstance(t, dict):
                            pd = t.get("PreferredDescriptorName")
                            if pd and pd not in props_dict.get(c["Name"], set()):
                                s += f"  - {c['Name']}.{m['Name']} -> {pd}\n"

    s += "\n" + "=" * 50 + "\nNOTCREATABLE INHERITANCE ANALYSIS\n" + "=" * 50 + "\n"
    s += f"NotCreatable classes that inherit from creatable classes: {len(nc_with_c_anc)}\n"
    for n in sorted(nc_with_c_anc):
        chain = []
        curr = n
        while curr in hierarchy:
            chain.append(curr)
            curr = hierarchy[curr]["super"]
            if not curr: break
        s += f"  - {n} (inheritance: {' -> '.join(chain)})\n"

    s += "\n" + "=" * 50 + "\nCREATABLE SIBLINGS OF NOTCREATABLE CLASSES\n" + "=" * 50 + "\n"
    if siblings:
        s += f"NotCreatable classes that have creatable siblings: {len(siblings)}\n"
        for n in sorted(siblings.keys()):
            s += f"  - {n} (parent: {hierarchy[n]['super']}) has creatable siblings:\n"
            for sib in sorted(siblings[n]): s += f"      - {sib}\n"
    else:
        s += "No NotCreatable classes found with creatable siblings.\n"
    return s

if __name__ == "__main__":
    try:
        content = fetch(sys.argv[1] if len(sys.argv) > 1 else None)
        print(content)
        write_dump_file(content, "Dump", os.path.dirname(__file__))
    except Exception as e:
        print(f"Error: {e}")