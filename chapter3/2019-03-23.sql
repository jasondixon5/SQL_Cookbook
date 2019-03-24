/* Chapter 3 */

/* 3.9 Performing Joins When Using Aggregates */

/* Join between emp table to get salary and emp_bonus table to get bonus
But avoid duplicate counting of salaries for employees who have more than 
one bonus */

-- note: book uses employee 10 but my bonus table only has employees from 20 and 30

SELECT deptno,
	empno,
	sal
FROM emp
WHERE deptno in (20)
ORDER BY deptno, empno;

SELECT * 
FROM emp_bonus
ORDER BY empno, type;

-- get all salaries and bonuses
-- without worrying about duplicates yet
SELECT e.empno,
	e.sal,
	sal*(COALESCE(eb.type/10, 0)) as bonus
FROM emp e
LEFT JOIN emp_bonus eb
ON e.empno = eb.empno
WHERE e.deptno in (20)
;

-- side exploration
-- see if deptno can be moved
-- to ON condition
SELECT e.deptno,
	e.empno,
	e.ename,
	e.sal,
	sal*(COALESCE(eb.type/10, 0)) as bonus
FROM emp e
LEFT JOIN emp_bonus eb
ON e.empno = eb.empno AND e.deptno in (20)
-- WHERE e.deptno in (20)

-- ***Answer: No. Moving deptno to ON condition caused all depts to appear
;


-- use book solution to get rid of entries with duplicate salaries
-- must be done in aggregation; can't be done in select of main query
SELECT deptno,
	SUM(distinct sal) AS salary_total,
	SUM(bonus) AS bonus_total
FROM (
	SELECT e.deptno,
		e.empno,
		e.ename,
		e.sal,
		sal*(COALESCE(eb.type/10, 0)) as bonus
	FROM emp e
	LEFT JOIN emp_bonus eb
	ON e.empno = eb.empno
	WHERE e.deptno in (20)
	) x
GROUP BY deptno
;

-- independently calculate salary total and test if makes sense
SELECT SUM(sal) AS salary_total
FROM emp
WHERE deptno in (20)
;

/* NOTE: Primary book solution fails; salary_total is not accurate.
This is because two of the employees have the same salary. So it
isn't just the duplicate employee entry that's removed but an
instance of a legitimate salary. */

/* Calculate salary and bonus totals separately and then join them into one table */

SELECT deptno,
	SUM(sal) AS salary_total
FROM emp
WHERE deptno in (20)
GROUP BY deptno
;

SELECT deptno, 
	SUM(bonus) AS bonus_total
FROM (
	SELECT e.deptno,
		e.sal * (COALESCE(eb.type/10, 0)) AS bonus
	FROM emp e
	LEFT JOIN emp_bonus eb
	ON e.empno = eb.empno
	WHERE e.deptno in (20)
) x
GROUP BY deptno
;

-- combine tables with join

SELECT sal_total.deptno,
	sal_total.salary_total,
	bon_total.bonus_total
FROM

(SELECT deptno,
	SUM(sal) AS salary_total
FROM emp
WHERE deptno in (20)
GROUP BY deptno
) sal_total

INNER JOIN

(SELECT deptno, 
	SUM(bonus) AS bonus_total
FROM (
	SELECT e.deptno,
		e.sal * (COALESCE(eb.type/10, 0)) AS bonus
	FROM emp e
	LEFT JOIN emp_bonus eb
	ON e.empno = eb.empno
	WHERE e.deptno in (20)
) x
GROUP BY deptno
) bon_total

ON sal_total.deptno = bon_total.deptno
;

-- now implement book's alternate solution to 
-- avoid duplicate salary issue
-- Tweaks from book sol include calculating bonus % based on type
-- rather than hard coding it and INNER JOIN syntax rather than
-- table, table + WHERE condition

SELECT d.deptno,
	d.total_sal,
	SUM(e.sal*COALESCE(eb.type/10, 0)) AS total_bonus
FROM emp e

INNER JOIN emp_bonus eb
ON e.empno = eb.empno

INNER JOIN (
	SELECT deptno,
		SUM(sal) AS total_sal
	FROM emp
	WHERE deptno in (20)
	GROUP BY deptno
) d
ON e.deptno = d.deptno

GROUP BY d.deptno, d.total_sal
;

/* in originally implementing above solution,
did LEFT JOIN instead of INNER JOIN, and
result showed two rows; not clear why two rows
but then inner join worked

+--------+-----------+-------------+
| deptno | total_sal | total_bonus |
+--------+-----------+-------------+
|   NULL |      NULL |    190.0000 |
|     20 |     10875 |   1140.0000 |
+--------+-----------+-------------+

*/

SELECT d.deptno,
	d.total_sal,
	SUM(e.sal*COALESCE(eb.type/10, 0)) AS total_bonus
FROM emp e

LEFT JOIN emp_bonus eb
ON e.empno = eb.empno

LEFT JOIN (
	SELECT deptno,
		SUM(sal) AS total_sal
	FROM emp
	WHERE deptno in (20)
	GROUP BY deptno
) d
ON e.deptno = d.deptno

GROUP BY d.deptno, d.total_sal
;

-- show first join
SELECT -- d.deptno,
	-- d.total_sal,
	SUM(e.sal*COALESCE(eb.type/10, 0)) AS total_bonus
FROM emp e

LEFT JOIN emp_bonus eb
ON e.empno = eb.empno
;

-- add context
SELECT -- d.deptno,
	-- d.total_sal,
	e.empno, e.ename, e.job, e.mgr, e.hiredate, e.deptno, eb.received, eb.type,
	SUM(e.sal*COALESCE(eb.type/10, 0)) AS total_bonus
FROM emp e

LEFT JOIN emp_bonus eb
ON e.empno = eb.empno
GROUP BY empno, ename, job, mgr, hiredate, deptno, received, type
;

/* NOTE: Explanation of above behavior seems to be that the table
from which the deptno is coming, named d, is filtered for only employees
in dept 20. So only dept 20 can be supplied as a column value. Because
other employees had bonuses (empl 7900 in dept 30 whose bonus was $190),
a left join will show non-dept 20 employees but not have the deptno value
to show (because the select clause pulls the dept from inline table d).

The same behavior applies to total_sal column in result set. That column
comes from inline table d, so salaries from other employees will not be
summed. 
*/

/* Book's solution in full, with exception of filtering for dept 20 instead of 10 */

SELECT d.deptno,
	d.total_sal,
	sum(e.sal*CASE WHEN eb.type=1 THEN .1
		WHEN eb.type=2 THEN .2
		ELSE .3 END) AS total_bonus
FROM emp e,
	emp_bonus eb,
	(
	SELECT deptno,
		SUM(sal) as total_sal
	FROM emp
	WHERE deptno=20
	GROUP BY deptno
	) d
WHERE e.deptno = d.deptno
AND e.empno = eb.empno
GROUP BY d.deptno, d.total_sal
;

/* explore what is going on in book solution query */

-- join emp to inline table created via subquery (alias "d")
SELECT e.deptno AS emp_deptno,
	d.deptno AS subquery_deptno,
	d.total_sal
FROM emp e,
	(
		SELECT deptno,
			SUM(sal) as total_sal
		FROM emp
		WHERE deptno=20
		GROUP BY deptno
	) d
WHERE e.deptno = d.deptno
;

SELECT e.empno, e.deptno FROM emp e WHERE e.deptno = 20;

-- join emp to emp_bonus
SELECT e.empno AS emp_empno,
	e.sal,
	e.deptno,
	eb.empno AS empbonus_empno,
	eb.type AS type,
	e.sal*COALESCE(eb.type/10, 0) AS bonus
FROM emp e, emp_bonus eb
WHERE e.empno = eb.empno
;

SELECT eb.* FROM emp_bonus eb;

SELECT * 
FROM emp e,
	emp_bonus eb,
	(
		SELECT deptno,
			SUM(sal) as total_sal
		FROM emp
		WHERE deptno = 20
		GROUP BY deptno
	) d
WHERE e.deptno = d.deptno
AND e.empno = eb.empno
;

SELECT *,
	e.sal*COALESCE(eb.type/10, 0) AS bonus
FROM emp e,
	emp_bonus eb,
	(
		SELECT deptno,
			SUM(sal) as total_sal
		FROM emp
		WHERE deptno = 20
		GROUP BY deptno
	) d
WHERE e.deptno = d.deptno
AND e.empno = eb.empno
;

/*
+-------+-------+---------+------+------------+------+------+--------+-------+------------+------+--------+-----------+----------+
| EMPNO | ENAME | JOB     | MGR  | HIREDATE   | SAL  | COMM | DEPTNO | EMPNO | RECEIVED   | TYPE | deptno | total_sal | bonus    |
+-------+-------+---------+------+------------+------+------+--------+-------+------------+------+--------+-----------+----------+
|  7369 | SMITH | CLERK   | 7902 | 1980-12-17 |  800 | NULL |     20 |  7369 | 2005-03-14 |    1 |     20 |     10875 |  80.0000 |
|  7788 | SCOTT | ANALYST | 7566 | 1982-12-09 | 3000 | NULL |     20 |  7788 | 2005-03-14 |    3 |     20 |     10875 | 900.0000 |
|  7369 | SMITH | CLERK   | 7902 | 1980-12-17 |  800 | NULL |     20 |  7369 | 2005-03-31 |    2 |     20 |     10875 | 160.0000 |
+-------+-------+---------+------+------------+------+------+--------+-------+------------+------+--------+-----------+----------+
3 rows in set (0.00 sec)
*/

/* Note the two rows in the result set for employee 7369 (SMITH). */
/* With this set you couldn't sum both sal and bonus; bonus would be correct but sal column wouldn't, because employees in dept 10 without a bonus aren't shown (so their values for the sal column won't be included. So that's why you need the total_sal column
which has already summed the dept's sal values in the subquery aliased as "d".
So only option is to SELECT/group by total_sal (and deptno if want dept to show) and then sum the bonus column. */

SELECT d.deptno,
	d.total_sal,
	SUM(e.sal*COALESCE(eb.type/10, 0)) AS total_bonus
FROM emp e,
	emp_bonus eb,
	(
		SELECT deptno,
			SUM(sal) as total_sal
		FROM emp
		WHERE deptno = 20
		GROUP BY deptno
	) d
WHERE e.deptno = d.deptno
AND e.empno = eb.empno
GROUP BY d.deptno, d.total_sal
;

/* fresh attempt from cold start */

SELECT * FROM emp WHERE deptno in (20);

SELECT * FROM emp_bonus WHERE empno in (
	SELECT empno FROM emp WHERE deptno in (20));

SELECT deptno,
	SUM(sal) AS total_salary
FROM emp
WHERE deptno in (20)
GROUP BY deptno;

SELECT dept_total.deptno,
	dept_total.total_salary,
	SUM(e.sal * COALESCE((eb.type/10), 0)) AS bonus
	
FROM (
	SELECT deptno,
		SUM(sal) AS total_salary
	FROM emp
	WHERE deptno in (20)
	GROUP BY deptno) dept_total

INNER JOIN emp e
ON e.deptno = dept_total.deptno

INNER JOIN emp_bonus eb
ON eb.empno = e.empno

GROUP BY dept_total.deptno, dept_total.total_salary
;
