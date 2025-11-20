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
    for api_class in api_classes:
        class_name = api_class["Name"]
        class_members = api_class["Members"]
        prevlen = len(s)

        for member in class_members:
            member_name = member["Name"]
            member_type = member["MemberType"]
            if member_type == "Property":
                serialization = member["Serialization"]

                if serialization["CanLoad"] and serialization["CanSave"]:
                    value_type = member["ValueType"]
                    if (
                        value_type["Category"] == "Class"
                        and value_type["Name"] != "Instance"
                    ):
                        s += f"{class_name}.{member_name} {{{value_type['Name']}}}\n"

        if prevlen != len(s):
            s += "\n"

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
