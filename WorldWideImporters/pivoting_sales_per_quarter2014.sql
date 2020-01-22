/*
	Sales report by quarters for 2014
*/

SELECT
	SUM(CASE WHEN 
			--SQLSERVER SPECIFIC FUNCTION	
			DATEPART(quarter, I.InvoiceDate) = 1 
			--MONTH(i.InvoiceDate) BETWEEN 1 AND 3
		THEN 
			il.Quantity * il.UnitPrice
		END
	) AS Q1
	, SUM(CASE WHEN 
			MONTH(i.InvoiceDate) BETWEEN 4 AND 6
		THEN 
			il.Quantity * il.UnitPrice
		END
	) AS Q2
	, SUM(CASE WHEN 
			MONTH(i.InvoiceDate) BETWEEN 7 AND 9
		THEN 
			il.Quantity * il.UnitPrice
		END
	) AS Q3
	, SUM(CASE WHEN 
			MONTH(i.InvoiceDate) BETWEEN 10 AND 12
		THEN 
			il.Quantity * il.UnitPrice
		END
	) AS Q4 
FROM
	sales.Invoices as i
	, sales.InvoiceLines as il
WHERE
	i.InvoiceID = il.InvoiceID
	AND YEAR(i.InvoiceDate) = 2014
;