import sqlite3 as sl

db = sl.connect('stats.db')
v = db.execute("SELECT Max(teamID) FROM Team").fetchone()[0]
print(type(v))