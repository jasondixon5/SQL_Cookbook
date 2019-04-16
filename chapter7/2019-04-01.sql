/* Chapter 7: Working with numbers */

/* 7.6 Generating a running total */

-- Calculate running total of salaries for all employees

SELECT 
    empno,
    ename,
    sal,
    (SELECT SUM(sal) FROM emp e2
    WHERE e2.empno <= e.empno) AS running_total_sal
FROM emp e
ORDER BY empno
;

-- Book problem instructs to order by sal when possible
-- Implement that approach
-- Use empno as tie breaker in case of identical sals
SELECT 
    empno,
    ename,
    sal,
    (SELECT SUM(sal) FROM emp e2
    WHERE e2.sal < e.sal
    OR (e2.sal = e.sal AND e2.empno <= e.empno)) 
        AS running_total_sal
FROM emp e
ORDER BY sal, empno
;

/* 7.7 Generating a running product */

-- compute running product of employees salaries
-- use addition of logs to simulate multiplication

SELECT 
    empno,
    ename,
    sal,
    (SELECT EXP(SUM(LN(sal))) FROM emp e2
    WHERE e2.sal < e.sal
    OR (e2.sal = e.sal AND e2.empno <= e.empno))
        AS running_product
FROM emp e
ORDER BY sal, empno
;

/* 7.8 Calculate a running difference */

/* Note: Does not use book solution, which is incorrect */

-- compute running diff on salaries in dept 10
-- order by empno 

-- Note that initialization is not strictly
-- necessary (will be set to first sal below)
-- SET @running_diff = 0;
-- If encounter an error will calculate
-- NULL - sal (e..g, NULL - 1000) which will
-- return NULL

SELECT
    empno,
    ename,
    sal,
    CASE empno WHEN (SELECT MIN(e2.empno) FROM emp e2
                        WHERE deptno in (10))
                THEN @running_diff := sal
                ELSE @running_diff := @running_diff - sal
                END AS running_difference
FROM emp
WHERE deptno in (10)
ORDER BY empno
;

-- calculate for all emps (not just dept 10)
SELECT
    empno,
    ename,
    sal,
    CASE empno WHEN (SELECT MIN(e2.empno) FROM emp e2)
                THEN @running_diff := sal
               ELSE @running_diff := @running_diff - sal
               END AS running_difference
FROM emp
ORDER BY empno
;

/* 7.9 Calculating a mode */

-- find mod of salaries in dept 20

-- examine salary freqs
SELECT deptno,
        sal,
        COUNT(*) sal_freq
FROM emp
WHERE deptno in (20)
GROUP BY deptno, sal
;

-- extract most common sal row (highest sal_freq)
SELECT deptno,
        sal,
        COUNT(*) sal_freq
FROM emp
WHERE deptno in (20)
GROUP BY deptno, sal
HAVING COUNT(*) >= ALL (SELECT COUNT(*) FROM emp
                        WHERE deptno in (20)
                        GROUP BY sal)
;

-- clean up to extract just sal
SELECT sal
FROM emp
WHERE deptno in (20)
GROUP BY sal
HAVING COUNT(*) >= ALL (SELECT COUNT(*) FROM emp
                        WHERE deptno in (20)
                        GROUP BY sal)
;

/* 7.10 Calculating a median */

/* Skip */

/* 7.11 Determining the percentage of a total */

-- Determine percentage each dept contributes to total

-- subquery approach
SELECT deptno,
        SUM(sal) dept_total_sal,
        SUM(sal)/(SELECT SUM(sal) FROM emp) AS pcnt_of_dept_sal_to_total_sal
FROM emp
GROUP BY deptno
;

-- percentage for just dept 10
-- case statement approach
SELECT SUM(CASE WHEN deptno in (10) THEN sal END) / SUM(sal)
    AS dept_10_pcnt_of_total_sal
FROM emp
;

/* 7.12 Aggregating nullable columns */

-- get average comm for dept 30
-- Note that comm is a nullable column

SELECT AVG(COALESCE(comm, 0)) AS avg_comm
FROM emp
WHERE deptno in (30)
;

-- get average sal and comm by dept

SELECT deptno,
        AVG(sal) as "average salary",
        AVG(COALESCE(comm, 0)) as "average commission"
FROM emp
GROUP BY deptno
;

/* 7.13 Computing averages without high/low values */

-- compute avg salary of all employees excluding
-- highest and lowest salaries

SELECT AVG(sal) AS "avg sal without outliers"
FROM emp
WHERE sal NOT IN (
        (SELECT MAX(sal) FROM emp),
        (SELECT MIN(sal) FROM emp))
;

/* 7.14 Converting alphanumeric strings into numbers */

/* Not supported by MySQL */

/* 7.15 Changing values in a running total */

-- assume following view 
DROP VIEW IF EXISTS V;

CREATE VIEW V (id, amt, trx)
AS
SELECT 1, 100, 'PR' FROM T1 UNION ALL
SELECT 2, 100, 'PR' FROM T1 UNION ALL
SELECT 3, 50, 'PY' FROM T1 UNION ALL
SELECT 4, 100, 'PR' FROM T1 UNION ALL
SELECT 5, 200, 'PY' FROM T1 UNION ALL
SELECT 6, 50, 'PY' FROM T1
;

SELECT * FROM V;

-- compute running balance
-- with 'PY' deducting from sum
-- and other transaction types adding to it

SELECT
    CASE trx 
        WHEN 'PR' THEN 'PURCHASE'
        WHEN 'PY' THEN 'PAYMENT'
        ELSE 'UNKNOWN TYPE'
        END AS transaction_type,
    amt AS transaction_amount,
    (SELECT SUM(
        CASE v2.trx WHEN 'PY' THEN -v2.amt
        ELSE v2.amt
        END)
    FROM V AS v2
    WHERE v2.id <= v.id) AS balance
FROM V
;
