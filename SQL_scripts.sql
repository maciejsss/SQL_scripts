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


-------------------
select 1 as n
union
select 2
union
select 3
union
select 4
union
select 5
union
select 6
union
select 7
union
select 8
union
select 9
union
select 10

-------------

SELECT custid, 
       empid
FROM sales.Orders
WHERE orderdate BETWEEN '2016-01-01' AND '2016-01-31'
EXCEPT
SELECT custid, 
       empid
FROM sales.Orders
WHERE orderdate BETWEEN '2016-02-01' AND '2016-02-28'
ORDER BY 1, 
         2;


----------

SELECT custid, 
       empid
FROM sales.Orders
WHERE orderdate BETWEEN '2016-01-01' AND '2016-01-31'
INTERSECT
SELECT custid, 
       empid
FROM sales.Orders
WHERE orderdate BETWEEN '2016-02-01' AND '2016-02-28'
ORDER BY 1, 
         2;



------------------


SELECT custid, 
       empid
FROM sales.Orders
WHERE orderdate BETWEEN '2016-01-01' AND '2016-01-31'
INTERSECT
SELECT custid, 
       empid
FROM sales.Orders
WHERE orderdate BETWEEN '2016-02-01' AND '2016-02-28'
EXCEPT
SELECT custid, 
       empid
FROM sales.Orders
WHERE YEAR(orderdate) = 2015; 


------------


SELECT empid
	,ordermonth
	,val
	,SUM(val) OVER (PARTITION BY empid ORDER BY ordermonth ROWS BETWEEN unbounded preceding	AND CURRENT ROW) AS runval
FROM Sales.EmpOrders

------------

SELECT orderid
	,custid
	,val
	,ROW_NUMBER() OVER (		ORDER BY val		) AS rownum
	,RANK() OVER (		ORDER BY val		) AS rank
	,DENSE_RANK() OVER (		ORDER BY val		) AS denseRank
	,NTILE(10) OVER (		ORDER BY val		) AS ntile
FROM Sales.OrderValues

-----------------

SELECT orderid
	,custid
	,val
	,ROW_NUMBER() OVER (
		PARTITION BY custid ORDER BY val
		) as rownum
FROM sales.OrderValues

-----------------------

SELECT custid
	,orderid
	,val
	,LAG(val) OVER (
		PARTITION BY custid ORDER BY orderid
		) AS prevval
	,LEAD(val) OVER (
		PARTITION BY custid ORDER BY orderid
		) AS nextval
FROM sales.OrderValues


-----------------


SELECT report.custid
	,report.orderid
	,convert(decimal(10,2),report.val / report.custTotalVal * 100) AS OrderPercentOfCustVal
	,convert(decimal(10,2),report.custTotalVal / report.totalVal * 100) AS CustPercentOfTotalVal
FROM (
	SELECT orderid
		,custid
		,val
		,sum(val) OVER () AS totalVal
		,sum(val) OVER (PARTITION BY custid) AS custTotalVal
	FROM sales.OrderValues
	) AS report

------------


SELECT empid
	,ordermonth
	,val
	,sum(val) OVER (PARTITION BY empid ORDER BY ordermonth)
FROM sales.EmpOrders

-------------
drop table if exists dbo.Orders
go
CREATE TABLE dbo.Orders (
	orderid INT NOT NULL
	,orderdate DATE NOT NULL
	,empid INT NOT NULL
	,custid VARCHAR(15) NOT NULL
	,qty INT NOT NULL
	,CONSTRAINT PK_Orders PRIMARY KEY (orderid)
	)

insert into dbo.Orders
values
(30001, '20140802',3,'A',10),
(10001, '20141224',2,'A',12),
(10005,'20141224',1,'B',20),
(40001, '20150109',2,'A',40),
(10006,'20140118',1,'C',14),
(20001,'20150212',2,'B',12),
(40005,'20160212',3,'A',10),
(20002,'20160216',1,'C',20),
(30003, '20160418',2,'B',15),
(30004,'20140418',3,'C',22),
(30007,'20160907',3,'D',30)


-------------------

SELECT custid
	,orderid
	,rank() OVER (PARTITION BY custid ORDER BY qty) AS rnk
	,DENSE_RANK() OVER (PARTITION BY custid ORDER BY qty) AS drnk
FROM dbo.Orders



select * from dbo.Orders



SELECT ord.custid
	,ord.orderid
	,ord.qty
	,ord.qty - ord.prevorder AS diffprev
	,ord.qty - ord.nextorder AS diffnext
FROM (
	SELECT custid
		,orderid
		,orderdate
		,qty
		,lag(qty) OVER (ORDER BY custid,orderdate) AS prevorder
		,lead(qty) OVER (ORDER BY custid,orderdate) AS nextorder
	FROM dbo.Orders
	) AS ord


------------

select * from dbo.Orders

SELECT empid
	,COUNT(CASE WHEN year(orderdate) = 2014	THEN orderid ELSE NULL END) AS cnt2014
	,COUNT(CASE	WHEN year(orderdate) = 2015	THEN orderid ELSE NULL END) AS cnt2015
	,COUNT(CASE	WHEN year(orderdate) = 2016	THEN orderid ELSE NULL END) AS cnt2016
FROM dbo.Orders
GROUP BY empid

----------------------

--- PIVOT

SELECT empid
		,custid
		,qty
	FROM dbo.Orders


SELECT empid, A,B,C,D
FROM (
	SELECT empid
		,custid
		,qty
	FROM dbo.Orders
	) AS sub
PIVOT(sum(qty) FOR custid IN (A,B,C,D)) AS piv


SELECT custid, [1],[2],[3]
FROM (
	SELECT empid
		,custid
		,qty
	FROM dbo.Orders
	) AS sub
PIVOT(sum(qty) FOR empid IN ([1],[2],[3])) AS piv
--------------


-- UNPIVOT
select 
*
from dbo.EmpCustOrders


select 
*
from dbo.EmpCustOrders
CROSS JOIN (VALUES('A'),('B'),('C'),('D')) as C(custid)


select 
empid,custid,qty
from dbo.EmpCustOrders
CROSS APPLY (VALUES('A', A),('B', B),('C', C),('D', D)) as C(custid,qty)
where qty is not null


select 
*
from dbo.EmpCustOrders

SELECT empid
	,custid
	,qty
FROM dbo.EmpCustOrders
UNPIVOT(qty for custid in (A,B,C,D)) as U



-------------- OUTPUT

DROP TABLE IF EXISTS dbo.T1
	
CREATE TABLE dbo.T1 (
	keycol INT NOT NULL identity(1, 1) CONSTRAINT PK_T1 PRIMARY KEY
	,datacol NVARCHAR(40) NOT NULL
	)

INSERT INTO dbo.T1 (datacol)
OUTPUT inserted.keycol
	,inserted.datacol
SELECT lastname
FROM HR.Employees
WHERE country = N'USA'



---------

DECLARE @newcols TABLE (
	keycol INT
	,datacol NVARCHAR(40)
	)

INSERT INTO dbo.T1 (datacol)
OUTPUT inserted.keycol
	,inserted.datacol
INTO @newcols
SELECT lastname
FROM HR.Employees
WHERE country = N'USA'

SELECT *
FROM @newcols

----------- DELETE OUTPUT

DROP TABLE IF EXISTS dbo.Orders
	
	SELECT *
	INTO dbo.Orders
	FROM sales.Orders



DELETE
FROM dbo.Orders
OUTPUT deleted.orderdate
	,deleted.orderdate
	,deleted.empid
	,deleted.custid
WHERE orderdate < '20160101'


----------- UPDATE OUTPUT

DROP TABLE IF EXISTS dbo.orderdetails
	SELECT *
	INTO dbo.OrderDetails
	FROM Sales.OrderDetails


BEGIN TRAN 
UPDATE dbo.OrderDetails
SET discount += 0.25
OUTPUT inserted.productid AS produc

	,deleted.discount AS oldPrice
	,inserted.discount AS newPrice

select @@TRANCOUNT

COMMIT


--------------

DELETE
FROM dbo.Orders
OUTPUT deleted.orderid
	,deleted.orderdate
WHERE orderdate < '2014-08-01'


----------


DELETE
FROM dbo.Orders
OUTPUT deleted.orderid
	,deleted.shipcountry
WHERE shipcountry = 'Brazil'


----------


SELECT * FROM dbo.Orders

UPDATE dbo.Orders
SET shipregion = '<None>'
OUTPUT inserted.custid
	,deleted.shipregion AS oldRegion
	,inserted.shipregion AS newRegion
WHERE shipregion IS NULL


--------------------MERGE

DROP TABLE IF EXISTS dbo.Customers
	CREATE TABLE dbo.Customers (
		custid INT NOT NULL
		,companyname VARCHAR(25) NOT NULL
		,phone VARCHAR(20) NOT NULL
		,address VARCHAR(20) NOT NULL
		,CONSTRAINT PK_Customers PRIMARY KEY (custid)
		)


insert into dbo.customers
values(1,'cust 1','(111) 111-1111','address 1'),
(2,'cust 2','(222) 222-2222','address 2'),
(3,'cust 3','(333) 333-3333','address 3'),
(4,'cust 4','(444) 444-4444','address 4'),
(5,'cust 5','(555) 555-5555','address 5')


DROP TABLE IF EXISTS dbo.CustomersStage
	CREATE TABLE dbo.CustomersStage (
		custid INT NOT NULL
		,companyname VARCHAR(25) NOT NULL
		,phone VARCHAR(20) NOT NULL
		,address VARCHAR(20) NOT NULL
		,CONSTRAINT PK_CustomersStage PRIMARY KEY (custid)
		)


insert into dbo.CustomersStage
values
(2,'AAAAA','(222) 222-2222','address 2'),
(3,'cust 3','(333) 333-3333','address 3'),
(5,'BBBBB','CCCCC','DDDDD'),
(6,'cust 6 (new)','(666) 666-6666','address 6'),
(7,'cust 7 (new)','(777) 777-7777','address 7')



MERGE INTO dbo.Customers AS TGT
USING dbo.CustomersStage AS SRC
	ON TGT.custid = SRC.custid
WHEN MATCHED AND (TGT.companyname <> SRC.companyname OR TGT.phone=SRC.phone OR TGT.address <> SRC.address)
	THEN
		UPDATE
		SET TGT.companyname = SRC.companyname
			,TGT.phone = SRC.phone
			,TGT.address = SRC.address
WHEN NOT MATCHED
	THEN
		INSERT
		VALUES (
			SRC.custid
			,SRC.companyname
			,SRC.phone
			,SRC.address
			)
WHEN NOT MATCHED BY SOURCE THEN DELETE; -- usuwa wiersze z tabeli docelowej je¿eli nie ma ich w Ÿród³owej


select * from dbo.Customers


----------------CTE DML

with c as 
(
select top(50) *
from dbo.Orders
where shipaddress = 'Torikatu 2345'
)

delete from c


select * from dbo.Orders
where shipaddress = 'Torikatu 2345'














































