/* CHAPTER 3: WORKING WITH MULTIPLE TABLES */

/* 3.7 Determining whether two tables have the same data */

/* Consider following view. Determine if this view and the table emp
have same data (cardinality and values).
*/

DROP VIEW IF EXISTS V;

CREATE VIEW V AS
SELECT * FROM emp WHERE deptno != 10
UNION ALL
SELECT * FROM emp WHERE ename = "WARD"
;

SELECT * FROM V;

-- Test cardinality first
SELECT COUNT(*) view_count FROM V;
SELECT COUNT(*) emp_count FROM emp;

-- Test view against emp table
-- Because rows could be duplicated,
-- include a column to test count of employees
-- in addition to testing other data

SELECT * 
FROM 
    (SELECT
        empno,
        ename,
        job,
        mgr,
        hiredate,
        sal,
        comm,
        deptno,
        COUNT(*) AS cnt
    FROM V
    GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
    ) v
WHERE NOT EXISTS (
    SELECT 1
    FROM (SELECT 
            empno,
            ename,
            job,
            mgr,
            hiredate,
            sal,
            comm,
            deptno,
            COUNT(*) AS cnt
        FROM emp
        GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
    ) e
    WHERE e.empno=v.empno
    AND e.ename=v.ename
    AND e.job=v.job
    AND COALESCE(e.mgr,0)=COALESCE(v.mgr,0)
    AND e.hiredate=v.hiredate
    AND e.sal=v.sal
    AND COALESCE(e.comm,0)=COALESCE(v.comm,0)
    AND e.hiredate=v.hiredate
    AND e.deptno=v.deptno
    AND e.cnt=v.cnt
)
;

-- Test emp table against view
-- Because rows could be duplicated,
-- include a column to test count of employees
-- in addition to testing other data
SELECT *
FROM
    (SELECT
        empno,
        ename,
        job,
        mgr,
        hiredate,
        sal,
        comm,
        deptno,
        COUNT(*) AS cnt
    FROM emp
    GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
    ) e
WHERE NOT EXISTS (
    SELECT 1
    FROM (
        SELECT
            empno,
            ename,
            job,
            mgr,
            hiredate,
            sal,
            comm,
            deptno,
            COUNT(*) AS cnt
        FROM V
        GROUP BY empno, ename, job, mgr, hiredate, sal, comm, deptno
            ) v
    WHERE v.empno=e.empno
    AND v.ename=e.ename
    AND v.job=e.job
    AND COALESCE(v.mgr, 0)=COALESCE(e.mgr,0)
    AND v.hiredate=e.hiredate
    AND v.sal=e.sal
    AND COALESCE(v.comm,0)=COALESCE(e.comm,0)
    AND v.deptno=e.deptno
    AND v.cnt=e.cnt
    )
;
DROP VIEW IF EXISTS V;

/* To combine the two sets, would just use a UNION ALL */

/* Performing joins when using aggregates */

-- Join emp and bonus tables to compute total salary and
-- total bonus for all employees
-- Handle fact that employee can have more than one bonus

-- View bonus table structure
SELECT * FROM emp_bonus;

-- View joined table
SELECT 
    e.ename,
    e.empno,
    e.sal,
    eb.empno,
    eb.type
FROM emp e
LEFT JOIN emp_bonus eb
ON eb.empno=e.empno
;

-- Add bonus calc to joined table
SELECT 
    e.ename,
    e.empno,
    e.sal,
    eb.empno,
    eb.type,
    e.sal * (COALESCE(eb.type,0)/10) AS bonus
FROM emp e
LEFT JOIN emp_bonus eb
ON eb.empno=e.empno
;

-- Calculate sum of bonus
-- Then calculate sum of salary as inline query
SELECT
    SUM(e.sal * (COALESCE(eb.type,0)/10)) AS bonus_total,
    (SELECT SUM(sal) FROM emp) AS salary_total
FROM emp e
LEFT JOIN emp_bonus eb
ON eb.empno=e.empno
;

-- Calculate each total independently to verify
SELECT SUM(sal) AS salary_total FROM emp;

SELECT
    SUM((SELECT e.sal 
    FROM emp e 
    WHERE e.empno=eb.empno) * (eb.type/10)) AS bonus_total
FROM emp_bonus eb
;

-- Alternate approach

-- First add salary total as column to joined table
SELECT
    e.ename,
    e.empno,
    e.sal,
    eb.empno,
    eb.type,
    e.sal * (COALESCE(eb.type,0)/10) AS bonus_total,
    (SELECT SUM(sal) FROM emp) AS salary_total
FROM emp e
LEFT JOIN emp_bonus eb
ON eb.empno=e.empno
;

-- Then sum bonus
-- Note that the GROUP BY is technically optional, since
-- the column salary_total is the same for all rows
SELECT 
    SUM(bonus_total), 
    salary_total
FROM (
    SELECT
        e.sal * (COALESCE(eb.type,0)/10) AS bonus_total,
        (SELECT SUM(sal) FROM emp) AS salary_total
    FROM emp e
    LEFT JOIN emp_bonus eb
    ON eb.empno=e.empno
    ) comp
GROUP BY salary_total
;

/* Restart chapter from beginning */

/* 3.1 Stacking one rowset atop another */

-- display name and dept number of employees in dept 10
-- along with name and dept number of each dept in table dept

SELECT
    ename AS ename_and_dname,
    deptno
FROM emp
WHERE deptno in (10)

UNION ALL
SELECT "--------", "" FROM DUAL

UNION ALL
SELECT
    dname,
    deptno
FROM dept
;

/* 3.2 Combining related rows */

-- Display names of employees in dept 10 along with loc of each dept

SELECT emp.ename, dept.loc
FROM emp
LEFT JOIN dept
ON emp.deptno=dept.deptno
WHERE emp.deptno in (10)
;

/* 3.3 Finding rows in common between two tables */

