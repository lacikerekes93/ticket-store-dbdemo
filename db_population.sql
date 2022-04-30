--Tickets
--drop table products
CREATE TABLE Tickets(
	TicketId int NOT NULL,
	EventId int NULL,
	TicketTier varchar(50) NULL,
	Price float NULL,
	UnitsAvailable smallint NULL check(UnitsAvailable >= 0),
	UnitsPurchased smallint NULL,
	Discontinued boolean NOT NULL,
 CONSTRAINT PK_TicketId PRIMARY KEY (
	TicketID
));

INSERT INTO  Tickets (TicketId, EventId, TicketTier, Price, UnitsAvailable, UnitsPurchased, Discontinued)
VALUES (1, 1, 'Tier A', 500, 50, 0, FALSE);
INSERT INTO  Tickets (TicketId, EventId, TicketTier, Price, UnitsAvailable, UnitsPurchased, Discontinued)
VALUES (2, 1, 'Tier B', 250, 5, 145, FALSE);
INSERT INTO  Tickets (TicketId, EventId, TicketTier, Price, UnitsAvailable, UnitsPurchased, Discontinued)
VALUES (3, 1, 'Tier C', 100, 2, 998, FALSE);
INSERT INTO  Tickets (TicketId, EventId, TicketTier, Price, UnitsAvailable, UnitsPurchased, Discontinued)
VALUES (4, 2, NULL, 10 ,4, 56, FALSE);
INSERT INTO  Tickets (TicketId, EventId, TicketTier, Price, UnitsAvailable, UnitsPurchased, Discontinued)
VALUES (5, 3, NULL, 20, 0, 100, TRUE);
--select * from products;

------------------------------------
--drop table customers;
CREATE TABLE customers(
	CustomerId int NOT NULL,
	Username varchar(100) NOT NULL,
	Email varchar(60) NOT NULL,
	Balance money NULL check(Balance >= '0.00'),
	MoneySpent int NULL,
 CONSTRAINT PK_CustomerId PRIMARY KEY (
	CustomerId
));
--4 customers
INSERT INTO Customers  (CustomerID, Username, Email, Balance) VALUES (1, 'Alfred', 'alfred@mail.com', 1000, 2000);
INSERT INTO Customers  (CustomerID, Username, Email, Balance) VALUES (1, 'Bela', 'bela@mail.com', 100, 20);
INSERT INTO Customers  (CustomerID, Username, Email, Balance) VALUES (1, 'Charles', 'charles@mail.com', 400, 70);
INSERT INTO Customers  (CustomerID, Username, Email, Balance) VALUES (1, 'Daniela', 'daniela@mail.com', 600, 120);


--select * from customers;
---------------------------------------
--drop table orders
--drop sequence seq_orders
create sequence seq_orders start 1 increment 1;
CREATE TABLE Orders(
	OrderID integer NOT NULL, --identity helyett seq
	CustomerID nchar(5) NOT NULL references customers(customerid),
	OrderDate timestamp without time zone DEFAULT now()::timestamp NULL,
	RequiredDate date NULL,
	ShippedDate date NULL,
	ShipVia int NULL,
	Freight money NULL,
	ShipName varchar(40) NULL,
	ShipAddress varchar(60) NULL,
	ShipCity varchar(15) NULL,
	ShipRegion varchar(15) NULL,
	ShipPostalCode varchar(10) NULL,
	ShipCountry varchar(15) NULL,
 CONSTRAINT PK_Orders PRIMARY KEY
(
	OrderID
));
--nincs rendelésünk (üres a tábla)
--drop table OrderDetails
CREATE TABLE OrderDetails(
	orderid int NOT NULL references orders(orderid),
	productid int NOT NULL references products(productid),
	unitprice money NOT NULL,
	quantity smallint NOT NULL check(quantity >= 0),
	discount DOUBLE PRECISION NOT NULL,
 CONSTRAINT PK_Order_Details PRIMARY KEY
(
	orderid ,
	productid
));
--(üres a tábla)
create or replace function new_order (var_productid integer, var_quantity integer, var_custid char(5)) returns integer as
$$
declare var_stock integer; var_unitprice money; var_balance money; var_orderid int;
begin
	select unitsinstock, unitprice into var_stock, var_unitprice from products where productid = var_productid;
	select balance into var_balance from customers where customerid = var_custid;
	if var_quantity * var_unitprice > var_balance or var_stock < var_quantity then
		raise notice 'Készlet vagy egyenleg hiba';
		return 1; --"the function either succeeds in its entirety or fails in its entirety"--no commit/rollback needed
	else
		update customers set balance = balance - var_quantity * var_unitprice where customerid = var_custid;
		var_orderid := nextval('seq_orders');
		insert into orders (orderid, customerid) values (var_orderid, var_custid);
		insert into OrderDetails (orderid, productid, unitprice, quantity, discount) values (var_orderid, var_productid, var_unitprice, var_quantity, 0);
		update products set unitsinstock = unitsinstock - var_quantity where productid = var_productid;
		return 0;
	end if;
end;
$$
language 'plpgsql';

--teszt
/*
select * from products where productid=1 --unitprice 18 unitsinstock 10 Chai
select * from customers where customerid='ALFKI' --balance 20000
select * from orders;
select * from orderdetails
update products set unitsinstock = 10 where productid=1
update customers set balance=2 where customerid='ALFKI'
--futtatás
select new_order(1, 1, 'ALFKI') --0 : OK
select new_order(1, 11, 'ALFKI') --1 NOTICE:  Készlet vagy egyenleg hiba: OK
*/
--lekérdezéshez egy view
--drop view last_orders;
create view last_orders as
select o.orderdate::timestamp(0) without time zone AS orderdate, c.companyname, c.country, c.balance, p.productname, od.quantity, od.quantity * od.unitprice AS value, p.unitsinstock
from products p join orderdetails od on p.productid=od.productid
	join orders o on o.orderid=od.orderid
	join customers c on c.customerid=o.customerid
order by orderdate desc limit 5;
--select * from last_orders;
