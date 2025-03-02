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


s = "\n"
filtered_properties = []


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

    global s, filtered_properties
    for api_class in api_classes:
        class_name = api_class["Name"]
        class_members = api_class["Members"]

        prev_len = len(s)
        enum_members = {}

        for member in class_members:
            member_name = member["Name"]
            member_type = member["MemberType"]
            if member_type == "Property":
                serialization = member["Serialization"]
                member_tags = member.get("Tags")
                original_tags = member_tags
                special = False
                if member_tags:
                    member_tags = array_to_dictionary(member_tags)
                    special = member_tags.get("NotScriptable")

                if serialization["CanLoad"] and serialization["CanSave"] and special:
                    value_type = member["ValueType"]["Name"]
                    value_category = member["ValueType"]["Category"]
                    if value_category == "Enum":
                        enum_members[value_type] = member_name
                    s += f"{class_name}.{member_name} {{{value_type}}}"
                    for item in original_tags:
                        if isinstance(item, dict):

                            s += f"{'{PreferredDescriptorName: '+item.get('PreferredDescriptorName')+'}'}"
                    s += "\n"

                if re.search(
                    r"xml|internal|serial|replica", member_name, re.IGNORECASE
                ):

                    str = f"{class_name}.{member_name}"
                    if not special:
                        str += " {Scriptable}"
                    if not (
                        serialization.get("CanLoad", True)
                        and serialization.get("CanSave", True)
                    ):
                        str += " {Serialize: False}"

                    filtered_properties.append(str)

        for enum_type, real_member_name in enum_members.items():
            for member in class_members:
                member_name = member["Name"]
                member_type = member["MemberType"]
                if member_name != real_member_name and member_type == "Property":
                    value_category = member["ValueType"]["Category"]
                    if value_category == "Enum":
                        value_type = member["ValueType"]["Name"]
                        if value_type == enum_type:
                            s += f"{real_member_name} -> {member_name}\n"

        if len(s) != prev_len:
            s += "\n"

    if filtered_properties:
        s += "\nPotential Proxy Properties:\n"
        s += "\n".join(filtered_properties) + "\n"


try:
    fetch_api()
    print(s)
    script_dir = os.path.dirname(os.path.realpath(__file__))
    output_file_path = os.path.join(script_dir, "Dump")
    with open(output_file_path, "w") as file:
        file.write(s)
except Exception as e:
    print(f"Error: {e}")
