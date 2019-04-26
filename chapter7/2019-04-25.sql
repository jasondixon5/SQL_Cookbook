/* Chapter 7: Working with Numbers */

/* 7.6 Generating a running total */

-- compute running salary of all employees

-- Subquery approach
select
    empno
    ,ename
    ,sal
    ,(select sum(sal) from emp e2 
     where e2.empno <= emp.empno) 
     as running_salary_total
from emp
;

-- cross join approach
select
    e.empno
    ,e.ename
    ,e.sal
    ,sum(e2.sal) as running_salary_total_xjoin
from emp e
cross join emp e2
on e2.empno <= e.empno
group by e.empno, e.ename, e.sal
;

/* 7.7 Generating a running product */

-- compute a running product of emp no

-- take ln of empno
select
    empno
    ,ename
    ,sal
    ,ln(empno)
from emp
;

-- take sum of ln(empno) for each empno
-- less than or equal to current
select
    e.empno
    ,e.ename
    ,e.sal
    ,ln(e.empno)
    ,(select sum(ln(empno)) from emp e2
      where e2.empno <= e.empno) as ln_sum
from emp e
;

-- raise e to sum(ln) to get approx running product
select
    e.empno
    ,e.ename
    ,e.sal
    ,ln(e.empno)
    ,(select sum(ln(empno)) from emp e2
      where e2.empno <= e.empno) as ln_sum
    ,exp((select sum(ln(empno)) from emp e2
      where e2.empno <= e.empno)) as running_product
from emp e
;

/* 7.8 Calculating a running difference */

-- compute running diff of salaries
-- NB: Book solution did not result in correct calcs
-- Instead, approaching using session variables

SET @running_diff = 0;

select 
    e.empno
    ,e.ename
    ,e.sal
    ,case when e.empno = (select min(empno) from emp)
        then @running_diff := e.sal
        else @running_diff := @running_diff - e.sal
        end as running_diff
from emp e
order by e.empno
;

/* 7.9 Calculate a mode */

select e.sal, count(*)
from emp e
group by e.sal
order by count(*) desc
;

select e.sal
from emp e
group by e.sal 
having count(e.sal) >= all(
    select count(e2.sal)
    from emp e2
    group by sal)
;

-- calculate mode again (cold start)
select
    sal
    ,count(*) as sal_frequ
from emp
group by sal
order by count(*)
;

select sal
from emp
group by sal
having count(*) >= all(
    select count(*) from emp group by sal
)
;

-- calculate mode again
-- but now limiting to dept 20
select
    sal
    ,count(*) as sal_frequ
from emp
where deptno in (20)
group by sal
order by count(*)
;

select sal
from emp
where deptno in (20)
group by sal
having count(*) >= all(
    select count(*) from emp
    where deptno in (20)
    group by sal
)
;

/* 7.10 Calculating a median */

-- Find median of salaries in dept 20

-- examine dept 20 salaries
select sal
from emp
where deptno in (20)
order by sal
;

-- book solution
select avg(sal) as median_sal
from (
    select e.sal
    from emp e
    cross join emp e2
    where e.deptno=e2.deptno
    and e.deptno=20
    group by e.sal
    having sum(case when e.sal=e2.sal then 1 else 0 end) >= abs(
        sum(sign(e.sal - e2.sal)
        )
    )
) x
;

-- examine what having clause is working on

-- first examine result of cross join before having clause
-- is added
-- include columns having clause is using
select 
    e.sal as e_sal
    ,e2.sal as e2_sal
    ,e.deptno as e_deptno
    ,e2.deptno as e2_deptno
    ,case when e.sal=e2.sal then 1 else 0 end as having_cond
    ,e.sal - e2.sal as sal_diff
    ,sign(e.sal-e2.sal) as sign_sal_diff
from emp e
cross join emp e2
where e.deptno=e2.deptno
and e.deptno=20
order by e.sal, e2.sal
;

select 
    e.sal as e_sal
    ,sum(case when e.sal=e2.sal then 1 else 0 end) as having_cond
    ,sum(sign(e.sal-e2.sal)) as sign_sal_diff
from emp e
cross join emp e2
where e.deptno=e2.deptno
and e.deptno=20
group by e.sal
order by e.sal
;

/* Implement percentile to find other portions of the data */

/*
Returns the lowest number under which the percentage
    of values represented by percentile fall below

    Steps:
    Sort list
    Find rank of percentile via:
        percentile (as decimal) * (length of num_list + 1)
    a) If rank is an integer, find and return number at that rank
    b) If rank is not an integer:
       1) Store integer part of rank, IR
       2) Store fractional part of rank, FR
       3) Retrieve value at rank position IR and store as IR_V
       4) Retrieve value at rank position (IR + 1) and store as IR1_V
       5) Calculate FR * (IR1_V - IR_V) + IR_V
       6) return result of step 5
*/
SET @perc = .5;
SET @rnk = @perc * (1 + (SELECT count(sal) from emp where deptno=20));
SET @rnk_int = floor(@rnk);
SET @rnk_frac = @rnk - @rnk_int;

select @perc, @rnk, @rnk_int, @rnk_frac from dual;

SET @row_num = 0;

SELECT @row_num := @row_num + 1 as row_num
        ,sal 
from emp 
where deptno=20 
order by sal
;

SET @row_num = 0;

SELECT 
     min(sal) as ir_v
    ,max(sal) as ir1_v
    ,max(sal) - min(sal) as diff
    ,@rnk_frac * (max(sal) - min(sal)) as frac_x_diff
    ,round(
        @rnk_frac 
        * (
            max(sal) - min(sal)
            ) 
        + min(sal)
        ,2) as percentile
FROM (
    SELECT @row_num := @row_num + 1 as row_num
            ,sal 
    from emp 
    where deptno=20 
    order by sal) x
WHERE row_num in (@rnk_int, @rnk_int + 1)
;

/* Test percentile solution with an even-numbered list */
SET @perc = .5;
SET @rnk = @perc * (1 + (SELECT count(sal) from emp));
SET @rnk_int = floor(@rnk);
SET @rnk_frac = @rnk - @rnk_int;

select @perc, @rnk, @rnk_int, @rnk_frac from dual;

SET @row_num = 0;

SELECT @row_num := @row_num + 1 as row_num
        ,sal 
from emp 
order by sal
;

SET @row_num = 0;

SELECT 
     min(sal) as ir_v
    ,max(sal) as ir1_v
    ,max(sal) - min(sal) as diff
    ,@rnk_frac * (max(sal) - min(sal)) as frac_x_diff
    ,round(
        @rnk_frac 
        * (
            max(sal) - min(sal)
            ) 
        + min(sal)
        ,2) as percentile
FROM (
    SELECT @row_num := @row_num + 1 as row_num
            ,sal 
    from emp 
    order by sal) x
WHERE row_num in (@rnk_int, @rnk_int + 1)
;

/* 7.9 Calculating a mode (repeat, cold start) */
 
-- find mode of salaries in dept 20

-- show salaries in dept 20 with frequency
select
    sal
    ,count(*) as frequency
from emp
where deptno in (20)
group by sal
order by count(*) desc, sal
;

-- determine mode of salaries
select 
    sal sal_dept20_mode
from emp
where deptno in (20)
group by sal
having count(*) >= all(
    select count(*) from emp
    where deptno in (20)
    group by sal
)
;

/* 7.10 Calculating a median */

-- calculate median of salaries in dept 20
-- book solution

-- show salaries in dept 20, ordered
select
    sal
from emp
where deptno in (20)
order by sal
;

-- determine median of salaries in dept 20
select avg(sal) as sal_dept20_median
from (
    select e.sal
    from emp e
    cross join emp e2
    where e.deptno = e2.deptno
    and e.deptno in (20)
    group by e.sal
    having sum(case when e.sal=e2.sal then 1 else 0 end) >= abs(
        sum(sign(e.sal - e2.sal))
    )
) x
;
/* 7.11 Determining percentage of total */

-- Determine what % of all salaries each dept is

-- Show total salaries by dept
select
    deptno
    ,sum(sal)
from emp
group by deptno
;

-- add % total
select
    deptno
    ,sum(sal) as dept_total
    ,sum(sal) / (select sum(sal) from emp) as dept_proportion
from emp
group by deptno
;

-- alt solution, if truly only want one dept
select
    sum(case when deptno in (10) then sal end) / sum(sal)
    as dept_10_prop
from emp
;

/* 7.13 Computing averages without high and low values */

-- Compute average salary excluding highest and lowest salaries
select
    avg(sal)
from emp
where sal not in (
     (select min(sal) from emp)
    ,(select max(sal) from emp)
)
;

-- alternate solution if only want to exclude a single instance
-- each of high and low value, in situation where there are
-- multiple values of either
select
     (
           sum(sal) 
        - (select max(sal) from emp) 
        - (select min(sal) from emp)
     ) / (count(*) - 2) as avg_excl_single_high_low
from emp
;

/* 7.15 Changing values in a running total */

-- given view below, calculate running total
-- where 'pr' rows add and 'py' rows subtract from total

drop view if exists v;
create view v (id, amt, trx)
as
select 1, 100, 'pr' from dual union all
select 2, 100, 'pr' from dual union all
select 3, 50, 'py' from dual union all
select 4, 100, 'pr' from dual union all
select 5, 200, 'py' from dual union all
select 6, 50, 'py' from dual
;

select * from v;

-- create transaction table with running total
select
    case trx
        when 'py' then 'payment'
        when 'pr' then 'purchase'
        else 'unknown'
    end as trx_type
    ,amt as amt
    ,(
        select sum(
            case trx 
                when 'py' then (-1 * amt)
                when 'pr' then amt
                else 0 end
                    )
        from v v2
        where v2.id <= v.id
        ) as balance 
from v
;

