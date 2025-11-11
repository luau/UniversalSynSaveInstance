import requests
import os
import re


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


def find_first_table(array):
    for item in array:
        if isinstance(item, dict):
            return item
    return None


Class = "Instance"


def check_superclass_inheritance(class_name, class_list):
    current_class = class_list.get(class_name)
    while current_class:
        if current_class["Name"] == Class:
            return True
        current_class = class_list.get(current_class["Superclass"])
    return False


s = "\n"


def api():

    deploy_history_url = "https://setup.rbxcdn.com/DeployHistory.txt"
    deploy_history = requests.get(deploy_history_url).text

    lines = deploy_history.splitlines()

    for line in reversed(lines):

        match = re.search(r"(version-[^\s]+)", line)

        if match:
            version_hash = match.group(1)

            api_dump_url = f"https://setup.rbxcdn.com/{version_hash}-Full-API-Dump.json"

            try:
                response = requests.get(api_dump_url)
                response.raise_for_status()
                return response

            except requests.RequestException as e:
                print(f"Error fetching API dump for {version_hash}: {e}")


def fetch_api():
    response = api()
    api_classes = response.json()["Classes"]
    class_list = {cls["Name"]: cls for cls in api_classes}

    global s
    for api_class in api_classes:
        class_name = api_class["Name"]

        # Check for superclass inheritance
        if not check_superclass_inheritance(class_name, class_list):
            s += f"{class_name} does not inherit from {Class}\n"

        prev_len = len(s)

        if len(s) != prev_len:
            s += "\n"


try:
    fetch_api()
    print(s)
    script_dir = os.path.dirname(os.path.realpath(__file__))
    output_file_path = os.path.join(script_dir, "Dump")
    with open(output_file_path, "w") as file:
        file.write(s)
except Exception as e:
    print(f"Error: {e}")
