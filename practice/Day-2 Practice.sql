-- Create "departments" table
CREATE TABLE departments (
  department_id NUMBER(6) NOT NULL PRIMARY KEY,
  department_name VARCHAR2(20) NOT NULL,
  manager_id NUMBER(6)
);

-- Create "jobs" table
CREATE TABLE jobs (
  job_id NUMBER(6) NOT NULL PRIMARY KEY,
  job_title VARCHAR2(20) NOT NULL,
  min_salary NUMBER(10,2),
  max_salary NUMBER(10,2)
);

-- Create "employees" table
CREATE TABLE employees (
  employee_id NUMBER(6) NOT NULL PRIMARY KEY,
  first_name VARCHAR(20),
  last_name VARCHAR(25) NOT NULL,
  email VARCHAR(25) NOT NULL,
  phone_number VARCHAR(20),
  hire_date DATE NOT NULL,
  job_id NUMBER(6) NOT NULL,
  salary NUMBER(8,2),
  commission_pct NUMBER(2,2),
  manager_id NUMBER(6),
  department_id NUMBER(4)
);

-- Make "job_id" as foreign key
ALTER TABLE employees
ADD CONSTRAINT fk_job_id
FOREIGN KEY (job_id)
REFERENCES jobs (job_id);

-- Make "manager_id" as foreign key
ALTER TABLE employees
ADD CONSTRAINT fk_manager_id
FOREIGN KEY (manager_id)
REFERENCES departments (department_id);

-- Insert data into "department" table
INSERT INTO departments (department_id, department_name, manager_id) VALUES (5, 'IT', 500);

-- Insert data into "jobs" table
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES (503, 'SFT_DEV', 50000.00, 70000.00);

-- Insert data into "employees" table\
INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id)
VALUES (17, 'Jude', 'Bellingham', 'bellingham@gmail.com', '1111111111', '05-JUN-19', 503, 65000, 0.2, NULL, 5);

-- Display tables
SELECT * FROM employees;
SELECT * FROM jobs;
SELECT * FROM departments;

SELECT employee_id, first_name, last_name, salary
FROM employees;

-- Aliases
SELECT first_name, last_name, salary*12 "Annual Salary"
FROM employees;

-- Concatenating Columns
SELECT last_name || job_id AS "Employees" FROM employees;

-- Writing Literal Character Strings
SELECT last_name || ' is a ' || job_id AS "Employee Details"
FROM employees;

-- Quote (q) Operator
SELECT department_name || q'[ Department's Manager ID: ]' || manager_id
AS "Department and Manager"
FROM departments;

-- Salary between 65000 to 80000
SELECT first_name, last_name, salary
FROM employees
WHERE salary BETWEEN 65000 AND 80000;

-- Find the number of employees earning between 65000 and 80000
SELECT salary, COUNT(salary) AS "Number of Employees"
FROM employees
WHERE salary BETWEEN 65000 AND 80000
GROUP BY salary;

-- Find employees who are manager in other 4 departments
SELECT first_name, last_name, manager_id, salary
FROM employees
WHERE manager_id IN (200, 300, 400, 500);

-- Find all the employees who have "JR" in their last_name
SELECT employee_id, first_name, salary
FROM employees
WHERE last_name LIKE '%JR%';

-- Find all employees who were hired in 1993
SELECT first_name, last_name, hire_date
FROM employees
WHERE hire_date LIKE '%93';

-- Find all employees who have 'e' on the 2nd position of their first_name
SELECT first_name, last_name, salary
FROM employees
WHERE last_name LIKE '_e%';

-- Escape '_' in the query
SELECT job_id, job_title, max_salary
FROM jobs
WHERE job_title LIKE 'SL_%';

-- Case conversion search
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE LOWER(last_name) = 'jr';

-- TRUNC and ROUND in hire_date
SELECT employee_id, first_name, last_name, TRUNC(hire_date, 'YEAR')
FROM employees
WHERE hire_date LIKE '%93';

SELECT employee_id, first_name, last_name, ROUND(hire_date, 'YEAR')
FROM employees
WHERE hire_date LIKE '%93';

SELECT first_name, last_name, TO_CHAR(salary, '$99,999.00')
AS SALARY
FROM employees;

SELECT first_name, last_name, TO_CHAR(salary, '$99,999.00')
AS SALARY
FROM employees
WHERE first_name='Paul';

-- NVL2
SELECT first_name, salary, commission_pct, NVL2(commission_pct, 'SAL+COM', 'SAL') AS INCOME
FROM employees;

-- NULLIF
SELECT first_name, LENGTH(last_name) expr1, last_name, LENGTH(last_name) expr2,
NULLIF (LENGTH(first_name), LENGTH(last_name)) RESULT
FROM employees;

-- If there is no commission then add 2000 with the salary otherwise add commission to the salary
SELECT employee_id, first_name, last_name, commission_pct,
COALESCE (salary+(salary*commission_pct), salary+2000) AS NEW_SALARY
FROM employees;

-- Add 10% salary increase to IT employees, 15% increase to Finance employees, 20% increase to Sales employees
-- Also format the salary correctly
SELECT first_name, last_name, department_id, TO_CHAR(salary, '$99,999.00') AS PREVIOUS_SALARY,
CASE department_id
    WHEN 5 THEN TO_CHAR(1.10*salary, '$99,999.00')
    WHEN 2 THEN TO_CHAR(1.15*salary, '$99,999.00')
    WHEN 4 THEN TO_CHAR(1.20*salary, '$99,999.00')
END REVISED_SALARY
FROM employees
WHERE department_id IN (2,4,5);

SELECT last_name, job_id, TO_CHAR(salary, '$99,999.00') PREVIOUS_SALARY,
DECODE (department_id,
            5, TO_CHAR(1.10*salary, '$99,999.00'),
            2, TO_CHAR(1.15*salary, '$99,999.00'),
            4, TO_CHAR(1.20*salary, '$99,999.00')) REVISED_SALARY
FROM employees
WHERE department_id IN (2,4,5);

-- COUNT(*) return all the number of rows
SELECT COUNT(*)
FROM employees
WHERE department_id = 5;

-- Find AVG salary of each department
SELECT department_id, AVG(salary)
FROM employees
GROUP BY department_id
ORDER BY department_id;

-- Find total salary of each department
SELECT department_id, SUM(salary)
FROM employees
GROUP BY department_id
ORDER BY department_id;

-- JOINS by USING function
SELECT employee_id, last_name, department_id, department_name
FROM employees JOIN departments
USING(department_id);

-- JOINS by ON clause
SELECT e.employee_id, e.last_name, d.department_id, d.department_name
FROM employees e JOIN departments d
ON e.department_id = d.department_id;

-- 3-way JOIN
-- Find the job title and department name for each employees
SELECT e.employee_id, e.first_name, e.last_name, j.job_title, d.department_name
FROM employees e JOIN jobs j
ON e.job_id = j.job_id
JOIN departments d
ON e.department_id = d.department_id;

-- Use WHERE clause to apply filter on JOINS
SELECT e.employee_id, e.first_name, e.last_name, j.job_title, d.department_name
FROM employees e JOIN jobs j
ON e.job_id = j.job_id
JOIN departments d
ON e.department_id = d.department_id
WHERE e.department_id = 5;

-- LEFT OUTER JOIN
-- We keep the values from the table on LEFT
SELECT e.employee_id, e.first_name, e.manager_id, e.salary, j.job_title
FROM employees e LEFT OUTER JOIN jobs j
ON e.job_id = j.job_id;

-- RIGHT OUTER JOIN
-- We keep the values from the table on RIGHT
SELECT d.department_id, d.department_name, e.first_name, e.salary
FROM departments d RIGHT OUTER JOIN employees e
ON d.department_id = e.department_id;

-- FULL OUTER JOIN keeps all the values from the both of the tables involved in the operation
SELECT e.employee_id, e.first_name, e.last_name, d.department_id, d.department_name, e.manager_id
FROM employees e FULL OUTER JOIN departments d
ON e.department_id = d.department_id;

-- Using Subquery to solve a query
-- Find all the employees that earn more than 'Mbappe'
SELECT employee_id, first_name, last_name, salary
FROM employees WHERE salary > (
    SELECT salary FROM employees
    WHERE first_name = 'Mbappe' OR last_name = 'Mbappe'
);

-- Find departments that pays more than the average minimum salary
-- By using department_id
SELECT d.department_id, AVG(e.salary)
FROM employees e JOIN departments d
ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
GROUP BY d.department_name
HAVING AVG(e.salary) > (
    SELECT MIN(AVG(e.salary))
    FROM employees e
    GROUP BY e.department_id
);
-- By using department_name
SELECT d.department_name, AVG(e.salary)
FROM employees e JOIN departments d
ON e.department_id = d.department_id
GROUP BY (d.department_name)
HAVING AVG(e.salary) > (
    SELECT MIN(AVG(e.salary))
    FROM employees e
    GROUP BY (e.department_id)
);

-- Find the jobs that pay more than the minimum average paying jobs
SELECT j.JOB_TITLE, AVG(e.SALARY)
FROM employees e JOIN jobs j
ON e.JOB_ID = j.JOB_ID
GROUP BY j.JOB_TITLE
HAVING AVG(e.SALARY) > (
    SELECT MIN((AVG(e.SALARY)))
    FROM employees e
    GROUP BY e.JOB_ID
);

SELECT last_name, salary, department_id
FROM employees
WHERE salary IN (
    SELECT MIN(salary)
    FROM employees
    GROUP BY department_id
);

-- Find minimum salary in each department
SELECT d.department_name, MIN(e.salary)
FROM employees e JOIN departments d
ON e.department_id = d.department_id
GROUP BY d.department_name;

-- Find the employees who recieve the minimum salary in each department
SELECT employee_id, first_name, last_name, department_name, salary
FROM employees e JOIN departments d
ON e.department_id = d.department_id
WHERE e.salary IN (
    SELECT MIN(e.salary)
    FROM employees e JOIN departments d
    ON e.department_id = d.department_id
);


-- Find list of all the other employees from all the other departments who earns more than Marketing department
SELECT employee_id, last_name, job_id, salary, department_id
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department_id = 3
);

SELECT MAX(salary) FROM employees;

SELECT employee_id, first_name, last_name, department_name
FROM employees e JOIN departments d
USING (department_id);

SELECT department_name, job_title
FROM departments d CROSS JOIN jobs j;

SELECT e.employee_id, e.first_name, e.last_name, d.department_name, j.job_title
FROM employees e JOIN departments d USING(department_id)
JOIN jobs j USING(job_id);

-- ========== ERROR ==============
-- Find the employees who gets these salary
SELECT employee_id, first_name, last_name, department_name, salary
FROM employees e JOIN departments d
ON e.department_id = d.department_id
WHERE e.salary IN (
    SELECT d.department_name, MIN(e.salary)
    FROM employees e JOIN departments d
    ON e.department_id = d.department_id
    GROUP BY d.department_name
);

-- ============ CORRECT =============
SELECT employee_id, first_name, last_name, department_name, salary
FROM employees e JOIN departments d
ON e.department_id = d.department_id
WHERE e.salary IN (
    SELECT MIN(e.salary)
    FROM employees e JOIN departments d
    ON e.department_id = d.department_id
);
