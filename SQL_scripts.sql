use TSQLV4
go

SELECT o.orderid 
       ,o.orderdate 
       ,o.custid 
       ,empid
FROM Sales.Orders o
WHERE YEAR(orderdate) = 2015 AND MONTH(orderdate) = 6;

--------------------

select
	o.orderid
	,o.orderdate
	,o.custid
	,o.empid
FROM Sales.Orders o
where orderdate = EOMONTH(orderdate)

----------------------

select 
*
from hr.Employees
where lastname like '%a%a%'

----------------------

SELECT orderid 
       ,SUM(qty * unitprice) AS totalvalue
FROM Sales.OrderDetails
GROUP BY orderid
HAVING SUM(qty * unitprice) >= 10000;

----------------

SELECT TOP 3 shipcountry, 
             AVG(freight) AS avgfreight
FROM Sales.Orders
where YEAR(shippeddate) = 2015
GROUP BY shipcountry
ORDER BY avgfreight DESC;

--------------

SELECT custid
       ,orderdate 
       ,orderid
       ,ROW_NUMBER() OVER(PARTITION BY custid ORDER BY orderid) AS rownum
FROM Sales.Orders;

-----------------------

SELECT empid
       ,firstname 
       ,lastname
       ,titleofcourtesy
       ,CASE titleofcourtesy
           WHEN 'Ms.'           THEN 'Female'
           WHEN 'Mrs.'           THEN 'Female'
           WHEN 'Mr.'           THEN 'Male'           
		   ELSE 'Unknown'
		   END AS Gender
FROM hr.Employees;

-----------

SELECT custid, 
       region
FROM Sales.Customers
ORDER BY CASE
             WHEN region IS NULL THEN 1
             ELSE 0
         END, 
         region;


--------------


SELECT empid 
       ,firstname 
       ,lastname 
       ,n
FROM dbo.Nums
     CROSS JOIN hr.Employees
WHERE n <= 5;

---------------

SELECT c.custid 
       ,COUNT(distinct o.orderid) AS numorders 
       ,SUM(od.qty) AS totalqty
FROM Sales.Customers c
     JOIN Sales.Orders o ON c.custid = o.custid
     JOIN Sales.OrderDetails od ON o.orderid = od.orderid
WHERE c.country = 'USA'
GROUP BY c.custid
ORDER BY c.custid


-----------


SELECT 
	c.custid
	,c.companyname
	,o.orderid
	,o.orderdate
FROM Sales.Customers c
     LEFT JOIN Sales.Orders o ON c.custid = o.custid

---------

SELECT 
	c.custid
	,c.companyname
FROM Sales.Customers c
     LEFT JOIN Sales.Orders o ON c.custid = o.custid
WHERE o.orderid IS NULL

-----------

SELECT 
	c.custid
	,c.companyname
	,o.orderid
	,o.orderdate
FROM Sales.Customers c
     LEFT JOIN Sales.Orders o ON c.custid = o.custid
WHERE o.orderdate = '20160212'


--------------

SELECT 
	c.custid
	,c.companyname
	,o.orderid
	,o.orderdate
FROM Sales.Customers c
     LEFT JOIN Sales.Orders o ON c.custid = o.custid and o.orderdate = '20160212'

---------


select
	orderid
	,orderdate
	,custid
	,empid
from Sales.Orders
where orderdate = 
(
select MAX(orderdate) from Sales.Orders
)


--------------

SELECT 
	empid
	,firstname
	,lastname
FROM HR.Employees
WHERE empid NOT IN
(
    SELECT empid
    FROM Sales.Orders
    WHERE orderdate >= '2016-05-01'
);

------------

SELECT DISTINCT 
       country
FROM Sales.Customers
WHERE country NOT IN
(
    SELECT e.country
    FROM HR.Employees e
);


----------

select
custid
,orderid
,orderdate
,empid
from Sales.Orders o
where orderdate = (
select MAX(o2.orderdate) from Sales.Orders o2
where o.custid=o2.custid
)


----------

SELECT 
c.custid
,c.companyname
FROM Sales.Customers c
WHERE c.custid IN
(
    SELECT o.custid
    FROM sales.Orders o
    WHERE c.custid = o.custid
          AND YEAR(orderdate) = 2015
)
      AND c.custid NOT IN
(
    SELECT o.custid
    FROM sales.Orders o
    WHERE c.custid = o.custid
          AND YEAR(orderdate) = 2016
);


----------------

SELECT c.custid 
       ,c.companyname
FROM Sales.Customers c
WHERE c.custid IN
(
    SELECT o.custid
    FROM Sales.Orders o
         JOIN Sales.OrderDetails od ON o.orderid = od.orderid
    WHERE od.productid = 12
);

--------

select 
custid
,ordermonth
,SUM(qty) over (partition by custid order by ordermonth) as runqty
from Sales.CustOrders




SELECT act.ordeyear, 
       act.orders, 
       prev.orders AS prevyearorders, 
       prev.orders - act.orders AS groth
FROM
(
    SELECT YEAR(orderdate) AS ordeyear, 
           COUNT(DISTINCT orderid) AS orders
    FROM sales.orders
    GROUP BY YEAR(orderdate)
) AS act
LEFT JOIN
(
    SELECT YEAR(orderdate) AS ordeyear, 
           COUNT(DISTINCT orderid) AS orders
    FROM sales.orders
    GROUP BY YEAR(orderdate)
) AS prev ON act.ordeyear = prev.ordeyear + 1;





SELECT c.companyname, 
       c.contactname, 
       orders.orderid, 
       orders.orderdate
FROM Sales.Customers c
     CROSS APPLY
(
    SELECT TOP 3 o.orderid, 
                 o.orderdate
    FROM Sales.Orders o
    WHERE o.custid = c.custid
    ORDER BY o.orderdate DESC
) AS orders;


-------------


DROP FUNCTION IF EXISTS dbo.TopOrders
GO

CREATE FUNCTION dbo.TopOrders
(@custid AS INT, 
 @n AS      INT
)
RETURNS TABLE
AS
     RETURN
     SELECT TOP (@n) o.orderid, 
                     o.empid, 
                     o.orderdate, 
                     o.requireddate
     FROM Sales.Orders o
     WHERE o.custid = @custid
     ORDER BY o.orderdate DESC;
GO

select * from dbo.TopOrders(1,3)
----------------

SELECT c.companyname, 
       c.contactname, 
       orders.empid, 
       orders.orderdate, 
       orders.orderid, 
       orders.requireddate
FROM Sales.Customers c
     CROSS APPLY dbo.TopOrders(c.custid, 3) AS orders;


SELECT DISTINCT 
       o.empid, 
(
    SELECT MAX(o2.orderdate)
    FROM sales.Orders o2
    WHERE o2.empid = o.empid
) AS maxorderdate
FROM Sales.Orders o;



SELECT o.empid, 
       maxorders.maxorderdate
FROM Sales.Orders o
     JOIN
(
    SELECT o2.empid, 
           MAX(o2.orderdate) AS maxorderdate
    FROM Sales.Orders o2
    GROUP BY o2.empid
) AS maxorders ON maxorders.empid = o.empid
                  AND maxorders.maxorderdate = o.orderdate;


------------------

WITH ordersRN
     AS (SELECT o.orderid, 
                o.orderdate, 
                o.custid, 
                o.empid, 
                ROW_NUMBER() OVER(
                ORDER BY o.orderdate, 
                         o.orderid) AS rownum
         FROM Sales.Orders o)
     SELECT *
     FROM ordersRN
     WHERE rownum BETWEEN 11 AND 20;


--------

DROP VIEW IF EXISTS Sales.VEmpOrders;
GO

CREATE VIEW Sales.VEmpOrders
AS
     SELECT o.empid, 
            YEAR(o.orderdate) AS year, 
            SUM(od.qty) AS qty
     FROM Sales.Orders o
          JOIN Sales.OrderDetails od ON o.orderid = od.orderid
     GROUP BY o.empid, 
              YEAR(o.orderdate);
GO



SELECT empid, 
       year, 
       qty, 
       SUM(qty) OVER(ORDER BY empid, year) AS runqty
FROM Sales.VEmpOrders;



IF OBJECT_ID('Production.TopProducts') IS NOT NULL
    DROP FUNCTION Production.TopProducts;
GO

CREATE FUNCTION Production.TopProducts
(@suppid AS INT, 
 @n AS      INT)
RETURNS TABLE
AS
     RETURN
     SELECT TOP (@n) productid, 
                     productname, 
                     unitprice
     FROM Production.Products
     WHERE supplierid = @suppid
	 order by unitprice desc
GO	 

select * from Production.TopProducts(5,2)


SELECT s.supplierid, 
       s.companyname, 
       topprod.productid, 
       topprod.productname, 
       topprod.unitprice
FROM Production.Suppliers s
     CROSS APPLY Production.TopProducts(s.supplierid, 2) AS topprod;

