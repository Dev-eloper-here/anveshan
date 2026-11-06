"""
Oracle se baat karne ka saara code yahan hai.
app.py sirf query() function call karta hai - use connection ki
fikr nahi karni padti.
"""
import oracledb

# test_db.py wali hi details
DB_USER = "INCIPIT"
DB_PASSWORD = "password"
DB_DSN = "localhost:1521/FREEPDB1"

# ---------------------------------------------------------------------
# CONNECTION POOL
#   test_db.py me har baar naya connection banaya tha. Website par har
#   page khulne pe naya connection banana slow hai (har baar login).
#   Pool kuch connections pehle se khol ke rakhta hai: request aayi,
#   pool se ek connection liya, kaam kiya, wapas pool me rakh diya.
#   min=1, max=4: kam se kam 1, zyada se zyada 4 connections khule.
# ---------------------------------------------------------------------
pool = oracledb.create_pool(
    user=DB_USER,
    password=DB_PASSWORD,
    dsn=DB_DSN,
    min=1,
    max=4,
)


def query(sql, params=None):
    """
    SELECT chalao aur rows ko list of dict ke roop me wapas do.

    test_db.py me har row ek tuple thi:   ('DBMS Mid-Sem Paper 2025', 'PYQ')
    Yahan har row ek dict hogi:          {'title': 'DBMS Mid-Sem...', 'resource_type': 'PYQ'}
    Dict ka fayda: HTML me d.title likh sakte hain, d[0] nahi.
    """
    # "with" ka matlab: kaam khatam hote hi (error aaye tab bhi)
    # connection apne aap pool me wapas chala jaaye.
    with pool.acquire() as conn:
        with conn.cursor() as cur:
            cur.execute(sql, params or {})
            # cur.description me har column ka naam hota hai (CAPITAL me)
            columns = [col[0].lower() for col in cur.description]
            return [dict(zip(columns, row)) for row in cur]
