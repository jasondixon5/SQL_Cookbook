/* Ch 3: Mult Tables */

/* Practice with finding values and rows 
in one table not in another table */

DROP TABLE IF EXISTS new_dept;

CREATE TABLE new_dept(deptno integer);

INSERT INTO new_dept VALUES (10);
INSERT INTO new_dept VALUES (50);
INSERT INTO new_dept VALUES (NULL);

/* View new_dept */
SELECT * FROM new_dept;
/* View regular dept table */
SELECT * FROM dept;

/* Find departments in dept that aren't in new_dept */

-- using NOT IN

SELECT * FROM dept d
WHERE deptno NOT IN (
    SELECT deptno FROM new_dept nd
)
;
/* Result:
Empty set */

SELECT * FROM dept d
WHERE deptno NOT IN (
    SELECT deptno FROM new_dept nd
    WHERE nd.deptno = d.deptno
)
;
/* Result:
+--------+------------+---------+
| DEPTNO | DNAME      | LOC     |
+--------+------------+---------+
|     20 | RESEARCH   | DALLAS  |
|     30 | SALES      | CHICAGO |
|     40 | OPERATIONS | BOSTON  |
+--------+------------+---------+
*/

-- using NOT EXISTS

SELECT * FROM dept d
WHERE NOT EXISTS (
    SELECT 1 FROM new_dept nd
    WHERE nd.deptno = d.deptno
)
;
/*Result:

+--------+------------+---------+
| DEPTNO | DNAME      | LOC     |
+--------+------------+---------+
|     20 | RESEARCH   | DALLAS  |
|     30 | SALES      | CHICAGO |
|     40 | OPERATIONS | BOSTON  |
+--------+------------+---------+
*/

/* Another approach that discards nulls */

SELECT d.* FROM dept d
WHERE d.deptno NOT IN (
    SELECT nd.deptno
    FROM new_dept nd
    WHERE nd.deptno IS NOT NULL
)
;
/* Result:
--------+------------+---------+
| DEPTNO | DNAME      | LOC     |
+--------+------------+---------+
|     20 | RESEARCH   | DALLAS  |
|     30 | SALES      | CHICAGO |
|     40 | OPERATIONS | BOSTON  |
+--------+------------+---------+
*/

-- find rows in dept that 
-- are not in emp

-- traditional solution

SELECT d.*
FROM dept d
LEFT JOIN emp e
ON e.deptno = d.deptno
WHERE e.deptno IS NULL
;

-- try with NOT EXISTS keyword

SELECT d.*
FROM dept d
WHERE NOT EXISTS (
    SELECT e.deptno FROM emp e
    WHERE e.deptno = d.deptno
)
;