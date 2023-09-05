import psycopg2

db_host = 'localhost'
db_port = '5440'
db_name = 'demo'
db_user = 'postgres'
db_password = 'postgres'

if __name__ == '__main__':
    try:
        connection = psycopg2.connect(
            host=db_host,
            port=db_port,
            database=db_name,
            user=db_user,
            password=db_password
        )
        cursor = connection.cursor()
        cursor.execute("SELECT * FROM bookings.flights_arrival_delayed")
        result = cursor.fetchall()
        for row in result:
            print(row)
            print("\n")
        cursor.close()
        connection.close()
    except psycopg2.Error as e:
        print("Error connecting to PostgreSQL:", e)
