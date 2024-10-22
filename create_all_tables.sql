USE poker_room; 

CREATE TABLE All_Card_Types (
    Card_Type_ID INT PRIMARY KEY AUTO_INCREMENT,
    Card_Combination INT NOT NULL, 
	CONSTRAINT Card_Name_Unq
		UNIQUE (Card_Combination)
);
CREATE TABLE All_Subround_Types (
    Subround_Type_ID INT PRIMARY KEY AUTO_INCREMENT,
    Subround_Name VARCHAR(20) 	NOT NULL, 
	CONSTRAINT Subround_Name_unq
		UNIQUE (Subround_Name)
);

CREATE TABLE All_Seat_Types (
	Max_Seats_ID INT PRIMARY KEY AUTO_INCREMENT,
    Max_Seats INT NOT NULL,
    CONSTRAINT Max_Seats_non_negative 
		CHECK (Max_Seats >= 2), 
	CONSTRAINT Max_Seats_unq 
		UNIQUE (Max_Seats)
);

CREATE TABLE All_Bet_Types (
	Bet_Type_ID INT PRIMARY KEY AUTO_INCREMENT,
    Bet_Type VARCHAR(20) NOT NULL,
    CONSTRAINT Bet_Type_unq
		UNIQUE (Bet_Type)
);

CREATE TABLE All_Limit_Types (
	Limit_Type_ID INT PRIMARY KEY AUTO_INCREMENT,
    Limit_Type DECIMAL(7, 3) NOT NULL,
    CONSTRAINT Limit_Type_unq
		UNIQUE (Limit_Type),
	CONSTRAINT Limit_Type_min
		CHECK (Limit_Type >= .1)
);
INSERT INTO All_Card_Types (Card_Combination) VALUES
	(1), (2), (3), (4), (5), (6), (7), (8), (9), (10);

INSERT INTO All_Subround_Types (Subround_Name) VALUES
	('Pre-Flop'), ('Flop'), ('Turn'), ('River');

INSERT INTO All_Seat_Types (Max_Seats) VALUES
	(6), (9), (12);

INSERT INTO All_Bet_Types (Bet_Type) VALUES 
	('Fold'), ('Bet'), ('All-In'); 

INSERT INTO All_Limit_Types (Limit_Type) VALUES
	(.1),(.5),(1),(2),(5);
    
CREATE TABLE System_Register (
	Register_ID INT PRIMARY KEY AUTO_INCREMENT,
    Account_Balance DECIMAL(7, 3) NOT NULL
);

CREATE TABLE Player (
	Player_ID INT PRIMARY KEY AUTO_INCREMENT,
    Player_Name VARCHAR(50) NOT NULL,
    Address VARCHAR(50), 
    Age INT 	NOT NULL, 
    Account_Creation_Date TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6), 
    Credit_Card_Number BIGINT, 
    Account_Balance DECIMAL(7, 3) NOT NULL DEFAULT 0.00,
    CONSTRAINT Adult_Constraint 
		CHECK (Age >= 21),
	CONSTRAINT playername_unq 
		UNIQUE(Player_Name)
);

INSERT INTO System_Register (Account_Balance) 
VALUES 
	(100.5);

INSERT INTO Player (Player_Name, Address, Age, Account_Creation_Date, Credit_Card_Number, Account_Balance) 
VALUES
	('BillyBob', '456 Oak St', 45, CURRENT_TIMESTAMP(6), 4532678956789123, 100),
	('BobSmith', '456 Oak St', 45, CURRENT_TIMESTAMP(6), 4532678956789123, 2200.50),
    ('CathyBrown', '789 Pine St', 29, CURRENT_TIMESTAMP(6), 4532678945671234, 890.30),
    ('DavidWilliams', '101 Elm St', 32, CURRENT_TIMESTAMP(6), 4532678998765432, 5400.00),
    ('EmilyDavis', '202 Birch St', 27, CURRENT_TIMESTAMP(6), 4532678976543210, 120.00),
    ('FrankThompson', '303 Cedar St', 38, CURRENT_TIMESTAMP(6), 4532678965432109, 300.25),
    ('GraceLee', '404 Spruce St', 35, CURRENT_TIMESTAMP(6), 4532678932123456, 7200.80),
    ('HenryClark', '505 Ash St', 50, CURRENT_TIMESTAMP(6), 4532678912340987, 100.00),
    ('IsabellaMartinez', '606 Fir St', 26, CURRENT_TIMESTAMP(6), 4532678923456781, 180.60),
    ('JamesAnderson', '707 Redwood St', 42, CURRENT_TIMESTAMP(6), 4532678998761234, 2500.40),
    ('KarenWilson', '808 Hemlock St', 31, CURRENT_TIMESTAMP(6), 4532678912345678, 130.00),
    ('LeoScott', '909 Cypress St', 46, CURRENT_TIMESTAMP(6), 4532678954321987, 1600.90),
    ('MariaKing', '1010 Willow St', 28, CURRENT_TIMESTAMP(6), 4532678945678912, 540.50),
    ('NathanWright', '1111 Alder St', 54, CURRENT_TIMESTAMP(6), 4532678987654321, 470.80),
    ('OliviaWhite', '1212 Poplar St', 33, CURRENT_TIMESTAMP(6), 4532678932109876, 8900.20),
    ('PaulGreen', '1313 Magnolia St', 40, CURRENT_TIMESTAMP(6), 4532678923450981, 123.45); 
    
CREATE TABLE Game (
	Game_ID INT PRIMARY KEY AUTO_INCREMENT,
    Limit_Type_ID INT NOT NULL,
    Max_Seats_ID INT NOT NULL,
    Start_Time TIMESTAMP(6) NOT NULL,
    End_Time TIMESTAMP(6), 
    CONSTRAINT G_Limit_Type_ID_FK
		FOREIGN KEY (Limit_Type_ID) REFERENCES All_Limit_Types (Limit_Type_ID)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
	CONSTRAINT G_Max_Seats_ID_FK
		FOREIGN KEY (Max_Seats_ID) REFERENCES All_Seat_Types (Max_Seats_ID)
        ON DELETE RESTRICT ON UPDATE RESTRICT
);

CREATE TABLE Round (
	Round_ID INT PRIMARY KEY AUTO_INCREMENT,
    Game_ID INT NOT NULL,
    Start_Time TIMESTAMP(6) NOT NULL,
    End_Time TIMESTAMP(6), 
    CONSTRAINT R_Game_ID_FK 
		FOREIGN KEY (Game_ID) REFERENCES Game (Game_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Subround (
	Subround_ID INT PRIMARY KEY AUTO_INCREMENT,
	Round_ID INT NOT NULL,
    Subround_Type_ID INT NOT NULL,
    Start_Time TIMESTAMP(6) NOT NULL,
    End_Time TIMESTAMP(6),
	Pot DECIMAL(7, 3) NOT NULL,
    CONSTRAINT SR_Round_ID_FK 
		FOREIGN KEY (Round_ID) REFERENCES Round (Round_ID)
        ON DELETE CASCADE ON UPDATE RESTRICT,
	CONSTRAINT SR_Subround_Type_ID_FK 
		FOREIGN KEY (Subround_Type_ID) REFERENCES All_Subround_Types (Subround_Type_ID)
        ON DELETE RESTRICT ON UPDATE RESTRICT
);

CREATE TABLE Game_Account (
	Game_Account_ID INT PRIMARY KEY AUTO_INCREMENT,
    Game_ID INT,
    Chip_Stack DECIMAL(7, 3),
    Time_Created TIMESTAMP(6) NOT NULL,
    Time_Closed TIMESTAMP(6), 
    CONSTRAINT GA_Game_ID_FK
			FOREIGN KEY (Game_ID) REFERENCES Game (Game_ID)
            ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Make_Bet (
	Bet_Time TIMESTAMP(6), 
	Subround_ID INT,
    Game_Account_ID INT,
    Bet_Type_ID INT,
    Bet_Amount DECIMAL(7, 3),
    CONSTRAINT Make_Bet_Composite_PK 
		PRIMARY KEY (Bet_Time, Subround_ID, Game_Account_ID),
	CONSTRAINT MB_Sub_Round_ID_FK 
		FOREIGN KEY (Subround_ID) REFERENCES Subround (Subround_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT MB_Game_Account_ID_FK 
		FOREIGN KEY (Game_Account_ID) REFERENCES Game_Account (Game_Account_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT MB_Bet_Type_ID_FK 
		FOREIGN KEY (Bet_Type_ID) REFERENCES All_Bet_Types (Bet_Type_ID)
        ON DELETE CASCADE ON UPDATE RESTRICT,
	CONSTRAINT Bet_Amount_non_negative
		CHECK (Bet_Amount >= 0)
); 

CREATE TABLE Pay_Out (
    Pay_Out_Time TIMESTAMP(6),
	Subround_ID INT,
    Game_Account_ID INT,
    Pay_Out_Amount DECIMAL(7, 3) NOT NULL, 
    CONSTRAINT Pay_Out_Composite_PK 
		PRIMARY KEY (Pay_Out_Time, Subround_ID, Game_Account_ID),
	CONSTRAINT PO_Sub_Round_ID_FK 
		FOREIGN KEY (Subround_ID) REFERENCES Subround (Subround_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT PO_Game_Account_ID_FK 
		FOREIGN KEY (Game_Account_ID) REFERENCES Game_Account (Game_Account_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
); 

CREATE TABLE Rake_Out (
	Rake_Time TIMESTAMP(6),
	Register_ID INT,
    Subround_ID INT,
    Rake_Amount DECIMAL(7, 3) NOT NULL, 
    CONSTRAINT Rake_Out_Composite_PK 
		PRIMARY KEY (Rake_Time, Register_ID, Subround_ID),
    CONSTRAINT RO_Register_ID_FK
		FOREIGN KEY (Register_ID) REFERENCES System_Register (Register_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT RO_Sub_Round_ID_FK 
		FOREIGN KEY (Subround_ID) REFERENCES Subround (Subround_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
); 
CREATE TABLE Buy_Out (
	Buy_Out_Time TIMESTAMP(6),
	Game_Account_ID INT,
    Player_ID INT,
    Buy_Out_Amount DECIMAL(7, 3) NOT NULL,
    CONSTRAINT Buy_Out_Composite_PK 
		PRIMARY KEY (Buy_Out_Time, Game_Account_ID, Player_ID),
    CONSTRAINT BO_Game_Account_ID_FK
		FOREIGN KEY (Game_Account_ID) REFERENCES Game_Account (Game_Account_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT BO_Player_ID_FK 
		FOREIGN KEY (Player_ID) REFERENCES Player (Player_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT Buy_Out_Amount_non_negative_or_zero
		CHECK (Buy_Out_Amount > 0)
); 
CREATE TABLE Buy_In (
	Buy_In_Time TIMESTAMP(6),
	Game_Account_ID INT,
    Player_ID INT,
    Buy_In_Amount DECIMAL(7, 3) NOT NULL,
    CONSTRAINT Buy_In_Composite_PK 
		PRIMARY KEY (Buy_In_Time, Game_Account_ID, Player_ID),
    CONSTRAINT BI_Game_Account_ID_FK
		FOREIGN KEY (Game_Account_ID) REFERENCES Game_Account (Game_Account_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT BI_Player_ID_FK 
		FOREIGN KEY (Player_ID) REFERENCES Player (Player_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT Buy_In_Amount_non_negative_or_zero
		CHECK (Buy_In_Amount > 0)
); 
CREATE TABLE Players_Cards (
	Player_Card_ID INT PRIMARY KEY AUTO_INCREMENT,
	Round_ID INT,
	Game_Account_ID INT NOT NULL, 
    Card_Type_ID INT NOT NULL,
	CONSTRAINT PC_Round_ID_FK 
		FOREIGN KEY (Round_ID) REFERENCES Round (Round_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT PC_Game_Account_ID_FK
		FOREIGN KEY (Game_Account_ID) REFERENCES Game_Account (Game_Account_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT PC_Card_Type_ID_FK 
		FOREIGN KEY (Card_Type_ID) REFERENCES All_Card_Types (Card_Type_ID)
        ON DELETE CASCADE ON UPDATE RESTRICT
); 

CREATE TABLE Community_Cards (
	Community_Card_ID INT PRIMARY KEY AUTO_INCREMENT,
	Card_Type_ID INT NOT NULL,
	Subround_ID INT NOT NULL, 
	CONSTRAINT CC_Card_Type_ID_FK 
		FOREIGN KEY (Card_Type_ID) REFERENCES All_Card_Types (Card_Type_ID)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT CC_Sub_Round_ID_FK
		FOREIGN KEY (Subround_ID) REFERENCES Subround (Subround_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
); 