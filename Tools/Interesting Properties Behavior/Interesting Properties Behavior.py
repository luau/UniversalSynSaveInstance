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

    # First pass: collect NotScriptable data and build class hierarchy
    class_hierarchy = {}
    not_creatable_classes = set()
    creatable_classes = set()

    for api_class in api_classes:
        class_name = api_class["Name"]
        class_members = api_class["Members"]
        class_tags = api_class.get("Tags")

        if class_tags:
            class_tags = array_to_dictionary(class_tags)
            if class_tags.get("NotCreatable"):
                not_creatable_classes.add(class_name)
            else:
                creatable_classes.add(class_name)
        else:
            creatable_classes.add(class_name)  # Assume creatable if no tags

        superclass = api_class["Superclass"]
        class_hierarchy[class_name] = {
            "superclass": superclass,
            "tags": class_tags or {},
        }

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

    not_creatable_with_creatable_ancestors = []

    def has_creatable_ancestor(class_name, visited=None):
        """Check if a class has any creatable ancestor in its inheritance chain"""
        if visited is None:
            visited = set()

        if class_name in visited:
            return False
        visited.add(class_name)

        if class_name not in class_hierarchy:
            return False

        superclass = class_hierarchy[class_name]["superclass"]
        if not superclass:  # No superclass
            return False

        # Skip if directly inheriting from Instance or Object
        if superclass in ["Instance", "Object"]:
            return False

        if superclass in creatable_classes:
            return True

        # Recursively check superclass
        return has_creatable_ancestor(superclass, visited)

    for class_name in not_creatable_classes:
        if has_creatable_ancestor(class_name):
            not_creatable_with_creatable_ancestors.append(class_name)

    creatable_with_notcreatable_ancestors = []

    def has_notcreatable_ancestor(class_name, visited=None):
        """Check if a class has any NotCreatable ancestor in its inheritance chain"""
        if visited is None:
            visited = set()

        if class_name in visited:
            return False
        visited.add(class_name)

        if class_name not in class_hierarchy:
            return False

        superclass = class_hierarchy[class_name]["superclass"]
        if not superclass:  # No superclass
            return False

        # Skip if directly inheriting from Instance or Object
        if superclass in ["Instance", "Object"]:
            return False

        if superclass in not_creatable_classes:
            return True

        # Recursively check superclass
        return has_notcreatable_ancestor(superclass, visited)

    for class_name in creatable_classes:
        if has_notcreatable_ancestor(class_name):
            creatable_with_notcreatable_ancestors.append(class_name)

    # Find creatable siblings of NotCreatable classes
    creatable_siblings_of_notcreatable = {}

    # Build a dictionary of parent -> children relationships
    parent_to_children = {}
    for class_name in class_hierarchy:
        parent = class_hierarchy[class_name]["superclass"]
        if parent:
            if parent not in parent_to_children:
                parent_to_children[parent] = []
            parent_to_children[parent].append(class_name)

    # Find parents that have both creatable and NotCreatable children
    for parent_class in parent_to_children:
        if parent_class in ["Instance", "Object"]:
            continue

        children = parent_to_children[parent_class]
        notcreatable_children = [
            child for child in children if child in not_creatable_classes
        ]
        creatable_children = [child for child in children if child in creatable_classes]

        # If parent has both creatable and NotCreatable children
        if notcreatable_children and creatable_children:
            for notcreatable_child in notcreatable_children:
                if notcreatable_child not in creatable_siblings_of_notcreatable:
                    creatable_siblings_of_notcreatable[notcreatable_child] = []
                creatable_siblings_of_notcreatable[notcreatable_child].extend(
                    creatable_children
                )

    # Remove duplicates from sibling lists
    for notcreatable_child in creatable_siblings_of_notcreatable:
        creatable_siblings_of_notcreatable[notcreatable_child] = list(
            set(creatable_siblings_of_notcreatable[notcreatable_child])
        )

    # Second pass: original data collection + NotScriptable type checking
    for api_class in api_classes:
        class_name = api_class["Name"]
        class_members = api_class["Members"]
        class_tags = api_class.get("Tags")

        if class_tags:
            class_tags = array_to_dictionary(class_tags)

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

    s += "\n" + "=" * 50 + "\n"
    s += "NOTCREATABLE INHERITANCE ANALYSIS\n"
    s += "=" * 50 + "\n\n"

    s += f"NotCreatable classes that inherit from creatable classes: {len(not_creatable_with_creatable_ancestors)}\n"
    for class_name in sorted(not_creatable_with_creatable_ancestors):
        chain = []
        current_class = class_name
        while current_class in class_hierarchy:
            chain.append(current_class)
            superclass = class_hierarchy[current_class]["superclass"]
            if not superclass:
                break
            current_class = superclass

        s += f"  - {class_name} (inheritance: {' -> '.join(chain)})\n"

    # ! Useless until there is a NotCreatable class that appears on its own naturally, so a fix using one of it's children (inheritors) should be applied
    # s += f"\nCreatable classes that inherit from NotCreatable classes: {len(creatable_with_notcreatable_ancestors)}\n"
    # for class_name in sorted(creatable_with_notcreatable_ancestors):
    #     chain = []
    #     current_class = class_name
    #     while current_class in class_hierarchy:
    #         chain.append(current_class)
    #         superclass = class_hierarchy[current_class]["superclass"]
    #         if not superclass:
    #             break
    #         current_class = superclass

    #     s += f"  - {class_name} (inheritance: {' -> '.join(chain)})\n"

    s += "\n" + "=" * 50 + "\n"
    s += "CREATABLE SIBLINGS OF NOTCREATABLE CLASSES\n"
    s += "=" * 50 + "\n\n"

    if creatable_siblings_of_notcreatable:
        s += f"NotCreatable classes that have creatable siblings: {len(creatable_siblings_of_notcreatable)}\n"
        for notcreatable_class in sorted(creatable_siblings_of_notcreatable.keys()):
            siblings = creatable_siblings_of_notcreatable[notcreatable_class]
            parent = class_hierarchy[notcreatable_class]["superclass"]
            s += (
                f"  - {notcreatable_class} (parent: {parent}) has creatable siblings:\n"
            )
            for sibling in sorted(siblings):
                s += f"      - {sibling}\n"
    else:
        s += "No NotCreatable classes found with creatable siblings.\n"

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
