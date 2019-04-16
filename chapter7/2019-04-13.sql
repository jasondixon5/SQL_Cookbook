/* CHAPTER 7: WORKING WITH NUMBERS */

/* 7.1 Computing an average */

-- Compute averages
-- * of salaries of all empls
-- * of salaries by dept
-- * of commissions of all empls
-- * of commissions by dept

select
    avg(sal) as avg_salary
from emp
;

select 
     deptno
    ,avg(sal) as avg_salary_by_dept
from emp
group by deptno
;

-- NB: Commission field can be null
select
    avg(coalesce(comm, 0)) as avg_comm
from emp
;

select
    deptno
    ,avg(coalesce(comm, 0)) as avg_comm_by_dept
from emp
group by deptno
;

/* 7.2 Finding min/max values in a column */

-- Find min/max values
-- of salaries
-- and also of salaries by dept
-- Then combine into one table

select
     min(sal) as lowest_salary
    ,max(sal) as highest_salary
from emp
;

select
     deptno
    ,min(sal) as lowest_salary
    ,max(sal) as highest_salary
from emp
group by deptno
;

select
     deptno
    ,min(sal) as lowest_salary
    ,max(sal) as highest_salary
from emp
group by deptno

union all

select
     'ALL DEPTS'
    ,min(sal) as lowest_salary
    ,max(sal) as highest_salary
from emp
;

/* 7.3 Summing the values in a column */

-- Get sum of salaries, by dept and for all empls
-- Get sum of commissions for all empls
-- Test rollup behavior with sal totals
-- Test behavior of using coalesce() func vs. not in sum of commissions

-- Sum of salaries
select
    sum(sal) as salary_total
FROM emp
;

-- Sum of salaries by dept
select
     deptno
    ,sum(sal) salary_ttl_by_dept
from emp
group by deptno
;

-- sum of commissions
-- with coalesce
select
    sum(coalesce(comm, 0)) as total_comm
FROM emp
;

select
    sum(comm) as total_comm
FROM emp
;

-- Sum of salaries by dept
-- using with rollup
select
     deptno
    ,sum(sal) salary_ttl_by_dept
from emp
group by deptno with rollup
;

-- Sum of salaries by dept
-- using with rollup
-- Show desc instead of null for deptno for total
select
     coalesce(deptno, 'total') as deptno
    ,sum(sal) salary_ttl_by_dept
from emp
group by deptno with rollup
;

/* 7.4 and 7.5 SKIP (counting rows/values) */

/* 7.6 Generating a running total */

-- Generate running total of salaries for all employees

-- Generate running total of salaries
-- Subquery approach
select
     ename
    ,empno
    ,sal
    ,(select sum(sal) from emp e2
      where e2.empno <= e.empno)
      as running_ttl_salary
from emp e
;

-- Generate running total of salaries
-- Join approach
select
     e.ename
    ,e.empno
    ,e.sal
    ,SUM(e2.sal) as running_ttl_salary
from emp e
inner join emp e2
on e2.empno <= e.empno
group by e.ename, e.empno, e.sal
order by e.empno;

/* 7.7 Generating a running product */

-- Generate running product
-- To make numbers more tractable,
-- multiply deptno instead of (book's suggestion of) salaries

-- Approach:
-- Use log to make mult into addition
-- 1) Get log of each number to multiply
-- 2) Sum the logs
-- 3) Convert sum of logs back into number

-- brief illustration of technique
select
     9*3
    ,ln(9)
    ,ln(3)
    ,ln(9)+ln(3)
    ,exp(ln(9) + ln(3))
from dual
;

select
     e.ename
    ,e.empno
    ,e.deptno
    ,ln(e.deptno) ln_deptno
    ,(select sum(ln(e2.deptno))
      from emp e2
      where e2.empno <= e.empno) as cumul_sum_ln
    ,(select exp(sum(ln(e2.deptno)))
      from emp e2
      where e2.empno <= e.empno) as cumul_prod_deptno
from emp e
;

-- NB: It's invalid in SQL to compute logarithms of values less
-- than or equal to zero. Would need to handle that scenario
-- in production. If need to compute running product with
-- values in that range, may need another solution

select
     ln(0)
    ,ln(-1)
from dual
;

show warnings;

/*
+-------+--------+
| ln(0) | ln(-1) |
+-------+--------+
|  NULL |   NULL |
+-------+--------+
1 row in set, 2 warnings (0.00 sec)

+---------+------+--------------------------------+
| Level   | Code | Message                        |
+---------+------+--------------------------------+
| Warning | 3020 | Invalid argument for logarithm |
| Warning | 3020 | Invalid argument for logarithm |
+---------+------+--------------------------------+
2 rows in set (0.00 sec)
*/

/* 7.8 Calculating a running difference */

-- Compute running diff of salaries in dept 10
-- NB: Book solution is not valid; the only valid
--     solution I've found is using a temp var

/*
-- test syntax
set @test_var = 0;

select
    e.empno,
    e.sal,
    case
        when e.empno = 7369
            then @test_var := e.sal
        else @test_var := @test_var + 100
    end as test_sum
from emp e
;
*/

set @running_diff = 0;
set @min_emp_no = (SELECT MIN(empno) FROM emp);

select
     e.ename
    ,e.empno
    ,e.sal
    -- first employee's salary is starting figure
    -- each subsequent salary is then subtracted
    ,case
        when e.empno = @min_emp_no
            then @running_diff := e.sal
        else @running_diff := @running_diff - e.sal
     end as running_diff
from emp e
order by e.empno
;

/* 7.9 Calculating a mode */

-- Find mode of salaries in dept 20

-- Find count of salaries in dept
select
    sal
    ,count(*) as frequency
from emp
where deptno in (20)
group by sal
order by count(*) desc
;

-- filter for the values with the highet frequencies
select
    sal
from emp
where deptno in (20)
group by sal
having count(*) = (select max(f)
                    from (select sal, count(*) as f
                            from emp
                            where deptno in (20)
                            group by sal) x)
;

-- book solution for mysql is very similar
-- but it uses the having clause with an all() expression

select sal
from emp
where deptno in (20)
group by sal
having count(*) >= all(
    select count(*)
    from emp
    where deptno in (20)
    group by sal
)
;

/* 7.10 Calculating a median */

-- Calculate median of salaries in dept 20
-- Book solution
-- Uses self-join to find median
select avg(sal)
from (
    select e.sal
    from emp e
    inner join emp d
    on d.deptno=e.deptno
    where e.deptno=20
    group by e.sal
    having sum(case when e.sal=d.sal then 1 else 0 end) >=
        abs(sum(sign(e.sal - d.sal)))
) x
;

/* 7.11 Determining the percentage of a total */

-- Determine percentage of all salaries that the salaries
-- in dept 10 represents
select
     deptno
    ,sum(sal) as salary_total
    ,sum(sal)/(select sum(sal) from emp) as salary_prop
from emp
group by deptno
;

-- book solution, which only seeks to get % for dept 10,
-- uses a different technique
select
    (sum(
        case when deptno=10 then sal end)
    ) / sum(sal) as pct
from emp
;

-- note that my solution with subquery might be
-- more efficient for getting the % for each dept
-- although book solution could be adapted as follows
-- for that

/* 7.12 Aggregating nullable columns */

-- Calculate average commission for employees in dept 30
-- use coalesce to convert nulls to 0
select
    avg(coalesce(comm, 0)) as avg_commission
from emp
where deptno in (30)
;

/* 7.13 Computing averages without high and low values */

-- compute average salary of all employees excluding 
-- highest and lowest salaries

select
     avg(sal) as avg_sal_without_outliers
    ,(select avg(sal) from emp) as avg_sal_with_outliers
from emp
where sal not in (
    (select max(sal) from emp),
    (select min(sal) from emp)
)
;

/* 7.14 Converting alphanumeric strings into numbers */

-- relies on translate function, which is not supported
-- by mysql or sql server

/* 7.15 Changing values in a running total */

-- consider view as follows
drop view if exists acct_transactions;
-- initially created view name with typo; drop if exists
drop view if exists acct_transactionas;
create view acct_transactions (id, amt, trx) as
    select 1, 100, 'pr' from dual union all
    select 2, 100, 'pr' from dual union all
    select 3, 50, 'py' from dual union all
    select 4, 100, 'pr' from dual union all
    select 5, 200, 'py' from dual union all
    select 6, 50, 'py' from dual
;

select * from acct_transactions;

-- create result set with transaction type, amt, and running balance
select
    case trx
        when 'pr' then 'purchase'
        when 'py' then 'payment'
    end as trx_type
    ,amt
    ,(select sum(case trx
                    when 'pr' then amt
                    when 'py' then amt * -1
                 end)
      from acct_transactions at2
      where at2.id <= acct_transactions.id
      ) as balance
from acct_transactions
order by id
;
