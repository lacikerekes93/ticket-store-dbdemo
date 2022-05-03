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
 CONSTRAINT PK_EventId PRIMARY KEY (EventId)
 );

INSERT INTO Events (EventId, Category, Name) VALUES (2,'Cinema', 'The Wolves of Wallstreet');
INSERT INTO Events (EventId, Category, Name) VALUES (3,'Concert', 'Halott Penz');


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
	PurchaseTime Timestamp DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT PK_UserTicketId PRIMARY KEY (UserId, TicketId)
 );

INSERT INTO UserTicket (UserID, TicketId, PurchaseTime) VALUES (2, 4, '2022-05-02 13:41:00.123');
INSERT INTO UserTicket (UserID, TicketId, PurchaseTime) VALUES (2, 5, '2022-05-02 14:42:00.133');