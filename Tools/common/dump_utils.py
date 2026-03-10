# common/dump_utils.py
import os
import sys
import requests
import re
import json


def array_to_dictionary(table, hybrid_mode=None):
    tmp = {}
    if hybrid_mode == "adjust":
        for key, value in table.items():
            if isinstance(key, int):
                tmp[value] = True
            elif isinstance(value, dict):
                tmp[key] = array_to_dictionary(value, "adjust")
            else:
                tmp[key] = value
    else:
        for value in table:
            if isinstance(value, str):
                tmp[value] = True
    return tmp


def should_write_file(output_file_path, new_content):
    if not os.path.exists(output_file_path):
        return True, "File doesn't exist, writing new file."

    with open(output_file_path, "r") as file:
        existing_content = file.read()

    existing_lines = existing_content.splitlines()
    current_lines = new_content.splitlines()

    if len(existing_lines) > 0 and len(current_lines) > 0:
        existing_rest = "\n".join(existing_lines[1:])
        current_rest = "\n".join(current_lines[1:])

        if existing_rest == current_rest:
            return (
                False,
                f"Only version hash changed ({current_lines[0]} -> {existing_lines[0]}), skipping file write.",
            )
        else:
            return True, "API content has changed, writing to file."

    return True, "File structure differs, writing to file."


def write_dump_file(content, filename="Dump", script_dir=None):
    if script_dir is None:
        script_dir = os.path.dirname(os.path.realpath(__file__))

    output_file_path = os.path.join(script_dir, filename)

    should_write, message = should_write_file(output_file_path, content)
    print(message)

    if should_write:
        with open(output_file_path, "w") as file:
            file.write(content)

    return should_write


def normalize_v2_dump(raw_dump):
    """
    Normalize v2 API dump format to match v1 structure for compatibility.
    v2 format: { "classes": [ { "name": "...", "members": [...] }, ... ] }
    v1 format: [ { "Name": "...", "Members": [...] }, ... ] (top-level array)
    """
    if isinstance(raw_dump, dict) and "classes" in raw_dump:
        # This is v2 format - normalize to v1-like structure
        normalized = []
        for cls in raw_dump["classes"]:
            normalized_class = {
                "Name": cls.get("name"),
                "ClassName": cls.get("name"),  # alias for compatibility
                "Members": [],
                "Superclass": cls.get("baseClass"),
                "Tags": cls.get("capabilities", []),
            }

            # Normalize members
            for member in cls.get("members", []):
                normalized_member = {
                    "Name": member.get("name"),
                    "MemberType": member.get(
                        "memberType"
                    ),  # Property, Function, Event, Callback
                    "Security": member.get("security", "None"),
                    "Tags": member.get("capabilities", []),
                }

                # Handle type information
                member_type = member.get("type")
                if member_type:
                    if isinstance(member_type, dict):

                        normalized_member["ValueType"] = {
                            "Name": member_type.get("type") or member_type.get("name"),
                            "Category": member_type.get("category", "Class"),
                        }
                        if "defaultValue" in member_type:
                            normalized_member["ValueType"]["DefaultValue"] = (
                                member_type["defaultValue"]
                            )
                    else:
                        normalized_member["ValueType"] = {
                            "Name": member_type,
                            "Category": "Primitive",
                        }
                    if "defaultValueMissingReason" in member_type:
                        normalized_member["ValueType"]["defaultValueMissingReason"] = (
                            member_type["defaultValueMissingReason"]
                        )
                    if "defaultValue" in member_type:
                        normalized_member["ValueType"]["defaultValue"] = member_type[
                            "defaultValue"
                        ]

                # Handle function-specific fields
                if member.get("memberType") in ("Function", "Callback"):
                    normalized_member["Parameters"] = []
                    normalized_member["ReturnType"] = None

                    if "arguments" in member_type:
                        for arg in member_type["arguments"]:
                            normalized_member["Parameters"].append(
                                {
                                    "Name": arg.get("identifier", "arg"),
                                    "Type": {
                                        "Name": arg.get("type"),
                                        "Category": (
                                            "Class" if not arg.get("isEnum") else "Enum"
                                        ),
                                    },
                                }
                            )

                    if "results" in member_type and member_type["results"]:
                        result = member_type["results"][0]
                        normalized_member["ReturnType"] = {
                            "Name": result.get("type"),
                            "Category": "Class" if not result.get("isEnum") else "Enum",
                        }

                # Copy over common flags
                for flag in [
                    "isPublic",
                    "isScriptable",
                    "isReplicated",
                    "isSerialized",
                    "isYieldable",
                ]:
                    if flag in member:
                        normalized_member[flag] = member[flag]

                normalized_class["Members"].append(normalized_member)

            normalized.append(normalized_class)
        return normalized
    return raw_dump  # Already in v1 format or unknown


def get_api_response(version_hash=None, api_version="auto"):
    """
    Fetch Roblox API dump.

    Args:
        version_hash: Specific version hash to fetch, or None for latest
        api_version: "v1", "v2", or "auto" (try v2 first, fall back to v1)

    Returns:
        tuple: (response_object, version_hash, api_version_used)
    """

    def try_fetch(url):
        try:
            response = requests.get(url.strip())
            response.raise_for_status()
            return response
        except requests.RequestException as e:
            print(f"Error fetching {url}: {e}")
            return None

    if api_version == "auto":
        url_candidates = [
            ("v1", f"https://setup.rbxcdn.com/{version_hash}-Full-API-Dump.json"),
            ("v2", f"https://setup.rbxcdn.com/{version_hash}-API-Dump-2.json"),
        ]
    elif api_version == "v2":
        url_candidates = [
            ("v2", f"https://setup.rbxcdn.com/{version_hash}-API-Dump-2.json")
        ]
    else:  # v1
        url_candidates = [
            ("v1", f"https://setup.rbxcdn.com/{version_hash}-Full-API-Dump.json")
        ]

    # If no version_hash provided, fetch latest from DeployHistory.txt
    if not version_hash:
        deploy_history_url = "https://setup.rbxcdn.com/DeployHistory.txt"
        try:
            deploy_history = requests.get(deploy_history_url).text
            lines = deploy_history.splitlines()
            for line in reversed(lines):
                match = re.search(r"(version-[^\s]+)", line)
                if match:
                    version_hash = match.group(1)
                    # Rebuild candidates with found hash
                    if api_version == "auto":
                        url_candidates = [
                            (
                                "v1",
                                f"https://setup.rbxcdn.com/{version_hash}-Full-API-Dump.json",
                            ),
                            (
                                "v2",
                                f"https://setup.rbxcdn.com/{version_hash}-API-Dump-2.json",
                            ),
                        ]
                    elif api_version == "v2":
                        url_candidates = [
                            (
                                "v2",
                                f"https://setup.rbxcdn.com/{version_hash}-API-Dump-2.json",
                            )
                        ]
                    else:
                        url_candidates = [
                            (
                                "v1",
                                f"https://setup.rbxcdn.com/{version_hash}-Full-API-Dump.json",
                            )
                        ]
                    break
            else:
                print("Could not find version hash in DeployHistory.txt")
                sys.exit(1)
        except requests.RequestException as e:
            print(f"Error fetching deploy history: {e}")
            sys.exit(1)

    for api_ver, url in url_candidates:
        print(f"Trying {api_ver} API dump: {url}")
        response = try_fetch(url)
        if response:
            try:
                data = response.json()
                # Return normalized data for v2, raw for v1
                if api_ver == "v2":
                    normalized_data = normalize_v2_dump(data)

                    class NormalizedResponse:
                        def __init__(self, original_response, normalized_json):
                            self._orig = original_response
                            self._normalized = normalized_json

                        def json(self):
                            return self._normalized

                        def __getattr__(self, attr):
                            return getattr(self._orig, attr)

                    return (
                        NormalizedResponse(response, normalized_data),
                        version_hash,
                    )
                return response, version_hash
            except json.JSONDecodeError as e:
                print(f"Invalid JSON in {api_ver} response: {e}")
                continue

    print("Failed to fetch API dump in any format")
    sys.exit(1)
