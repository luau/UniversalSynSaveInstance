# common/dump_utils.py
import os
import sys
import requests
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


def should_write_file(output_file_path, new_content):
    if not os.path.exists(output_file_path):
        return True, "File doesn't exist, writing new file."

    with open(output_file_path, "r") as file:
        existing_content = file.read()

    existing_lines = existing_content.splitlines()
    current_lines = new_content.splitlines()

    if len(existing_lines) > 0 and len(current_lines) > 0:
        existing_rest = "\n".join(existing_lines[1:])
        current_rest = "\n".join(current_lines[1:])

        if existing_rest == current_rest:
            return (
                False,
                f"Only version hash changed ({current_lines[0]} -> {existing_lines[0]}), skipping file write.",
            )
        else:
            return True, "API content has changed, writing to file."

    return True, "File structure differs, writing to file."


def write_dump_file(content, filename="Dump", script_dir=None):
    if script_dir is None:
        script_dir = os.path.dirname(os.path.realpath(__file__))

    output_file_path = os.path.join(script_dir, filename)

    should_write, message = should_write_file(output_file_path, content)
    print(message)

    if should_write:
        with open(output_file_path, "w") as file:
            file.write(content)

    return should_write


def get_api_response(version_hash=None):
    if version_hash:
        api_dump_url = f"https://setup.rbxcdn.com/{version_hash}-Full-API-Dump.json"
        try:
            response = requests.get(api_dump_url)
            response.raise_for_status()
            return response, version_hash
        except requests.RequestException as e:
            print(f"Error fetching API dump for {version_hash}: {e}")
            sys.exit(1)
    else:
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
