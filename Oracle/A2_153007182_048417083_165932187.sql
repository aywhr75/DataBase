
-- **********************************


-- We weren't sure about the displayOrder column
-- We assume that the first Character of deptCode
-- is alphabet and second code could be number or alphabet
-- total 816 cases when we set the first character as an alphabet
CREATE TABLE a2departments (
    deptCode        CHAR(2)         PRIMARY KEY,
    deptName        VARCHAR2(50)    NOT NULL,
    officeNumber    VARCHAR2(7),
    displayOrder    NUMBER(3)
);


CREATE TABLE a2term (
    termCode         INTEGER        GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    termName         VARCHAR2(10)   NOT NULL,
    startDate        DATE           NOT NULL,
    endDate          DATE           NOT NULL
);

CREATE TABLE a2employees (
    empID           INTEGER         GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    firstName       VARCHAR2(20)    NOT NULL,
    lastName        VARCHAR2(20)    NOT NULL,
    prefix          VARCHAR2(8),
    suffix          VARCHAR2(8),
    isActive        NUMBER(1)       DEFAULT 1 NOT NULL CHECK (isActive IN (1,0)),
    sin             INTEGER         NOT NULL UNIQUE,
    dob             DATE            NOT NULL,
    email           VARCHAR2(30)    NOT NULL UNIQUE,
    phone           NUMBER(10)      NOT NULL
);

CREATE TABLE a2advisors (
    empID           INTEGER         PRIMARY KEY,
    isActive        NUMBER(1)       DEFAULT 1 NOT NULL CHECK(isActive IN (1,0)),
    
    CONSTRAINT  a2advisors_fk FOREIGN KEY(empID) REFERENCES a2employees(empID)
);

-- Assume that SENECA uses Alpha-2 code
CREATE TABLE a2countries (
    countryCode     CHAR(2)         PRIMARY KEY,
    countryName     VARCHAR2(56)    NOT NULL UNIQUE,
    continent       CHAR(2)         NOT NULL,
    isActive        NUMBER(1)       DEFAULT 1 NOT NULL CHECK(isActive IN (1,0))

);
CREATE TABLE a2courses (
    courseCode          CHAR(6)         PRIMARY KEY,
    courseName          VARCHAR2(50)    NOT NULL,
    courseDescription   VARCHAR2(300),
    isAvailable         NUMBER(1)       DEFAULT 1 NOT NULL CHECK(isAvailable IN (1,0)),
    termTaken           NUMBER(1)       NOT NULL 
);

CREATE TABLE a2programs (
    progCode        VARCHAR2(5)     PRIMARY KEY,
    progName        VARCHAR2(40)    NOT NULL,
    lengthYears     CHAR(1)         DEFAULT 2 NOT NULL CHECK(lengthYears > 0),
    isCurrent       NUMBER(1)       DEFAULT 1 NOT NULL CHECK(isCurrent IN (1,0)),
    deptCode        CHAR(2)         NOT NULL,
    
    CONSTRAINT  a2programs_fk       FOREIGN KEY (deptCode) REFERENCES a2departments(deptCode)
);

-- Student can choose M as Male and F as Female, and null option is available

CREATE TABLE a2students (
    studentID       INTEGER         GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    firstName       VARCHAR2(20)    NOT NULL,
    lastName        VARCHAR2(20)    NOT NULL,
    dob             DATE            NOT NULL,
    gender          CHAR(1),
    email           VARCHAR2(30)    NOT NULL UNIQUE,
    homeCountry     CHAR(2)         NOT NULL,
    phone           NUMBER(10)      NOT NULL,
    advisorID       INTEGER         NOT NULL,
    
    CONSTRAINT  a2students_fk_home     FOREIGN KEY(homeCountry)   REFERENCES a2countries(countryCode),
    CONSTRAINT  a2students_fk_advisor  FOREIGN KEY(advisorID)     REFERENCES a2advisors(empID)
);

CREATE TABLE a2professors (
    emplID          INTEGER         PRIMARY KEY,
    deptCode        CHAR(2)         NOT NULL,
    isActive        NUMBER(1)       DEFAULT 1 NOT NULL CHECK(isActive IN (1,0)),
    
    CONSTRAINT a2prof_fk_empl   FOREIGN KEY(emplID) REFERENCES a2employees(empID),
    CONSTRAINT a2prof_fk_dept   FOREIGN KEY(deptCode) REFERENCES a2departments(deptCode)
);

CREATE TABLE a2sections (
    sectionID       INTEGER         GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    sectionLetter   CHAR(3)         NOT NULL,
    courseCode      CHAR(6)         NOT NULL,
    termCode        INTEGER         NOT NULL,
    profID          INTEGER         NOT NULL,
    
    CONSTRAINT  a2sect_fl_cour  FOREIGN KEY(courseCode) REFERENCES a2courses(courseCode),
    CONSTRAINT  a2sect_fk_term  FOREIGN KEY(termCode)   REFERENCES a2term(termCode),
    CONSTRAINT  a2sect_fk_prof  FOREIGN KEY(profID)     REFERENCES a2professors(emplID)
);

CREATE TABLE a2jnc_students_sections (
    sectionID       INTEGER         PRIMARY KEY,
    studentID       INTEGER         NOT NULL,
    gradeObtained   VARCHAR2(4)     NOT NULL,
    isActive        NUMBER(1)       DEFAULT 1 NOT NULL CHECK(isActive IN (1,0)),
    
    CONSTRAINT a2jnc_stu_sec_fk_sect    FOREIGN KEY (sectionID) REFERENCES a2sections(sectionID),
    CONSTRAINT a2jnc_stu_sec_fk_stu     FOREIGN KEY (studentID) REFERENCES a2students(studentID)
);

CREATE TABLE a2jnc_prog_courses (
    progCourseID    INTEGER         GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    progCode        VARCHAR2(5)     NOT NULL,
    courseCode      CHAR(6)         NOT NULL,
    isActive        NUMBER(1)         DEFAULT 1 NOT NULL CHECK(isActive IN (1,0)),

    CONSTRAINT a2jnc_pro_cou_fk_prog    FOREIGN KEY (progCode) REFERENCES a2programs(progCode),
    CONSTRAINT a2jnc_pro_cou_fk_cour    FOREIGN KEY (courseCode) REFERENCES a2courses(courseCode)
);

CREATE TABLE a2jnc_prog_students (
    progCode        VARCHAR2(5)     NOT NULL,
    studentID       INTEGER         NOT NULL,
    isActive        NUMBER(1)       DEFAULT 1 NOT NULL CHECK(isActive IN (1,0)),

    CONSTRAINT a2jnc_pro_stu_pk PRIMARY KEY (progCode, studentID),
    CONSTRAINT a2jnc_pro_stu_fk_pro FOREIGN KEY (progCode) REFERENCES a2programs(progCode),
    CONSTRAINT a2jnc_pro_stu_fk_stu FOREIGN KEY (studentID) REFERENCES a2students(studentID)
);

INSERT INTO a2departments VALUES ('IT','Information and Communications Technology','N-K1433',1);
INSERT INTO a2term VALUES(NULL, 'SUMMER', TO_DATE('20190519', 'yyyymmdd'), TO_DATE('20190814','yyyymmdd'));
INSERT INTO a2term VALUES(NULL, 'FALL', TO_DATE('20190908', 'yyyymmdd'), TO_DATE('20191218', 'yyyymmdd'));
INSERT INTO a2term VALUES(NULL, 'WINTER', TO_DATE('20190111', 'yyyymmdd'), TO_DATE('20190423', 'yyyymmdd'));
INSERT INTO a2countries VALUES ('CA', 'Canada', 'NA', 1);
INSERT INTO a2countries VALUES ('KR', 'KOREA', 'AS', 1);

INSERT INTO a2employees VALUES (
    NULL, 'Clint', 'MacDonald', 'Mr', NULL, 1, 123456789,
        to_date('1973-03-10', 'yyyy-mm-dd'),
        'clint.macdonald@myseneca.ca', 4164915050);
        
INSERT INTO a2employees VALUES (
    NULL, 'Shazeela', 'Nabi', 'Mr', NULL, 1, 123456790,
        to_date('1963-05-20', 'yyyy-mm-dd'),
        'ShazeelaNabi@myseneca.ca', 4164915023);
        
INSERT INTO a2employees VALUES (
    NULL, 'Timothy', 'mckenna', 'Mr', NULL, 1, 123456791,
        to_date('1983-02-10', 'yyyy-mm-dd'),
        'timothyMK@myseneca.ca', 4164915220);
        
INSERT INTO a2employees VALUES (
    NULL, 'Peter', 'Liu', 'Mr', NULL, 1, 1234567892,
        to_date('1943-03-10', 'yyyy-mm-dd'),
        'peter.liu@myseneca.ca', 4164445050);
        
INSERT INTO a2employees VALUES (
    NULL, 'David', 'Humphrey', 'Mr', NULL, 1, 1234564444,
        to_date('1983-02-10', 'yyyy-mm-dd'),
        'David.H@myseneca.ca', 4164442473);
        
INSERT INTO a2employees VALUES (
    NULL, 'Ryan', 'Lockhart-Thompson', 'Mr', NULL, 1, 1432413245,
        to_date('1953-03-20', 'yyyy-mm-dd'),
        'ryan.lt@myseneca.ca', 4164919099);
        
INSERT INTO a2employees VALUES (
    NULL, 'Cindy', 'Laurin', 'Mrs', NULL, 1, 1432413431,
        to_date('1963-12-20', 'yyyy-mm-dd'),
        'cindy.la@myseneca.ca', 4164998367);

INSERT INTO a2employees VALUES (
    NULL, 'Kadeem', 'Best', 'Mr', NULL, 1, 1432422221,
        to_date('1973-03-20', 'yyyy-mm-dd'),
        'kadeem.be@myseneca.ca', 4164949381);
        
INSERT INTO a2employees VALUES (
    NULL, 'betrice', 'brangman', 'Ms', NULL, 1, 1432444444,
        to_date('1943-05-20', 'yyyy-mm-dd'),
        'betrice.br@myseneca.ca', 4164949381);
        
INSERT INTO a2employees VALUES (
    NULL, 'Hossein', 'Pourmodheji', 'Mr', NULL, 1, 1432423333,
        to_date('1983-04-20', 'yyyy-mm-dd'),
        'houssein.be@myseneca.ca', 4164949897);
        
INSERT INTO a2employees VALUES (
    NULL, 'Mary', 'Saith', 'Ms', NULL, 1, 1432422243,
        to_date('1983-02-12', 'yyyy-mm-dd'),
        'Mary.sa@myseneca.ca', 4164974741);

INSERT INTO a2employees VALUES (
    NULL, 'Najma', 'Ismat', 'Mrs', NULL, 1, 1432426666,
        to_date('1933-02-12', 'yyyy-mm-dd'),
        'NajmaIa@myseneca.ca', 4164971111);
    
INSERT INTO a2advisors VALUES(9, 1);
INSERT INTO a2students VALUES(NULL, 'Young A', 'Lee', TO_DATE('19750601', 'yyyymmdd'), 'F', 'yalee2@myseneca.ca', 'KR', 6472709690, 9);


INSERT INTO a2courses VALUES (
	'IPC144', 
    'Introduction to Programming Using C', 
    'This course covers the fundamental principles of computer programming, with an emphasis on problem solving strategies using structured programming techniques.',
    1,
    1
);
INSERT INTO a2courses VALUES (
	'APC100', 
    'Applied Professional Communications', 
    'This course focuses on self-awareness, group work, team building, interpersonal communication, presentation skills, conflict, and time management with applications to industry-specific settings.',
    1,
    1
);
INSERT INTO a2courses VALUES (
	'COM101', 
    'Communicating Across Contexts',
    'This course introduces students to the core concepts of communication. Students will cultivate an awareness of these concepts by analyzing how they are used in a variety of texts and contexts, and they will apply these concepts strategically in their own writing.',
    1,
    1
);
INSERT INTO a2courses VALUES (
	'CPR101',
    'Computer Principles for Programmers',
    'Students learn how modern computer systems implement process control, multitasking, virtualization, file storage, and network communications.',
    1,
    1
);
INSERT INTO a2courses VALUES (
	'ULI101', 
    'Introduction to UNIX/Linux and the Internet',
    'This subject introduces students to Unix, Linux and the Internet. Students will learn the core utilities to work productively in a Linux environment.',
    1,
    1
);
INSERT INTO a2courses VALUES (
	'DBS201', 
    'Introduction to Database Design and SQL', 
    'This subject introduces students to relational database design and SQL used with relational databases. Students will be introduced to  relational and object oriented models with a focus on the relational model and its operators',
    1,
    2
);

INSERT INTO a2courses VALUES (
	'DCF255',
    'Data Communications Fundamentals',
    'Using well-known and widely-used Internet applications and standard networking technology as examples, students will study and learn topics that explain how distributed applications work on a network.',
    1,
    2
);

INSERT INTO a2courses VALUES (
	'OOP244', 
    'Introduction to Object Oriented Programming',
    'This subject introduces the student to object-oriented programming. The student learns to build reusable objects, encapsulate data and logic within a class, inherit one class from another and implement polymorphism.',
    1,
    2
);

INSERT INTO a2courses VALUES (
	'WEB222',
    'Web Programming Principles',
    'This is an introductory course in web programming using JavaScript, CSS (cascading style sheets), HTML and the DOM (document object model) interface.' ,
    1,
    1
);
INSERT INTO a2courses VALUES (
	'DBS301', 
    'Database Design II and SQL Using Oracle',
    'This subject continues the study of database design and SQL begun in DBS201. Students will learn the entire set of SQL statements using the Oracle DBMS.',
    1,
    3
);

INSERT INTO a2courses VALUES (
	'OOP345',
    'Object-Oriented Software Development Using C++',
    'This subject continues the study of database design and SQL begun in DBS201. Students will learn the entire set of SQL statements using Oracle''s DBMS. Students will also learn Oracle''s SQL *Plus commands.',
    1,
    3
);

INSERT INTO a2courses VALUES (
	'SYS366',
    'Requirements Gathering Using OO Models',
    'This subject focuses on the techniques and tools involved in gathering requirements for business systems that will solve business stakeholders'' processing problems.',
    1,
    3
);

INSERT INTO a2courses VALUES (
	'WEB322', 
    'Web Programming Tools and Framework',
    'This course teaches students to design and create simple web applications and services, in JavaScript, using widely-used and powerful tools and frameworks.',
    1,
    3
);

INSERT INTO a2courses VALUES (
    'WTP100', 
    'Work Term Preparation', 
    'This mandatory course for WIL students prepares students to job search for their co-ops/work terms. Students will reflect on their skills, attitudes, and expectations and evaluate and interpret available opportunities in the workplace.',
    1,
    3
);

INSERT INTO a2programs VALUES (
    'CPA', 
    'Computer Programming and Analysis', 
    3, 
    1, 
    'IT'
);

INSERT INTO a2professors VALUES (
    1, 'IT', 1
);
INSERT INTO a2professors VALUES (
    2, 'IT', 1
);
INSERT INTO a2professors VALUES (
    3, 'IT', 1
);
INSERT INTO a2professors VALUES (
    4, 'IT', 1
);
INSERT INTO a2professors VALUES (
    5, 'IT', 1
);
INSERT INTO a2professors VALUES (
    6, 'IT', 1
);
INSERT INTO a2professors VALUES (
    7, 'IT', 1
);
INSERT INTO a2professors VALUES (
    8, 'IT', 1
);
INSERT INTO a2professors VALUES (
    10, 'IT', 1
);
INSERT INTO a2professors VALUES (
    11, 'IT', 1
);
INSERT INTO a2professors VALUES (
    12, 'IT', 1
);


-- 1st
INSERT INTO a2sections VALUES (
    NULL, 'NAB', 'IPC144', 1, 2
);
INSERT INTO a2sections VALUES (
    NULL, 'NAB', 'CPR101', 1, 3
);
INSERT INTO a2sections VALUES (
    NULL, 'NAB', 'ULI101', 1, 12
);

-- 2nd
INSERT INTO a2sections VALUES (
    NULL, 'NDE', 'DBS201', 2, 1
);
INSERT INTO a2sections VALUES (
    NULL, 'NDE', 'DCF255', 2, 6
);
INSERT INTO a2sections VALUES (
    NULL, 'NDE', 'OOP244', 2, 4
);
INSERT INTO a2sections VALUES (
    NULL, 'NDE', 'WEB222', 2, 5
);

-- 3rd
INSERT INTO a2sections VALUES (
    NULL, 'NDD', 'OOP345', 3, 10
);
INSERT INTO a2sections VALUES (
    NULL, 'NDD', 'SYS366', 3, 7
);
INSERT INTO a2sections VALUES (
    NULL, 'NDD', 'WEB322', 3, 8
);
INSERT INTO a2sections VALUES (
    NULL, 'NDD', 'DBS301', 3, 1
);
INSERT INTO a2sections VALUES (
    NULL, 'NDD', 'WTP100', 3, 11
);


INSERT INTO a2jnc_students_sections VALUES(1, 1, 'A', 1);
INSERT INTO a2jnc_students_sections VALUES(2, 1, 'A+', 1);
INSERT INTO a2jnc_students_sections VALUES(3, 1, 'B+', 1);
INSERT INTO a2jnc_students_sections VALUES(4, 1, 'B', 1);
INSERT INTO a2jnc_students_sections VALUES(5, 1, 'FAIL', 1);
INSERT INTO a2jnc_students_sections VALUES(6, 1, 'B+', 1);
INSERT INTO a2jnc_students_sections VALUES(7, 1, 'PASS', 1);
INSERT INTO a2jnc_students_sections VALUES(8, 1, 'A+', 1);
INSERT INTO a2jnc_students_sections VALUES(9, 1, 'DNC', 1);
INSERT INTO a2jnc_students_sections VALUES(10, 1, 'A+', 1);
INSERT INTO a2jnc_students_sections VALUES(11, 1, 'A+', 1);
INSERT INTO a2jnc_students_sections VALUES(12, 1, 'PASS', 1);

INSERT INTO a2jnc_prog_courses VALUES (
    NULL, 'CPA', 'IPC144', 1
);
INSERT INTO a2jnc_prog_courses VALUES (
    NULL, 'CPA', 'CPR101', 1
);
INSERT INTO a2jnc_prog_courses VALUES (
    NULL, 'CPA', 'ULI101', 1
);
INSERT INTO a2jnc_prog_courses VALUES (
    NULL, 'CPA', 'DBS201', 1
);
INSERT INTO a2jnc_prog_courses VALUES (
    NULL, 'CPA', 'DCF255', 1
);
INSERT INTO a2jnc_prog_courses VALUES (
    NULL, 'CPA', 'OOP244', 1
);
INSERT INTO a2jnc_prog_courses VALUES (
    NULL, 'CPA', 'WEB222', 1
);
INSERT INTO a2jnc_prog_courses VALUES (
    NULL, 'CPA', 'OOP345', 1
);
INSERT INTO a2jnc_prog_courses VALUES (
    NULL, 'CPA', 'SYS366', 1
);
INSERT INTO a2jnc_prog_courses VALUES (
    NULL, 'CPA', 'WEB322', 1
);
INSERT INTO a2jnc_prog_courses VALUES (
    NULL, 'CPA', 'DBS301', 1
);
INSERT INTO a2jnc_prog_courses VALUES (
    NULL, 'CPA', 'WTP100', 1
);

INSERT INTO a2jnc_prog_students VALUES (
    'CPA', 1, 1
);

-- i.	A student transcript that contains all the courses taken 
-- and the marks obtained for each student

-- Create student information on first table with studentId
-- Calculate each student's total GPA and Union two table
-- Order by student number and course DESC to formatting

CREATE OR REPLACE VIEW a2VWStudentTranscript AS (
SELECT *
    FROM(
        SELECT *
            FROM ((
                SELECT   studentID,
                         RPAD(firstName || ' ' || lastName, 25) Name, 
                         courseCode Course,
                         gradeObtained Grade                 
                    FROM a2students JOIN a2jnc_students_sections USING(studentID)
                        JOIN a2sections USING(sectionID))
                    
                UNION ALL
            
                (SELECT  studentID,
                         'Total GPA' Name,
                         ' ',
                          TO_CHAR((SELECT avg(grade) FROM(
                                        SELECT studentID, (
                                            CASE upper(gradeObtained)
                                                WHEN 'A+' THEN 4.0
                                                WHEN 'A' THEN 4.0
                                                WHEN 'B+' THEN 3.5
                                                WHEN 'B' THEN 3.0
                                                WHEN 'C+' THEN 2.5
                                                WHEN 'C' THEN 2.0
                                                WHEN 'D+' THEN 1.5
                                                WHEN 'D' THEN 1.0
                                                WHEN 'PASS' THEN null
                                                    ELSE 0
                                            END) AS grade
                                            FROM a2jnc_students_sections)
                                            GROUP BY studentID)) AS Grade
                            FROM A2students)
             )
             ORDER BY studentID, course DESC
             )
     );
    
select * from a2VWStudentTranscript;

        
    
-- ii.	A Class list for students enrolled in a particular course section

-- We thought this question could mean 2 possible answer, so we wrote both of them
-- When we enter the section letter, it will show all the classes with the same section Number
-- In our first semester, our schedule was fixed, and same section had same class list

CREATE OR REPLACE VIEW a2vwSectionClass AS (
    SELECT  courseCode,
            courseName,
            courseDescription description,
            termTaken term
        FROM a2sections JOIN a2courses USING (courseCode)
        WHERE upper(sectionLetter) LIKE upper('&sectionLetter_ex_NDE')
);
SELECT * FROM a2vwSectionClass;

-- Interpreting the question as a list of enrolled students in the section 
-- of a particular course, results in the following queries:

CREATE OR REPLACE VIEW a2vwSectionStudents AS (
    SELECT firstName ||', ' || lastName AS "Student Name",
            studentID AS "Student ID",
            courseCode || sectionLetter AS "Course Section"
        FROM a2students JOIN a2jnc_students_sections USING(studentID)
            JOIN a2sections USING (sectionID)
        WHERE upper(courseCode) LIKE upper('&courseCode_ex_DBS301')
            AND upper(sectionLetter) LIKE upper('&sectionLetter_ex_NDE')
);

SELECT * FROM a2vwSectionStudents;

-- iii.	The average mark for each section and the professor whom instructed it

-- Prints Average mark and order by section to compare grades between professors

CREATE OR REPLACE VIEW a2vwSectionStudents AS (
    SELECT * FROM (
        SELECT  p.emplID AS "Employee ID",
                firstName || ', ' || lastName AS "Name",
                courseCode || sectionLetter AS "Section", 
                "Avg grade"
            FROM a2employees e JOIN a2professors p ON e.empID = p.emplID 
                JOIN a2Sections s ON e.empID = s.profID 
                JOIN (SELECT  sectionID, 
                    AVG(CASE upper(gradeObtained)
                        WHEN 'A+' THEN 4.0
                        WHEN 'A' THEN 4.0
                        WHEN 'B+' THEN 3.5
                        WHEN 'B' THEN 3.0
                        WHEN 'C+' THEN 2.5
                        WHEN 'C' THEN 2.0
                        WHEN 'D+' THEN 1.5
                        WHEN 'D' THEN 1.0
                        WHEN 'PASS' THEN 4.0
                        ELSE  0
                    END) AS "Avg grade"
                    FROM a2jnc_students_sections
                    GROUP BY sectionID
                ) USING(sectionID)
            ORDER BY "Section", "Avg grade" DESC
    )
);
    
SELECT * FROM A2VWSECTIONSTUDENTS;
    
--iv. An output of all the courses required for each program sorted by program name and the term required.

-- Format the termTaken to make it visually appealing

CREATE OR REPLACE VIEW a2vwProgramCourses AS (
    SELECT * FROM(
        SELECT  progCode, 
                progName, 
                courseCode, 
                courseName,
                TO_CHAR(TO_DATE(termTaken, 'dd'), 'fmddth') || ' Semester' term
            FROM a2programs JOIN a2jnc_prog_courses USING(progCode) LEFT JOIN a2courses USING (courseCode)
            ORDER BY progCode, term
    )
);

SELECT * FROM a2vwProgramCourses;

-- v.	A term specific list of which professors are teaching which courses and how many students are enrolled
--      in each course section.  Remember that professors can teach more than one section of the same course each term.

--      Create a view of all course code, name, section, professor name, term and count students in their class

CREATE OR REPLACE VIEW a2vwTermInfo AS (
    SELECT *
        FROM(
            SELECT  courseCode "Course Code",
                    courseName "Course Name",
                    sectionLetter Section,
                    firstName ||' '|| lastName "PROFESSOR NAME",
                    count(studentID) "TOTAL STUDENTS",
                    TO_CHAR(TO_DATE(termCode, 'dd'), 'fmddth') term
                    FROM a2employees JOIN a2sections ON a2employees.empID = a2sections.profID
                        RIGHT JOIN a2courses USING (courseCode)
                        RIGHT JOIN a2jnc_students_sections USING (sectionID)
                    GROUP BY termCode, firstName ||' '|| lastName, courseCode, courseName, sectionLetter
                    ORDER BY termCode
            )
);
SELECT * FROM a2vwTermInfo;


/*
   -- End of the reporting.
    -- Set Permission to user_info:
    -- Only allow select for to selected user(user_info, probably professor Clint)
    
 GRANT SELECT ON a2departments TO user_info;
 GRANT SELECT ON a2term TO user_info;
 GRANT SELECT ON a2employees TO user_info;
 GRANT SELECT ON a2advisors TO user_info;
 GRANT SELECT ON a2countries TO user_info;
 GRANT SELECT ON a2courses TO user_info;
 GRANT SELECT ON a2programs TO user_info;
 GRANT SELECT ON a2students TO user_info;
 GRANT SELECT ON a2professors TO user_info;
 GRANT SELECT ON a2sections TO user_info;
 GRANT SELECT ON a2jnc_students_sections TO user_info;
 GRANT SELECT ON a2jnc_prog_courses TO user_info;
 GRANT SELECT ON a2jnc_prog_students TO user_info;
 GRANT SELECT ON a2vwTermStats TO user_info;  
 GRANT SELECT ON a2VWStudentTranscript TO user_info; 
 GRANT SELECT ON a2vwSectionStudents TO user_info; 
 GRANT SELECT ON a2vwProgramCourses TO user_info; 
 GRANT SELECT ON a2vwTermStats TO user_info; 
 
 -- End of Permission Setting.
-- End of Assignment 2.
*/

-- Deletion Queries

DROP TABLE A2JNC_PROG_STUDENTS;
DROP TABLE A2JNC_PROG_COURSES;
DROP TABLE A2JNC_STUDENTS_SECTIONS;
DROP TABLE A2SECTIONS;
DROP TABLE A2PROFESSORS;
DROP TABLE A2STUDENTS;
DROP TABLE A2PROGRAMS;
DROP TABLE A2COURSES;
DROP TABLE A2COUNTRIES;
DROP TABLE A2ADVISORS;
DROP TABLE A2EMPLOYEES;
DROP TABLE A2TERM;
DROP TABLE A2DEPARTMENTS;
