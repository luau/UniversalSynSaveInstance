import os, subprocess, sys

def run_files(directory, script_name, vh=None):
    non_py = []
    for root, _, files in os.walk(directory):
        for f in files:
            fp = os.path.join(root, f)
            if f.endswith(".py"):
                if os.path.abspath(fp) == script_name: continue
                print(f"Found: {fp}")
                try:
                    cmd = ["python", fp, vh] if vh else ["python", fp]
                    subprocess.run(cmd, check=True)
                    print(f"Executed: {fp}")
                except subprocess.CalledProcessError as e:
                    print(f"Error running {fp}: {e}")
            elif f.endswith((".luau", ".lua")):
                if os.path.abspath(fp) != script_name:
                    non_py.append(fp)
    if non_py:
        print("\n" + "=" * 50)
        print("Files that couldn't be run (non-Python files):")
        print("=" * 50)
        for fp in non_py: print(f"Could not run: {fp}")
        print(f"Total non-Python files: {len(non_py)}")

if __name__ == "__main__":
    d = os.path.dirname(os.path.abspath(__file__))
    sn = os.path.abspath(__file__)
    vh = sys.argv[1] if len(sys.argv) > 1 else None
    run_files(d, sn, vh)