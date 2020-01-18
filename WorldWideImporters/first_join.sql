-- Q1 Provide all custid, name, and city name
	
-- Q2 Provide all custid, name, and city name
-- and the name and city name of customer to invoice.
-- self/auto join: the data we seek is in the same table

SELECT 
	Cust.CustomerID, 
	Cust.CustomerName, 
	Ci.CityName as CustomerLocation,
	Cust2.CustomerName as BillToCustomerName,
	Ci2.CityName as BillingLocation
FROM 
	Sales.Customers as Cust,
	Sales.Customers as Cust2,
	[Application].Cities as Ci,
	[Application].Cities as Ci2
WHERE 
	Cust.PostalCityID = Ci.CityID
	and Cust.BillToCustomerID = Cust2.CustomerID
	and Cust2.PostalCityID = Ci2.CityID
ORDER BY 
	Cust.CustomerID
;