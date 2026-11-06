"""
Step 1: Python se Oracle tak pahunchna.

Chalane ke liye (isi folder me terminal kholke):
    python test_db.py
"""
import oracledb

# ---------------------------------------------------------------------
# 1. CONNECTION
#    DataGrip ke "Test Connection" jaisa hi.
#    dsn = "host:port/service". DataGrip me INCIPIT connection par
#    right-click -> Properties -> General me yahi teen cheezein milti hain.
# ---------------------------------------------------------------------
conn = oracledb.connect(
    user="INCIPIT",
    password="password",
    dsn="localhost:1521/FREEPDB1",
)
print("Connected. Oracle version:", conn.version)
print()

# ---------------------------------------------------------------------
# 2. CURSOR
#    Cursor wo object hai jo query chalata hai aur result laata hai.
#    Ek connection par kai cursor ban sakte hain.
# ---------------------------------------------------------------------
cur = conn.cursor()

# ---------------------------------------------------------------------
# 3. SIMPLE QUERY
#    SQL bilkul waisa hi jaisa DataGrip me likhte the.
#    Result ki har row ek tuple aati hai, jaise ('APPROVED', 1033).
#    "for status, count in cur" us tuple ko do variables me tod deta hai.
# ---------------------------------------------------------------------
print("Documents by status:")
cur.execute("SELECT status, COUNT(*) FROM documents GROUP BY status")
for status, count in cur:
    print("  ", status, count)
print()

# ---------------------------------------------------------------------
# 4. VIEW + BIND VARIABLE
#    v_documents wahi view hai jo Step 9 me banaya tha - Python ke
#    liye wo bhi ek normal table jaisa hai.
#
#    :subj ek BIND VARIABLE hai - query me ek khaali jagah, jiski value
#    alag se di jaati hai (neeche ki dictionary me).
#    Website me user jo bhi search box me likhega, wo hamesha aise hi
#    jaayega - kabhi bhi query ke string me jod ke nahi.
#    Kyun - ye Step 3 me detail me.
# ---------------------------------------------------------------------
print("First 5 approved DBMS files:")
cur.execute(
    """
    SELECT title, resource_type, subjects
    FROM   v_documents
    WHERE  status = 'APPROVED'
    AND    subjects LIKE :subj
    FETCH FIRST 5 ROWS ONLY
    """,
    {"subj": "%DBMS%"},
)
for row in cur:
    print("  ", row)

# ---------------------------------------------------------------------
# 5. BAND KARO
#    Kaam khatam hone par cursor aur connection band karna.
# ---------------------------------------------------------------------
cur.close()
conn.close()
print()
print("Done.")
