import os, sys, requests, re, json


def array_to_dictionary(t, h=None):
    if h == "adjust":
        return {
            k: array_to_dictionary(v, "adjust") if isinstance(v, dict) else v
            for k, v in t.items()
        }
    return {v: True for v in t if isinstance(v, str)}


def write_dump_file(content, filename="Dump", script_dir=None):
    if script_dir is None:
        script_dir = os.path.dirname(os.path.abspath(__file__))
    path = os.path.join(script_dir, filename)
    if os.path.exists(path):
        with open(path) as f:
            old = f.read().splitlines()
        new = content.splitlines()
        if len(old) > 1 and len(new) > 1 and "\n".join(old[1:]) == "\n".join(new[1:]):
            print("No content changes, skipping write.")
            return False
    with open(path, "w") as f:
        f.write(content)
    print("File written.")
    return True


def normalize_v2_dump(data):
    res = {"Classes": [], "Enums": []}
    for c in data["classes"]:
        nc = {
            "Name": c.get("name"),
            "Superclass": c.get("baseClass"),
            "Members": [],
            "Tags": [],
        }
        # for ck, cv in c.items():
        #     if ck not in nc:
        #         nc[ck] = cv
        c_tags = []
        # if c.get("isPublic") == False:
        #     c_tags.append("NotReplicated")
        if c.get("isScriptCreatable") == False:
            c_tags.append("NotCreatable")
            c_tags.append("NotReplicated")
        elif c.get("isUserFacing") == False:
            c_tags.append("NotReplicated")
        if c.get("deprecated"):
                c_tags.append("Deprecated")

        if nc["Name"].endswith("Service"):
            c_tags.append("Service")
        nc["Tags"] = c_tags

        for m in c.get("members"):
            nm = {
                "Name": m.get("name"),
                "MemberType": m.get("memberType"),
                "ThreadSafety": m.get("threadSafety"),
            }

            m_tags = []
            if m.get("isYieldable"):
                m_tags.append("Yields")
            if m.get("isPublic") == False:
                m_tags.append("Hidden")
            if m.get("isScriptable") == False:
                m_tags.append("NotScriptable")
            if m.get("isReplicated") == False:
                m_tags.append("NotReplicated")

            if m.get("deprecated"):
                m_tags.append("Deprecated")
            if m.get("isAsync") == False:
                m_tags.append("NoYield")
            if m.get("replacedWith"):
                m_tags.append(
                    {
                        "PreferredDescriptorName": m.get("replacedWith"),
                        "ThreadSafety": "Unknown",
                    }
                )

            mt = m.get("type")

            if m.get("memberType") == "Property":
                if m.get("writeSecurity") == None:  # unreliable
                    print(nm["Name"])
                    m_tags.append("ReadOnly")
                if m.get("readSecurity") == None:  # unreliable
                    print(nm["Name"])
                    m_tags.append("WriteOnly")

                nm["Security"] = {
                    "Read": m.get("readSecurity"),
                    "Write": m.get("writeSecurity"),
                }
                nm["Serialization"] = {
                    "CanLoad": m.get("isSerialized"),
                    "CanSave": m.get("isSerialized"),
                }
                dv = (
                    mt["defaultValue"]
                    if "defaultValue" in mt and mt["defaultValue"] is not None
                    else mt.get(
                        "defaultValueMissingReason", "__api_dump_no_string_value__"
                    )
                )
                if dv.startswith("api_dump_"):
                    dv = "__" + dv + "__"
                nm["Default"] = dv

                nm["ValueType"] = {
                    "Name": mt.get("type"),
                    "Category": mt.get("isEnum") and "Enum" or None,
                    "Capabilities": mt.get("capabilities"),
                }

            elif m.get("memberType") in ["Function", "Event", "Callback"]:

                nm["Security"] = mt.get("security")
                nm["Parameters"] = [
                    {
                        "Name": a.get("identifier"),
                        "Type": {
                            "Name": a.get("type"),
                            "Category": mt.get("isEnum") and "Enum" or None,
                        },
                    }
                    for a in (mt.get("arguments"))
                ]

                r = mt.get("results")[0]

                nm["ReturnType"] = {
                    "Name": r.get("type"),
                    "Category": mt.get("isEnum") and "Enum" or None,
                }
            nm["Tags"] = m_tags

            # for mk, mv in m.items():
            #     if mk not in nm:
            #         nm[mk] = mv
            nc["Members"].append(nm)
        res["Classes"].append(nc)
    for e in data["enums"]:
        enum = {
            "Name": e.get("name"),
            "Items": [{"Name": k, "Value": v} for k, v in e.get("items", {}).items()],
        }

        res["Enums"].append(enum)
    return res


def get_api_response(version_hash=None, api_version="auto"):
    def fetch(u):
        try:
            r = requests.get(u.strip())
            r.raise_for_status()
            return r
        except:
            return None

    if not version_hash:
        try:
            txt = requests.get("https://setup.rbxcdn.com/DeployHistory.txt").text
            for line in reversed(txt.splitlines()):
                m = re.search(r"(version-[^\s]+)", line)
                if m:
                    version_hash = m.group(1)
                    break
        except:
            pass

    if not version_hash:
        print("No version hash found")
        sys.exit(1)

    urls = []
    if api_version == "auto":
        urls = [
            ("v1", f"https://setup.rbxcdn.com/{version_hash}-Full-API-Dump.json"),
            ("v2", f"https://setup.rbxcdn.com/{version_hash}-API-Dump-2.json"),
        ]
    elif api_version == "v2":
        urls = [("v2", f"https://setup.rbxcdn.com/{version_hash}-API-Dump-2.json")]
    else:
        urls = [("v1", f"https://setup.rbxcdn.com/{version_hash}-Full-API-Dump.json")]

    for v, u in urls:
        print(f"Trying {v}: {u}")
        r = fetch(u)
        if r:
            data = r.json()
            if v == "v2":

                class W:
                    def __init__(self, orig, data):
                        self._o, self._d = orig, data

                    def json(self):
                        return self._d

                    def __getattr__(self, a):
                        return getattr(self._o, a)

                return W(r, normalize_v2_dump(data)), version_hash
            return r, version_hash
    sys.exit(1)
