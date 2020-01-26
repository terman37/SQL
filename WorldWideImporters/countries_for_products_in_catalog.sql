/*

Q1: Extract productid, productname and the coutries of manufacturing for each product in the catalog

*/

USE WideWorldImporters

SELECT 
	si.StockItemID as id
	, si.StockItemName
	, si.CustomFields
	-- not possible: breach in the first normal form.
FROM
	Warehouse.StockItems as SI
	
--WHERE
	
ORDER BY
	SI.StockItemID