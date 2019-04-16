/* Chapter 5: Metadata queries */

/* 5.1 Listing tables in a schema */

-- list all the tables in a given schema (db)
select table_name
from information_schema.tables
where table_schema = "sql_cookbook"
;

/* 5.2 Listing a table's columns */

-- list all columns in a table along with other helpful info
select
     column_name
    ,data_type
    ,ordinal_position
from information_schema.columns
where table_schema = "sql_cookbook"
and table_name = "emp"
;

select
     column_name
    ,table_name
from information_schema.columns
where table_schema = "sql_cookbook"
;

select
    *
from information_schema.columns
where table_schema = "sql_cookbook"
and table_name = "t1"
;

show columns from t1;

select *
from information_schema.columns
limit 1
;

/* Columns that might be of interest:
table_schema
table_name
column_name
ordinal_position
column_default
is_nullable
data_type
character_maximum_length (nb: also obtainable from column_type)
numeric_precision (nb: also obtainable from column_type)
datetime_precision
character_set_name
column_type
column_key
extra
privileges
column_comment
generation_expression
*/

select
    table_name
    ,column_name
    -- ,generation_expression
    ,column_type
    ,datetime_precision
    ,numeric_precision
    ,numeric_scale
    ,character_maximum_length
from information_schema.columns
where table_schema = "sql_cookbook"
and table_name in ("acct_transactions", "emp")
;

/* Listing indexed columns for a table */

-- mysql solution
-- table name
show index from emp
;

-- no indexes on this db yet,
-- so create one
create index ix_emp_deptno on emp (deptno)
;
/*
Note that index can be created only once. Subsequent
runs of script give following error message:
ERROR 1061 (42000): Duplicate key name 'ix_emp_deptno'
*/
show index from emp
;

