import os
import subprocess
import sys


def find_python() -> str:
    """Use the same interpreter that's running this script."""
    return sys.executable or "python"


def run_files(directory: str, script_path: str, vh: str | None = None) -> int:
    base_dir = os.path.normpath(os.path.abspath(directory))
    py_exe = find_python()
    non_py = []
    errors = 0

    for root, _, files in os.walk(directory):
        if os.path.normpath(os.path.abspath(root)) == base_dir:
            continue
        for f in files:
            fp = os.path.join(root, f)
            if f.endswith(".py"):
                if os.path.abspath(fp) == script_path:
                    continue
                print(f"Found: {fp}")
                cmd = [py_exe, fp] + ([vh] if vh else [])
                try:
                    subprocess.run(cmd, check=True)
                    print(f"Executed: {fp}")
                except subprocess.CalledProcessError as e:
                    print(f"Error running {fp}: {e}")
                    errors += 1
                except FileNotFoundError as e:
                    print(f"Could not launch interpreter for {fp}: {e}")
                    errors += 1
            elif f.endswith((".luau", ".lua")):
                non_py.append(fp)

    if non_py:
        print(
            "\n"
            + "=" * 50
            + "\nFiles that couldn't be run (non-Python files):\n"
            + "=" * 50
        )
        for fp in non_py:
            print(f"Could not run: {fp}")
        print(f"Total non-Python files: {len(non_py)}")

    return errors


if __name__ == "__main__":
    d = os.path.dirname(os.path.abspath(__file__))
    vh = sys.argv[1] if len(sys.argv) > 1 else None
    error_count = run_files(d, os.path.abspath(__file__), vh)
    sys.exit(1 if error_count else 0)
