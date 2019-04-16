/* CHAPTER 3: WORKING WITH MULTIPLE TABLES */

/* Skip 3.1, 3.2 */

/* 3.3 Finding rows in common between two tables */

-- Find common rows between two tables, but
-- there are multiple columns on which to join

-- Specifically, retrieve all rows in employee table matching
-- employees in following view

DROP VIEW IF EXISTS V;

CREATE VIEW V AS
    select ename, job, sal
    FROM emp
    WHERE job="CLERK"
;

SELECT * FROM V;

-- Retrieve empno, ename, job, sal, and deptno
-- of all employees in emp that match rows in view V

SELECT
    e.empno,
    e.ename,
    e.job,
    e.sal,
    e.deptno
FROM emp e
INNER JOIN V v
ON v.ename = e.ename
AND v.job = e.job
AND v.sal = e.sal
;

DROP VIEW IF EXISTS V;

/* 3.4 Retrieve values from one table that do not exist in another */

-- Find depts in table dept that do not exist in table emp
SELECT deptno
FROM dept
WHERE deptno NOT IN (
    SELECT deptno FROM emp
)
;

-- Alternate solution using outer join
SELECT d.deptno
FROM dept d
LEFT JOIN emp e
ON d.deptno=e.deptno
WHERE e.deptno IS NULL
;

-- Alternate solution to NOT IN using NOT EXISTS
-- Necessary if the subquery used after NOT IN can contain NULLs

-- First, illustrate the problem with NOT in
-- The following query returns an empty set
-- even though it might be expected to return
-- any employee that is not a manager
SELECT empno
FROM emp
WHERE empno NOT IN (
    SELECT mgr FROM emp
)
;

-- Rewrite above query using NOT EXISTS
SELECT empno
FROM emp
WHERE NOT EXISTS (
    SELECT 1 FROM emp e2
    WHERE e2.mgr=emp.empno
)
;

-- test results received above
-- with another alernative
SELECT empno
FROM emp
WHERE empno NOT IN (
    SELECT mgr FROM emp
    WHERE mgr IS NOT NULL
)
;

-- Finally, rewrite the query to find depts with no employees
-- using NOT EXISTS
SELECT deptno
FROM dept d
WHERE NOT EXISTS (
    SELECT 1 FROM emp e
    WHERE d.deptno=e.deptno
)
;

/* 3.5 Retrieving rows from one table that do not correspond
in another */

-- Similar to previous problem but returning more than just one
-- column

-- Return all columns from dept for any depts that have no employees
SELECT 
    d.deptno,
    d.dname,
    d.loc
FROM dept d
LEFT JOIN emp e
ON e.deptno=d.deptno
WHERE e.deptno IS NULL
;

-- Test if above query would work with null
-- condition moved to ON statement
SELECT 
    d.deptno,
    d.dname,
    d.loc,
    e.deptno
FROM dept d
LEFT JOIN emp e
ON e.deptno=d.deptno
AND e.deptno IS NULL
;
/* Result: Placing 'is null' condition in the ON expression
does not give expected results (see below).

+--------+------------+----------+--------+
| deptno | dname      | loc      | deptno |
+--------+------------+----------+--------+
|     10 | ACCOUNTING | NEW YORK |   NULL |
|     20 | RESEARCH   | DALLAS   |   NULL |
|     30 | SALES      | CHICAGO  |   NULL |
|     40 | OPERATIONS | BOSTON   |   NULL |
+--------+------------+----------+--------+
4 rows in set (0.00 sec)
*/

/* 3.7 Determining whether two tables have the same data */

/* Consider following view. Determine if this view and the table emp
have same data (cardinality and values).
*/

DROP VIEW IF EXISTS V;

CREATE VIEW V AS
SELECT * FROM emp WHERE deptno != 10
UNION ALL
SELECT * FROM emp WHERE ename = "WARD"
;

SELECT * FROM V;

-- Test cardinality first
SELECT COUNT(*) view_count FROM V;
SELECT COUNT(*) emp_count FROM emp;

