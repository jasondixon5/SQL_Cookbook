/* CHAPTER 12: REPORTING AND WAREHOUSING */

/* 12.10 Creating vertical histograms */

-- Create histogram of number of employees in each dept

-- Create columns for each dept and 
-- an asterisk for each employee
SELECT
    CASE WHEN deptno = 10 THEN "*" END AS d10,
    CASE WHEN deptno = 20 THEN "*" END AS d20,
    CASE WHEN deptno = 30 THEN "*" END AS d30
FROM emp
;

-- Sort columns so asterisk all line up from bottom
SELECT
    CASE WHEN deptno = 10 THEN "*" END AS d10,
    CASE WHEN deptno = 20 THEN "*" END AS d20,
    CASE WHEN deptno = 30 THEN "*" END AS d30
FROM emp
ORDER BY 1 DESC, 2 DESC, 3 DESC 
;

-- Order by does not work because of nulls across columns 
-- (only sorts first column correctly)

-- Create grouping by assigning row num within each dept
-- and then using aggregate func (similar to how grouped
-- employees by job in earlier problem)
SELECT
    CASE WHEN deptno = 10 THEN "*" END AS d10,
    CASE WHEN deptno = 20 THEN "*" END AS d20,
    CASE WHEN deptno = 30 THEN "*" END AS d30,
    (SELECT COUNT(*) FROM emp e2
    WHERE e2.empno <= emp.empno
    AND e2.deptno = emp.deptno) AS grp_num
FROM emp
;

-- Use row num within each dept to group
-- Take max() from each group
SELECT
    MAX(CASE WHEN deptno = 10 THEN "*" END) AS d10,
    MAX(CASE WHEN deptno = 20 THEN "*" END) AS d20,
    MAX(CASE WHEN deptno = 30 THEN "*" END) AS d30
FROM emp
GROUP BY (
    SELECT COUNT(*) FROM emp e2
    WHERE e2.empno <= emp.empno
    AND e2.deptno = emp.deptno)
;
-- Add ordering
SELECT
    MAX(CASE WHEN deptno = 10 THEN "*" END) AS d10,
    MAX(CASE WHEN deptno = 20 THEN "*" END) AS d20,
    MAX(CASE WHEN deptno = 30 THEN "*" END) AS d30
FROM emp
GROUP BY (
    SELECT COUNT(*) FROM emp e2
    WHERE e2.empno <= emp.empno
    AND e2.deptno = emp.deptno)
ORDER BY 1, 2, 3
;

/* Skip 12.11 */

/* 12.12 Calculating simple subtotals */

-- Get sal by job and a total salary for table
SELECT
    job,
    SUM(sal) AS "total salary"
FROM emp
GROUP BY job WITH ROLLUP
;

-- Add description for grand total row
-- which is normally null
SELECT
    COALESCE(job, "TOTAL") AS job,
    SUM(sal) AS "total salary"
FROM emp
GROUP BY job WITH ROLLUP
;

/* 12.13 Calculating subtotals for all possible combinations */

-- Create tables with totals and then UNION them
SELECT
    deptno,
    job,
    "TOTAL BY DEPT AND JOB" AS category,
    SUM(sal) AS "salary total"
FROM emp
GROUP BY deptno, job
;

SELECT
    NULL,
    job,
    "TOTAL BY JOB",
    SUM(sal)
FROM emp
GROUP BY job
;

SELECT
    deptno,
    NULL,
    "TOTAL BY DEPT",
    SUM(sal)
FROM emp
GROUP BY deptno
;

SELECT
    NULL,
    NULL,
    "GRAND TOTAL",
    SUM(sal)
FROM emp
;

SELECT
    deptno,
    job,
    "TOTAL BY DEPT AND JOB" AS category,
    SUM(sal) AS "salary total"
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

-- Note that there is no need to order result,
-- because the group by statements will automatically
-- order each subtotal by the grouping columns
-- There is also no need to use UNION (vs. UNION ALL),
-- since there are no duplicate rows.

/* 12.17 Grouping by Units of Time */

/* Do not have the table used as an example, so explore approach
with integers representing seconds stamp.
Problem is to use the timestamp to create a row that sums
transactions over every 5 seconds.
*/

-- explore what mod returns
SELECT 7%5, 8%5, 9%5, 10%5, 11%5, 12%5
FROM DUAL;

-- mod will number consecutive rows differently
-- problem is to number consecutive rows the same,
-- with the numbering incrementing every 5 seconds

-- Try ceiling
SELECT CEILING(7/5), CEILING(8/5), CEILING(9/5), CEILING(10/5), CEILING(11/5), 
CEILING(12/5) FROM DUAL;

-- This returns the same number every 4 rows
-- Book solution uses the transaction date
-- and subtracts 1/24/60/60 from it,
-- then divides that number by 5 and takes its ceiling

-- what number is 1/24/60/60?
SET @time_sub = (1/24/60/60);
SELECT @time_sub FROM DUAL;

-- 1/24/60/60 represents one second
-- see: http://www.dba-oracle.com/t_date_arithmetic.htm
-- (the book example is for Oracle)

-- SET @test_date = (SELECT NOW());

-- SELECT @test_date FROM DUAL;
-- SELECT @test_date - @time_sub FROM DUAL;

SET @test_date = (SELECT TIMESTAMP '2005-07-28 19:03:07');
SELECT @test_date FROM DUAL;

SELECT DATE_FORMAT(@test_date, "%i%s");

SELECT DATE_FORMAT(
    DATE_SUB(@test_date, INTERVAL 1 SECOND), 
    "%i%s") time_to_grp_test;

SELECT DATE_FORMAT(
    DATE_SUB(@test_date, INTERVAL 1 SECOND), 
    "%i%s") time_to_grp_test;

SELECT 0306/5.0;

SELECT CEILING(0306/5.0);

/* 12.18 Performing aggregations over different groups/
partitions simulateously */

-- return result set with each employee's name,
-- dept, number of employees in dept, number of
-- employees with same job, and total employees
-- in company

SELECT
    ename,
    deptno,
    (SELECT COUNT(*) FROM emp e2
    WHERE e2.deptno = emp.deptno) AS deptno_cnt,
    job,
    (SELECT COUNT(*) FROM emp e2
    WHERE e2.job = emp.job) AS job_cnt,
    (SELECT COUNT(*) FROM emp) AS total_empl_cnt
FROM emp
;

/* 12.19 Performing aggregations over a moving range of values */

-- Beginning with first hire date, compute a moving sum of salaries
-- for 90 days prior to current salary

SELECT 
    hiredate,
    sal,
    (
        SELECT SUM(sal) FROM emp e2
        -- sum salaries for all employees with hire dates
        -- between (hiredate - 90 days) and current row hiredate
        WHERE e2.hiredate >= DATE_SUB(emp.hiredate, INTERVAL 90 DAY)
        AND e2.hiredate <= emp.hiredate
        ) AS spending_pattern
FROM emp
ORDER BY hiredate
;

-- MySQL also supports BETWEEN...AND comparison operator
SELECT 
    hiredate,
    sal,
    (
        SELECT SUM(sal) FROM emp e2
        -- sum salaries for all employees with hire dates
        -- between (hiredate - 90 days) and current row hiredate
        WHERE e2.hiredate BETWEEN DATE_SUB(emp.hiredate, INTERVAL 90 DAY)
        AND emp.hiredate
        ) AS spending_pattern
FROM emp
ORDER BY hiredate
;

-- Use a self join instead of a subquery
SELECT
    emp.hiredate,
    emp.sal,
    SUM(e2.sal) AS spending_pattern
FROM emp, emp e2
WHERE e2.hiredate BETWEEN 
    DATE_SUB(emp.hiredate, INTERVAL 90 DAY)
    AND emp.hiredate
GROUP BY emp.hiredate, emp.sal
ORDER BY emp.hiredate
;

/* 12.20 Pivoting a result set with subtotals */

/* Note that the book does not offer a solution for MySQL,
because the book solutions rely on the GROUPING() function
(unsupported by MySQL).*/

-- Create report of each mgr
-- with columns for each dept listing total sal of emps who report
-- to that mgr in that dept
-- Include row at end with total of each column (i.e., each dept)
-- and separate column with that row listing all sals total

/* Failed solution:
SELECT 
    emp.mgr,
    COALESCE(
        (SELECT SUM(sal) FROM emp e2
        WHERE e2.mgr=emp.empno AND e2.deptno=10), 0) AS dept10,
    COALESCE(
        (SELECT SUM(sal) FROM emp e2
        WHERE e2.mgr=emp.empno AND e2.deptno=20), 0) AS dept20,
    COALESCE(
        (SELECT SUM(sal) FROM emp e2
        WHERE e2.mgr=emp.empno AND e2.deptno=30), 0) AS dept30,
    NULL AS total
FROM emp
WHERE emp.mgr IS NOT NULL;
*/

-- Create initial table in sparse matrix format
SELECT 
    empno,
    mgr,
    CASE WHEN deptno=10 THEN sal ELSE 0 END AS d10,
    CASE WHEN deptno=20 THEN sal ELSE 0 END AS d20,
    CASE WHEN deptno=30 THEN sal ELSE 0 END AS d30
FROM emp
;

-- Add group number with unique consecutive group num
-- within each manager and dept
SELECT 
    empno,
    mgr,
    CASE WHEN deptno=10 THEN sal ELSE 0 END AS d10,
    CASE WHEN deptno=20 THEN sal ELSE 0 END AS d20,
    CASE WHEN deptno=30 THEN sal ELSE 0 END AS d30,
    (SELECT COUNT(*) FROM emp e2
    WHERE e2.empno <= emp.empno 
    AND e2.mgr=emp.mgr
    AND e2.deptno=emp.deptno) AS grp_num
FROM emp
WHERE mgr IS NOT NULL
ORDER BY 2, 6
;

-- Group by grp_num and sum within each mgr/group
SELECT 
    mgr,
    SUM(CASE WHEN deptno=10 THEN sal ELSE 0 END) AS d10,
    SUM(CASE WHEN deptno=20 THEN sal ELSE 0 END) AS d20,
    SUM(CASE WHEN deptno=30 THEN sal ELSE 0 END) AS d30
FROM emp
WHERE mgr IS NOT NULL
GROUP BY mgr, (
    SELECT COUNT(*) FROM emp e2
    WHERE e2.empno <= emp.empno 
    AND e2.mgr=emp.mgr
    AND e2.deptno=emp.deptno)
;

-- UPDATE: No need to use grp_num for ordering
-- Can just group by mgr
SELECT 
    mgr,
    SUM(CASE WHEN deptno=10 THEN sal ELSE 0 END) AS d10,
    SUM(CASE WHEN deptno=20 THEN sal ELSE 0 END) AS d20,
    SUM(CASE WHEN deptno=30 THEN sal ELSE 0 END) AS d30
FROM emp
WHERE mgr IS NOT NULL
GROUP BY mgr
;

-- Now add column for grand total (blank for now)
SELECT 
    mgr,
    SUM(CASE WHEN deptno=10 THEN sal ELSE 0 END) AS d10,
    SUM(CASE WHEN deptno=20 THEN sal ELSE 0 END) AS d20,
    SUM(CASE WHEN deptno=30 THEN sal ELSE 0 END) AS d30,
    NULL AS 'grand total'
FROM emp
WHERE mgr IS NOT NULL
GROUP BY mgr
;

-- Now create a row for subtotals and grand total
SELECT
    NULL AS mgr,
    (SELECT SUM(sal) FROM emp
    WHERE deptno=10 AND mgr IS NOT NULL) AS d10,
    (SELECT SUM(sal) FROM emp
    WHERE deptno=20 AND mgr IS NOT NULL) AS d20,
    (SELECT SUM(sal) FROM emp
    WHERE deptno=30 AND mgr IS NOT NULL) AS d30,
    (SELECT sum(sal) FROM emp
    WHERE mgr IS NOT NULL) AS total
FROM DUAL
;

-- Put the two tables together via UNION ALL
SELECT 
    mgr,
    SUM(CASE WHEN deptno=10 THEN sal ELSE 0 END) AS d10,
    SUM(CASE WHEN deptno=20 THEN sal ELSE 0 END) AS d20,
    SUM(CASE WHEN deptno=30 THEN sal ELSE 0 END) AS d30,
    NULL AS 'grand total'
FROM emp
WHERE mgr IS NOT NULL
GROUP BY mgr

UNION ALL

SELECT
    NULL AS mgr,
    (SELECT SUM(sal) FROM emp
    WHERE deptno=10 AND mgr IS NOT NULL) AS d10,
    (SELECT SUM(sal) FROM emp
    WHERE deptno=20 AND mgr IS NOT NULL) AS d20,
    (SELECT SUM(sal) FROM emp
    WHERE deptno=30 AND mgr IS NOT NULL) AS d30,
    (SELECT sum(sal) FROM emp
    WHERE mgr IS NOT NULL) AS total
FROM DUAL
;
