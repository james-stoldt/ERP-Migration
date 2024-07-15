--------------------------------------------------------------------------------------------------------------------------------------
--Author:	James Stoldt
--Date:		July 15, 2024
--DBMS: 	IBM DB2
--------------------------------------------------------------------------------------------------------------------------------------
--Searches through all table name DESCRIPTIONS within all schemas

--This is a useful trick to find tables by description when you don't know their names

--See https://www.ibm.com/docs/en/i/7.5?topic=views-i-catalog-tables for more information

--------------------------------------------------------------------------------------------------------------------------------------

--This example searches for tables in the schema SCHEMA123 that contain the word "order" in their DESCRIPTION (case insensitive):

--SELECT
--    TABLE_SCHEMA,
--    TABLE_NAME,
--    TABLE_TEXT

--FROM
--    QSYS2.SYSTABLES
 
--WHERE
--    UPPER(TABLE_TEXT) LIKE UPPER('%order%')
--        AND
--    TABLE_SCHEMA = 'SCHEMA123';

--Sample results:

--TABLE_SCHEMA		TABLE_NAME		TABLE_TEXT
---------------------------------------------------------------
--SCHEMA123			COHEADER		Customer Order Header File
--SCHEMA123			CODETAIL		Customer Order Detail File
--SCHEMA123			POHEADER		Purchase Order Header File
--SCHEMA123			PODETAIL		Purchase Order Detail File

--------------------------------------------------------------------------------------------------------------------------------------

SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TEXT

FROM
    QSYS2.SYSTABLES
   
WHERE
    UPPER(TABLE_TEXT) LIKE UPPER('%TABLE_NAME_KEYWORD_HERE%')
        AND
    TABLE_SCHEMA = 'SCHEMA_NAME_HERE';
