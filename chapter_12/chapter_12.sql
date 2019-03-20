/* 12.1 Pivot result set (multiple rows) into one row */

-- get set to pivot
SELECT deptno, count(*) AS cnt
FROM emp
GROUP BY deptno
;
/*
-- pivot into one row
-- look at how data is grouped
SELECT * FROM emp
ORDER BY deptno;
*/

/*
-- get intermediate table showing what will be included
-- in each new column
SELECT deptno,
	CASE deptno WHEN 10 THEN 1 ELSE 0 END AS dept_10,
	CASE deptno WHEN 20 THEN 1 ELSE 0 END AS dept_20,
	CASE deptno WHEN 30 THEN 1 ELSE 0 END AS dept_30
FROM emp
ORDER BY deptno
;
*/

-- now combine counts into a sum
SELECT deptno,
	SUM(CASE deptno WHEN 10 THEN 1 ELSE 0 END) AS dept_10,
	SUM(CASE deptno WHEN 20 THEN 1 ELSE 0 END) AS dept_20,
	SUM(CASE deptno WHEN 30 THEN 1 ELSE 0 END) AS dept_30
FROM emp
GROUP BY deptno
;

/* 12.2 - Pivot result set into multiple rows (and columns) */

-- examine original data set to pivot
SELECT job, ename
FROM emp
ORDER BY job
;

-- create intermediate table with bool column for each job
SELECT job,
	ename,
	CASE WHEN job="ANALYST" THEN 1 ELSE NULL END AS analysts,
	CASE WHEN job="CLERK" THEN 1 ELSE NULL END AS clerks,
CASE WHEN job="MANAGER" THEN 1 ELSE NULL END AS mgrs,
CASE WHEN job="PRESIDENT" THEN 1 ELSE NULL END AS prez,
CASE WHEN job="SALESMAN" THEN 1 ELSE NULL END AS sales
FROM emp
ORDER BY job
;

-- add empl name to each column in intermediate table 
SELECT job,
	ename,
	CASE WHEN job="ANALYST" THEN ename ELSE NULL END AS analysts,
	CASE WHEN job="CLERK" THEN ename ELSE NULL END AS clerks,
CASE WHEN job="MANAGER" THEN ename ELSE NULL END AS mgrs,
CASE WHEN job="PRESIDENT" THEN ename ELSE NULL END AS prez,
CASE WHEN job="SALESMAN" THEN ename ELSE NULL END AS sales
FROM emp
ORDER BY job
;

-- remove extra columns
SELECT CASE WHEN job="ANALYST" THEN ename ELSE NULL END AS analysts,
	CASE WHEN job="CLERK" THEN ename ELSE NULL END AS clerks,
	CASE WHEN job="MANAGER" THEN ename ELSE NULL END AS mgrs,
	CASE WHEN job="PRESIDENT" THEN ename ELSE NULL END AS prez,
	CASE WHEN job="SALESMAN" THEN ename ELSE NULL END AS sales
FROM emp
ORDER BY job
;

-- add col to make each name/job combo unique
-- then group by that new column and apply aggregate func to remove nulls
SELECT max(CASE WHEN job="ANALYST" THEN ename ELSE NULL END) AS analysts,
	max(CASE WHEN job="CLERK" THEN ename ELSE NULL END) AS clerks,
	max(CASE WHEN job="MANAGER" THEN ename ELSE NULL END) AS mgrs,
	max(CASE WHEN job="PRESIDENT" THEN ename ELSE NULL END) AS prez,
	max(CASE WHEN job="SALESMAN" THEN ename ELSE NULL END) AS sales
FROM (SELECT e.job,
       		e.ename,
		(SELECT count(*) FROM emp d
		WHERE e.job=d.job AND d.empno > e.empno) AS rnk
      FROM emp e) x
GROUP BY rnk
;

/* 12.8 */
/* book interim table solution*/
SELECT COUNT(*) as grp,
	e.empno,
	e.ename
FROM emp e, emp d
WHERE e.empno >= d.empno
GROUP BY e.empno, e.ename
ORDER BY 1
;

/* attempt at another way to get same ranking/row no */

/* examine raw data first */
SELECT e.empno,
	e.ename,
	d.empno,
	d.ename
FROM emp e, emp d
WHERE e.empno >= d.empno
;

SELECT e.empno, 
	e.ename,
	d.empno,
	d.ename
FROM emp e, emp d
WHERE e.empno >= d.empno
ORDER BY 2, 1
;

/* another way to get row number */
SELECT rnk,
	ename,
	empno
FROM	(SELECT e.ename,
		e.empno,
		(SELECT COUNT(*) 
		FROM emp d 
		WHERE d.empno <= e.empno) AS rnk
	FROM emp e) x
	ORDER BY rnk
;

/* now use book solution for dividing results into groups */
SELECT mod(rnk, 4)+1 AS grp,
	ename,
	empno
FROM	(SELECT e.ename,
		e.empno,
		(SELECT COUNT(*) 
		FROM emp d 
		WHERE d.empno <= e.empno) AS rnk
	FROM emp e) x
	ORDER BY 1
;

/* confirm intuition that without 
statement e.empno >= d.empno row/num or grp would be 
itentical for every row */
SELECT COUNT(*) as grp,
	e.empno,
	e.ename
FROM emp e, emp d
GROUP BY e.empno, e.ename
ORDER BY 1
;

/* Experiment with cross-join as solution to problems of type
12.2, specifically to assign employee rank */

SELECT 	e.empno, 
	e.ename,
	e2.empno,
	e2.ename
FROM emp AS e, emp as e2
WHERE e.empno >= e2.empno
ORDER BY 1, 2;

SELECT count(*) AS rnk,
	e.empno, 
	e.ename
	FROM emp AS e, emp as e2
WHERE e.empno >= e2.empno
GROUP BY e.empno, e.ename
;

SELECT count(*) AS rnk,
	e.empno, 
	e.ename
	FROM emp AS e, emp as e2
WHERE e.empno <= e2.empno
GROUP BY e.empno, e.ename
;

/* try rank/row num with session variables */
SELECT e.empno, 
	e.ename,
	init.RowNumInit,
	@rank := @rank + 1 AS 'RowNum'
	FROM emp AS e
	JOIN (SELECT @rank := 0 AS RowNumInit) AS init
;
/*
SELECT e.empno,
	e.ename,
	@row_number := CASE
		WHEN @row_number IS NULL 
			THEN SET @row_number = 1
			ELSE @row_number + 1
			END AS RowNum
	FROM emp AS e
	;
*/

/* the first attempt worked fine
the second attempt keeps incrementing the RowNum column
(e.g., most recent is row numbers 16-29),
presumably because now that the script has been run the session
variable is set and no longer null. 
So that points to a danger of session variables.
The first attempt (2nd above) resets with every run of the script
so seems to be a correct solution. 
It is notable that all solutions seem to either use a join
or a subquery; unlike the book solutions, however, it does
not appear that every solution requires a count of rows. */

/* 12.9 Create horizontal histograms */
SELECT deptno,
	lpad('*', count(*), '*') AS size
FROM emp 
GROUP BY deptno
;
select deptno,
	count(*) AS size
FROM emp
GROUP BY deptno
;

/* 12.10 Create vertical histograms */
/* first get table of asterisks to manipulate */
SELECT CASE deptno WHEN 10 THEN '*' ELSE NULL END AS D10,
	CASE deptno WHEN 20 THEN '*' ELSE NULL END AS D20,
	CASE deptno WHEN 30 THEN '*' ELSE NULL END AS D30
FROM emp
;

/* 12.10 Create vertical histograms */
SELECT MAX(D10) AS D10,
	MAX(D20) AS D20,
	MAX(D30) AS D30

FROM (
	SELECT 
	CASE deptno WHEN 10 THEN '*' ELSE NULL END AS D10,
	CASE deptno WHEN 20 THEN '*' ELSE NULL END AS D20,
	CASE deptno WHEN 30 THEN '*' ELSE NULL END AS D30, 
	(SELECT COUNT(*) FROM emp e2
	WHERE e1.deptno = e2.deptno AND e1.empno > e2.empno) AS rnk
FROM emp e1) AS x
GROUP BY rnk
ORDER BY 1, 2, 3
;

/* 12.11 Returning non-GROUP BY columns */

/* First build an inline view to find the high and low salaries
by deptno and job */
SELECT deptno,
	job,
	sal
FROM emp
ORDER BY deptno, job, sal
;
/*
SELECT deptno,
	job,
	max(sal) AS high_sal_dept_job,
	min(sal) AS low_sal_dept_job
FROM emp
GROUP BY deptno, job
;

SELECT emp.deptno,
	emp.ename,
	emp.job,
	emp.sal,
	x.high_sal as highest_empl_sal_dept_job,
	x.low_sal as lowest_empl_sal_dept_job
FROM emp
INNER JOIN

	(
	SELECT deptno,
		job,
		max(sal) AS high_sal,
		min(sal) AS low_sal
	FROM emp
	GROUP BY deptno, job) x

ON emp.deptno = x.deptno AND emp.job = x.job AND (emp.sal = x.high_sal OR emp.sal = x.low_sal)
ORDER BY emp.deptno, emp.job
;
*/

/* above attempts actually show lowest and highest salary within each 
job/dept combination. problem is to show highest and lowest within each job
and separately highest and lowest within each dept, then include employees
whose salary match any one of those 4 thresholds */
SELECT e.deptno,
	e.job,
	e.ename,
	e.sal,
	(SELECT max(sal) FROM emp e2
	WHERE e.deptno = e2.deptno) AS max_dept_sal,
	(SELECT max(sal) FROM emp e2
	WHERE e.job = e2.job) AS max_job_sal,
	(SELECT min(sal) FROM emp e2
	WHERE e.deptno = e2.deptno) AS min_dept_sal,
	(SELECT min(sal) FROM emp e2
	WHERE e.job = e2.job) AS min_job_sal
FROM emp e
ORDER BY e.deptno, e.job
;

SELECT deptno,
	job,
	ename,
	sal,
	CASE sal WHEN max_dept_sal THEN 'HIGH SAL IN DEPT'
		WHEN min_dept_sal THEN 'LOW SAL IN DEPT'
		END AS DEPT_STATUS,
	CASE sal WHEN max_job_sal THEN 'HIGH SAL IN JOB'
		WHEN min_job_sal THEN 'LOW SAL IN DEPT'
		END AS JOB_STATUS
FROM (
	SELECT e.deptno,
		e.job,
		e.ename,
		e.sal,
		(SELECT max(sal) FROM emp e2
		WHERE e.deptno = e2.deptno) AS max_dept_sal,
		(SELECT max(sal) FROM emp e2
		WHERE e.job = e2.job) AS max_job_sal,
		(SELECT min(sal) FROM emp e2
		WHERE e.deptno = e2.deptno) AS min_dept_sal,
		(SELECT min(sal) FROM emp e2
		WHERE e.job = e2.job) AS min_job_sal
	
	FROM emp e) x
ORDER BY deptno, job
;

SELECT deptno,
	job,
	ename,
	sal,
	CASE sal WHEN max_dept_sal THEN 'HIGH SAL IN DEPT'
		WHEN min_dept_sal THEN 'LOW SAL IN DEPT'
		END AS DEPT_STATUS,
	CASE sal WHEN max_job_sal THEN 'HIGH SAL IN JOB'
		WHEN min_job_sal THEN 'LOW SAL IN DEPT'
		END AS JOB_STATUS
FROM (
	SELECT e.deptno,
		e.job,
		e.ename,
		e.sal,
		(SELECT max(sal) FROM emp e2
		WHERE e.deptno = e2.deptno) AS max_dept_sal,
		(SELECT max(sal) FROM emp e2
		WHERE e.job = e2.job) AS max_job_sal,
		(SELECT min(sal) FROM emp e2
		WHERE e.deptno = e2.deptno) AS min_dept_sal,
		(SELECT min(sal) FROM emp e2
		WHERE e.job = e2.job) AS min_job_sal
	
	FROM emp e) x
WHERE sal in (max_dept_sal, 
		max_job_sal, 
		min_dept_sal, 
		min_job_sal)
-- ORDER BY deptno, job
;

/* 12.12 Calculalating simple subtotals */
-- use rollup extension
SELECT job, sum(sal) AS salary
FROM emp
GROUP BY job
;

SELECT job, sum(sal) AS salary
FROM emp
GROUP BY job WITH ROLLUP
;

SELECT COALESCE(job, 'TOTAL') job,
	sum(sal) AS salary
FROM emp
GROUP BY job WITH ROLLUP
;

SHOW WARNINGS;

/* received following warning for query above:
+---------+------+----------------------------------------------+
| Level   | Code | Message                                      |
+---------+------+----------------------------------------------+
| Warning | 1052 | Column 'job' in group statement is ambiguous |
+---------+------+----------------------------------------------+
*/

/* try to fix warning by renaming job */

SELECT COALESCE(job, 'TOTAL') job_name,
	sum(sal) AS salary
FROM emp
GROUP BY job_name WITH ROLLUP
;
/* 
Note: The above renaming of job column to job_name resulted in
error not being thrown, so it appears to have corrected issue
*/

-- use UNION operator
SELECT job, sum(sal) AS salary
FROM emp
GROUP BY job

UNION ALL

SELECT 'TOTAL' AS job,
	SUM(sal) AS salary
FROM emp
;

/* 12.13 Calculating subtotals for all possible combinations */

-- total by dept and job
SELECT deptno,
	job,
	"TOTAL BY DEPT AND JOB",
	SUM(sal)
FROM emp
GROUP BY deptno, job
;

/* 12.18 Aggregations over different groups/partitions */

SELECT e.ename,
	e.deptno,
	(SELECT COUNT(*) FROM emp e2
	WHERE e2.deptno = e.deptno) AS deptno_cnt,
	e.job,
	(SELECT COUNT(*) FROM emp e2
	WHERE e2.job = e.job) AS job_cnt,
	(SELECT COUNT(*) FROM emp e2) AS total_empl_cnt
FROM emp e
;

/* 12.19 Aggregrations over moving range */

-- examine hire date column
SELECT e.hiredate
FROM emp e
ORDER BY 1
;

-- add remaining cols
SELECT e.hiredate,
	e.sal,
	(SELECT SUM(sal) FROM emp e2
	WHERE e2.hiredate BETWEEN e.hiredate-90 AND e.hiredate)
		AS moving_90day_spend
FROM emp e
ORDER BY 1
;

-- modify solution to instead calc cumulative sum (not in book)
SELECT e.empno,
	e.hiredate,
	e.sal,
	(SELECT SUM(sal) FROM emp e2
	WHERE e2.empno <= e.empno)
		AS cumulative_spend
FROM emp e
ORDER BY 1
;

-- try with temp variable
SET @run_sum = 0;

SELECT e.empno,
	e.hiredate,
	e.sal,
	(@run_sum := (@run_sum + e.sal)) AS cumulative_sum
FROM emp e
ORDER BY 1
;

SET @run_sum = 0;
