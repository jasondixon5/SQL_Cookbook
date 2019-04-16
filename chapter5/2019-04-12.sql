/* CHAPTER 5: METADATA QUERIES */

/* 5.1 Listing tables in a schema */

SELECT table_name
FROM information_schema.tables
WHERE table_schema = "sql_cookbook"
;

/* 5.2 Listing a table's columns */

SELECT
    column_name,
    data_type,
    ordinal_position
FROM information_schema.columns
WHERE table_schema = "sql_cookbook"
AND table_name = "emp"
;

-- use show columns command on this table,
-- to see what other columns are available apart
-- from what book suggests
SHOW columns from information_schema.columns
;

/* 5.3 Listing indexed columns for a table */
SHOW index FROM emp;

/* 5.4 Listing constraints on a table */

SELECT
    a.table_name,
    a.constraint_name,
    b.column_name,
    a.constraint_type
FROM information_schema.table_constraints a,
    information_schema.key_column_usage b
WHERE a.table_name = "emp"
AND a.table_schema = "sql_cookbook"
AND a.table_name = b.table_name
AND a.table_schema = b.table_schema
AND a.constraint_name = b.constraint_name
;

/* 5.5 Listing foreign keys without corresponding indexes */

-- no specific code provided
-- execute show index for a table
-- Query information_schema.key_column_usage to see
-- foreign keys for a table
-- If a column is in key_column_usage but not index,
-- you know column is not indexed

/* 5.6 Using SQL to generate SQL */

-- Create statements to count number of rows in tables

-- first get list of tables
SELECT table_name
FROM information_schema.tables
WHERE table_schema = "sql_cookbook"
;

-- then add statement to create string that inserts
-- table name 
SELECT CONCAT(
    'select count(*) from ', table_name, ';'
    ) AS sql_statements
FROM
    (SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = "sql_cookbook"
    ) table_list
;

-- generate insert statements for an insert script
-- to repopulate dept table
-- (NB: book example uses emp table)
SELECT * FROM DEPT;

SELECT CONCAT(
    'insert into dept(deptno, dname, loc)
    values(',
    deptno,
    ', ''',
    dname,
    '''',
    ', ',
    '''',
    loc,
    '''',
    ');'
) AS sql_statements
FROM dept
;
