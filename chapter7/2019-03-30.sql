/* Chapter 7: Working with numbers */

/* 7.1 Computing an average */

-- avg salary for all empl
-- avg salary for each dept

SELECT AVG(sal)
FROM emp
;

SELECT 
    deptno,
    AVG(sal)
FROM emp
GROUP BY deptno
;

-- avg commission by dept
SELECT deptno,
    AVG(COALESCE(comm, 0)) as avg_comm
FROM emp
GROUP BY deptno
;

/* 7.2 Finding min/max value in column */

-- Find highest and lowest sal for all employees
-- Find highest and lowest sal for each dept

SELECT MIN(sal) AS lowest_sal,
    MAX(sal) AS highest_sal
FROM emp
;

SELECT deptno,
    MIN(sal) as lowest_dept_sal,
    MAX(sal) as highest_dept_sal
FROM emp
GROUP BY deptno
;

/* 7.3 Summing values */

-- find sum of salaries
-- find sum of salaries by dept
-- find sum of comm, a nullable field
-- find sum of comm by dept

SELECT SUM(sal) total_sal
FROM emp
;

SELECT deptno,
    SUM(sal) total_dept_sal
FROM emp
GROUP BY deptno
;

-- comm
-- SUM() func automatically ignores nulls
-- compare results with and without coalesce

SELECT deptno,
    SUM(comm) total_comm
FROM emp
GROUP BY deptno
;

SELECT deptno,
    SUM(COALESCE(comm, 0)) AS total_comm
FROM emp
GROUP BY deptno
;

/* 7.4 Counting rows in a table */

-- count number of rows by dept
-- count number of comm *values* by dept

SELECT deptno,
    COUNT(*) total_emps
FROM emp
GROUP BY deptno
;

SELECT deptno,
    COUNT(comm) AS total_comm_rows
FROM emp
GROUP BY deptno
;

/* 7.5 Counting values in a column */

/* Demonstrated above with supplemental solution to 7.4 */

/* 7.6 Generating a running total */

-- compute running total of salaries for all employees

-- solution using scalar, correlated subquery
SELECT 
    empno,
    ename,
    deptno,
    sal,
    (SELECT SUM(sal) FROM emp e2
    WHERE e2.empno <= e.empno) AS running_sal_total
FROM emp e
;

-- similar solution, but impose ordering
-- by hire date to make it a running total
-- of employees as they're hired

-- note that two employees could be hired on the same day
-- see emps 7900 (James) and 7902 (Ford)
-- Want to make sure total is accurate based on tie breaker
-- which is going to be empno

SELECT 
    empno,
    ename,
    hiredate,
    deptno,
    sal,
    CASE WHEN (SELECT COUNT(*) FROM emp e2
                WHERE e2.hiredate = e.hiredate) > 1
        THEN (
            (SELECT SUM(sal) FROM emp e2
            WHERE e2.hiredate < e.hiredate) + 
            (SELECT SUM(sal) FROM emp e2
            WHERE e2.hiredate = e.hiredate
            AND e2.empno <= e.empno)
            )
        ELSE (
            SELECT SUM(sal) FROM emp e2
            WHERE e2.hiredate <= e.hiredate)
        END
        AS running_total_sal
FROM emp e
ORDER BY hiredate, empno
;