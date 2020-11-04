import presto

# Connect to Presto
conn = presto.dbapi.connect(
    host='localhost',
    port=8080,
    user='presto',
    catalog='hive',
    schema='default',
)

# Execute SQL query
cur = conn.cursor()
cur.execute('SELECT iris.petal_length FROM hive.default.iris LIMIT 1')
rows = cur.fetchall()
print(rows)