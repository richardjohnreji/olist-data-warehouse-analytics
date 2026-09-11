"""
===============================================================================
Project: Olist Brazilian E-commerce Data Warehouse & Analytics
File: bronze_loader.py

Description:
    Main ETL orchestrator for loading the Olist datasets into the Bronze layer.
===============================================================================
"""

from olist_dw.config import SOURCE_FILES
from olist_dw.database import get_connection
from olist_dw.utils.logger import get_logger
from olist_dw.utils.csv_reader import read_csv
from olist_dw.utils.database_loader import load_dataframe


def load_bronze():
    """
    Executes the Bronze ETL process.

    Workflow:
        1. Connect to SQL Server.
        2. Read each source CSV.
        3. Load data into Bronze tables.
        4. Log successes and failures.
        5. Close the database connection.
    """

    logger = get_logger("BronzeETL")

    logger.info("Starting Bronze ETL process.")

    successful_tables = []
    failed_tables = []

    connection = None

    try:
        # ---------------------------------------------------------------------
        # Connect to SQL Server
        # ---------------------------------------------------------------------
        connection = get_connection()
        logger.info("Connected to SQL Server.")

        # ---------------------------------------------------------------------
        # Process each dataset
        # ---------------------------------------------------------------------
        for dataset_name, dataset_info in SOURCE_FILES.items():

            file_name = dataset_info["file"]
            table_name = dataset_info["table"]

            try:
                logger.info(f"Processing table: {table_name}")
                logger.info(f"Source file: {file_name}")

                # Read CSV
                dataframe = read_csv(file_name)

                logger.info(
                    f"Successfully read '{file_name}' "
                    f"({len(dataframe):,} rows × {len(dataframe.columns)} columns)."
                )

                # Load into Bronze table
                rows_loaded = load_dataframe(
                    connection=connection,
                    dataframe=dataframe,
                    table_name=table_name
                )

                logger.info(
                    f"Loaded {rows_loaded:,} rows into bronze.{table_name}."
                )

                successful_tables.append(table_name)

            except Exception as error:

                logger.error(
                    f"Failed to process table '{table_name}': {error}"
                )

                failed_tables.append(table_name)

                # Continue with the next dataset
                continue

        logger.info("Bronze ETL process finished.")

    except Exception as error:

        logger.error(f"Bronze ETL failed: {error}")

    finally:

        if connection:
            connection.close()
            logger.info("Database connection closed.")

    # -------------------------------------------------------------------------
    # Execution Summary
    # -------------------------------------------------------------------------
    logger.info("=" * 60)
    logger.info("Bronze ETL Summary")
    logger.info("=" * 60)

    logger.info(f"Total Datasets : {len(SOURCE_FILES)}")
    logger.info(f"Successful     : {len(successful_tables)}")
    logger.info(f"Failed         : {len(failed_tables)}")

    if successful_tables:
        logger.info("Successful Tables:")
        for table in successful_tables:
            logger.info(f"  [OK] {table}")

    if failed_tables:
        logger.info("Failed Tables:")
        for table in failed_tables:
            logger.info(f"  [FAILED] {table}")

    logger.info("=" * 60)


if __name__ == "__main__":
    load_bronze()