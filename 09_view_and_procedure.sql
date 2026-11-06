-- =====================================================================
--  File : 09_view_and_procedure.sql
--  Kya  : Ek VIEW (website ka search isse padhega) aur ek PROCEDURE
--         (website ka Approve / Reject button isse chalega).
--  Run  : Part 1 aur 2 ek saath (Ctrl+A, Ctrl+Enter).
--         Part 3 ke tests EK-EK KARKE, upar se neeche.
-- =====================================================================


-- ---------------------------------------------------------------------
-- PART 1: VIEW
--
--   View = ek SAVED QUERY jise table ki tarah use kar sakte ho.
--   Iska apna data nahi hota - jab bhi koi isse SELECT karta hai,
--   andar wali query us waqt chalti hai.
--
--   Fayda: 4 tables ka JOIN + GROUP BY + LISTAGG ek baar yahan likha.
--   Ab website ko sirf itna likhna hai:
--       SELECT * FROM v_documents WHERE status = 'APPROVED'
--   Join badalna pade to sirf view badlega, website ka code nahi.
--
--   CREATE OR REPLACE: view pehle se ho to use naye version se badal do.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW v_documents AS
SELECT d.doc_id,
       d.title,
       d.resource_type,
       d.file_url,
       d.file_format,
       d.size_kb,
       d.academic_year,
       d.exam_type,
       d.status,
       d.source,
       d.uploaded_at,
       u.full_name AS uploader,
       LISTAGG(s.short_name, ', ') WITHIN GROUP (ORDER BY s.short_name) AS subjects
FROM   documents d
JOIN   app_users u          ON u.user_id    = d.uploaded_by
JOIN   document_subjects ds ON ds.doc_id    = d.doc_id
JOIN   subjects s           ON s.subject_id = ds.subject_id
GROUP  BY d.doc_id, d.title, d.resource_type, d.file_url, d.file_format, d.size_kb,
          d.academic_year, d.exam_type, d.status, d.source, d.uploaded_at, u.full_name;


-- ---------------------------------------------------------------------
-- PART 2: PROCEDURE
--
--   Procedure = database ke andar save kiya hua PL/SQL program, jise
--   naam se call karte hain - jaise C me function.
--
--   review_document(doc_id, 'APPROVED' ya 'REJECTED'):
--     1. decision sahi hai ya nahi, check
--     2. moderator ka user_id nikaalo
--     3. UPDATE - sirf tab jab document abhi PENDING ho
--     4. koi row nahi badli (pehle se reviewed / galat id) -> error
--
--   Kuch nayi cheezein:
--     documents.doc_id%TYPE   = "jo type documents.doc_id ka hai, wahi".
--                               Column ka type badla to yahan apne aap badlega.
--     SELECT ... INTO v_x     = query ka result ek variable me rakhna
--     SQL%ROWCOUNT            = pichhli SQL ne kitni rows badli
--     RAISE_APPLICATION_ERROR = apna error number (-20000 se -20999) aur
--                               message ke saath error dena
--
--   COMMIT yahan NAHI hai, jaan-boojh kar. Jo call kare (website),
--   wahi decide kare ki kab pakka karna hai. Ye achhi practice hai.
--
--   Status badalte hi Step 3 wala trigger audit me apne aap likhega -
--   procedure ko uske baare me kuch pata hi nahi hai.
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE review_document (
    p_doc_id   IN documents.doc_id%TYPE,
    p_decision IN VARCHAR2
) AS
    v_moderator app_users.user_id%TYPE;
BEGIN
    IF p_decision NOT IN ('APPROVED', 'REJECTED') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Decision must be APPROVED or REJECTED');
    END IF;

    SELECT MIN(user_id)
    INTO   v_moderator
    FROM   app_users
    WHERE  user_role = 'MODERATOR';

    UPDATE documents
    SET    status      = p_decision,
           reviewed_by = v_moderator,
           reviewed_at = SYSTIMESTAMP
    WHERE  doc_id = p_doc_id
    AND    status = 'PENDING';

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Document ' || p_doc_id || ' is not pending review');
    END IF;
END;
/


-- =====================================================================
-- PART 3: TESTS - ek-ek karke, upar se neeche
-- =====================================================================

-- (a) View aur procedure bane, VALID hain?     Expected: dono VALID
SELECT object_name, object_type, status
FROM   user_objects
WHERE  object_name IN ('V_DOCUMENTS', 'REVIEW_DOCUMENT');

-- (b) View ko table ki tarah padho - abhi review ke liye kya pending hai
--     Expected: 2 rows (DBMS Mid-Sem Paper 2024, Cloud Computing Unit 1 Notes)
SELECT doc_id, title, subjects, uploader
FROM   v_documents
WHERE  status = 'PENDING';

-- (c) Procedure call karo: Cloud notes ko approve
--     DECLARE ... BEGIN ... END = ek chhota PL/SQL block.
--     Pehle link se doc_id nikaalte hain, phir procedure ko dete hain.
DECLARE
    v_id documents.doc_id%TYPE;
BEGIN
    SELECT doc_id INTO v_id
    FROM   documents
    WHERE  file_url = 'https://example.com/incipit/cloud-unit1';

    review_document(v_id, 'APPROVED');
    COMMIT;
END;
/

-- (d) Wahi document DOBARA approve karo
--     Expected: ORA-20002: Document ... is not pending review
--     (Do moderator ek saath button dabayein to doosre ko yahi error milega)
DECLARE
    v_id documents.doc_id%TYPE;
BEGIN
    SELECT doc_id INTO v_id
    FROM   documents
    WHERE  file_url = 'https://example.com/incipit/cloud-unit1';

    review_document(v_id, 'APPROVED');
    COMMIT;
END;
/

-- (e) Galat decision
--     Expected: ORA-20001: Decision must be APPROVED or REJECTED
BEGIN
    review_document(1, 'MAYBE');
END;
/

-- (f) Procedure ne UPDATE kiya, trigger ne apne aap audit likha
--     Expected: 2 rows - INSERT (PENDING), phir UPDATE (PENDING -> APPROVED)
SELECT a.audit_id, a.operation, a.old_status, a.new_status, a.changed_at
FROM   document_audit a
JOIN   documents d ON d.doc_id = a.doc_id
WHERE  d.file_url = 'https://example.com/incipit/cloud-unit1'
ORDER  BY a.audit_id;


-- =====================================================================
-- PART 4 (optional): staging table ab nahi chahiye
--   Import ho chuka hai. Hatana ho to neeche wali line chalao.
--   Rakhoge to bhi koi nuksan nahi.
-- =====================================================================
-- DROP TABLE import_files PURGE;
