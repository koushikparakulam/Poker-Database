USE poker_room;

CREATE TABLE System_Register (
	Register_ID INT PRIMARY KEY AUTO_INCREMENT,
    Account_Balance FLOAT8
);

CREATE TABLE Player (
	Player_ID INT PRIMARY KEY AUTO_INCREMENT,
    Player_Name VARCHAR(50) NOT NULL,
    Address VARCHAR(50), 
    Age INT 	NOT NULL, 
    Account_Creation_Date TIMESTAMP(6) NOT NULL, 
    Credit_Card_Number BIGINT, 
    Account_Balance FLOAT8,
    CONSTRAINT Adult_Constraint 
		CHECK (Age >= 21)
);

INSERT INTO System_Register (Account_Balance) 
VALUES 
	(100.5);

INSERT INTO Player (Player_Name, Address, Age, Account_Creation_Date, Credit_Card_Number, Account_Balance) 
VALUES 
	('Bob Smith', '456 Oak St', 45, CURRENT_TIMESTAMP(6), 4532678956789123, 2200.50),
    ('Cathy Brown', '789 Pine St', 29, CURRENT_TIMESTAMP(6), 4532678945671234, 890.30),
    ('David Williams', '101 Elm St', 32, CURRENT_TIMESTAMP(6), 4532678998765432, 5400.00),
    ('Emily Davis', '202 Birch St', 27, CURRENT_TIMESTAMP(6), 4532678976543210, 120.00),
    ('Frank Thompson', '303 Cedar St', 38, CURRENT_TIMESTAMP(6), 4532678965432109, 300.25),
    ('Grace Lee', '404 Spruce St', 35, CURRENT_TIMESTAMP(6), 4532678932123456, 7200.80),
    ('Henry Clark', '505 Ash St', 50, CURRENT_TIMESTAMP(6), 4532678912340987, 0.00),
    ('Isabella Martinez', '606 Fir St', 26, CURRENT_TIMESTAMP(6), 4532678923456781, 180.60),
    ('James Anderson', '707 Redwood St', 42, CURRENT_TIMESTAMP(6), 4532678998761234, 2500.40),
    ('Karen Wilson', '808 Hemlock St', 31, CURRENT_TIMESTAMP(6), 4532678912345678, 130.00),
    ('Leo Scott', '909 Cypress St', 46, CURRENT_TIMESTAMP(6), 4532678954321987, 1600.90),
    ('Maria King', '1010 Willow St', 28, CURRENT_TIMESTAMP(6), 4532678945678912, 540.50),
    ('Nathan Wright', '1111 Alder St', 54, CURRENT_TIMESTAMP(6), 4532678987654321, 470.80),
    ('Olivia White', '1212 Poplar St', 33, CURRENT_TIMESTAMP(6), 4532678932109876, 8900.20),
    ('Paul Green', '1313 Magnolia St', 40, CURRENT_TIMESTAMP(6), 4532678923450981, 123.45); 

        