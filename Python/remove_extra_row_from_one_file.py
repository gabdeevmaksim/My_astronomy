import pyarrow as pa
import pyarrow.csv as pc
import pandas as pd

def find_and_remove_extra_row_csv(file_paths):
    """
    Finds and removes the extra row from the CSV file that has one more row 
    than the others, based on comparing the last 8 columns.

    Args:
        file_paths: A list of paths to the four CSV files.

    Returns:
        None. Modifies the file with the extra row in place.

    # Example usage (replace with your actual file paths):
    file_paths = [
        "file1.csv",
        "file2.csv",
        "file3.csv",
        "file4.csv",
    ]

    find_and_remove_extra_row_csv(file_paths)
    """

    if len(file_paths) != 4:
        raise ValueError("Exactly four file paths are required.")

    dfs = []
    row_counts = []

    # 1. Read files, get row counts, and identify the file with an extra row
    for file_path in file_paths:
        table = pc.read_csv(file_path)
        column_names = table.column_names
        last_8_cols = column_names[-8:]
        df = table.select(last_8_cols).to_pandas()
        dfs.append(df)
        row_counts.append(table.num_rows)

    min_rows = min(row_counts)
    extra_row_file_index = None
    for i, count in enumerate(row_counts):
        if count > min_rows:
            if extra_row_file_index is not None:
                raise ValueError("More than one file has extra rows.")
            extra_row_file_index = i

    if extra_row_file_index is None:
        print("All files have the same number of rows. No row removed.")
        return

    # 2. Combine last 8 columns for comparison
    for i, df in enumerate(dfs):
        dfs[i]['combined'] = df.apply(lambda row: '_'.join(row.astype(str)), axis=1)

    # 3. Find the combination that is NOT present in other files
    extra_row_file_path = file_paths[extra_row_file_index]
    extra_row_df = dfs[extra_row_file_index]
    other_files_combinations = set()
    for i, df in enumerate(dfs):
        if i != extra_row_file_index:
            other_files_combinations.update(df['combined'])

    row_to_remove_combined = None
    for combined_value in extra_row_df['combined']:
        if combined_value not in other_files_combinations:
            if row_to_remove_combined is not None:
              print("Warning: More than one extra row found based on last 8 columns. Removing only the first one.")
              break
            row_to_remove_combined = combined_value

    if row_to_remove_combined is None:
        print("Could not identify the extra row based on the last 8 columns.")
        return

    # 4. Remove the extra row and overwrite the file
    
    # Read the entire table
    full_table = pc.read_csv(extra_row_file_path)

    # Convert to Pandas DataFrame
    full_df = full_table.to_pandas()
    
    # Find the index of the row to remove in the full DataFrame
    row_to_remove_index = full_df[full_df.iloc[:, -8:].apply(lambda row: '_'.join(row.astype(str)), axis=1) == row_to_remove_combined].index

    if not row_to_remove_index.empty:
      # Remove the identified row
      updated_df = full_df.drop(row_to_remove_index)

      # Overwrite the original file
      updated_df.to_csv(extra_row_file_path, index=False)
      print(f"Removed extra row from: {extra_row_file_path}")
    else:
      print(f"Could not find row to remove in {extra_row_file_path}")

# Example usage (replace with your actual file paths):
file_paths = [
    "/Users/wera/Max_astro/Slovakia/elisa_on_a_server/dataset/detached_nospots_period(0.01-1)_1000000_g.csv",
    "/Users/wera/Max_astro/Slovakia/elisa_on_a_server/dataset/detached_nospots_period(0.01-1)_1000000_gaia.csv",
    "/Users/wera/Max_astro/Slovakia/elisa_on_a_server/dataset/detached_nospots_period(0.01-1)_1000000_I.csv",
    "/Users/wera/Max_astro/Slovakia/elisa_on_a_server/dataset/detached_nospots_period(0.01-1)_1000000_V.csv",
]

find_and_remove_extra_row_csv(file_paths)