SELECT * FROM employees;
SELECT * FROM departments;
SELECT * FROM locations;

SELECT * FROM jobs;

SELECT COUNT(min_salary) FROM jobs WHERE min_salary > 6000;

--Display all the employees who were hired after 1997
SELECT * FROM employees
WHERE TO_CHAR(hire_date, 'YYYY') > 1997;

--Show last name, job, salary, commission. Sort in descending order by salary
SELECT last_name, job_id, salary, commission_pct
FROM employees
ORDER BY salary DESC;

--Employees who don't have any commission will receiive a 10% raise
--Output: The salary of Warthon after a 10% raise is 4840
SELECT 'The salary of ' || last_name || ' after a 10% raise is ' || salary*1.10
"UPDATED SALARY"
FROM employees
WHERE commission_pct IS NULL;

--Show the last name, number of years employeed and number of months employees for each employees
--Sort from the longest duration
SELECT
last_name,
TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12) YEARS,
TRUNC(MOD(MONTHS_BETWEEN(SYSDATE, hire_date), 12)) MONTHS
FROM employees
ORDER BY YEARS DESC, MONTHS DESC;

--Show employees who has a last name starting with J,K,L,M
SELECT employee_id, last_name, salary FROM employees
WHERE last_name LIKE 'J%' OR last_name LIKE 'K%' OR last_name LIKE 'L%' OR last_name LIKE 'M%';

--Show a list of employees with a "Yes"/"No" column based on commission
SELECT last_name, job_id, salary, commission_pct, NVL2(commission_pct, 'Yes', 'No') "COMMISSION?"
FROM employees; 

--Show name, job title, department, salary, location for employees that work in a specific location
--prompt that location

CREATE OR REPLACE VIEW empl_dept_loc (id, name, job, salary, department, location)
AS SELECT e.employee_id, e.FIRST_NAME || ' ' || e.last_name, e.job_id, e.salary, d.department_name, l.city
FROM employees e, departments d, locations l
WHERE e.department_id = d.department_id
AND d.location_id = l.location_id;

SELECT * FROM empl_dept_loc WHERE location = :user_input;

--Find employees last name ending with 'n'
SELECT last_name, job_id, salary FROM employees WHERE last_name LIKE '%n';

--Find name, location, and number of employees for each department
SELECT d.department_id, d.department_name, d.location_id, COUNT(e.employee_id) "Number of Employees"
FROM employees e RIGHT OUTER JOIN departments d
ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name, d.location_id;

--Find job titles in department 20 and 50
SELECT DISTINCT job_id FROM employees WHERE department_id IN (20, 50);

--Find jobs in Administration and Executive department and their numbers
SELECT e.job_id, COUNT(e.job_id) AS "FREQUENCY"
FROM employees e, departments d
WHERE e.department_id = d.department_id
AND d.department_name IN ('Administration', 'Executive')
GROUP BY e.job_id
ORDER BY "FREQUENCY" DESC;

--Find all employees who were hired at the first half of the month
SELECT last_name, job_id, hire_date
FROM employees
WHERE TO_CHAR(hire_date, 'DD') < 16;

--Show salaries of employees in terms of thousand dollars
SELECT last_name, salary, TRUNC(salary / 1000) Thousands FROM employees;

--Show employees who have managers who earn more than 15000
--Display employee name, manager name, manager salary, manager salary grade
SELECT e.last_name "Employee", m.last_name "Manager", m.salary "Manager Salary", j.grade_level "Salary Grade"
FROM employees e, employees m, job_grades j
WHERE e.manager_id = m.employee_id AND e.job_id = j.job_id
AND m.salary > 15000;

--Create a report to display the lowest salary of the department with the highest AVG salary
SELECT department_id, MIN(salary)
FROM employees
GROUP BY department_id
HAVING AVG(salary) = (SELECT MAX(AVG(salary)) FROM employees GROUP BY department_id);

--List all departments where no Sales Representatives work
SELECT * FROM departments
WHERE department_id NOT IN (SELECT department_id FROM employees
                            WHERE job_id = 'SA_REP' AND department_id IS NOT NULL);

--Find departments who employs less than 3 employees
SELECT d.department_id, d.department_name, COUNT(*)
FROM departments d, employees e
WHERE d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(*) < 3;

--Find departments that has the highest number of employees
SELECT d.department_id, d.department_name, COUNT(*)
FROM departments d, employees e
WHERE d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(*) = (SELECT MAX(COUNT(*)) FROM employees GROUP BY department_id);

--Find departments that has the lowest number of employees
SELECT d.department_id, d.department_name, COUNT(*)
FROM departments d, employees e
WHERE d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(*) = (SELECT MIN(COUNT(*)) FROM employees GROUP BY department_id);

--Create an anniversary overview
SELECT last_name, TO_CHAR(hire_date, 'Month DD') BIRTHDAY
FROM employees
ORDER BY TO_CHAR(hire_date, 'DDD');

--Create MEMBER table
CREATE TABLE member (
    member_id NUMBER(10)
    CONSTRAINT member_number_id_pk PRIMARY KEY,
    last_name VARCHAR(25)
    CONSTRAINT member_last_name_nn NOT NULL,
    first_name VARCHAR(25),
    address VARCHAR(100),
    city VARCHAR(30),
    phone VARCHAR(15),
    join_date DATE DEFAULT SYSDATE
    CONSTRAINT member_join_date_nn NOT NULL
);

--Create TITLE table
CREATE TABLE title (
    title_id NUMBER(6)
    CONSTRAINT title_title_id_pk PRIMARY KEY,
    title VARCHAR(60)
    CONSTRAINT title_title_nn NOT NULL,
    description VARCHAR(400)
    CONSTRAINT title_description_nn NOT NULL,
    rating VARCHAR(4)
    CONSTRAINT title_rating_ck CHECK (rating IN ('G', 'PG', 'R', 'NC17', 'NR')),
    category VARCHAR(20)
    CONSTRAINT title_category_ck CHECK (category IN ('DRAMA', 'COMEDY', 'ACTION', 'CHILD', 'SCIFI', 'DOCUMENTARY')),
    release_date DATE
);

--Create TITLE_COPY table
CREATE TABLE title_copy (
    copy_id NUMBER(10),
    title_id NUMBER(10)
    CONSTRAINT title_copy_title_status_if_fk REFERENCES title(title_id),
    status VARCHAR(15)
    CONSTRAINT title_copy_status_nn NOT NULL
    CONSTRAINT title_copy_status_ck CHECK (status IN ('AVAILABLE', 'DESTROYED', 'RENTED', 'RESERVED')),
    CONSTRAINT title_copy_copy_id_title_id_pk PRIMARY KEY (copy_id, title_id)
);

--Create RENTAL table
CREATE TABLE rental (
    book_date DATE DEFAULT SYSDATE,
    member_id NUMBER(10)
    CONSTRAINT rental_member_id_fk REFERENCES member(member_id),
    copy_id NUMBER(10),
    act_ret_date DATE,
    exp_ret_date DATE DEFAULT SYSDATE + 2,
    title_id NUMBER(10),
    CONSTRAINT rental_book_date_copy_title_pk PRIMARY KEY(book_date, member_id, copy_id, title_id),
    CONSTRAINT rental_copy_id_title_id_fk FOREIGN KEY(copy_id, title_id)
    REFERENCES title_copy(copy_id, title_id)
);

--Create RESERVATION table
CREATE TABLE reservation (
    res_date DATE,
    member_id NUMBER(10)
    CONSTRAINT reservation_member_id REFERENCES member(member_id),
    title_id NUMBER(10)
    CONSTRAINT reservation_title_id REFERENCES title(title_id),
    CONSTRAINT reservation_release_mem_tit_pk PRIMARY KEY(res_date, member_id, title_id)
);

--Verify if the tables were created properly
SELECT table_name FROM user_tables
WHERE table_name IN ('MEMBER', 'TITLE', 'TITLE_COPY', 'RENTAL', 'RESERVATION');

--Verify if the constraints were created properly
SELECT constraint_name, constraint_type, table_name
FROM user_constraints
WHERE table_name IN ('MEMBER', 'TITLE', 'TITLE_COPY', 'RENTAL', 'RESERVATION');

--Create sequences to uniquely identify each row in MEMBER TABLE and TITLE TABLE
CREATE SEQUENCE member_id_seq
START WITH 101
NOCACHE;

CREATE SEQUENCE title_id_seq
START WITH 92
NOCACHE;

--Check sequence
SELECT sequence_name, increment_by, last_number
FROM user_sequences
WHERE sequence_name IN ('MEMBER_ID_SEQ', 'TITLE_ID_SEQ');

--INSERT INTO TITLE AND MEMBER
INSERT INTO title(title_id, title, description, rating, category, release_date)
VALUES (title_id_seq.NEXTVAL, 'Willie and Christmas Too', 'All of Willies friends make a Christmas list for Santa but Willie has yet to add his own wish list', 'G', 'CHILD', TO_DATE('05-OCT-1995', 'DD-MON-YYYY'));

SELECT * FROM TITLE;

INSERT INTO member(member_id, first_name, last_name, address, city, phone, join_date)
VALUES(member_id_seq.NEXTVAL, 'Mark', 'Quick-to-See', '6921 King Way', 'Lagos', '63-559-7777', TO_DATE('07-APR-1990', 'DD-MON-YYYY'));

SELECT * FROM MEMBER;

INSERT INTO title_copy(copy_id, title_id, status) VALUES (1, 92, 'AVAILABLE');

SELECT * FROM title_copy;

INSERT INTO rental(title_id, copy_id, member_id, book_date, exp_ret_date, act_ret_date)
VALUES(92, 1, 101, SYSDATE-3, SYSDATE-1, SYSDATE-2);

SELECT * FROM rental;

--Create a view named title_avail to show the movie titles, the availability of each copy, and its expected return date if rented. Query all rows from the view
CREATE OR REPLACE VIEW title_avail AS
    SELECT t.title, c.copy_id, c.status, r.exp_ret_date
    FROM title t JOIN title_copy c
    ON t.tile_id = c.title_id
    FULL OUTER JOIN rental r
    ON c.copy_id = r.copy_id
    AND c.title_id = r.title_id;

INSERT INTO reservation (res_date, member_id, title_id) VALUES (SYSDATE, 101, 92);

SELECT * FROM reservation;

