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

*/

-- 6.10
