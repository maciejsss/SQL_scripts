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