/* Chapter 13: Hierarchical Queries */

/* 13.1 Expressing a parent-child relationship */

-- Display each employee's name along with name of manager

-- NB: Book example result set combines employee and manager
--     name into one line, e.g., "FORD works for JONES"

-- first retrieve the info
select
    e.ename as emp_name
    ,e2.ename as mgr_name
from emp e
left join emp e2
on e2.empno = e.mgr
;

-- combine emp and mgr name into one row
-- NB: While book example uses inner join,
--     which excludes employees without a manager
--     I am using an outer join that will include
--     those employees (there is only one) and 
--     handle them.
select
    concat(e.ename, ' ', 'works for', ' ', 
        case when e2.ename is null then 'NO ONE' 
        else e2.ename end) as emp_mgr_relationship
from emp e
left join emp e2
on e2.empno = e.mgr
;

-- alternate approach uses a subquery instead of a self-join
-- demonstrate with the two columns still separate
select
    e.ename as emp_name
    ,(select e2.ename from emp e2 where e2.empno=e.mgr) as mgr_name
from emp e
;

/* 13.2 Expressing a child-parent-grandparent relationship */

-- Show child-parent-grandparent relationship for employees

-- MySQL solution requires n - 1 self joins, where n is
-- number of levels to return
-- No general solution exists for varying numbers of levels

select
    e.ename as emp_name
    ,e2.ename as mgr_name
    ,e3.ename as mgr_mgr_name
from emp e
join emp e2 on e.mgr=e2.empno
join emp e3 on e2.mgr=e3.empno
;

-- solution with outer joins for up to 3 levels
-- but allowing for fewer

select
    e.ename as emp_name
    ,e2.ename as mgr_name
    ,e3.ename as mgr_mgr_name
from emp e
left join emp e2 on e.mgr=e2.empno
left join emp e3 on e2.mgr=e3.empno
;

-- combine the three ename columns into one string
-- of format "emp_name --> mgr_name --> mgr_mgr_name"
select
    e.ename as emp_name
    ,e2.ename as mgr_name
    ,e3.ename as mgr_mgr_name
from emp e
left join emp e2 on e.mgr=e2.empno
left join emp e3 on e2.mgr=e3.empno
;

/* 13.3 Creating a hierarchical view of a table */

-- return emp-mgr paths for all emps
-- e.g.:
--  KING
--  KING - BLAKE - ALLEN
--  KING - BLAKE - ALLEN - JAMES
--  ...
--  KING - JONES - SCOTT - ADAMS

select ename as emp_tree
from emp where mgr is null

union all

select concat(a.ename, " - ", b.ename)
from emp a
join
emp b on a.empno=b.mgr
where a.mgr is null

union all

select concat(a.ename, ' * ', b.ename, ' * ', c.ename)
from emp a
join 
emp b on a.empno=b.mgr
left join 
emp c on b.empno=c.mgr
where a.ename = 'KING'

union all

select concat(a.ename, ' / ', b.ename, ' / ', c.ename, ' / ', d.ename)
from emp a
join emp b on a.empno = b.mgr
join emp c on b.empno = c.mgr
left join emp d on c.empno = d.mgr
where a.ename = 'KING'
;

-- wrap query in outer query to remove nulls
-- make name separator consistent
select emp_tree
from (
    select ename as emp_tree
    from emp where mgr is null

    union all

    select concat(a.ename, " - ", b.ename)
    from emp a
    join
    emp b on a.empno=b.mgr
    where a.mgr is null

    union all

    select concat(a.ename, ' - ', b.ename, ' - ', c.ename)
    from emp a
    join 
    emp b on a.empno=b.mgr
    left join 
    emp c on b.empno=c.mgr
    where a.ename = 'KING'

    union all

    select concat(a.ename, ' - ', b.ename, ' - ', c.ename, ' - ', d.ename)
    from emp a
    join emp b on a.empno = b.mgr
    join emp c on b.empno = c.mgr
    left join emp d on c.empno = d.mgr
    where a.ename = 'KING'
) x
where emp_tree is not null
order by 1;

-- examine last portion of query
-- with and without the left join
select concat(a.ename, ' - ', b.ename, ' - ', c.ename, ' - ', d.ename)
    from emp a
    join emp b on a.empno = b.mgr
    join emp c on b.empno = c.mgr
    left join emp d on c.empno = d.mgr
    where a.ename = 'KING'
    ;

select concat(a.ename, ' - ', b.ename, ' - ', c.ename, ' - ', d.ename)
    from emp a
    join emp b on a.empno = b.mgr
    join emp c on b.empno = c.mgr
    join emp d on c.empno = d.mgr
    where a.ename = 'KING'
    ;

/* 13.4 Finding all child rows for a given parent row */

-- In MySQL, must know in advance how many nodes deep
-- a hierarchy goes
-- For example, find all employees who report to Jones
-- who has 3 levels of reports

-- solution uses an inline query
-- write that query first
select 
    a.ename as root
    ,b.ename as branch
    ,c.ename as leaf
from emp a
join emp b on a.empno = b.mgr
join emp c on b.empno = c.mgr
where a.ename = 'JONES'
;

-- now unpivot the 3 columns into 1 column with 6 rows
-- via an outer query with a case statement
select
    case t100.id
        when 1 then root
        when 2 then branch
        else leaf
    end as jones_subordinates
from (
select 
    a.ename as root
    ,b.ename as branch
    ,c.ename as leaf
from emp a
join emp b on a.empno = b.mgr
join emp c on b.empno = c.mgr
where a.ename = 'JONES'
);