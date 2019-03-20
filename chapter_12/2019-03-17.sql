
/* Practice 03-17-2019 */

/* 12.1 Pivot result set into one row */

SELECT SUM(CASE WHEN deptno = 10 THEN 1 ELSE 0 END) AS dept10_cnt,
	SUM(CASE WHEN deptno = 20 THEN 1 ELSE 0 END) AS dept20_cnt,
	SUM(CASE WHEN deptno = 30 THEN 1 ELSE 0 END) AS dept30_cnt
FROM emp
;

-- alternate solution
SELECT MAX(CASE WHEN deptno = 10 THEN emp_count ELSE NULL END) AS dept10_cnt,
	MAX(CASE WHEN deptno = 20 THEN emp_count ELSE NULL END) AS dept20_cnt,
	MAX(CASE WHEN deptno = 30 THEN emp_count ELSE NULL END) AS dept30_cnt
FROM
	
(SELECT deptno,
	COUNT(*) emp_count
FROM emp
GROUP BY deptno) x
;

/* 12.2 Pivot set into multiple rows */

SELECT 	(SELECT COUNT(*) FROM emp e2
		WHERE e2.job = emp.job
		AND e2.empno <= emp.empno) AS num_within_job,
	MAX(CASE WHEN job = "CLERK" THEN ename ELSE NULL END) AS clerks,
	MAX(CASE WHEN job = "ANALYST" THEN ename ELSE NULL END) AS analysts,
	MAX(CASE WHEN job = "MANAGER" THEN ename ELSE NULL END) AS mgrs,
	MAX(CASE WHEN job = "PRESIDENT" THEN ename ELSE NULL END) AS prez,
	MAX(CASE WHEN job = "SALESMAN" THEN ename ELSE NULL END) AS sales
FROM emp
GROUP BY 1
;

-- now use inline view to get rid of group # (num within job)
SELECT
	MAX(CASE WHEN job = "CLERK" THEN ename ELSE NULL END) AS clerks,
	MAX(CASE WHEN job = "ANALYST" THEN ename ELSE NULL END) AS analysts,
	MAX(CASE WHEN job = "MANAGER" THEN ename ELSE NULL END) AS mgrs,
	MAX(CASE WHEN job = "PRESIDENT" THEN ename ELSE NULL END) AS prez,
	MAX(CASE WHEN job = "SALESMAN" THEN ename ELSE NULL END) AS sales
FROM (
	SELECT job,
		ename,
		(SELECT COUNT(*) FROM emp e2
			WHERE e2.job = emp.job
			AND e2.empno <= emp.empno) 
		AS num_within_job
	FROM emp) x
GROUP BY num_within_job
;

/* 12.3 Reverse pivoting a result set */

SELECT dept.deptno, 
	CASE dept.deptno
		WHEN 10 THEN dept10_cnt
		WHEN 20 THEN dept20_cnt
		WHEN 30 THEN dept30_cnt
		ELSE 0 END AS emp_cnt
FROM 
	(SELECT SUM(CASE WHEN deptno = 10 THEN 1 ELSE 0 END) AS dept10_cnt,
		SUM(CASE WHEN deptno = 20 THEN 1 ELSE 0 END) AS dept20_cnt,
		SUM(CASE WHEN deptno = 30 THEN 1 ELSE 0 END) AS dept30_cnt
	FROM emp) x, dept
;

-- solution without depts above 30
SELECT dept.deptno, 
	CASE dept.deptno
		WHEN 10 THEN dept10_cnt
		WHEN 20 THEN dept20_cnt
		WHEN 30 THEN dept30_cnt
		ELSE 0 END AS emp_cnt
FROM 
	(SELECT SUM(CASE WHEN deptno = 10 THEN 1 ELSE 0 END) AS dept10_cnt,
		SUM(CASE WHEN deptno = 20 THEN 1 ELSE 0 END) AS dept20_cnt,
		SUM(CASE WHEN deptno = 30 THEN 1 ELSE 0 END) AS dept30_cnt
	FROM emp) x, dept
WHERE dept.deptno in (10, 20, 30)
;

/* 12.6 Pivoting result set to facilitate inter-row calcs */

SELECT dept10_sal,
	dept20_sal,
	dept30_sal,
	dept20_sal - dept10_sal AS diff_20_10,
	dept30_sal - dept10_sal AS diff_30_10,
	dept30_sal - dept20_sal AS diff_30_20
FROM

(SELECT SUM(CASE WHEN deptno=10 THEN sal ELSE NULL END) AS dept10_sal,
	SUM(CASE WHEN deptno=20 THEN sal ELSE NULL END) AS dept20_sal,
	SUM(CASE WHEN deptno=30 THEN sal ELSE NULL END) AS dept30_sal
FROM emp) x
;

/* 12.7 Creating buckets of data of a fixed size */

-- Assign row number
SELECT (SELECT COUNT(*) FROM emp e2
	WHERE e2.empno <= e.empno) row_num,
	e.empno,
	e.ename
FROM emp e
;

-- Divide row number by desired number of elements
-- for each bucket
SET @grp_size := 5;

SELECT row_num/@grp_size AS grp,
	row_num,
	empno,
	ename
FROM (
	SELECT (SELECT COUNT(*) FROM emp e2
		WHERE e2.empno <= e.empno) row_num,
		e.empno,
		e.ename
	FROM emp e
	) x
;

-- Take decimal grp size's ceiling to get integer grp numbers
SET @grp_size := 5;

SELECT CEILING(row_num/@grp_size) AS grp,
	row_num,
	empno,
	ename
FROM (
	SELECT (SELECT COUNT(*) FROM emp e2
		WHERE e2.empno <= e.empno) row_num,
		e.empno,
		e.ename
	FROM emp e
	) x
;

/* Not in book, but how would we group employees by a criterion?
   For example, buckets of salary */
SELECT sal FROM emp ORDER BY sal;
-- salaries range from 800 to 5000
-- group in buckets of 1000
-- where group 0 is < 1000, 1 is range [1000, 2000), etc.
SELECT empno, 
	sal,
	sal/1000 AS grp_interim,
	FLOOR(sal/1000) AS grp
FROM emp
ORDER BY 4
;

/* 12.8 Creating a predefined number of buckets */
/* diff from 12.7 problem in that know how many buckets but do
not care about how many items are in each bucket */

-- first assign row num
SELECT e.empno,
	e.ename,
	(SELECT COUNT(*) FROM emp e2
		WHERE e2.empno <= e.empno) AS row_num
FROM emp e
;

-- use row_num to calculate a bucket number
SET @bucket_count := 4;

SELECT empno,
	ename,
	mod(row_num, @bucket_count)+1 AS bucket_num

FROM (
	SELECT e.empno,
		e.ename,
		(SELECT COUNT(*) FROM emp e2
			WHERE e2.empno <= e.empno) AS row_num
	FROM emp e
	) x
ORDER BY 3
;

-- similar solution but use cross join instead of subquery
-- get cross product of all empnos greater than or equal to another
-- then count those rows

-- cross join
SELECT e.empno,
	e.ename,
	d.empno,
	d.ename
FROM emp e, emp d
WHERE e.empno >= d.empno
ORDER BY e.empno, e.ename;

-- count rows included in cross join
-- can accomplish by grouping on first instance 
-- of empl no and empl name
SELECT count(*) as grp,
	e.empno,
	e.ename
FROM emp e, emp d
WHERE e.empno >= d.empno
GROUP BY e.empno, e.ename
ORDER BY 1
;

-- now do mod calc on grp to get buckets
SELECT mod(count(*), 4) +1 as bucket_num,
	e.empno,
	e.ename
FROM emp e, emp d
WHERE e.empno >= d.empno
GROUP BY e.empno, e.ename
ORDER BY 1
;


/* 12.9 Creating horizontal histograms */
-- first get count of employees in each dept
SELECT deptno,
	COUNT(*) AS empl_cnt
FROM emp
GROUP BY deptno
;

-- then convert count to series of characters
SELECT deptno,
	LPAD('*', empl_cnt, '*') AS dept_empl_cnt

FROM (
	SELECT deptno,
		COUNT(*) AS empl_cnt
	FROM emp
	GROUP BY deptno
	) x
;

-- try different characters
SELECT deptno,
	LPAD('|', empl_cnt, '|') AS dept_empl_cnt

FROM (
	SELECT deptno,
		COUNT(*) AS empl_cnt
	FROM emp
	GROUP BY deptno
	) x
;

SELECT deptno,
	LPAD('=', empl_cnt, '=') AS dept_empl_cnt

FROM (
	SELECT deptno,
		COUNT(*) AS empl_cnt
	FROM emp
	GROUP BY deptno
	) x
;
