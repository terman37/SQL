/*
	total values of sales for year 2014,2015,2016
*/

-- First Way using union
SELECT (SELECT
	sum(il.Quantity * il.UnitPrice)
FROM
	sales.Invoices as i
	, sales.InvoiceLines as il
WHERE
	i.InvoiceID = il.InvoiceID
	AND year(i.InvoiceDate)=2014) AS S2014,
(SELECT
	sum(il.Quantity * il.UnitPrice)
FROM
	sales.Invoices as i
	, sales.InvoiceLines as il
WHERE
	i.InvoiceID = il.InvoiceID
	AND year(i.InvoiceDate)=2015) AS S2015,
(SELECT
	sum(il.Quantity * il.UnitPrice)
FROM
	sales.Invoices as i
	, sales.InvoiceLines as il
WHERE
	i.InvoiceID = il.InvoiceID
	AND year(i.InvoiceDate)=2016) AS S2016
;

-- Second way using CASE statement
SELECT
	SUM(CASE WHEN 
			YEAR(i.InvoiceDate) = 2014
		THEN 
			il.Quantity * il.UnitPrice
		END
	) AS S2014
	, SUM(CASE WHEN 
			YEAR(i.InvoiceDate) = 2015
		THEN 
			il.Quantity * il.UnitPrice
		END
	) AS S2015
	, SUM(CASE WHEN 
			YEAR(i.InvoiceDate) = 2016
		THEN 
			il.Quantity * il.UnitPrice
		END
	) AS S2016
FROM
	sales.Invoices as i
	, sales.InvoiceLines as il
WHERE
	i.InvoiceID = il.InvoiceID
	AND YEAR(i.InvoiceDate) BETWEEN 2014 AND 2016
;


SELECT
	YEAR(i.InvoiceDate) as y
	, sum(il.Quantity * il.UnitPrice) as total_sales
FROM
	sales.Invoices as i
	, sales.InvoiceLines as il
WHERE
	i.InvoiceID = il.InvoiceID
GROUP BY
	YEAR(i.InvoiceDate)
HAVING 
	YEAR(i.InvoiceDate) IN (2014,2015,2016)
ORDER BY
	y

;