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


datatypes = []
datatypes_set = set()


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

    global datatypes
    global datatypes_set

    for api_class in api_classes:
        class_members = api_class["Members"]

        for member in class_members:
            if member["MemberType"] == "Property":
                ignored = False

                if not ignored:
                    member_tags = member.get("Tags")

                    if member_tags:
                        member_tags = array_to_dictionary(member_tags)

                    serialization = member["Serialization"]
                    if serialization["CanLoad"] :
                        value_type = member["ValueType"]
                        value_type_name = value_type["Name"]
                        value_type_cat = value_type["Category"]
                        if value_type_cat == "Enum":
                            value_type_name = "Enum"
                        if value_type_cat == "Class":
                            value_type_name = "Class"
                        if value_type_name not in datatypes_set:
                            datatypes_set.add(value_type_name)
                            datatypes.append(value_type_name)


try:
    fetch_api()
    datatypes.sort()
    s = "\n".join(datatypes) + "\n"
    print(s)
    script_dir = os.path.dirname(os.path.realpath(__file__))
    output_file_path = os.path.join(script_dir, "Dump")
    with open(output_file_path, "w") as file:
        file.write(s)
except Exception as e:
    print(f"Error: {e}")
