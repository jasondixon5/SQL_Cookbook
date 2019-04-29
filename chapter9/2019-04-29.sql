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

