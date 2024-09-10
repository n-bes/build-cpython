import duckdb
import glob
import sys
import re

create_table_sql = """
    CREATE TABLE sarif_data (
        build_id TEXT NOT NULL, 
        python_version TEXT NOT NULL,  
        file_path TEXT NOT NULL,
        file_content JSON NOT NULL
    );
"""

insert_data_pattern = """
    INSERT INTO sarif_data (build_id, python_version, file_path, file_content)
    VALUES (?,?,?,?);
"""

if __name__ == '__main__':
    if len(sys.argv) < 3:
        exit(f"usage: {sys.argv[0]} <path to .sarif> <path to .db>")

    path_to_files = sys.argv[1]
    path_to_db = sys.argv[2]
    files = glob.glob(f'{path_to_files}/**/*.sarif', recursive=True)
    if len(files) == 0:
        exit(f".sarif files not found. usage: {sys.argv[0]} <path>")

    with duckdb.connect(path_to_db) as con:
        con.sql(create_table_sql)
        for file in files:
            result = re.match(".*/build_(\\d+)/sarif-data/src/(Python-[a-zA-Z0-9_.]+)/(.*)", file)
            if result:
                with open(file, 'r') as f:
                    content = f.read()
                    params = [result[1], result[2], result[3], content]
                    print(result[1])
                    con.sql(insert_data_pattern, params=params)