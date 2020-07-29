USE SQLPlayGroundA19

-- By default, isolation is "read commited" --> TABLE LOCK
-- SET TRANSACTION ISOLATION LEVEL SNAPSHOT; 
-- CAN BE SET TO "snapshot" LEVEL -- > ROW LEVEL LOCK
-- Needs to be enabled for the DB / properties / Options: 
-- - Allow snapshot isolation

BEGIN TRANSACTION
-- Opens a new transaction in the RDBMS
-- Everything here happens in the context of the transaction

	SELECT * FROM dummy_table;

	DELETE FROM dummy_table;

	SELECT * FROM dummy_table;

-- COMMIT;
ROLLBACK;