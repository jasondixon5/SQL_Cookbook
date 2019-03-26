/* Chapter 6: Working with Strings */

/* 6.1 Walking a String */

-- Put each letter of empl name 'KING' on its own row

-- repeat name n times
SELECT e.ename
FROM emp e, T10 -- T10 is has one column, ID, going from 1 to 10
WHERE e.ename in ("KING")
AND T10.id <= LENGTH(e.ename)
;

-- substring name to get only letter
SELECT e.ename,
	SUBSTRING(e.ename, T10.ID, 1) AS letter 
-- T10 is has one column, ID, going from 1 to 10
FROM emp e, T10
WHERE e.ename in ("KING")
AND T10.id <= LENGTH(e.ename)
;

-- book solution
-- same in substance but slightly different in style
SELECT SUBSTRING(e.ename, iter.pos, 1) AS C
FROM (SELECT ename FROM emp WHERE ename = "KING") e,
	(SELECT id AS pos FROM t10) iter
WHERE iter.pos <= LENGTH(e.ename)
;

-- now walk the string backwards
/*
1 -> 4
2 -> 3
3 -> 2
4 -> 1

4 = 4-0, 3-(-1)
3 = 4-1, 3-0
2 = 4-2, 3-1
1 = 4-3, 3-2
*/

SELECT e.ename,
	SUBSTRING(e.ename, LENGTH(e.ename)-T10.ID+1, 1) AS letter 
-- T10 is has one column, ID, going from 1 to 10
FROM emp e, T10
WHERE e.ename in ("KING")
AND T10.id <= LENGTH(e.ename)
;

/* 6.2 Embedding quotes within string literals */

-- produce the following strings
-- g'day mate
-- beavers' teeth
-- '
-- ''

SELECT 'g''day mate',
	'beavers'' teeth',
	'''',
	''''''
;

-- Side experiment
-- Test null value of empty strings in MySQL
SELECT '' IS NULL,
	NULL IS NULL,
	'''' IS NULL,
	'''''' IS NULL
;
/* Results of above query:
+------------+--------------+--------------+----------------+
| '' IS NULL | NULL IS NULL | '''' IS NULL | '''''' IS NULL |
+------------+--------------+--------------+----------------+
|          0 |            1 |            0 |              0 |
+------------+--------------+--------------+----------------+

*/

/* So it seems that book's statement that "a string literal comprising
two quotes alone, with no intervening characters, is NULL" is not actually
correct for MySQL v5. In doing research on this found a reference on
Stack Overflow that in Oracle it is NULL, so perhaps this only applies
to MySQL or book statement meant to only apply to Oracle.
*/

/* Side question: 
While researching empty strings and nulls, also found SO posts on
how NULLS are stored and their efficiency/space costs. Made me
wonder how to see what engine I'm running on MySQL, so found
this query. */ 

SELECT TABLE_NAME,
       ENGINE
FROM   information_schema.TABLES
WHERE  TABLE_SCHEMA = 'sql_cookbook';

/* 6.3 Counting occurrenses of a character in a string */

-- Find out how many commas are in the string '10,CLERK,MANAGER'
SET @phrase = '10,CLERK,MANAGER';

SELECT @phrase;

-- technique is to subtract length of string without commas
-- from length of string with commas
SELECT @phrase AS original_phrase,
	LENGTH(@phrase) AS phrase_length,
	LENGTH(@phrase) - LENGTH(REPLACE(@phrase, ',', '')) AS cnt_commas
;

-- NOTE that above technique only works if string you're searching for
--  (in the above case, a comma) has a length of 1. 
-- If it could have a length > 1 (e.g., "LL") extra step is needed.
-- Divide cnt above by length of string you're searching for

SET @phrase = "HELLO, DOLLY";
SET @string_to_count = "LL";

SELECT @phrase AS original_phrase,
	LENGTH(@phrase) AS phrase_length,
	@string_to_count AS search_string,
	LENGTH(@string_to_count) AS search_str_length,
	(LENGTH(@phrase) - LENGTH(REPLACE(@phrase, @string_to_count, ''))) / LENGTH(@string_to_count) AS cnt_string_instances 
;

/* 6.4 Removing unwanted characters from a string */

-- use replace to remove vowels 
SELECT ename,
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ename, 'A', ''), 'E', ''), 'I', ''), 'O', ''), 'U', '') AS stripped_ename
FROM emp
;

-- use replace to remove 0's from number stored as string
SELECT sal,
	REPLACE(sal, '0', '') AS stripped_sal
FROM emp
;

/* 6.5 Separating numeric and character data */

/* No MySQL or SQL Server solution */

/* 6.6 Determining whether a string is alphanumeric */

-- return rows from a table only when a column contains
-- only numbers and letters

-- view given in book will be built as inline view

SELECT ename as data
FROM emp
WHERE deptno=10
UNION ALL
SELECT CONCAT(ename, ', $', sal, '.00') AS data
FROM emp
WHERE deptno=20
UNION ALL
SELECT CONCAT(ename, deptno) AS data
FROM emp
WHERE deptno=30
;

/* MySQL Solution uses regular expressions */

SELECT * FROM (
	SELECT ename as data
	FROM emp
	WHERE deptno=10
	UNION ALL
	SELECT CONCAT(ename, ', $', sal, '.00') AS data
	FROM emp
	WHERE deptno=20
	UNION ALL
	SELECT CONCAT(ename, deptno) AS data
	FROM emp
	WHERE deptno=30
) v
WHERE data regexp '[^0-9a-zA-Z]' = 0
;

/* See what regexp is doing */

SELECT data,
	data regexp '[^0-9a-zA-Z]' AS reg_has_any_non_alphanum,
	data regexp '[0-9a-zA-Z]' AS reg_has_any_alphanum
FROM (
	SELECT ename as data
	FROM emp
	WHERE deptno=10
	UNION ALL
	SELECT CONCAT(ename, ', $', sal, '.00') AS data
	FROM emp
	WHERE deptno=20
	UNION ALL
	SELECT CONCAT(ename, deptno) AS data
	FROM emp
	WHERE deptno=30
) v
;

/* Note following from MySQL docum which is relevant to results of 
column 'reg_has_any_non_alphanum' above:

"Because a regular expression pattern matches if it occurs anywhere in the value,
it is not necessary...to put a wildcard on either side of the pattern to get it 
to match the entire value as would be true with an SQL pattern."
https://dev.mysql.com/doc/refman/5.7/en/pattern-matching.html
*/

/* Implement the SQL Server solution, which can also work in 
MySQL if you don't want to use the regexp feature.

From book: "Because SQL Server does not support a TRANSLATE function,
you must walk each row and find any that contains a character that 
contains a non-alphanumeric value. That can be done many ways, but
the following solution uses an ASCII-value evaluation."

Note that 'walking each row' in this case means repeating the rows
by doing a cartesian product.
*/

SELECT data
FROM (
	SELECT v.data,
		iter.pos,
		substring(v.data, iter.pos, 1) c,
		ascii(substring(v.data, iter.pos, 1)) val
	FROM (
		SELECT ename as data
		FROM emp
		WHERE deptno=10
		UNION ALL
		SELECT CONCAT(ename, ', $', sal, '.00') AS data
		FROM emp
		WHERE deptno=20
		UNION ALL
		SELECT CONCAT(ename, deptno) AS data
		FROM emp
		WHERE deptno=30
	) v,
	(SELECT id AS pos FROM t100) iter
	WHERE iter.pos <= LENGTH(v.data)) x
GROUP BY data
HAVING MIN(val) BETWEEN 48 and 122
;

/* explore what SQL Solution is doing */

SELECT 	ASCII('$'),
	ASCII(','), 
	ASCII('0'),
	ASCII('9'),
	ASCII('A'),
	ASCII('Z'),
	ASCII('a'),
	ASCII('z')
;

SELECT * FROM (
		SELECT ename as data
		FROM emp
		WHERE deptno=10
		UNION ALL
		SELECT CONCAT(ename, ', $', sal, '.00') AS data
		FROM emp
		WHERE deptno=20
		UNION ALL
		SELECT CONCAT(ename, deptno) AS data
		FROM emp
		WHERE deptno=30
		) v,
		(SELECT id AS pos FROM t100) iter
;

-- the following query gives a row for each character in each row in v
SELECT * FROM (
		SELECT ename as data
		FROM emp
		WHERE deptno=10
		UNION ALL
		SELECT CONCAT(ename, ', $', sal, '.00') AS data
		FROM emp
		WHERE deptno=20
		UNION ALL
		SELECT CONCAT(ename, deptno) AS data
		FROM emp
		WHERE deptno=30
		) v,
		(SELECT id AS pos FROM t100) iter
WHERE iter.pos <= LENGTH(v.data)
ORDER BY data, pos;

-- add a column for the character at the index matching position i
-- also add a column to get that character's ascii value

SELECT *,
	SUBSTRING(v.data, iter.pos, 1) char_at_i,
	ASCII(SUBSTRING(v.data, iter.pos, 1))
FROM (
		SELECT ename as data
		FROM emp
		WHERE deptno=10
		UNION ALL
		SELECT CONCAT(ename, ', $', sal, '.00') AS data
		FROM emp
		WHERE deptno=20
		UNION ALL
		SELECT CONCAT(ename, deptno) AS data
		FROM emp
		WHERE deptno=30
		) v,
		(SELECT id AS pos FROM t100) iter
WHERE iter.pos <= LENGTH(v.data)
ORDER BY data, pos;

/* Last step is to filter, via HAVING(), for ASCII values between 48 and 122 */

/* first attempt, below, resulted in just the special characters being filtered out */

SELECT * FROM (

	SELECT *,
	SUBSTRING(v.data, iter.pos, 1) char_at_i,
	ASCII(SUBSTRING(v.data, iter.pos, 1)) ascii_value_of_char
FROM (
		SELECT ename as data
		FROM emp
		WHERE deptno=10
		UNION ALL
		SELECT CONCAT(ename, ', $', sal, '.00') AS data
		FROM emp
		WHERE deptno=20
		UNION ALL
		SELECT CONCAT(ename, deptno) AS data
		FROM emp
		WHERE deptno=30
		) v,
		(SELECT id AS pos FROM t100) iter
WHERE iter.pos <= LENGTH(v.data)) x

GROUP BY 1, 2, 3
HAVING MIN(ascii_value_of_char) BETWEEN 48 AND 122
;

SELECT data FROM (

	SELECT *,
	SUBSTRING(v.data, iter.pos, 1) char_at_i,
	ASCII(SUBSTRING(v.data, iter.pos, 1)) ascii_value_of_char
FROM (
		SELECT ename as data
		FROM emp
		WHERE deptno=10
		UNION ALL
		SELECT CONCAT(ename, ', $', sal, '.00') AS data
		FROM emp
		WHERE deptno=20
		UNION ALL
		SELECT CONCAT(ename, deptno) AS data
		FROM emp
		WHERE deptno=30
		) v,
		(SELECT id AS pos FROM t100) iter
WHERE iter.pos <= LENGTH(v.data)) x

GROUP BY data
HAVING MIN(ascii_value_of_char) BETWEEN 48 AND 122
;

