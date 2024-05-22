import os
import subprocess

def lint_sql_file(file_path, dialect='mysql'):
    try:
        print(f"Linting {file_path}...")
        subprocess.run(['sqlfluff', 'lint', file_path, '--dialect', dialect], check=True)
        print(f"{file_path} linted successfully!")
    except subprocess.CalledProcessError as e:
        print(f"Error linting {file_path}: {e}")

if __name__ == "__main__":
    sql_directory = '.'
    for root, dirs, files in os.walk(sql_directory):
        for file in files:
            if file.endswith('.sql'):
                file_path = os.path.join(root, file)
                lint_sql_file(file_path)
