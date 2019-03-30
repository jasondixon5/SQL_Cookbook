/* Chapter 9: Date Manipulation */

/* 9.1 Determine if a year is a leap year */

/* Book solution involves finding last day
of February and then testing if it's 29th or
28th */

-- find first day of year by subtracting the number
-- of days it is into the year from the current date
-- Then add one day.

SELECT CURDATE();

SELECT DATE_ADD(
        DATE_ADD(CURDATE(),
            INTERVAL -DAYOFYEAR(CURDATE()) DAY),
            INTERVAL 1 DAY) dy
;

-- add one month to date found above
SELECT DATE_ADD( 
    DATE_ADD(
    DATE_ADD(CURDATE(),
            INTERVAL -DAYOFYEAR(CURDATE()) DAY),
            INTERVAL 1 DAY),
            INTERVAL 1 MONTH) dy
;

-- use LAST_DAY() func to find last day of the month
-- for the date calculated above
SELECT LAST_DAY(
    DATE_ADD( 
    DATE_ADD(
    DATE_ADD(CURDATE(),
            INTERVAL -DAYOFYEAR(CURDATE()) DAY),
            INTERVAL 1 DAY),
            INTERVAL 1 MONTH)) dy
;

-- extract day from the date calculated above
SELECT DAY(
    LAST_DAY(
    DATE_ADD( 
    DATE_ADD(
    DATE_ADD(CURDATE(),
            INTERVAL -DAYOFYEAR(CURDATE()) DAY),
            INTERVAL 1 DAY),
            INTERVAL 1 MONTH))) dy
;

-- Compare day to 29 to determine if year is leap year
SET @last_day_feb = DAY(
    LAST_DAY(
    DATE_ADD( 
    DATE_ADD(
    DATE_ADD(CURDATE(),
            INTERVAL -DAYOFYEAR(CURDATE()) DAY),
            INTERVAL 1 DAY),
            INTERVAL 1 MONTH)));

SELECT (@last_day_feb = 29) AS is_leap_year
;

/* 9.2 Determining number of days in a year */

/* Book solution uses fact that the number of days
in current year is diff between first day
of next year and first day of current year (in days).

1. Find first day of current year.
2. Add one year to that date.
3. Subtract current year from result of step 2.
*/

-- calc first day of current year
SET @first_day_current_year = DATE_ADD(DATE_ADD(CURDATE(),
                                    INTERVAL -DAYOFYEAR(CURDATE()) DAY),
                                    INTERVAL 1 DAY);

SELECT @first_day_current_year;

-- calc first day of next year
SELECT DATE_ADD(@first_day_current_year,
                INTERVAL 1 YEAR) new_year
;

-- subtract current year from new year
SELECT DATEDIFF(
                DATE_ADD(@first_day_current_year,
                INTERVAL 1 YEAR),
                @first_day_current_year) num_days_in_curr_year
;

SELECT DAYOFYEAR('2000-12-31') num_days_Y2000,
    DAYOFYEAR('2001-12-31') num_days_Y2001
;

