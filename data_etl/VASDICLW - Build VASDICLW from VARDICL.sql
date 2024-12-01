--------------------------------------------------------------------------------------------------------------------------------------
-- Author:  James Stoldt
-- Date:    July 15, 2024
-- DBMS:    IBM DB2
-- Query:	  Build VASDICLW from VARDICL
--------------------------------------------------------------------------------------------------------------------------------------
-- VASDICLW is an extension table in the F60MODSDTA schema. This table was created in response to a change request we submitted, 
-- because we needed the ability to warn or suppress warnings for Order Entry users if an item is out of stock, setting it at 
-- the division and class level. This table is used to flag each item division/class with out-of-stock warning 'Y' or 'N'.

-- This query ensures that VASDICLW contains entries for every record in the Division/Class Master table (VARDICL).
-- If a corresponding record does not already exist in VASDICLW, it is inserted.

-- This file contains two queries:
-- 1. A static query merging records from VARDICL into VASDICLW in the test environment.
-- 2. A dynamic query performing the same merge operation, in the environment specified by variables at runtime.

-- This query should be executed closely before go-live. Post go-live, it is expected that the users will maintain this table
-- using the Division/Class maintenance program whenever creating or modifying Division/Class records. In the event users fail
-- to maintain the table properly, this query could be used (with care) to fill in missing records in VASDICLW.
--------------------------------------------------------------------------------------------------------------------------------------

-- Merge records from VARDICL into VASDICLW
MERGE INTO T60MODSDTA.VASDICLW AS TARGET
USING T60FILES.VARDICL AS SOURCE
ON
	SOURCE.RNDEL = TARGET.RWDEL
	AND SOURCE.RNCMP = TARGET.RWCMP
	AND SOURCE.RNDIV = TARGET.RWDIV
	AND SOURCE.RNCLAS = TARGET.RWCLAS

-- Insert new records into VASDICLW if no match is found
WHEN NOT MATCHED THEN
	INSERT
	(	
		RWDEL, RWCMP, RWDIV, RWCLAS, RWOSWRN,
		RWCCTD, RWCCTT, RWCCTU, RWCCTP,
		RWLCGD, RWLCGT, RWLCGU, RWLCGP
	)
	VALUES
	(
		SOURCE.RNDEL, SOURCE.RNCMP, SOURCE.RNDIV, SOURCE.RNCLAS, 'Y',
    VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYYYMMDD'), VARCHAR_FORMAT(CURRENT TIMESTAMP, 'HHMMSS'), 'SQL', 'SQL',
    VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYYYMMDD'), VARCHAR_FORMAT(CURRENT TIMESTAMP, 'HHMMSS'), 'SQL', 'SQL'
	)
	
	-- RWOSWRN is the warn Y/N field
	
	-- RWCCTD, RWCCTT, RWCCTU, and RWCCTP are normally used to track the date, timestamp, IBM user, and IBM program name that created
	-- the record. These values are normally populated by the program creating/maintaining the record. However, since we are populating
	-- the table manually with SQL, we need to provide default values. These values are essentially placeholders. 
	-- I default the user and program to 'SQL'. Date and time fields default to current date/time.
	
	-- RWLCGD, RWLCGT, RWLCGU, and RWLCGP follow the same convention, but keep track of "last changed" instead of "created".
	
-------------------------------------------------------------------
-- The following block contains dynamic SQL to switch easily between the test and production environments.
-- It dynamically constructs and executes the same merge operation as above, but with schema names set at runtime.

BEGIN
    DECLARE schemaMain VARCHAR(128);
    DECLARE schemaMods VARCHAR(128);
    DECLARE sqlX CLOB(20000);

	  -- ************************************** TEST ENVIRONMENT SCHEMAS **************************************
	  SET schemaMain = 'T60FILES';
    SET schemaMods = 'T60MODSDTA';

	  -- *********************************** PRODUCTION ENVIRONMENT SCHEMAS ***********************************
    -- SET schemaMain = 'F60FILES';
    -- SET schemaMods = 'F60MODSDTA';

    SET sqlX = 'MERGE INTO ' || schemaMods || '.VASDICLW AS TARGET
                   USING ' || schemaMain || '.VARDICL AS SOURCE
                   ON
                       SOURCE.RNDEL = TARGET.RWDEL
                       AND SOURCE.RNCMP = TARGET.RWCMP
                       AND SOURCE.RNDIV = TARGET.RWDIV
                       AND SOURCE.RNCLAS = TARGET.RWCLAS
                   WHEN NOT MATCHED THEN
                       INSERT
                       (   
							            RWDEL, RWCMP, RWDIV, RWCLAS, RWOSWRN,
							            RWCCTD, RWCCTT, RWCCTU, RWCCTP,
							            RWLCGD, RWLCGT, RWLCGU, RWLCGP
                       )
                       VALUES
                       (
                           SOURCE.RNDEL, SOURCE.RNCMP, SOURCE.RNDIV, SOURCE.RNCLAS, ''Y'',
                           VARCHAR_FORMAT(CURRENT TIMESTAMP, ''YYYYMMDD''), VARCHAR_FORMAT(CURRENT TIMESTAMP, ''HHMMSS''), ''SQL'', ''SQL'',
                           VARCHAR_FORMAT(CURRENT TIMESTAMP, ''YYYYMMDD''), VARCHAR_FORMAT(CURRENT TIMESTAMP, ''HHMMSS''), ''SQL'', ''SQL''
                       )';

    EXECUTE IMMEDIATE sqlX;
END;
