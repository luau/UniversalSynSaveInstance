import os
import subprocess
import sys

def run_python_files_in_directories(directory, script_name, version_hash=None):
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

if __name__ == "__main__":
    current_directory = os.path.dirname(os.path.abspath(__file__))
    script_name = os.path.abspath(__file__)
    
    # Check if version hash was passed as a command line argument
    version_hash = None
    if len(sys.argv) > 1:
        version_hash = sys.argv[1]
    
    run_python_files_in_directories(current_directory, script_name, version_hash)