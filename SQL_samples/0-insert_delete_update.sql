use SQLPlayGroundA19

-- insert values in table
INSERT INTO 
	dummy_table 
	(colB, colC)
VALUES
	('goodbye', '2020-01-20'),
	('bye bye', '2020-01-22'),
	('youhou', NULL)
;

-- update query
UPDATE dummy_table
   SET colB = 'newnew'
      ,colC = '2020-01-01'
 WHERE colB like '%bye' 
 ;

-- delete lines from table
DELETE 
FROM 
	dummy_table
WHERE
	colB = 'newnew'
;

-- std select statement
select 
	*
from 
	dummy_table
;