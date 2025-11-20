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

    for api_class in api_classes:
        class_name = api_class["Name"]
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

        if (
            class_tags
            and class_tags.get("NotCreatable")
            and not class_tags.get("Service")
            and not "Base" in class_name
            and not "Page" in class_name
            and not "Plugin" in class_name
            and not "Setting" in class_name
        ):
            s += f"{class_name}\n"

        if len(s) != prev_len:
            s += "\n"

        class_list[class_name] = class_info

    return s


if __name__ == "__main__":
    # Check if version hash was passed as a command line argument
    version_hash = sys.argv[1] if len(sys.argv) > 1 else None

    try:
        content = fetch_api(version_hash)
        print(content)

        script_dir = os.path.dirname(os.path.realpath(__file__))
        write_dump_file(content, "Dump", script_dir)

    except Exception as e:
        print(f"Error: {e}")
