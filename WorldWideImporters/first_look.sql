-- FORCE ACTIVE DB
USE WideWorldImporters

-- ABSOLUTE RULE: RESULT OF SQL QUERY IS ALWAYS A TABLE (ResultSet stored in RAM)

-- SQL Clauses are case insensitive
-- terminated by a ; --> allows multiple queries

SELECT 5 AS test;
SELECT * FROM Sales.Customers;
SELECT SUM(UnitPrice) FROM Sales.InvoiceLines;

-- Q1 Write a query levaring TWO rows in the resultset
-- COL1: integer hard coded VALUES
-- COL2: decimal hard coded VALUES
SELECT 1.3 as col1, 3.6 as col2
UNION
SELECT 5 as col1, 5.2 as col2;