/* Chapter 3: Working with Multiple Tables */

/* 3.1 Stacking rows atop each other */

SELECT ename AS emps_and_depts,
	deptno
FROM emp
WHERE deptno in (10)

UNION ALL

SELECT "--------",
	"----"

UNION ALL

SELECT dname,
	deptno
FROM dept
;

/* 3.2 Combing related rows */

SELECT deptno, loc
FROM dept
ORDER BY loc
;

SELECT e.ename,
	d.loc,
	e.deptno
FROM emp e
INNER JOIN dept d
ON d.deptno = e.deptno
ORDER BY d.loc
;

SELECT e.ename,
	d.loc
FROM emp e
INNER JOIN dept d
ON d.deptno = e.deptno
WHERE e.deptno IN (10);

/* 3.3 Finding rows in common between two tables */

-- book creates a view for the problem; I'll create a subquery

SELECT ename,
	job,
	sal
FROM emp
WHERE job in ("CLERK")
;

-- problem is to get other columns from emp not included in "view" above
SELECT e.empno,
	e.ename,
	e.job,
	e.sal,
	e.deptno
FROM emp e
INNER JOIN (
	SELECT ename,
		job,
		sal
	FROM emp
	WHERE job in ("CLERK")) clerks
ON e.ename = clerks.ename
AND e.job = clerks.job
AND e.sal = clerks.sal
;

/* Considered solving problem with a "where col in ()" solution,
   but that would require building that clause for each of the 
   fields in the inline table "clerks", which does not seem efficient
*/

/* 3.4 Retrieving values from one table that do not exist in another */

-- find depts in table dept with no employees in them
-- (employees are listed in table emp with a deptno)

/* The below query resulted in error: 
ERROR 1054 (42S22): Unknown column 'd.deptno' in 'where clause'
*/

/*
SELECT d.deptno
FROM dept d
WHERE NOT EXISTS (
	SELECT 1
	FROM (
		SELECT ename
		FROM emp e
		WHERE e.deptno = d.deptno
	) x
)
;
*/

/* It doesn't appear then that a correlated subquery can
    reference a field outside of the enclosing parentheses */

/* Correction: */

SELECT d.deptno
FROM dept d
WHERE NOT EXISTS (
	SELECT 1
	FROM emp e
	WHERE e.deptno = d.deptno)
;

/* Note also that this particular data accomodates the following
solution. The solution is not flexible, however, because if 
there were a row with the value of deptno set as NULL, 
the query below would return an empty set. */

SELECT d.deptno
FROM dept d
WHERE deptno not in (SELECT e.deptno FROM emp e);

/* 3.5 Retrieving rows from one table that do not
correspond to rows from another */

-- like problem 3.4, except returning all columns from first table
-- rather than just one column

SELECT d.*
FROM dept d
WHERE NOT EXISTS (
	SELECT 1
	FROM emp e
	WHERE e.deptno = d.deptno)
;

/* above solution works but book solution uses an left outer join
with emp and then filters for nulls in the/a column(s) returned
from the second table. See below: */

SELECT d.*
FROM dept d
LEFT JOIN emp e
ON e.deptno = d.deptno
WHERE e.deptno IS NULL
;

/* 3.6 - Skip. Just demonstrates how outer joins
can be used to add data without interfering with other joins */

/* 3.7 Determining whether two tables have the same data */

-- determine if two tables share both cardinality and values

-- first test cardinality
-- note that book uses a view but I will use an inline temp table
SELECT * FROM emp WHERE deptno != 10
UNION ALL 
SELECT * FROM emp WHERE ename = "WARD"
;

-- first test cardinality with employee table emp
SELECT COUNT(*) AS view_row_count
FROM (
SELECT * FROM emp WHERE deptno != 10
UNION ALL 
SELECT * FROM emp WHERE ename = "WARD"
) v
UNION ALL

SELECT COUNT(*) AS emp_row_count
FROM emp
;

-- now compare data in each table

-- the tables can differ as follows
-- * rows in one table that are not in the other
-- * rows that have one instance in one table but > 1 in the other

-- solution involves counting instances of each row in each table in order
-- to handle second possibility

-- in emp but not in v

SELECT * FROM (
	SELECT empno,
	ename,
	job,
	mgr,
	hiredate,
	sal,
	comm,
	deptno,
	COUNT(*) AS cnt
	FROM emp
	GROUP BY empno, ename, job, mgr, 
		hiredate, sal, comm, deptno
) e

WHERE NOT EXISTS (
	SELECT 1
	FROM ( 
		SELECT *, 
			COUNT(*) AS cnt
		FROM (
			SELECT * FROM emp WHERE deptno != 10
			UNION ALL 
			SELECT * FROM emp WHERE ename = "WARD"
		) subview
		GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
	) v
	WHERE e.empno = v.empno
	AND e.ename = v.ename
	AND e.job = v.job
	AND COALESCE(e.mgr, 0) = COALESCE(v.mgr, 0)
	AND e.hiredate = v.hiredate
	AND e.sal = v.sal
	AND COALESCE(e.comm, 0) = COALESCE(v.comm, 0)
	AND e.deptno = v.deptno
	AND e.cnt = v.cnt
)	
;

-- in v but not in emp

SELECT * FROM (
		SELECT *, 
			COUNT(*) AS cnt
		FROM (
			SELECT * FROM emp WHERE deptno != 10
			UNION ALL 
			SELECT * FROM emp WHERE ename = "WARD"
		) subview
		GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
	) v

WHERE NOT EXISTS (
	SELECT 1
	FROM (
		SELECT * FROM (
			SELECT empno,
			ename,
			job,
			mgr,
			hiredate,
			sal,
			comm,
			deptno,
			COUNT(*) AS cnt
			FROM emp
			GROUP BY empno, ename, job, mgr, 
			hiredate, sal, comm, deptno
		) esub
	) e

	WHERE e.empno = v.empno
	AND e.ename = v.ename
	AND e.job = v.job
	AND COALESCE(e.mgr, 0) = COALESCE(v.mgr, 0)
	AND e.hiredate = v.hiredate
	AND e.sal = v.sal
	AND COALESCE(e.comm, 0) = COALESCE(v.comm, 0)
	AND e.deptno = v.deptno
	AND e.cnt = v.cnt
) 
;

/* then can UNION ALL the results to get one table (not shown here) */

/* 3.8 Identifying and avoiding cartesian products */

-- just a demonstration and discussion of n-1 join rule and that
-- result set will be product of count of the two tables

/* 3.9 Performing joins when using aggregates */

-- sum of salaries in dept 20 (note: book uses dept 10)
-- and sum of salaries of employees in dept 20
-- Circumstance is that there are two bonuses for one empl
-- so a straight join and SUM will overstate salaries

SELECT sals.deptno,
	sals.sum_salaries,
	SUM(e.sal * (COALESCE(eb.type, 0)/10)) AS bonus_total
FROM (

	SELECT e.deptno,
		SUM(e.sal) as sum_salaries
	FROM emp e
	WHERE e.deptno in (20)
	GROUP BY e.deptno
) sals

LEFT JOIN emp e
ON e.deptno = sals.deptno

LEFT JOIN emp_bonus eb
ON eb.empno = e.empno

GROUP BY sals.deptno,
	sals.sum_salaries
;

/* Result:

+--------+--------------+-----------+
| deptno | total_salary | bonus     |
+--------+--------------+-----------+
|     20 |        10875 | 1140.0000 |
+--------+--------------+-----------+

*/

/* Returning missing data from multiple tables */

-- return rows from dept that do not exist in emp and vice-versa
-- note that solution involves union because mysql lacks a full outer join

-- also note that book solution involves inserting a new employee whose deptno 
-- is null, which I haven't duplicated here. Solution is still the same

SELECT d.deptno,
	dname,
	ename
FROM emp e
LEFT JOIN dept d
ON d.deptno = e.deptno

UNION

SELECT d.deptno,
	dname,
	ename
FROM dept d
LEFT JOIN emp e
ON e.deptno = d.deptno
;

/* I chose to use two left joins, which means swapping tables in each 
unioned query. Another solution (used by the book for the MySQL solution
is to keep the table orders the same but use a left outer join and right
outer join respectively. */

SELECT d.deptno,
	dname,
	ename
FROM emp e
LEFT JOIN dept d
ON d.deptno = e.deptno

UNION

SELECT d.deptno,
	dname,
	ename
FROM emp e
RIGHT JOIN dept d
ON e.deptno = d.deptno
;

/* Using nulls in operations and comparisons */

-- find employees whose commission is less than the comission of employee 'WARD'
-- Employees with no (i.e., a NULL) comission should be included as well

SELECT comm FROM emp WHERE ename = "WARD";

SELECT empno, ename, comm FROM emp ORDER BY comm;

SELECT empno,
	ename,
	comm
FROM emp
WHERE COALESCE(comm, 0) < (
				SELECT comm
				FROM emp
			       WHERE ename = "WARD")
;	
