/*
all customers (id, name,city name) who have not converted orders into sales
*/

SELECT
	--DISTINCT
	c.CustomerID
	, c.CustomerName
	, ci.CityName
FROM
	Sales.Customers as c
	, Sales.Orders as o
	, [Application].Cities as ci
WHERE
	c.CustomerID = o.CustomerID 
	AND
	c.PostalCityID = ci.CityID
	AND
	NOT EXISTS
	--o.OrderID NOT IN
	(
		SELECT 
			1
			--i.OrderID
		FROM 
			Sales.Invoices as i
		WHERE
			i.OrderID = o.orderID
	)
GROUP BY
	c.CustomerID
	, c.CustomerName
	, ci.CityName
ORDER BY
	c.CustomerID