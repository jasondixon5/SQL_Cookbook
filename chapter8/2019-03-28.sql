/* Chapter 8: Date Arithmetic */

/* 8.4 Determining number of months or years between two dates. */

-- Find months between first and last hire date in emp table

SELECT MIN(hiredate),
    MAX(hiredate)
FROM emp
;

SELECT MIN(hiredate),
    MAX(hiredate),
    TIMESTAMPDIFF(YEAR, MIN(hiredate), MAX(hiredate)) AS diff_years,
    TIMESTAMPDIFF(MONTH, MIN(hiredate), MAX(hiredate)) AS diff_months
FROM emp
;

/* Exact solution depends on how the years and months should be counted
Different solutions will be inclusive or exclusive,
e.g., 2013-2010 could be interpreted as 3 years or 2 depending on
whether to count first year.
*/

SELECT 
     (YEAR(hd_max) - YEAR(hd_min))*12 
      + (MONTH(hd_max) - MONTH(hd_min)) AS mnths_diff,
     ((YEAR(hd_max) - YEAR(hd_min))*12 
      + (MONTH(hd_max) - MONTH(hd_min))) 
      / 12 AS years_diff
FROM (
    SELECT MIN(hiredate) AS hd_min,
        MAX(hiredate) AS hd_max
    FROM emp) x
;
/* The technique of calculating month(end) - month(start) and adding
that to (number of years * 12) is specific to MySQL.

Note that SQL Server can calculate months directly via:
DATEDIFF(MONTH,hd_min,hd_max).
To get years, divide result by 12.

For MySQL, below is an explanation of why offsetting 
by (month(end) - month(start)) works.

Ideally, would only add the full years and then add, for the partial years, 
the months after the start date and the months up to and including the end date.

However, can't limit it to just adding the full years. It will count the year of 
the end date as 12 months.

This limitation means that without the adjustment, the months will be overstated 
by the months between the end date and the last month of its year AND
understated by the months between the start date and the end of its year.

Subtracting the month of the start date from the month of the end date 
(month(end) - month(start)) results in the difference between 12 and the 
number of months in the partial years. This matches the number of months 
to offset that extra full year for the end date.

For example, if start date = 12/1980 and end date = 01/1983, want to count 
1981 and 1982 as two years + the relevant months in the beginning and ending year.
Subtracting 1983-1980 yields 3 full years, however, not 2. So when multiply that 
times 12 months in a year, left with 36 months.

The correct number of months is 25. Subtracting 1 - 12 yields 11, 
which when added to 36 yields 25. 
*/

/* 8.5 Determining number of seconds, minutes, or hours between two dates. */

-- Find diff between hiredates of ALLEN and WARD in seconds, minutes, and hours.

-- extract dates and calculate diff in days
SELECT ward_hd,
        allen_hd,
        DATEDIFF(ward_hd, allen_hd) diff_ward_allen,
        DATEDIFF(allen_hd, ward_hd) diff_allen_ward
FROM (
SELECT MAX(CASE WHEN ename = "WARD" THEN hiredate END) as ward_hd,
    MAX(CASE WHEN ename = "ALLEN" THEN hiredate END) as allen_hd
FROM emp
) x
;

-- extract dates and calculate diff in seconds, minutes, and hours
SELECT ward_hd,
        allen_hd,
        DATEDIFF(ward_hd, allen_hd) * 24 diff_hrs,
        DATEDIFF(ward_hd, allen_hd) * 24 * 60 diff_minutes,
        DATEDIFF(ward_hd, allen_hd) * 24 * 60 * 60 diff_seconds
FROM (
SELECT MAX(CASE WHEN ename = "WARD" THEN hiredate END) as ward_hd,
    MAX(CASE WHEN ename = "ALLEN" THEN hiredate END) as allen_hd
FROM emp
) x
;

/* 8.6 Counting the occurrences of each day of week in a year */

/* 
Solution involves:
- generating all possible dates in a year
- formatting dates to get name/number of day of week
- counting occurrences of each name/number
*/

-- Use current year and get count of each day of week in year
SET @current_year = (SELECT YEAR(NOW()));

SET @days_in_current_year = (SELECT DATEDIFF(MAKEDATE(@current_year+1, 1), 
                MAKEDATE(@current_year, 1)) AS days_in_year);

SELECT @days_in_current_year;

-- book solution uses T500 table which has 500 rows
-- I only have T100 which has 100 rows.
-- So create new table using variables

SET @row_num = -1;

SELECT (@row_num := @row_num + 1) AS num
FROM T100, T100 t2
WHERE @row_num < (@days_in_current_year); 
/*
SELECT DATE_ADD(MAKEDATE(@current_year, 1), INTERVAL num DAY) AS incr_date
FROM (
SELECT (@row_num := @row_num + 1) AS num
FROM T100, T100 t2
WHERE @row_num < (@days_in_current_year)
) x
; 
*/
SELECT DATE_ADD(MAKEDATE(@current_year, 1), INTERVAL 1 DAY) AS incr_date
FROM t100
;

SET @row_num = -1;

SELECT num
FROM
(SELECT (@row_num := @row_num + 1) AS num
FROM T100, T100 t2
WHERE @row_num < ((@days_in_current_year) - 1)
) x;
 
SET @row_num = -1;

SELECT dow, 
        COUNT(*)
FROM 
(SELECT DATE_FORMAT(incr_date, '%a') AS dow
FROM
(
SELECT DATE_ADD(MAKEDATE(@current_year, 1), INTERVAL num DAY) AS incr_date
FROM
(SELECT (@row_num := @row_num + 1) AS num
FROM T100, T100 t2
WHERE @row_num < ((@days_in_current_year) - 1)
) x) y) z
GROUP BY dow
;

 -- clean up and consolidate so can do an order by DAYOFWEEK()
 SET @row_num = -1;

SELECT dow, 
        COUNT(*) AS count_of_dow
FROM 
(
SELECT DATE_ADD(MAKEDATE(@current_year, 1), INTERVAL num DAY) AS incr_date,
        DATE_FORMAT(
            DATE_ADD(
                MAKEDATE(
                    @current_year, 1), INTERVAL num DAY), '%a') AS dow
FROM
(SELECT (@row_num := @row_num + 1) AS num
FROM T100, T100 t2
WHERE @row_num < ((@days_in_current_year) - 1)
) x) y
GROUP BY dow, DAYOFWEEK(incr_date)
ORDER BY DAYOFWEEK(incr_date)
;
/* Results of above query:
+------+--------------+
| dow  | count_of_dow |
+------+--------------+
| Sun  |           52 |
| Mon  |           52 |
| Tue  |           53 |
| Wed  |           52 |
| Thu  |           52 |
| Fri  |           52 |
| Sat  |           52 |
+------+--------------+
*/

/* 8.7 Determining date diff between current record and next one */

-- find diff between day empl hired and day next empl was hired

-- first find hire date and next hire date for each employee
SELECT hiredate
       , (SELECT MIN(hiredate)
        FROM emp e2 WHERE e2.hiredate > e.hiredate) AS next_hire_hd
FROM emp e
ORDER BY hiredate
;

-- now use dates to calculate difference
SELECT empno,
    ename,
    deptno,
    hiredate,
    next_hire_hd,
        DATEDIFF(next_hire_hd, hiredate) AS days_till_next_hire
FROM (
SELECT empno
        , ename
        , deptno
        , hiredate
       , (SELECT MIN(hiredate)
        FROM emp e2 WHERE e2.hiredate > e.hiredate) AS next_hire_hd
FROM emp e
ORDER BY hiredate
) x
;

-- now filter for only employees in dept 10 per book's original problem descr
SELECT empno,
    ename,
    deptno,
    hiredate,
    next_hire_hd,
        DATEDIFF(next_hire_hd, hiredate) AS days_till_next_hire
FROM (
SELECT empno
        , ename
        , deptno
        , hiredate
       , (SELECT MIN(hiredate)
        FROM emp e2 WHERE e2.hiredate > e.hiredate) AS next_hire_hd
FROM emp e
WHERE deptno in (10)
ORDER BY hiredate
) x
;

-- now also filter next hire dates by dept (not part of book problem description)
SELECT empno,
    ename,
    deptno,
    hiredate,
    next_hire_hd,
        DATEDIFF(next_hire_hd, hiredate) AS days_till_next_hire
FROM (
SELECT empno
        , deptno
        , ename
        , hiredate
       , (SELECT MIN(hiredate)
        FROM emp e2 WHERE e2.hiredate > e.hiredate
                    AND e2.deptno in (10)) AS next_hire_hd
FROM emp e
WHERE deptno in (10)
ORDER BY hiredate
) x
;

