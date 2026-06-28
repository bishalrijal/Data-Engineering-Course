# Q7 (Stretch)
# Python script: connect, run Q2, print formatted table
# output at the end of this file

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
    #dict is dictionary that stores key-value pairs
    #it says what type function will return

    load_dotenv() # this will read .env into memory
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
    in main function, config = load_config() 
    so config stores the dict
    it is unpacked using **config
    """
    return psycopg2.connect(**config)  #returns connection to main function


# ─── TASK 3 ───────────────────────────────────────────────────────────────────
def fetch_drivers(conn) -> list:
    """
    conn object was passed from main to fetch_drivers(conn)
    returned by get_connection(config) function
    
    now that conn established the connection
    we will use cursor to communicate with database
    cursor helps to execute SQL queries and fetch results
    """
    cur = conn.cursor()
    cur.execute(SQL)
    rows=cur.fetchall()  #fetches all rows from executed query
    cur.close()  
    #its important to close the cursor after use to free up resources
    return rows
    

# ─── TASK 4 ───────────────────────────────────────────────────────────────────
def print_results(rows: list) -> None:
  
   
    print(f"{'Driver':<25}{'Completed Rides':>15}")
    print(f"{'-'*42}")

    for driver_name, completed_rides in rows:
        print(f"{driver_name:<25}{completed_rides:>15}")

    print(f"{'-'*42}")
    print(f"{'Total Drivers:':<25}{len(rows):>15}")


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
My output:

Driver                   Completed Rides
----------------------------------------
Rajan Pandey                         307
Nisha Bista                          300
Suresh Magar                         298
Bikash Karki                         291
Priya Gurung                         285
Anita Rai                            284
Ramesh Shrestha                      278
Deepak Thapa                         278
Kabita Lama                          276
Sita Tamang                          265
Bishal Rijal                           1
----------------------------------------
Total Drivers                         11
"""