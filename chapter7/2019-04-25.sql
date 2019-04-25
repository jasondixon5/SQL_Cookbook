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

