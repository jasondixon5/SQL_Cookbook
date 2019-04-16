/* CHAPTER 3: WORKING WITH MULTIPLE TABLES */

/* 3.3 Finding rows in common between two tables */

DROP VIEW IF EXISTS V;

CREATE VIEW V AS 
SELECT ename, job, sal
FROM emp
WHERE job="CLERK"
;

SELECT * FROM V;

-- Return empno, ename, job, sal, and deptno columns
-- for all employees in emp that match rows in view V

-- Option: Join
SELECT
    e.empno,
    e.ename,
    e.job,
    e.sal,
    e.deptno
FROM emp e
INNER JOIN V v
ON v.ename=e.ename
AND v.job=e.job
AND v.sal=e.sal
;

-- Option: Correlated subquery with exists
SELECT
    e.empno,
    e.ename,
    e.job,
    e.sal,
    e.deptno
FROM emp e
WHERE EXISTS (
    SELECT 1
    FROM V v
    WHERE v.ename=e.ename
    AND v.job=e.job
    AND v.sal=e.sal
)
;

DROP VIEW IF EXISTS V;

/* 3.4 Retrieving values from one table that do not exist in another */

-- Find which dept numbers, if any, in table dept do not exist in table emp

-- Option: Subquery with NOT IN (with handling for nulls)
SELECT d.deptno
FROM dept d
WHERE d.deptno NOT IN 
(SELECT e.deptno FROM emp e WHERE e.deptno IS NOT NULL)
;

-- Option: Outer join, with filter for nulls in right table
SELECT d.deptno
FROM dept d
LEFT JOIN emp e
ON e.deptno=d.deptno
WHERE e.deptno IS NULL
;

-- Option: Subquery with NOT EXISTS
SELECT d.deptno
FROM dept d 
WHERE NOT EXISTS (
    SELECT 1
    FROM emp e
    WHERE e.deptno=d.deptno
)
;

/*3.5 Skip - similar to above but returning more columns
Book solution uses approach of second option for above problem */

/* 3.6 Adding joins to a query without interfering with other joins*/

-- Have a query, below of employees and their location
-- Want to add date each employee received a bonus
-- (creating view for bonuses for this problem since my emp_bonus
-- table is slightly different than the book's)

DROP VIEW IF EXISTS bonus_view;

CREATE VIEW bonus_view AS
SELECT 7369 AS empno, '14-03-2005' AS received, 1 AS type
UNION ALL
SELECT 7900, '14-03-2005', 2
UNION ALL
SELECT 7788, '14-03-2005', 3
;

SELECT * FROM bonus_view;

-- Starting query to add to
SELECT e.ename, d.loc
FROM emp e, dept d
WHERE e.deptno=d.deptno
;

-- add to query with outer join
-- have to restructure inner join syntax to ansi 92
-- (this is advantage of always using that syntax instead of old)
SELECT e.ename, d.loc, bv.received
FROM emp e INNER JOIN dept d
ON e.deptno=d.deptno
LEFT JOIN bonus_view bv
ON e.empno=bv.empno
-- in revised (but not original) query, book orders by loc
ORDER BY d.loc, e.ename;

-- another option: use subquery in select list
-- to mimic outer join
SELECT e.ename,
    d.loc,
    (SELECT bv.received FROM bonus_view bv
    WHERE bv.empno=e.empno) AS received
FROM emp e INNER JOIN dept d
ON e.deptno=d.deptno
ORDER BY d.loc, e.ename
;

DROP VIEW IF EXISTS bonus_view;

/* 3.7 Determining whether two tables have the same data */

-- consider following view
DROP VIEW IF EXISTS V;
CREATE VIEW V AS
    SELECT * FROM emp WHERE deptno != 10
    UNION ALL
    SELECT * FROM emp WHERE ename = "WARD"
;
SELECT * FROM V;

-- Return rows in emp that are not in V
-- Consider both cardinality and values

SELECT *
FROM (
    SELECT 
        ename,
        job,
        mgr,
        hiredate,
        sal,
        comm,
        deptno,
        COUNT(*) AS cnt
    FROM emp
    GROUP BY ename, job, mgr, hiredate, sal, comm, deptno
) e
WHERE NOT EXISTS (
    SELECT 1 FROM (
        SELECT 
            ename
            job,
            mgr,
            hiredate,
            sal,
            comm,
            COUNT(*) AS cnt
        FROM V
        GROUP BY ename, job, mgr, hiredate, sal, comm
    ) v
    WHERE v.ename=e.ename
    AND v.job=e.job
    AND COALESCE(v.mgr, 0)=COALESCE(e.mgr, 0)
    AND v.hiredate=e.hiredate
    AND v.sal=e.sal
    AND COALESCE(v.comm, 0)=COALESCE(e.comm, 0)
    AND v.cnt = e. cnt
)
;

/* Error:
ERROR 1054 (42S22): Unknown column 'v.ename' in 'where clause'
*/

-- Verify inline view "v"
SELECT 
    ename
    job,
    mgr,
    hiredate,
    sal,
    comm,
    COUNT(*) AS cnt
FROM V
GROUP BY ename, job, mgr, hiredate, sal, comm
;

SHOW WARNINGS;

/* Forgot a comma after 'ename' !!! 
*/

-- Return rows in emp that are not in V
SELECT *
FROM (
    SELECT 
        ename,
        job,
        mgr,
        hiredate,
        sal,
        comm,
        deptno,
        COUNT(*) AS cnt
    FROM emp
    GROUP BY ename, job, mgr, hiredate, sal, comm, deptno
) e
WHERE NOT EXISTS (
    SELECT 1 FROM (
        SELECT 
            ename,
            job,
            mgr,
            hiredate,
            sal,
            comm,
            COUNT(*) AS cnt
        FROM V
        GROUP BY ename, job, mgr, hiredate, sal, comm
    ) v
    WHERE v.ename=e.ename
    AND v.job=e.job
    AND COALESCE(v.mgr, 0)=COALESCE(e.mgr, 0)
    AND v.hiredate=e.hiredate
    AND v.sal=e.sal
    AND COALESCE(v.comm, 0)=COALESCE(e.comm, 0)
    AND v.cnt = e. cnt
)
;

-- obtain rows in V not in table emp

SELECT *
FROM (
    SELECT 
        ename,
        job,
        mgr,
        hiredate,
        sal,
        comm,
        deptno,
        COUNT(*) AS cnt
    FROM V
    GROUP BY ename, job, mgr, hiredate, sal, comm, deptno
) v
WHERE NOT EXISTS (
    SELECT 1 FROM (
        SELECT 
            ename,
            job,
            mgr,
            hiredate,
            sal,
            comm,
            COUNT(*) AS cnt
        FROM emp
        GROUP BY ename, job, mgr, hiredate, sal, comm
    ) e
    WHERE v.ename=e.ename
    AND v.job=e.job
    AND COALESCE(v.mgr, 0)=COALESCE(e.mgr, 0)
    AND v.hiredate=e.hiredate
    AND v.sal=e.sal
    AND COALESCE(v.comm, 0)=COALESCE(e.comm, 0)
    AND v.cnt = e. cnt
)
;

/* Try storing each result set in a view
and then unioning them */

-- Return rows in emp that are not in V
CREATE VIEW in_emp_not_in_v AS

SELECT *
FROM (
    SELECT 
        ename,
        job,
        mgr,
        hiredate,
        sal,
        comm,
        deptno,
        COUNT(*) AS cnt
    FROM emp
    GROUP BY ename, job, mgr, hiredate, sal, comm, deptno
) e
WHERE NOT EXISTS (
    SELECT 1 FROM (
        SELECT 
            ename,
            job,
            mgr,
            hiredate,
            sal,
            comm,
            COUNT(*) AS cnt
        FROM V
        GROUP BY ename, job, mgr, hiredate, sal, comm
    ) v
    WHERE v.ename=e.ename
    AND v.job=e.job
    AND COALESCE(v.mgr, 0)=COALESCE(e.mgr, 0)
    AND v.hiredate=e.hiredate
    AND v.sal=e.sal
    AND COALESCE(v.comm, 0)=COALESCE(e.comm, 0)
    AND v.cnt = e. cnt
)
;

-- obtain rows in V not in table emp
CREATE VIEW in_v_not_in_emp AS
SELECT *
FROM (
    SELECT 
        ename,
        job,
        mgr,
        hiredate,
        sal,
        comm,
        deptno,
        COUNT(*) AS cnt
    FROM V
    GROUP BY ename, job, mgr, hiredate, sal, comm, deptno
) v
WHERE NOT EXISTS (
    SELECT 1 FROM (
        SELECT 
            ename,
            job,
            mgr,
            hiredate,
            sal,
            comm,
            COUNT(*) AS cnt
        FROM emp
        GROUP BY ename, job, mgr, hiredate, sal, comm
    ) e
    WHERE v.ename=e.ename
    AND v.job=e.job
    AND COALESCE(v.mgr, 0)=COALESCE(e.mgr, 0)
    AND v.hiredate=e.hiredate
    AND v.sal=e.sal
    AND COALESCE(v.comm, 0)=COALESCE(e.comm, 0)
    AND v.cnt = e. cnt
)
;

SELECT * FROM in_v_not_in_emp
UNION ALL
SELECT * FROM in_emp_not_in_v
;

/* 3.9 Performing joins when using aggregates */

DROP VIEW IF EXISTS v_emp_bonus;

CREATE VIEW v_emp_bonus AS 
SELECT 7934 AS empno, "2005-03-17" AS received, 1 AS type
UNION ALL 
SELECT 7934 AS empno, "2005-02-15" AS received, 2 AS type
UNION ALL
SELECT 7839 AS empno, "2005-02-15" AS received, 3 AS type
UNION ALL
SELECT 7782 AS empno, "2005-02-15" AS received, 1 AS type
;

SELECT * FROM v_emp_bonus;

-- Find sum of all salaries in dept 10
-- along with the sum of their bonuses
-- Note that type in bonus table corresponds
-- to % of salary (e.g., 1 = 10% or .10)
-- Use view v_emp_bonus to get bonus info

-- get bonus amounts
SELECT
    eb.empno,
    eb.type,
    e.sal,
    eb.type/10*e.sal AS bonus_amount
FROM v_emp_bonus eb
LEFT JOIN emp e
ON e.empno=eb.empno
;

-- get employees and salaries in dept 10,
-- along with sum of salaries
SELECT e.empno,
    e.sal
FROM emp e
WHERE e.deptno IN (10)
;

-- add bonus type to employee result set
SELECT e.empno,
    e.sal,
    eb.type
FROM emp e
INNER JOIN v_emp_bonus eb
ON e.empno=eb.empno
WHERE e.deptno IN (10)
;

-- add calculate of bonus
-- via subquery
SELECT e.empno,
    e.sal,
    eb.type,
    e.sal*(eb.type/10) AS bonus_amount
FROM emp e
INNER JOIN v_emp_bonus eb
ON e.empno=eb.empno
WHERE e.deptno IN (10)
;

/*
This result set reveals the problem.
If we sum the sal column, empno 7934
will have his/her salary included 
twice in the sum

+-------+------+------+--------------+
| empno | sal  | type | bonus_amount |
+-------+------+------+--------------+
|  7782 | 2450 |    1 |     245.0000 |
|  7839 | 5000 |    3 |    1500.0000 |
|  7934 | 1300 |    1 |     130.0000 |
|  7934 | 1300 |    2 |     260.0000 |
+-------+------+------+--------------+
4 rows in set (0.00 sec)

*/

-- Calculate sum of bonuses
-- and include sum of salaries as subquery
SELECT SUM(
            e.sal*(eb.type/10)
            ) AS bonus_amount,
        (SELECT SUM(sal) FROM emp e2
        WHERE e2.deptno IN (10)) 
            AS salary_total
FROM emp e
INNER JOIN v_emp_bonus eb
ON e.empno=eb.empno
WHERE e.deptno IN (10)
;

-- Another approach is to create table of bonuses as above
-- with a scalar column for sum of salaries
-- and then calculate sum of bonuses and avg of salary total
-- outside of query

SELECT SUM(bonus_amount) as dept10_bonus,
    salary_total
FROM (
SELECT
    e.sal*(eb.type/10) AS bonus_amount,
    (SELECT SUM(sal) FROM emp e2
    WHERE e2.deptno IN (10)) AS salary_total
FROM emp e
INNER JOIN v_emp_bonus eb
ON e.empno=eb.empno
WHERE e.deptno IN (10)
) x
;

-- What if the filter for which employees to include
-- was more complicated than just those in dept 10?
-- In that case, including the filter criteria in both
-- the outer query (that joins v_emp_bonus & emp) and
-- the subquery that totals the salaries would be
-- subject to error
-- Might prefer to do sum of salaries outside of query
-- rather than sum of bonuses
SELECT
    SUM(bonus_amount) AS bonus_total,
    (SELECT SUM(salary) FROM emp e2
    WHERE e2.empno IN (SELECT empno FROM x)) AS salary_total
FROM (
SELECT 
    eb.empno,
    e.deptno,
    e.sal*(eb.type/10) AS bonus_amount
FROM emp e
INNER JOIN v_emp_bonus eb
ON e.empno=eb.empno
WHERE e.deptno in (10)
) x; 

/*
Received error on above query: 
ERROR 1146 (42S02): Table 'sql_cookbook.x' doesn't exist
*/

SELECT
    SUM(bonus_amount) AS bonus_total,
    (SELECT SUM(sal) FROM emp e2
    WHERE e2.empno=x.empno) AS salary_total
FROM (
SELECT 
    eb.empno,
    e.deptno,
    e.sal*(eb.type/10) AS bonus_amount
FROM emp e
INNER JOIN v_emp_bonus eb
ON e.empno=eb.empno
WHERE e.deptno in (10)
) x; 

/* ERROR 1140 (42000): In aggregated query without GROUP BY, 
expression #2 of SELECT list contains nonaggregated column 'x.empno'; 
this is incompatible with sql_mode=only_full_group_by
*/

-- only option may a temp table or view out of the joined table
-- that calculates the bonus amount
-- and then refer to it twice

DROP VIEW IF EXISTS bonus_calc;
CREATE VIEW bonus_calc AS
SELECT 
    eb.empno,
    e.deptno,
    e.sal*(eb.type/10) AS bonus_amount
FROM emp e
INNER JOIN v_emp_bonus eb
ON e.empno=eb.empno
WHERE e.deptno in (10)
;

SELECT * FROM bonus_calc;

SELECT SUM(bonus_amount) AS bonus_total,
(SELECT SUM(sal) FROM emp
WHERE emp.empno IN (SELECT bonus_calc.empno FROM bonus_calc))
    AS salary_total
FROM bonus_calc
;

DROP VIEW IF EXISTS bonus_calc;

/* 3.10 Performing outer joins when using aggregates */

-- consider a different employee bonus table, below
DROP VIEW IF EXISTS v_emp_bonus;
CREATE VIEW v_emp_bonus AS
    SELECT 7934 AS empno, '2005-03-17' AS received, 1 AS type
    UNION ALL
    SELECT 7934, '2005-02-15', 2
;
SELECT * FROM v_emp_bonus;

-- Now find total of all bonuses and total of all salaries in dept 10
SELECT bonus_total,
    (SELECT SUM(sal) FROM emp WHERE deptno=10) AS salary_total
FROM (
    SELECT 
        SUM(e.sal * (eb.type/10)) AS bonus_total
    FROM emp e
    INNER JOIN v_emp_bonus eb
    ON eb.empno=e.empno
) x
;

/* A different example with a different bonus table.
In this case, there are rows for employees in different departments.
*/

SELECT 
    e.deptno,
    eb.*
FROM emp_bonus eb
LEFT JOIN emp e
ON e.empno=eb.empno
;

/*
+--------+-------+------------+------+
| deptno | EMPNO | RECEIVED   | TYPE |
+--------+-------+------------+------+
|     20 |  7369 | 2005-03-14 |    1 |
|     20 |  7369 | 2005-03-31 |    2 |
|     20 |  7788 | 2005-03-14 |    3 |
|     30 |  7900 | 2005-03-14 |    2 |
+--------+-------+------------+------+
*/

-- Calculate the total salary and the total bonus per department.
-- Each employee can have only one salary, but can have more than one bonus

SELECT 
    bonus_calc.deptno,
    bonus_calc.dept_bonus_total,
    (SELECT SUM(sal) FROM emp
    WHERE emp.deptno=bonus_calc.deptno) AS dept_salary_total
FROM (
SELECT
    e.deptno,
    COALESCE(SUM(e.sal * (eb.type/10)), 0) AS dept_bonus_total
FROM emp e
LEFT JOIN emp_bonus eb
ON eb.empno=e.empno
GROUP BY e.deptno
) bonus_calc
;

-- for verification, show dept salary total
SELECT 
    deptno,
    SUM(sal)
FROM emp
GROUP BY deptno
;

-- show bonus_total
SELECT
    e.deptno,
    COALESCE(SUM(e.sal * (eb.type/10)), 0) AS dept_bonus_total
FROM emp e
LEFT JOIN emp_bonus eb
ON eb.empno=e.empno
GROUP BY e.deptno
;

-- Add a column to table of bonus and salary totals
SELECT
    deptno,
    dept_bonus_total,
    dept_salary_total,
    dept_bonus_total + dept_salary_total AS dept_comp_total
FROM (
    SELECT 
        bonus_calc.deptno,
        bonus_calc.dept_bonus_total,
        (SELECT SUM(sal) FROM emp
        WHERE emp.deptno=bonus_calc.deptno) AS dept_salary_total
    FROM (
    SELECT
        e.deptno,
        COALESCE(SUM(e.sal * (eb.type/10)), 0) AS dept_bonus_total
    FROM emp e
    LEFT JOIN emp_bonus eb
    ON eb.empno=e.empno
    GROUP BY e.deptno
    ) bonus_calc
) comp_table
;

-- Note that adding a grand total row can't be done with 
-- a simple group by with rollup
-- For one, would require grouping by all columns
-- Secondly, that adds a subtotal row for each dept
-- The only solution would be to add a query that 
-- sums each column and then UNION it to the above query.



