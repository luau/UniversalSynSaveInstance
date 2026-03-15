import os, sys, requests
p = os.path.dirname(os.path.abspath(__file__))
while p != os.path.dirname(p) and not os.path.exists(os.path.join(p, "common")):
    p = os.path.dirname(p)
sys.path.insert(0, os.path.join(p, "common"))
from dump_utils import write_dump_file, get_api_response

def extract_caps(data, caps=None):
    if caps is None: caps = set()
    if isinstance(data, list):
        for i in data: extract_caps(i, caps)
    elif isinstance(data, dict):
        for k, v in data.items(): extract_caps(v, caps)
    elif isinstance(data, str): caps.add(data)
    return caps

def get_roblox_types():
    try:
        resp = requests.get("https://api.github.com/repos/Roblox/creator-docs/contents/content/en-us/reference/engine/datatypes")
        return [i["name"][:-5] for i in resp.json() if i["type"] == "file" and i["name"].endswith(".yaml")]
    except: return []

def fetch(vh=None):
    resp, vh = get_api_response(vh)
    data = resp.json()
    dtypes, dtypes_set, save_t, load_t = [], set(), {}, {}
    all_m_tags, all_caps, all_c_tags = set(), set(), set()

    for c in data["Classes"]:
        for t in c.get("Tags", []):
            if isinstance(t, str): all_c_tags.add(t)
        for m in c["Members"]:
            for t in m.get("Tags", []):
                if isinstance(t, str): all_m_tags.add(t)
            for cap in extract_caps(m.get("Capabilities", [])): all_caps.add(cap)
            if m["MemberType"] == "Property":
                ser = m["Serialization"]
                vt = m["ValueType"]
                if vt["Category"] in ["Enum", "Class"]: continue
                name = vt["Name"]
                if ser["CanSave"]: save_t[name] = True
                elif name not in save_t: save_t[name] = False
                if ser["CanLoad"]: load_t[name] = True
                elif name not in load_t: load_t[name] = False
                if name not in dtypes_set:
                    dtypes_set.add(name)
                    dtypes.append(name)
    
    for e in data["Enums"]:
        if e["Name"] == "SecurityCapability":
            for i in e["Items"]: all_caps.add(i["Name"])
            break
    return vh, dtypes, dtypes_set, save_t, load_t, all_m_tags, all_caps, all_c_tags

if __name__ == "__main__":
    try:
        vh, dtypes, dtypes_set, save_t, load_t, all_m_tags, all_caps, all_c_tags = fetch(sys.argv[1] if len(sys.argv) > 1 else None)
        dtypes.sort()
        roblox = sorted(get_roblox_types())
        all_d = sorted(list(set(dtypes) | set(roblox)))
        api_only = set(dtypes) - set(roblox)
        docs_only = set(roblox) - set(dtypes)
        
        lines = ["=== DATATYPES ==="]
        for d in all_d:
            ind = []
            if d in api_only: ind.append("[API]")
            elif d in docs_only: ind.append("[DOCS]")
            else: ind.append("[BOTH]")
            if d in dtypes_set:
                if save_t.get(d): ind.append("{CanSave}")
                if load_t.get(d): ind.append("{CanLoad}")
                if (save_t.get(d) and not load_t.get(d)) or (load_t.get(d) and not save_t.get(d)):
                    ind.append("-> Probably has a descriptor")
            lines.append(f"{d} {' '.join(ind)}")
        
        lines.append("\n=== DATATYPES ANALYSIS ===")
        lines.append(f"Total unique datatypes: {len(all_d)}")
        lines.append(f"From API only: {len(api_only)}")
        lines.append(f"From Docs only: {len(docs_only)}")
        lines.append(f"In both sources: {len(set(dtypes) & set(roblox))}")
        
        lines.append("\n=== CLASS TAGS ===")
        lines.append(f"Total unique class tags: {len(all_c_tags)}")
        for t in sorted(all_c_tags): lines.append(f"  {t}")
        
        lines.append("\n=== MEMBER TAGS ===")
        lines.append(f"Total unique tags: {len(all_m_tags)}")
        for t in sorted(all_m_tags): lines.append(f"  {t}")
        
        lines.append("\n=== CAPABILITIES ===")
        lines.append(f"Total unique capabilities: {len(all_caps)}")
        for t in sorted(all_caps): lines.append(f"  {t}")
        
        content = "\n".join(lines) + "\n"
        full = f"{vh}\n\n{content}"
        print(content)
        write_dump_file(full, "Dump", os.path.dirname(__file__))
    except Exception as e:
        print(f"Error: {e}")
        import traceback; traceback.print_exc()