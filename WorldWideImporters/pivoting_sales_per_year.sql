/*
	total values of sales for year 2014,2015,2016
*/

SELECT
	year(i.InvoiceDate) as y
	, sum(il.Quantity * il.UnitPrice) as total_sales
FROM
	sales.Invoices as i
	, sales.InvoiceLines as il
WHERE
	i.InvoiceID = il.InvoiceID
GROUP BY
	year(i.InvoiceDate)
HAVING 
	year(i.InvoiceDate) IN (2014,2015,2016)
ORDER BY
	y