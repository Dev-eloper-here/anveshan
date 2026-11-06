-- =====================================================================
--  File : 03_audit_trigger.sql
--  Kya  : documents table par ek trigger. Jab bhi koi document
--         INSERT, status UPDATE, ya DELETE hoga, uska record
--         document_audit me apne aap likh diya jaayega.
--  Run  : 04 se PEHLE chalana, taki seed data ka bhi audit bane.
--         Poori file select karke Ctrl+Enter.
--
--  Trigger kya hota hai:
--    Ek chhota PL/SQL program jo database khud chalata hai jab table
--    par koi event hota hai. Application ko kuch karna nahi padta.
--
--  :OLD aur :NEW kya hain:
--    :OLD = row ki purani value (change se pehle)
--    :NEW = row ki nayi value  (change ke baad)
--    INSERT me :OLD khaali hota hai, DELETE me :NEW khaali hota hai.
-- =====================================================================

CREATE OR REPLACE TRIGGER trg_documents_audit
AFTER INSERT OR UPDATE OF status OR DELETE ON documents
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO document_audit (doc_id, operation, old_status, new_status, changed_by)
        VALUES (:NEW.doc_id, 'INSERT', NULL, :NEW.status, :NEW.uploaded_by);

    ELSIF UPDATING THEN
        -- status same rakh ke update kiya ho to record mat banao
        IF :OLD.status <> :NEW.status THEN
            INSERT INTO document_audit (doc_id, operation, old_status, new_status, changed_by)
            VALUES (:NEW.doc_id, 'UPDATE', :OLD.status, :NEW.status, :NEW.reviewed_by);
        END IF;

    ELSIF DELETING THEN
        INSERT INTO document_audit (doc_id, operation, old_status, new_status, changed_by)
        VALUES (:OLD.doc_id, 'DELETE', :OLD.status, NULL, NULL);
    END IF;
END;
/

-- Check: trigger bana aur VALID hai?
SELECT trigger_name, triggering_event, status
FROM   user_triggers;

SELECT object_name, status
FROM   user_objects
WHERE  object_type = 'TRIGGER';
