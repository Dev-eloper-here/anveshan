-- =====================================================================
--  File : 06_pyq_rule_for_imports.sql
--  Kya  : documents table me naya column "source" aur PYQ wala rule
--         badalna, taki academicaid ka purana data import ho sake.
--  Run  : INCIPIT connection par. Part 1 aur 2 ek saath chala sakte ho
--         (Ctrl+A, Ctrl+Enter). Part 3 ke checks ek-ek karke.
--
--  Problem:
--    CK_DOC_PYQ_META kehta hai: PYQ hai to saal AUR exam type dono do.
--    academicaid ke 146 PYQs me se sirf 84 me dono milte hain. Baaki
--    asli papers hain, bas file ke naam me saal nahi likha (jaise
--    "1 math.pdf"). Purana rule unhe import hi nahi hone dega.
--
--  Hal (isse "legacy data" handle karna kehte hain):
--    Har document ke saath likho ki wo AAYA kahan se:
--      UPLOAD = website se kisi student ne daala   -> rule lagega
--      IMPORT = academicaid se laaya gaya          -> rule se chhoot
--    Isse naye uploads par rule waisa hi rahega, aur purana data bhi aa jaayega.
-- =====================================================================


-- ---------------------------------------------------------------------
-- PART 1: naya column
--   DEFAULT 'UPLOAD' ki wajah se jo 27 documents abhi table me hain,
--   un sab me apne aap 'UPLOAD' bhar jaayega.
-- ---------------------------------------------------------------------
ALTER TABLE documents ADD (
    source VARCHAR2(6) DEFAULT 'UPLOAD' NOT NULL
);

ALTER TABLE documents ADD CONSTRAINT ck_doc_source
    CHECK (source IN ('UPLOAD', 'IMPORT'));


-- ---------------------------------------------------------------------
-- PART 2: purana rule hatao, naya lagao
--   Constraint ko seedha "edit" nahi kar sakte - DROP karke dobara
--   ADD karna padta hai. Naam wahi rakha (CK_DOC_PYQ_META), taki
--   05 wala demo aur website ka error message waise hi kaam karein.
--
--   Naya rule padhne ka tareeka - inme se KOI EK sach hona chahiye:
--     1. ye PYQ hi nahi hai
--     2. ye import hua hai
--     3. saal aur exam type dono bhare hain
-- ---------------------------------------------------------------------
ALTER TABLE documents DROP CONSTRAINT ck_doc_pyq_meta;

ALTER TABLE documents ADD CONSTRAINT ck_doc_pyq_meta CHECK (
       resource_type <> 'PYQ'
    OR source = 'IMPORT'
    OR (academic_year IS NOT NULL AND exam_type IS NOT NULL)
);


-- =====================================================================
-- PART 3: CHECK - ek-ek karke chalao
-- =====================================================================

-- (a) Naya column aaya?                       Expected: SOURCE, VARCHAR2, 'UPLOAD', N
SELECT column_name, data_type, data_default, nullable
FROM   user_tab_columns
WHERE  table_name = 'DOCUMENTS' AND column_name = 'SOURCE';

-- (b) Purane 27 documents me kya bhara?       Expected: UPLOAD 27
SELECT source, COUNT(*) AS docs
FROM   documents
GROUP  BY source;

-- (c) Dono rules ka text
SELECT constraint_name, search_condition_vc
FROM   user_constraints
WHERE  table_name = 'DOCUMENTS'
AND    constraint_name IN ('CK_DOC_PYQ_META', 'CK_DOC_SOURCE');

-- (d) Website wala upload (source = UPLOAD) ab bhi ROKA jaana chahiye
--     Expected: ORA-02290: check constraint (INCIPIT.CK_DOC_PYQ_META) violated
INSERT INTO documents (title, resource_type, file_url, file_format, uploaded_by)
VALUES ('Test PYQ without year', 'PYQ', 'https://example.com/incipit/test-06', 'PDF',
        (SELECT user_id FROM app_users WHERE email = 'aarav@incipit.example'));
