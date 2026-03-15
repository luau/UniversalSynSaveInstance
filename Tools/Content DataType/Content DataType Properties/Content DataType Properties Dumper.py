import os, sys

# Find 'common' directory by searching up the tree
p = os.path.dirname(os.path.abspath(__file__))
while p != os.path.dirname(p) and not os.path.exists(os.path.join(p, "common")):
    p = os.path.dirname(p)
sys.path.insert(0, os.path.join(p, "common"))

from dump_utils import write_dump_file, get_api_response

def fetch_api(version_hash=None):
    response, version_hash = get_api_response(version_hash)
    output = f"{version_hash}\n\n"
    for cls in response.json()["Classes"]:
        name = cls["Name"]
        found = False
        for m in cls["Members"]:
            if m["MemberType"] == "Property" and m["ValueType"]["Name"] == "Content":
                output += f"{name}.{m['Name']}\n"
                found = True
        if found: output += "\n"
    return output

if __name__ == "__main__":
    try:
        content = fetch_api(sys.argv[1] if len(sys.argv) > 1 else None)
        print(content)
        write_dump_file(content, "Dump", os.path.dirname(__file__))
    except Exception as e:
        print(f"Error: {e}")