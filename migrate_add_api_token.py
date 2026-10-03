import sqlite3
import sys
from pathlib import Path


def migrate(db_path):
    db_path = Path(db_path)

    if not db_path.exists():
        raise FileNotFoundError(f"Database not found: {db_path}")

    conn = sqlite3.connect(db_path)

    try:
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS api_token (
                id INTEGER PRIMARY KEY,
                user_id INTEGER NOT NULL,
                token_hash VARCHAR(64) NOT NULL UNIQUE,
                device_name VARCHAR(100),
                created_at DATETIME,
                last_used_at DATETIME,
                expires_at DATETIME,
                is_active INTEGER DEFAULT 1
            )
            """
        )

        conn.execute(
            """
            CREATE INDEX IF NOT EXISTS ix_api_token_user_id
            ON api_token(user_id)
            """
        )

        conn.execute(
            """
            CREATE INDEX IF NOT EXISTS ix_api_token_token_hash
            ON api_token(token_hash)
            """
        )

        conn.commit()

        print("api_token table is ready.")

    finally:
        conn.close()


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python migrate_add_api_token.py <database_path>")
        sys.exit(1)

    migrate(sys.argv[1])
