--Table Creation
CREATE TABLE courses(
    course_id int primary key,
    course_code text,
    course_title text,
    course_grade text,
    course_credits int,
    course_points text,
    course_gpa text,
    comments text,
    CGPA text
);

CREATE TABLE enrolledsemester(
    semester_id int primary key,
    student_id int,
    semester text,
    credits_attempted int,
    credits_earned int,
    semester_points float,
    semester_gpa float
);

CREATE TABLE enrolledsemestercourses(
    Crs_id int primary key,
    semester_id int,
    course_id int,
    program_id int
);

CREATE TABLE feeder(
    feeder_id int primary key,
    feeder text
);

CREATE TABLE programs(
    program_id int primary key,
    program_name text,
    program_code text,
    program_degree text
);

CREATE TABLE student_info(
    student_id int primary key,
    feeder_id int,
    DOB text,
    gender text,
    ethnicity text,
    city text,
    district text,
    program_start text,
    programEnd text,
    program_status text,
    grad_date text
);

--Copying csv files.
COPY courses
FROM '/home/zhenitsu/Downloads/Courses.csv'
DELIMITER ','
CSV HEADER;

COPY enrolledsemester
FROM '/home/zhenitsu/Downloads/EnrolledSemester.csv'
DELIMITER ','
CSV HEADER;

COPY enrolledsemestercourses
FROM '/home/zhenitsu/Downloads/EnrolledSemesterCourses.csv'
DELIMITER ','
CSV HEADER;

COPY feeder
FROM '/home/zhenitsu/Downloads/Feeder.csv'
DELIMITER ','
CSV HEADER;

COPY programs
FROM '/home/zhenitsu/Downloads/programs.csv'
DELIMITER ','
CSV HEADER;

COPY student_info
FROM '/home/zhenitsu/Downloads/student_info.csv'
DELIMITER ','
CSV HEADER;

--Query Time.
--Acceptance Rates BINT.
SELECT 
COUNT(*) AS TOTAL_APPLICANTS, 
SUM(CASE WHEN program_status = 'Graduated' 
THEN 1 ELSE 0 END) AS Graduated, 
ROUND(100 * SUM(CASE WHEN program_status = 'Graduated' THEN 1 ELSE 0 END) / COUNT(*), 2) AS grad_rate
FROM student_info AS SI
JOIN enrolledsemester AS ES
ON SI.student_id = ES.student_id
JOIN enrolledsemestercourses AS ESC
ON ES.semester_id = ESC.semester_id
JOIN programs AS P
ON ESC.program_id = P.program_id
WHERE P.program_code = 'BINT';

--Acceptance Rates AINT.
SELECT 
COUNT(*) AS TOTAL_APPLICANTS, 
SUM(CASE WHEN program_status = 'Graduated' THEN 1 ELSE 0 END) AS Graduated, 
ROUND(100 * SUM(CASE WHEN program_status = 'Graduated' THEN 1 ELSE 0 END) / COUNT(*), 2) AS grad_rate
FROM student_info AS SI 
INNER JOIN programs AS P
ON SI.program_code = P.program_code
WHERE P.program_code = 'AINT';

--Rank Feeder Institutions
SELECT feeder.feeder, 
COUNT(*) AS total_applicants, 
SUM(CASE WHEN program_status = 'Graduated' THEN 1 ELSE 0 END) AS graduated, 
ROUND(100 * SUM(CASE WHEN program_status = 'Graduated' THEN 1 ELSE 0 END) / COUNT(*), 2) AS grad_rate, 
AVG(CAST(courses."CGPA" AS DECIMAL)) AS avg_cgpa
FROM student_info
INNER JOIN feeder ON student_info.feeder_id = feeder.feeder_id
INNER JOIN enrolledsemestercourses ON student_info.student_id = student_info.student_id
INNER JOIN programs ON enrolledsemestercourses.program_id = programs.program_id
INNER JOIN courses ON enrolledsemestercourses."Crs_id" = courses.course_id
WHERE programs.program_code IN ('AINT', 'BINT') 
GROUP BY feeder.feeder
ORDER BY grad_rate DESC, avg_cgpa DESC;

--Graduation Rates for BINT.
SELECT 
COUNT(*) AS total_graduates,
COUNT(program_status) * 100 / (SELECT COUNT(student_id) 
FROM student_info ) AS graduation_rate
FROM student_info
WHERE program_status = 'Graduated';

--Graduation Rates for AINT.
SELECT 
COUNT(*) AS total_graduates,
COUNT(*) * 100/ (SELECT COUNT(student_id) 
FROM student_info ) AS graduation_rate
FROM student_info
WHERE program_status = 'Graduated';

--Average Time to Graduate for BINT.
SELECT AVG((SI."programEnd"::date - SI.program_start::date)/365.0) AS avg_time
FROM student_info as SI
INNER JOIN programs as P
ON P.program_code = P.program_code
WHERE P.program_code = 'BINT';

--Average Time to Graduate for AINT.
SELECT 
AVG((student_info."programEnd"::date - student_info.program_start::date)/365.0) AS avg_time
FROM student_info
INNER JOIN programs AS P
ON P.program_code = P.program_code
WHERE P.program_code = 'AINT';

--My Queries.
--Students who are still in school.
SELECT student_id, program_start, program_status,
FROM student_info
WHERE program_status = 'In Process';

--Students that were in the Year 2004.
SELECT SI.student_id, ES.semester, P.program_name
FROM student_info AS SI 
JOIN enrolledsemester AS ES 
ON SI.student_id = ES.student_id
JOIN enrolledsemestercourses AS ESC 
ON ES.semester_id = ESC.semester_id
JOIN programs AS P 
ON ESC.program_id = P.program_id
WHERE semester LIKE '2004%'
ORDER BY semester ASC;

--Amount of students born before the year 2000.
SELECT 
COUNT(student_id) AS amount_born
FROM student_info
WHERE "DOB" < '2000-01-01';