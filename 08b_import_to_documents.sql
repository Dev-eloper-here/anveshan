-- =====================================================================
--  File : 08b_import_to_documents.sql
--  Kya  : import_files (kachcha data) se asli tables me data daalna.
--  Run  : 08a ke BAAD. Part 1-3 ek saath (Ctrl+A, Ctrl+Enter).
--         Checks ek-ek karke.
--
--  Staging table ka idea:
--    Bahar se aaya data pehle ek alag "kachchi" table me aata hai.
--    Wahan dekh sakte ho, galti ho to theek kar sakte ho, aur asli
--    tables tab tak saaf rehti hain. Phir ek INSERT ... SELECT se
--    saaf data asli tables me jaata hai. Industry me import aise hi hota hai.
-- =====================================================================


-- ---------------------------------------------------------------------
-- PART 1: Ek user jiske naam se ye files "upload" maani jaayengi.
--   documents.uploaded_by NOT NULL hai, to kisi user ka hona zaroori hai.
-- ---------------------------------------------------------------------
INSERT INTO app_users (full_name, email, user_role)
VALUES ('Academic Aid (seniors)', 'academicaid-import@incipit.example', 'STUDENT');


-- ---------------------------------------------------------------------
-- PART 2: documents me 1009 files
--
--   (a) ROW_NUMBER() ... PARTITION BY drive_id
--       import_files me 2 files do baar hain (do subjects ki wajah se).
--       documents me har file EK hi baar chahiye, warna UQ_DOC_URL
--       rokega. ROW_NUMBER har drive_id ke andar rows ko 1, 2, ...
--       number deta hai - hum sirf rn = 1 wali row lete hain.
--
--   (b) file_url: Drive ID se poora link banta hai ( || = jodna )
--
--   (c) file_format: file ke naam ka extension (.pdf, .jpg ...)
--       REGEXP_SUBSTR se nikaalte hain, phir CASE se hamari value me.
--       Extension na ho (Google Docs ki apni files) to LINK.
--
--   (d) status seedha APPROVED - seniors ki files pehle se chuni hui
--       hain. CK_DOC_REVIEW kehta hai APPROVED ke saath reviewer aur
--       time bhi chahiye - isliye wo bhi diye hain.
--
--   (e) source = 'IMPORT' - isi ki wajah se bina saal wale PYQ
--       Step 6 ke naye rule se paas ho jaayenge.
--
--   SUBSTRB(title, 1, 200): title column 200 BYTES ka hai. Hindi ka ek
--   akshar 3 bytes leta hai, to lambe Hindi naam kaatne padte hain.
-- ---------------------------------------------------------------------
INSERT INTO documents (title, resource_type, file_url, file_format,
                       academic_year, exam_type, uploaded_by,
                       status, reviewed_by, reviewed_at, source)
SELECT SUBSTRB(f.title, 1, 200),
       f.resource_type,
       'https://drive.google.com/file/d/' || f.drive_id || '/view',
       CASE LOWER(REGEXP_SUBSTR(f.file_name, '\.([[:alnum:]]+)$', 1, 1, NULL, 1))
            WHEN 'pdf'  THEN 'PDF'
            WHEN 'jpg'  THEN 'IMAGE'  WHEN 'jpeg' THEN 'IMAGE'  WHEN 'png' THEN 'IMAGE'
            WHEN 'doc'  THEN 'DOC'    WHEN 'docx' THEN 'DOC'    WHEN 'txt' THEN 'DOC'
            WHEN 'ppt'  THEN 'PPT'    WHEN 'pptx' THEN 'PPT'
            ELSE 'LINK'
       END,
       f.academic_year,
       f.exam_type,
       (SELECT user_id FROM app_users WHERE email = 'academicaid-import@incipit.example'),
       'APPROVED',
       (SELECT MIN(user_id) FROM app_users WHERE user_role = 'MODERATOR'),
       SYSTIMESTAMP,
       'IMPORT'
FROM (
    SELECT i.*,
           ROW_NUMBER() OVER (PARTITION BY i.drive_id ORDER BY i.subject_short) AS rn
    FROM   import_files i
) f
WHERE f.rn = 1;


-- ---------------------------------------------------------------------
-- PART 3: har file ko uske subject(s) se jodna (M:N)
--   import_files ki har row = (file, subject). File ka doc_id
--   documents se link match karke milta hai, subject_id subjects se
--   short_name match karke. Yahan dono rows chahiye - isliye 1011.
-- ---------------------------------------------------------------------
INSERT INTO document_subjects (doc_id, subject_id)
SELECT DISTINCT d.doc_id, s.subject_id
FROM   import_files i
JOIN   documents d ON d.file_url   = 'https://drive.google.com/file/d/' || i.drive_id || '/view'
JOIN   subjects  s ON s.short_name = i.subject_short;

COMMIT;


-- =====================================================================
-- CHECKS - ek-ek karke
-- =====================================================================

-- (a) Kahan se aaye documents                Expected: IMPORT 1009, UPLOAD 27
SELECT source, COUNT(*) AS docs
FROM   documents
GROUP  BY source;

-- (b) Type ke hisaab se (sirf import)         Expected: NOTES 320, PYQ 260, BOOK 191,
--                                                       LAB 136, OTHER 52, SYLLABUS 50
SELECT resource_type, COUNT(*) AS docs
FROM   documents
WHERE  source = 'IMPORT'
GROUP  BY resource_type
ORDER  BY docs DESC;

-- (c) Koi file bina subject ke reh gayi?      Expected: 0
--     NOT EXISTS: "aisa koi document jiske liye document_subjects me
--     ek bhi row NAHI hai"
SELECT COUNT(*) AS docs_without_subject
FROM   documents d
WHERE  NOT EXISTS (SELECT 1 FROM document_subjects ds WHERE ds.doc_id = d.doc_id);

-- (d) Woh 2 files jo do subjects ki hain (EE ka shared folder)
SELECT d.title,
       LISTAGG(s.short_name, ', ') WITHIN GROUP (ORDER BY s.short_name) AS subjects
FROM   documents d
JOIN   document_subjects ds ON ds.doc_id    = d.doc_id
JOIN   subjects          s  ON s.subject_id = ds.subject_id
WHERE  d.source = 'IMPORT'
GROUP  BY d.doc_id, d.title
HAVING COUNT(*) > 1;

-- (e) Bina saal wale PYQs bhi aaye?           Expected: 112 (Step 6 ke rule ki wajah se)
SELECT COUNT(*) AS pyq_without_year_or_exam
FROM   documents
WHERE  source = 'IMPORT' AND resource_type = 'PYQ'
AND   (academic_year IS NULL OR exam_type IS NULL);

-- (f) Trigger ne har import likha?            Expected: INSERT 1036 (27 + 1009), UPDATE 25
SELECT operation, COUNT(*) AS rows_logged
FROM   document_audit
GROUP  BY operation;

-- (g) Ek asli file kholke dekho - FILE_URL copy karke browser me
SELECT d.title, d.file_url
FROM   documents d
JOIN   document_subjects ds ON ds.doc_id    = d.doc_id
JOIN   subjects          s  ON s.subject_id = ds.subject_id
WHERE  s.short_name = 'DBMS' AND d.source = 'IMPORT';
