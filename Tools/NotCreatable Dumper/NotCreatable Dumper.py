import requests
import os


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


def fetch_api():
    api_dump_url = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/Mini-API-Dump.json"
    response = requests.get(api_dump_url)
    api_classes = response.json()["Classes"]

    global s
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


try:
    fetch_api()
    print(s)
    script_dir = os.path.dirname(os.path.realpath(__file__))
    output_file_path = os.path.join(script_dir, "Dump")
    with open(output_file_path, "w") as file:
        file.write(s)
except Exception as e:
    print(f"Error: {e}")
