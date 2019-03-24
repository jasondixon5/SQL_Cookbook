-- Chapter 6, Working with Strings

-- /Users/jasondixon/Dropbox/Projects/SQL_Cookbook/chapter6.sql

/*

-- Solution uses t10 table; examine that table
select * from t10
;
-- table t10 has one column, values from 1 to 10

-- generate one row for each letter of string
SELECT ENAME, ITER.POS
FROM (
    SELECT ENAME FROM EMP
    WHERE ENAME = "KING") E,
    (SELECT ID AS POS FROM T10) ITER
;

-- limit results for each row to substring
SELECT SUBSTR(ENAME, ITER.POS, 1)
FROM
    (SELECT ENAME FROM EMP
    WHERE ENAME = "KING") E,
    (SELECT ID AS POS FROM T10) ITER
WHERE ITER.POS <= LENGTH(ENAME)
;

-- exploration of SUBSTRING()
-- SELECT SUBSTRING("KING",1,1) FROM EMP;
-- SELECT SUBSTRING("KING",2,1) FROM EMP;
-- SELECT SUBSTRING("KING",3,1) FROM EMP;


-- 6.3 Count number of characters in a string
select (length('10,CLARK,MANAGER') - 
length(replace('10,CLARK,MANAGER',',','')))/
length(',') as cnt
from t1;

-- 6.4, Remove unwanted characters

select ENAME, SAL
from EMP;

-- 6.8, order by last two characters in name
SELECT ENAME FROM EMP
ORDER BY SUBSTR(ENAME, LENGTH(ENAME)-1)
;



SELECT SUBSTR('ALLAN', LENGTH('ALLAN'));
SELECT SUBSTR('ALLAN', LENGTH('ALLAN')-1);
SELECT SUBSTR('ALLAN', LENGTH('ALLAN')-1, 2);

-- UNCLEAR WHY THIS 3RD EXAMPLE WORKS (WITH 3RD ARG TO SUBSTR)
WHEN THIS ERRORS OUT:

SELECT ENAME FROM EMP
ORDER BY SUBSTR(ENAME, LENGTH(ENAME)-1, 2)
;



-- 6.10

-- Addl practice
-- 6.1
SELECT ENAME FROM EMP
WHERE ENAME = "KING"
;

SELECT * FROM T10
;

SELECT ENAME, ID FROM EMP, T10
WHERE ENAME = "KING"
;

SELECT ENAME FROM EMP, T10
WHERE ENAME = "KING"
;


SELECT SUBSTR(ENAME, T10.ID, 1)
FROM EMP, T10
WHERE ENAME = "KING"
;

SELECT SUBSTR(ENAME, T10.ID, 1)
FROM EMP, T10
WHERE ENAME = "KING"
AND T10.ID <= LENGTH(ENAME)
;


-- TRY WITH TEMP TABLE (ASSUME NO TABLE T10 EXISTS)

CREATE TEMPORARY TABLE pivot_temp
(
    ID INT AUTO_INCREMENT,
    CONSTRAINT pk_id PRIMARY KEY (ID)
 )
;

INSERT INTO pivot_temp values ();
INSERT INTO pivot_temp values ();
INSERT INTO pivot_temp values ();
INSERT INTO pivot_temp values ();
INSERT INTO pivot_temp values ();
INSERT INTO pivot_temp values ();
INSERT INTO pivot_temp values ();
INSERT INTO pivot_temp values ();
INSERT INTO pivot_temp values ();
INSERT INTO pivot_temp values ();

-- select * from pivot_temp;

 SELECT SUBSTR(ENAME, pivot_temp.ID, 1)
FROM EMP, pivot_temp
WHERE ENAME = "KING"
AND pivot_temp.ID <= LENGTH(ENAME)
;

DROP TABLE pivot_temp
;


-- TRY WITH VAR AS TEMP TABLE AND SESSION VARIABLE
-- FIRST TEST SYNTAX TO CREATE TEMP TABLE
SET @ROW_NUM = 0;

SELECT (@ROW_NUM := @ROW_NUM + 1) AS NUM 
FROM EMP
LIMIT 10
;

-- THEN CREATE AND USE TEMP TABLE
SET @ROW_NUM = 0;

SELECT SUBSTR(ENAME, pivot_temp.ID, 1)
FROM EMP, 
(SELECT (@ROW_NUM := @ROW_NUM + 1) AS ID
FROM EMP
LIMIT 10) pivot_temp
WHERE ENAME = "KING"
AND pivot_temp.ID <= LENGTH(ENAME)
;


-- 6.3, COUNT CHARACTERS IN STRING

-- COUNT NUMBER OF COMMAS
SET @phrase = "10,CLARK,MANAGER";
SET @search_string = ",";

SELECT length(@phrase) - length(replace(@phrase,@search_string,"")) 
/ length(@search_string) cnt
;

-- 6.4 REPLACE CHARACTERS

-- SOLUTIONS ARE INTUITIVE BUT WANT TO EXPLORE SAL PORTION
-- LOOKS LIKE MYSQL WILL ALLOW 0 TO BE TRIMMED WITHOUT CONVERTING/
-- CASTING TO STRING FIRST
SELECT SAL, REPLACE(SAL, 0, '') FROM EMP;

-- WORKS WITH OTHER CHARACTERS?
-- YES
-- BUT NOT SURE HOW USEFUL THIS IS FOR NUMBERS
SELECT SAL, REPLACE(SAL, 5, '') FROM EMP;


-- what data type is trimmed sal col?
-- create temp table to examine
describe emp;
DROP TABLE IF EXISTS trim_sal;

CREATE TEMPORARY TABLE trim_sal
SELECT SAL, REPLACE(SAL, 5, '') FROM EMP;

DESCRIBE trim_sal
;
DROP TABLE trim_sal
;

-- answer: new trimmed sal col is varchar(11)
-- SO it appears mysql implicitly casted the return of the
-- replace function to a string for each row
-- can we get the same by explicit casting?

-- FIRST TEST CASTING
describe emp;
DROP TABLE IF EXISTS trim_sal;

CREATE TEMPORARY TABLE trim_sal
SELECT CAST(SAL AS CHAR)
FROM EMP;


DESCRIBE trim_sal
;
DROP TABLE IF EXISTS trim_sal
;

-- NOW COMBINE CASTING WITH REPLACING

DROP TABLE IF EXISTS trim_sal;

CREATE TEMPORARY TABLE trim_sal
SELECT REPLACE(CAST(SAL AS CHAR),'0','')
FROM EMP;

SELECT * FROM trim_sal
;
DESCRIBE trim_sal
;
DROP TABLE IF EXISTS trim_sal
;

-- NOW COMBINE INTO ORIGINAL QUERY
SELECT SAL, REPLACE(CAST(SAL AS CHAR), '0', '') FROM EMP;

-- NOT SURE EXPLICIT CASTING IS USEFUL, APART FROM
-- PRINCIPLE THAT EXPLICIT IS BETTER THAN IMPLICIT

-- 6.10

-- BOOK SOLUTION, WHICH DIDN'T WORK
-- SELECT DEPTNO, GROUP_CONCAT(ENAME ORDER BY EMPNO SEPARATOR, ",") AS EMPS
-- FROM EMP
-- GROUP BY DEPTNO
-- ;

-- THIS SOLUTION WORKED:

SELECT DEPTNO, GROUP_CONCAT(ENAME) AS EMPS
FROM EMP
GROUP BY DEPTNO;
*/
