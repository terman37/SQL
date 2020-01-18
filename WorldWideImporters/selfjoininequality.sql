-- Extract all "USB food flash drive"
-- stockitemid, stockitemname, unitprice
-- more or equally expensive than "USB food flash drive - dessert 10 drive variety pack"

SELECT 
	IT1.StockItemID,
	IT1.StockItemName,
	IT1.UnitPrice
FROM 
	Warehouse.StockItems as It1,
	Warehouse.StockItems as It2
WHERE
	It1.UnitPrice >= it2.UnitPrice and
	IT2.StockItemName LIKE '%USB food%dessert 10%' and
	it1.StockItemName LIKE '%USB food%' and
	It1.StockItemID <> IT2.StockItemID
ORDER BY
	it1.UnitPrice 