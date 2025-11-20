import os
import sys


def import_dump_utils():
    """Smart function to find and import dump_utils from common directory"""
    current_dir = os.path.dirname(os.path.abspath(__file__))

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


write_dump_file, get_api_response, array_to_dictionary = import_dump_utils()

datatypes = []
datatypes_set = set()
can_save_tracker = {}
can_load_tracker = {}

all_member_tags = set()
all_capabilities = set()


def extract_capabilities(capabilities_data):
    """Universal method to extract all capability strings from nested structures"""
    capabilities = set()

    if isinstance(capabilities_data, list):
        for item in capabilities_data:
            if isinstance(item, str):
                capabilities.add(item)
            elif isinstance(item, dict):
                # Recursively extract from nested dictionaries
                capabilities.update(extract_capabilities(item))
    elif isinstance(capabilities_data, dict):
        for key, value in capabilities_data.items():
            if isinstance(value, (list, dict)):
                # Recursively extract from nested structures
                capabilities.update(extract_capabilities(value))
            elif isinstance(value, str):
                capabilities.add(value)

    return capabilities


def fetch_api(version_hash=None):
    response, version_hash = get_api_response(version_hash)
    api_data = response.json()
    api_classes = api_data["Classes"]
    api_enums = api_data["Enums"]

    global datatypes, datatypes_set, can_save_tracker, can_load_tracker
    global all_member_tags, all_capabilities

    # Process Classes
    for api_class in api_classes:
        class_members = api_class["Members"]

        for member in class_members:
            member_tags = member.get("Tags")
            if member_tags:
                for tag in member_tags:
                    if isinstance(tag, str):
                        all_member_tags.add(tag)

            member_capabilities = member.get("Capabilities")
            if member_capabilities:
                extracted_caps = extract_capabilities(member_capabilities)
                all_capabilities.update(extracted_caps)

            if member["MemberType"] == "Property":

                serialization = member["Serialization"]
                value_type = member["ValueType"]
                value_type_name = value_type["Name"]
                value_type_cat = value_type["Category"]

                if value_type_cat == "Enum" or value_type_cat == "Class":
                    continue

                # Track CanSave status
                if serialization["CanSave"]:
                    can_save_tracker[value_type_name] = True
                elif value_type_name not in can_save_tracker:
                    can_save_tracker[value_type_name] = False

                # Track CanLoad status
                if serialization["CanLoad"]:
                    can_load_tracker[value_type_name] = True
                elif value_type_name not in can_load_tracker:
                    can_load_tracker[value_type_name] = False

                if value_type_name not in datatypes_set:
                    datatypes_set.add(value_type_name)
                    datatypes.append(value_type_name)

    # Process Enums - look for SecurityCapability
    for api_enum in api_enums:
        if api_enum["Name"] == "SecurityCapability":
            items = api_enum["Items"]
            for item in items:
                capability_name = item["Name"]
                all_capabilities.add(capability_name)
            break  # Found SecurityCapability, no need to continue

    return version_hash


if __name__ == "__main__":
    version_hash = sys.argv[1] if len(sys.argv) > 1 else None

    try:
        version_hash = fetch_api(version_hash)
        datatypes.sort()

        output_lines = []

        output_lines.append("=== DATATYPES ===")
        for value_type in datatypes:
            can_save_status = can_save_tracker.get(value_type, False)
            can_load_status = can_load_tracker.get(value_type, False)

            verdict_text = ""
            if (can_save_status and not can_load_status) or (
                can_load_status and not can_save_status
            ):
                verdict_text = "-> Probably has a descriptor"

            parts = [value_type]
            if can_save_status:
                parts.append("{CanSave}")
            if can_load_status:
                parts.append("{CanLoad}")
            parts.append(verdict_text)
            output_lines.append(" ".join(parts).strip())

        output_lines.append("")

        output_lines.append("=== MEMBER TAGS ===")
        output_lines.append(f"Total unique tags: {len(all_member_tags)}")
        sorted_tags = sorted(list(all_member_tags))

        for tag in sorted_tags:
            output_lines.append(f"  {tag}")

        output_lines.append("")

        output_lines.append("=== CAPABILITIES ===")
        output_lines.append(f"Total unique capabilities: {len(all_capabilities)}")
        sorted_capabilities = sorted(list(all_capabilities))

        for capability in sorted_capabilities:
            output_lines.append(f"  {capability}")

        content_body = "\n".join(output_lines) + "\n"
        full_content = version_hash + "\n\n" + content_body

        print(content_body)

        script_dir = os.path.dirname(os.path.realpath(__file__))
        write_dump_file(full_content, "Dump", script_dir)

    except Exception as e:
        print(f"Error: {e}")
        import traceback

        traceback.print_exc()
