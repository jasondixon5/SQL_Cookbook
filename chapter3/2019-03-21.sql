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

SELECT e.ename,
	e.deptno AS emp_deptno,
	d.*
FROM dept d LEFT JOIN emp e
ON (d.deptno = e.deptno)
;
