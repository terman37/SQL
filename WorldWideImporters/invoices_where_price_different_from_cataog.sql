/*
is there any lines of invoices 
where the product unit price is different 
from the catalog (warehouse.stockitem) unit price
*/

SELECT
	cat.StockItemName
	, cat.UnitPrice
	, il.UnitPrice
	, i.CustomerID
	, i.InvoiceDate
	--, sd.DealDescription
	--, sd.DiscountPercentage

FROM 
	Warehouse.StockItems as cat
	, Sales.InvoiceLines as il
	, sales.Invoices as i
	--, Sales.SpecialDeals as sd
WHERE
	i.InvoiceID = il.InvoiceID
	and cat.StockItemID = il.StockItemID
	--and cat.StockItemID = sd.StockGroupID
	and cat.UnitPrice <> il.UnitPrice

ORDER BY
	il.InvoiceID
	, i.InvoiceDate
	, i.CustomerID