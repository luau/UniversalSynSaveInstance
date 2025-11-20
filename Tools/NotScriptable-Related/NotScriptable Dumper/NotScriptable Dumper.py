import os
import sys
import re


def import_dump_utils():
    """Smart function to find and import dump_utils from common directory"""
    current_dir = os.path.dirname(os.path.abspath(__file__))

    # Search up the directory tree
    search_dir = current_dir
    max_depth = 10

    for _ in range(max_depth):
        common_path = os.path.join(search_dir, "common")
        dump_utils_path = os.path.join(common_path, "dump_utils.py")

        if os.path.exists(dump_utils_path):
            if common_path not in sys.path:
                sys.path.append(common_path)
            try:
                from dump_utils import (
                    write_dump_file,
                    get_api_response,
                    array_to_dictionary,
                )

                print(f"Found dump_utils at: {common_path}")
                return write_dump_file, get_api_response, array_to_dictionary
            except ImportError as e:
                print(f"Failed to import from {common_path}: {e}")
                break

        parent_dir = os.path.dirname(search_dir)
        if parent_dir == search_dir:
            break
        search_dir = parent_dir

    raise ImportError("Could not find common/dump_utils.py in any parent directory")


# Import utilities
write_dump_file, get_api_response, array_to_dictionary = import_dump_utils()


def fetch_api(version_hash=None):
    response, version_hash = get_api_response(version_hash)
    api_classes = response.json()["Classes"]

    s = version_hash + "\n\n"
    filtered_properties = []

    for api_class in api_classes:
        class_name = api_class["Name"]
        class_members = api_class["Members"]

        prev_len = len(s)
        enum_members = {}

        for member in class_members:
            member_name = member["Name"]
            member_type = member["MemberType"]
            if member_type == "Property":
                serialization = member["Serialization"]
                member_tags = member.get("Tags")
                original_tags = member_tags
                special = False
                if member_tags:
                    member_tags = array_to_dictionary(member_tags)
                    special = member_tags.get("NotScriptable")

                if serialization["CanLoad"] and serialization["CanSave"] and special:
                    value_type = member["ValueType"]["Name"]
                    value_category = member["ValueType"]["Category"]
                    if value_category == "Enum":
                        enum_members[value_type] = member_name
                    s += f"{class_name}.{member_name} {{{value_type}}}"
                    for item in original_tags:
                        if isinstance(item, dict):
                            s += f"{{PreferredDescriptorName: {item.get('PreferredDescriptorName')}}}"
                    s += "\n"

                if re.search(
                    r"xml|internal|serial|replica", member_name, re.IGNORECASE
                ):
                    prop_str = f"{class_name}.{member_name}"
                    if not special:
                        prop_str += " {Scriptable}"
                    if not (
                        serialization.get("CanLoad", True)
                        and serialization.get("CanSave", True)
                    ):
                        prop_str += " {Serialize: False}"

                    filtered_properties.append(prop_str)

        for enum_type, real_member_name in enum_members.items():
            for member in class_members:
                member_name = member["Name"]
                member_type = member["MemberType"]
                if member_name != real_member_name and member_type == "Property":
                    value_category = member["ValueType"]["Category"]
                    if value_category == "Enum":
                        value_type = member["ValueType"]["Name"]
                        if value_type == enum_type:
                            s += f"{real_member_name} -> {member_name} {{POTENTIAL PROXY}}\n"

        if len(s) != prev_len:
            s += "\n"

    if filtered_properties:
        s += "\nPotential Proxy Properties:\n"
        s += "\n".join(filtered_properties) + "\n"

    return s


if __name__ == "__main__":
    version_hash = sys.argv[1] if len(sys.argv) > 1 else None
    try:
        content = fetch_api(version_hash)
        print(content)

        script_dir = os.path.dirname(os.path.realpath(__file__))
        write_dump_file(content, "Dump", script_dir)

    except Exception as e:
        print(f"Error: {e}")
