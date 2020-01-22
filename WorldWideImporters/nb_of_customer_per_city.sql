/*
	provide number of customers per city
*/

SELECT 
	COUNT(1)
	, cu.PostalCityID
FROM 
	Sales.Customers as cu
GROUP BY 
	cu.PostalCityID