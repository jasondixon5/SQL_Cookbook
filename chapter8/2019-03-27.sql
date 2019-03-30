/* Chapter 8: Data Arithmetic */

/* 8.1 Adding and subtracting days, months, years */

-- Return following days in relation to hiredate for Clark
-- * 5 days before and after hired
-- * 5 months ~
-- * 5 years ~

SELECT HIREDATE,
    DATE_ADD(HIREDATE, INTERVAL 5 DAY) AS HIRE_AND_5D,
    DATE_ADD(HIREDATE, INTERVAL 5 MONTH) AS HIRE_AND_5M,
    DATE_ADD(HIREDATE, INTERVAL 5 YEAR) AS HIRE_AND_5Y
FROM emp
WHERE ename IN ("CLARK")
;

/* MySQL also supports the '+' and '-' operators used in conj
with "INTERVAL n unit" syntax. Also note that SQL Server 
accomplishes this action via the DATEADD() function
with the syntax DATEADD(unit, n, value_to_change) 
where n can be positive or negative to accomplish addition
or subtraction, respectively. */

-- alternate MySQL syntax
SELECT HIREDATE,
    HIREDATE + INTERVAL 5 DAY AS HIRE_AND_5D,
    HIREDATE + INTERVAL 5 MONTH AS HIRE_AND_5M,
    HIREDATE + INTERVAL 5 YEAR AS HIRE_AND_5Y
FROM emp
WHERE ename IN ("CLARK")
;

/* 8.2 Determining number of days between two dates */

-- Find difference in days between hire dates of empls Allen and Ward
SET @hire_date1 = (SELECT hiredate FROM emp WHERE ename = "ALLEN");
SET @hire_date2 = (SELECT hiredate FROM emp WHERE ename = "WARD");

SELECT ABS(DATEDIFF(@hire_date1, @hire_date2)) AS days_apart_hired__vars
;

-- can also solve with inline views (book solution)

SELECT ABS(DATEDIFF(hd_allen, hd_ward)) AS days_apart_hired__inline
FROM (
    SELECT hiredate AS hd_allen
    FROM emp
    WHERE ename = "ALLEN"
) x,
(
    SELECT hiredate AS hd_ward
    FROM emp
    WHERE ename = "WARD"
) y
;

/* 8.3 Determining the number of business days between two days */

-- Find number of business days between the 
-- hire date of Blake and the hire date of Jones
-- Note that this requires a pivot table that has
-- enough rows to do a join on

-- validate hiredates
SELECT hiredate AS hd_blake FROM emp WHERE ename = "BLAKE";
SELECT hiredate AS hd_jones FROM emp WHERE ename = "JONES";

-- diff between dates is less than 100 days, so can use T100

-- get hiredates and # calendar days diff between them
SELECT hd_blake,
        hd_jones,
        ABS(DATEDIFF(hd_blake, hd_jones)) AS days_diff
FROM (
SELECT 
    MAX(CASE WHEN ename = "BLAKE" THEN hiredate END) AS hd_blake,
    MAX(CASE WHEN ename = "JONES" THEN hiredate END) AS hd_jones
FROM emp) x
;

-- add columns for t100.id (i.e., days to add to first hiredate),
-- day of week (1=Sunday, 7=Saturday), and whether new date is weekday
SELECT hd_blake,
        hd_jones,
        ABS(DATEDIFF(hd_blake, hd_jones)) AS days_diff,
        t100.id,
        DAYOFWEEK(DATE_ADD(hd_jones, INTERVAL t100.id DAY)) AS added_date_dow,
        CASE WHEN DAYOFWEEK(DATE_ADD(hd_jones, INTERVAL t100.id DAY)) IN (1, 7)
            THEN 0
            ELSE 1 END AS is_weekday 
FROM (
SELECT 
    MAX(CASE WHEN ename = "BLAKE" THEN hiredate END) AS hd_blake,
    MAX(CASE WHEN ename = "JONES" THEN hiredate END) AS hd_jones
FROM emp) x, t100
WHERE t100.id <= ABS(DATEDIFF(hd_blake, hd_jones)) + 1 
;

-- sum of is_weekday column is number of business days between the two dates
SELECT SUM(is_weekday)AS num_business_days
FROM (
SELECT hd_blake,
        hd_jones,
        ABS(DATEDIFF(hd_blake, hd_jones)) AS days_diff,
        t100.id,
        DAYOFWEEK(DATE_ADD(hd_jones, INTERVAL t100.id DAY)) AS added_date_dow,
        CASE WHEN DAYOFWEEK(DATE_ADD(hd_jones, INTERVAL t100.id DAY)) IN (1, 7)
            THEN 0
            ELSE 1 END AS is_weekday 
FROM (
SELECT 
    MAX(CASE WHEN ename = "BLAKE" THEN hiredate END) AS hd_blake,
    MAX(CASE WHEN ename = "JONES" THEN hiredate END) AS hd_jones
FROM emp) x, t100
WHERE t100.id <= ABS(DATEDIFF(hd_blake, hd_jones)) + 1 
) y
;

