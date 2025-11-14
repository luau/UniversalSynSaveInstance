import requests
import os
import re


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
                return response, version_hash

            except requests.RequestException as e:
                print(f"Error fetching API dump for {version_hash}: {e}")


def fetch_api():
    response, version_hash = api()
    api_classes = response.json()["Classes"]

    output = version_hash + "\n\n"

    for api_class in api_classes:
        class_name = api_class["Name"]
        class_members = api_class["Members"]
        prev_len = len(output)
        for member in class_members:
            member_name = member["Name"]
            member_type = member["MemberType"]

            if member_type == "Property":
                serialization = member["Serialization"]
                value_type = member["ValueType"]["Name"]

                # Check if ValueType is "Content" and both CanSave and CanLoad are true
                if (
                    value_type == "Content"
                    and serialization["CanLoad"]
                    and serialization["CanSave"]
                ):

                    output += f"{class_name}.{member_name}\n"

        if len(output) != prev_len:
            output += "\n"

    return output


try:
    result = fetch_api()
    print(result)
    script_dir = os.path.dirname(os.path.realpath(__file__))
    output_file_path = os.path.join(script_dir, "Dump")
    with open(output_file_path, "w") as file:
        file.write(result)
except Exception as e:
    print(f"Error: {e}")
