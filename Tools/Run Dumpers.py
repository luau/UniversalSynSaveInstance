import os
import subprocess


def run_python_files_in_directories(directory, script_name):

    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".py"):
                file_path = os.path.join(root, file)

                if os.path.abspath(file_path) == script_name:
                    continue
                print(f"Found Python file: {file_path}")
                try:

                    subprocess.run(["python", file_path], check=True)
                    print(f"Executed: {file_path}")
                except subprocess.CalledProcessError as e:
                    print(f"Error running {file_path}: {e}")


current_directory = os.path.dirname(os.path.abspath(__file__))


script_name = os.path.abspath(__file__)


run_python_files_in_directories(current_directory, script_name)
