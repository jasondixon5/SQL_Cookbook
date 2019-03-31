/* Chapter 7: Working With Numbers */

/* 7.6 Generating a running total */

/* Take solution from yesterday and simplify it.
Yesterday's solution included logic to accurately
calculate the salary if two employees were hired
the same day (using empno as a tie breaker).

Yesterday's solution:

SELECT 
    empno,
    ename,
    hiredate,
    deptno,
    sal,
    CASE WHEN (SELECT COUNT(*) FROM emp e2
                WHERE e2.hiredate = e.hiredate) > 1
        THEN (
            (SELECT SUM(sal) FROM emp e2
            WHERE e2.hiredate < e.hiredate) + 
            (SELECT SUM(sal) FROM emp e2
            WHERE e2.hiredate = e.hiredate
            AND e2.empno <= e.empno)
            )
        ELSE (
            SELECT SUM(sal) FROM emp e2
            WHERE e2.hiredate <= e.hiredate)
        END
        AS running_total_sal
FROM emp e
ORDER BY hiredate, empno
;
*/

SELECT 
    deptno,
    empno,
    ename,
    hiredate,
    sal,
    (SELECT SUM(sal) FROM emp e2
    -- Include everyone hired up to
    -- but not included this row's
    -- hire date
    WHERE e2.hiredate < e.hiredate
    -- Also include anyone hired
    -- on this row's hire date
    -- if empno is lower
    -- Captures anyone appearing in
    -- result so far (which will
    -- be sorted by hiredate, then empno)
    -- and includes this row's salary
    -- This approach uses empno
    -- to distinguish empls hired
    -- the same day
    OR (e2.hiredate = e.hiredate
        AND e2.empno <= e.empno))
        AS running_total_sal
FROM emp e
ORDER BY hiredate, empno
;

/* Generating a running product */

/* Uses logs to simulate multiplication.
ln(AB) = ln(A) + ln(B)

ln(sal1 * sal2) = ln(sal1) + ln(sal2)

1. Calculate log of each salary up to and including
current row salary.
2. Sum logs found above.
3. Convert the summed figure by raising e to the 
summed figure above (via the EXP() func).
*/

-- For this solution, ignore hire date condition handled
-- in 7.6 above and just calculate the running product
-- in order of empno.

-- Show sal and ln of sal for each row
SELECT
    deptno,
    empno,
    ename,
    sal,
    LN(sal)
FROM emp e
ORDER BY empno
;

-- Calculating running sum of logs
SELECT
    deptno,
    empno,
    ename,
    sal,
    (SELECT SUM(LN(sal)) FROM emp e2
    WHERE e2.empno <= e.empno) AS ln_running_sum
FROM emp e
ORDER BY empno
;

-- Convert by raising e to running sum of logs
SELECT
    deptno,
    empno,
    ename,
    sal,
    (SELECT EXP(SUM(LN(sal))) FROM emp e2
    WHERE e2.empno <= e.empno) AS running_product
FROM emp e
ORDER BY empno
;

/* Calculating a running difference */

/* Had trouble with this problem before, so here
is book solution to validate and start */

-- calculate running diff for employees in dept 10
SELECT a.empno,
    a.ename,
    a.sal,
    (SELECT 
        CASE WHEN a.empno=min(b.empno) THEN SUM(b.sal)
        ELSE SUM(-b.sal)
        END
    FROM emp b
    WHERE b.empno <= a.empno
    AND b.deptno=a.deptno) as rnk
FROM emp a
WHERE a.deptno=10
;

/*
Result set:
+-------+--------+------+-------+
| empno | ename  | sal  | rnk   |
+-------+--------+------+-------+
|  7782 | CLARK  | 2450 |  2450 |
|  7839 | KING   | 5000 | -7450 |
|  7934 | MILLER | 1300 | -8750 |
+-------+--------+------+-------+
*/

/* NOTES ON ABOVE
The rnk column, which is supposed to be a running difference,
appears to just list the running sum * -1. 

This is not my understanding of a running difference.

As when practicing before, I do not believe a valid solution
is given to calculate a running difference as I understand it
for this problem.
*/

/* Try with variable to store diff up to that point */
SET @cum_diff = 0;

SELECT
    empno,
    ename,
    deptno,
    sal,
    CASE WHEN empno = (SELECT min(empno) FROM emp)
    -- first entry should just list the sal
    -- subsequent entries will subtract salary from 
    -- the running diff
    THEN @cum_diff := @cum_diff + sal 
    ELSE @cum_diff := @cum_diff - sal
    END AS running_diff
FROM emp
ORDER BY empno
;

/* Try with variable declared within query */
/* Rename variable to avoid bleedover from prior query
since vars are technically session variables */
/* Also simplified condition for first employee
to just reset variable value to sal of that empl */

SELECT
    empno,
    ename,
    deptno,
    sal,
    CASE WHEN empno = (SELECT min(empno) FROM emp)
    -- first entry should just list the sal
    -- subsequent entries will subtract salary from 
    -- the running diff
    THEN @running_diff := sal 
    ELSE @running_diff := @running_diff - sal
    END AS running_diff
FROM emp
CROSS JOIN
(SELECT @running_diff :=0) x
ORDER BY empno
;

/* 7.9 Calculating a Mode */

-- find mode of salaries in dept 20

-- examine salaries
SELECT sal FROM EMP WHERE deptno in (20);

-- find salary counts
SELECT sal, COUNT(*)
FROM emp
WHERE deptno in (20)
GROUP BY sal
;

-- use salary count table as inline view
SELECT sal 
FROM (
    SELECT sal,
            COUNT(*) AS sal_freq
    FROM emp
    WHERE deptno in (20)
    GROUP BY sal) x
WHERE sal_freq = (
    SELECT MAX(sal_freq) 
    FROM 
        (SELECT sal,
        COUNT(*) AS sal_freq
        FROM emp
        WHERE deptno in (20)
        GROUP BY sal) x)
;

/* Book solution */

/* Uses filter on grouped table and ALL comparison to
get salaries with greatest frequency */

SELECT sal
FROM emp
WHERE deptno in (20)
GROUP BY sal
HAVING COUNT(*) >= ALL (SELECT COUNT(*)
                        FROM emp
                        WHERE deptno IN (20)
                        GROUP BY sal)
;

/* explore solution */

/* ALL keyword is described as follows in documentation:

The word ALL, which must follow a comparison operator, 
means “return TRUE if the comparison is TRUE for ALL of 
the values in the column that the subquery returns.” 

https://dev.mysql.com/doc/refman/8.0/en/all-subqueries.html

*/

/* 7.10 Calculating a median */

/* Skip for now */

/* 7.11 Determining percent of a total */

-- Determine what % of all salaries are the salaries
-- in dept 10 (the percentage that dept 10 sals contribute
-- to total)

SELECT 
    SUM(sal) / (SELECT SUM(sal) FROM emp) 
    AS dept_10_prop_of_sal
FROM emp
WHERE deptno in (10)
;

-- Calculate for all depts
SELECT 
    deptno,
    SUM(sal) sal_total_by_dept,
    SUM(sal) / (SELECT SUM(sal) FROM emp)
        AS sal_proportion
FROM emp
GROUP BY deptno

UNION ALL

-- add dividor row
SELECT 
    LPAD("-", LENGTH("deptno"), "-"),
    LPAD("-", LENGTH("sal_total_by_dept"), "-"),
    LPAD("-", LENGTH("sal_proportion"), "-")
FROM DUAL

UNION ALL

SELECT 'TOTAL',
    SUM(sal),
    SUM(sal) / SUM(sal)
FROM emp
;

/* Book solution uses a slightly simpler query
to get the total salaries for dept 10 */

-- leverages fact that NULLs are ignored by
-- SUM() func

SELECT (
    SUM(
        CASE WHEN deptno = 10 THEN sal END
        )/SUM(sal)
        )
        AS pct
FROM emp
;

SELECT CASE WHEN deptno = 10 THEN sal END
        AS dept_10_sal
FROM emp
;

SELECT * FROM emp LIMIT 1;

/*
-- try to get each employee's % of total sal
SELECT (CASE WHEN deptno = 10 THEN sal END)/SUM(sal)
        AS dept_10_sal_prop
FROM emp

ERROR 1140 (42000): In aggregated query without GROUP BY, 
expression #1 of SELECT list contains nonaggregated column 
'sql_cookbook.emp.DEPTNO'; this is incompatible with 
sql_mode=only_full_group_by

It appears the book query only works because it's 
summing the salaries from dept 10 and then dividing that sum
by the sum of all sals
*/

/* Use case statements to do column for 
each dept's prop of sal */

SELECT
    COALESCE(SUM(CASE WHEN deptno = 10 THEN sal END)/SUM(sal),0)
        AS dept10_prop,
    COALESCE(SUM(CASE WHEN deptno = 20 THEN sal END)/SUM(sal),0)
        AS dept20_prop,
    COALESCE(SUM(CASE WHEN deptno = 30 THEN sal END)/SUM(sal),0)
        AS dept30_prop,
    COALESCE(SUM(CASE WHEN deptno NOT IN (10, 20, 30) 
        THEN sal END)/SUM(sal),0)
        AS other_dept_prop
FROM emp
;

/* Now calculate same values but as rows instead of columns */

SELECT
    deptno,
    SUM(sal) dept_total_sal,
    SUM(sal) / (SELECT SUM(sal) FROM emp) AS dept_prop_of_salaries
FROM emp
GROUP BY deptno
;

/* 7.15 Changing values in a running total */

-- build view of credit card transactions
-- some rows are payments and some are charges
-- Need to change way value contributes to running
-- total depending on whether transaction is payment or
-- charge

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

SELECT CASE trx
        WHEN "PR" THEN "PURCHASE"
        WHEN "PY" THEN "PAYMENT"
        ELSE "**UNKNOWN TYPE**"
        END AS trx_type,
        amt,
        (SELECT SUM(
            CASE v2.trx WHEN 'PY' THEN -v2.amt
            ELSE v2.amt END)
            FROM V v2
            WHERE v2.id <= v.id) AS balance
FROM V v
;



            