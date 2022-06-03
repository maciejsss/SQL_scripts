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
