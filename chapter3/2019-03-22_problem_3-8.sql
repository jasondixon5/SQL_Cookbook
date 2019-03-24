/* Chapter 3 */

/* 3.7 Determining whether two tables have the same data */

DROP VIEW IF EXISTS V;

CREATE VIEW V AS
	SELECT * FROM emp WHERE deptno != 10
	UNION ALL
	SELECT * FROM emp WHERE ename = "WARD"
;

-- SELECT * FROM v;

-- query to pull info from each table
-- with cnt column to identify instances of 
-- duplicate entries for employees
-- Will be used as subqueries from which to pull

SELECT e.empno,
	e.ename,
	e.job,
	e.mgr,
	e.hiredate,
	e.sal,
	e.comm,
	e.deptno,
	COUNT(*) AS cnt
FROM emp e
GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
;

SELECT v.empno,
	v.ename,
	v.job,
	v.mgr,
	v.hiredate,
	v.sal,
	v.comm,
	v.deptno,
	COUNT(*) AS cnt
FROM V v
GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
;

-- get rows in e that aren't in v
-- via correlated join conditions
SELECT * 
FROM (
	SELECT e.empno,
		e.ename,
		e.job,
		e.mgr,
		e.hiredate,
		e.sal,
		e.comm,
		e.deptno,
		COUNT(*) AS cnt
	FROM emp e
	GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
	) e

WHERE NOT EXISTS (

	SELECT 1
	FROM (

		SELECT v.empno,
			v.ename,
			v.job,
			v.mgr,
			v.hiredate,
			v.sal,
			v.comm,
			v.deptno,
			COUNT(*) AS cnt
		FROM V v
		GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
	) v
	WHERE v.empno = e.empno
	AND v.ename = e.ename
	AND v.job = e.job
	AND COALESCE(v.mgr, 0) = COALESCE(e.mgr, 0)
	AND v.hiredate = e.hiredate
	AND v.sal = e.sal
	AND COALESCE(v.comm, 0) = COALESCE(e.comm, 0)
	AND v.deptno = e.deptno
	AND v.cnt = e.cnt
)

;

-- get rows in v that aren't in v
-- via correlated join conditions
SELECT *
FROM (
	SELECT v.empno,
		v.ename,
		v.job,
		v.mgr,
		v.hiredate,
		v.sal,
		v.comm,
		v.deptno,
		COUNT(*) AS cnt
	FROM V v
	GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
) v
WHERE NOT EXISTS (
	SELECT 1 
	FROM (
		SELECT e.empno,
			e.ename,
			e.job,
			e.mgr,
			e.hiredate,
			e.sal,
			e.comm,
			e.deptno,
			COUNT(*) AS cnt
		FROM emp e
		GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
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

-- union all the two results
SELECT *
FROM (

	SELECT empno,
	ename,
	job,
	mgr,
	hiredate,
	sal,
	comm,
	deptno,
	count(*) AS cnt
	FROM emp
	GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
) e

WHERE NOT EXISTS (
	SELECT 1 FROM (
		SELECT empno,
		ename,
		job,
		mgr,
		hiredate,
		sal,
		comm,
		deptno,
		count(*) AS cnt
		FROM V
		GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
	) v
	WHERE v.empno = e.empno
	AND v.ename = e.ename
	AND v.job = e.job
	AND COALESCE(v.mgr, 0) = COALESCE(e.mgr, 0)
	AND v.hiredate = e.hiredate
	AND v.sal = e.sal
	AND COALESCE(v.comm, 0) = COALESCE(e.comm, 0)
	AND v.deptno = e.deptno
	AND v.cnt = e.cnt
)

UNION ALL

SELECT *
FROM (
	SELECT empno,
	ename,
	job,
	mgr,
	hiredate,
	sal,
	comm,
	deptno,
	count(*) AS cnt
	FROM V
	GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
) v

WHERE NOT EXISTS (
	SELECT 1 FROM (
		SELECT empno,
		ename,
		job,
		mgr,
		hiredate,
		sal,
		comm,
		deptno,
		count(*) AS cnt
		FROM emp
		GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
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
-- try adding col to indicate source of rows
SELECT *
FROM (

	SELECT 'emp_table' AS source, 
	empno,
	ename,
	job,
	mgr,
	hiredate,
	sal,
	comm,
	deptno,
	count(*) AS cnt
	FROM emp
	GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
) e

WHERE NOT EXISTS (
	SELECT 1 FROM (
		SELECT empno,
		ename,
		job,
		mgr,
		hiredate,
		sal,
		comm,
		deptno,
		count(*) AS cnt
		FROM V
		GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
	) v
	WHERE v.empno = e.empno
	AND v.ename = e.ename
	AND v.job = e.job
	AND COALESCE(v.mgr, 0) = COALESCE(e.mgr, 0)
	AND v.hiredate = e.hiredate
	AND v.sal = e.sal
	AND COALESCE(v.comm, 0) = COALESCE(e.comm, 0)
	AND v.deptno = e.deptno
	AND v.cnt = e.cnt
)

UNION ALL

SELECT *
FROM (
	SELECT 'v_table',
	empno,
	ename,
	job,
	mgr,
	hiredate,
	sal,
	comm,
	deptno,
	count(*) AS cnt
	FROM V
	GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
) v

WHERE NOT EXISTS (
	SELECT 1 FROM (
		SELECT empno,
		ename,
		job,
		mgr,
		hiredate,
		sal,
		comm,
		deptno,
		count(*) AS cnt
		FROM emp
		GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
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

