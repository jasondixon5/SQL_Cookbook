/* CHAPTER 12: REPORTING AND WAREHOUSING */

/* 12.1 Pivoting a result set into one row */

SELECT 
    deptno, 
    COUNT(*) AS empl_count
FROM emp 
GROUP BY deptno
;

-- Use CASE statement to pivot rows to columns
SELECT 
    deptno, 
    CASE deptno WHEN 10 THEN 1 ELSE NULL END AS dept10_empl_count,
    CASE deptno WHEN 20 THEN 1 ELSE NULL END AS dept20_empl_count,
    CASE deptno WHEN 30 THEN 1 ELSE NULL END AS dept30_empl_count,
    CASE WHEN deptno NOT IN (10, 20, 30) THEN 1 ELSE NULL END AS misc_empl_count
FROM emp 
;

-- Use CASE statement to pivot rows to columns
-- Use aggregate func to get total count for each new column
SELECT 
    deptno, 
    SUM(CASE deptno WHEN 10 THEN 1 ELSE NULL END) AS dept10_empl_count,
    SUM(CASE deptno WHEN 20 THEN 1 ELSE NULL END) AS dept20_empl_count,
    SUM(CASE deptno WHEN 30 THEN 1 ELSE NULL END) AS dept30_empl_count,
    SUM(CASE WHEN deptno NOT IN (10, 20, 30) THEN 1 ELSE NULL END) AS misc_empl_count
FROM emp
GROUP BY deptno 
;

-- Use CASE statement to pivot rows to columns
-- Use aggregate func to get total count for each new column
-- Clean up unneeded deptno column
SELECT 
    SUM(CASE deptno WHEN 10 THEN 1 ELSE NULL END) AS dept10_empl_count,
    SUM(CASE deptno WHEN 20 THEN 1 ELSE NULL END) AS dept20_empl_count,
    SUM(CASE deptno WHEN 30 THEN 1 ELSE NULL END) AS dept30_empl_count,
    SUM(CASE WHEN deptno NOT IN (10, 20, 30) THEN 1 ELSE NULL END) AS misc_empl_count
FROM emp
;

/* 12.2 Pivoting a result set into multiple rows */

-- Show each employee and their job, with a column for each job

-- examine data
SELECT
    job,
    ename
FROM emp
;

SELECT DISTINCT job FROM emp ORDER BY job;

-- Create column for each job
SELECT 
    CASE job WHEN "ANALYST" THEN ename END AS analysts,
    CASE job WHEN "CLERK" THEN ename END AS clerks,
    CASE job WHEN "MANAGER" THEN ename END AS managers,
    CASE job WHEN "PRESIDENT" THEN ename END AS presidents,
    CASE job WHEN "SALESMAN" THEN ename END AS salesman
FROM emp 
;

-- Create column for each job
-- Create unique identifier within each job for each empl
SELECT 
    (SELECT COUNT(*) FROM emp e2
    WHERE e2.empno <= emp.empno
    AND e2.job=emp.job) AS group_no,
    CASE job WHEN "ANALYST" THEN ename END AS analysts,
    CASE job WHEN "CLERK" THEN ename END AS clerks,
    CASE job WHEN "MANAGER" THEN ename END AS managers,
    CASE job WHEN "PRESIDENT" THEN ename END AS presidents,
    CASE job WHEN "SALESMAN" THEN ename END AS salesman
FROM emp 
;

-- Create column for each job
-- Create unique identifier within each job for each empl
-- Apply aggregate function to remove nulls, using unique
--   identifier as grouping field
-- (Not necessary to show unique identifier in columns)
SELECT 
    MAX(CASE job WHEN "ANALYST" THEN ename END) AS analysts,
    MAX(CASE job WHEN "CLERK" THEN ename END) AS clerks,
    MAX(CASE job WHEN "MANAGER" THEN ename END) AS managers,
    MAX(CASE job WHEN "PRESIDENT" THEN ename END) AS presidents,
    MAX(CASE job WHEN "SALESMAN" THEN ename END) AS salesman
FROM emp 
GROUP BY (
    SELECT COUNT(*) FROM emp e2
    WHERE e2.empno <= emp.empno
    AND e2.job=emp.job)
;

/* 12.3 Reverse pivoting a result set */

-- Given a result set that has a column for each value,
-- pivot the columns to rows

-- Example result set to start with
SELECT 
    SUM(CASE deptno WHEN 10 THEN 1 ELSE NULL END) AS dept10,
    SUM(CASE deptno WHEN 20 THEN 1 ELSE NULL END) AS dept20,
    SUM(CASE deptno WHEN 30 THEN 1 ELSE NULL END) AS dept30,
    SUM(CASE WHEN deptno NOT IN (10, 20, 30) THEN 1 ELSE NULL END) AS misc
FROM emp
;

-- Cross join with another table to get 4 rows
-- Use case statement to create one column
SELECT *
FROM (
SELECT
    SUM(CASE deptno WHEN 10 THEN 1 ELSE NULL END) AS dept10,
    SUM(CASE deptno WHEN 20 THEN 1 ELSE NULL END) AS dept20,
    SUM(CASE deptno WHEN 30 THEN 1 ELSE NULL END) AS dept30,
    SUM(CASE WHEN deptno NOT IN (10, 20, 30) THEN 1 ELSE NULL END) AS misc
FROM emp
) dept_counts, (SELECT DISTINCT deptno FROM emp) depts
;

SELECT
    deptno,
    CASE deptno
        WHEN 10 THEN dept10
        WHEN 20 THEN dept20
        WHEN 30 THEN dept30
    END AS empl_count
FROM (
SELECT
    SUM(CASE deptno WHEN 10 THEN 1 ELSE NULL END) AS dept10,
    SUM(CASE deptno WHEN 20 THEN 1 ELSE NULL END) AS dept20,
    SUM(CASE deptno WHEN 30 THEN 1 ELSE NULL END) AS dept30,
    SUM(CASE WHEN deptno NOT IN (10, 20, 30) THEN 1 ELSE NULL END) AS misc
FROM emp
) dept_counts, (SELECT DISTINCT deptno FROM emp) depts
ORDER BY deptno
;

/* Now what if we didn't have a table with the dept numbers
we needed already? */

-- Create table with the deptnos
SELECT 10 AS deptno FROM DUAL
UNION ALL
SELECT 20 FROM DUAL
UNION ALL
SELECT 30 FROM DUAL
UNION ALL
SELECT "MISC" FROM DUAL
;

-- Put result sets together via cross join
SELECT * FROM 
(SELECT
    SUM(CASE deptno WHEN 10 THEN 1 ELSE NULL END) AS dept10,
    SUM(CASE deptno WHEN 20 THEN 1 ELSE NULL END) AS dept20,
    SUM(CASE deptno WHEN 30 THEN 1 ELSE NULL END) AS dept30,
    SUM(CASE WHEN deptno NOT IN (10, 20, 30) THEN 1 ELSE NULL END) AS misc
FROM emp) dept_counts,
(SELECT 10 AS deptno FROM DUAL
UNION ALL
SELECT 20 FROM DUAL
UNION ALL
SELECT 30 FROM DUAL
UNION ALL
SELECT "MISC" FROM DUAL
) depts
;

-- Create table with the deptnos
-- Put result sets together via cross join
-- Clean up columns so results show each dept and its employee count
SELECT 
    depts.deptno,
    CASE depts.deptno
        WHEN 10 THEN dept10
        WHEN 20 THEN dept20
        WHEN 30 THEN dept30
        WHEN 'MISC' THEN misc
    END AS empl_counts
FROM 
(SELECT
    SUM(CASE deptno WHEN 10 THEN 1 ELSE NULL END) AS dept10,
    SUM(CASE deptno WHEN 20 THEN 1 ELSE NULL END) AS dept20,
    SUM(CASE deptno WHEN 30 THEN 1 ELSE NULL END) AS dept30,
    SUM(CASE WHEN deptno NOT IN (10, 20, 30) THEN 1 ELSE NULL END) AS misc
FROM emp) dept_counts,
(SELECT 10 AS deptno FROM DUAL
UNION ALL
SELECT 20 FROM DUAL
UNION ALL
SELECT 30 FROM DUAL
UNION ALL
SELECT "MISC" FROM DUAL
) depts
;

-- One advantage of the 'manual' approach to create the
-- depts table is that it allowed inclusion of a dept
-- that doesn't have any employees
-- Though a similar advantage could be gained from joining
-- on the depts table

/* Skip 12.4 - 12.6 */

/* 12.7 Creating buckets of data of a fixed size */

-- Organize employees in table emp into groups of five

-- Assign a row number to each employee
SELECT
    (SELECT COUNT(*) FROM emp e2
    WHERE e2.empno <= emp.empno) AS row_num,
    empno,
    ename
FROM emp
;

-- Assign a row number to each employee
-- Use row number to create a group number,
--   with each group containing five members where possible
SELECT 
    CEILING(row_num/5) AS grp_num,
    empno,
    ename
FROM (
SELECT
    (SELECT COUNT(*) FROM emp e2
    WHERE e2.empno <= emp.empno) AS row_num,
    empno,
    ename
FROM emp) x
;

/* 12.8 Creating a predefined number of buckets */

-- Organize employees into 4 buckets
SELECT 
    row_num % 4 AS grp_num,
    empno,
    ename
FROM (
SELECT
    (SELECT COUNT(*) FROM emp e2
    WHERE e2.empno <= emp.empno) AS row_num,
    empno,
    ename
FROM emp) x
;

/* 
NEEDS MORE WORK; FIGURED IT OUT IN PYTHON BUT NOT SURE HOW
IT CAN BE ACCOMPLISHED IN SQL

How would we get consecutive employees to have the same grp number?
That is, instead of the grp_num going 1 2 3 0 1 2 3 0 ...
it goes 1 1 1 1 2 2 2 2 ...
*/

/*
-- Get max number of employees in each group
SET @emp_per_bucket = (SELECT CEILING((COUNT(*)/4)) FROM emp);
SET @emps_seen = 1;
SET @group_no = 1;
*/

/*
1. Select row
2. Increment emps seen
3. If seen 4 or fewer employees, assign grp num
4. If seen 5 employees, increment grp num, assign it, then reset 
5. 

@emp_per_bucket == 4

Row 1
@emps_seen == 1
increment @emps_seen


*/

/* 12.9 Creating horizontal histograms */

-- create histogram of number of empls in each dept
SELECT 
    deptno,
    LPAD("*", COUNT(*), "*") AS empl_count
FROM emp
GROUP BY deptno
;

-- Try similar approach with employee salaries
-- For readability, make each $1000 appear as one asterisk

-- Create column to get number of asterisks needed
SELECT
    job,
    SUM(sal),
    SUM(CEILING(sal/1000)) AS "salary ($1000s)"
FROM emp
GROUP BY job
;

-- Convert number column to asterisk
SELECT
    job,
    LPAD("*", SUM(CEILING(sal/1000)), "*") AS salary
FROM emp
GROUP BY job
;

