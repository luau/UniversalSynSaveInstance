import requests, os


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
    api_classes = response.json()['Classes']

    global s
    for api_class in api_classes:
        class_name = api_class['Name']
        class_members = api_class['Members']
        prevlen = len(s)
        for member in class_members:
            member_name = member['Name']
            member_type = member['MemberType']
            if member_type == "Property":
                serialization = member['Serialization']

                if serialization['CanLoad'] and serialization['CanSave']:
                    value_type = member['ValueType']
                    if value_type['Category'] == "Class" and value_type['Name'] != "Instance":
                        s += f"{class_name}.{member_name} {{{value_type['Name']}}}\n"
        if prevlen != len(s):
            s +="\n"

try:
    fetch_api()
    print(s)
    script_dir = os.path.dirname(os.path.realpath(__file__))
    output_file_path = os.path.join(script_dir, "Dump")
    with open(output_file_path, "w") as file:
        file.write(s)
except Exception as e:
    print(f"Error: {e}")
