#!/usr/bin/env python3

__author__ = "Remy Prioul"
__version__ = "1.0.0"


from sqlalchemy import create_engine
from pandas import read_json, read_csv, Timestamp
from glob import glob
from pathlib import Path


DATA_DIR_PATTERN = f"{Path(__file__).absolute().parent}/../data/*"


def main():
    # Initiate engine for import into Postgres DB
    engine = create_engine("postgresql://postgres:lkiQbrJJZHond53syDmV@localhost:5432/postgres")

    files_to_load = glob(f"{DATA_DIR_PATTERN}.json") + glob(f"{DATA_DIR_PATTERN}.csv")
    for file in files_to_load:
        df = None
        if Path(file).suffix == ".json":
            df = read_json(file)
        elif Path(file).suffix == ".csv":
            df = read_csv(file)

        if df is not None:
            # Add additional inserted_at column for traceability
            df["_inserted_at"] = Timestamp("now")
            df.to_sql(Path(file).stem, schema="raw_data", con=engine)

    print("Import complete")

if __name__ == "__main__":
    main()
