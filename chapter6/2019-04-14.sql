/* Chapter 6: Working with strings */

/* 6.1 Walking a string */

-- Traverse string and return character for each row
-- Use ename 'KING'

-- Use a cross join to return a row for each letter
select
    ename
from emp
cross join t100
where ename = "KING"
and t100.id <= length(ename)
;

-- Use a cross join to return a row for each letter
-- Then index into string at appropriate place in
-- each row
select
    ename
    ,substring(ename, t100.id, 1) as letter
from emp
cross join t100
where ename = "KING"
and t100.id <= length(ename)
;

/* 6.2 Embedding quotes within string literals */

-- return g'day mate and apple's core
select
    'g''day mate' as phrase1
    ,'apple''s core' as phrase2
from dual
;

-- test if '' is null
select
    case when '' is null then 0 else 1 end
from dual
;
/*
+----------------------------------------+
| case when '' is null then 0 else 1 end |
+----------------------------------------+
|                                      1 |
+----------------------------------------+
*/

/* 6.3 Counting the occurrences of a character in a string */

-- given following string
--   '10,CLARK,MANAGER'
-- determine how many commas are in the string

-- calculate length of string without the characters
-- and subtract it from length of string with the characters

SET @char_to_count = ',';
SET @str_to_parse = '10,CLARK,MANAGER';

select
    @char_to_count as chr
    ,@str_to_parse as phrase
    ,length(@str_to_parse) as len_phrase
    ,replace(@str_to_parse, @char_to_count, '') as repl_phrase
    ,length(replace(@str_to_parse, @char_to_count, '')) as len_repl_phrase
    ,length(
        @str_to_parse
        ) - length(
            replace(@str_to_parse, @char_to_count, '')
            ) as len_diff 
from dual
;
/*
len_diff = 2
*/

-- this solution only works if character to count has length of 1
-- demonstrate:

SET @char_to_count = 'oo';
SET @str_to_parse = 'foo';

select
    @char_to_count as chr
    ,@str_to_parse as phrase
    ,length(@str_to_parse) as len_phrase
    ,replace(@str_to_parse, @char_to_count, '') as repl_phrase
    ,length(replace(@str_to_parse, @char_to_count, '')) as len_repl_phrase
    ,length(
        @str_to_parse
        ) - length(
            replace(@str_to_parse, @char_to_count, '')
            ) as len_diff 
from dual
;
/* len_diff = 2 (incorrect; character to count only appears in 
string once)
*/

-- fix is to divide len_diff by length of character to count

-- try 'oo' example again with modification
SET @char_to_count = 'oo';
SET @str_to_parse = 'foo';

select
    @char_to_count as chr
    ,@str_to_parse as phrase
    ,length(@str_to_parse) as len_phrase
    ,replace(@str_to_parse, @char_to_count, '') as repl_phrase
    ,length(replace(@str_to_parse, @char_to_count, '')) as len_repl_phrase
    ,(length(
        @str_to_parse
        ) - length(
            replace(@str_to_parse, @char_to_count, '')
            )) / length(@char_to_count)
        as count_occur
from dual
;
/*
count_occur = 1.0000
*/

-- try original problem with modified technique
-- to confirm it still returns correct answer
SET @char_to_count = ',';
SET @str_to_parse = '10,CLARK,MANAGER';

select
    @char_to_count as chr
    ,@str_to_parse as phrase
    ,length(@str_to_parse) as len_phrase
    ,replace(@str_to_parse, @char_to_count, '') as repl_phrase
    ,length(replace(@str_to_parse, @char_to_count, '')) as len_repl_phrase
    ,(length(
        @str_to_parse
        ) - length(
            replace(@str_to_parse, @char_to_count, '')
            )) / length(@char_to_count)
        as count_occur
from dual
;
/*
count_occur = 2.0000
*/

/* 6.4 Remove unwanted characters from a string */

-- remove all vowels from ename
select
    ename
    ,replace(
        replace(
        replace(
        replace(
        replace(ename, 
            'A', ''), 
            'E', ''), 
            'I', ''), 
            'O', ''), 
            'U', '') as no_vowels
from emp
;

-- remove all zeros from salary
-- note that you apparently can't cast to varchar
-- so must cast to char
select
    sal
    ,convert(sal, char(15)) as sal_str
    ,replace(
        convert(sal, char(15)),
        '0', '') as sal_str_no_zero
from emp
;

-- Note that converting to char is actually not required
select
    sal
    -- ,convert(sal, char(15)) as sal_str
    ,replace(sal, 0, '') as sal_no_zero
from emp
;

/* 6.5 Skip 
(relies on translate() func not supported in mysql) 
*/

/* 6.6 Determining whether a string is alphanumeric */

/* Relies on view with alphanumeric and other character
data.
MySQL solution to find rows with non-alphanum data:

    select data
    from V
    where data regexp '[^0-9a-zA-Z]' = 0

Solutions for an rdbms with translate() func is different:
Use translate() to convert all alphanum characters to a single
character, then identify any rows that have characters other than
that one.
*/





