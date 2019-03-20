/* 12.10 Create vertical histogram */
-- get employee count per dept
SELECT deptno,
	COUNT(*) empl_cnt
FROM emp
GROUP BY deptno
;

-- get empl name in columns for each dept
SELECT CASE deptno WHEN 10 THEN ename ELSE NULL END AS D10,
	CASE deptno WHEN 20 THEN ename ELSE NULL END AS D20,
	CASE deptno WHEN 30 THEN ename ELSE NULL END AS D30
FROM emp
;

-- replace empl name with '*'
SELECT CASE deptno WHEN 10 THEN '*' ELSE NULL END AS D10,
	CASE deptno WHEN 20 THEN '*' ELSE NULL END AS D20,
	CASE deptno WHEN 30 THEN '*' ELSE NULL END AS D30
FROM emp
;

-- add empl no for each empl within each dept
-- for grouping & aggregate expr to remove nulls
SELECT (SELECT COUNT(*) FROM emp e2 WHERE e.empno <= e2.empno
	AND e2.deptno=e.deptno) AS grp,
	CASE deptno WHEN 10 THEN '*' ELSE NULL END AS D10,
	CASE deptno WHEN 20 THEN '*' ELSE NULL END AS D20,
	CASE deptno WHEN 30 THEN '*' ELSE NULL END AS D30
FROM emp e
;

-- add aggr and grouping to get rid of nulls
-- convert original query to inline for simpler selecting
SELECT max(D10) AS D10,
	max(D20) AS D20,
	max(D30) AS D30
FROM 
(SELECT (SELECT COUNT(*) FROM emp e2 WHERE e.empno <= e2.empno
	AND e2.deptno=e.deptno) AS grp,
	CASE deptno WHEN 10 THEN '*' ELSE NULL END AS D10,
	CASE deptno WHEN 20 THEN '*' ELSE NULL END AS D20,
	CASE deptno WHEN 30 THEN '*' ELSE NULL END AS D30
FROM emp e) x
GROUP BY grp
ORDER BY 1, 2, 3 
;

/* 12.11 Returning non-group by columns */

/* Return name, dept, title, sal and indicator if empl has highest or
lowest sal in dept and highest or lowest sal in job */

-- create queries to get both sets of data

-- empl columns
SELECT deptno,
	ename,
	job,
	sal
FROM emp
;

-- highest and lowest salaries in each dept
SELECT deptno,
	MAX(sal) AS dept_max,
	MIN(sal) AS dept_min
FROM emp
GROUP BY deptno
;

SELECT job,
	MAX(sal) AS job_max,
	MIN(sal) AS job_min
FROM emp
GROUP BY job
;


-- Partial solution attempt
SELECT deptno,
	ename,
	job,
	sal,
	CASE sal
		WHEN (SELECT MAX(sal) FROM emp e2 WHERE e2.deptno=e.deptno
			GROUP BY deptno)
		THEN 'TOP SAL IN DEPT'
		WHEN (SELECT MIN(sal) FROM emp e2 WHERE e2.deptno=e.deptno
			GROUP BY deptno)
		THEN 'LOW SAL IN DEPT'
	END AS dept_status
FROM emp e
;

-- above solution begins to get there
-- but book solution slightly simpler in case statement by using inline view
-- to get max/min sals
-- Inline view will also simplify filtering out salaries that aren't in one of
-- the four groups (max dept, min dept, max job, min job)
-- Also realized from book solutiont that don't need group by statement
--  when getting max and min salaries 

-- set up inline table
SELECT deptno,
	ename,
	job,
	sal,
	(SELECT MAX(sal) FROM emp e2 WHERE e2.deptno = e.deptno) AS dept_max,
	(SELECT MIN(sal) FROM emp e2 WHERE e2.deptno = e.deptno) AS dept_min,
	(SELECT MAX(sal) FROM emp e2 WHERE e2.job = e.job) AS job_max,
	(SELECT MIN(sal) FROM emp e2 WHERE e2.job = e.job) AS job_min
FROM emp e
; 

-- add outer query
SELECT deptno,
	ename,
	job,
	sal,
	CASE sal WHEN dept_max THEN 'TOP SAL IN DEPT'
		WHEN dept_min THEN 'LOW SAL IN DEPT'
	END AS dept_status,
	CASE sal WHEN job_max THEN 'TOP SAL IN JOB'
		WHEN job_min THEN 'LOW SAL IN JOB'
	END AS job_status

FROM

(SELECT deptno,
	ename,
	job,
	sal,
	(SELECT MAX(sal) FROM emp e2 WHERE e2.deptno = e.deptno) AS dept_max,
	(SELECT MIN(sal) FROM emp e2 WHERE e2.deptno = e.deptno) AS dept_min,
	(SELECT MAX(sal) FROM emp e2 WHERE e2.job = e.job) AS job_max,
	(SELECT MIN(sal) FROM emp e2 WHERE e2.job = e.job) AS job_min
FROM emp e) x
WHERE sal in (dept_max, dept_min, job_max, job_min)
ORDER BY deptno
;

/* 12.12 Calculating simple subtotals */

-- Generate totals by jobs with a grand total for result set
SELECT job,
	SUM(sal)
FROM emp
GROUP BY job WITH ROLLUP
;

-- add coalesce to make description for total not be just NULL
SELECT COALESCE(job, 'TOTAL') AS job,
	SUM(sal)
FROM emp
GROUP BY job WITH ROLLUP
;

/* 12.13 Calculating subtotals for all combinations */

-- first see what the rollup keyword provides
SELECT deptno,
	job,
	SUM(sal)
FROM emp
GROUP BY deptno, job WITH ROLLUP
;

-- totals were provided for each dept, and an addl total was given for all employees
-- however, totals for each job (irrespective of dept) are missing
-- SQL Server will give this addl combo along with the others via the WITH CUBE keyphrase
-- But in MySQL, this has to be accomplished via UNION ALL

SELECT deptno,
	job,
	"TOTAL BY DEPT AND JOB" AS category,
	SUM(sal) as sal
FROM emp
GROUP BY deptno, job

UNION ALL

SELECT NULL AS deptno,
	job,
	"TOTAL BY JOB" AS category,
	SUM(sal) as sal
FROM emp
GROUP BY job

UNION ALL

SELECT deptno,
	NULL AS job,
	'TOTAL BY DEPT' AS category,
	SUM(sal) as sal
FROM emp
GROUP BY deptno

UNION ALL

SELECT NULL AS deptno,
	NULL AS job,
	'GRAND TOTAL' AS category,
	SUM(sal) AS sal
FROM emp
;

/* Not part of chapter...
Try classic 'show employee and the employee's manager' problem */

-- first show relevant columns
SELECT empno, ename, mgr FROM emp
;

-- do self join to retrieve mgr name
SELECT e.empno,
	e.ename,
	e.mgr,
	e2.ename
FROM emp e
LEFT JOIN emp e2
ON e.mgr = e2.empno
;

-- clean up column names, null representation
SELECT e.empno,
	e.ename,
	COALESCE(e.mgr, "NO MGR") AS mgr_empno,
	COALESCE(e2.ename, "NO MGR") AS mgr_ename
FROM emp e
LEFT JOIN emp e2
ON e.mgr = e2.empno
;
