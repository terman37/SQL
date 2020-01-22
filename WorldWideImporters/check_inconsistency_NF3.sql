USE WideWorldImporters

-- DESCRIPTION: CHECK INCONSISTENCY
-- Q1: EXTRACT ALL INVOICES ID, ATTACHED CUST ID, BILL TO CUST ID, 
-- AND THE VALUE OF BILL TO CUST ID IN CUSTOMER TABLE

SELECT 
	inv.InvoiceID,
	inv.CustomerID,
	inv.BillToCustomerID,
	cust.BillToCustomerID
FROM 
	sales.Invoices as inv,
	sales.Customers as cust
WHERE
	inv.CustomerID = cust.CustomerID
	and inv.BillToCustomerID <> cust.BillToCustomerID