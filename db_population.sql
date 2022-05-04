create database flask;
use flask;

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

INSERT INTO Tickets (TicketId, EventId, TicketTier, Price, UnitsAvailable, UnitsPurchased, Discontinued)
VALUES (1, 1, 'Tier A', 500, 50, 0, FALSE);
INSERT INTO Tickets (TicketId, EventId, TicketTier, Price, UnitsAvailable, UnitsPurchased, Discontinued)
VALUES (2, 1, 'Tier B', 250, 5, 145, FALSE);
INSERT INTO Tickets (TicketId, EventId, TicketTier, Price, UnitsAvailable, UnitsPurchased, Discontinued)
VALUES (3, 1, 'Tier C', 100, 2, 998, FALSE);
INSERT INTO Tickets (TicketId, EventId, TicketTier, Price, UnitsAvailable, UnitsPurchased, Discontinued)
VALUES (4, 2, NULL, 10 ,4, 56, FALSE);
INSERT INTO Tickets (TicketId, EventId, TicketTier, Price, UnitsAvailable, UnitsPurchased, Discontinued)
VALUES (5, 3, NULL, 20, 0, 100, TRUE);


CREATE TABLE Events(
	EventId int NOT NULL,
	Category varchar(60),
	Name varchar(60),
	EventDate DATETIME,
 CONSTRAINT PK_EventId PRIMARY KEY (EventId)
 );

INSERT INTO Events (EventId, Category, Name, EventDate) VALUES (1, 'Concert', 'Muse', '2023-05-01 19:00:00');
INSERT INTO Events (EventId, Category, Name, EventDate) VALUES (2, 'Cinema', 'The Wolves of Wallstreet', '2022-05-28 20:00:00');
INSERT INTO Events (EventId, Category, Name, EventDate) VALUES (3, 'Concert', 'Halott Penz', '2022-04-29 20:00:00');


CREATE TABLE Users(
	UserId int NOT NULL,
	Username varchar(100) NOT NULL,
	Email varchar(60) NOT NULL,
	Balance float NULL check(Balance >= '0.00'),
	MoneySpent float NULL,
 CONSTRAINT PK_UserId PRIMARY KEY (
	UserId
));

INSERT INTO Users (UserID, Username, Email, Balance, MoneySpent) VALUES (1, 'admin', 'admin@mail.com', 10000, 0);
INSERT INTO Users (UserID, Username, Email, Balance, MoneySpent) VALUES (2, 'Alfred', 'alfred@mail.com', 1000, 2000);
INSERT INTO Users (UserID, Username, Email, Balance, MoneySpent) VALUES (3, 'Bela', 'bela@mail.com', 100, 20);
INSERT INTO Users (UserID, Username, Email, Balance, MoneySpent) VALUES (4, 'Charles', 'charles@mail.com', 400, 70);
INSERT INTO Users (UserID, Username, Email, Balance, MoneySpent) VALUES (5, 'Daniela', 'daniela@mail.com', 600, 120);


CREATE TABLE UserTicket(
	UserId int NOT NULL,
	TicketId int NOT NULL,
	Quantity int NOT NULL,
	PurchaseTime Timestamp DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT PK_UserTicketId PRIMARY KEY (UserId, TicketId)
 );

INSERT INTO UserTicket (UserID, TicketId, Quantity, PurchaseTime) VALUES (2, 4, 1, '2022-05-02 13:41:00.123');
INSERT INTO UserTicket (UserID, TicketId, Quantity, PurchaseTime) VALUES (2, 5, 1, '2022-05-02 14:42:00.133');

DELIMITER $$

create trigger before_ticket_insert
before insert
on userticket for each row
begin

    DECLARE `negative` CONDITION FOR SQLSTATE '45000';

    declare availableQuantity int;
    declare userbalance float;
    declare ticketprice float;

    select UnitsAvailable
    into availableQuantity
    from tickets
    where ticketid = new.ticketid;

    if availableQuantity >= new.quantity THEN
       UPDATE tickets
       SET UnitsAvailable = UnitsAvailable - new.quantity
       where ticketid = new.ticketid;
    else
        SIGNAL `negative`
        SET MESSAGE_TEXT = 'An error occurred';
    end if;


    select balance
    into userbalance
    from users
    where userid = new.userid;

    select price
    into ticketprice
    from tickets
    where ticketid = new.ticketid;

    if userbalance >= ticketprice THEN
       UPDATE users
       SET balance = balance - ticketprice
       where userid = new.userid;
    else
        SIGNAL `negative`
        SET MESSAGE_TEXT = 'An error occurred';
    end if;

end$$
DELIMITER ;
