"""
Anveshan website.

Chalane ke liye:   python app.py
Browser me kholo:  http://localhost:5000
Band karne ke liye terminal me Ctrl + C
"""
from flask import Flask, render_template, request

import db

app = Flask(__name__)

TYPES = ["PYQ", "NOTES", "BOOK", "LAB", "SYLLABUS", "OTHER"]
MAX_RESULTS = 100


# ---------------------------------------------------------------------
# SEARCH QUERY
#
#   Har filter is pattern me likha hai:
#       (:rtype IS NULL OR d.resource_type = :rtype)
#   Matlab: user ne filter khaali chhoda (NULL) -> ye shart hamesha sach,
#           filter chuna -> sirf wahi rows.
#   Isse EK hi query har combination sambhal leti hai - 5 filters ke
#   liye 32 alag queries likhne ki zaroorat nahi.
#
#   :q, :rtype ... BIND VARIABLES hain. User ka likha hua text kabhi
#   SQL ke andar jodte nahi - alag se bhejte hain. (Neeche explain.)
#
#   Branch / semester ke liye EXISTS: "is document ka koi subject us
#   branch ke us semester me padhaya jaata hai kya?"
#   document -> document_subjects -> subject_offerings -> branches
# ---------------------------------------------------------------------
SEARCH_SQL = """
SELECT d.doc_id, d.title, d.resource_type, d.file_url,
       d.academic_year, d.exam_type, d.subjects, d.uploader
FROM   v_documents d
WHERE  d.status = 'APPROVED'

AND   (:q IS NULL
       OR UPPER(d.title) LIKE '%' || UPPER(:q) || '%'
       OR EXISTS (SELECT 1
                  FROM   document_subjects x
                  JOIN   subjects s ON s.subject_id = x.subject_id
                  WHERE  x.doc_id = d.doc_id
                  AND   (UPPER(s.short_name)   LIKE '%' || UPPER(:q) || '%'
                      OR UPPER(s.subject_name) LIKE '%' || UPPER(:q) || '%')))

AND   (:rtype IS NULL OR d.resource_type = :rtype)
AND   (:yr    IS NULL OR d.academic_year = :yr)

AND   (:subj  IS NULL
       OR EXISTS (SELECT 1 FROM document_subjects x
                  WHERE x.doc_id = d.doc_id AND x.subject_id = :subj))

AND   ((:branch IS NULL AND :sem IS NULL)
       OR EXISTS (SELECT 1
                  FROM   document_subjects x
                  JOIN   subject_offerings o ON o.subject_id = x.subject_id
                  JOIN   branches b          ON b.branch_id  = o.branch_id
                  WHERE  x.doc_id = d.doc_id
                  AND   (:sem    IS NULL OR o.semester    = :sem)
                  AND   (:branch IS NULL OR b.branch_code = :branch)))

ORDER  BY d.uploaded_at DESC, d.doc_id DESC
FETCH FIRST 100 ROWS ONLY
"""


def to_int(value):
    """'3' -> 3,  '' ya galat value -> None"""
    try:
        return int(value)
    except (TypeError, ValueError):
        return None


def read_filters():
    """
    URL se filters padho. Search karne pe URL aisa banta hai:
        /?q=dbms&branch=CSE&sem=3&subj=&rtype=PYQ&yr=
    request.args isi "?" ke baad wale hisse ko dict jaisa deta hai.
    Khaali value ko None bana dete hain, taki SQL me "IS NULL" sach ho.
    """
    args = request.args
    return {
        "q":      (args.get("q") or "").strip() or None,
        "branch": args.get("branch") or None,
        "sem":    to_int(args.get("sem")),
        "subj":   to_int(args.get("subj")),
        "rtype":  args.get("rtype") or None,
        "yr":     to_int(args.get("yr")),
    }


def dropdown_options():
    """Dropdowns ki values bhi database se hi aati hain."""
    return {
        "branches":  db.query("SELECT branch_code, branch_name FROM branches ORDER BY branch_code"),
        "semesters": db.query("SELECT DISTINCT semester FROM subject_offerings ORDER BY semester"),
        "subjects":  db.query("SELECT subject_id, short_name, subject_name FROM subjects ORDER BY short_name"),
        "years":     db.query("""SELECT DISTINCT academic_year FROM documents
                                 WHERE status = 'APPROVED' AND academic_year IS NOT NULL
                                 ORDER BY academic_year DESC"""),
        "types":     TYPES,
    }


@app.get("/")
def home():
    filters = read_filters()

    # filters dict seedha bind variables ban jaata hai:
    #   {"q": "dbms", "branch": "CSE", "sem": 3, ...}
    #   SQL ke :q, :branch, :sem ... in values se bhar jaate hain.
    docs = db.query(SEARCH_SQL, filters)

    return render_template(
        "index.html",
        docs=docs,
        f=filters,
        options=dropdown_options(),
        max_results=MAX_RESULTS,
    )


if __name__ == "__main__":
    app.run(debug=True)
