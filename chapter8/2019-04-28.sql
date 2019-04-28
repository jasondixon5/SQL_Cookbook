/* Chapter 8: Date Arithmetic */

/* cont practice from 2019-04-27 */

/* 8.3 Determining number of business days between two dates */

-- restating book solution, which was slightly diff than mine
select sum(
    case when dayofweek(
                date_add(jones_hd,
                        interval t100.id - 1 DAY)) in (1, 6)
        then 0 else 1 end) as days
from (
    select 
        max(case when ename = "BLAKE" then hiredate end)
            as blake_hd,
        max(case when ename = "JONES" then hiredate end)
            as jones_hd
    from emp
    where ename in ("BLAKE", "JONES")) x
cross join t100
where t100.id <= datediff(blake_hd, jones_hd) + 1
;

/* 8.4 Determining the number of months or years between two dates */

-- Find number of months between first and last employees hired
-- Express that value in years
-- NB: Depending on approach, years may be rounded up or down,
--     e.g., 27 months could be rounded up to 3 years or down 
--           to 2 years (or kept as a fraction/decimal)

select
    min(hiredate) as min_hd
    ,max(hiredate) as max_hd
from emp
;

-- examine the different values the book solution works with

select
    min(hiredate) as min_hd
    -- ,year(min(hiredate)) as min_hd_yr
    -- ,month(min(hiredate)) as min_hd_mo
    ,max(hiredate) as max_hd
    -- ,year(max(hiredate)) as max_hd_yr
    -- ,month(max(hiredate)) as max_hd_mo
    ,year(max(hiredate)) - year(min(hiredate)) as diff_yrs
    ,(year(max(hiredate)) - year(min(hiredate)))*12 as diff_yrs_x_12
    ,month(max(hiredate)) - month(min(hiredate)) as diff_mnths
    ,(year(max(hiredate))
        - year(min(hiredate))) * 12 
        + ((month(max(hiredate))
          - month(min(hiredate)))) as adjusted_mnths
from emp
;

select 
    adjusted_mnths as mnth
    ,adjusted_mnths/12 as yr_frac
    ,round(adjusted_mnths/12, 0) as yr_rnd
    ,floor(adjusted_mnths/12) as yr_rnd_down

from (
select
    min(hiredate) as min_hd
    ,max(hiredate) as max_hd
    ,year(max(hiredate)) - year(min(hiredate)) as diff_yrs
    ,(year(max(hiredate)) - year(min(hiredate)))*12 as diff_yrs_x_12
    ,month(max(hiredate)) - month(min(hiredate)) as diff_mnths
    ,(year(max(hiredate))
        - year(min(hiredate))) * 12 
        + ((month(max(hiredate))
          - month(min(hiredate)))) as adjusted_mnths
from emp
) x
;

-- Book solution is to initially calc diff in months in terms
-- of diff in years * 12, which may overstate months slightly
-- Then calculate diff between max date month and min date month,
-- which may result in a negative number, and add it to months
-- figure found above. If months was overstated, then adding this 
-- difference will bring it down.

-- Try another solution with period difference function
-- NB: Period difference function takes a string in format 
--     'MMYYYY', not a date, and calculates difference in months

-- month() function extracts date as value in range 1 to 12
-- need value or string padded with 0

-- test concat func
select concat(1983,04)
from dual
;

-- test using lpad to pad single-digit months with a 0
select concat(1983,
    lpad(month(max(hiredate)), 2, '0')) as pad_max
    ,concat(1983,
    lpad(month(min(hiredate)), 2, '0')) as pad_min
from emp
;

-- now that testing of funcs is done, extract relevant dates
select
     min(hiredate) as min_hd
    ,max(hiredate) as max_hd
from emp
;

-- wrap query to extract dates in query to create
-- strings of format 'MMYYYY' from relevant dates
select concat(
    year(min_hd),
    lpad(month(min_hd), 2, '0')) as min_str
    ,concat(
        year(max_hd),
        lpad(month(max_hd), 2, '0')) as max_str
from (
select
     min(hiredate) as min_hd
    ,max(hiredate) as max_hd
from emp
) hiredates
;

-- Wrap those queries in outer query to use period_diff() func
-- Result should be 25
select period_diff(max_str, min_str) as pd_diff_mnths
from (
select concat(
    year(min_hd),
    lpad(month(min_hd), 2, '0')) as min_str
    ,concat(
        year(max_hd),
        lpad(month(max_hd), 2, '0')) as max_str
from (
select
     min(hiredate) as min_hd
    ,max(hiredate) as max_hd
from emp
) hiredates
) hiredates_str
;

/* 8.5 Determining the number of seconds, minutes, or 
hours between two dates */

-- Find difference between hiredates of ALLEN and WARD 
-- in seconds, minutes, and hours

-- After finding number of days, can calculate
-- days * 24 for hours
-- days * 24 * 60 for minutes
-- days * 24 * 60 * 60 for seconds

-- NB: In a datetime field, this solution will not
--     take into account the time portion of the field

-- Get the dates and identify which is greater
select 
    min(hiredate) as min_hd
   ,max(hiredate) as max_hd
from emp
where ename in ("ALLEN", "WARD")
;

-- calculate days
select
    datediff(max_hd, min_hd) as diff_days
    ,datediff(max_hd, min_hd) * 24 as diff_hours
    ,datediff(max_hd, min_hd) * 24 * 60 as diff_mins
    ,datediff(max_hd, min_hd) * 24 * 60 * 60 as diff_seconds
from (
    select 
        min(hiredate) as min_hd
       ,max(hiredate) as max_hd
    from emp
    where ename in ("ALLEN", "WARD") 
) dates_temp_table
;

-- Book solution uses a different approach for the inline table
-- NB: Weakness of this solution is that you have to know
--     which of the hiredates is the greater.
--     An alternative would be to wrap datediff() func in abs()
--     to get a positive integer as number of days
select
    datediff(ward_hd, allen_hd) as diff_days
    ,datediff(ward_hd, allen_hd) * 24 as diff_hours
    ,datediff(ward_hd, allen_hd) * 24 * 60 as diff_mins
    ,datediff(ward_hd, allen_hd) * 24 * 60 * 60 as diff_seconds
from (
    select
        max(case when ename = "WARD" then hiredate end) as ward_hd
        ,max(case when ename = "ALLEN" then hiredate end) as allen_hd
    from emp
) x
;

/* 8.6 Counting the occurrences of weekdays in a year */

-- Count the number of times each weekday occurs in a year

-- Construct year start and end dates
-- Find number of days between them 
--   (necessary to handle leap years; otherwise could just do
--    start + 364 increments)
select
    datediff("2012-12-31", "2012-01-01") as increments
from dual
;

-- generate a date for each day in the year
select date_add("2012-01-01", interval t500.id-1 day) as incr_dt
from t500
where t500.id <= (
    select
    datediff("2012-12-31", "2012-01-01") + 1
    from dual)
;

-- count occurrences with each day's count as a column
-- wrap in subquery for readability
select
    sum(case when dayofweek(incr_dt) = 2 then 1 end) as mon_count
    ,sum(case when dayofweek(incr_dt) = 3 then 1 end) as tue_count
    ,sum(case when dayofweek(incr_dt) = 4 then 1 end) as wed_count
    ,sum(case when dayofweek(incr_dt) = 5 then 1 end) as thu_count
    ,sum(case when dayofweek(incr_dt) = 6 then 1 end) as fri_count
   ,sum(case when dayofweek(incr_dt) = 7 then 1 end) as sat_count
   ,sum(case when dayofweek(incr_dt) = 1 then 1 end) as sun_count
from (
select date_add("2012-01-01", interval t500.id-1 day) as incr_dt
from t500
where t500.id <= (
    select
    datediff("2012-12-31", "2012-01-01") + 1
    from dual)
) days_of_year_table;

-- Book solution uses grouping rather than pivoting
-- Implement a form of that approach:
select
     dow_int
    ,count(*) as days_count
from (
    select
        dayofweek(
            date_add("2012-01-01", 
                    interval t500.id-1 day)) as dow_int
    from t500
    where t500.id <= (
        select
        datediff("2012-12-31", "2012-01-01") + 1
        from dual)
) days_of_year_table
group by dow_int
;

-- Now use date format func to get name of day instead of int dow
-- For ordering the results, there is no general function to 
-- get day of week int from just a weekday name string (must have
-- date to pass to those functions) so use a case statement
-- advantage of case statement is that you can impose
-- whatever order of weekdays you want, including Monday as first
select 
    dow_str 
    ,count(*) as days_counts
from (
    select
        date_format(
            date_add("2012-01-01", interval t500.id-1 day), '%W' ) as dow_str
    from t500 
    where t500.id <= (
        select datediff("2012-12-31", "2012-01-01") + 1 from dual)
) days_of_year_table
group by dow_str
order by case dow_str
    when "Monday" then 0
    when "Tuesday" then 1
    when "Wednesday" then 2
    when "Thursday" then 3
    when "Friday" then 4
    when "Saturday" then 5
    when "Sunday" then 6
    end
;

/* 8.7 Determining the date difference between the current
record and the next record */

-- For each employee determine number of days
-- between the day they were hired and the day the next
-- employee was hired

-- get each date
select
    e.hiredate as hd
    ,(select min(e2.hiredate) from emp e2 
     where e2.hiredate > e.hiredate) as next_hd
from emp e
;

-- calculate difference in days
-- add other fields to subquery to be able to display who
-- the dates are for
select hire_dates.*, datediff(next_hd, hd) as diff_days_between
from (
    select
        e.ename,
        e.deptno,
        e.hiredate as hd
        ,(select min(e2.hiredate) from emp e2 
        where e2.hiredate > e.hiredate) as next_hd
    from emp e
) hire_dates
order by hire_dates.hd, hire_dates.ename
;

