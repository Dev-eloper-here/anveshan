-- =====================================================================
--  File : 05_constraint_and_trigger_demo.sql
--  Kya  : Evaluation demo ke liye. Part A ke saare statements FAIL
--         hone chahiye - yahi dikhata hai ki galat data database
--         khud rok deta hai. Part B trigger ko live chalte dikhata hai.
--
--  Run  : POORI FILE EK SAATH MAT CHALANA.
--         Har statement par cursor rakh ke Ctrl+Enter, ek-ek karke.
--         Error ke message me constraint ka naam dikhega - isiliye
--         schema me har constraint ka naam rakha tha.
-- =====================================================================


-- =====================================================================
-- PART A : Ye sab FAIL honge
-- =====================================================================

-- A1. PYQ hai par saal aur exam type nahi diya
--     Expected: ORA-02290: check constraint (INCIPIT.CK_DOC_PYQ_META) violated
INSERT INTO documents (title, resource_type, file_url, file_format, uploaded_by)
VALUES ('Test PYQ without year', 'PYQ', 'https://example.com/incipit/test-a1', 'PDF',
        (SELECT user_id FROM app_users WHERE email = 'aarav@incipit.example'));

-- A2. NOTES ke saath exam_type de diya (exam_type sirf PYQ ke liye)
--     Expected: ORA-02290: check constraint (INCIPIT.CK_DOC_EXAM_ONLY_PYQ) violated
INSERT INTO documents (title, resource_type, file_url, file_format, exam_type, uploaded_by)
VALUES ('Test notes with exam type', 'NOTES', 'https://example.com/incipit/test-a2', 'PDF', 'MID',
        (SELECT user_id FROM app_users WHERE email = 'aarav@incipit.example'));

-- A3. Bina reviewer ke APPROVE karne ki koshish
--     Expected: ORA-02290: check constraint (INCIPIT.CK_DOC_REVIEW) violated
UPDATE documents
SET    status = 'APPROVED'
WHERE  file_url = 'https://example.com/incipit/aiml-intro';

-- A4. Same file dobara upload
--     Expected: ORA-00001: unique constraint (INCIPIT.UQ_DOC_URL) violated
INSERT INTO documents (title, resource_type, file_url, file_format, academic_year, exam_type, uploaded_by)
VALUES ('DBMS Mid-Sem 2025 (copy)', 'PYQ', 'https://example.com/incipit/dbms-mid-2025', 'PDF', 2025, 'MID',
        (SELECT user_id FROM app_users WHERE email = 'riya@incipit.example'));

-- A5. Document ko aise subject se jodna jo exist hi nahi karta
--     Expected: ORA-02291: integrity constraint (INCIPIT.FK_DS_SUBJECT) violated - parent key not found
INSERT INTO document_subjects (doc_id, subject_id)
VALUES ((SELECT doc_id FROM documents WHERE file_url = 'https://example.com/incipit/aiml-intro'), 99999);

-- A6. Semester 9 (B.Tech me sirf 8 hote hain)
--     Expected: ORA-02290: check constraint (INCIPIT.CK_OFF_SEMESTER) violated
INSERT INTO subject_offerings (subject_id, branch_id, semester)
VALUES ((SELECT subject_id FROM subjects WHERE short_name = 'DBMS'),
        (SELECT branch_id  FROM branches WHERE branch_code = 'CSE'), 9);


-- =====================================================================
-- PART B : Trigger live demo
-- =====================================================================

-- B1. Pehle dekho: aiml-intro ki history me abhi sirf INSERT hai
SELECT a.audit_id, a.operation, a.old_status, a.new_status, a.changed_at
FROM   document_audit a
JOIN   documents d ON d.doc_id = a.doc_id
WHERE  d.file_url = 'https://example.com/incipit/aiml-intro'
ORDER  BY a.audit_id;

-- B2. Moderator ise sahi tareeke se approve karta hai (ye CHALEGA)
UPDATE documents
SET    status      = 'APPROVED',
       reviewed_by = (SELECT user_id FROM app_users WHERE email = 'moderator@incipit.example'),
       reviewed_at = SYSTIMESTAMP
WHERE  file_url = 'https://example.com/incipit/aiml-intro';

COMMIT;

-- B3. B1 wali query dobara chalao.
--     Ab ek nayi row dikhegi: UPDATE, PENDING -> APPROVED.
--     Ye row kisi ne haath se nahi likhi - trigger ne likhi.
SELECT a.audit_id, a.operation, a.old_status, a.new_status, a.changed_at
FROM   document_audit a
JOIN   documents d ON d.doc_id = a.doc_id
WHERE  d.file_url = 'https://example.com/incipit/aiml-intro'
ORDER  BY a.audit_id;
