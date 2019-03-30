/* Chapter 7: Working with Numbers */

/* 7.1 Computing an average */

-- find avg salary for all employees and avg salary for each dept

SELECT AVG(sal) avg_sal_all_empls
FROM emp
;

SELECT deptno,
	AVG(sal) avg_sal_by_dept
FROM emp
GROUP BY deptno
;

SELECT AVG(avg_sal_by_dept) AS avg_all_dept_avg_sals
FROM (SELECT deptno,
	AVG(sal) avg_sal_by_dept
	FROM emp
	GROUP BY deptno) x
;

/* Side exploration on how nulls are handled */

-- get avg of commission with and without coalescing nulls to 0
-- avg function by default will ignore nulls

SELECT AVG(comm) avg_comm_ignoring_nulls
FROM emp
;

SELECT AVG(COALESCE(comm, 0)) avg_comm_coalescing_nulls_to_0
FROM emp
;

/* As expected, adding in 0's for null values brought average down */

/* Finding min/max values in a column */

-- Find min and max sal
SELECT MIN(sal),
	MAX(sal),
	AVG(sal)
FROM emp;

SELECT deptno,
	MIN(sal),
	MAX(sal),
	AVG(sal)
FROM emp
GROUP BY deptno 
;

-- Find min and max comm
-- This col demonstrates that NULLS are ignored and also that
-- you can have a null group 
SELECT MIN(comm),
	MAX(comm),
	AVG(comm)
FROM emp;

SELECT deptno,
	MIN(comm),
	MAX(comm),
	AVG(comm)
FROM emp
GROUP BY deptno
;

/* 7.5 Generating a running total */

SELECT e.ename,
	e.sal,
	(SELECT SUM(e2.sal)
	FROM emp e2
	WHERE e2.empno <= e.empno) AS running_total_sal
FROM emp e
;

/* 7.6 Generating a running product */

/* This technique involves following steps to calculate a running product:
1. Calculate ln of each number
2. Calculate running sum of lns
3. Raise e to power of ln sum calculated above (using exp() func)
*/

SELECT sal,
	LN(sal) AS ln_sal,
	'placeholder for running sum of lsn',
	'placeholder for exp(ln(sum))'
FROM emp
;

SELECT sal,
	LN(sal) AS ln_sal,
	(SELECT SUM(LN(sal))
	FROM emp e2
	WHERE e2.empno <= e.empno) AS sum_ln_of_sals,
	-- 'placeholder for running sum of lsn',
	'placeholder for exp(ln(sum))'
FROM emp e
;

SELECT sal,
	LN(sal) AS ln_sal,
	(SELECT SUM(LN(sal))
	FROM emp e2
	WHERE e2.empno <= e.empno) AS sum_ln_of_sals,
	-- 'placeholder for running sum of lsn',
	(SELECT EXP(SUM(LN(sal)))
	FROM emp e2
	WHERE e2.empno <= e.empno) AS exp_of_sum_ln_of_sals
	-- 'placeholder for exp(ln(sum))'
FROM emp e
;

-- book solution calculates values for dept 10 emps only
-- give that sol

SELECT empno,
	deptno,
	sal,
	(SELECT EXP(SUM(LN(sal))) 
	FROM emp e2
	WHERE e2.empno <= e.empno
	AND e2.deptno = e.deptno) AS running_prod
FROM emp e
WHERE deptno=10
;

/* 7.8 Calculating a running difference */

-- calculate running diff of employees in dept 10
SELECT e.ename,
	e.sal,
	(SELECT CASE WHEN e.empno = min(e2.empno)
			THEN SUM(e2.sal)
		ELSE SUM(-e2.sal)
		END
	FROM emp e2
	WHERE e2.empno <= e.empno
	AND e2.deptno = e.deptno) AS running_diff
FROM emp e
WHERE e.deptno in (10)
;

select e.empno,
	e.ename,
	e.sal
FROM emp e
WHERE e.deptno in (10);

/*
Approach tested in Excel and consists of following
If first employee, return that
If not first employee:
 * get first employee's salary; store as-is
 * to first employee's salary, add each (sal * -1) to it for
   each employee want to count up to that point
   (i.e., each employee's whose emplno is greater than first employee's empno
   but less than or equal to empl currently evaluating

e.g., if looking at employees in dept 10:
+-------+--------+------+
| empno | ename  | sal  |
+-------+--------+------+
|  7782 | CLARK  | 2450 |
|  7839 | KING   | 5000 |
|  7934 | MILLER | 1300 |
+-------+--------+------+

if empno = 1st empl, return sal
for employee 7839
	add 1st empl + (sal *-1) of employees > 7782 but <= 7839 (current employee),

*/

SELECT e.ename,
	e.sal,
	(SELECT CASE WHEN e.empno = min(e2.empno)
		THEN e.sal
	ELSE (SELECT sal FROM emp e3 WHERE e3.empno = min(e2.empno)) - (SELECT SUM(-1*e4.sal) FROM emp e4 WHERE e4.empno > min(e2.empno) AND e4.empno <= e.empno) 
	END
	FROM emp e2
	WHERE e2.deptno = e.deptno) AS tentative_diff
FROM emp e
WHERE e.deptno IN (10)
;

/** need to revisit this problem. Most recent solution I put didn't work as expected */


