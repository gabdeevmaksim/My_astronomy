import pyarrow as pa
import pyarrow.csv as pc
import pandas as pd

def analyze_csv_files(file_paths):
    """
    Analyzes multiple CSV files to check the number of rows and the number of 
    equal combinations in the last 8 columns.

    Args:
        file_paths: A list of paths to the CSV files.

    Returns:
        None. Prints the analysis results to the console.

    # Example usage (replace with your actual file paths):
    file_paths = [
        "file1.csv",
        "file2.csv",
        "file3.csv",
        "file4.csv",
    ]

    analyze_csv_files(file_paths)
    """

    if len(file_paths) != 4:
        raise ValueError("Exactly four file paths are required.")

    dfs = []
    row_counts = []

    for file_path in file_paths:
        # Read the CSV file using PyArrow
        table = pc.read_csv(file_path)
        column_names = table.column_names
        last_8_cols = column_names[-8:]

        # Convert the last 8 columns to a Pandas DataFrame
        df = table.select(last_8_cols).to_pandas()
        dfs.append(df)

        # Get the number of rows
        num_rows = table.num_rows
        row_counts.append(num_rows)

        print(f"File: {file_path}")
        print(f"  Number of rows: {num_rows}")

    # Find combinations of last 8 columns that appear in all files
    
    # Combine last 8 columns into a single string for easier comparison
    for i, df in enumerate(dfs):
        dfs[i]['combined'] = df.apply(lambda row: '_'.join(row.astype(str)), axis=1)

    # Find common combinations across all files
    common_combinations = set(dfs[0]['combined'])
    for df in dfs[1:]:
        common_combinations.intersection_update(set(df['combined']))

    print(f"Number of equal combinations (in all 4 files): {len(common_combinations)}")

# Example usage (replace with your actual file paths):
file_paths = [
    "/Users/wera/Max_astro/Slovakia/elisa_on_a_server/dataset/detached_nospots_period(1.01-2)_1000000_g.csv",
    "/Users/wera/Max_astro/Slovakia/elisa_on_a_server/dataset/detached_nospots_period(1.01-2)_1000000_gaia.csv",
    "/Users/wera/Max_astro/Slovakia/elisa_on_a_server/dataset/detached_nospots_period(1.01-2)_1000000_I.csv",
    "/Users/wera/Max_astro/Slovakia/elisa_on_a_server/dataset/detached_nospots_period(1.01-2)_1000000_V.csv",
]

analyze_csv_files(file_paths)