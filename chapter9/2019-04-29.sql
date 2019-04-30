/* Chapter 9: Date Manipulation */

/* 9.1 Determining if a year is a leap year */

-- Determine day of last day of Feb; if it's 29th then
-- year is a leap year

select 
    current_date as curr_date
    ,dayofyear(current_date) as doy
    ,date_add(current_date, interval -dayofyear(current_date) day) as last_day_prev_yr
   ,date_add(
       date_add(current_date, interval -dayofyear(current_date) day), interval 1 day) as first_day_curr_yr
    ,date_add(
        date_add(
        date_add(
           current_date, 
           interval -dayofyear(current_date) day), 
           interval 1 day), interval 1 month)
           as first_day_feb
    ,last_day(date_add(
            date_add(
            date_add(
            current_date, 
            interval -dayofyear(current_date) day), 
            interval 1 day), interval 1 month))
            as last_day_feb
;

select day(last_day(date_add(
                date_add(
                date_add(
                current_date, 
                interval -dayofyear(current_date) day), 
                interval 1 day), interval 1 month)))
                as last_day_feb_curr_yr
;

/* 9.2 Determining the number of days in a year */

-- Determine number of days in current year

-- First find the first day of the desired year
-- Add one year to that date to get the first day of the next yr
-- Subtract first date of current year from first date of following
--  year

-- Find first day of current year
select 
    curr_year as first_day_curr_yr
    ,(curr_year + interval 1 year) as first_day_next_yr
    ,datediff(
        (curr_year + interval 1 year), curr_year) as num_days_curr_yr
from (
select date_add(
    current_date, interval -dayofyear(
        current_date) + 1 day) as curr_year
    
) x
;

/* Extracting units of time from a date */

-- Using current date, extract day, month, year, 
--  second, minute, and hour

select current_timestamp
;

select
     date_format(current_timestamp, '%Y') as yr
    ,date_format(current_timestamp, '%m') as mon
    ,date_format(current_timestamp, '%d') as day
    ,date_format(current_timestamp, '%k') as hr
    ,date_format(current_timestamp, '%i') as min
    ,date_format(current_timestamp, '%s') as sec
;

/* 9.4 Determining the first and last day of a month */

-- Each solution uses a variant of finding first day of month,
-- adding a month, and then subtracting a day to find the last
-- day of the month

-- Find first and last day of current month
-- MySQL solution uses day() function to determine
-- how many days into current month we are and subtracting
-- that figure to calculate first day of month
-- Then it uses the convenience func last_day() to find
-- last day of the current month
select
    current_date
    ,day(current_date) days_into_month
    ,date_add(current_date, interval -day(current_date)+1 day) as first_of_mo
    ,last_day(current_date) last_of_mo
;

/* 9.5 Determining all dates for a particular weekday 
throughout the year */

/* Solution is to return each day for desired year
and keep only the dates corresponding to the dow you 
care about */

-- first generate each date of the desired year
-- (using current year as demonstration)
select date_add(first_doy, interval t500.id-1 day) as doy
from t500
cross join (
select
    date_add(
        current_date, interval -dayofyear(current_date)+1 day)
        as first_doy
    ,date_add(
       date_add(
           current_date, interval -dayofyear(current_date)+1 day),
       interval 1 year) as first_doy_next
   ,date_add(
       date_add(
       date_add(
           current_date, interval -dayofyear(current_date)+1 day),
       interval 1 year), interval -1 day) as last_doy
    ) x
where date_add(first_doy, interval t500.id-1 day) <= last_doy
;

-- now add a filter for day of the week 
-- use Fridays (== 5 when using dayofweek() func)
select date_add(first_doy, interval t500.id-1 day) as doy
from t500
cross join (
select
    date_add(
        current_date, interval -dayofyear(current_date)+1 day)
        as first_doy
    ,date_add(
       date_add(
           current_date, interval -dayofyear(current_date)+1 day),
       interval 1 year) as first_doy_next
   ,date_add(
       date_add(
       date_add(
           current_date, interval -dayofyear(current_date)+1 day),
       interval 1 year), interval -1 day) as last_doy
    ) x
where date_add(first_doy, interval t500.id-1 day) <= last_doy
and dayofweek(date_add(first_doy, interval t500.id-1 day)) in (6)
;

/* 9.6 Determining the date of the first and last occurrence
of a specific weekday in a month */

-- Find first and last Mondays of the current month

-- Technique involves finding first day of month and then
-- doing arithmetic on the integer days of week values 
-- (e.g., Sun minus Sat is 1 - 7)

-- first get first day of current month and month integer value
select 
    date_add(
        date_add(current_date, interval -day(current_date) day), interval 1 day) as dy
    ,month(current_date) mth
;

-- find first Monday of month by doing arithmetic on 
-- weekday integer (where Mondah == 2)
select 
    -- if first day of month is Monday dow int will be 2 and 
    -- dow int - 2 will be 0
    -- if first day is Tue - Sat dow int will be > 2 
    -- and so dow int - 2 will be poz
    -- if first day is Sun, dow int - 2 will be (1-2 = -1)
    -- The sign() function returns 0 for 0, 1 for poz int, 
    -- -1 for neg int
    -- Evaluate sign and take conditional action:
    -- * If first day is Sun, add 1 day
    -- * If first day is Tue - Sat, calc 7 minus number of days
    --   day is away from Mon and add that value to first day
    -- * If first day is Mon, just return it
    dayofweek(dy)-2 as dow_first_day_minus_2
    ,sign(dayofweek(dy)-2) sign_dow_first_minus_2
    ,case sign(dayofweek(dy)-2)
        when 0 then dy
        when -1 then date_add(dy, interval abs(dayofweek(dy)-2) day)
        when 1 then date_add(dy,interval (7-(dayofweek(dy)-2)) day)
        end as first_monday,
        mth
from (
select 
    date_add(
        date_add(current_date, interval -day(current_date) day), interval 1 day) as dy
    ,month(current_date) mth
    ) x
;

-- determine whether adding 28 days to first day of month 
-- returns a date that is into the next month; 
-- if it doesn't, then add 28; otherwise add 21 to get last 
-- Monday of month
select 
    first_monday
    ,case month(date_add(
        first_monday, interval 28 day))
        when mth then date_add(first_monday, interval 28 day)
        else date_add(first_monday, interval 21 day)
    end as last_monday
from (
select
    dayofweek(dy)-2 as dow_first_day_minus_2
    ,sign(dayofweek(dy)-2) sign_dow_first_minus_2
    ,case sign(dayofweek(dy)-2)
        when 0 then dy
        when -1 then date_add(dy, interval abs(dayofweek(dy)-2) day)
        when 1 then date_add(dy,interval (7-(dayofweek(dy)-2)) day)
        end as first_monday,
        mth
from (
select 
    date_add(
        date_add(current_date, interval -day(current_date) day), interval 1 day) as dy
    ,month(current_date) mth
    ) x
    ) y
;

/* 9.7 Creating a calendar */

-- Create a calendar for the current month
-- Technique is to return each day for current month
-- and then pivot on the day of the week for each week 
-- in the month

-- first calculate first day of month and retrieve month int 
select
    date_add(
        current_date, interval -dayofmonth(current_date)+1 day) dy
    ,date_format(
       date_add(
        current_date, interval -dayofmonth(current_date)+1 day), '%m' 
    ) mth
from dual
;

-- use t500 pivot to add an increasing number of days to 
-- first day, to get a row for each date in the month
select
    date_add(x.dy, interval t500.id-1 day) dy,
    x.mth
from (
select
    date_add(
        current_date, interval -dayofmonth(current_date)+1 day) dy
    ,date_format(
       date_add(
        current_date, interval -dayofmonth(current_date)+1 day), '%m' 
    ) mth
from dual
) x cross join t500
-- add no more than 30 days to first day of month
-- filter for id <= 31 because adding id - 1 to first day in select clause
where t500.id <= 31
-- only include days in relevant month
and date_format(
   date_add(x.dy, interval t500.id-1 day), '%m') = x.mth 

;

-- wrap queries in outer query that retrieves 
-- week number, day of month, and day of week
select 
    date_format(dy, '%u') as wk
    ,date_format(dy, '%d') dm
    ,date_format(dy, '%w')+1 dw
from (
select
    date_add(x.dy, interval t500.id-1 day) dy,
    x.mth
from (
select
    date_add(
        current_date, interval -dayofmonth(current_date)+1 day) dy
    ,date_format(
       date_add(
        current_date, interval -dayofmonth(current_date)+1 day), '%m' 
    ) mth
from dual
) x cross join t500
-- add no more than 30 days to first day of month
-- filter for id <= 31 because adding id - 1 to first day in select clause
where t500.id <= 31
-- only include days in relevant month
and date_format(
   date_add(x.dy, interval t500.id-1 day), '%m') = x.mth 
) y
;

-- wrap all queries created so far in outer query
-- that will pivot data into columns for each day of the week
select
     max(case dw when 2 then dm end) as Mo
    ,max(case dw when 3 then dm end) as Tu
    ,max(case dw when 4 then dm end) as We
    ,max(case dw when 5 then dm end) as Th
    ,max(case dw when 6 then dm end) as Fr
    ,max(case dw when 7 then dm end) as Sa
    ,max(case dw when 1 then dm end) as Su
from (
select 
    date_format(dy, '%u') as wk
    ,date_format(dy, '%d') dm
    ,date_format(dy, '%w')+1 dw
from (
select
    date_add(x.dy, interval t500.id-1 day) dy,
    x.mth
from (
select
    date_add(
        current_date, interval -dayofmonth(current_date)+1 day) dy
    ,date_format(
       date_add(
        current_date, interval -dayofmonth(current_date)+1 day), '%m' 
    ) mth
from dual
) x cross join t500
-- add no more than 30 days to first day of month
-- filter for id <= 31 because adding id - 1 to first day in select clause
where t500.id <= 31
-- only include days in relevant month
and date_format(
   date_add(x.dy, interval t500.id-1 day), '%m') = x.mth 
) y
) z
group by wk
order by wk
;

/* 9.8 Listing quarter start and end dates for the year */

-- For current year, find quarter start and end dates
-- Generate the start and end dates along with the quarter
-- each start/end date combo falls into

-- Get first of year 
-- Use pivot table t100 to get a 4 rows, since there are 4 quarters
select 
    t100.id
    ,date_add(
        current_date, interval -dayofyear(current_date)+1 day)
        as dy
from t100
where t100.id <= 4
;

-- Increment first day of year by 3-month periods
-- to get quarter start dates
select date_add(
    -- id is 1, 2, 3, 4
    -- increment by 0, 3, 6, 9 months
    dy, interval (3*(id-1)) month) as dy
from (
    select 
        t100.id
        ,date_add(
            current_date, interval -dayofyear(current_date)+1 day)
            as dy
    from t100
    where t100.id <= 4
) x
;

-- extract quarter number from start date
-- calculate end date from start date
-- NB: Book solution returns unmodified (and incorrect) 
--     start dates from inner query (x) and then uses outer 
--     query to adjust them
-- My solution uses inner query x to get correct start date
-- and then outer query just calculates correct end date
select 
    quarter(dy) as qtr_num
    ,dy as qtr_start
    -- increment by 3 months and then subtract 1 day
    ,date_add(
        date_add(
        dy, interval 3 month),
        interval -1 day) as qtr_end
from (
    select date_add(
        -- id is 1, 2, 3, 4
        -- increment by 0, 3, 6, 9 months
        dy, interval (3*(id-1)) month) as dy
    from (
        select 
            t100.id
            ,date_add(
                current_date, interval -dayofyear(current_date)+1 day)
                as dy
        from t100
        where t100.id <= 4
) x
) y
;

/* 9.9 Determining quarter start and end dates for a given quarter */

-- Given a quarter number, determine its start and end date
-- Use current year as demonstration
drop view if exists v;
create view v as
    select 2019 as yr, 1 as qtr
    union all 
    select 2019 as yr, 2 as qtr
    union all 
    select 2019 as yr, 3 as qtr
    union all 
    select 2019 as yr, 4 as qtr
;

select 
    qtr as qtr
    ,date_add(
        concat(yr, '-', '01', '-', '01'), 
        interval 3*(qtr-1) month) as qtr_start
    ,date_add(
        date_add(
        concat(yr, '-', '01', '-', '01'),
        interval 3*(qtr) month), interval -1 day) as qtr_end
from v
;

-- book solution involves creating a 'yyyymm' date
-- then using the lastdate() func to get last day of month
-- and then calculating first day of month
-- NB: Book's v has year and quarter combined in 
--     format '20191', so involves an extra step of
--     extracting the quarter number (e.g., 1) via
--     mod(value, 10)
-- However, my attempts to use str_to_date() as book does
-- were not successful. It's not clear if something changed
-- or if this was a bug in the book example.

select
    str_to_date('20151', '%Y%m')
from v
;

/* Returns:
+------------------------------+
| str_to_date('20151', '%Y%m') |
+------------------------------+
| NULL                         |
| NULL                         |
| NULL                         |
| NULL                         |
+------------------------------+
*/

/* 9.10 Filling in missing dates */

-- Generate a count of employees hired by month and year
-- but do not skip the months and years in which no employees
-- were hired

-- Find the boundary dates
select 
     min(hiredate) as min_hd
    ,max(hiredate) as max_hd
from emp
;

-- Find the first day of the first year and the last day of the
-- last year
select
    year(min(hiredate)) as min_year
    ,year(max(hiredate)) as max_year
from emp
;

select
    concat(year(min(hiredate)), "-01-01") as min_date
    ,concat(year(max(hiredate)), "-12-31") as max_date
from emp
;

-- Use pivot table to generate month and year for each 
-- date month and year between the two dates
select
    date_add(min_date, interval t100.id-1 month) as mth
from (
select
    concat(year(min(hiredate)), "-01-01") as min_date
    ,concat(year(max(hiredate)), "-12-31") as max_date
from emp
) x
cross join t100
where date_add(min_date, interval t100.id-1 month) <= max_date 
;

-- extract month and year
select month(mth) as mth, year(mth) as yr
from (
select
    date_add(min_date, interval t100.id-1 month) as mth
from (
select
    concat(year(min(hiredate)), "-01-01") as min_date
    ,concat(year(max(hiredate)), "-12-31") as max_date
from emp
) x
cross join t100
where date_add(min_date, interval t100.id-1 month) <= max_date 
) y;

-- join emp table
select month(mth) as mth, year(mth) as yr, count(hiredate) as cnt_hired
from (
select
    date_add(min_date, interval t100.id-1 month) as mth
from (
select
    concat(year(min(hiredate)), "-01-01") as min_date
    ,concat(year(max(hiredate)), "-12-31") as max_date
from emp
) x
cross join t100
where date_add(min_date, interval t100.id-1 month) <= max_date 
) y
left join emp
on month(hiredate) = month(mth) and year(hiredate) = year(mth)
group by year(mth), month(mth)
;

-- verify total makes sense
-- there should be 14 employees total
select sum(cnt_hired)
from (
select month(mth) as mth, year(mth) as yr, count(hiredate) as cnt_hired
from (
select
    date_add(min_date, interval t100.id-1 month) as mth
from (
select
    concat(year(min(hiredate)), "-01-01") as min_date
    ,concat(year(max(hiredate)), "-12-31") as max_date
from emp
) x
cross join t100
where date_add(min_date, interval t100.id-1 month) <= max_date 
) y
left join emp
on month(hiredate) = month(mth) and year(hiredate) = year(mth)
group by year(mth), month(mth)
) z
;

/* 9.11 Searching on specific units of time */

-- Find all employees hired in the first quarter of any year
select
    ename
    ,hiredate
from emp 
where quarter(hiredate) in (1)
;

/* 9.12 Comparing records using specific parts of a date */

-- Find employees hired in the same month and year
-- Technique involves a self join
-- NB: Book problem example is to find empls hired on same
--     month and weekday; I implemented month and year instead

select
    e.ename as e1
    ,e.hiredate as hd1
    ,e2.ename as e2
    ,e2.hiredate as hd2
from emp e
join emp e2
on month(e.hiredate) = month(e2.hiredate)
and year(e.hiredate) = year(e2.hiredate)
where e.empno < e2.empno
;
