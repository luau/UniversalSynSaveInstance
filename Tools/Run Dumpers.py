import os
import subprocess
import sys


def run_python_files_in_directories(directory, script_name, version_hash=None):
    non_python_files = []

    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".py"):
                file_path = os.path.join(root, file)

                if os.path.abspath(file_path) == script_name:
                    continue
                print(f"Found Python file: {file_path}")
                try:
                    if version_hash:
                        subprocess.run(["python", file_path, version_hash], check=True)
                    else:
                        subprocess.run(["python", file_path], check=True)
                    print(f"Executed: {file_path}")
                except subprocess.CalledProcessError as e:
                    print(f"Error running {file_path}: {e}")
            elif file.endswith(".luau") or file.endswith(".lua"):
                _, ext = os.path.splitext(file)
                if ext and ext.lower() != ".py":
                    file_path = os.path.join(root, file)
                    if os.path.abspath(file_path) != script_name:
                        non_python_files.append(file_path)

    if non_python_files:
        print("\n" + "=" * 50)
        print("Files that couldn't be run (non-Python files):")
        print("=" * 50)
        for file_path in non_python_files:
            print(f"Could not run: {file_path}")
        print(f"Total non-Python files: {len(non_python_files)}")


if __name__ == "__main__":
    current_directory = os.path.dirname(os.path.abspath(__file__))
    script_name = os.path.abspath(__file__)

    # Check if version hash was passed as a command line argument
    version_hash = None
    if len(sys.argv) > 1:
        version_hash = sys.argv[1]

    run_python_files_in_directories(current_directory, script_name, version_hash)
