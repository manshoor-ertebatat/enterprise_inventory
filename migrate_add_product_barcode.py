import sqlite3
import sys
from pathlib import Path


INDEX_NAME = "ux_product_barcode"


def migrate(db_path):
    db_path = Path(db_path)

    if not db_path.exists():
        raise FileNotFoundError(f"Database not found: {db_path}")

    conn = sqlite3.connect(db_path)

    try:
        columns = {
            row[1]
            for row in conn.execute("PRAGMA table_info(product)").fetchall()
        }

        if "barcode" not in columns:
            conn.execute(
                "ALTER TABLE product ADD COLUMN barcode VARCHAR(100)"
            )
            print("barcode column added successfully.")
        else:
            print("barcode column already exists.")

        conn.execute(
            f"""
            CREATE UNIQUE INDEX IF NOT EXISTS {INDEX_NAME}
            ON product(barcode)
            WHERE barcode IS NOT NULL
            """
        )

        conn.commit()
        print(f"Unique index '{INDEX_NAME}' is ready.")

    finally:
        conn.close()


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python migrate_add_product_barcode.py <database_path>")
        sys.exit(1)

    migrate(sys.argv[1])
