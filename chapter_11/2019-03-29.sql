/* Chapter 11: Advanced Searching */

/* 11.1 Paginating Through a Result Set */

-- return first five salaries from table EMP, then next 5, etc.

SELECT ename, sal
FROM emp
LIMIT 5 OFFSET 0
;

SELECT ename, sal
FROM emp
LIMIT 5 OFFSET 5
;

SELECT ename, sal
FROM emp
LIMIT 5 OFFSET 10
;

SELECT ename, sal
FROM emp
LIMIT 5 OFFSET 15
;

/* Write solution without use of OFFSET keyword
(akin to SQL Server)
*/

SELECT e.ename,
        e.sal,
        COUNT(*) as row_num
FROM emp e
INNER JOIN emp e2
ON e2.empno <= e.empno
GROUP BY e.ename, e.sal
ORDER BY 2
;

SELECT ename,
        sal
FROM (

    SELECT e.ename,
            e.sal,
            COUNT(*) as row_num
    FROM emp e
    INNER JOIN emp e2
    ON e2.empno <= e.empno
    GROUP BY e.ename, e.sal
    ORDER BY 2) x
WHERE row_num BETWEEN 1 AND 6
;

SELECT ename,
        sal
FROM (
    SELECT e.ename,
            e.sal,
            COUNT(*) as row_num
    FROM emp e
    INNER JOIN emp e2
    ON e2.empno <= e.empno
    GROUP BY e.ename, e.sal
    ORDER BY 2) x
WHERE row_num BETWEEN 7 AND 12
;

/* Now mimic original order of table by
assigning a row number based on original order */

SET @row_number = 0;

SELECT ename,
        sal
FROM (
SELECT e.ename,
        e.sal,
        (@row_number := @row_number + 1) AS row_num
FROM emp e) x
WHERE row_num BETWEEN 1 and 5
;

/* 11.2 Skipping n Rows From a Table */

-- return 1st, 3rd, 5th, etc. rows from table

-- Assign row numbers
-- Then return each odd row by using modulo operator
SET @row_number = 0;

SELECT ename,
        sal,
        row_num
FROM (
SELECT e.ename,
        e.sal,
        (@row_number := @row_number + 1) AS row_num
FROM emp e) x
WHERE mod(row_num, 2) != 0
;

-- return every 3rd row starting from row 3
SET @row_number = 0;

SELECT ename,
        sal,
        row_num
FROM (
SELECT e.ename,
        e.sal,
        (@row_number := @row_number + 1) AS row_num
FROM emp e) x
WHERE mod(row_num, 3) = 0
;

-- return every 4th row starting from first row
-- Necessitates changing row # to 0 so return rows 0, 4, 8, 12, ...
SET @row_number = -1;

SELECT ename,
        sal,
        row_num
FROM (
SELECT e.ename,
        e.sal,
        (@row_number := @row_number + 1) AS row_num
FROM emp e) x
WHERE mod(row_num, 4) = 0
;

/* 11.3 Incorporating OR Logic When Using Outer Joins */

-- return name and dept info for all employees in 
-- depts 10 and 20 and dept info for depts 30 and
-- 40 (but no employee info)

-- my take on book solution 
SELECT ename,
        d.deptno,
        dname,
        loc
FROM dept d
LEFT OUTER JOIN emp e
ON 
    (e.deptno = d.deptno
    AND (e.DEPTNO IN (10, 20))
    )
ORDER BY d.deptno;

-- book solution
SELECT ename,
        d.deptno,
        dname,
        loc
FROM dept d
LEFT OUTER JOIN emp e
ON 
    (e.deptno = d.deptno
    AND (e.DEPTNO=10 OR e.DEPTNO=20))
ORDER BY d.deptno;

-- alternate book solution, using inline view
SELECT e.ename,
    d.deptno,
        d.dname,
        d.loc
FROM dept d
LEFT JOIN 
    (SELECT ename, deptno
    FROM emp
    WHERE deptno in (10, 20)
    ) e ON (e.deptno = d.deptno)
ORDER BY 2
;

/* 11.4 Finding rows that are reciprocals */

-- not done but understand solution
-- may need to practice it

/* 11.5 Selecting the top n Records */

/* Limit result set based on some sort of ranking */

-- return names and salaries of the employees 
-- with the top 5 salaries
-- Note: This can mean return the first 5 employees
-- (wherein tied employees would both be part of the 5)
-- or the first 5 salaries (wherein tied employees would
-- only have their salary appear once)

-- Return top 5 employees' salaries
SELECT rnk,
        sal
FROM (
    SELECT (SELECT COUNT(DISTINCT e2.sal)
    FROM emp e2
    WHERE e.sal <= e2.sal) AS rnk,
    e.sal
    FROM emp e
) x
ORDER BY rnk
;

-- exploration of solution

SELECT sal,
        (SELECT COUNT(e2.sal) FROM emp e2
        WHERE e2.sal <= e.sal) rnk
FROM emp e
GROUP BY sal
ORDER BY 2
;

SELECT sal,
        (SELECT COUNT(e2.sal) FROM emp e2
        WHERE e.sal <= e2.sal) rnk
FROM emp e
GROUP BY sal
ORDER BY 2
;

SELECT sal,
        (SELECT COUNT(*) FROM emp e2
        WHERE e2.sal <= e.sal) rnk
FROM emp e
GROUP BY sal
ORDER BY 2
;

SELECT sal,
        (SELECT COUNT(*) FROM emp e2
        WHERE e2.sal <= e.sal) rnk
FROM emp e
GROUP BY sal, empno
ORDER BY 2
;

/* Result of query immediately above:
+------+------+
| sal  | rnk  |
+------+------+
|  800 |    1 |
|  950 |    2 |
| 1100 |    3 |
| 1250 |    5 |
| 1250 |    5 |
| 1300 |    6 |
| 1500 |    7 |
| 1600 |    8 |
| 2450 |    9 |
| 2850 |   10 |
| 2975 |   11 |
| 3000 |   13 |
| 3000 |   13 |
| 5000 |   14 |
+------+------+

*/

/* 
After some exploration, determined the reason it skips (e.g., going
from 3 to 5). There is 1 salary <= the lowest salary of 800; there are three
salaries <= 1100 (i.e., 800, 950, and 1100); but, there are five
salaries (unique entries in the table) <= 1250 (i.e., 800, 950,
1100, **and then two entries (rows) of 1250**). 

So have to add the DISTINCT keyword when counting to only count any
entries with the same salary as one when calculating the count of salaries
<= each row's sal. See below.
*/

SELECT e.ename,
        e.sal,
        (SELECT COUNT(DISTINCT sal)
        FROM emp e2
        WHERE e2.sal <= e.sal) AS rnk
FROM emp e
ORDER BY 2
;
/* Results of above query:

+--------+------+
| ename  | rnk  |
+--------+------+
| SMITH  |    1 |
| JAMES  |    2 |
| ADAMS  |    3 |
| WARD   |    4 |
| MARTIN |    4 |
| MILLER |    5 |
| TURNER |    6 |
| ALLEN  |    7 |
| CLARK  |    8 |
| BLAKE  |    9 |
| JONES  |   10 |
| FORD   |   11 |
| SCOTT  |   11 |
| KING   |   12 |
+--------+------+
*/

-- now return top 5 salaries, wherein if two employees
-- have same salary, it's only counted once. So there will
-- be returned 5 unique salaries

SELECT DISTINCT sal as top_salaries
FROM (
SELECT e.ename,
        e.sal,
        (SELECT COUNT(DISTINCT sal)
        FROM emp e2
        WHERE e2.sal <= e.sal) AS rnk
FROM emp e
ORDER BY 2 DESC) x
LIMIT 5;

/* 11.6 Find records with highest and lowest values */

-- find highest and lowest salaries in table emp

SELECT ename,
        sal
FROM emp
WHERE sal in (
        (SELECT MAX(sal) FROM emp),
        (SELECT MIN(sal) FROM emp)
)
;

