"""
===============================================================================
Project: Olist Brazilian E-commerce Data Warehouse & Analytics
File: csv_reader.py

Description:
    Reads CSV files from the source folder and returns a pandas DataFrame.
===============================================================================
"""

from pathlib import Path

import pandas as pd

from olist_dw.config import SOURCE_FOLDER


def read_csv(file_name: str) -> pd.DataFrame:

    file_path = SOURCE_FOLDER / file_name

    if not file_path.exists():
        raise FileNotFoundError(f"Source file not found: {file_path}")

    dataframe = pd.read_csv(
    file_path,
    dtype=str
)

    # Convert blank/whitespace strings to None
    dataframe = dataframe.replace(r'^\s*$', None, regex=True)

    return dataframe