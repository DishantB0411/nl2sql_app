from sqlalchemy import create_engine, text

connection_uri = (
    "mssql+pyodbc://@localhost\\SQLEXPRESS/rental_app"
    "?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes"
)

try:
    engine = create_engine(connection_uri)
    with engine.connect() as conn:
        result = conn.execute(text("SELECT name FROM sys.databases")).fetchall()
        print("✅ Connection successful!")
        print("Databases available:", [row[0] for row in result])
except Exception as e:
    print("❌ Connection failed!")
    print("Error details:", str(e))
