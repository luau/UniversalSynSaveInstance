import os, sys, requests, json, time

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CACHE_FILE = os.path.join(SCRIPT_DIR, "api_dump_cache.json")
CACHE_TTL = 60 * 60 * 2  # 2 hours


def array_to_dictionary(t, h=None):
    if h == "adjust":
        return {
            k: array_to_dictionary(v, "adjust") if isinstance(v, dict) else v
            for k, v in t.items()
        }
    return {v: True for v in t if isinstance(v, str)}


def write_dump_file(content, filename="Dump", script_dir=None, skip_lines=1):
    if script_dir is None:
        script_dir = os.path.dirname(os.path.abspath(__file__))
    path = os.path.join(script_dir, filename)

    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            old = f.read().splitlines()
        new = content.splitlines()

        if "\n".join(old[skip_lines:]) == "\n".join(new[skip_lines:]):
            print(
                f"No content changes (ignoring first {skip_lines} lines), skipping write."
            )
            return False

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

    print("File written:", path)
    return True


def normalize_v2_dump(data):
    class_names = {c.get("name") for c in data["classes"]}

    type_renames = {
        "CoordinateFrame": "CFrame",
        "Rect2D": "Rect",
        "Vector3Int16": "Vector3int16",
        "Vector2Int16": "Vector2int16",
    }

    def apply_rename(type_name):
        return type_renames.get(type_name, type_name)

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
                    m_tags.append("ReadOnly")
                if m.get("readSecurity") == None:  # unreliable
                    m_tags.append("WriteOnly")

                nm["Security"] = {
                    "Read": m.get("readSecurity"),
                    "Write": m.get("writeSecurity"),
                }
                nm["Serialization"] = {
                    "CanLoad": m.get("isSerialized"),
                    "CanSave": m.get("isSerialized"),
                }
                
                dv = mt.get("defaultValue")
                if dv is None:
                    dv = mt.get("defaultValueMissingReason", "__api_dump_no_string_value__")
                
                if isinstance(dv, str) and dv.startswith("api_dump_"):
                    dv = "__" + dv + "__"
                nm["Default"] = dv

                # 3. Determine Category and Apply Rename
                type_name = mt.get("type")
                category = None
                if mt.get("isEnum"):
                    category = "Enum"
                elif type_name in class_names:
                    category = "Class"

                nm["ValueType"] = {
                    "Name": apply_rename(type_name),
                    "Category": category,
                    "Capabilities": mt.get("capabilities"),
                }

            elif m.get("memberType") in ["Function", "Event", "Callback"]:

                nm["Security"] = mt.get("security")
                nm["Parameters"] = [
                    {
                        "Name": a.get("identifier"),
                        "Type": {
                            "Name": apply_rename(a.get("type")),
                            "Category": "Enum" if mt.get("isEnum") else ("Class" if a.get("type") in class_names else None),
                        },
                    }
                    for a in (mt.get("arguments"))
                ]

                r = mt.get("results")[0]

                nm["ReturnType"] = {
                    "Name": apply_rename(r.get("type")),
                    "Category": "Enum" if mt.get("isEnum") else ("Class" if r.get("type") in class_names else None),
                }
            nm["Tags"] = m_tags

            # for mk, mv in m.items():
            #     if mk not in nm:
            #         nm[mk] = mv
            nc["Members"].append(nm)
        res["Classes"].append(nc)

    res["Classes"].sort(key=lambda x: x["Name"])

    for e in data["enums"]:
        enum = {
            "Name": e.get("name"),
            "Items": [{"Name": k, "Value": v} for k, v in e.get("items", {}).items()],
        }

        res["Enums"].append(enum)

    res["Enums"].sort(key=lambda x: x["Name"])

    return res


def sort_v1_dump(data):
    if "Classes" in data and isinstance(data["Classes"], list):
        data["Classes"].sort(key=lambda x: x.get("Name", ""))

        for c in data["Classes"]:
            if "Members" in c and isinstance(c["Members"], list):
                c["Members"].sort(key=lambda x: x.get("Name", ""))

    if "Enums" in data and isinstance(data["Enums"], list):
        data["Enums"].sort(key=lambda x: x.get("Name", ""))

        for e in data["Enums"]:
            if "Items" in e and isinstance(e["Items"], list):
                e["Items"].sort(key=lambda x: x.get("Name", ""))

    return data


def fetch(u):
    try:
        r = requests.get(u.strip())
        r.raise_for_status()
        return r
    except:
        return None


def parse_version(v):
    return tuple(int(x) for x in v.split("."))


def get_version_history_latest():
    try:
        txt = requests.get(
            "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/version-history.json"
        ).text

        for line in reversed(txt.splitlines()):
            if "version-" in line:
                parts = line.strip().strip(",")
                k, v = parts.split(":")
                return k.strip().strip('"'), v.strip().strip('"')
    except:
        pass


def get_clientsettings(url):
    try:
        data = fetch(url).json()
        return data.get("version"), data.get("clientVersionUpload")
    except:
        return None


def get_latest_version():
    candidates = []

    vh = get_version_history_latest()
    if vh:
        candidates.append(vh)

    zb = get_clientsettings(
        "https://clientsettings.rbxcdn.com/v2/client-version/WindowsStudio64/channel/zbeta"
    )
    if zb:
        candidates.append(zb)

    live = get_clientsettings(
        "https://clientsettings.rbxcdn.com/v2/client-version/WindowsStudio64"
    )
    if live:
        candidates.append(live)

    if not candidates:
        return None, None

    candidates.sort(key=lambda x: parse_version(x[0]), reverse=True)
    return candidates[0]


def load_cache(api_version):
    """Load cached response for a given API version"""
    if not os.path.exists(CACHE_FILE):
        return None, None
    try:
        with open(CACHE_FILE, "r") as f:
            data = json.load(f)

        if api_version in data:
            entry = data[api_version]
            if time.time() - entry["time"] < CACHE_TTL:
                print("Using cached dump for", api_version)

                class CachedResponse:
                    def __init__(self, text):
                        self.text = text
                        self._json = None

                    def json(self):
                        if self._json is None:
                            self._json = json.loads(self.text)
                        return self._json

                return CachedResponse(entry["dump"]), entry.get("version_hash")
    except Exception as e:
        print("Failed to load cache:", e)
    return None, None


def save_cache(resp_obj, api_version, version_hash):
    """Save API dump and version_hash for a given API version"""
    try:
        if os.path.exists(CACHE_FILE):
            with open(CACHE_FILE, "r") as f:
                data = json.load(f)
        else:
            data = {}

        if isinstance(resp_obj, str):
            dump_text = resp_obj
        elif hasattr(resp_obj, "text"):
            dump_text = resp_obj.text
        else:
            dump_text = json.dumps(resp_obj.json())

        data[api_version] = {
            "time": time.time(),
            "dump": dump_text,
            "version_hash": version_hash,
        }
        with open(CACHE_FILE, "w") as f:
            json.dump(data, f)
    except Exception as e:
        print("Failed to save cache:", e)


def get_api_response(version_hash=None, api_version="v1"):
    """Fetch API dump (v1/v2), uses cache per version+api"""
    cached, cached_vh = load_cache(api_version)
    if cached:
        return cached, cached_vh

    if not version_hash:
        version, version_hash = get_latest_version()

    if not version_hash:
        print("No version hash found")
        sys.exit(1)

    print("Using:", version_hash)

    urls = []
    if api_version == "auto":
        urls = [
            ("v1", f"https://setup.rbxcdn.com/{version_hash}-Full-API-Dump.json"),
            ("v2", f"https://setup.rbxcdn.com/{version_hash}-API-Dump-2.json"),
        ]
    else:
        urls = [
            (
                api_version,
                f"https://setup.rbxcdn.com/{version_hash}-{'Full-API-Dump.json' if api_version=='v1' else 'API-Dump-2.json'}",
            )
        ]

    for v, u in urls:
        print(f"Trying {v}: {u}")
        r = fetch(u)
        if not r:
            continue
        if v == "v2":

            class W:
                def __init__(self, orig, data):
                    self._o, self._d = orig, data

                def json(self):
                    return self._d

                def __getattr__(self, a):
                    return getattr(self._o, a)

            normalized = normalize_v2_dump(r.json())
            result = W(r, normalized)
            save_cache(json.dumps(normalized), v, version_hash)
        else:
            raw_data = r.json()
            sorted_data = sort_v1_dump(raw_data)

            class W:
                def __init__(self, orig, data):
                    self._o, self._d = orig, data

                def json(self):
                    return self._d

                def __getattr__(self, a):
                    return getattr(self._o, a)

            result = W(r, sorted_data)
            save_cache(json.dumps(sorted_data), v, version_hash)

        return result, version_hash

    raise RuntimeError("Failed to fetch API dump")
