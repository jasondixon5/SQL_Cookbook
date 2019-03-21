/* Chapter 3: Working with Multiple Tables */

/* 3.1 Stacking one rowset atop another */

-- show name and deptno of employees in dept 10
-- and name and dept no of each dept in table dept
SELECT ename AS ename_and_dname,
	deptno
FROM emp
WHERE deptno = 10

UNION ALL

SELECT "----------", NULL

UNION ALL

SELECT dname,
	deptno
FROM dept
;

-- try to make dashes dependent on largest dept
-- or longest employee name (whichever is longer)

-- set length of longest dept name
SET @max_dept_name_length := (
	SELECT MAX(LENGTH(dname))
	FROM dept);

-- set length of longest employee name
SET @max_empl_name_length := (
	SELECT MAX(LENGTH(ename))
	FROM emp
	WHERE deptno = 10);

-- set length of separator as longer of max dept name or max empl name 
SET @separator_length := (
	SELECT MAX(max_length)
	FROM (
		SELECT @max_dept_name_length AS max_length
		UNION
		SELECT @max_empl_name_length) x
	);

SELECT ename AS ename_and_dname,
	deptno
FROM emp
WHERE deptno = 10

UNION ALL

SELECT LPAD("-", @separator_length, "-"), NULL

UNION ALL

SELECT dname,
	deptno
FROM dept
;

/* 3.2 Combining related rows */

-- display names of employees in dept 10 along with dept loc
-- note that book uses an inner join, but that would not show employees
-- who were not assigned a dept

SELECT e.ename,
	d.loc
FROM emp e
LEFT OUTER JOIN dept d
ON e.deptno = d.deptno
WHERE e.deptno in (10)
;

/* 3.3 Finding rows in common between two tables */

/* Note that for this problem must create a temporary view */
/* Will create it inlign */

SELECT e.empno,
	e.ename,
	e.job,
	e.sal,
	e.deptno
FROM emp e
INNER JOIN (
	SELECT ename, job, sal 
	FROM emp 
	WHERE job="CLERK") V
ON v.ename = e.ename 
AND v.job = e.job
AND v.sal = e.sal
;

/* 3.4 Retrieving values from one table that do not exist in another */

SELECT deptno
FROM dept
WHERE deptno not in (
	SELECT deptno FROM emp)
;

/* note that above solution only works as long as emp.deptno cannot return NULLS */
/* the following query returns an empty set (note the null in the list of deptnos */

SELECT deptno
FROM dept
WHERE deptno not in (
	SELECT deptno FROM emp
	UNION ALL
	SELECT null)
;

/* to get around the problem with nulls, use EXISTS/NOT EXISTS */

/* examine results of query to mimic the subquery that 
 NOT EXISTS will be used to check against */
SELECT 1, deptno FROM emp WHERE deptno = 10;
SELECT 1, deptno FROM emp WHERE deptno = 20;
SELECT 1, deptno FROM emp WHERE deptno = 30;
-- the following query results in an empty set
SELECT 1, deptno FROM emp WHERE deptno = 40;

/* 
  the NOT EXISTS will evaluate to False for each dept
  except dept 40, which will evaluate to True and trigger
  the condition
*/

SELECT d.deptno
FROM dept d
WHERE NOT EXISTS (
	SELECT NULL
	FROM emp e
	WHERE d.deptno = e.deptno)
;

/* Note that the subquery in the above query returning NULL will
not trigger the condition. Only an empty set will trigger it. */

/* 3.5 Retrieving rows from one table that do not 
   correspond to rows in another */

/* Write like previous problem's solution to show it works
even though book says it's a subtly different problem */

SELECT d.*
FROM dept d
WHERE NOT EXISTS (
	SELECT NULL
	FROM emp e
	WHERE d.deptno = e.deptno)
;

/* now write with book solution using outer join and filter for nulls */
-- first show all rows returned (matched and not matched between the tables 
SELECT d.deptno,
	d.dname,
	d.loc,
	e.deptno
FROM dept d
LEFT OUTER JOIN emp e
ON d.deptno = e.deptno
;

SELECT d.deptno,
	d.dname,
	d.loc
FROM dept d
LEFT OUTER JOIN emp e
ON d.deptno = e.deptno
WHERE e.deptno IS NULL
;
