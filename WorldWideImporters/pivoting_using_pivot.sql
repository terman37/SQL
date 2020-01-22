SELECT * FROM   
(
    SELECT 
        il.Quantity * il.UnitPrice as totprice, 
        concat('Q',datepart(quarter,I.InvoiceDate)) as q
    FROM
		sales.Invoices as i
		, sales.InvoiceLines as il
	WHERE
		i.InvoiceID = il.InvoiceID
		and YEAR(i.InvoiceDate) = 2014
) t 
PIVOT(
    sum(totprice) 
    FOR q in ([Q1],[Q2],[Q3],[Q4])
) AS pivot_table;