import pyarrow as pa
import pyarrow.csv as pc
import pandas as pd

def find_and_remove_extra_rows_csv(file_paths):
    """
    Finds and removes rows from CSV files to ensure they have the same number of rows
    and identical values in the last 8 columns for matching rows.

    Args:
        file_paths: A list of paths to the four CSV files.

    Returns:
        None. Modifies the files in place.

    Example usage (replace with your actual file paths):
    file_paths = [
    "file1.csv",
    "file2.csv",
    "file3.csv",
    "file4.csv",
]

find_and_remove_extra_rows_csv(file_paths)
    """

    if len(file_paths) != 4:
        raise ValueError("Exactly four file paths are required.")

    # 1. Read the last 8 columns of each file into Pandas DataFrames
    dfs = []
    for file_path in file_paths:
        table = pc.read_csv(file_path)
        column_names = table.column_names
        last_8_cols = column_names[-8:]
        df = table.select(last_8_cols).to_pandas()
        dfs.append(df)

    # 2. Find the number of rows in each file
    row_counts = [len(df) for df in dfs]
    min_rows = min(row_counts)
    
    # 3. Identify the file with an extra row (if any)
    extra_row_file_index = None
    if len(set(row_counts)) > 1:
      for i, count in enumerate(row_counts):
          if count != min_rows:
              extra_row_file_index = i
              break

    # 4. Find combinations of last 8 columns that appear in only 3 files
    if extra_row_file_index is not None:
        # Combine last 8 columns into a single string for easier comparison
        for i, df in enumerate(dfs):
            dfs[i]['combined'] = df.apply(lambda row: '_'.join(row.astype(str)), axis=1)

        # Count occurrences of each combination across all files
        all_combinations = pd.concat([df['combined'] for df in dfs])
        combination_counts = all_combinations.value_counts()

        # Identify combinations that appear exactly 3 times
        combinations_to_remove = combination_counts[combination_counts == 3].index

        # 5. Remove the extra row from the identified file(s)
        for i, df in enumerate(dfs):
            if i != extra_row_file_index:
                rows_to_remove = df[df['combined'].isin(combinations_to_remove)].index
                if not rows_to_remove.empty:
                    
                    # Read the entire table
                    full_table = pc.read_csv(file_paths[i])

                    # Convert to Pandas DataFrame
                    full_df = full_table.to_pandas()

                    # Remove identified row(s)
                    updated_df = full_df.drop(rows_to_remove)

                    # Overwrite the original file (using Pandas to_csv)
                    updated_df.to_csv(file_paths[i], index=False)
                    print(f"Removed {len(rows_to_remove)} row(s) from {file_paths[i]}")

    # 6. Verify that all files now have the same number of rows and matching last 8 columns
    updated_row_counts = []
    for i, file_path in enumerate(file_paths):
        table = pc.read_csv(file_path)
        updated_row_counts.append(table.num_rows)

    if len(set(updated_row_counts)) == 1:
        print("All files now have the same number of rows.")
        
        for i in range(len(file_paths)):
          for j in range(i+1,len(file_paths)):
            table1 = pc.read_csv(file_paths[i]).select(table.column_names[-8:])
            table2 = pc.read_csv(file_paths[j]).select(table.column_names[-8:])
            
            df1 = table1.to_pandas().sort_index()
            df2 = table2.to_pandas().sort_index()

            if df1.equals(df2):
              print(f"Last 8 columns of files {file_paths[i]} and {file_paths[j]} are equal")
            else:
              print(f"Last 8 columns of files {file_paths[i]} and {file_paths[j]} are NOT fully equal after row removal.")
    else:
        print("Error: Files do not have the same number of rows after processing.")


# Example usage (replace with your actual file paths):
file_paths = [
    "/Users/wera/Max_astro/Slovakia/elisa_on_a_server/dataset/detached_nospots_period(0.01-1)_1000000_g.csv",
    "/Users/wera/Max_astro/Slovakia/elisa_on_a_server/dataset/detached_nospots_period(0.01-1)_1000000_gaia.csv",
    "/Users/wera/Max_astro/Slovakia/elisa_on_a_server/dataset/detached_nospots_period(0.01-1)_1000000_I.csv",
    "/Users/wera/Max_astro/Slovakia/elisa_on_a_server/dataset/detached_nospots_period(0.01-1)_1000000_V.csv",
]

find_and_remove_extra_rows_csv(file_paths)