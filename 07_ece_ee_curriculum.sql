-- =====================================================================
--  File : 07_ece_ee_curriculum.sql
--  Kya  : ECE aur EE ke subjects, aur kaunsa subject kis branch ke
--         kis semester me hai. (academicaid ki ECE / EE list se)
--  Run  : INCIPIT par. Poori file Ctrl+A, Ctrl+Enter. Checks end me.
--
--  Teen hisse:
--    1. 1st year (sem 1, 2) teeno branches me SAME hai. Naye subjects
--       nahi chahiye - sirf CSE ki rows copy karke ECE/EE ke liye.
--    2. ECE aur EE ke apne subjects (sem 3 se) - 25 naye.
--    3. In naye subjects ke semesters (offerings).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. 1st year: CSE ki sem 1-2 offerings ko ECE aur EE ke liye copy karo
--
--    INSERT ... SELECT: VALUES ki jagah ek SELECT ka result insert hota
--    hai. SELECT CSE ki 14 rows laata hai, CROSS JOIN unhe ECE aur EE
--    dono ke saath jodta hai -> 14 x 2 = 28 nayi rows.
-- ---------------------------------------------------------------------
INSERT INTO subject_offerings (subject_id, branch_id, semester, paper_code)
SELECT o.subject_id, b.branch_id, o.semester, o.paper_code
FROM   subject_offerings o
JOIN   branches c ON c.branch_id = o.branch_id AND c.branch_code = 'CSE'
CROSS  JOIN branches b
WHERE  b.branch_code IN ('ECE', 'EE')
AND    o.semester IN (1, 2);


-- ---------------------------------------------------------------------
-- 2. ECE aur EE ke naye subjects
--    Site par sirf short form likha hai (EDC, NAS...). Poore naam
--    unhi se banaye hain - koi galat lage to UPDATE se theek kar lena.
--
--    Dhyan do: Control Systems aur EMT yahan EK-EK baar hain, jabki
--    dono branches me padhaye jaate hain. Kaunsi branch me kab - wo
--    offerings (part 3) me jaata hai.
-- ---------------------------------------------------------------------
INSERT INTO subjects (subject_name, short_name, category)
SELECT 'Electronic Devices and Circuits',          'EDC',   'DSC' FROM dual UNION ALL
SELECT 'Network Analysis and Synthesis',           'NAS',   'DSC' FROM dual UNION ALL
SELECT 'Digital Electronics-I',                    'DE1',   'DSC' FROM dual UNION ALL
SELECT 'Signals and Systems',                      'SS',    'DSC' FROM dual UNION ALL
SELECT 'Electromagnetic Theory',                   'EMT',   'DSC' FROM dual UNION ALL
SELECT 'Linear Integrated Circuits',               'LIC',   'DSC' FROM dual UNION ALL
SELECT 'Control Systems',                          'CTRL',  'DSC' FROM dual UNION ALL
SELECT 'Digital Signal Processing',                'DSP',   'DSC' FROM dual UNION ALL
SELECT 'Analog Communication Systems',             'ACS',   'DSC' FROM dual UNION ALL
SELECT 'AVLSI',                                    'AVLSI', 'DSE' FROM dual UNION ALL
SELECT 'Hands-On CMOS VLSI Design',                'CMOS',  'DSC' FROM dual UNION ALL
SELECT 'Embedded Systems and Applications',        'ESA',   'DSC' FROM dual UNION ALL
SELECT 'Digital Communication Systems',            'DCS',   'DSC' FROM dual UNION ALL
SELECT 'Electrical Network Analysis',              'ENA',   'DSC' FROM dual UNION ALL
SELECT 'Electrical Machines-I',                    'EM1',   'DSC' FROM dual UNION ALL
SELECT 'Analog to Digital Electronic Circuits',    'ADEC',  'DSC' FROM dual UNION ALL
SELECT 'Electrical Machines-II',                   'EM2',   'DSC' FROM dual UNION ALL
SELECT 'Power Transmission and Distribution',      'PTD',   'DSC' FROM dual UNION ALL
SELECT 'Electrical and Electronic Measurements',   'EEM',   'DSC' FROM dual UNION ALL
SELECT 'Power System Analysis',                    'PSA',   'DSC' FROM dual UNION ALL
SELECT 'Switchgear and Protection',                'SGP',   'DSC' FROM dual UNION ALL
SELECT 'Embedded System Technologies',             'EST',   'DSC' FROM dual UNION ALL
SELECT 'Power Electronics',                        'PE',    'DSC' FROM dual UNION ALL
SELECT 'Electrical Drives',                        'ED',    'DSC' FROM dual UNION ALL
SELECT 'Skill Enhancement Course (pool)',          'SEC',   'SEC' FROM dual;


-- ---------------------------------------------------------------------
-- 3. ECE aur EE ke sem 3 se 7 tak ke offerings
--    Is baar derived table me branch ka code bhi hai, isliye
--    CROSS JOIN ki jagah branches se seedha JOIN hai.
-- ---------------------------------------------------------------------
INSERT INTO subject_offerings (subject_id, branch_id, semester, paper_code)
SELECT s.subject_id, b.branch_id, x.sem, x.code
FROM (
    SELECT 'ECE' br, 'EDC' sn, 3 sem, 'DSC-7' code FROM dual UNION ALL
    SELECT 'ECE', 'NAS',   3, 'DSC-8'       FROM dual UNION ALL
    SELECT 'ECE', 'DE1',   3, 'DSC-9'       FROM dual UNION ALL
    SELECT 'ECE', 'DSE',   3, 'DSE-1/GE-3'  FROM dual UNION ALL
    SELECT 'ECE', 'VAC',   3, NULL          FROM dual UNION ALL
    SELECT 'ECE', 'AEC',   3, NULL          FROM dual UNION ALL
    SELECT 'ECE', 'SS',    4, 'DSC-10'      FROM dual UNION ALL
    SELECT 'ECE', 'EMT',   4, 'DSC-11'      FROM dual UNION ALL
    SELECT 'ECE', 'LIC',   4, 'DSC-12'      FROM dual UNION ALL
    SELECT 'ECE', 'DSE',   4, 'DSE-2/GE-4'  FROM dual UNION ALL
    SELECT 'ECE', 'VAC',   4, NULL          FROM dual UNION ALL
    SELECT 'ECE', 'AEC',   4, NULL          FROM dual UNION ALL
    SELECT 'ECE', 'CTRL',  5, 'DSC-13'      FROM dual UNION ALL
    SELECT 'ECE', 'DSP',   5, 'DSC-14'      FROM dual UNION ALL
    SELECT 'ECE', 'ACS',   5, 'DSC-15'      FROM dual UNION ALL
    SELECT 'ECE', 'DSE',   5, 'DSE-3/GE-5'  FROM dual UNION ALL
    SELECT 'ECE', 'AVLSI', 5, NULL          FROM dual UNION ALL
    SELECT 'ECE', 'AEC',   5, NULL          FROM dual UNION ALL
    SELECT 'ECE', 'CMOS',  6, 'DSC-16'      FROM dual UNION ALL
    SELECT 'ECE', 'ESA',   6, 'DSC-17'      FROM dual UNION ALL
    SELECT 'ECE', 'DCS',   6, 'DSC-18'      FROM dual UNION ALL
    SELECT 'ECE', 'DSE',   6, 'DSE-4'       FROM dual UNION ALL
    SELECT 'ECE', 'AVLSI', 6, 'DSE-6'       FROM dual UNION ALL
    SELECT 'ECE', 'DSE',   7, 'DSE-5..8'    FROM dual UNION ALL

    SELECT 'EE',  'ENA',   3, 'DSC-7'       FROM dual UNION ALL
    SELECT 'EE',  'EM1',   3, 'DSC-8'       FROM dual UNION ALL
    SELECT 'EE',  'ADEC',  3, 'DSC-9'       FROM dual UNION ALL
    SELECT 'EE',  'DSE',   3, 'DSE-1/GE-3'  FROM dual UNION ALL
    SELECT 'EE',  'VAC',   3, NULL          FROM dual UNION ALL
    SELECT 'EE',  'AEC',   3, NULL          FROM dual UNION ALL
    SELECT 'EE',  'SEC',   3, NULL          FROM dual UNION ALL
    SELECT 'EE',  'EM2',   4, 'DSC-10'      FROM dual UNION ALL
    SELECT 'EE',  'PTD',   4, 'DSC-11'      FROM dual UNION ALL
    SELECT 'EE',  'EEM',   4, 'DSC-12'      FROM dual UNION ALL
    SELECT 'EE',  'DSE',   4, 'DSE-2/GE-4'  FROM dual UNION ALL
    SELECT 'EE',  'VAC',   4, NULL          FROM dual UNION ALL
    SELECT 'EE',  'AEC',   4, NULL          FROM dual UNION ALL
    SELECT 'EE',  'SEC',   4, NULL          FROM dual UNION ALL
    SELECT 'EE',  'PSA',   5, 'DSC-13'      FROM dual UNION ALL
    SELECT 'EE',  'CTRL',  5, 'DSC-14'      FROM dual UNION ALL
    SELECT 'EE',  'EMT',   5, 'DSC-15'      FROM dual UNION ALL
    SELECT 'EE',  'DSE',   5, 'DSE-3/GE-5'  FROM dual UNION ALL
    SELECT 'EE',  'VAC',   5, NULL          FROM dual UNION ALL
    SELECT 'EE',  'AEC',   5, NULL          FROM dual UNION ALL
    SELECT 'EE',  'SGP',   6, 'DSC-16'      FROM dual UNION ALL
    SELECT 'EE',  'EST',   6, 'DSC-17'      FROM dual UNION ALL
    SELECT 'EE',  'PE',    6, 'DSC-18'      FROM dual UNION ALL
    SELECT 'EE',  'DSE',   6, 'DSE-4'       FROM dual UNION ALL
    SELECT 'EE',  'GE',    6, 'GE-6'        FROM dual UNION ALL
    SELECT 'EE',  'ED',    7, NULL          FROM dual UNION ALL
    SELECT 'EE',  'DSE',   7, 'DSE-5..8'    FROM dual
) x
JOIN subjects s ON s.short_name  = x.sn
JOIN branches b ON b.branch_code = x.br;

COMMIT;


-- =====================================================================
-- CHECKS - ek-ek karke chalao
-- =====================================================================

-- (a) Har branch me kitni offerings          Expected: CSE 39, ECE 38, EE 41
SELECT b.branch_code, COUNT(*) AS offerings
FROM   subject_offerings o
JOIN   branches b ON b.branch_id = o.branch_id
GROUP  BY b.branch_code
ORDER  BY b.branch_code;

-- (b) Total subjects                         Expected: 49
SELECT COUNT(*) AS subjects FROM subjects;

-- (c) Ek hi subject, alag branch me alag code
--     Expected: CTRL -> ECE DSC-13, EE DSC-14  |  EMT -> ECE DSC-11, EE DSC-15
SELECT s.short_name, b.branch_code, o.semester, o.paper_code
FROM   subject_offerings o
JOIN   subjects s ON s.subject_id = o.subject_id
JOIN   branches b ON b.branch_id  = o.branch_id
WHERE  s.short_name IN ('CTRL', 'EMT')
ORDER  BY s.short_name, b.branch_code;
