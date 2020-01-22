
-- SIMULATE DATA INCONSISTENCY

UPDATE Sales.Invoices
SET BillToCustomerID = 2
where CustomerID = 2