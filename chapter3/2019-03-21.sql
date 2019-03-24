/* Chapter 3: Working with Multiple Tables */

/* 3.1 Stacking one rowset atop another */

SELECT ename AS ENAME_AND_DNAME,
	deptno
FROM emp
WHERE deptno = 10

UNION ALL

SELECT "----------", ""

UNION ALL

SELECT dname,
	deptno
FROM dept
;

/* 3.2 Combining related rows (from mult tables */

SELECT e.ename,
	d.loc
FROM emp e
INNER JOIN dept d
ON e.deptno = d.deptno
WHERE e.deptno = 10
;

/* explore join behavior with a cartesian product */

-- data query will work with
SELECT e.ename, e.deptno FROM emp e WHERE e.deptno = 10;
SELECT d.deptno, d.loc FROM dept d;

-- cartesian product (no join condition)
SELECT e.ename,
	d.loc,
	e.deptno AS emp_deptno,
	d.deptno AS dep_deptno
FROM emp e, dept d
WHERE e.deptno = 10
;

-- add join condition to return correct results
SELECT e.ename,
	d.loc,
	e.deptno AS emp_deptno,
	d.deptno AS dep_deptno
FROM emp e, dept d
WHERE e.deptno = 10 AND e.deptno = d.deptno
;

/* 3.3 Finding common rows between two tables */
/* Perhaps better described as getting unshared columns for rows that share 
some columns */

-- note that book uses declared view; will use inline view instead
SELECT e.*
FROM emp e

INNER JOIN

(SELECT ename,
	job,
	sal
FROM emp
WHERE job= "CLERK") v

ON e.ename = v.ename
AND e.job = v.job
AND e.sal = v.sal
;

/* 3.4 Retrieving values from one table that do not exist in another */

-- find departments without any employees
SELECT deptno
FROM dept
WHERE deptno NOT IN (
	SELECT DISTINCT deptno
	FROM emp)
;

-- now make solution robust to nulls being returned by subquery
SELECT d.deptno
FROM dept d
-- subquery returns empty set if no matching deptno in emp
WHERE NOT EXISTS (
	SELECT 1
	FROM emp e
	WHERE d.deptno = e.deptno)
;

/* 3.5 Retrieving rows from one table that do not exist in another */
/* Differs from problem 3.4 in that now need to return more than one column */

-- first build on previous problem's solution
SELECT d.*
FROM dept d
WHERE NOT EXISTS (
	SELECT 1
	FROM emp e
	WHERE d.deptno = e.deptno)
;

-- now mimic book's approach with outer join instead of subquery
SELECT d.*
FROM dept d
LEFT OUTER JOIN
emp e
ON d.deptno = e.deptno
WHERE e.deptno IS NULL
;

/* 3.6 Adding joins to a query without interfering with other joins */

/* nothing to practice; just demonstrates using outer joins
or scalar subquery in select clause as way of adding fields to result
without affecting rows returned */

/* 3.7 Determining whether two tables have the same date */

-- create view to check against emp table
DROP VIEW IF EXISTS V;

SHOW WARNINGS;

CREATE VIEW V
AS
SELECT * FROM emp WHERE deptno != 10
UNION ALL
SELECT * FROM emp WHERE ename = "WARD"
;


/* 
Book solution hinges on fact that the view has duplicate rows.
In this circumstance, it isn't enough to just check to see if each row
is also in the other table. For any duplicate rows in a table, if the first
instance was found in the other table then the subsequent (duplicate) row will
be found also. 

This constraint is overcome by creating an extra column that counts
how many times that row appears in a table. If it appears once in each
table, it's ignored. If it appears once in the first table but twice in the 
second table, the counts will be different and so the (otherwise unique) rows
will be different, and therefore the query will return each row.
*/

-- drop view from session
DROP VIEW IF EXISTS V;


