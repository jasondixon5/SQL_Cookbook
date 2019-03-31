/* pivot mult rows into one row/mult columns 
first show set to transform */
SELECT deptno, count(*)
FROM emp
GROUP BY deptno
;

/* now pivot into one row */
/* included cols not in book for unaccounted for values and for nulls */

SELECT SUM(CASE WHEN deptno = 10 THEN 1 else 0 end) as count_dept10,
SUM(CASE WHEN deptno = 20 THEN 1 ELSE 0 end) as count_dept20,
SUM(CASE WHEN deptno = 30 THEN 1 ELSE 0 end) as count_dept30,
SUM(CASE WHEN deptno NOT IN (10, 20, 30) THEN 1 ELSE 0 end) as count_otherdept,
SUM(CASE WHEN deptno IS NULL THEN 1 ELSE 0 end) AS count_nulldeptno
FROM EMP
;

/* 12.2 pivoting result set into multiple rows */

SELECT MAX(CASE WHEN job = "CLERK" THEN ename ELSE NULL END) AS clerks,
MAX(CASE WHEN job = "ANALYST" THEN ename ELSE NULL END) AS analysts,
MAX(CASE WHEN job = "MANAGER" THEN ename ELSE NULL END) AS mgrs,
MAX(CASE WHEN job = "PRESIDENT" THEN ename ELSE NULL END) AS prez,
MAX(CASE WHEN job = "SALESMAN" THEN ename ELSE NULL END) AS sales
FROM (
	SELECT e.job,
		e.ename,
		(SELECT COUNT(*) FROM emp d
		WHERE e.job=d.job AND e.empno < d.empno) as rnk
		FROM emp e
		) x
	GROUP BY rnk
;

SELECT e.job,
	e.ename,
	(SELECT COUNT(*) FROM emp d
WHERE e.job=d.job AND e.empno < d.empno) as rnk
FROM emp e
;

SELECT job, ename, empno FROM emp;

/* Be careful to note that the condition using " < " is not
d.empno < e.empno but rather e.empno < d.empno. 
In words, that means something like within subtable d,
"count all employees with this job who have an empno greater
than the empno of the row I'm looking at in the main table
right now." 
To note:
* I think it would be less confusing to write d.empno > e.empno
  instead of e.empno < d.empno
* This only works because empno is monotonic in the table emp.
  If employee numbers were reused, this solution wouldn't work
  to provide an employee rank.
* If the condition were d.empno < e.empno, the solution still
  works, but the opposite rank is assigned to each row.
  This results in the employees being listed in the opposite order
  of the provided solution, but, interestingly, also results in the
  employees being listed in the same order as they appear in the 
  table.
*/

--  rewrite as d.empno > e.empno
SELECT e.job,
	e.ename,
	(SELECT COUNT(*) FROM emp d
WHERE e.job=d.job AND d.empno > e.empno) as rnk
FROM emp e
;

-- rewrite with opposite rank order assigned
SELECT e.job,
	e.ename,
	(SELECT COUNT(*) FROM emp d
WHERE e.job=d.job AND d.empno < e.empno) as rnk
FROM emp e
;

SELECT MAX(CASE WHEN job = "CLERK" THEN ename ELSE NULL END) AS clerks,
MAX(CASE WHEN job = "ANALYST" THEN ename ELSE NULL END) AS analysts,
MAX(CASE WHEN job = "MANAGER" THEN ename ELSE NULL END) AS mgrs,
MAX(CASE WHEN job = "PRESIDENT" THEN ename ELSE NULL END) AS prez,
MAX(CASE WHEN job = "SALESMAN" THEN ename ELSE NULL END) AS sales
FROM (
	SELECT e.job,
		e.ename,
		(SELECT COUNT(*) FROM emp d
		WHERE e.job=d.job AND e.empno < d.empno) as rnk
		FROM emp e
		) x
	GROUP BY rnk
;


SELECT MAX(CASE WHEN job = "CLERK" THEN ename ELSE NULL END) AS clerks,
MAX(CASE WHEN job = "ANALYST" THEN ename ELSE NULL END) AS analysts,
MAX(CASE WHEN job = "MANAGER" THEN ename ELSE NULL END) AS mgrs,
MAX(CASE WHEN job = "PRESIDENT" THEN ename ELSE NULL END) AS prez,
MAX(CASE WHEN job = "SALESMAN" THEN ename ELSE NULL END) AS sales
FROM (
	SELECT e.job,
		e.ename,
		(SELECT COUNT(*) FROM emp d
		WHERE e.job=d.job AND e.empno > d.empno) as rnk
		FROM emp e
		) x
	GROUP BY rnk
;

/* 12.2 addl practice */

SELECT job, 
	ename
FROM emp
ORDER BY job
;

SELECT job,
	ename,
	CASE WHEN job="ANALYST" THEN 1 ELSE NULL END AS analysts
FROM emp
ORDER BY job
;

SELECT job,
	ename,
	CASE WHEN job="ANALYST" THEN ename ELSE NULL END AS analysts,
	CASE WHEN job="CLERK" THEN ename ELSE NULL END AS clerks,
	CASE WHEN job not in ("ANALYST", "CLERK") THEN ename ELSE NULL END AS others
FROM emp
ORDER BY job
;

SELECT 	CASE WHEN job="ANALYST" THEN ename ELSE NULL END AS analysts,
	CASE WHEN job="CLERK" THEN ename ELSE NULL END AS clerks,
	CASE WHEN job not in ("ANALYST", "CLERK") THEN ename ELSE NULL END AS others
FROM emp
ORDER BY job
;

SELECT 	rnk,
	CASE WHEN job="ANALYST" THEN ename ELSE NULL END AS analysts,
	CASE WHEN job="CLERK" THEN ename ELSE NULL END AS clerks
	FROM (
	SELECT e.job,
		e.ename,
		(SELECT COUNT(*) FROM emp d
		WHERE e.job=d.job AND d.empno < e.empno) AS rnk
	FROM emp e) X
ORDER BY rnk
;


SELECT 	rnk,
	MAX(CASE WHEN job="ANALYST" THEN ename ELSE NULL END) AS analysts,
	MAX(CASE WHEN job="CLERK" THEN ename ELSE NULL END) AS clerks
FROM (
	SELECT e.job,
		e.ename,
		(SELECT COUNT(*) FROM emp d
		WHERE e.job=d.job AND d.empno < e.empno) AS rnk
	FROM emp e) X
GROUP BY RNK
;


SELECT 	MAX(CASE WHEN job="ANALYST" THEN ename ELSE NULL END) AS analysts,
	MAX(CASE WHEN job="CLERK" THEN ename ELSE NULL END) AS clerks
FROM (
	SELECT e.job,
		e.ename,
		(SELECT COUNT(*) FROM emp d
		WHERE e.job=d.job AND d.empno < e.empno) AS rnk
	FROM emp e) X
GROUP BY RNK
;

