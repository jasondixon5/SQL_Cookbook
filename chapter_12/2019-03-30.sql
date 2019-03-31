/* Chapter 12: Reporting and Warehousing */

/* NOTE: Many of these solutions account for
employees not in the departments or positions
known to contain employees, as a way to practice
"future-proofing" the data. These techniques
are not in the book solutions. */

/* 12.1 Pivoting a Result Set Into One Row */

-- Take result set of number of employees per dept
-- and pivot it to show a column for each dept
-- instead of a row

-- first examine count by dept (data to be transformed)
SELECT deptno,
    COUNT(*) as emp_count
FROM emp
GROUP BY deptno
;

-- now add case statements to add new columns
-- (transform rows to columns)

SELECT MAX(CASE WHEN deptno=10 THEN emp_count
        END) AS DEPTNO_10,
        MAX(CASE WHEN deptno=20 THEN emp_count
        END) AS DEPTNO_20,
        MAX(CASE WHEN deptno=30 THEN emp_count
        END) AS DEPTNO_30,
        MAX(CASE WHEN deptno NOT IN (10, 20, 30) THEN emp_count
        END) AS DEPTNO_OTHER
FROM (

    SELECT deptno,
        COUNT(*) as emp_count
    FROM emp
    GROUP BY deptno) x
;

-- book solution uses case expression with 1 and no
-- subquery

SELECT SUM(CASE WHEN deptno=10 THEN 1 ELSE 0 END) AS DEPTNO_10,
    SUM(CASE WHEN deptno=20 THEN 1 ELSE 0 END) AS DEPTNO_20,
    SUM(CASE WHEN deptno=30 THEN 1 ELSE 0 END) AS DEPTNO_30,
    SUM(CASE WHEN deptno NOT IN (10, 20, 30) THEN 1 ELSE 0 END) AS DEPTNO_OTHER
FROM emp
;

/* 12.2 Pivoting a Result Set Into Multiple Rows */

/* Turn rows into columns */

-- Return each employee and their job,
-- with a column for each job and a row
-- for each employee

-- First examine what jobs exist
SELECT DISTINCT job
FROM emp
ORDER BY job;

/* Result set:
+-----------+
| job       |
+-----------+
| ANALYST   |
| CLERK     |
| MANAGER   |
| PRESIDENT |
| SALESMAN  |
+-----------+
*/

-- Build query to put each job in its own column 
SELECT CASE WHEN job IN ("ANALYST") THEN ename END AS analyst,
    CASE WHEN job IN ("CLERK") THEN ename END AS clerk,
    CASE WHEN job IN ("MANAGER") THEN ename END AS manager,
    CASE WHEN job in ("PRESIDENT") THEN ename END AS prez,
    CASE WHEN job in ("SALESMAN") THEN ename END AS sales,
    CASE WHEN job NOT IN ("ANALYST", "CLERK", "MANAGER", "PRESIDENT", "SALESMAN") THEN ename END AS other
FROM emp
;

-- Assign a group ID to each person in a position
-- This step will allow multiple people in a group
-- to be extracted with an aggregate func (because each
-- will have its own id)
SELECT
    (SELECT COUNT(*) FROM emp e2
    WHERE e2.empno <= emp.empno AND e2.job = emp.job) AS grp_id,
    CASE WHEN job IN ("ANALYST") THEN ename END AS analyst,
    CASE WHEN job IN ("CLERK") THEN ename END AS clerk,
    CASE WHEN job IN ("MANAGER") THEN ename END AS manager,
    CASE WHEN job in ("PRESIDENT") THEN ename END AS prez,
    CASE WHEN job in ("SALESMAN") THEN ename END AS sales,
    CASE WHEN job NOT IN ("ANALYST", "CLERK", "MANAGER", "PRESIDENT", "SALESMAN") THEN ename END AS other
FROM emp
ORDER BY 1
;

-- Group on group ID and use an aggregate function to
-- get the single non-null value from each group in
-- each column

SELECT 
    MAX(analyst) AS analyst,
    MAX(clerk) AS clerk,
    MAX(manager) AS manager,
    MAX(prez) AS prez,
    MAX(sales) AS sales,
    MAX(other) AS other
FROM (
    SELECT
        (SELECT COUNT(*) FROM emp e2
        WHERE e2.empno <= emp.empno AND e2.job = emp.job) AS grp_id,
        CASE WHEN job IN ("ANALYST") THEN ename END AS analyst,
        CASE WHEN job IN ("CLERK") THEN ename END AS clerk,
        CASE WHEN job IN ("MANAGER") THEN ename END AS manager,
        CASE WHEN job in ("PRESIDENT") THEN ename END AS prez,
        CASE WHEN job in ("SALESMAN") THEN ename END AS sales,
        CASE WHEN job NOT IN ("ANALYST", "CLERK", "MANAGER", "PRESIDENT", "SALESMAN") THEN ename END AS other
    FROM emp
) emp_by_position
GROUP BY grp_id
;

-- Try same approach but without inline view.
-- Requires putting grp_id query in the GROUP BY statement.
SELECT MAX(CASE WHEN job IN ("ANALYST") THEN ename END) AS analyst,
    MAX(CASE WHEN job IN ("CLERK") THEN ename END) AS clerk,
    MAX(CASE WHEN job IN ("MANAGER") THEN ename END) AS manager,
    MAX(CASE WHEN job in ("PRESIDENT") THEN ename END) AS prez,
    MAX(CASE WHEN job in ("SALESMAN") THEN ename END) AS sales,
    MAX(CASE WHEN job NOT IN ("ANALYST", "CLERK", "MANAGER", "PRESIDENT", "SALESMAN") THEN ename END) AS other
FROM emp
GROUP BY (SELECT COUNT(*) FROM emp e2
        WHERE e2.empno <= emp.empno AND e2.job = emp.job)
;

/* Both approaches were successful.
Result set:
+---------+--------+---------+------+--------+-------+
| analyst | clerk  | manager | prez | sales  | other |
+---------+--------+---------+------+--------+-------+
| SCOTT   | SMITH  | JONES   | KING | ALLEN  | NULL  |
| FORD    | ADAMS  | BLAKE   | NULL | WARD   | NULL  |
| NULL    | JAMES  | CLARK   | NULL | MARTIN | NULL  |
| NULL    | MILLER | NULL    | NULL | TURNER | NULL  |
+---------+--------+---------+------+--------+-------+
*/

-- Try adding dept no
-- Will require adding a layer to grouping
-- to make each ename/job/dept combo unique

-- First add deptno to sparse report (before grouping)
SELECT
    (SELECT COUNT(*) FROM emp e2
    WHERE e2.empno <= emp.empno 
    AND e2.job = emp.job
    AND e2.deptno = emp.deptno) AS grp_id,
    deptno,
    CASE WHEN job IN ("ANALYST") THEN ename END AS analyst,
    CASE WHEN job IN ("CLERK") THEN ename END AS clerk,
    CASE WHEN job IN ("MANAGER") THEN ename END AS manager,
    CASE WHEN job in ("PRESIDENT") THEN ename END AS prez,
    CASE WHEN job in ("SALESMAN") THEN ename END AS sales,
    CASE WHEN job NOT IN ("ANALYST", "CLERK", "MANAGER", "PRESIDENT", "SALESMAN") THEN ename END AS other
FROM emp
ORDER BY 1, 2
;

SELECT 
    deptno,
    MAX(CASE WHEN job IN ("ANALYST") THEN ename END) AS analyst,
    MAX(CASE WHEN job IN ("CLERK") THEN ename END) AS clerk,
    MAX(CASE WHEN job IN ("MANAGER") THEN ename END) AS manager,
    MAX(CASE WHEN job in ("PRESIDENT") THEN ename END) AS prez,
    MAX(CASE WHEN job in ("SALESMAN") THEN ename END) AS sales,
    MAX(CASE WHEN job NOT IN ("ANALYST", "CLERK", "MANAGER", "PRESIDENT", "SALESMAN") THEN ename END) AS other
FROM emp
GROUP BY (SELECT COUNT(*) FROM emp e2
        WHERE e2.empno <= emp.empno 
        AND e2.job = emp.job
        AND e2.deptno = emp.deptno),
        deptno
ORDER BY 1
;

-- examine employees by dept and job to verify results
SELECT deptno,
        job,
        ename
FROM emp
GROUP BY deptno, job, ename
ORDER BY 1, 2, 3
;

/* 12.3 Reverse pivoting a result set */

/* Assuming data is stored like this:
+-----------+-----------+-----------+--------------+
| DEPTNO_10 | DEPTNO_20 | DEPTNO_30 | DEPTNO_OTHER |
+-----------+-----------+-----------+--------------+
|         3 |         5 |         6 |         NULL |
+-----------+-----------+-----------+--------------+

Problem is to convert each column into a row, like
this:

+--------+-----------+
| deptno | emp_count |
+--------+-----------+
|     10 |         3 |
|     20 |         5 |
|     30 |         6 |
+--------+-----------+
*/

-- First examine initial data

SELECT *
FROM (
    SELECT 
    SUM(CASE WHEN deptno=10 THEN 1 ELSE 0 END) AS DEPTNO_10,
    SUM(CASE WHEN deptno=20 THEN 1 ELSE 0 END) AS DEPTNO_20,
    SUM(CASE WHEN deptno=30 THEN 1 ELSE 0 END) AS DEPTNO_30,
    SUM(CASE WHEN deptno NOT IN (10, 20, 30) THEN 1 ELSE 0 END) AS DEPTNO_OTHER
    FROM emp) emp_cnt_by_dept
;

-- create cartesian product with another table
-- to product rows
-- Other table can be any one with required number of rows
-- Note that you must know in advance how many
-- additional rows are needed.
SELECT *
FROM (
    SELECT 
    SUM(CASE WHEN deptno=10 THEN 1 ELSE 0 END) AS DEPTNO_10,
    SUM(CASE WHEN deptno=20 THEN 1 ELSE 0 END) AS DEPTNO_20,
    SUM(CASE WHEN deptno=30 THEN 1 ELSE 0 END) AS DEPTNO_30,
    SUM(CASE WHEN deptno NOT IN (10, 20, 30) THEN 1 ELSE 0 END) AS DEPTNO_OTHER
    FROM emp) emp_cnt_by_dept

CROSS JOIN

(SELECT deptno FROM dept) dept
;

SELECT 
    CASE WHEN deptno IN (10, 20, 30) THEN deptno
    ELSE "OTHER" END AS deptno,
    CASE deptno WHEN 10 THEN DEPTNO_10
                WHEN 20 THEN DEPTNO_20
                WHEN 30 THEN DEPTNO_30
                ELSE DEPTNO_OTHER
    END AS emp_cnt
                
FROM (
    SELECT 
    SUM(CASE WHEN deptno=10 THEN 1 ELSE 0 END) AS DEPTNO_10,
    SUM(CASE WHEN deptno=20 THEN 1 ELSE 0 END) AS DEPTNO_20,
    SUM(CASE WHEN deptno=30 THEN 1 ELSE 0 END) AS DEPTNO_30,
    SUM(CASE WHEN deptno NOT IN (10, 20, 30) THEN 1 ELSE 0 END) AS DEPTNO_OTHER
    FROM emp) emp_cnt_by_dept

CROSS JOIN

(SELECT deptno FROM dept) dept
;

/* 12.4 and 12.5
These problems are included to demonstrate
window functions, which are not supported
by MySQL 5. */

/* 12.6 Pivoting a result set to facilitate
inter-row calculations */

/* Similar to problem 12.1, but instead of empl
count want to get a sum of salaries */

-- Build a result set with a column each for
-- sum of salaries in dept 10, 20, and 30,
-- to faciliate doing calculations among
-- dept totals

-- First examine starting set of sum of salaries by dept
SELECT 
    deptno,
    SUM(sal)
FROM emp
GROUP BY deptno
;

-- Build sparse report of salaries for each dept
SELECT 
    CASE WHEN deptno=10 THEN sal END AS dept10_sal,
    CASE WHEN deptno=20 THEN sal END AS dept20_sal,
    CASE WHEN deptno=30 THEN sal END AS dept30_sal,
    CASE WHEN deptno NOT IN (10, 20, 30) THEN sal END
        AS other_dept_sal
FROM emp
;

-- Total each column
-- NOTE: Coalesce nulls to 0 for readability
SELECT 
    COALESCE(SUM(CASE WHEN deptno=10 
    THEN sal END), 0) AS dept10_sal,
    COALESCE(SUM(CASE WHEN deptno=20 
    THEN sal END), 0) AS dept20_sal,
    COALESCE(SUM(CASE WHEN deptno=30 
    THEN sal END), 0) AS dept30_sal,
    COALESCE(SUM(CASE WHEN deptno NOT IN (10, 20, 30) 
    THEN sal END), 0)
        AS other_dept_sal
FROM emp
;

-- Wrap query in inlne view and do the calcs
-- (in this case, diffs)
-- Note: Didn't list all combinations
SELECT 
    dept10_sal,
    dept20_sal,
    (dept20_sal - dept10_sal) AS diff_depts_20_10,
    dept30_sal,
    (dept30_sal - dept10_sal) AS diff_depts_30_10

FROM (
    SELECT 
        COALESCE(SUM(CASE WHEN deptno=10 
        THEN sal END), 0) AS dept10_sal,
        COALESCE(SUM(CASE WHEN deptno=20 
        THEN sal END), 0) AS dept20_sal,
        COALESCE(SUM(CASE WHEN deptno=30 
        THEN sal END), 0) AS dept30_sal,
        COALESCE(SUM(CASE WHEN deptno NOT IN (10, 20, 30) 
        THEN sal END), 0)
            AS other_dept_sal
    FROM emp) sal_totals
;

/* Creating buckets of data of a fixed size */

-- Create n buckets of employees of 5 each

-- First assign a row num to each employee
SELECT
    (SELECT COUNT(*)
    FROM emp e2
    WHERE e.empno >= e2.empno) AS row_num,
    empno,
    ename
FROM emp e
;

-- Divide each row num by the count of emp in each bucket
-- Then take ceiling of result to get integer
SET @bucket_size = 5;

SELECT 
    row_num,
    row_num / @bucket_size AS row_num_div_bucket_size,
    CEILING(row_num / @bucket_size) AS ceil,
    empno,
    ename
FROM (
    SELECT
        (SELECT COUNT(*)
        FROM emp e2
        WHERE e.empno >= e2.empno) AS row_num,
        empno,
        ename
    FROM emp e) numbered_emp_list
;

-- Clean up results
SET @bucket_size = 5;

SELECT 
    CEILING(row_num / @bucket_size) AS group_num,
    empno,
    ename
FROM (
    SELECT
        (SELECT COUNT(*)
        FROM emp e2
        WHERE e.empno >= e2.empno) AS row_num,
        empno,
        ename
    FROM emp e) numbered_emp_list
;

/* 12.8 Creating a predefined number of buckets */

-- Create 5 buckets of n employees each
-- Use technique of modulo operator instead of 
-- ceiling since the bucket count is fixed
-- instead of the size of each bucket

SET @bucket_size = 5;

SELECT 
    row_num,
    row_num / @bucket_size AS row_num_div_bucket_size,
    MOD(row_num, @bucket_size) AS grp,
    empno,
    ename
FROM (
    SELECT
        (SELECT COUNT(*)
        FROM emp e2
        WHERE e.empno >= e2.empno) AS row_num,
        empno,
        ename
    FROM emp e) numbered_emp_list
;

/* Solution above is accuarate,
but book solution uses a cross join
instead of an inline view to count the 
rows

Implement that solution.
*/

/*
-- examine cross join
SELECT e.empno,
        e.ename,
        e2.empno,
        e2.ename
FROM emp e
CROSS JOIN emp e2
;
*/
-- use cross join to do count
SET @bucket_size = 5;

SELECT e.empno,
    e.ename,
    COUNT(*) as rnk,
    COUNT(*)/@bucket_size as rnk_incr,
    MOD(COUNT(*), @bucket_size) as grp
FROM emp e
CROSS JOIN emp e2
ON e.empno >= e2.empno
GROUP BY e.empno, e.ename
;

/* 12.9 Creating horizontal histograms */

-- display number of empls in each dept as horizontal historgram

-- first display counts
SELECT COUNT(*)
FROM emp
GROUP BY deptno
;

-- then convert count to asterisks
SELECT deptno,
    LPAD('*', COUNT(*), '*') AS emp_count
FROM emp
GROUP BY deptno
;

/* 12.10 Create Vertical Histograms */

SELECT
    CASE WHEN deptno=10 THEN '*' END AS dept_10,
    CASE WHEN deptno=20 THEN '*' END AS dept_20,
    CASE WHEN deptno=30 THEN '*' END AS dept_30,
    CASE WHEN deptno NOT IN (10, 20, 30) THEN '*' END AS dept_other
FROM emp
;

-- assign group number

SELECT
    (SELECT COUNT(*) FROM emp e2
    WHERE e.deptno=e2.deptno
    AND e.empno <= e2.empno) AS grp,
    CASE WHEN deptno=10 THEN '*' END AS dept_10,
    CASE WHEN deptno=20 THEN '*' END AS dept_20,
    CASE WHEN deptno=30 THEN '*' END AS dept_30,
    CASE WHEN deptno NOT IN (10, 20, 30) THEN '*' END AS dept_other
FROM emp e
;

-- use grp number for grouping
-- to enable retrieving non-null value in each grp
-- in each column
SELECT 
    MAX(dept_10) AS dept_10, 
    MAX(dept_20) AS dept_20,
    MAX(dept_30) AS dept_30, 
    MAX(dept_other)
FROM (
SELECT
    (SELECT COUNT(*) FROM emp e2
            WHERE e.deptno=e2.deptno
            AND e.empno <= e2.empno) AS grp,
    CASE WHEN deptno=10 THEN '*' END AS dept_10,
    CASE WHEN deptno=20 THEN '*' END AS dept_20,
    CASE WHEN deptno=30 THEN '*' END AS dept_30,
    CASE WHEN deptno NOT IN (10, 20, 30) THEN '*' END AS dept_other
FROM emp e
) x
GROUP BY grp
ORDER BY grp DESC
;

-- order by columns and see if that makes a diff
SELECT 
    MAX(dept_10) AS dept_10, 
    MAX(dept_20) AS dept_20,
    MAX(dept_30) AS dept_30, 
    MAX(dept_other)
FROM (
SELECT
    (SELECT COUNT(*) FROM emp e2
            WHERE e.deptno=e2.deptno
            AND e.empno <= e2.empno) AS grp,
    CASE WHEN deptno=10 THEN '*' END AS dept_10,
    CASE WHEN deptno=20 THEN '*' END AS dept_20,
    CASE WHEN deptno=30 THEN '*' END AS dept_30,
    CASE WHEN deptno NOT IN (10, 20, 30) THEN '*' END AS dept_other
FROM emp e
) x
GROUP BY grp
ORDER BY 1, 2, 3, 4
;

-- Note that book solution for above query used order by 
-- 1 desc, 2 desc, 3 desc... but that approach
-- caused my columns to be ordered backwards

/* 12.11 Returning non-group by columns */

-- Return deptno, ename, job, sal, and two new
-- columns that indicate if emp has highest or 
-- lowest sal in the dept and if emp has highest
-- or lowest sal in the job role

/*
SELECT deptno,
    ename,
    job,
    sal
FROM __x__
WHERE sal in (min_sal_dept,
                min_sal_job,
                max_sal_dept,
                max_sal_job)
;
*/
-- Build a table with each employee's status

SELECT 
    empno,
    CASE e.sal  
        WHEN (SELECT MIN(e2.sal)
            FROM emp e2
            WHERE e2.deptno=e.deptno)
            THEN "LOW SAL IN DEPT"
        WHEN (SELECT MAX(e2.sal)
            FROM emp e2
            WHERE e2.deptno = e.deptno)
            THEN "HIGH SAL IN DEPT"
        END AS dept_status,
    CASE e.sal
        WHEN (SELECT MIN(e2.sal)
            FROM emp e2
            WHERE e2.job=e.job)
            THEN "LOW SAL IN JOB"
        WHEN (SELECT MAX(e2.sal)
            FROM emp e2
            WHERE e2.job=e.job)
            THEN "HIGH SAL IN JOB"
        END AS job_status
FROM emp e
;

-- join table to empl table

SELECT deptno,
    ename,
    job,
    sal,
    dept_status,
    job_status
FROM emp
LEFT JOIN (
    SELECT 
        empno,
        CASE e.sal  
            WHEN (SELECT MIN(e2.sal)
                FROM emp e2
                WHERE e2.deptno=e.deptno)
                THEN "LOW SAL IN DEPT"
            WHEN (SELECT MAX(e2.sal)
                FROM emp e2
                WHERE e2.deptno = e.deptno)
                THEN "HIGH SAL IN DEPT"
            END AS dept_status,
        CASE e.sal
            WHEN (SELECT MIN(e2.sal)
                FROM emp e2
                WHERE e2.job=e.job)
                THEN "LOW SAL IN JOB"
            WHEN (SELECT MAX(e2.sal)
                FROM emp e2
                WHERE e2.job=e.job)
                THEN "HIGH SAL IN JOB"
            END AS job_status
    FROM emp e) job_status_table
ON job_status_table.empno = emp.empno
ORDER BY deptno, job, ename
;

-- filter for only those with something in either
-- of the status columns
-- also coalesce nulls for status to empty string
-- for readability
SELECT deptno,
    ename,
    job,
    sal,
    COALESCE(dept_status, '') as dept_status,
    COALESCE(job_status, '') AS job_status
FROM emp
LEFT JOIN (
    SELECT 
        empno,
        CASE e.sal  
            WHEN (SELECT MIN(e2.sal)
                FROM emp e2
                WHERE e2.deptno=e.deptno)
                THEN "LOW SAL IN DEPT"
            WHEN (SELECT MAX(e2.sal)
                FROM emp e2
                WHERE e2.deptno = e.deptno)
                THEN "HIGH SAL IN DEPT"
            END AS dept_status,
        CASE e.sal
            WHEN (SELECT MIN(e2.sal)
                FROM emp e2
                WHERE e2.job=e.job)
                THEN "LOW SAL IN JOB"
            WHEN (SELECT MAX(e2.sal)
                FROM emp e2
                WHERE e2.job=e.job)
                THEN "HIGH SAL IN JOB"
            END AS job_status
    FROM emp e) job_status_table
ON job_status_table.empno = emp.empno
WHERE NOT (dept_status is NULL AND job_status IS NULL)
ORDER BY deptno, job, ename
;

/* Note that this solution does not address
how to classify an employee who is the only one
in the dept or job.
E.g. emp KING (JOB=PRESIDENT). The book does not
address this either and its approach classifies
King as 'High [Top] Sal in Job'.

Add condition to check if there is more than one
employee in the job or dept.
*/

-- Note that must first refactor CASE statement from
-- syntax of CASE e.sal WHEN X to CASE WHEN e.sal = x

SELECT deptno,
    ename,
    job,
    sal,
    COALESCE(dept_status, '') as dept_status,
    COALESCE(job_status, '') AS job_status
FROM emp
LEFT JOIN (
    SELECT 
        empno,
        CASE
            WHEN 1 = (SELECT COUNT(*) FROM 
            emp e2 WHERE e2.deptno=e.deptno)
            THEN "**ONLY EMPL IN DEPT**"
            WHEN e.sal = (SELECT MIN(e2.sal)
                FROM emp e2
                WHERE e2.deptno=e.deptno)
                THEN "LOW SAL IN DEPT"
            WHEN e.sal = (SELECT MAX(e2.sal)
                FROM emp e2
                WHERE e2.deptno = e.deptno)
                THEN "HIGH SAL IN DEPT"
            END AS dept_status,
        CASE
            WHEN 1 = (SELECT COUNT(*) FROM
            emp e2 WHERE e2.job=e.job)
            THEN "**ONLY EMPL IN JOB**"
            WHEN e.sal = (SELECT MIN(e2.sal)
                FROM emp e2
                WHERE e2.job=e.job)
                THEN "LOW SAL IN JOB"
            WHEN e.sal = (SELECT MAX(e2.sal)
                FROM emp e2
                WHERE e2.job=e.job)
                THEN "HIGH SAL IN JOB"
            END AS job_status
    FROM emp e) job_status_table
ON job_status_table.empno = emp.empno
WHERE NOT (dept_status is NULL AND job_status IS NULL)
ORDER BY deptno, job, ename
;

-- book solution might be somewhat cleaner,
-- because it separates the subquery to find
-- the max/min salaries from the case statement

SELECT 
    deptno,
    ename,
    job,
    sal,
    CASE 
        WHEN sal = max_by_dept
        THEN "HIGH SAL IN DEPT"
        WHEN sal = min_by_dept
        THEN "LOW SAL IN DEPT"
        END AS dept_status,
    CASE
        WHEN sal = max_by_job
        THEN "HIGH SAL IN JOB"
        WHEN sal = min_by_job
        THEN "LOW SAL IN JOB"
        END AS job_status
FROM (
    SELECT
        e.deptno,
        e.ename,
        e.job,
        e.sal,
        (SELECT MAX(sal) FROM emp e2
        WHERE e2.deptno = e.deptno) AS max_by_dept,
        (SELECT MIN(sal) FROM emp e2
        WHERE e2.deptno = e.deptno) AS min_by_dept,
        (SELECT MAX(sal) FROM emp e2
        WHERE e2.job = e.job) AS max_by_job,
        (SELECT MIN(sal) FROM emp e2
        WHERE e2.job = e.job) AS min_by_job
    FROM emp e) emp_with_sal_status

WHERE sal in (max_by_dept, min_by_dept,
            max_by_job, min_by_job)
ORDER BY deptno, job, ename
;

/* 12.12 Calculating simple subtotals */

-- Sum salaries in table emp by job (subtotal); 
-- include the sum of all salaries in emp (grand total)

SELECT 
    COALESCE(job, 'TOTAL') AS job,
    SUM(sal) AS salary_total 
FROM emp
GROUP BY job
WITH ROLLUP
;
SHOW WARNINGS;

/* Received warning:
+---------+------+----------------------------------------------+
| Level   | Code | Message                                      |
+---------+------+----------------------------------------------+
| Warning | 1052 | Column 'job' in group statement is ambiguous |
+---------+------+----------------------------------------------+
*/

-- Duplicate the coalesce statement in group by 
-- to attempt to remove ambiguity of job column reference
SELECT 
    COALESCE(job, 'TOTAL') AS job,
    SUM(sal) AS salary_total 
FROM emp
GROUP BY COALESCE(job, 'TOTAL')
WITH ROLLUP
;

-- The above solution worked; no warning was thrown

-- now implement without rollup keyword
SELECT
    job,
    SUM(sal) AS salary_total
FROM emp
GROUP BY job

UNION ALL

SELECT 'TOTAL',
        SUM(sal) AS salary_total
FROM emp
;

/* 12.13 Calculating subtotals for all combinations */

-- SQL Server has CUBE expression with GROUP BY,
-- but in MySQL must use series of UNION ALL expressions

SELECT
    deptno,
    job,
    "TOTAL BY DEPT AND JOB" AS category,
    SUM(sal) AS salary_total
FROM emp
GROUP BY deptno, job

UNION ALL

SELECT 
    NULL,
    job,
    "TOTAL BY JOB",
    SUM(sal)
FROM emp
GROUP BY job

UNION ALL

SELECT
    deptno,
    NULL,
    "TOTAL BY DEPT",
    SUM(sal)
FROM emp
GROUP BY deptno

UNION ALL

SELECT
    NULL,
    NULL,
    "GRAND TOTAL",
    SUM(sal)
FROM emp
;

/* 12.14 Identifying rows that are not subtotals */

/* Highlights use of cube extension and grouping func,
which are not implemented in MySQL */

/* 12.15 Using case expressions to flag rows 
12.16 Creating a sparse matrix */

/* These problems were demonstrated in
the earlier problems */

/* 12.17 Grouping rows by units of time */

/* Uses table not provided of transactions with 
- trx id
- trx date (datetime)
- trx cnt

Each row is a count of transactions per second.

To get a row for each 5-second time period,
use technique from 12.7 to divide trx id by 5 and
take ceiling from result. That creates logical buckets
of 5 transactions in each bucket.

Then group by that value (group ID) and take the min,
max, and sum of trx cnt for each group.

Workaround if you don't have a trx id column:
- Create column for hour
- Create column for seconds / 5 as grp id
- Group by hr and grp id

An interesting use of the 12.17 problem/solution is
to add new columns to original table to create a report
with a column for running total of trx cnt for that 
group and an indicator column that just has an "x" for
each transaction that represents the end of the group.
*/

/* 12.18 Performing aggregations over different groups/
partitions simultaneously*/

/* Create result set with employee's name, dept,
total # of empls in the dept, total # of empls with
same job role, and total # of empls
*/

SELECT
    ename,
    deptno,
    (SELECT COUNT(*) FROM emp e2 
    WHERE e2.deptno = e.deptno) AS dept_cnt,
    job,
    (SELECT COUNT(*) FROM emp e2
    WHERE e2.job = e.job) AS job_cnt,
    (SELECT COUNT(*) FROM emp) AS total_empl_cnt
FROM emp e
ORDER BY deptno, job, ename
;

/* 12.19 Performing aggregations over a moving
range of values */

-- Compute moving sum of salaries in emp table
-- every 90 days, starting with hire date of first
-- employee

-- first calculate date 90 days prior
-- to check syntax
SELECT hiredate,
        sal,
        DATE_SUB(e.hiredate, INTERVAL 90 DAY) 
            AS 90_day_prior
FROM emp e
ORDER BY hiredate
;

-- use above syntax to calculate spending
-- for prior 90 days
SELECT hiredate,
        sal,
        (SELECT SUM(sal) FROM emp e2
        WHERE e2.hiredate BETWEEN 
        DATE_SUB(
            e.hiredate, INTERVAL 90 DAY)
            AND e.hiredate) 
            AS spending_pattern
FROM emp e
ORDER BY hiredate
;

/* 12.20 Pivoting a result set with subtotals */

/* Demonstrates GROUPING() func. No MySQL solution
provided. */

