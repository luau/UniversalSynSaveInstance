import os
import sys
import re


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
                from dump_utils import write_dump_file, get_api_response

                print(f"Found dump_utils at: {common_path}")
                return write_dump_file, get_api_response
            except ImportError as e:
                print(f"Failed to import from {common_path}: {e}")
                break

        parent_dir = os.path.dirname(search_dir)
        if parent_dir == search_dir:
            break
        search_dir = parent_dir

    raise ImportError("Could not find common/dump_utils.py in any parent directory")


write_dump_file, get_api_response = import_dump_utils()


def fetch_content_properties(version_hash=None):
    """
    Fetch v2 API dump and filter for properties with:
    - ValueType.Name == "Content"
    - defaultValue exists in ValueType
    """
    response, version_hash = get_api_response(version_hash, api_version="v2")

    api_classes = response.json()

    output = f"{version_hash}\n\n"
    found_count = 0

    for api_class in api_classes:
        class_name = api_class.get("Name", "UnknownClass")
        class_members = api_class.get("Members", [])
        class_start_len = len(output)

        for member in class_members:
            member_name = member.get("Name")
            member_type = member.get("MemberType")

            if member_type != "Property":
                continue

            value_type = member.get("ValueType", {})
            if not isinstance(value_type, dict):
                continue

            if value_type.get("Name") != "Content":
                continue

            defaultValue = value_type.get("defaultValue")
            if not defaultValue:
                continue
            defaultValue = re.sub(r"\s+", "", defaultValue)
            security = member.get("Security", "None")
            tags = member.get("Tags", [])

            output += f"{class_name}.{member_name}"

            # output += f" {{defaultValue: {defaultValue}}}"

            if security != "None":
                output += f" {{Security: {security}}}"

            # if tags:
            #     output += f" {{Tags: {', '.join(tags)}}}"

            output += "\n"
            found_count += 1

        if len(output) > class_start_len:
            output += "\n"

    output += (
        f"\n---\nTotal Content properties with defaultValue found: {found_count}\n"
    )
    return output


if __name__ == "__main__":
    version_hash = sys.argv[1] if len(sys.argv) > 1 else None

    try:
        content = fetch_content_properties(version_hash)
        print(content)

        script_dir = os.path.dirname(os.path.realpath(__file__))
        write_dump_file(content, "Dump", script_dir)

    except Exception as e:
        print(f"Error: {e}")
        import traceback

        traceback.print_exc()
        sys.exit(1)
