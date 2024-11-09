USE poker_room;

CREATE TABLE Make_Bet (
	Bet_Time TIMESTAMP(6), 
	Subround_ID INT,
    Game_Account_ID INT,
    Bet_Type_ID INT,
    Bet_Amount FLOAT8,
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
        ON DELETE CASCADE ON UPDATE RESTRICT
); 

CREATE TABLE Pay_Out (
    Pay_Out_Time TIMESTAMP(6),
	Subround_ID INT,
    Game_Account_ID INT,
    Pay_Out_Amount FLOAT8, 
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
    Rake_Amount FLOAT8, 
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
    Buy_Out_Amount FLOAT8,
    CONSTRAINT Buy_Out_Composite_PK 
		PRIMARY KEY (Buy_Out_Time, Game_Account_ID, Player_ID),
    CONSTRAINT BO_Game_Account_ID_FK
		FOREIGN KEY (Game_Account_ID) REFERENCES Game_Account (Game_Account_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT BO_Player_ID_FK 
		FOREIGN KEY (Player_ID) REFERENCES Player (Player_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
); 
CREATE TABLE Buy_In (
	Buy_In_Time TIMESTAMP(6),
	Game_Account_ID INT,
    Player_ID INT,
    Buy_In_Amount FLOAT8,
    CONSTRAINT Buy_In_Composite_PK 
		PRIMARY KEY (Buy_In_Time, Game_Account_ID, Player_ID),
    CONSTRAINT BI_Game_Account_ID_FK
		FOREIGN KEY (Game_Account_ID) REFERENCES Game_Account (Game_Account_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT BI_Player_ID_FK 
		FOREIGN KEY (Player_ID) REFERENCES Player (Player_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
); 
CREATE TABLE Players_Cards (
	Player_Card_ID INT PRIMARY KEY AUTO_INCREMENT,
	Round_ID INT,
	Game_Account_ID INT, -- Used for new Buy-Ins where a Game Account Does not Exist
    Card_Type_ID INT,
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
	Card_Type_ID INT,
	Subround_ID INT, 
	CONSTRAINT CC_Card_Type_ID_FK 
		FOREIGN KEY (Card_Type_ID) REFERENCES All_Card_Types (Card_Type_ID)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT CC_Sub_Round_ID_FK
		FOREIGN KEY (Subround_ID) REFERENCES Subround (Subround_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
); 