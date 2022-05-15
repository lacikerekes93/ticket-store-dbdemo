drop database if exists flask;

create database flask;
use flask;

CREATE TABLE Tickets(
	TicketId int NOT NULL,
	EventId int NULL,
	TicketTier varchar(50) NULL,
	Price float NULL,
	UnitsAvailable smallint NULL check(UnitsAvailable >= 0),
	UnitsPurchased smallint NULL,
 CONSTRAINT PK_TicketId PRIMARY KEY (
	TicketID
));

INSERT INTO Tickets (TicketId, EventId, TicketTier, Price, UnitsAvailable, UnitsPurchased)
VALUES (1, 1, 'Tier A', 500, 50, 0);
INSERT INTO Tickets (TicketId, EventId, TicketTier, Price, UnitsAvailable, UnitsPurchased)
VALUES (2, 1, 'Tier B', 250, 5, 145);
INSERT INTO Tickets (TicketId, EventId, TicketTier, Price, UnitsAvailable, UnitsPurchased)
VALUES (3, 1, 'Tier C', 100, 2, 998);
INSERT INTO Tickets (TicketId, EventId, TicketTier, Price, UnitsAvailable, UnitsPurchased)
VALUES (4, 2, NULL, 10 ,4, 56);
INSERT INTO Tickets (TicketId, EventId, TicketTier, Price, UnitsAvailable, UnitsPurchased)
VALUES (5, 3, NULL, 20, 2, 100);


CREATE TABLE Events(
	EventId int NOT NULL,
	Category varchar(60),
	Name varchar(60),
	EventDate DATETIME,
	Discontinued boolean DEFAULT 0,
 CONSTRAINT PK_EventId PRIMARY KEY (EventId)
 );

INSERT INTO Events (EventId, Category, Name, EventDate) VALUES (1, 'Concert', 'Muse', '2023-05-01 19:00:00');
INSERT INTO Events (EventId, Category, Name, EventDate) VALUES (2, 'Cinema', 'The Wolf of Wallstreet', '2022-05-28 20:00:00');
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

INSERT INTO Users (UserId, Username, Email, Balance, MoneySpent) VALUES (1, 'admin', 'admin@mail.com', 10000, 0);
INSERT INTO Users (UserId, Username, Email, Balance, MoneySpent) VALUES (2, 'Alfred', 'alfred@mail.com', 1000, 2000);
INSERT INTO Users (UserId, Username, Email, Balance, MoneySpent) VALUES (3, 'Bela', 'bela@mail.com', 100, 20);
INSERT INTO Users (UserId, Username, Email, Balance, MoneySpent) VALUES (4, 'Charles', 'charles@mail.com', 400, 70);
INSERT INTO Users (UserId, Username, Email, Balance, MoneySpent) VALUES (5, 'Daniela', 'daniela@mail.com', 600, 120);


CREATE TABLE UserTicket(
	UserId int NOT NULL,
	TicketId int NOT NULL,
	Quantity int NOT NULL,
	PurchaseTime Timestamp DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT PK_UserTicketId PRIMARY KEY (UserId, TicketId)
 );


CREATE TABLE TicketTransactionLog(
	TransactionId int AUTO_INCREMENT,
	UserId int NOT NULL,
	UserName varchar(100),
	TicketId int NOT NULL,
	EventId int,
	EventDisplayName varchar(150),
	Quantity int,
	TransactionTime Timestamp DEFAULT CURRENT_TIMESTAMP,
	Cancelled boolean DeFAULT 0,
	Processed boolean DEFAULT False,
	ProcessedTime Timestamp,
 CONSTRAINT PK_TransactionId PRIMARY KEY (TransactionId)
 );


DELIMITER $$

create trigger before_ticket_insert
before insert
on UserTicket for each row
begin

    DECLARE `negative` CONDITION FOR SQLSTATE '45000';

    declare availableQuantity int;
    declare userbalance float;
    declare ticketprice float;

    select UnitsAvailable
    into availableQuantity
    from Tickets
    where TicketId = new.TicketId;

    if availableQuantity >= new.Quantity THEN
       UPDATE Tickets
       SET UnitsAvailable = UnitsAvailable - new.Quantity
       where TicketId = new.TicketId;
    else
        SIGNAL `negative`
        SET MESSAGE_TEXT = 'An error occurred';
    end if;

    select Balance
    into userbalance
    from Users
    where UserId = new.UserId;

    select Price
    into ticketprice
    from Tickets
    where TicketId = new.TicketId;

    if userbalance >= ticketprice THEN
       UPDATE Users
       SET balance = balance - ticketprice
       where UserId = new.UserId;
    else
        SIGNAL `negative`
        SET MESSAGE_TEXT = 'An error occurred';
    end if;

end$$
DELIMITER ;


DELIMITER $$

create trigger after_ticket_insert
after insert
on UserTicket for each row

begin

    declare eventId int;
    declare userName varchar(100);
    declare eventDisplayName varchar(100);

    select e.EventId, e.Name
    into eventId, eventDisplayName
    from Tickets t
    join Events e on t.EventId = e.EventId
    where t.TicketId = new.TicketId;

    select u.UserName
    into userName
    from Users u
    where u.UserId = new.UserId;

    INSERT INTO TicketTransactionLog (UserId, UserName, TicketId, EventId, EventDisplayName, Quantity)
    VALUES (new.UserId, userName, new.TicketId, eventId, eventDisplayName, new.Quantity);

end$$
DELIMITER ;


DELIMITER $$

create trigger after_ticket_update
after update
on UserTicket for each row

begin

    declare eventId int;
    declare userName varchar(100);
    declare eventDisplayName varchar(100);

    select e.EventId, e.Name
    into eventId, eventDisplayName
    from Tickets t
    join Events e on t.EventId = e.EventId
    where t.TicketId = new.TicketId;

    select u.UserName
    into userName
    from Users u
    where u.UserId = new.UserId;

    INSERT INTO TicketTransactionLog (UserId, UserName, TicketId, EventId, EventDisplayName, Quantity)
    VALUES (new.UserId, userName, new.TicketId, eventId, eventDisplayName, new.Quantity-old.Quantity);

end$$
DELIMITER ;


DELIMITER $$

create trigger after_ticket_refund
after delete
on UserTicket for each row
begin

    declare ticketprice float;

    UPDATE Tickets
    SET UnitsAvailable = UnitsAvailable + old.Quantity
    where TicketId = old.TicketId;

    select Price
    into ticketprice
    from Tickets
    where ticketid = old.ticketid;

    UPDATE Users
    SET balance = balance + (ticketprice * old.Quantity)
    where UserId = old.UserId;

    UPDATE TicketTransactionLog
    SET Cancelled = 1
    where UserId = old.UserId and TicketId = old.TicketId;

end$$
DELIMITER ;


DELIMITER $$
create PROCEDURE sp_process_tickets(IN var_EventId int)
BEGIN

    declare var_TransactionId int;
    declare var_UserName varchar(100);
    declare var_EventName varchar(100);
    declare done int;

    declare cursor_events cursor for
        select TransactionId, Username, EventDisplayName
        from TicketTransactionLog where Processed=0 and Cancelled=0 and EventId=var_EventId;
    declare continue handler for not found set done=1;

    open cursor_events;
    igmLoop: loop

        fetch cursor_events into var_TransactionId, var_UserName, var_EventName;
        if done = 1 then leave igmLoop; end if;

            call printf(concat('Processing Transaction ID=', var_TransactionId, ' User: ', var_UserName, ' for Event: ', var_EventName));

            call printf(' Processing ticket..');
            select sleep(1);

            update TicketTransactionLog
            set ProcessedTime=CURRENT_TIMESTAMP(), Processed=1
            where TransactionId=var_TransactionId;

            call printf('Event processing OK');

    end loop igmLoop;

    update Events set Discontinued=1 where EventID=var_EventId;

    close cursor_events;
end$$
DELIMITER ;


DELIMITER $$

DROP PROCEDURE IF EXISTS printf;
CREATE PROCEDURE printf(thetext TEXT)
BEGIN

  select thetext as ``;

END$$

DELIMITER ;
