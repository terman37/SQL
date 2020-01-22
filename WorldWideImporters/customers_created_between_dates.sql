/*
	all customers who have been created between 01/01/2013 and 15/2/2014
*/

-- This is T-SQL
DECLARE @StyleDate int;
SET @StyleDate = 103;

SELECT 
	cust.CustomerID
	, cust.CustomerName
	, cust.AccountOpenedDate
	, CONVERT(varchar,cust.AccountOpenedDate,@StyleDate) As StyledDate
FROM 
	Sales.Customers as cust
WHERE
	cust.AccountOpenedDate BETWEEN
												-- SQL SERVER SPECIFIC
		CONVERT(date,'01/01/2013',@StyleDate)	-- STYLE 103 CORRESPOND TO DD/MM/YYYY
		AND
		CONVERT(date,'15/02/2014',@StyleDate) 
ORDER BY 
	cust.AccountOpenedDate DESC