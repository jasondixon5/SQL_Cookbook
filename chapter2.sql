/*



SELECT ENAME, SAL FROM EMP
WHERE DEPTNO IN (10)
    AND
    SAL IS NULL
;  

SELECT ENAME, JOB, SAL FROM EMP
WHERE DEPTNO IN (10)
ORDER BY SAL ASC
;

SELECT ENAME, JOB, SAL FROM EMP
WHERE DEPTNO IN (10)
ORDER BY 3 ASC
;

SELECT ENAME, EMPNO, DEPTNO, SAL, JOB FROM EMP
ORDER BY DEPTNO ASC, SAL DESC
;

SELECT ENAME, JOB, SUBSTR(JOB, -2) FROM EMP
ORDER BY SUBSTR(JOB, -2)
;

SELECT ENAME, JOB, SUBSTR(JOB, LENGTH(JOB)-1) FROM EMP
ORDER BY SUBSTR(JOB, LENGTH(JOB)-1)

-- NON NULLS DESCENDING, ALL NULLS LAST
SELECT ENAME, SAL, COMM 
FROM (
    SELECT ENAME, SAL, COMM, CASE
    WHEN COMM IS NULL THEN 0 ELSE 1 END AS IS_NULL
    FROM EMP
    ) X
ORDER BY IS_NULL DESC, COMM
;
-- NON NULLS ASCENDING, ALL NULLS LAST
SELECT ENAME, SAL, COMM 
FROM (
    SELECT ENAME, SAL, COMM, CASE
    WHEN COMM IS NULL THEN 0 ELSE 1 END AS IS_NULL
    FROM EMP
    ) X
ORDER BY IS_NULL DESC, COMM DESC
;

SELECT ENAME, SAL, JOB, COMM
FROM EMP
ORDER BY CASE 
    WHEN JOB = "SALESMAN" THEN COMM 
    ELSE SAL 
    END
*/