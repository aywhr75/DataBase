*********************************

/* Question 1. 
Display the employee number, full employee name, job and hire date of all
 employees hired in May or November of any year, with the most recently hired
 employees displayed first.
 
 exclude people hired in 2015 and 2016.  
 Full name should be in the form ?œLastname,  Firstname?? 
 Hire date should be in the form of [May 31<st,nd,rd,th> of 2016]
*/

-- Use RPAD function to set width, and use proper format to convert date into character
-- Solution 1.

SELECT  employee_id, 
        RPAD(last_name || ' ' || first_name , 25) "Full Name",
        job_id, 
        to_char(Last_day(hire_date), 'fm[Month ddth "of" yyyy]') "Hire_date"
    FROM employees
    WHERE to_char(hire_date, 'mm') IN (05, 11) 
        AND to_char(hire_date, 'yyyy') NOT IN (2015, 2016)
    ORDER BY hire_date DESC;

/* Question 2. 
List the employee number, full name, job and the modified salary for all 
 employees whose monthly earning is outside the range 
 $6,000 ??$11,000 and who are employed as Vice Presidents or Managers.
*/


-- Use || to concatenate strings
-- Use Case function to set different behaviors depend on the condition
-- Solution 2.

SELECT  'Emp#' || ' ' || 
        employee_id || ' named ' || 
        first_name || ' ' || 
        last_name || ' who is ' ||
        job_id || ' will have a new salary of ' || 
        to_char((salary + salary * (CASE WHEN upper(job_id) LIKE '%VP' THEN 0.25 
                                        ELSE 0.18 END)), 'fm$99999')
        "Employees with increased Pay"
        FROM employees
        WHERE (salary < 6000 OR salary > 11000) AND (upper(job_id) LIKE '%VP' OR upper(job_id) LIKE '%MAN' OR upper(job_id) LIKE '%MGR')
        ORDER BY salary DESC;
    
/* Question 3. 
Display the employee last name, salary, job title and manager# of all
employees not earning a commission OR if they work in the SALES department, 
but only  if their total monthly salary with $1000 included bonus and  
commission (if  earned) is  greater  than  $15,000.
*/

-- Use NVL to show 'NONE' when the value is NULL
-- Set Total Income column by adding bonus and calculate annual amount of income
-- Solution 3.

SELECT  last_name, 
        salary, 
        job_id, 
        NVL(to_char(manager_id), 'NONE') "Manager#", 
        to_char(((salary + 1000) * 12), '$999,999.99') "Total Income"
    FROM employees
    WHERE (commission_pct IS NULL 
        OR department_id IN (
            SELECT department_id 
                FROM departments 
                WHERE upper(department_name) = 'SALES'
            )
        ) AND 1000 + salary * (
            CASE WHEN commission_pct IS NULL THEN 1 
                ELSE (1 + commission_pct) END) > 15000
    ORDER BY "Total Income" DESC;
        
/* Question 4. 
Display Department_id, Job_id and the Lowest salary for this combination 
under the alias Lowest Dept/Job Pay, but only if that Lowest Pay falls in
the range $6000 - $17000. Exclude people who work as some kind of 
Representative job from this query and departments IT and SALES as well.
*/

-- Set LIKE keywords to use wildcards
-- Solution 4.

SELECT department_id, job_id, min(salary) "Lowest Dept/Job Pay"
    FROM employees
    WHERE upper(job_id) NOT LIKE '%REP%'
            AND upper(job_id) NOT LIKE 'IT%'
            AND upper(job_id) NOT LIKE 'SA%'
    GROUP BY department_id, job_id
    HAVING min(salary) >= 6000 AND min(salary) <= 17000
    ORDER BY department_id, job_id;

/* Question 5. 
Display last_name, salary and job for all employees who earn more than
all lowest paid employees per department outside the US locations.
*/

-- Select minimum salary of employees who does not working in US
-- Sort out President and Vice President using wildcards
-- Solution 5.

SELECT last_name, salary, job_id
    FROM employees 
    WHERE salary > ALL (
        SELECT MIN(salary)
            FROM employees 
                JOIN departments USING(department_id) 
                JOIN locations USING(location_id)
            WHERE upper(country_id) != 'US'
            GROUP BY department_id
        ) AND upper(job_id) NOT LIKE '%PRES'
        AND upper(job_id) NOT LIKE '%VP'
    ORDER BY job_id;

  
/* Question 6. 
Who are the employees (show last_name, salary and job) who work either in
IT or MARKETING department and earn more than the worst paid person in the 
ACCOUNTING department. 
*/

-- Select department_id of IT, Marketing department
-- Get lowest salary in the accounting department
-- Solution 6.

SELECT  last_name, salary, job_id
    FROM employees
    WHERE department_id IN (
        SELECT department_id 
            FROM departments 
            WHERE upper(department_name) IN ('IT', 'MARKETING')
        ) AND salary > (
            SELECT min(salary) 
                FROM employees 
                WHERE department_id IN (
                    SELECT department_id 
                        FROM departments 
                        WHERE upper(department_name) IN ('ACCOUNTING')))
    ORDER BY last_name;

/* Question 7. 
Display alphabetically the full name, job, salary and department 
number for each employee who earns less than the best paid unionized 
employee
*/

-- Select maximum salary of employees who is not President, VP, Manager
-- Get the department_id of department_name SALES and MARKETING
-- Solution 7.

SELECT  RPAD(first_name || ' ' || last_name, 25) "Employee", 
        job_id, 
        LPAD(to_char(salary, '$99,999'), 15, '=') "Salary", 
        department_id
    FROM employees
    WHERE salary < (
        SELECT max(salary) 
            FROM employees 
            WHERE upper(job_id) NOT LIKE '%PRES'
                AND upper(job_id) NOT LIKE '%VP'
                AND upper(job_id) NOT LIKE '%MAN'
                AND upper(job_id) NOT LIKE '%MGR'
        ) AND department_id IN (
            SELECT department_id 
                FROM departments 
                WHERE upper(department_name) IN ('SALES', 'MARKETING'))
    ORDER BY "Employee";                

/* Question 8.
Display department name, city and number of different jobs in each department. 
If city is null, you should print Not Assigned Yet.
*/

-- Using left join to include all the data of employees 
-- and full outer join to get all the data from both side
-- count job_id group by department name first and city
-- For better formatting, use substr function to set the proper width
-- Solution 8.

SELECT  department_name, 
        SUBSTR(NVL(city, 'Not Assigned Yet'), 0, 24) "City", 
        COUNT(job_id) "# of Jobs"
    FROM employees e LEFT JOIN departments d USING (department_id)
        FULL OUTER JOIN locations l USING (location_id)
    GROUP BY department_name, city;
    
    
    