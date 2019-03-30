/* Chapter 7: Working with Numbers */

/* 7.9 Calculating a mode */

-- find mode of salaries in dept 20

SELECT sal,
	COUNT(sal) AS sal_freq
FROM emp
WHERE deptno in (20)
GROUP BY sal
;

/* Could select sal(s) with highest sal_freq */
/* This aligns closely with the "common sense" view of
what's going on, i.e., find count of salaries and then
pick the one(s) with the highest frequency.
But this is very convlulted SQL */

SELECT sal
FROM 

(SELECT sal, COUNT(sal) AS sal_freq
FROM emp
WHERE deptno in (20)
GROUP BY sal) x

WHERE sal_freq = (

SELECT 
	MAX(sal_freq)
FROM

(SELECT sal, COUNT(sal) AS sal_freq
FROM emp
WHERE deptno in (20)
GROUP BY sal) y )
;

/* Book solution */

/* This solution demonstrates that it is not always 
necessary to have the aggregate function in the select
clause. The grouped data is aggregated but that
aggregation is used for a filter instead of to display
the count. 

This solution also follows the common sense view
(pick the sal(s) with the highest count of salaries */

/* This solution also demonstrates the 'all' keyword,
which isn't frequently used by other recipes in this book. */

SELECT sal
FROM emp
WHERE deptno in (20)
GROUP BY sal
HAVING COUNT(*) >= all (SELECT COUNT(*)
			FROM emp
			WHERE deptno in (20)
			GROUP BY sal)
;

/* Add column to show what the comparison is looking at */

SELECT sal,
	COUNT(*) count_of_sals,
	COUNT(*) >= ALL (SELECT COUNT(*)
			FROM emp
			WHERE deptno in (20)
			GROUP BY sal) AS equal_to_or_exceeds_counts
FROM emp
WHERE deptno in (20)
GROUP BY sal
;

/* 7.10 Calculating a median */

/* Book solution */

SELECT AVG(sal)
FROM (
	SELECT e.sal
	FROM emp e,
	emp e2
	WHERE e.deptno = e2.deptno
	AND e.deptno in (20)
	GROUP BY e.sal
	HAVING SUM(CASE WHEN e.sal = e2.sal THEN 1 ELSE 0 END) >= ABS(SUM(SIGN(e.sal - e2.sal)))) x
;

/* Examine original source table and inline table */

SELECT sal, deptno FROM emp;

SELECT e.sal AS e_sal, e.deptno AS e_dept, e2.sal AS e2_sal, e2.deptno AS e2_dept
FROM emp e, emp e2
;


SELECT e.sal AS e_sal, e.deptno AS e_dept, e2.sal AS e2_sal, e2.deptno AS e2_dept
FROM emp e, emp e2
WHERE e.deptno = e2.deptno
AND e.deptno in (20)
;

SELECT e.sal AS e_sal, 
	e.deptno AS e_dept
FROM emp e, emp e2
WHERE e.deptno = e2.deptno
AND e.deptno in (20)
;

SELECT e.sal AS e_sal, 
	e.deptno AS e_dept,
	e2.sal AS e2_sal, 
	e2.deptno AS e2_dept,
	CASE WHEN e.sal = e2.sal THEN 1 ELSE 0 END AS e1_e2_sal_match
FROM emp e, emp e2
WHERE e.deptno = e2.deptno
AND e.deptno in (20)
;

-- Add columns for this portion: ABS(SUM(SIGN(e.sal - e2.sal)))) x
SELECT e.sal AS e_sal, 
	e.deptno AS e_dept,
	e2.sal AS e2_sal, 
	e2.deptno AS e2_dept,
	CASE WHEN e.sal = e2.sal THEN 1 ELSE 0 END AS e1_e2_sal_match,
	e.sal - e2.sal AS sal_diff
FROM emp e, emp e2
WHERE e.deptno = e2.deptno
AND e.deptno in (20)
;

SELECT e.sal AS e_sal, 
	e.deptno AS e_dept,
	e2.sal AS e2_sal, 
	e2.deptno AS e2_dept,
	CASE WHEN e.sal = e2.sal THEN 1 ELSE 0 END AS e1_e2_sal_match,
	e.sal - e2.sal AS sal_diff,
	SIGN(e.sal - e2.sal) AS sign_sal_diff
FROM emp e, emp e2
WHERE e.deptno = e2.deptno
AND e.deptno in (20)
ORDER BY e.sal
;

SELECT e.sal,
	SUM(CASE WHEN e.sal = e2.sal THEN 1 ELSE 0 END) AS sum_e1_e2_sal_match,
	SUM(SIGN(e.sal - e2.sal)) AS sum_sign_sal_diff
FROM emp e, emp e2
WHERE e.deptno = e2.deptno
AND e.deptno in (20)
GROUP BY e.sal
;

SELECT e.sal,
	SUM(CASE WHEN e.sal = e2.sal THEN 1 ELSE 0 END) AS sum_e1_e2_sal_match,
	SUM(SIGN(e.sal - e2.sal)) AS sum_sign_sal_diff,
	ABS(SUM(SIGN(e.sal - e2.sal))) AS abs_sum_sign_sal_diff
FROM emp e, emp e2
WHERE e.deptno = e2.deptno
AND e.deptno in (20)
GROUP BY e.sal
;

-- SUM(CASE WHEN e.sal = e2.sal THEN 1 ELSE 0 END) >= ABS(SUM(SIGN(e.sal - e2.sal)))) x
SELECT e.sal,
	SUM(CASE WHEN e.sal = e2.sal THEN 1 ELSE 0 END) AS sum_e1_e2_sal_match,
	SUM(SIGN(e.sal - e2.sal)) AS sum_sign_sal_diff,
	ABS(SUM(SIGN(e.sal - e2.sal))) AS abs_sum_sign_sal_diff,
        SUM(CASE WHEN e.sal = e2.sal THEN 1 ELSE 0 END) >= ABS(SUM(SIGN(e.sal - e2.sal))) AS sum_sal_match_grt_than_ab_sum_sign
FROM emp e, emp e2
WHERE e.deptno = e2.deptno
AND e.deptno in (20)
GROUP BY e.sal
;

/* Due to the cross join, the column that adds up how many times the salaries in 
e and e2 match should always return at least 1. It seems to be there mainly just
to give an easy way to do a comparison.

The interesting column is the one that takes the differences between each salary in e and e2, extracts the sign (with 0 for no diff, 1 for poz, -1 for neg), and then sums the signs. We are left the number of times the salary differed from another salary less 
the times when it was exactly above and below two salaries (i.e., those salaries
would have signs of 1 and -1 so they would cancel out). 

*/

/* Note: I understand the solution and have tested it in SQL and Excel to
make sure I understand how it's done. But it's not intuitive, and need to 
spend some more time studying it to understand it more intuitively. */



/* 7.11 Determining percentage of a total */

-- Determine what percentage of salaries are the salaries in dept 10
-- (i.e., % dept 10 salaries contribute to total

/*
SELECT SUM(sal)/(SELECT SUM(sal) FROM emp) AS prop_dept10_contributes
FROM emp
WHERE deptno in (10)
;

SELECT e.deptno,
	SUM(sal) sal_by_dept,
	SUM(sal) / (SELECT SUM(sal) FROM emp e2) prop_dept_contributes
FROM emp e
GROUP BY deptno
;
*/
/* Book solution, which is slightly different */
/*
SELECT (SUM(
		CASE WHEN deptno = 10 THEN sal END)/SUM(sal)
		) as pct
FROM emp
;
*/
/* 7.12 Aggregating nullable columns */

-- Determine avg commission for employees in dept 30
-- Because some empls have null for commission, count null as 0

/*
SELECT AVG(COALESCE(comm, 0)) as avg_comm
FROM emp
WHERE deptno in (30)
;
*/
/* 7.13 Computing averages without high and low values */

-- Compute avg salary of all employees excluding the highest and lowest salaries

/*
SELECT (SELECT AVG(sal) FROM emp) AS avg_sal_with_skew,
	AVG(sal) avg_sal_without_skew
FROM emp
WHERE sal NOT IN (
	(SELECT MIN(sal) FROM emp),
	(SELECT MAX(sal) FROM emp)
)
;
*/
