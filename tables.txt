DROP TABLE IF EXISTS EMP;

CREATE TABLE EMP
       (EMPNO integer NOT NULL,
        ENAME VARCHAR(10),
        JOB VARCHAR(9),
        MGR integer,
        HIREDATE DATE,
        SAL integer,
        COMM integer,
        DEPTNO integer)
;

DROP TABLE IF EXISTS DEPT;
CREATE TABLE DEPT
       (DEPTNO integer,
        DNAME VARCHAR(14),
        LOC VARCHAR(13) )
;
        
DROP TABLE IF EXISTS T1;
CREATE TABLE T1 (ID INTEGER);

DROP TABLE IF EXISTS T10;
CREATE TABLE T10 (ID INTEGER);

DROP TABLE IF EXISTS T100;
CREATE TABLE T100 (ID INTEGER);

DROP TABLE IF EXISTS EMP_BONUS;
CREATE TABLE EMP_BONUS (EMPNO integer,
                        RECEIVED DATE, 
                        TYPE integer);