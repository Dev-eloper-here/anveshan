-- =====================================================================
--  File : 02_seed_curriculum.sql
--  Kya  : CSE curriculum - branches, subjects, aur kaunsa subject kis
--         semester me hai. Ye academicaid.in/cse/study.html ke subject
--         list se liya gaya hai (sirf subject naam, unki files nahi).
--  Run  : 01_schema.sql ke BAAD. Poori file select karke Ctrl+Enter.
--
--  Note : IDs haath se nahi daale. Identity column khud ID deta hai.
--         Haath se ID daaloge to baad me identity ki sequence takrayegi.
-- =====================================================================


-- ---------------------------------------------------------------------
-- Branches
-- ---------------------------------------------------------------------
INSERT INTO branches (branch_code, branch_name) VALUES ('CSE', 'Computer Engineering');
INSERT INTO branches (branch_code, branch_name) VALUES ('ECE', 'Electronics and Communication Engineering');
INSERT INTO branches (branch_code, branch_name) VALUES ('EE',  'Electrical Engineering');


-- ---------------------------------------------------------------------
-- Subjects  (naam waise hi jaise site par likhe hain;
--            jahan poora naam pata ho wahan sahi kar lena)
-- ---------------------------------------------------------------------
INSERT INTO subjects (subject_name, short_name, category)
SELECT 'Mathematics-I',                              'MATH1',  'DSC' FROM dual UNION ALL
SELECT 'EEE',                                        'EEE',    'DSC' FROM dual UNION ALL
SELECT 'FCP',                                        'FCP',    'DSC' FROM dual UNION ALL
SELECT 'Workshop',                                   'WKSP',   'OTH' FROM dual UNION ALL
SELECT 'Mathematics-II',                             'MATH2',  'DSC' FROM dual UNION ALL
SELECT 'Physics',                                    'PHY',    'DSC' FROM dual UNION ALL
SELECT 'Data Structures',                            'DS',     'DSC' FROM dual UNION ALL
SELECT 'Analysis and Design of Algorithms',          'ADA',    'DSC' FROM dual UNION ALL
SELECT 'Digital System Design',                      'DSD',    'DSC' FROM dual UNION ALL
SELECT 'Database Management Systems',                'DBMS',   'DSC' FROM dual UNION ALL
SELECT 'Operating System',                           'OS',     'DSC' FROM dual UNION ALL
SELECT 'Software Engineering',                       'SE',     'DSC' FROM dual UNION ALL
SELECT 'Computer System Architecture',               'CSA',    'DSC' FROM dual UNION ALL
SELECT 'Theory of Computation',                      'TOC',    'DSC' FROM dual UNION ALL
SELECT 'Artificial Intelligence and Machine Learning','AIML',  'DSC' FROM dual UNION ALL
SELECT 'Computer Networks',                          'CN',     'DSC' FROM dual UNION ALL
SELECT 'Cybersecurity',                              'CYSEC',  'DSC' FROM dual UNION ALL
SELECT 'Cloud Computing',                            'CLOUD',  'DSC' FROM dual UNION ALL
SELECT 'Software Project Management',                'SPM',    'DSC' FROM dual UNION ALL
SELECT 'Cyber Physical Systems',                     'CPS',    'DSC' FROM dual UNION ALL
SELECT 'Specialization / Minor (DSE / GE pool)',     'DSE',    'DSE' FROM dual UNION ALL
SELECT 'General Elective (pool)',                    'GE',     'GE'  FROM dual UNION ALL
SELECT 'Value Addition Course (pool)',               'VAC',    'VAC' FROM dual UNION ALL
SELECT 'Ability Enhancement Course (pool)',          'AEC',    'AEC' FROM dual;


-- ---------------------------------------------------------------------
-- Offerings: kaunsa subject CSE me kis semester me hai
--   Dhyan do: Workshop (Sem 1, 2), VAC/AEC (Sem 1-5), DSE (Sem 3-7)
--   ek se zyada semester me aate hain. Site par isi wajah se same
--   Drive folder do-do semesters me link kiya hua hai.
-- ---------------------------------------------------------------------
INSERT INTO subject_offerings (subject_id, branch_id, semester, paper_code)
SELECT s.subject_id, b.branch_id, x.sem, x.code
FROM (
    SELECT 'MATH1' sn, 1 sem, 'DSC-1'       code FROM dual UNION ALL
    SELECT 'EEE',      1,     'DSC-5'            FROM dual UNION ALL
    SELECT 'FCP',      1,     NULL               FROM dual UNION ALL
    SELECT 'WKSP',     1,     NULL               FROM dual UNION ALL
    SELECT 'GE',       1,     NULL               FROM dual UNION ALL
    SELECT 'VAC',      1,     NULL               FROM dual UNION ALL
    SELECT 'AEC',      1,     NULL               FROM dual UNION ALL

    SELECT 'MATH2',    2,     'DSC-4'            FROM dual UNION ALL
    SELECT 'PHY',      2,     'DSC-2'            FROM dual UNION ALL
    SELECT 'DS',       2,     'DSC-6'            FROM dual UNION ALL
    SELECT 'WKSP',     2,     NULL               FROM dual UNION ALL
    SELECT 'GE',       2,     NULL               FROM dual UNION ALL
    SELECT 'VAC',      2,     NULL               FROM dual UNION ALL
    SELECT 'AEC',      2,     NULL               FROM dual UNION ALL

    SELECT 'ADA',      3,     'DSC-7'            FROM dual UNION ALL
    SELECT 'DSD',      3,     'DSC-8'            FROM dual UNION ALL
    SELECT 'DBMS',     3,     'DSC-9'            FROM dual UNION ALL
    SELECT 'DSE',      3,     'DSE-1/GE-3'       FROM dual UNION ALL
    SELECT 'VAC',      3,     NULL               FROM dual UNION ALL
    SELECT 'AEC',      3,     NULL               FROM dual UNION ALL

    SELECT 'OS',       4,     'DSC-10'           FROM dual UNION ALL
    SELECT 'SE',       4,     NULL               FROM dual UNION ALL  -- site par SE aur CSA dono "DSC-12" likhe hain; confirm karke bharna
    SELECT 'CSA',      4,     'DSC-12'           FROM dual UNION ALL
    SELECT 'DSE',      4,     'DSE-2/GE-4'       FROM dual UNION ALL
    SELECT 'VAC',      4,     NULL               FROM dual UNION ALL
    SELECT 'AEC',      4,     NULL               FROM dual UNION ALL

    SELECT 'TOC',      5,     'DSC-13'           FROM dual UNION ALL
    SELECT 'AIML',     5,     'DSC-14'           FROM dual UNION ALL
    SELECT 'CN',       5,     'DSC-15'           FROM dual UNION ALL
    SELECT 'DSE',      5,     'DSE-3/GE-5'       FROM dual UNION ALL
    SELECT 'VAC',      5,     NULL               FROM dual UNION ALL
    SELECT 'AEC',      5,     NULL               FROM dual UNION ALL

    SELECT 'CYSEC',    6,     'DSC-16'           FROM dual UNION ALL
    SELECT 'CLOUD',    6,     'DSC-17'           FROM dual UNION ALL
    SELECT 'SPM',      6,     'DSC-18'           FROM dual UNION ALL
    SELECT 'DSE',      6,     'DSE-4'            FROM dual UNION ALL
    SELECT 'GE',       6,     'GE-6'             FROM dual UNION ALL

    SELECT 'CPS',      7,     NULL               FROM dual UNION ALL
    SELECT 'DSE',      7,     'DSE-5..7/GE-7,8'  FROM dual
) x
JOIN subjects s ON s.short_name = x.sn
CROSS JOIN branches b
WHERE b.branch_code = 'CSE';

COMMIT;


-- ---------------------------------------------------------------------
-- CHECK QUERIES - inko alag-alag chalakar dekho
-- ---------------------------------------------------------------------

-- (a) Har semester me kitne subjects
SELECT o.semester, COUNT(*) AS subjects
FROM   subject_offerings o
GROUP  BY o.semester
ORDER  BY o.semester;

-- (b) Semester 3 ki poori list (JOIN)
SELECT o.semester, o.paper_code, s.subject_name, s.category
FROM   subject_offerings o
JOIN   subjects s ON s.subject_id = o.subject_id
JOIN   branches b ON b.branch_id  = o.branch_id
WHERE  b.branch_code = 'CSE' AND o.semester = 3
ORDER  BY s.category, o.paper_code;

-- (c) Kaunse subjects EK SE ZYADA semester me aate hain
--     Yahi woh cheez hai jo folder hierarchy me fit nahi hoti.
SELECT s.subject_name,
       COUNT(*)                                                 AS semesters,
       LISTAGG(o.semester, ', ') WITHIN GROUP (ORDER BY o.semester) AS which_sems
FROM   subject_offerings o
JOIN   subjects s ON s.subject_id = o.subject_id
GROUP  BY s.subject_name
HAVING COUNT(*) > 1
ORDER  BY semesters DESC;
