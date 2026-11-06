-- =====================================================================
--  File : 04_seed_users_documents.sql
--  Kya  : Demo users aur 27 demo documents.
--         Naam aur links sab DEMO hain (example.com / .example domain
--         aise hi testing ke liye reserved hain) - koi asli file nahi.
--  Run  : 03_audit_trigger.sql ke BAAD. Poori file Ctrl+A, Ctrl+Enter.
--
--  Flow jo isme chalega (asli site jaisa):
--    1. Students upload karte hain   -> sab documents PENDING
--    2. Moderator review karta hai   -> zyadatar APPROVED, 2 REJECTED
--    3. 3 documents PENDING hi rehte hain (review queue)
--  Trigger in sab ka record document_audit me apne aap rakhega.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. Users: 1 moderator + 4 students
-- ---------------------------------------------------------------------
INSERT INTO app_users (full_name, email, user_role, branch_id)
SELECT x.nm, x.em, x.rl, b.branch_id
FROM (
    SELECT 'Incipit Moderator' nm, 'moderator@incipit.example' em, 'MODERATOR' rl FROM dual UNION ALL
    SELECT 'Aarav Mehta',          'aarav@incipit.example',        'STUDENT'      FROM dual UNION ALL
    SELECT 'Riya Kapoor',          'riya@incipit.example',         'STUDENT'      FROM dual UNION ALL
    SELECT 'Kabir Malhotra',       'kabir@incipit.example',        'STUDENT'      FROM dual UNION ALL
    SELECT 'Ananya Verma',         'ananya@incipit.example',       'STUDENT'      FROM dual
) x
CROSS JOIN branches b
WHERE b.branch_code = 'CSE';


-- ---------------------------------------------------------------------
-- 2. Documents (sab PENDING me aayenge - status ka DEFAULT)
--    slug = link ka aakhri hissa; poora link neeche jud jaata hai
-- ---------------------------------------------------------------------
INSERT INTO documents (title, resource_type, file_url, file_format,
                       size_kb, academic_year, exam_type, uploaded_by)
SELECT x.title, x.rtype,
       'https://example.com/incipit/' || x.slug,
       x.fmt, x.kb, x.yr, x.exam, u.user_id
FROM (
    SELECT 'dbms-mid-2025' slug, 'DBMS Mid-Sem Paper 2025' title, 'PYQ' rtype, 'PDF' fmt, 640 kb, 2025 yr, 'MID' exam, 'aarav' who FROM dual UNION ALL
    SELECT 'dbms-end-2024',         'DBMS End-Sem Paper 2024',                     'PYQ',      'PDF',   910,  2024, 'END', 'riya'   FROM dual UNION ALL
    SELECT 'dbms-normalization',    'Normalization 1NF to BCNF - Handwritten Notes','NOTES',   'PDF',  4200,  NULL, NULL,  'kabir'  FROM dual UNION ALL
    SELECT 'dbms-sql-lab',          'SQL Lab Manual - DDL, DML, Joins',            'LAB',      'PDF',  1800,  2025, NULL,  'ananya' FROM dual UNION ALL
    SELECT 'korth-summary',         'Database System Concepts - Ch 1 to 7 Summary','BOOK',     'PDF', 12500,  NULL, NULL,  'riya'   FROM dual UNION ALL
    SELECT 'ada-mid-2025',          'ADA Mid-Sem Paper 2025',                      'PYQ',      'PDF',   700,  2025, 'MID', 'aarav'  FROM dual UNION ALL
    SELECT 'ada-greedy-dp',         'Greedy vs Dynamic Programming Notes',         'NOTES',    'PDF',  3100,  NULL, NULL,  'kabir'  FROM dual UNION ALL
    SELECT 'graph-algorithms',      'Graph Algorithms - BFS, DFS, Dijkstra',       'NOTES',    'PDF',  2600,  NULL, NULL,  'ananya' FROM dual UNION ALL
    SELECT 'dsd-kmaps',             'Boolean Algebra and K-Maps',                  'NOTES',    'PDF',  2200,  NULL, NULL,  'riya'   FROM dual UNION ALL
    SELECT 'dsd-end-2024',          'DSD End-Sem Paper 2024',                      'PYQ',      'IMAGE',1500,  2024, 'END', 'kabir'  FROM dual UNION ALL
    SELECT 'dsd-verilog-lab',       'Verilog Lab Programs',                        'LAB',      'DOC',   300,  2025, NULL,  'aarav'  FROM dual UNION ALL
    SELECT 'ds-end-2025',           'Data Structures End-Sem Paper 2025',          'PYQ',      'PDF',   820,  2025, 'END', 'ananya' FROM dual UNION ALL
    SELECT 'c-pointers',            'C Pointers and Memory - Notes',               'NOTES',    'PDF',  1900,  NULL, NULL,  'aarav'  FROM dual UNION ALL
    SELECT 'math1-mid-2024',        'Mathematics-I Mid-Sem Paper 2024',            'PYQ',      'PDF',   560,  2024, 'MID', 'riya'   FROM dual UNION ALL
    SELECT 'math2-formula-sheet',   'Mathematics-II Formula Sheet',                'OTHER',    'IMAGE', 450,  NULL, NULL,  'kabir'  FROM dual UNION ALL
    SELECT 'physics-lab-template',  'Physics Lab Readings Template',               'LAB',      'DOC',   120,  2025, NULL,  'ananya' FROM dual UNION ALL
    SELECT 'workshop-manual',       'Workshop Practice Manual',                    'LAB',      'PDF',  5300,  NULL, NULL,  'aarav'  FROM dual UNION ALL
    SELECT 'scheduling-concurrency','CPU Scheduling and Concurrency Control',      'NOTES',    'PPT',  3400,  NULL, NULL,  'riya'   FROM dual UNION ALL
    SELECT 'os-mid-2025',           'Operating System Mid-Sem Paper 2025',         'PYQ',      'PDF',   610,  2025, 'MID', 'kabir'  FROM dual UNION ALL
    SELECT 'toc-automata',          'Finite Automata Cheat Sheet',                 'OTHER',    'PDF',   380,  NULL, NULL,  'ananya' FROM dual UNION ALL
    SELECT 'cn-osi-tcpip',          'OSI and TCP/IP Model Notes',                  'NOTES',    'PDF',  2100,  NULL, NULL,  'aarav'  FROM dual UNION ALL
    SELECT 'syllabus-2nd-year',     '2nd Year CSE Syllabus',                       'SYLLABUS', 'PDF',   980,  2026, NULL,  'riya'   FROM dual UNION ALL
    SELECT 'dbms-notes-blurry',     'DBMS Normalization Notes (blurry scan)',      'NOTES',    'IMAGE',6100,  NULL, NULL,  'kabir'  FROM dual UNION ALL
    SELECT 'exam-memes',            'Exam Memes',                                  'OTHER',    'IMAGE',  90,  NULL, NULL,  'ananya' FROM dual UNION ALL
    SELECT 'aiml-intro',            'AI and ML Introduction Slides',               'NOTES',    'PPT',  7800,  NULL, NULL,  'aarav'  FROM dual UNION ALL
    SELECT 'dbms-mid-2024',         'DBMS Mid-Sem Paper 2024',                     'PYQ',      'PDF',   590,  2024, 'MID', 'riya'   FROM dual UNION ALL
    SELECT 'cloud-unit1',           'Cloud Computing Unit 1 Notes',                'NOTES',    'PDF',  2400,  NULL, NULL,  'kabir'  FROM dual
) x
JOIN app_users u ON u.email = x.who || '@incipit.example';


-- ---------------------------------------------------------------------
-- 3. Kaunsa document kin subjects ka hai (M:N)
--    Dhyan do: kuch documents ek se zyada subjects se jude hain -
--    yahi folder system nahi kar sakta.
-- ---------------------------------------------------------------------
INSERT INTO document_subjects (doc_id, subject_id)
SELECT d.doc_id, s.subject_id
FROM (
    SELECT 'dbms-mid-2025' slug, 'DBMS' sn FROM dual UNION ALL
    SELECT 'dbms-end-2024',          'DBMS'  FROM dual UNION ALL
    SELECT 'dbms-normalization',     'DBMS'  FROM dual UNION ALL
    SELECT 'dbms-sql-lab',           'DBMS'  FROM dual UNION ALL
    SELECT 'korth-summary',          'DBMS'  FROM dual UNION ALL
    SELECT 'ada-mid-2025',           'ADA'   FROM dual UNION ALL
    SELECT 'ada-greedy-dp',          'ADA'   FROM dual UNION ALL
    SELECT 'graph-algorithms',       'DS'    FROM dual UNION ALL   -- 2 subjects
    SELECT 'graph-algorithms',       'ADA'   FROM dual UNION ALL
    SELECT 'dsd-kmaps',              'DSD'   FROM dual UNION ALL   -- 2 subjects
    SELECT 'dsd-kmaps',              'EEE'   FROM dual UNION ALL
    SELECT 'dsd-end-2024',           'DSD'   FROM dual UNION ALL
    SELECT 'dsd-verilog-lab',        'DSD'   FROM dual UNION ALL
    SELECT 'ds-end-2025',            'DS'    FROM dual UNION ALL
    SELECT 'c-pointers',             'FCP'   FROM dual UNION ALL   -- 2 subjects
    SELECT 'c-pointers',             'DS'    FROM dual UNION ALL
    SELECT 'math1-mid-2024',         'MATH1' FROM dual UNION ALL
    SELECT 'math2-formula-sheet',    'MATH2' FROM dual UNION ALL
    SELECT 'physics-lab-template',   'PHY'   FROM dual UNION ALL
    SELECT 'workshop-manual',        'WKSP'  FROM dual UNION ALL
    SELECT 'scheduling-concurrency', 'OS'    FROM dual UNION ALL   -- 2 subjects
    SELECT 'scheduling-concurrency', 'DBMS'  FROM dual UNION ALL
    SELECT 'os-mid-2025',            'OS'    FROM dual UNION ALL
    SELECT 'toc-automata',           'TOC'   FROM dual UNION ALL
    SELECT 'cn-osi-tcpip',           'CN'    FROM dual UNION ALL
    SELECT 'syllabus-2nd-year',      'ADA'   FROM dual UNION ALL   -- 6 subjects
    SELECT 'syllabus-2nd-year',      'DSD'   FROM dual UNION ALL
    SELECT 'syllabus-2nd-year',      'DBMS'  FROM dual UNION ALL
    SELECT 'syllabus-2nd-year',      'OS'    FROM dual UNION ALL
    SELECT 'syllabus-2nd-year',      'SE'    FROM dual UNION ALL
    SELECT 'syllabus-2nd-year',      'CSA'   FROM dual UNION ALL
    SELECT 'dbms-notes-blurry',      'DBMS'  FROM dual UNION ALL
    SELECT 'exam-memes',             'DBMS'  FROM dual UNION ALL
    SELECT 'aiml-intro',             'AIML'  FROM dual UNION ALL
    SELECT 'dbms-mid-2024',          'DBMS'  FROM dual UNION ALL
    SELECT 'cloud-unit1',            'CLOUD' FROM dual
) x
JOIN documents d ON d.file_url   = 'https://example.com/incipit/' || x.slug
JOIN subjects  s ON s.short_name = x.sn;


-- ---------------------------------------------------------------------
-- 4. Moderator review
--    REJECTED: blurry scan aur memes
--    PENDING  : aiml-intro, dbms-mid-2024, cloud-unit1 (queue me rahenge)
--    APPROVED : baaki sab
-- ---------------------------------------------------------------------
UPDATE documents
SET    status      = 'REJECTED',
       reviewed_by = (SELECT user_id FROM app_users WHERE email = 'moderator@incipit.example'),
       reviewed_at = SYSTIMESTAMP
WHERE  file_url IN ('https://example.com/incipit/dbms-notes-blurry',
                    'https://example.com/incipit/exam-memes');

UPDATE documents
SET    status      = 'APPROVED',
       reviewed_by = (SELECT user_id FROM app_users WHERE email = 'moderator@incipit.example'),
       reviewed_at = SYSTIMESTAMP
WHERE  status = 'PENDING'
AND    file_url NOT IN ('https://example.com/incipit/aiml-intro',
                        'https://example.com/incipit/dbms-mid-2024',
                        'https://example.com/incipit/cloud-unit1');

COMMIT;


-- =====================================================================
-- CHECK QUERIES - ek-ek karke chalao (cursor rakh ke Ctrl+Enter)
-- =====================================================================

-- (a) Kitne documents kis status me?        Expected: APPROVED 22, REJECTED 2, PENDING 3
SELECT status, COUNT(*) AS docs
FROM   documents
GROUP  BY status;

-- (b) Trigger ne kitne records likhe?       Expected: INSERT 27, UPDATE 24
SELECT operation, COUNT(*) AS rows_logged
FROM   document_audit
GROUP  BY operation;

-- (c) Review queue: kaun se documents abhi approve hone baaki hain
SELECT d.doc_id, d.title, u.full_name AS uploaded_by, d.uploaded_at
FROM   documents d
JOIN   app_users u ON u.user_id = d.uploaded_by
WHERE  d.status = 'PENDING'
ORDER  BY d.uploaded_at;

-- (d) Asli "search": Semester 3 ke saare approved PYQs
--     Folder me isko dhoondhne ke liye 3 folder kholne padte.
SELECT s.short_name AS subject, d.title, d.academic_year, d.exam_type
FROM   documents d
JOIN   document_subjects ds ON ds.doc_id     = d.doc_id
JOIN   subjects          s  ON s.subject_id  = ds.subject_id
JOIN   subject_offerings o  ON o.subject_id  = s.subject_id
JOIN   branches          b  ON b.branch_id   = o.branch_id
WHERE  b.branch_code   = 'CSE'
AND    o.semester      = 3
AND    d.status        = 'APPROVED'
AND    d.resource_type = 'PYQ'
ORDER  BY s.short_name, d.academic_year DESC;

-- (e) Woh documents jo EK SE ZYADA subjects se jude hain
SELECT d.title,
       COUNT(*) AS subjects,
       LISTAGG(s.short_name, ', ') WITHIN GROUP (ORDER BY s.short_name) AS tagged_with
FROM   documents d
JOIN   document_subjects ds ON ds.doc_id    = d.doc_id
JOIN   subjects          s  ON s.subject_id = ds.subject_id
GROUP  BY d.doc_id, d.title
HAVING COUNT(*) > 1
ORDER  BY subjects DESC;
