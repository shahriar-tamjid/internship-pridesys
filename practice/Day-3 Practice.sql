SELECT * FROM employees;

SELECT d.department_name "DEPARTMENT", SUM(e.salary) "TOTAL SALARY"
FROM employees e JOIN departments d
ON e.department_id = e.department_id
GROUP BY d.department_name;

SELECT e.EMPLOYEE_ID, e.LAST_NAME, d.DEPARTMENT_NAME, e.salary
FROM employees e JOIN departments d
ON e.department_id = d.department_id
WHERE e.salary < (
    SELECT AVG(e.salary)
    FROM employees e
);

SELECT e.EMPLOYEE_ID, e.LAST_NAME, d.DEPARTMENT_NAME, e.salary
FROM employees e JOIN departments d
ON e.department_id = d.department_id
WHERE e.salary > (
    SELECT AVG(e.salary)
    FROM employees e
);

SELECT COUNT(*)
FROM employees e JOIN departments d
ON e.department_id = d.department_id
WHERE e.salary < (
    SELECT AVG(e.salary)
    FROM employees e
);

SELECT COUNT(*)
FROM employees e JOIN departments d
ON e.department_id = d.department_id
WHERE e.salary > (
    SELECT AVG(e.salary)
    FROM employees e
);

SELECT e.job_id MAX_SAL_JOBS, AVG(e.salary)
FROM employees e JOIN jobs j
ON e.JOB_ID = j.JOB_ID
GROUP BY j.job_id
HAVING AVG(e.salary) > (
    SELECT MIN(AVG(salary))
    FROM employees
    GROUP BY job_id
)
ORDER BY AVG(e.salary) DESC;

SELECT last_name, job_id
FROM employees
WHERE job_id = 'SA%';

-- Use the & substitution in a SQL statement to prompt for values
INSERT INTO departments VALUES (&department_id, &department_name, &location_id);

CREATE TABLE sales_reps (
    id NUMBER(6),
    name VARCHAR(20),
    salary NUMBER(8,2),
    commission_pct NUMBER(2,2)
);

SELECT ID, NAME, FROM sales_reps;

-- Insert data from a big table to a newly created table
INSERT INTO sales_reps (id, name, salary, commission_pct)
    SELECT employee_id, last_name, salary, commission_pct
    FROM employees
    WHERE job_id LIKE '%REP%';

-- Clone or Copy a Table
INSERT INTO copy_emp
    SELECT * FROM employees;

SELECT * FROM copy_emp;
    
SELECT e.emp_no, e.first_name, e.last_name, a.in_time
FROM emp e JOIN attendance a
ON e.emp_no = a.emp_no
WHERE TO_CHAR (a.attendance_date, 'DD-Mon-YYYY') = '01-Jan-2021' AND TO_CHAR (a.in_time, 'HH24:MI') > '09:00';

-- Emp_ID, Emp_name, jobtitle_name, Join_date, Dept_name, attn_date,shift_in_time, in_time, Late
CREATE OR REPLACE VIEW late_employees
(Emp_ID, Emp_name, jobtitle_name, Join_date, Dept_name, attn_date, in_time)
AS SELECT
e.Emp_ID, e.Emp_name, j.jobtitle_name, e.Join_date, d.Dept_name, a.attn_date, a.in_time
FROM
Emp e, Jobtitle j, Dept d, Attendance a
WHERE
e.Jobtitle_no = j.Jobtitle_no AND e.Dept_no = d.Dept_no AND e.Emp_no = a.Emp_no
WITH READ ONLY;

SELECT Emp_ID, Emp_name, jobtitle_name, Join_date, Dept_name, attn_date, in_time, TO_CHAR (a.in_time, 'HH24:MI') 
CASE in_time
    WHEN in_time > Shift_in_time THEN 'Late'
    and TO_CHAR (a.in_time, 'HH24:MI') 
    ELSE 'On-time'
END AS Late

-- SOLUTION: 1
SELECT e.emp_id, e.emp_name, e.jobtitle_name, a.in_time,
FROM emp e JOIN attendance a
ON e.emp_id = a.emp_id
WHERE TO_DATE (a.attendance_date, 'DD-MON-YYYY') = '01-JAN-2021'
AND TO_CHAR (in_time, 'HH24:MI') > '09:00';

-- SOLUTION: 2
SELECT e.Emp_id, e.Emp_name, j.Jobtitle_name, COUNT(a.Attendance_date) AS Present_Days
FROM employee e, attendance a, Jobtitle j
WHERE e.Emp_no = a.Emp_no AND e.Jobtitle_no = j.Jobtitle_no
AND TO_DATE (a.Attendance_date, 'DD-MON-YYYY') > '01-JAN-2018'
AND a.Attendance_status = 'P';

-- SOLUTION-3
SELECT e.Emp_name, j.Jobtitle_name, e.Join_date, a.Attendance_date, a.In_time, a.Out_time
FROM Emp e , Attendance a, Jobtitle j
where e.Emp_no = a.Emp_no
and  e.Jobtitle_no = j.Jobtitle_no
and TO_DATE (a.Attendance_date, 'DD-MON-YYYY') BETWEEN '2019-01-01' AND '2019-01-31';

-- SOLUTION-4
-- Write a query to show employee list to show job duration   with the following column
SELECT e.Emp_name, e.Emp_id, e.Join_date , j.Jobtitle_name, d.Dept_name,
TO_DATE (CURRENT_DATE, 'DD-MON-YYYY') - TO_DATE (e.Join_date, 'DD-MON-YYYY') "Job Duration"
FROM Emp e, Jobtitle j, Dept d
WHERE e.Jobtitle_no = j.Jobtitle_no AND e.Dept_no = d.Dept_no;

-- SOLUTION-5
-- Write a query to show the emp list who left after January-2019 and job age minimum 1 year
SELECT e.Emp_name, e.Emp_id, e.Join_date, j.Jobtitle_name, d.Dept_name
FROM Emp e, Jobtitle j, Dept d
WHERE e.Jobtitle_no = j.Jobtitle_no AND e.Dept_no = d.Dept_no
AND TO_DATE (e.Join_date, 'DD-MON-YYYY') > '31-JAN-2019'
AND YEAR (CURRENT_DATE, 'DD-MON-YYYY') - YEAR (e.Join_date, 'DD-MON-YYYY') >= 1;

-- SOLUTION-6
-- Write a SQL query to show department wise active employee salary summery
SELECT d.Dept_name, SUM(e.Active_flag) AS "Active Employees", SUM(e.salary) AS "Total Salary"
FROM Emp e, Dept d
WHERE e.Dept_no = d.Dept_no
GROUP BY d.Dept_name
HAVING e.Active_flag = 1;

-- SOLUTION-7
-- Write a SQL query to show Absent Employee List of date ’01-jan-2019’ 
SELECT e.Emp_no, e.First_name, e.Last_name, a.Attendance_date
FROM Emp e, Attendance a
WHERE e.Emp_no = a.Emp_no
AND TO_DATE(a.Attendance_date, 'DD-mon-YYYY') = '01-jan-2019'
AND a.Attendance_status = 'A';

-- SOLUTION-8
-- Write a SQL query to show Out time Missing Employee List for then month jan-2019
SELECT e.Emp_no, e.First_name, e.Last_name
FROM Emp e, Attendance a
WHERE e.Emp_no = a.Emp_no
AND TO_CHAR(a.Out_time, 'HH24:MI') IS NULL
AND TO_DATE(a.Attendance_date, 'DD-mon-YYYY') >= '01-jan-2019'
AND TO_DATE(a.Attendance_date, 'DD-mon-YYYY') <= '31-jan-2019';
