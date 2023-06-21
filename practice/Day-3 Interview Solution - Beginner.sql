-- SOLUTION: 1
-- Write a SQL query to show late employee list with late column where office time (9:00 AM to 5:00 PM) of date 01-jan-2021
SELECT e.emp_id, e.emp_name, e.jobtitle_name, a.in_time,
FROM emp e JOIN attendance a
ON e.emp_id = a.emp_id
WHERE TO_DATE (a.attendance_date, 'DD-MON-YYYY') = '01-JAN-2021'
AND TO_CHAR (in_time, 'HH24:MI') > '09:00';

-- SOLUTION: 2
-- Write a SQL query to show employee list who join after ’01-jan-2018’ and at least 5-day present 
SELECT e.Emp_id, e.Emp_name, j.Jobtitle_name, COUNT(a.Attendance_date) AS Present_Days
FROM employee e, attendance a, Jobtitle j
WHERE e.Emp_no = a.Emp_no AND e.Jobtitle_no = j.Jobtitle_no
AND TO_DATE (a.Attendance_date, 'DD-MON-YYYY') > '01-JAN-2018'
AND a.Attendance_status = 'P';

-- SOLUTION-3
-- Write a SQL query to show the attendance of an employee for month ‘January 2019’
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
