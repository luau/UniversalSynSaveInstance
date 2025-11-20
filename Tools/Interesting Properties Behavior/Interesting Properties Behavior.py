import os
import sys


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
    class_list = {}

    # Blacklist of common types that shouldn't trigger the warning
    NOTSCRIPTABLE_BLACKLIST = {
        "Axes",
        "bool",
        "BrickColor",
        "CFrame",
        "Color3",
        "ColorSequence",
        "Content",
        "ContentId",
        "double",
        "Faces",
        "float",
        "Font",
        "int",
        "int64",
        "NumberRange",
        "NumberSequence",
        "PhysicalProperties",
        "Ray",
        "Rect",
        "string",
        "UDim",
        "UDim2",
        "Vector2",
        "Vector3",
    }

    not_scriptable_types = set()
    not_scriptable_properties = []

    # First pass: collect NotScriptable data
    for api_class in api_classes:
        class_name = api_class["Name"]
        class_members = api_class["Members"]

        for member in class_members:
            if member["MemberType"] == "Property":
                member_tags = member.get("Tags")
                if member_tags:
                    member_tags = array_to_dictionary(member_tags)
                    if member_tags.get("NotScriptable"):
                        value_type = member["ValueType"]
                        value_type_name = value_type["Name"]
                        value_type_cat = value_type["Category"]
                        if (
                            value_type_cat not in ["Enum", "Class"]
                            and value_type_name not in NOTSCRIPTABLE_BLACKLIST
                        ):
                            not_scriptable_types.add(value_type_name)
                            not_scriptable_properties.append(
                                f"{class_name}.{member['Name']}"
                            )

    # Second pass: original data collection + NotScriptable type checking
    for api_class in api_classes:
        class_name = api_class["Name"]
        class_members = api_class["Members"]
        class_tags = api_class.get("Tags")

        if class_tags:
            class_tags = array_to_dictionary(class_tags)
        else:
            print(class_name, "notags")

        class_info = {
            "Tags": class_tags,
            "Superclass": api_class["Superclass"],
            "Properties": {},
        }

        prev_len = len(s)

        for member in class_members:
            if member["MemberType"] == "Property":
                property_name = member["Name"]
                member_tags = member.get("Tags")

                if member_tags:
                    member_tags = array_to_dictionary(member_tags)
                else:
                    member_tags = {}

                serialization = member["Serialization"]

                # Check if this property uses a ValueType from NotScriptable properties
                value_type = member["ValueType"]
                value_type_name = value_type["Name"]
                value_type_cat = value_type["Category"]
                uses_notscriptable_type = (
                    value_type_name in not_scriptable_types
                    and value_type_cat not in ["Enum", "Class"]
                    and not member_tags.get("NotScriptable")
                    and value_type_name not in NOTSCRIPTABLE_BLACKLIST
                )
                tags = []

                if uses_notscriptable_type:
                    tags.append(
                        f"{{Uses NotScriptable Type without the tag - {value_type_name} }}"
                    )

                if member_tags.get("WriteOnly"):
                    if member_tags.get("NotScriptable"):
                        tags.append("{WriteOnly}")
                    else:
                        tags.append("{Has WriteOnly without NotScriptable}")

                if serialization["CanLoad"] or serialization["CanSave"]:
                    # Add CanLoad/CanSave conditions
                    if serialization["CanLoad"] and not serialization["CanSave"]:
                        tags.append("{CanLoad Only}")
                    elif serialization["CanSave"] and not serialization["CanLoad"]:
                        tags.append("{CanSave Only}")

                    # Add Deprecated tag if present
                    if member_tags.get("Deprecated"):
                        deprecated_tag = "{Deprecated}"
                        if serialization["CanSave"]:
                            deprecated_tag += " {CanSave}"
                        tags.append(deprecated_tag)

                    # Combine tags into one line, each tag in separate brackets
                    if tags:
                        s += f"{class_name}.{property_name} {' '.join(tags)}\n"

                class_info["Properties"][property_name] = {
                    "Serialization": serialization,
                    "Tags": member_tags,
                    "Default": member.get("Default"),
                }

        if class_tags and class_tags.get("NotCreatable"):
            for property_name, property_info in class_info["Properties"].items():
                value = property_info.get("Default")
                if (
                    value != "__api_dump_class_not_creatable__"
                    and "__api_dump_" not in value
                ):
                    s += f"{class_name} is NotCreatable but {class_name}.{property_name} has a default value: {value}\n"
                    break

        if len(s) != prev_len:
            s += "\n"

        class_list[class_name] = class_info

    # Add analysis section
    s += "\n" + "=" * 50 + "\n"
    s += "NOTSCRIPTABLE VALUE TYPE ANALYSIS\n"
    s += "=" * 50 + "\n\n"

    s += f"ValueTypes found exclusively in NotScriptable properties: {len(not_scriptable_types)}\n"
    for type_name in sorted(not_scriptable_types):
        s += f"  - {type_name}\n"

    s += f"\nProperties with NotScriptable tag: {len(not_scriptable_properties)}\n"
    for prop in sorted(not_scriptable_properties):
        s += f"  - {prop}\n"

    s += f"\nBlacklisted types (excluded from analysis): {len(NOTSCRIPTABLE_BLACKLIST)}\n"
    for type_name in sorted(NOTSCRIPTABLE_BLACKLIST):
        s += f"  - {type_name}\n"

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
