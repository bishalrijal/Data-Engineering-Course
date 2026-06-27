import os
import psycopg2
from dotenv import load_dotenv

SQL="""SELECT
	d."name" AS driver_name,
	count(*) AS Number_of_rides
FROM
	drivers d
INNER JOIN trips t ON
	d.driver_id = t.driver_id
GROUP BY
	d."name"
ORDER BY
	number_of_rides DESC;"""


def load_config():
    load_dotenv(os.path.join(os.path.dirname(__file__),".env"))
    return{
        "host": os.getenv("DB_HOST"),
        "port": os.getenv("DB_PORT"),
        "dbname": os.getenv("DB_NAME"),
        "user": os.getenv("DB_USER"),
        "password": os.getenv("DB_PASSWORD"),
    }

def get_connection(config):
    return psycopg2.connect(**config)


def fetch_drivers(conn):
    cur=conn.cursor()
    cur.execute(SQL)
    rows=cur.fetchall()
    cur.close()
    return rows

def print_results(rows):
    print(f"\n{'Driver':<25} {'Completed Rides':>15}")
    print("-" * 42)
    for driver_name, completed_rides in rows:
        print(f"{driver_name:<25} {completed_rides:>15}")
    print("-" * 42)
    print(f"{'Total drivers:':<25} {len(rows):>15}\n")


def main():
    config=load_config()

    try:
        conn=get_connection(config)
    except psycopg2.OperationalError as e:
        print(f"Conection Failed: {e}")
        return
    rows=fetch_drivers(conn)
    print_results(rows)
    conn.close()

if __name__=="__main__":
    main()