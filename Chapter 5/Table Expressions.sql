---------------------------------------------------------------------
-- Derived Tables
---------------------------------------------------------------------
/*
    Inner query (subquery) :
        query CustomerId, CustomerCompanyName
        from customerTable that 
        customers CustomerCountry in USA
    The result of this inner query is to create a derived table with the alias USACusts. 
    This derived table contains only the columns CustomerId and CustomerCompanyName for USA customers.
*/
USE Northwinds2022TSQLV7;
SELECT *
FROM (SELECT CustomerId, CustomerCompanyName
      FROM Sales.Customer
      WHERE CustomerCountry = N'USA') AS USACusts;

---------------------------------------------------------------------
-- Assigning Column Aliases
---------------------------------------------------------------------

-- Following fails
/*
SELECT
  YEAR(orderdate) AS orderyear,
  COUNT(DISTINCT customerId) AS numcusts
FROM Sales.[Order]
GROUP BY orderyear;
*/
/*
    Inner query (subquery) :
        query CustomerId, year of orderdate
        from order table that 
    The result of this inner query is to create a derived table with the alias D. 
    This derived table contains only the columns ustomerId, year of orderdate
    from the derived table 
        query orderyear, count the customerId no duplicates 
        for each order year
*/
GO 
-- Listing 5-1 Query with a Derived Table using Inline Aliasing Form
SELECT orderyear, COUNT(DISTINCT CustomerId) AS numcusts
FROM (SELECT YEAR(orderdate) AS orderyear, CustomerId
      FROM Sales.[Order]) AS D
GROUP BY orderyear;

/*
    From the order table 
    query year of order data 
    with 
    counting customerId no duplicates 
    All rows with the same year will be combined into a single group,
*/

SELECT YEAR(orderdate) AS orderyear, COUNT(DISTINCT CustomerId) AS numcusts
FROM Sales.[Order]
GROUP BY YEAR(orderdate);

/*
Inner query:
    gets the orderdate , customerid 
    from the order table.
query orderYear, count customerId from the drived table 
group each by orderyear
*/
-- External column aliasing
SELECT orderyear, COUNT(DISTINCT customerId) AS numcusts
FROM (SELECT YEAR(orderdate), CustomerId
      FROM Sales.[Order]) AS D(orderyear, customerId)
GROUP BY orderyear;
GO

---------------------------------------------------------------------
-- Using Arguments
---------------------------------------------------------------------

/*
    creating a variable called @empid which equal to 3
*/
-- Yearly Count of customer handled by Employee 3
DECLARE @empid AS INT = 3;

/*
Inner Query :
    gets year of orderdata , customer id from the order table
    that customer id = empId variable which is 3
    from this driven table query 
    orderYear , count customerid 
    query that by each year 
*/
SELECT orderyear, COUNT(DISTINCT CustomerId) AS numcusts
FROM (SELECT YEAR(orderdate) AS orderyear, CustomerId
      FROM Sales.[Order]
      WHERE EmployeeId = @empid) AS D
GROUP BY orderyear;
GO

---------------------------------------------------------------------
-- Nesting
---------------------------------------------------------------------

-- Listing 5-2 Query with Nested Derived Tables
/*
    Nested tables 
    This is a nested query that first selects the year of each order using YEAR(orderdate) and the customer ID for that order. 
    hen counts the number of unique customer IDs (COUNT(DISTINCT CustomerId)) for each year (GROUP BY orderyear). 
    Finally, it renames the count as numcusts and aliases the subquery as D2.
*/

SELECT orderyear, numcusts
FROM (SELECT orderyear, COUNT(DISTINCT CustomerId) AS numcusts
      FROM (SELECT YEAR(orderdate) AS orderyear, CustomerId
            FROM Sales.[Order]) AS D1
      GROUP BY orderyear) AS D2
WHERE numcusts > 70;

/*
    query that retrieves the order year and the number of unique customers who placed orders in that year,
    but only for the years where the number of customers is greater than 70.
*/
SELECT YEAR(orderdate) AS orderyear, COUNT(DISTINCT CustomerId) AS numcusts
FROM Sales.[Order]
GROUP BY YEAR(orderdate)
HAVING COUNT(DISTINCT CustomerId) > 70;

---------------------------------------------------------------------
-- Multiple References
---------------------------------------------------------------------
/*
    This is a SQL query that calculates the number of unique customers who placed orders in each year,
    along with the growth rate of the number of customers from the previous year, using a left outer join to compare each year's results with the previous year's results.
    This selects the current year (Cur.orderyear), the number of unique customers who placed orders in the current year (Cur.numcusts),
    the number of unique customers who placed orders in the previous year (Prv.numcusts),
    and the growth rate in the number of customers from the previous year to the current year (Cur.numcusts - Prv.numcusts).
*/
-- Listing 5-3 Multiple Derived Tables Based on the Same Query
SELECT Cur.orderyear, 
  Cur.numcusts AS curnumcusts, Prv.numcusts AS prvnumcusts,
  Cur.numcusts - Prv.numcusts AS growth
FROM (SELECT YEAR(orderdate) AS orderyear,
        COUNT(DISTINCT CustomerId) AS numcusts
      FROM Sales.[Order]
      GROUP BY YEAR(orderdate)) AS Cur
  LEFT OUTER JOIN
     (SELECT YEAR(orderdate) AS orderyear,
        COUNT(DISTINCT CustomerId) AS numcusts
      FROM Sales.[Order]
      GROUP BY YEAR(orderdate)) AS Prv
    ON Cur.orderyear = Prv.orderyear + 1;

---------------------------------------------------------------------
-- Common Table Expressions
---------------------------------------------------------------------
/*
query that creates a Common Table Expression (CTE) named USACusts, 
which contains the CustomerId and CustomerCompanyName of all customers located in the USA, 
and then selects all columns from the USACusts CTE.
This selects all columns from the USACusts CTE. This will output the CustomerId and CustomerCompanyName for all customers located in the USA.
this query creates a CTE that contains the CustomerId and CustomerCompanyName of all customers located in the USA, and then selects all columns from the CTE.
*/
WITH USACusts AS
(
  SELECT CustomerId, CustomerCompanyName
  FROM Sales.Customer
  WHERE CustomerCountry = N'USA'
)
SELECT * FROM USACusts;

---------------------------------------------------------------------
-- Assigning Column Aliases
---------------------------------------------------------------------

-- Inline column aliasing
/*
    creates a common table expression (CTE) named 'C'.
    which contains the year of each order YEAR(orderdate) and 
    the corresponding CustomerId for each order from the Sales.[Order] table. 
*/
WITH C AS
(
  SELECT YEAR(orderdate) AS orderyear, CustomerId
  FROM Sales.[Order]
)
SELECT orderyear, COUNT(DISTINCT CustomerId) AS numcusts
FROM C
GROUP BY orderyear;

/*
This creates a CTE named C that retrieves the year of each order (YEAR(orderdate)) and the corresponding CustomerId for each order from the Sales.[Order] table.
It renames the year as orderyear. This will allow us to group the orders by year and count the number of unique customers for each year.
*/
-- External column aliasing
WITH C(orderyear, customerId) AS
(
  SELECT YEAR(orderdate), CustomerId
  FROM Sales.[Order]
)
SELECT orderyear, COUNT(DISTINCT customerId) AS numcusts
FROM C
GROUP BY orderyear;
GO

---------------------------------------------------------------------
-- Using Arguments
---------------------------------------------------------------------

DECLARE @empid AS INT = 3;

WITH C AS
(
  SELECT YEAR(orderdate) AS orderyear, CustomerId
  FROM Sales.[Order]
  WHERE EmployeeId = @empid
)
SELECT orderyear, COUNT(DISTINCT CustomerId) AS numcusts
FROM C
GROUP BY orderyear;
GO

---------------------------------------------------------------------
-- Defining Multiple CTEs
---------------------------------------------------------------------

WITH C1 AS
(
  SELECT YEAR(orderdate) AS orderyear, CustomerId
  FROM Sales.[Order]
),
C2 AS
(
  SELECT orderyear, COUNT(DISTINCT CustomerId) AS numcusts
  FROM C1
  GROUP BY orderyear
)
SELECT orderyear, numcusts
FROM C2
WHERE numcusts > 70;

---------------------------------------------------------------------
-- Multiple References
---------------------------------------------------------------------

WITH YearlyCount AS
(
  SELECT YEAR(orderdate) AS orderyear,
    COUNT(DISTINCT CustomerId) AS numcusts
  FROM Sales.[Order]
  GROUP BY YEAR(orderdate)
)
SELECT Cur.orderyear, 
  Cur.numcusts AS curnumcusts, Prv.numcusts AS prvnumcusts,
  Cur.numcusts - Prv.numcusts AS growth
FROM YearlyCount AS Cur
  LEFT OUTER JOIN YearlyCount AS Prv
    ON Cur.orderyear = Prv.orderyear + 1;

--------------------------------------------------------
-- Views
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Views Described
---------------------------------------------------------------------

-- Creating USACusts View
DROP VIEW IF EXISTS Sales.USACusts;
GO
CREATE VIEW Sales.USACusts
AS

SELECT
  CustomerId, CustomerCompanyName, CustomerContactName, CustomerContactTitle, CustomerAddress,
  CustomerCity, CustomerRegion, CustomerPostalCode, CustomerCountry, CustomerPhoneNumber, CustomerFaxNumber
FROM Sales.Customer
WHERE CustomerCountry = N'USA';
GO

SELECT CustomerId, CustomerCompanyName
FROM Sales.USACusts;
GO

---------------------------------------------------------------------
-- Views and ORDER BY
---------------------------------------------------------------------

-- ORDER BY in a View is not Allowed
/*
ALTER VIEW Sales.USACusts
AS

SELECT
  customerId, CustomerCompanyName, CustomerContactName, CustomerContactTitle, CustomerAddress,
  CustomerCity, CustomerRegion, CustomerPostalCode, CustomerCountry, CustomerPhoneNumber, CustomerFaxNumber
FROM Sales.customer
WHERE CustomerCountry = N'USA'
ORDER BY CustomerRegion;
GO
*/

-- Instead, use ORDER BY in Outer Query
SELECT CustomerId, CustomerCompanyName, CustomerRegion
FROM Sales.USACusts
ORDER BY CustomerRegion;
GO

-- Do not Rely on TOP 
ALTER VIEW Sales.USACusts
AS

SELECT TOP (100) PERCENT
  CustomerId, CustomerCompanyName, CustomerContactName, CustomerContactTitle, CustomerAddress,
  CustomerCity, CustomerRegion, CustomerPostalCode, CustomerCountry, CustomerPhoneNumber, CustomerFaxNumber
FROM Sales.Customer
WHERE CustomerCountry = N'USA'
ORDER BY CustomerRegion;
GO

-- Query USACusts
SELECT CustomerId, CustomerCompanyName, CustomerRegion
FROM Sales.USACusts;
GO

-- DO NOT rely on OFFSET-FETCH, even if for now the engine does return rows in rder
ALTER VIEW Sales.USACusts
AS

SELECT 
  CustomerId, CustomerCompanyName, CustomerContactName, CustomerContactTitle, CustomerAddress,
  CustomerCity, CustomerRegion, CustomerPostalCode, CustomerCountry, CustomerPhoneNumber, CustomerFaxNumber
FROM Sales.Customer
WHERE CustomerCountry = N'USA'
ORDER BY CustomerRegion
OFFSET 0 ROWS;
GO

-- Query USACusts
SELECT CustomerId, CustomerCompanyName, CustomerRegion
FROM Sales.USACusts;
GO

---------------------------------------------------------------------
-- View Options
---------------------------------------------------------------------

---------------------------------------------------------------------
-- ENCRYPTION
---------------------------------------------------------------------

ALTER VIEW Sales.USACusts
AS

SELECT
  CustomerId, CustomerCompanyName, CustomerContactName, CustomerContactTitle, CustomerAddress,
  CustomerCity, CustomerRegion, CustomerPostalCode, CustomerCountry, CustomerPhoneNumber, CustomerFaxNumber
FROM Sales.Customer
WHERE CustomerCountry = N'USA';
GO

SELECT OBJECT_DEFINITION(OBJECT_ID('Sales.USACusts'));
GO

ALTER VIEW Sales.USACusts WITH ENCRYPTION
AS

SELECT
  CustomerId, CustomerCompanyName, CustomerContactName, CustomerContactTitle, CustomerAddress,
  CustomerCity, CustomerRegion, CustomerPostalCode, CustomerCountry, CustomerPhoneNumber, CustomerFaxNumber
FROM Sales.Customer
WHERE CustomerCountry = N'USA';
GO

SELECT OBJECT_DEFINITION(OBJECT_ID('Sales.USACusts'));

EXEC sp_helptext 'Sales.USACusts';
GO

---------------------------------------------------------------------
-- SCHEMABINDING
---------------------------------------------------------------------

ALTER VIEW Sales.USACusts WITH SCHEMABINDING
AS

SELECT
  customerId, CustomerCompanyName, CustomerContactName, CustomerContactTitle, CustomerAddress,
  CustomerCity, CustomerRegion, CustomerPostalCode, CustomerCountry, CustomerPhoneNumber, CustomerFaxNumber
FROM Sales.Customer
WHERE CustomerCountry = N'USA';
GO

-- Try a schema change
/*
ALTER TABLE Sales.customer DROP COLUMN CustomerAddress;
*/
GO

---------------------------------------------------------------------
-- CHECK OPTION
---------------------------------------------------------------------

-- Notice that you can insert a row through the view
INSERT INTO Sales.USACusts(
  CustomerCompanyName, CustomerContactName, CustomerContactTitle, CustomerAddress,
  CustomerCity, CustomerRegion, CustomerPostalCode, CustomerCountry, CustomerPhoneNumber, CustomerFaxNumber)
 VALUES(
  N'Customer ABCDE', N'Contact ABCDE', N'Title ABCDE', N'Address ABCDE',
  N'London', NULL, N'12345', N'UK', N'012-3456789', N'012-3456789');

-- But when you query the view, you won't see it
SELECT customerId, CustomerCompanyName, CustomerCountry
FROM Sales.USACusts
WHERE CustomerCompanyName = N'Customer ABCDE';

-- You can see it in the table, though
SELECT customerId, CustomerCompanyName, CustomerCountry
FROM Sales.customer
WHERE CustomerCompanyName = N'Customer ABCDE';
GO

-- Add CHECK OPTION to the View
ALTER VIEW Sales.USACusts WITH SCHEMABINDING
AS

SELECT
  customerId, CustomerCompanyName, CustomerContactName, CustomerContactTitle, CustomerAddress,
  CustomerCity, CustomerRegion, CustomerPostalCode, CustomerCountry, CustomerPhoneNumber, CustomerFaxNumber
FROM Sales.Customer
WHERE CustomerCountry = N'USA'
WITH CHECK OPTION;
GO

-- Notice that you can't insert a row through the view
/*
INSERT INTO Sales.USACusts(
  CustomerCompanyName, CustomerContactName, CustomerContactTitle, CustomerAddress,
  CustomerCity, CustomerRegion, CustomerPostalCode, CustomerCountry, CustomerPhoneNumber, CustomerFaxNumber)
 VALUES(
  N'Customer FGHIJ', N'Contact FGHIJ', N'Title FGHIJ', N'Address FGHIJ',
  N'London', NULL, N'12345', N'UK', N'012-3456789', N'012-3456789');
*/
GO

-- Cleanup
DELETE FROM Sales.customer
WHERE customerId > 91;

DROP VIEW IF EXISTS Sales.USACusts;
GO

---------------------------------------------------------------------
-- Inline User Defined Functions
---------------------------------------------------------------------

-- Creating GetCust[Order] function
USE Northwinds2022TSQLV7;
DROP FUNCTION IF EXISTS dbo.GetCust[Order];
GO
CREATE FUNCTION dbo.GetCust[Order]
  (@cid AS INT) RETURNS TABLE
AS
RETURN
  SELECT orderid, customerId, empid, orderdate, requireddate,
    shippeddate, shipperid, freight, shipname, shipCustomerAddress, shipCustomerCity,
    shipCustomerRegion, shipCustomerPostalCode, shipCustomerCountry
  FROM Sales.[Order]
  WHERE customerId = @cid;
GO

-- Test Function
SELECT orderid, customerId
FROM dbo.GetCust[Order](1) AS O;

SELECT O.orderid, O.customerId, OD.productid, OD.qty
FROM dbo.GetCust[Order](1) AS O
  INNER JOIN Sales.OrderDetails AS OD
    ON O.orderid = OD.orderid;
GO

-- Cleanup
DROP FUNCTION IF EXISTS dbo.GetCust[Order];
GO

---------------------------------------------------------------------
-- APPLY
---------------------------------------------------------------------

SELECT S.shipperid, E.empid
FROM Sales.Shippers AS S
  CROSS JOIN HR.Employees AS E;

SELECT S.shipperid, E.empid
FROM Sales.Shippers AS S
  CROSS APPLY HR.Employees AS E;

-- 3 most recent orders for each customer
SELECT C.customerId, A.orderid, A.orderdate
FROM Sales.customer AS C
  CROSS APPLY
    (SELECT TOP (3) orderid, empid, orderdate, requireddate 
     FROM Sales.[Order] AS O
     WHERE O.customerId = C.customerId
     ORDER BY orderdate DESC, orderid DESC) AS A;

-- With OFFSET-FETCH
SELECT C.customerId, A.orderid, A.orderdate
FROM Sales.customer AS C
  CROSS APPLY
    (SELECT orderid, empid, orderdate, requireddate 
     FROM Sales.[Order] AS O
     WHERE O.customerId = C.customerId
     ORDER BY orderdate DESC, orderid DESC
     OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY) AS A;

-- 3 most recent orders for each customer, preserve customers
SELECT C.customerId, A.orderid, A.orderdate
FROM Sales.customer AS C
  OUTER APPLY
    (SELECT TOP (3) orderid, empid, orderdate, requireddate 
     FROM Sales.[Order] AS O
     WHERE O.customerId = C.customerId
     ORDER BY orderdate DESC, orderid DESC) AS A;

-- Creation Script for the Function Top[Order]
DROP FUNCTION IF EXISTS dbo.Top[Order];
GO
CREATE FUNCTION dbo.Top[Order]
  (@customerId AS INT, @n AS INT)
  RETURNS TABLE
AS
RETURN
  SELECT TOP (@n) orderid, empid, orderdate, requireddate 
  FROM Sales.[Order]
  WHERE customerId = @customerId
  ORDER BY orderdate DESC, orderid DESC;
GO

SELECT
  C.customerId, C.CustomerCompanyName,
  A.orderid, A.empid, A.orderdate, A.requireddate 
FROM Sales.customer AS C
  CROSS APPLY dbo.Top[Order](C.customerId, 3) AS A;