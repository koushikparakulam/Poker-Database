USE poker_room;

CREATE TABLE Game (
	Game_ID INT PRIMARY KEY AUTO_INCREMENT,
    Limit_Type_ID INT,
    Max_Seats_ID INT,
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
    Game_ID INT,
    Start_Time TIMESTAMP(6) NOT NULL,
    End_Time TIMESTAMP(6), 
    CONSTRAINT R_Game_ID_FK 
		FOREIGN KEY (Game_ID) REFERENCES Game (Game_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Subround (
	Subround_ID INT PRIMARY KEY AUTO_INCREMENT,
	Round_ID INT,
    Subround_Type_ID INT,
    Start_Time TIMESTAMP(6) NOT NULL,
    End_Time TIMESTAMP(6),
	Pot INT,
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
    Chip_Stack FLOAT8,
    Time_Created TIMESTAMP(6) NOT NULL,
    Time_Closed TIMESTAMP(6), 
    CONSTRAINT GA_Game_ID_FK
			FOREIGN KEY (Game_ID) REFERENCES Game (Game_ID)
            ON DELETE CASCADE ON UPDATE CASCADE
);