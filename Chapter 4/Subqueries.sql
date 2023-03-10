
---------------------------------------------------------------------
-- Scalar Subqueries
---------------------------------------------------------------------

-- Order with the maximum order ID
USE Northwinds2022TSQLV7;

/*
    create a variable @maxid and setting it's value OrderId Value from Sales.order
    and this variable can be used later on to get info
*/
DECLARE @maxid AS INT = (SELECT MAX(OrderId)
                         FROM Sales.[Order]);

/*
    Query the : OrderId, orderdate, EmployeeId, CustomerId
    that the order id equal to Top/Max order id 
*/
SELECT OrderId, orderdate, EmployeeId, CustomerId
FROM Sales.[Order]
WHERE orderid = @maxid;
GO

/*
    Query the : orderid, orderdate, EmployeeId, CustomerId
    where orderId equal to Top/Max order id 
*/

SELECT orderid, orderdate, EmployeeId, CustomerId
FROM Sales.[Order]
WHERE orderid = (SELECT MAX(O.orderid)
                 FROM Sales.[Order] AS O);

-- Scalar subquery expected to return one value
/*
    query orderid that employeeLastName contains 'C' at the begining  
*/
SELECT orderid
FROM Sales.[Order]
WHERE EmployeeId = 
  (SELECT E.EmployeeId
   FROM HumanResources.Employee AS E
   WHERE E.EmployeeLastName LIKE N'C%');
GO

/*
    query orderid that employeeLastName contains 'D' at the begining  
*/
SELECT orderid
FROM Sales.[Order]
WHERE EmployeeId = 
  (SELECT E.EmployeeId
   FROM HumanResources.Employee AS E
   WHERE E.EmployeeLastName LIKE N'D%');
GO

/*
    query orderid that employeeLastName contains 'A' at the begining  
*/
SELECT orderid
FROM Sales.[Order]
WHERE EmployeeId = 
  (SELECT E.EmployeeId
   FROM HumanResources.Employee AS E
   WHERE E.EmployeeLastName LIKE N'A%');

---------------------------------------------------------------------
-- Multi-Valued Subqueries
---------------------------------------------------------------------

/*
    select all orderid that employeeLastName contains 'D' at the begining 
*/
SELECT orderid
FROM Sales.[Order]
WHERE EmployeeId IN
  (SELECT E.EmployeeId
   FROM HumanResources.Employee AS E
   WHERE E.EmployeeLastName LIKE N'D%');

/*
    select all orderid that employeeLastName contains 'D' at the begining 
    Using Joins
*/
SELECT O.orderid
FROM HumanResources.Employee AS E
  INNER JOIN Sales.[Order] AS O
    ON E.EmployeeId = O.EmployeeId
WHERE E.EmployeeLastName LIKE N'D%';


-- Orders placed by US customers
/*
    select all : CustomerId, orderid, orderdate, EmployeeId 
    where customerId is USA 
*/
SELECT CustomerId, orderid, orderdate, EmployeeId
FROM Sales.[Order]
WHERE CustomerId IN
  (SELECT C.CustomerId
   FROM Sales.Customer AS C
   WHERE C.CustomerCountry = N'USA');

-- Customers who placed no orders
/*
    select all : CustomerId, CustomerCompanyName
    that customers that didn't place orders
*/
SELECT CustomerId, CustomerCompanyName
FROM Sales.Customer
WHERE CustomerId NOT IN
  (SELECT O.CustomerId
   FROM Sales.[Order] AS O);

-- Missing order IDs
USE TSQLV4;
DROP TABLE IF EXISTS dbo.Orders;
CREATE TABLE dbo.Orders(orderid INT NOT NULL CONSTRAINT PK_Orders PRIMARY KEY);


INSERT INTO dbo.Orders(orderid)
  SELECT orderid
  FROM Sales.Orders
  WHERE orderid % 2 = 0;

SELECT n
FROM dbo.Nums
WHERE n BETWEEN (SELECT MIN(O.orderid) FROM dbo.Orders AS O)
            AND (SELECT MAX(O.orderid) FROM dbo.Orders AS O)
  AND n NOT IN (SELECT O.orderid FROM dbo.Orders AS O);

-- CLeanup
DROP TABLE IF EXISTS dbo.Orders;

---------------------------------------------------------------------
-- Correlated Subqueries
---------------------------------------------------------------------

-- Orders with maximum order ID for each customer
-- Listing 4-1: Correlated Subquery
/*
    query: CustomerId, orderid, orderdate,EmployeeId
    only for orders with the highest orderId for each customer
    This is achieved by using a subquery to find the maximum orderid for each customer and then selecting only the rows where the orderid matches that maximum.

*/
USE Northwinds2022TSQLV7;

SELECT CustomerId, orderid, orderdate, EmployeeId
FROM Sales.[Order] AS O1
WHERE orderid =
  (SELECT MAX(O2.orderid)
   FROM Sales.[Order] AS O2
   WHERE O2.CustomerId = O1.CustomerId);

/*
    SELECT the max value of the orderId where the customerId = 85
*/
SELECT MAX(O2.orderid)
FROM Sales.[Order] AS O2
WHERE O2.CustomerId = 85;


---------------------------------------------------------------------
-- EXISTS
---------------------------------------------------------------------

-- Customers from Spain who placed orders
/*
    SELECT CustomerId, CustomerCountry
    that customers's country is Spain
    filter only includes rows where exists at least one order in the order sales
*/
SELECT CustomerId, CustomerCountry
FROM Sales.Customer AS C
WHERE CustomerCountry = N'Spain'
  AND EXISTS
    (SELECT * FROM Sales.[Order] AS O
     WHERE O.CustomerId = C.CustomerId);

-- Customers from Spain who didn't place Orders
/*
    SELECT CustomerId, CustomerCountry
    that customers's country is Spain
    filter only includes rows where NOT exists at least one order in the order sales
*/
SELECT CustomerId, CustomerCompanyName
FROM Sales.Customer AS C
WHERE CustomerCompanyName = N'Spain'
  AND NOT EXISTS
    (SELECT * FROM Sales.[Order] AS O
     WHERE O.CustomerId = C.CustomerId);

---------------------------------------------------------------------
-- Beyond the Fundamentals of Subqueries
-- (Optional, Advanced)
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Returning "Previous" or "Next" Value
---------------------------------------------------------------------
/*
    query orderid, orderdate, EmployeeId, CustomerId,
        with max order id from sales 
        that order id is less than the current order id
*/
SELECT orderid, orderdate, EmployeeId, CustomerId,
  (SELECT MAX(O2.orderid)
   FROM Sales.[Order] AS O2
   WHERE O2.orderid < O1.orderid) AS prevorderid
FROM Sales.[Order] AS O1;

/*
    query orderid, orderdate, EmployeeId, CustomerId,
    with max order id from sales 
        that order id is more than the current order id
*/
SELECT orderid, orderdate, EmployeeId, CustomerId,
  (SELECT MIN(O2.orderid)
   FROM Sales.[Order] AS O2
   WHERE O2.orderid > O1.orderid) AS nextorderid
FROM Sales.[Order] AS O1;


---------------------------------------------------------------------
-- Misbehaving Subqueries
---------------------------------------------------------------------

---------------------------------------------------------------------
-- NULL Trouble
---------------------------------------------------------------------

-- Customers who didn't place orders

/*
     CustomerId and CustomerCompanyName columns from the Sales.
     Customer table for customers who have not placed any orders in the Sales.Order table. It uses the NOT IN operator to achieve this.
*/
-- Using NOT IN
SELECT CustomerId, CustomerCompanyName
FROM Sales.Customer
WHERE CustomerId NOT IN(SELECT O.CustomerId
                    FROM Sales.[Order] AS O);

-- Add a row to the Orders table with a NULL custid
INSERT INTO Sales.[Order]
  (CustomerId, EmployeeId, orderdate, requireddate, ShipToDate, shipperid,
   freight, ShipToName, ShipToAddress, ShipToCity, ShipToRegion,
   ShipToPostalCode, ShipToCountry)
  VALUES(NULL, 1, '20160212', '20160212',
         '20160212', 1, 123.00, N'abc', N'abc', N'abc',
         N'abc', N'abc', N'abc');

-- Following returns an empty set
/*
    query selects the CustomerId and CustomerCompanyName columns from the Sales.
    Customer table for customers who have not placed any orders in the Sales.Order table. 
    It uses a subquery with a NOT IN operator to achieve this.

*/
SELECT CustomerId, CustomerCompanyName
FROM Sales.Customer
WHERE CustomerId NOT IN(SELECT O.CustomerId
                    FROM Sales.[Order] AS O);
/*
    query selects CustomerId and CustomerCompanyName 
    columns from the Customers table who have not placed any orders in the Sales.Order table. It uses a subquery with a NOT IN operator to achieve this
    and excludin Null values
*/
-- Exclude NULLs explicitly
SELECT CustomerId, CustomerCompanyName
FROM Sales.Customer
WHERE CustomerId NOT IN(SELECT O.CustomerId 
                    FROM Sales.[Order] AS O
                    WHERE O.CustomerId IS NOT NULL);

/*
    Same as above but using Not Exists
*/
-- Using NOT EXISTS
SELECT CustomerId, CustomerCompanyName
FROM Sales.Customer AS C
WHERE NOT EXISTS
  (SELECT * 
   FROM Sales.[Order] AS O
   WHERE O.CustomerId = C.CustomerId);

-- Cleanup
DELETE FROM Sales.[Order] WHERE CustomerId IS NULL;
GO

---------------------------------------------------------------------
-- Substitution Error in a Subquery Column Name
---------------------------------------------------------------------

-- Create and populate table Sales.MyShippers
DROP TABLE IF EXISTS Sales.MyShippers;

CREATE TABLE Sales.MyShippers
(
  shipper_id  INT          NOT NULL,
  companyname NVARCHAR(40) NOT NULL,
  phone       NVARCHAR(24) NOT NULL,
  CONSTRAINT PK_MyShippers PRIMARY KEY(shipper_id)
);

INSERT INTO Sales.MyShippers(shipper_id, companyname, phone)
  VALUES(1, N'Shipper GVSUA', N'(503) 555-0137'),
	      (2, N'Shipper ETYNR', N'(425) 555-0136'),
				(3, N'Shipper ZHISN', N'(415) 555-0138');
GO

-- Shippers who shipped orders to customer 43

-- Bug
SELECT shipper_id, companyname
FROM Sales.MyShippers
WHERE shipper_id IN
  (SELECT shipper_id
   FROM Sales.[Order]
   WHERE CustomerId = 43);
GO

-- The safe way using aliases, bug identified
/*
    query selects the shipper_id and companyname columns from the Sales.
    MyShippers table for shippers that have been used by the customer with a CustomerId of 43 in the Sales.Order table. 
    The query uses a subquery with a SELECT statement and a WHERE clause with a condition involving CustomerId and ShipperId.
*/
SELECT shipper_id, companyname
FROM Sales.MyShippers
WHERE shipper_id IN
  (SELECT O.ShipperId
   FROM Sales.[Order] AS O
   WHERE O.CustomerId = 43);
GO

-- Bug corrected
SELECT shipper_id, companyname
FROM Sales.MyShippers
WHERE shipper_id IN
  (SELECT O.shipperid
   FROM Sales.[Order] AS O
   WHERE O.CustomerId = 43);

-- Cleanup
DROP TABLE IF EXISTS Sales.MyShippers;