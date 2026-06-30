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
    return {
        "host": os.getenv("DB_HOST"),
        "port": os.getenv("DB_PORT"),
        "dbname": os.getenv("DB_NAME"),
        "user": os.getenv("DB_USER"),
        "password": os.getenv("DB_PASSWORD")
    }



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
    cur = conn.cursor()
    cur.execute(SQL)
    rows = cur.fetchall()
    cur.close()
    return rows
    


# ─── TASK 4 ───────────────────────────────────────────────────────────────────
def print_results(rows: list) -> None:
    # TODO: print the header
    print(f"{'Driver':<25}{'Completed Rides':>15}")
    print('-'*40)
    # TODO: loop over rows and print each driver_name and completed_rides
    for driver_name, completed_rides in rows:
        print(f"{driver_name:<25}{completed_rides:>15}")

    # TODO: print a footer with the total number of drivers
    print("-" * 40)
    print(f"{'Total drivers:':<25}{len(rows):>15}")

# ─────────────────────────────────────────────────────────────────────────────
def main():
    config = load_config()

    try:
        conn = get_connection(config)
    except psycopg2.OperationalError as e:
        print(f"Connection failed: {e}")
        return

    rows = fetch_drivers(conn)
    print_results(rows)

    conn.close()


if __name__ == "__main__":
    main()
    
"""
Output
Driver                   Completed Rides
----------------------------------------
Rajan Pandey                         308
Nisha Bista                          300
Suresh Magar                         298
Bikash Karki                         291
Priya Gurung                         285
Anita Rai                            284
Ramesh Shrestha                      278
Deepak Thapa                         278
Kabita Lama                          276
Sita Tamang                          265
Priyams R Bajracharya                  0
----------------------------------------
Total drivers:                        11
"""