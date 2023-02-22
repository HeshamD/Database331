---------------------------------------------------------------------
-- CROSS Joins
---------------------------------------------------------------------

USE Northwinds2022TSQLV7;

--- matching cusId with EmpId combining with every record in customer and employee table
-- SQL-92
SELECT C.CustomerId, E.EmployeeId
FROM Sales.Customer AS C
  CROSS JOIN HumanResources.Employee AS E;

-- SQL-89
SELECT C.CustomerId, E.EmployeeId
FROM 
    Sales.Customer AS C,
    HumanResources.Employee AS E;

-- 
-- Self Cross-Join
/* 
The result set of a self cross-join will contain all possible combinations 
    of rows from the same table.

    The query selects the EmployeeId, EmployeeFirstName, and EmployeeLastName columns for both copies of the Employee table,
    and uses table aliases E1 and E2 to distinguish between them in the SELECT statement. 
    The resulting output will include two columns each for the employee ID, first name, and last name, one set for each employee being paired with another employee.
*/
SELECT
  E1.EmployeeId, E1.EmployeeFirstName, E1.EmployeeLastName,
  E2.EmployeeId, E2.EmployeeFirstName, E2.EmployeeLastName
FROM HumanResources.Employee AS E1 
  CROSS JOIN HumanResources.Employee AS E2;
GO

-- All numbers from 1 - 1000

-- Auxiliary table of digits
USE Northwinds2022TSQLV7;

DROP TABLE IF EXISTS dbo.Digits;

CREATE TABLE dbo.Digits(digit INT NOT NULL PRIMARY KEY);

INSERT INTO dbo.Digits(digit)
  VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

SELECT digit FROM dbo.Digits;
GO

/*
The query performs a cross-join between the "Digits" table three times, using table aliases D1, D2, and D3 to distinguish between them.
By multiplying the digits in each of the three columns by the appropriate powers of ten and adding them together, the query creates a list of numbers from 1 to 1000.
*/
-- All numbers from 1 - 1000
SELECT D3.digit * 100 + D2.digit * 10 + D1.digit + 1 AS n
FROM         dbo.Digits AS D1
  CROSS JOIN dbo.Digits AS D2
  CROSS JOIN dbo.Digits AS D3
ORDER BY n;

---------------------------------------------------------------------
-- INNER Joins
---------------------------------------------------------------------

USE Northwinds2022TSQLV7;

/*
    show the following records 
    EmployeeId, EmployeeFirstName, EmployeeLastName, orderid
    with orders 
*/
-- SQL-92
SELECT E.EmployeeId, E.EmployeeFirstName, E.EmployeeLastName, O.orderid
FROM HumanResources.Employee AS E
  INNER JOIN Sales.[Order] AS O
    ON E.EmployeeId = O.EmployeeId;

-- SQL-89
/*
    this query will preform the same as the one above it but this 
    one using the older syntax by using where clause to make the condition
*/
SELECT E.EmployeeId, E.EmployeeFirstName, E.EmployeeLastName, O.orderid
FROM HumanResources.Employee AS E,Sales.[Order] AS O
WHERE E.EmployeeId = O.EmployeeId;
GO

-- Inner Join Safety
/*
SELECT E.empid, E.firstname, E.lastname, O.orderid
FROM HR.Employees AS E
  INNER JOIN Sales.Orders AS O;
GO
*/

/*
    this query will result the following records:
    E.EmployeeId, E.EmployeeFirstName, E.EmployeeLastName
    with the order that matches with employeeId

Without a JOIN condition or WHERE clause, the query will preform 
a cross-join between the two tables.
This means that each row in the Employee table will be matched 
with every row in the order table

*/

SELECT E.EmployeeId, E.EmployeeFirstName, E.EmployeeLastName, O.orderid
FROM HumanResources.Employee AS E, Sales.[Order] AS O
GO

---------------------------------------------------------------------
-- More Join Examples
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Composite Joins
---------------------------------------------------------------------

-- Audit table for updates against OrderDetails
USE Northwinds2022TSQLV7;

DROP TABLE IF EXISTS Sales.OrderDetailsAudit;

CREATE TABLE Sales.OrderDetailsAudit
(
  lsn        INT NOT NULL IDENTITY,
  orderid    INT NOT NULL,
  productid  INT NOT NULL,
  dt         DATETIME NOT NULL,
  loginname  sysname NOT NULL,
  columnname sysname NOT NULL,
  oldval     SQL_VARIANT,
  newval     SQL_VARIANT,
  CONSTRAINT PK_OrderDetailsAudit PRIMARY KEY(lsn),
  CONSTRAINT FK_OrderDetailsAudit_OrderDetails
    FOREIGN KEY(orderid, productid)
    REFERENCES Sales.OrderDetail(orderid,productid)
);

/*
    This will show OD.orderid, OD.productid, OD.Quantity,
  ODA.dt, ODA.loginname, ODA.oldval, ODA.newval
  where this join is inner join that one of the tables 
  has a composite key so that's why we are using two columns
  matching with.
*/

SELECT OD.orderid, OD.productid, OD.Quantity,
  ODA.dt, ODA.loginname, ODA.oldval, ODA.newval
FROM Sales.OrderDetail AS OD
  INNER JOIN Sales.OrderDetailsAudit AS ODA
    ON OD.orderid = ODA.orderid
    AND OD.productid = ODA.productid
WHERE ODA.columnname = N'qty';

---------------------------------------------------------------------
-- Non-Equi Joins
---------------------------------------------------------------------
/*
returns a list of all possible pairs of employees from the HumanResources.Employee table. 
The query uses a self-join on the Employee table, joining it to itself as E1 and E2.
*/
-- Unique pairs of employees
SELECT
  E1.EmployeeId, E1.EmployeeFirstName, E1.EmployeeLastName,
  E2.EmployeeId, E2.EmployeeFirstName, E2.EmployeeLastName
FROM HumanResources.Employee AS E1
  INNER JOIN HumanResources.Employee  AS E2
    ON E1.EmployeeId < E2.EmployeeId;

---------------------------------------------------------------------
-- Multi-Join Queries
---------------------------------------------------------------------

/*
query returns data that shows which customers have placed which orders, and which products were included in each order, along with the quantity of each product.
*/

SELECT
  C.CustomerId, C.CustomerCompanyName, O.OrderId,
  OD.productid, OD.Quantity
FROM Sales.Customer AS C
  INNER JOIN Sales.[Order] AS O
    ON C.CustomerId = O.CustomerId
  INNER JOIN Sales.OrderDetail AS OD
    ON O.orderid = OD.orderid;

---------------------------------------------------------------------
-- Fundamentals of Outer Joins 
---------------------------------------------------------------------

-- Customers and their orders, including customers with no orders
SELECT C.CustomerId, C.CustomerCompanyName, O.OrderId
FROM Sales.Customer AS C
  LEFT OUTER JOIN Sales.[Order] AS O
    ON C.CustomerId = O.CustomerId;

-- Customers with no orders
SELECT C.CustomerId, C.CustomerCompanyName
FROM Sales.Customer AS C
  LEFT OUTER JOIN Sales.[Order] AS O
    ON C.CustomerId = O.CustomerId
WHERE O.orderid IS NULL;

---------------------------------------------------------------------
-- Beyond the Fundamentals of Outer Joins
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Including Missing Values
---------------------------------------------------------------------

SELECT DATEADD(day, n-1, CAST('20140101' AS DATE)) AS orderdate
FROM dbo.Nums
WHERE n <= DATEDIFF(day, '20140101', '20161231') + 1
ORDER BY orderdate;

SELECT DATEADD(day, Nums.n - 1, CAST('20140101' AS DATE)) AS orderdate,
  O.OrderId, O.CustomerId, O.EmployeeId
FROM dbo.Nums
  LEFT OUTER JOIN Sales.[Order] AS O
    ON DATEADD(day, Nums.n - 1, CAST('20140101' AS DATE)) = O.orderdate
WHERE Nums.n <= DATEDIFF(day, '20140101', '20161231') + 1
ORDER BY orderdate;

---------------------------------------------------------------------
-- Filtering Attributes from Non-Preserved Side of Outer Join
---------------------------------------------------------------------

SELECT C.CustomerId, C.CustomerCompanyName, O.orderid, O.orderdate
FROM Sales.Customer AS C
  LEFT OUTER JOIN Sales.[Order] AS O
    ON C.CustomerId = O.CustomerId
WHERE O.orderdate >= '20160101';

---------------------------------------------------------------------
-- Using Outer Joins in a Multi-Join Query
---------------------------------------------------------------------

SELECT C.CustomerId, O.orderid, OD.productid, OD.Quantity
FROM Sales.Customer AS C
  LEFT OUTER JOIN Sales.[Order] AS O
    ON C.CustomerId = O.CustomerId
  INNER JOIN Sales.OrderDetail AS OD
    ON O.orderid = OD.orderid;

-- Option 1: use outer join all along
SELECT C.CustomerId, O.orderid, OD.productid, OD.Quantity
FROM Sales.Customer AS C
  LEFT OUTER JOIN Sales.[Order] AS O
    ON C.CustomerId = O.CustomerId
  LEFT OUTER JOIN Sales.OrderDetail AS OD
    ON O.orderid = OD.orderid;

-- Option 2: change join order
SELECT C.CustomerId, O.orderid, OD.productid, OD.Quantity
FROM Sales.[Order] AS O
  INNER JOIN Sales.OrderDetail AS OD
    ON O.orderid = OD.orderid
  RIGHT OUTER JOIN Sales.Customer AS C
     ON O.CustomerId = C.CustomerId;

-- Option 3: use parentheses
SELECT C.CustomerId, O.orderid, OD.ProductId, OD.Quantity
FROM Sales.Customer AS C
  LEFT OUTER JOIN
      (Sales.[Order] AS O
         INNER JOIN Sales.OrderDetail AS OD
           ON O.orderid = OD.orderid)
    ON C.CustomerId = O.CustomerId;

---------------------------------------------------------------------
-- Using the COUNT Aggregate with Outer Joins
---------------------------------------------------------------------

SELECT C.CustomerId, COUNT(*) AS numorders
FROM Sales.Customer AS C
  LEFT OUTER JOIN Sales.[Order] AS O
    ON C.CustomerId = O.CustomerId
GROUP BY C.CustomerId;

SELECT C.CustomerId, COUNT(O.orderId) AS numorders
FROM Sales.Customer AS C
  LEFT OUTER JOIN Sales.[Order] AS O
    ON C.CustomerId = O.CustomerId
GROUP BY C.CustomerId;