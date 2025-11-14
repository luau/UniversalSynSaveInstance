import requests
import os
import re
import sys


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


s = "\n"


def api(version_hash=None):
    if version_hash:
        # Use the provided version hash
        api_dump_url = f"https://setup.rbxcdn.com/{version_hash}-Full-API-Dump.json"
        try:
            response = requests.get(api_dump_url)
            response.raise_for_status()
            return response
        except requests.RequestException as e:
            print(f"Error fetching API dump for {version_hash}: {e}")
            sys.exit(1)
    else:
        # Fall back to the original method of finding the latest version
        deploy_history_url = "https://setup.rbxcdn.com/DeployHistory.txt"
        deploy_history = requests.get(deploy_history_url).text

        lines = deploy_history.splitlines()

        for line in reversed(lines):
            match = re.search(r"(version-[^\s]+)", line)
            if match:
                version_hash = match.group(1)
                api_dump_url = (
                    f"https://setup.rbxcdn.com/{version_hash}-Full-API-Dump.json"
                )
                try:
                    response = requests.get(api_dump_url)
                    response.raise_for_status()
                    return response, version_hash
                except requests.RequestException as e:
                    print(f"Error fetching API dump for {version_hash}: {e}")


def fetch_api(version_hash=None):
    response, version_hash = api(version_hash)
    api_classes = response.json()["Classes"]

    global s
    s = version_hash + "\n\n"
    class_list = {}

    for api_class in api_classes:
        class_name = api_class["Name"]
        class_tags = api_class.get("Tags")

        if class_tags:
            # print(class_tags)
            if len(class_tags) == 0:
                print("tagsempty")
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

    return class_list


if __name__ == "__main__":
    # Check if version hash was passed as a command line argument
    version_hash = None
    if len(sys.argv) > 1:
        version_hash = sys.argv[1]

    try:
        fetch_api(version_hash)
        print(s)
        script_dir = os.path.dirname(os.path.realpath(__file__))
        output_file_path = os.path.join(script_dir, "Dump")
        with open(output_file_path, "w") as file:
            file.write(s)
    except Exception as e:
        print(f"Error: {e}")
