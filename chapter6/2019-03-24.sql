/* Chapter 6: Working with Strings */

/* Practice with MySQL string functions */

/* Convert first and last name to initials */

-- research how func substring_index works
/*
SELECT SUBSTRING_INDEX('www.mysql.com', '.',  1);
SELECT SUBSTRING_INDEX('www.mysql.com', '.', -1);
SELECT SUBSTRING_INDEX('www.mysql.com', '.',  2);
SELECT SUBSTRING_INDEX('www.mysql.com', '.', -2);
SELECT SUBSTRING_INDEX('www.mysql.com', '.',  3);
SELECT SUBSTRING_INDEX('www.mysql.com', '.', -3);
*/

/* 
+-------------------------------------------+
| SUBSTRING_INDEX('www.mysql.com', '.',  1) |
+-------------------------------------------+
| www                                       |
+-------------------------------------------+
1 row in set (0.00 sec)

+-------------------------------------------+
| SUBSTRING_INDEX('www.mysql.com', '.', -1) |
+-------------------------------------------+
| com                                       |
+-------------------------------------------+
1 row in set (0.00 sec)

+-------------------------------------------+
| SUBSTRING_INDEX('www.mysql.com', '.',  2) |
+-------------------------------------------+
| www.mysql                                 |
+-------------------------------------------+
1 row in set (0.00 sec)

+-------------------------------------------+
| SUBSTRING_INDEX('www.mysql.com', '.', -2) |
+-------------------------------------------+
| mysql.com                                 |
+-------------------------------------------+
1 row in set (0.00 sec)

+-------------------------------------------+
| SUBSTRING_INDEX('www.mysql.com', '.',  3) |
+-------------------------------------------+
| www.mysql.com                             |
+-------------------------------------------+
1 row in set (0.00 sec)

+-------------------------------------------+
| SUBSTRING_INDEX('www.mysql.com', '.', -3) |
+-------------------------------------------+
| www.mysql.com                             |
+-------------------------------------------+
1 row in set (0.00 sec)
*/

SET @name := "Emily Dickinson";

SELECT @name
;

-- separate names
SELECT SUBSTRING_INDEX(@name, ' ', 1),
	-- find space, return characters to right of it
	-- then in that set of chars, get first letter
	SUBSTRING_INDEX(@name, ' ', -1)
;

-- extract first character from each name
SELECT SUBSTRING(SUBSTRING_INDEX(@name, ' ', 1), 1, 1),
	SUBSTRING(SUBSTRING_INDEX(@name, ' ', -1), 1, 1)
;

-- combine into one string with names separated by a period
SELECT CONCAT_WS('.', 
		SUBSTRING(SUBSTRING_INDEX(@name, ' ', 1), 1, 1),
		SUBSTRING(SUBSTRING_INDEX(@name, ' ', -1), 1, 1)
		) AS initialized_name
;

-- add final period to string
SELECT CONCAT(
	CONCAT_WS('.', 
		SUBSTRING(SUBSTRING_INDEX(@name, ' ', 1), 1, 1),
		SUBSTRING(SUBSTRING_INDEX(@name, ' ', -1), 1, 1)
		), 
		'.'
		) AS initialized_name
;

/* 6.8 Ordering by parts of a string */

-- order by last two letters of employee name
SELECT ename,
	SUBSTRING(ename, -2, 2) AS last_two
FROM emp
ORDER BY SUBSTRING(ename, -2, 2)
;

-- above solution uses negative indexing to start two letters from end
-- book solution, below, determines index of second-to-last character
-- via the length func
SELECT ename,
	SUBSTRING(ename, LENGTH(ename)-1, 2) AS last_two
FROM emp
ORDER BY SUBSTRING(ename, LENGTH(ename)-1, 2)
;

/* 6.10 Creating a delimited list from table rows */
/* Uses mysql-specific group_concat() func */

-- get raw table results before aggregating with group_concat
SELECT deptno, ename FROM emp ORDER BY deptno, empno;

SELECT deptno,
	GROUP_CONCAT(ename order by empno) AS emps
FROM emp
GROUP BY deptno
;

