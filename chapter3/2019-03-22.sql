/* Chapter 3 */

/* 3.9 Performing joins when using aggregates */

/*
SELECT e.empno,
	ename,
	SUM(sal) as sal,
	SUM(sal * ),

	(SELECT SUM(type)
	FROM emp_bonus eb
	WHERE eb.empno = e.empno) AS bonus
FROM emp e
GROUP BY 1, 2
;
*/

/* Note that for purposes of this problem an extra
entry was inserted for emp_bonus. Below shows state before
insert, what was inserted, and state after insert 

mysql> SELECT * FROM emp_bonus;
+-------+------------+------+
| EMPNO | RECEIVED   | TYPE |
+-------+------------+------+
|  7369 | 2005-03-14 |    1 |
|  7900 | 2005-03-14 |    2 |
|  7788 | 2005-03-14 |    3 |
+-------+------------+------+
3 rows in set (0.00 sec)

mysql> INSERT INTO emp_bonus VALUES (7369, '2005-03-31', 2);
Query OK, 1 row affected (0.01 sec)

mysql> SELECT * FROM emp_bonus;
+-------+------------+------+
| EMPNO | RECEIVED   | TYPE |
+-------+------------+------+
|  7369 | 2005-03-14 |    1 |
|  7900 | 2005-03-14 |    2 |
|  7788 | 2005-03-14 |    3 |
|  7369 | 2005-03-31 |    2 |
+-------+------------+------+
4 rows in set (0.01 sec)

*/

-- initial attempt at intermediate table
-- to calculate total sal and total bonus
-- for each employee
-- Note that dept 30 instead of dept 10 was used
-- because my emp_bonus table doesn't have any
-- employees from dept 10
SELECT e.empno,
	e.ename,
	e.sal,
	y.bonus_total
FROM emp e

LEFT JOIN (
	SELECT empno,
		SUM(bonus) as bonus_total 
	FROM
	(
		SELECT e.empno,
			e.sal,
			eb.type,
			e.sal * (eb.type/10) AS bonus
		FROM emp e
		INNER JOIN emp_bonus eb
		ON e.empno = eb.empno) x
	GROUP BY empno) y
ON y.empno = e.empno
WHERE e.deptno in (30)
;


