
/*
identify orders not converted into a sale
--> Existence query
*/

SELECT
	o.*
FROM
	Sales.Orders as o
WHERE
	NOT EXISTS 
	(
		SELECT 
			*
		FROM 
			Sales.Invoices as i
		WHERE
			i.OrderID = o.orderID
	)