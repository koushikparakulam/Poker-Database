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
    Limit_Type FLOAT8 NOT NULL,
    CONSTRAINT Limit_Type_unq
		UNIQUE (Limit_Type),
	CONSTRAINT Limit_Type_min
		CHECK (Limit_Type >= .01)
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
    

	
