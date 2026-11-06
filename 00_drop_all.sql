-- =====================================================================
--  File : 00_drop_all.sql
--  Kya  : Saari tables hata deta hai. SIRF tab chalana jab schema
--         badal ke dobara shuru se banana ho. Saara data chala jaayega.
--  Note : Pehli baar chalaoge to "table or view does not exist" error
--         aayega - wo normal hai, ignore karo.
-- =====================================================================
DROP TABLE document_audit    CASCADE CONSTRAINTS PURGE;
DROP TABLE document_subjects CASCADE CONSTRAINTS PURGE;
DROP TABLE documents         CASCADE CONSTRAINTS PURGE;
DROP TABLE app_users         CASCADE CONSTRAINTS PURGE;
DROP TABLE subject_offerings CASCADE CONSTRAINTS PURGE;
DROP TABLE subjects          CASCADE CONSTRAINTS PURGE;
DROP TABLE branches          CASCADE CONSTRAINTS PURGE;
