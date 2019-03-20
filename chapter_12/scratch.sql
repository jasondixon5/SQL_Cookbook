/* scratch practice of various concepts in the chapter */

/* assigning row number */

SELECT ename,
	(SELECT COUNT(*) FROM emp e2
	WHERE e.empno <= e2.empno) AS rnk_no
FROM emp e
;

/* assigning row number and grouping within categories*/

SELECT ename,
	job,
	(SELECT COUNT(*) FROM emp e2
	WHERE e.empno <= e2.empno
	AND e.job = e2.job) AS rnk_no
FROM emp e
ORDER BY job
;

/* assigning row number and grouping within categories*/
/* to create sparse matrix */

SELECT rnk_no,
	CASE job
		WHEN "CLERK" THEN ename ELSE NULL END AS clerks,
	CASE job
		WHEN "SALESMAN" THEN ename ELSE NULL END AS sales,
	CASE job
		WHEN "MANAGER" THEN ename ELSE NULL END AS mgrs,
	CASE job
		WHEN "ANALYST" THEN ename ELSE NULL END AS best,
	CASE job 
		WHEN "PRESIDENT" THEN ename ELSE NULL END AS jefe
FROM
(
	SELECT ename,
		job,
		(SELECT COUNT(*) FROM emp e2
		WHERE e.empno <= e2.empno
		AND e.job = e2.job) AS rnk_no
	FROM emp e) x
ORDER BY 1, 2, 3, 4, 5, 6
;

/* assigning row number and grouping within categories*/
/* to create sparse matrix */
/* collapse to remove nulls */

SELECT rnk_no,
	MAX(CASE job
		WHEN "CLERK" THEN ename ELSE NULL END) AS clerks,
	MAX(CASE job
		WHEN "SALESMAN" THEN ename ELSE NULL END) AS sales,
	MAX(CASE job
		WHEN "MANAGER" THEN ename ELSE NULL END) AS mgrs,
	MAX(CASE job
		WHEN "ANALYST" THEN ename ELSE NULL END) AS best,
	MAX(CASE job 
		WHEN "PRESIDENT" THEN ename ELSE NULL END) AS jefe
FROM
(
	SELECT ename,
		job,
		(SELECT COUNT(*) FROM emp e2
		WHERE e.empno <= e2.empno
		AND e.job = e2.job) AS rnk_no
	FROM emp e) x
GROUP BY rnk_no
ORDER BY 1, 2, 3, 4, 5, 6
;

/* assigning row number and grouping within categories*/
/* to create sparse matrix */
/* collapse to remove nulls */
/* remove rnk_no from displayed cols, as it isn't interpretable now */
/* also remove order by clause */

SELECT 
	MAX(CASE job
		WHEN "CLERK" THEN ename ELSE NULL END) AS clerks,
	MAX(CASE job
		WHEN "SALESMAN" THEN ename ELSE NULL END) AS sales,
	MAX(CASE job
		WHEN "MANAGER" THEN ename ELSE NULL END) AS mgrs,
	MAX(CASE job
		WHEN "ANALYST" THEN ename ELSE NULL END) AS best,
	MAX(CASE job 
		WHEN "PRESIDENT" THEN ename ELSE NULL END) AS jefe
FROM
(
	SELECT ename,
		job,
		(SELECT COUNT(*) FROM emp e2
		WHERE e.empno <= e2.empno
		AND e.job = e2.job) AS rnk_no
	FROM emp e) x
GROUP BY rnk_no
;


