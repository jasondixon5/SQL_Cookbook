/* Chapter 8: Date Arithmetic */

/* 8.1 Adding and subtracting days, months, and years */

-- Using hiredate of employee CLARK, return following values:
-- 5 days before and after empl was hired
-- 5 months before and after empl was hired
-- 5 years before and after empl was hired

select
    hiredate as clark_hire
    ,date_sub(hiredate, interval 5 day) as hd_minus_5d
    ,date_add(hiredate, interval 5 day) as hd_add_5d
    ,date_sub(hiredate, interval 5 month) as hd_minus_5m
    ,date_add(hiredate, interval 5 month) as hd_add_5m
    ,date_sub(hiredate, interval 5 year) as hd_minus_5y
    ,date_add(hiredate, interval 5 year) as hd_add_5y
from emp
where ename in ("CLARK")
;

/* 8.2 Determining number of days between two dates */

-- Find difference between hire dates of employees ALLEN and WARD

select datediff(ward_hd, allen_hd) as diff_ward_allen_hd_days
from (
    select
        (select hiredate from emp where ename = "ALLEN") as allen_hd
        ,(select hiredate from emp where ename = "WARD") as ward_hd
    from dual) x
;

-- Book solution uses a cross join instead of scalar subqueries
select datediff(ward_hd, allen_hd) as diff_ward_allen_hd_days
from (
    select hiredate as ward_hd
    from emp
    where ename = "WARD"
    ) x
JOIN (
    select hiredate as allen_hd
    from emp
    where ename = "ALLEN"
) y
;

/* 8.3 Determining the number of business days [weekdays] 
between two dates */

-- Find number of business days between hire dates of BLAKE and JONES

-- Use a pivot table to return a row for each day between the 
-- two dates; then count the number of days that are not
-- Saturday or Sunday between them

-- Show hired date of each empl
select hiredate as blake_hd from emp where ename = "BLAKE";
select hiredate as jones_hd from emp where ename = "JONES";

-- Determine number of days between the two dates
-- Add 1 day so that count is inclusive
SET @days_diff = (
select datediff(blake_hd, jones_hd) + 1 as diff_blake_jones_hd_days
from (
    select
        (select hiredate from emp where ename = "BLAKE") as blake_hd
        ,(select hiredate from emp where ename = "JONES") as jones_hd
    from dual) x)
;

SELECT @days_diff;

-- generate a table using the pivot table T100 (which has 100
-- rows and only an id column numbering each row),
-- which has a row for each date
select
    hiredate
    ,T100.id
from emp
cross join T100
where T100.id <= @days_diff
and emp.ename = "JONES"
;

-- use the ID from T100 to calculate a date for each day between
-- the earlier hire date and that date + interval
-- NB: Jones was hired first
-- First date should be earlier hire date so
-- to start at hire_date + 1 use ID - 1 (ID starts at 1)
select
    date_add(hiredate, interval (T100.id-1) day) as incr_date
from emp
cross join T100
where T100.id <= @days_diff
and emp.ename = "JONES"
;

-- determine day of week of the incremented date
-- Note that Sunday == 1 and Saturday == 6
select dayofweek(incr_date) 
from (
select
    date_add(hiredate, interval (T100.id-1) day) as incr_date
from emp
cross join T100
where T100.id <= @days_diff
and emp.ename = "JONES"
) x
;

-- determine day of week of the incremented date
-- and then count number of rows whose day of week 
-- is on a weekend
-- Note that Sunday == 1 and Saturday == 6
select count(dayofweek(incr_date)) as num_weekdays
from (
select
    date_add(hiredate, interval (T100.id-1) day) as incr_date
from emp
cross join T100
where T100.id <= @days_diff
and emp.ename = "JONES"
) x
where dayofweek(incr_date) not in (1, 6)
;

-- book solution does not use a session variable
-- and so everything is in one query with subqueries
-- NB: My solution is still slightly different from book

-- book solution starts with getting the two dates
select 
    max(case when ename = "BLAKE" then hiredate end) as blake_hd
    ,max(case when ename = "JONES" then hiredate end) as jones_hd
from emp
where ename in ("BLAKE", "JONES")
;

-- then wrapping that table in an outer query to do the calcs
select sum(
    case when dayofweek(
        date_add(jones_hd, interval T100.id-1 day))
        in (1, 6) then 0 else 1 end) as days
from (
select 
    max(case when ename = "BLAKE" then hiredate end) as blake_hd
    ,max(case when ename = "JONES" then hiredate end) as jones_hd
from emp
where ename in ("BLAKE", "JONES")
) x
cross join T100
where T100.id <= datediff(blake_hd, jones_hd) + 1
;

