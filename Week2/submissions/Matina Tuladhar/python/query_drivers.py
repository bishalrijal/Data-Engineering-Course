"""
query_drivers.py
----------------
Week 2 Assignment — Python + PostgreSQL

Your task: complete each function marked with TODO.
Run the script when done:  python query_drivers.py

Expected output:
    Driver                    Completed Rides
    ------------------------------------------
    Alice Johnson                          12
    Bob Smith                               9
    ...
    ------------------------------------------
    Total drivers:                         15
"""

import os
import psycopg2
from dotenv import load_dotenv


# The SQL query is provided — do not change it.
SQL = """
    SELECT
        d.name              AS driver_name,
        COUNT(t.trip_id)    AS completed_rides
    FROM drivers d
    LEFT JOIN trips t
        ON t.driver_id = d.driver_id
        AND t.status = 'completed'
    GROUP BY d.driver_id, d.name
    ORDER BY completed_rides DESC;
"""


# ─── TASK 1 ───────────────────────────────────────────────────────────────────
def load_config() -> dict:
    """
    Load database credentials from a .env file.

    Returns:
        dict with keys: host, port, dbname, user, password
    """
    load_dotenv()

    return {"host":os.getenv('DB_HOST'), 
            "port" : os.getenv('DB_PORT', '5432'),
            "dbname":os.getenv('DB_NAME'),
            "user":os.getenv('DB_USER'),
            "password":os.getenv('DB_PASSWORD')}


# ─── TASK 2 ───────────────────────────────────────────────────────────────────
def get_connection(config: dict):
    """
    Open and return a psycopg2 database connection.

    Args:
        config: dict returned by load_config()

    Returns:
        psycopg2 connection object   
    """
    return psycopg2.connect(**config)


# ─── TASK 3 ───────────────────────────────────────────────────────────────────
def fetch_drivers(conn) -> list:
    """
    Execute the SQL query and return all rows.

    Args:
        conn: open psycopg2 connection

    Returns:
        list of tuples — each tuple is (driver_name, completed_rides)
    """
    with conn.cursor() as cur:
        cur.execute(SQL)
        return cur.fetchall()


# ─── TASK 4 ───────────────────────────────────────────────────────────────────
def print_results(rows: list) -> None:
    """
    Print the query results as a formatted table.

    Args:
        rows: list of (driver_name, completed_rides) tuples

    Expected format (column widths: name = 25 left, rides = 15 right):

        Driver                    Completed Rides
        ------------------------------------------
        Alice Johnson                          12
        ------------------------------------------
        Total drivers:                         15

    """
    h1,h2 = "Driver", "Completed Rides"
    print(f"\n{h1:<25}{h2:>15}")
    print("------------------------------------------")

    for row in rows:
        driver_name,completed_rides = row
        print(f"{driver_name:<25}{completed_rides:>15}")

    print("------------------------------------------")
    total_drivers = "Total drivers"
    print(f"{total_drivers:<25}{len(rows):>15}\n")


# ─────────────────────────────────────────────────────────────────────────────
def main():
    config = load_config()

    try:
        conn = get_connection(config)
    except psycopg2.OperationalError as e:
        print(f"Connection failed: {type(e).__name__}: {e}")
        return

    rows = fetch_drivers(conn)
    print_results(rows)

    conn.close()


if __name__ == "__main__":
    main()
