SELECT * FROM employees WHERE job_id LIKE 'SA_%';

-- INSERT with subquery
-- INSERT all the representatives in "reps" table

-- First create the table
CREATE TABLE reps (
    emp_id NUMBER(4),
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    job_id VARCHAR(10),
    salary NUMBER(8,2)
);

-- INSERT data from "employees" table
INSERT INTO reps (emp_id, first_name, last_name, job_id, salary)
    SELECT employee_id, first_name, last_name, job_id, salary
    FROM employees
    WHERE job_id LIKE '%REP%';

-- Check the table
SELECT * FROM reps;

-- Create "copy_emp" table
-- In this table: minimum salary cannot be less than 0 and email must be unique
CREATE TABLE copy_emp (
    employee_id NUMBER(6),
    first_name VARCHAR2(20),
    last_name VARCHAR2(25)
    CONSTRAINT cp_emp_last_name_nn NOT NULL,
    email VARCHAR2(25)
    CONSTRAINT cp_emp_email_nn NOT NULL,
    phone_number VARCHAR2(20),
    hire_date DATE CONSTRAINT cp_emp_hire_date_nn NOT NULL,
    job_id VARCHAR2(10)
    CONSTRAINT cp_emp_job_nn NOT NULL,
    salary NUMBER(8,2),
    commission_pct NUMBER(2,2),
    manager_id NUMBER(6),
    department_id NUMBER(4),
    CONSTRAINT cp_emp_salary_min CHECK (salary > 0),
    CONSTRAINT cp_emp_email_uk UNIQUE (email)
    );

-- Make "employee_id" unique
CREATE UNIQUE INDEX cp_emp_emp_id_pk ON copy_emp (employee_id);

-- Make "employee_id" PRIMARY KEY, "department_id" FOREIGN KEY, "job_id" FOREIGN KEY, "manager_id" FOREIGN KEY
ALTER TABLE copy_emp ADD (
    CONSTRAINT cp_emp_emp_id_pk
    PRIMARY KEY (employee_id),
    CONSTRAINT cp_emp_dept_fk
    FOREIGN KEY (department_id) REFERENCES departments (department_id),
    CONSTRAINT cp_emp_job_fk
    FOREIGN KEY (job_id) REFERENCES jobs (job_id),
    CONSTRAINT cp_emp_manager_fk
    FOREIGN KEY (manager_id) REFERENCES copy_emp
    );

SELECT * FROM copy_emp WHERE employee_id = 117;

INSERT INTO copy_emp (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
    SELECT * FROM employees;

-- UPDATE values of copy_emp
UPDATE copy_emp
SET department_id = 50
WHERE employee_id = 113;

UPDATE copy_emp
SET job_id = 'IT_PROG', commission_pct = NULL
WHERE employee_id = 114;

-- Updating two columns with a subquery
UPDATE copy_emp
SET
job_id = (SELECT job_id FROM copy_emp WHERE employee_id = 205),
salary = (SELECT salary FROM copy_emp WHERE employee_id = 205)
WHERE employee_id = 113;

SELECT employee_id, job_id, salary FROM copy_emp WHERE employee_id = 113;
SELECT employee_id, job_id, salary FROM copy_emp WHERE employee_id = 205;

-- Updating two column with a subquery (compact way)
-- employee_id = 107 moved to the same position as employee_id = 110
UPDATE copy_emp
SET (job_id, salary, commission_pct, manager_id, department_id)
= (SELECT job_id, salary, commission_pct, manager_id, department_id
   FROM copy_emp
   WHERE employee_id = 110)
WHERE employee_id = 107;

SELECT employee_id, job_id, salary, commission_pct, manager_id, department_id
FROM copy_emp WHERE employee_id = 107;
SELECT employee_id, job_id, salary, commission_pct, manager_id, department_id
FROM copy_emp WHERE employee_id = 110;

-- Update data in one table from another table
-- Rollback the recent changes made in employee_id = 107
UPDATE copy_emp
SET (job_id, salary, commission_pct, manager_id, department_id)
= (SELECT job_id, salary, commission_pct, manager_id, department_id
   FROM employees
   WHERE employee_id = 107)
WHERE employee_id = 107;

SELECT employee_id, job_id, salary, commission_pct, manager_id, department_id
FROM copy_emp WHERE employee_id = 107;

-- DELETE using single value
DELETE FROM copy_emp WHERE employee_id = 107;
SELECT * FROM copy_emp;

-- DELETE using multiple value
DELETE FROM copy_emp WHERE department_id IN (30, 40);

-- DELETE all the representatives and clerks from copy_emp
DELETE FROM copy_emp WHERE job_id IN (
    SELECT job_id FROM copy_emp
    WHERE job_id LIKE '%REP%' OR job_id LIKE '%CLERK%' 
);

-- To empty the table and keep the structure intact we use "TRUNCATE"
TRUNCATE TABLE copy_emp;
SELECT * FROM copy_emp;

COMMIT;

SELECT * FROM copy_emp WHERE job_id = 'IT_PROG';
UPDATE copy_emp
SET first_name = 'Jude', last_name = 'Bellingham', email = 'HEYJUDE', salary = 5555, commission_pct = 0.5
WHERE employee_id = 103;

SELECT * FROM copy_emp WHERE employee_id = 103;

SAVEPOINT jude_bellingham;

UPDATE copy_emp
SET first_name = 'Toni', last_name = 'Kroos', email = 'Kr88s', salary = 8888, commission_pct = 0.8
WHERE employee_id = 103;

ROLLBACK TO SAVEPOINT jude_bellingham;

-- Create football_manager table
CREATE TABLE football_managers (
    manager_id NUMBER(3),
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    country VARCHAR(20)
);

-- Make "manager_id" unique
CREATE UNIQUE INDEX mng_id_pk ON football_managers (manager_id);

-- Make "manager_id" primary key
ALTER TABLE football_managers ADD (
    CONSTRAINT mng_id_pk PRIMARY KEY (manager_id)
);

SELECT * FROM football_managers;

INSERT INTO football_managers VALUES (101, 'Zinedine', 'Zidane', 'France');
INSERT INTO football_managers VALUES (102, 'Carlo', 'Anchelotti', 'Italy');
INSERT INTO football_managers VALUES (103, 'Pep', 'Gardiola', 'Spain');
INSERT INTO football_managers VALUES (104, 'Jose', 'Mourinho', 'Portugal');
INSERT INTO football_managers VALUES (105, 'Lionel', 'Scaloni', 'Argentina');
INSERT INTO football_managers VALUES (106, 'Gerath', 'Southgate', 'England');

-- COMMIT saves the all the progress made till now
COMMIT;

INSERT INTO football_managers VALUES (107, 'Luis', 'Van Gaal', 'Netherlands');
INSERT INTO football_managers VALUES (108, 'Alex', 'Ferguson', 'Scotland');

SELECT * FROM football_managers;

-- ROLLBACK rolls back to the latest COMMIT 
ROLLBACK;

-- FOR UPDATE checks for update in the database before showing results in SELECT
-- FOR UPDATE OF <column_name> checks for update of a certain column before showing results in SELECT 
SELECT * FROM football_managers
WHERE first_name LIKE '%o%'
FOR UPDATE
ORDER BY manager_id;

-- Example Table with CONSTRAINT
CREATE TABLE employees_table (
    employee_id NUMBER(6)
    CONSTRAINT emp_id_pk PRIMARY KEY,
    first_name VARCHAR(20)
    CONSTRAINT first_name_nn NOT NULL,
    last_name VARCHAR(20)
    CONSTRAINT last_name_nn NOT NULL,
    email VARCHAR(25)
    CONSTRAINT email_nn NOT NULL
    CONSTRAINT email_uq UNIQUE,
    phone_number VARCHAR(20)
    CONSTRAINT phn_num_nn NOT NULL
    CONSTRAINT phn_num_uq UNIQUE,
    hire_date DATE
    CONSTRAINT hr_date_nn NOT NULL,
    job_id VARCHAR(20)
    CONSTRAINT job_id_nn NOT NULL,
    salary NUMBER(8,2)
    CONSTRAINT salary_nn CHECK(salary > 0),
    commission_pct NUMBER(2,2),
    manager_id NUMBER(6)
    CONSTRAINT mng_id_fk REFERENCES departments (manager_id),
    department_id NUMBER(4)
    CONSTRAINT dept_id_fk REFERENCES departments (department_id)
);

-- Violating Constraints
-- You cannot delete a row that contains a primary key that is used as a foreign key in another table.

-- Creating table from a subquery
CREATE TABLE dept80
AS 
    SELECT employee_id, first_name, last_name, salary*12 ANSAL, hire_date
    FROM employees
    WHERE department_id = 80;

SELECT * FROM dept80;

ALTER TABLE employees READ ONLY;
-- perform table maintenance and then
-- return table back to read/write mode
ALTER TABLE employees READ WRITE;

-- Create a view for all the employees of department_id 80
CREATE OR REPLACE VIEW emp_view_80 (id_number, name, annual_salary, dept_id)
AS
    SELECT employee_id, first_name || ' ' || last_name, salary*12, department_id
    FROM employees
    WHERE department_id = 80;

SELECT * FROM emp_view_80;

-- Create a view that shows min_sal, max_sal, avg_sal, total_sal for each department
CREATE OR REPLACE VIEW dept_sal (dept_name, min_sal, max_sal, avg_sal, total_sal)
AS
    SELECT d.department_name, MIN(e.salary), MAX(e.salary), AVG(e.salary), SUM(e.salary)
    FROM employees e, departments d
    WHERE e.department_id = d.department_id
    GROUP BY (d.department_name);

SELECT * FROM dept_sal;

SELECT * FROM departments;

-- Create a sequence for department_id
CREATE SEQUENCE dept_deptid_seq
    INCREMENT BY 10
    START WITH 280
    MAXVALUE 9999
    NOCACHE
    NOCYCLE;

-- Insert a new department "Support" to the location_id = 2500
INSERT INTO departments (department_id, department_name, location_id)
VALUES (dept_deptid_seq.NEXTVAL, 'Support', 2500);

-- Check the Current value of dept_deptid_seq
SELECT dept_deptid_seq.CURRVAL FROM DUAL;

-- Change the sequence
ALTER SEQUENCE dept_deptid_seq
    INCREMENT BY 20
    MAXVALUE 1000
    NOCACHE
    NOCYCLE;

INSERT INTO departments (department_id, department_name, location_id)
VALUES (dept_deptid_seq.NEXTVAL, 'Maintenance', 2400);

SELECT dept_deptid_seq.CURRVAL FROM DUAL;

-- The HR department wants a query to display the last name, job ID, hire date, and
-- employee ID for each employee, with the employee ID appearing first. Provide an
-- alias STARTDATE for the HIRE_DATE column
SELECT employee_id, last_name, job_id, hire_date STARTDATE
FROM employees;

-- The HR department wants a query to display all unique job IDs from the EMPLOYEES table.
SELECT DISTINCT job_id FROM employees;

-- Name the column headings Emp #, Employee, Job, and Hire Date, respectively. 
SELECT employee_id "Emp #", last_name Employee, job_id Job, hire_date "Hire Date"
FROM employees;

-- The HR department wants a query to display all unique job IDs from the EMPLOYEES table
SELECT DISTINCT job_id FROM employees;

-- The HR department has requested a report of all employees and their job IDs. Display
-- the last name concatenated with the job ID (separated by a comma and space) and
-- name the column Employee and Title. 
SELECT last_name || ', ' || job_id "Employee and Title"
FROM employees;

--  Separate each column output by a comma. Name the column title THE_OUTPUT
SELECT employee_id || ', ' || first_name || ', ' || last_name || ', ' || email || ', ' || phone_number || ', ' || hire_date || ', ' || job_id || ', ' || salary || ', ' || commission_pct || ', ' || manager_id || ', ' || department_id "THE OUTPUT" FROM employees;

-- HR department needs a report that displays the last name and salary of employees who earn more than $12,000
SELECT last_name, salary
FROM employees
WHERE salary > 12000;

--  Create a report that displays the last name and department number for employee number 176
SELECT last_name, department_id
FROM employees
WHERE employee_id = 176;

-- The HR department needs to find high-salary and low-salary employees. Modify
-- previous query to display the last name and salary for any employee whose salary
-- is not in the range of $5,000 to $12,000.

SELECT last_name, salary
FROM employees
WHERE salary NOT BETWEEN 5000 AND 12000;

-- Create a report to display the last name, job ID, and hire date for employees with the
-- last names of Matos and Taylor. Order the query in ascending order by hire date.
SELECT last_name, job_id, hire_date
FROM employees
WHERE last_name = 'Matos' OR last_name = 'Taylor'
ORDER BY hire_date; 

-- Display the last name and department ID of all employees in departments 20 or 50 in ascending alphabetical order by name
SELECT last_name, department_id FROM employees
WHERE department_id IN (20, 50) ORDER BY last_name;

-- last name and salary of employees who earn
-- between $5,000 and $12,000, and are in department 20 or 50. Label the columns
-- Employee and Monthly Salary, respectively.
SELECT last_name Employee, salary "Monthly Salary" FROM employees
WHERE salary BETWEEN 5000 AND 12000 AND department_id IN (20, 50);

-- Displays the last name and hire date for all employees who were hired in 1994.
SELECT last_name, hire_date FROM employees
WHERE TO_CHAR(hire_date, 'YYYY') = '1994'; 

--  display the last name and job title of all employees who do not have a manager
SELECT last_name, job_id FROM employees
WHERE manager_id IS NULL;

-- Create a report to display the last name, salary, and commission for all employees
-- who earn commissions. Sort data in descending order of salary and commissions.
SELECT last_name, salary, commission_pct FROM employees
WHERE commission_pct IS NOT NULL
ORDER BY salary DESC, commission_pct DESC;

-- Members of the HR department want to have more flexibility with the queries that
-- you are writing. They would like a report that displays the last name and salary of
-- employees who earn more than an amount that the user specifies after a prompt
SELECT last_name, salary FROM employees
WHERE salary > &sal_amt; 

-- The HR department wants to run reports based on a manager. Create a query that
-- prompts the user for a manager ID and generates the employee ID, last name, salary,
-- and department for that manager’s employees. The HR department wants the ability
-- to sort the report on a selected column.
SELECT employee_id, last_name, salary, department_id
FROM employees
WHERE manager_id = &mng_id
ORDER BY &col_name;

-- Display all employee last names in which the third letter of the name is “a.” 
SELECT last_name FROM employees WHERE last_name LIKE '__a%';

-- Display the last names of all employees who have both an “a” and an “e” in their last name.
SELECT last_name FROM employees WHERE last_name LIKE '%a%' AND last_name LIKE '%e%'; 

-- Display the last name, job, and salary for all employees whose job is that of a sales
-- representative or a stock clerk, and whose salary is not equal to $2,500, $3,500, or $7,000.
SELECT last_name, job_id, salary FROM employees
WHERE job_id IN ('SL_REP', 'ST_CLERK')
AND salary NOT IN (2500, 3500, 7000);

-- display the last name, salary, and commission for all employees whose commission amount is 20%.
SELECT last_name, salary, commission_pct FROM employees
WHERE commission_pct = 0.2;

-- last_name and salary of employees earning more than $12,000.
SELECT last_name, salary FROM employees WHERE salary > 12000;

--  last name and department number for employee number 176.
SELECT last_name, department_id FROM employees WHERE employee_id = 176;

-- Write a query to display the system date.
SELECT SYSDATE "DATE" FROM DUAL;

--  The HR department needs a report to display the employee number, last name, salary,
-- and salary increased by 15.5% (expressed as a whole number) for each employee.
-- Label the column New Salary. 
SELECT employee_id, last_name, salary, ROUND(salary + salary*0.155) "New Salary"
FROM employees;

--Modify your query lab_03_02.sql to add a column that subtracts the old salary
--from the new salary. Label the column Increase
SELECT employee_id, last_name, salary "Old Salary", ROUND(salary + salary*0.155) "New Salary", ROUND(salary + salary*0.155) - salary "Increase"
FROM employees;

-- Write a query that displays the last name (with the first letter in uppercase and all the
--other letters in lowercase) and the length of the last name for all employees whose
--name starts with the letters “J,” “A,” or “M.” Give each column an appropriate label
SELECT INITCAP(last_name) "Name", LENGTH(last_name) "Length"
FROM employees
WHERE last_name LIKE 'J%' OR last_name LIKE 'A%' OR last_name LIKE 'M%';

-- Modify the query such that the case of the entered letter does not affect the output
SELECT INITCAP(last_name) "Name", LENGTH(last_name) "Length"
FROM employees
WHERE last_name LIKE UPPER('&start_letter%')
ORDER BY last_name;

--Create a query to display the last name and salary for all employees. Format the
--salary to be 15 characters long, left-padded with the $ symbol.
SELECT last_name, LPAD(salary, 15, '$') SALARY FROM employees;

--Create a query that displays the first eight characters of the employees’ last names
--and indicates the amounts of their salaries with asterisks. Each asterisk signifies a
--thousand dollars. Sort the data in descending order of salary
SELECT RPAD(last_name, 8) || ' ' || RPAD(' ', salary/1000+1, '*') "Employees and Their Salaries"
FROM employees
ORDER BY salary DESC;

-- Create a query to display the last name and the number of weeks employed for all
--employees in department 90. Label the number of weeks column TENURE. Truncate
--the number of weeks value to 0 decimal places. Show the records in descending order of the employee’s tenure.
SELECT last_name, TRUNC((SYSDATE - hire_date) / 7) AS TENURE
FROM employees
WHERE department_id = 90
ORDER BY TENURE DESC;

--Create a report that produces the following for each employee:
--<employee last name> earns <salary> monthly but wants <3 times salary.>.
SELECT last_name || ' earns ' || salary || ' monthly but wants ' || salary*3 AS "DREAM SALARY"
FROM employees;

-- Display the last name, hire date, and day of the week on which the employee started
SELECT last_name, hire_date, TO_CHAR(hire_date, 'DAY') DAY
FROM employees
ORDER BY TO_CHAR(hire_date - 1, 'd');

--Create a query that displays the employees’ last names and commission amounts. If
--an employee does not earn commission, show “No Commission.” Label the column COMM
SELECT last_name, NVL(TO_CHAR(commission_pct), 'No Commission') COMM
FROM employees;

-- Assign "Job Grade" for Job Titles
SELECT job_id, DECODE (job_id,
                        'AD_PRES', 'A',
                        'ST_MAN', 'B',
                        'IT_PROG', 'C',
                        'SA_REP', 'D',
                        'ST_CLERK', 'E', 0) "Job Grade"
from employees;

-- write the statement in the preceding exercise by using the CASE syntax.
SELECT job_id,
CASE job_id
    WHEN 'AD_PRES' THEN 'A'
    WHEN 'ST_MAN' THEN 'B'
    WHEN 'IT_PROG' THEN 'C'
    WHEN 'SA_REP' THEN 'D'
    WHEN 'SL_CLERK' THEN 'E'
    ELSE '0'
END "Job Grade"
FROM employees;

--Find the highest, lowest, sum, and average salary of all employees
SELECT MAX(salary) "Highest", MIN(salary) "Lowest", SUM(salary) "Total", ROUND(AVG(salary)) "Average"
FROM employees;

--minimum, maximum, sum, and average salary for each job type.
SELECT job_id "Job Title", MAX(salary) "Highest", MIN(salary) "Lowest", SUM(salary) "Total", ROUND(AVG(salary)) "Average"
FROM employees
GROUP BY job_id;

--find number of people with the same job title
SELECT job_id "JOB", COUNT(*)
FROM employees
GROUP BY job_id;

--Determine the number of managers without listing them
SELECT COUNT(DISTINCT manager_id) "Number of Managers" FROM employees;

-- Find the difference between the highest and lowest salaries
SELECT MAX(salary) - MIN(salary) DIFFERENCE
FROM employees;

-- Create a report to display the manager number and the salary of the lowest-paid
--employee for that manager. Exclude anyone whose manager is not known. Exclude
--any groups where the minimum salary is $6,000 or less. Sort the output in descending order of salary. 
SELECT manager_id, MIN(salary)
FROM employees
WHERE manager_id IS NOT NULL
GROUP BY manager_id
HAVING MIN(salary) > 6000
ORDER BY MIN(salary) DESC;

--Create a query that will display the total number of employees and, of that total, the
--number of employees hired in 1995, 1996, 1997, and 1998. Create appropriate column headings. 
SELECT COUNT(*) TOTAL,
SUM(DECODE(TO_CHAR(hire_date, 'YYYY'),1995,1,0)) "1995",
SUM(DECODE(TO_CHAR(hire_date, 'YYYY'),1996,1,0)) "1996",
SUM(DECODE(TO_CHAR(hire_date, 'YYYY'),1997,1,0)) "1997"
FROM employees;

--Write a query for the HR department to produce the addresses of all the departments.
--Use the LOCATIONS and COUNTRIES tables. Show the location ID, street address,
--city, state or province, and country in the output
SELECT location_id, street_address, city, state_province, country_name
FROM locations NATURAL JOIN countries;

--Write a query to display the last name, department number, and department name for all the employees.
SELECT last_name, department_id, department_name
FROM employees NATURAL JOIN departments; 

--Display the last name, job, department number, and department name for all employees who work in Toronto
SELECT last_name, job_id, department_id, department_name
FROM departments NATURAL JOIN employees NATURAL JOIN locations
WHERE city = 'Toronto';

--The HR department needs a query that prompts the user for an employee last name.
--The query then displays the last name and hire date of any employee in the same
--department as the employee whose name they supply (excluding that employee). For
--example, if the user enters Zlotkey, find all employees who work with Zlotkey (excluding Zlotkey). 

UNDEFINE Enter_name
SELECT last_name, hire_date
FROM employees
WHERE department_id = (SELECT department_id
 FROM employees
 WHERE last_name = '&&Enter_name')
AND last_name <> '&Enter_name'; 

-- Create a report that displays the employee number, last name, and salary of all
-- employees who earn more than the average salary. Sort the results in order of ascending salary.
SELECT employee_id, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary; 

--  Write a query that displays the employee number and last name of all employees who
-- work in a department with any employee whose last name contains a “u.”
SELECT employee_id, last_name
FROM employees
WHERE department_id IN (SELECT department_id FROM employees WHERE last_name LIKE '%u%');
--
--
--
--The HR department needs a report that displays the last name, department number,
--and job ID of all employees whose department location ID is 1700.
SELECT last_name, department_id, job_id
FROM employees
WHERE department_id IN (SELECT department_id
 FROM departments
 WHERE location_id = 1700); 

--Modify the query so that the user is prompted for a location ID
SELECT last_name, department_id, job_id
FROM employees
WHERE department_id IN (SELECT department_id
 FROM departments
 WHERE location_id =
&Enter_location);

-- Create a report for HR that displays the last name and salary of every employee who reports to King.
SELECT last_name, salary
FROM employees
WHERE manager_id = (SELECT employee_id
 FROM employees
 WHERE last_name = 'King'); 
 
-- Create a report for HR that displays the department number, last name, and job ID for every employee in the Executive department.
SELECT department_id, last_name, job_id
FROM employees
WHERE department_id IN (SELECT department_id
 FROM departments
 WHERE department_name =
'Executive'); 

--Create a report that displays a list of all employees whose salary is more than the salary of any employee from department 60.
SELECT last_name FROM employees
WHERE salary > ANY (SELECT salary
 FROM employees
 WHERE department_id=60); 
 
--display the employee number, last name,
--and salary of all employees who earn more than the average salary and who work in a
--department with any employee whose last name contains a “u.”
SELECT employee_id, last_name, salary
FROM employees
WHERE department_id IN (SELECT department_id
 FROM employees
 WHERE last_name like '%u%')
AND salary > (SELECT AVG(salary)
 FROM employees); 
 
--The HR department needs a list of department IDs for departments that do not contain
--the job ID ST_CLERK. Use the set operators to create this report.
SELECT department_id
FROM departments
MINUS
SELECT department_id
FROM employees
WHERE job_id = 'ST_CLERK'; 

--The HR department needs a list of countries that have no departments located in
--them. Display the country ID and the name of the countries. Use the set operators to create this report.
SELECT country_id,country_name
FROM countries
MINUS
SELECT l.country_id,c.country_name
FROM locations l JOIN countries c
ON (l.country_id = c.country_id)
JOIN departments d
ON d.location_id=l.location_id; 

--Produce a list of jobs for departments 10, 50, and 20, in that order. Display job ID and department ID using the set operators.
SELECT distinct job_id, department_id
FROM employees
WHERE department_id = 10
UNION ALL
SELECT DISTINCT job_id, department_id
FROM employees
WHERE department_id = 50
UNION ALL
SELECT DISTINCT job_id, department_id
FROM employees
WHERE department_id = 20;

--Create a report that lists the employee IDs and job IDs of those employees who
--currently have a job title that is the same as their job title when they were initially
--hired by the company (that is, they changed jobs, but have now gone back to doing their original job). 
SELECT employee_id, job_id
FROM employees
INTERSECT
SELECT employee_id, job_id
FROM job_history;

--The HR department needs a report with the following specifications:
--• Last name and department ID of all the employees from the EMPLOYEES table, regardless of whether or not they belong to a department
--• Department ID and department name of all the departments from the DEPARTMENTS table, regardless of whether or not they have employees working in them 
SELECT last_name, department_id, TO_CHAR(NULL)
FROM employees
UNION
SELECT TO_CHAR(NULL), department_id, department_name
FROM departments; 

SELECT * FROM copy_emp;

SAVEPOINT step_5;

DELETE FROM copy_emp;

SELECT * FROM copy_emp;

ROLLBACK TO step_5;

--Create sub-table
CREATE TABLE copy_emp2 AS
    SELECT employee_id, first_name, last_name, job_id, salary
    FROM employees;

SELECT * FROM copy_emp2;

--department no 50 wants a view where employee_id is empno, last_name is employee, department_id is deptno
CREATE OR REPLACE VIEW dept50 AS
    SELECT employee_id empno, last_name employee, department_id deptno
    FROM employees
    WHERE department_id = 50;

SELECT * FROM dept50;

CREATE TABLE copy_emp3 AS
    SELECT * FROM employees;

SELECT * FROM copy_emp3;

SAVEPOINT test_12345;

DELETE FROM copy_emp3;

ROLLBACK TO test_12345;
