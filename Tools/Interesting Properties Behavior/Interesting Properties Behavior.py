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
        class_members = api_class["Members"]
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

        for member in class_members:
            if member["MemberType"] == "Property":
                property_name = member["Name"]
                ignored = False

                if not ignored:
                    member_tags = member.get("Tags")

                    if member_tags:
                        member_tags = array_to_dictionary(member_tags)

                    serialization = member["Serialization"]
                    if serialization["CanLoad"]:
                        if not serialization["CanSave"]:
                            s += f"{class_name}.{property_name} {{CanLoad Only}}\n"
                        if member_tags and member_tags.get("Deprecated"):
                            s += f"{class_name}.{property_name} {{Deprecated}} {  ' {CanSave}' if serialization['CanSave']  else ''}\n"
                    elif serialization["CanSave"]:
                        s += f"{class_name}.{property_name} {{CanSave Only}}\n"

                    class_info["Properties"][property_name] = {
                        "Serialization": serialization,
                        "Tags": member_tags,
                        "Default": member.get("Default"),
                    }

        if class_tags and class_tags.get("NotCreatable"):
            for property_name, property_info in class_info["Properties"].items():
                value = property_info.get("Default")
                if value != "__api_dump_class_not_creatable__":
                    s += f"{class_name} is NotCreatable but {class_name}.{property_name} has a default value: {value}\n"
                    break

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
