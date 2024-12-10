SET SESSION max_sp_recursion_depth = 64;

USE poker_room;
DROP TRIGGER IF EXISTS Make_Bet_Deletion_Trigger;
DROP TRIGGER IF EXISTS Community_Cards_Deletion_Trigger;
DROP TRIGGER IF EXISTS Players_Cards_Deletion_Trigger;
DROP TRIGGER IF EXISTS Buy_In_Deletion_Trigger;
DROP TRIGGER IF EXISTS Buy_Out_Deletion_Trigger;
DROP TRIGGER IF EXISTS Game_Deletion_Trigger;
DROP TRIGGER IF EXISTS Round_Deletion_Trigger;
DROP TRIGGER IF EXISTS Subround_Deletion_Trigger;


DROP TRIGGER IF EXISTS Close_Game_Trigger;
DROP TRIGGER IF EXISTS Start_Game_Trigger;
DROP TRIGGER IF EXISTS Close_Game_Account_Trigger;
DROP TRIGGER IF EXISTS Start_Round_Trigger;
DROP TRIGGER IF EXISTS Community_Cards_Trigger;
DROP TRIGGER IF EXISTS Make_Bet_Trigger;

DROP TABLE IF EXISTS Debug_Temp;
DROP TABLE IF EXISTS Debug_Money;


CREATE TABLE Debug_Temp (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    message TEXT,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Debug_Money (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    message TEXT,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Deletion Triggers for deletion constraints

DELIMITER //
CREATE TRIGGER Make_Bet_Deletion_Trigger
BEFORE DELETE ON Make_Bet
FOR EACH ROW
	BEGIN
		DECLARE p_Round_ID INT;
        
        SELECT Round_ID INTO p_Round_ID FROM Subround WHERE Subround_ID = OLD.Subround_ID;
		IF EXISTS(SELECT * FROM Round R WHERE R.Round_ID = p_Round_ID AND R.End_Time IS NULL) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deletion Transaction Constraint Violated for Make Bet, Round still Active';
		END IF;
		
	END//
    
DELIMITER //
CREATE TRIGGER Community_Cards_Deletion_Trigger
BEFORE DELETE ON Community_Cards
FOR EACH ROW
	BEGIN
		DECLARE p_Round_ID INT;
        
        SELECT Round_ID INTO p_Round_ID FROM Subround WHERE Subround_ID = OLD.Subround_ID;
		IF EXISTS(SELECT * FROM Round R WHERE R.Round_ID = p_Round_ID AND R.End_Time IS NULL) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deletion Transaction Constraint Violated for Community Cards, Round still Active';
		END IF;
		
	END//
    
DELIMITER //
CREATE TRIGGER Players_Cards_Deletion_Trigger
BEFORE DELETE ON Players_Cards
FOR EACH ROW
	BEGIN
		IF EXISTS(SELECT * FROM Round R WHERE R.Round_ID = OLD.Round_ID AND R.End_Time IS NULL) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deletion Transaction Constraint Violated for Players Cards, Round still Active';
		END IF;
		
	END//
    
DELIMITER //
CREATE TRIGGER Buy_In_Deletion_Trigger
BEFORE DELETE ON Buy_In
FOR EACH ROW
	BEGIN
		IF EXISTS(SELECT * FROM Game_Account GA WHERE GA.Game_Account_ID = OLD.Game_Account_ID AND GA.Time_Closed IS NULL) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deletion Transaction Constraint Violated for Buy In, Game Account still Active';
		END IF;
		
	END//
    
DELIMITER //
CREATE TRIGGER Buy_Out_Deletion_Trigger
BEFORE DELETE ON Buy_Out
FOR EACH ROW
	BEGIN
		
		IF EXISTS(SELECT * FROM Game_Account GA WHERE GA.Game_Account_ID = OLD.Game_Account_ID AND GA.Time_Closed IS NULL) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deletion Transaction Constraint Violated for Buy Out, Game Account still Active';
		END IF;
		
	END//

DELIMITER //
CREATE TRIGGER Game_Deletion_Trigger
BEFORE DELETE ON Game
FOR EACH ROW
BEGIN
	
    IF OLD.End_Time IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Game Deletion Hierarchy Constraint Violated for Game, Game is still active';

	ELSEIF EXISTS (SELECT * FROM Round R WHERE R.Game_ID = OLD.Game_ID AND R.End_Time IS NULL) 
		   OR EXISTS (SELECT * FROM Subround S JOIN Round R ON S.Round_ID = R.Round_ID
				      WHERE R.Game_ID = OLD.Game_ID AND S.End_Time IS NULL) THEN
           SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Game Deletion Hierarchy Constraint Violated for Game, Round/Subround(s) still active';
    END IF;
END//

DELIMITER //
CREATE TRIGGER Round_Deletion_Trigger
BEFORE DELETE ON Round
FOR EACH ROW
BEGIN

    IF 	OLD.End_Time IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Game Deletion Hierarchy Constraint Violated for Round, Round is still active';

	ELSEIF EXISTS (SELECT * FROM Subround SR WHERE SR.Round_ID = OLD.Round_ID AND SR.End_Time IS NULL) THEN
           SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Game Deletion Hierarchy Constraint Violated for Round, Subround(s) still active';
    END IF;
END//

DELIMITER //
CREATE TRIGGER Subround_Deletion_Trigger
BEFORE DELETE ON Subround
FOR EACH ROW
BEGIN
    IF 	OLD.End_Time IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Game Deletion Hierarchy Constraint Violated for Subround, Subround is still active';
    END IF;
END//



-- Update and Insert Triggers

-- Checks if a Game has two players and creates a new round
-- Otherwise, if a new player has joined an existing game, t
DELIMITER //
CREATE TRIGGER Start_Game_Trigger
AFTER INSERT ON Game_Account
FOR EACH ROW
	BEGIN
		DECLARE Game_End_Time INT;
        DECLARE Game_Round_Counts INT DEFAULT 0;
        DECLARE Open_Round_ID INT; 
        INSERT INTO Debug_Temp (message)
		VALUES (CONCAT('Entered the Start_Game_Trigger'));
        
        -- Count the associated Games Round records to verify it is 0
        SELECT COUNT(*) INTO Game_Round_Counts FROM Round WHERE Game_ID = NEW.Game_ID LIMIT 1;
        
        IF Game_Round_Counts = 0 THEN
			INSERT INTO Debug_Temp (message)
			VALUES (CONCAT('New Round being created'));
			SET Game_End_Time = (SELECT End_Time FROM Game WHERE Game_ID = NEW.Game_ID);
			IF (SELECT COUNT(*) FROM Game_Account 
				WHERE (Game_ID = NEW.Game_ID) AND (NEW.Time_Closed IS NULL) AND (Game_End_Time IS NULL)) >= 2 
				THEN
					INSERT INTO Round (Game_ID, Start_Time, End_Time)
					VALUES (NEW.Game_ID, CURRENT_TIMESTAMP(6), NULL);
			END IF;
		-- Obtain a round record that is open, and give the new game_account their cards
		ELSE 
			INSERT INTO Debug_Temp (message)
			VALUES (CONCAT('Round already exists, just give them new cards'));
			SELECT Round_ID INTO Open_Round_ID FROM Round WHERE Game_ID = NEW.Game_ID AND End_Time IS NULL LIMIT 1;
            CALL GeneratePlayerCards(Open_Round_ID);
		END IF;
		
	END//

-- Checks if a Round has been inserted and Creates the players Cards
-- Thereafter it Inserts a New Subround
DELIMITER //
CREATE TRIGGER Start_Round_Trigger
AFTER INSERT ON Round
FOR EACH ROW
	BEGIN
		DECLARE Curr_Subround_Type_ID INT;
        INSERT INTO Debug_Temp (message)
		VALUES (CONCAT('Entered the Start_Round_Trigger; Giving cards to players'));
		CALL GeneratePlayerCards(NEW.Round_ID);
        
        SELECT Subround_Type_ID INTO Curr_Subround_Type_ID FROM All_Subround_Types WHERE Subround_Name = 'Pre-Flop';
		
        INSERT INTO Subround (Round_ID, Subround_Type_ID, Start_Time, End_Time, Pot)
			VALUES (NEW.Round_ID, Curr_Subround_Type_ID, CURRENT_TIMESTAMP(6), NULL, 0);
	END//

-- Sets the Game_ID NULL of all Game_Accounts that are closed with that Round
DELIMITER //
CREATE TRIGGER Close_Game_Account_Trigger
AFTER UPDATE ON Round
FOR EACH ROW
	BEGIN
		INSERT INTO Debug_Temp (message)
		VALUES (CONCAT('Entered the Close_Game_Account_Trigger'));
		IF NEW.End_Time IS NOT NULL THEN
			IF NOT EXISTS (SELECT * FROM Subround SR WHERE SR.Round_ID = NEW.Round_ID AND SR.End_Time IS NULL) THEN
				INSERT INTO Debug_Temp (message)
				VALUES (CONCAT('Players has left game; their Game_ID is being nullified'));
				UPDATE Game_Account GA
				SET GA.Game_ID = NULL
				WHERE GA.Time_Closed IS NOT NULL AND GA.Game_ID = NEW.Game_ID;
			ELSE 
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Game Closure Hierarchy Violated For Round, Subround still active';
			END IF;
		END IF;
	END//
    
DELIMITER //
CREATE TRIGGER Close_Game_Trigger
AFTER UPDATE ON Game
FOR EACH ROW
	BEGIN
		INSERT INTO Debug_Temp (message)
		VALUES (CONCAT('Entered the Close_Game_Trigger'));
		IF NEW.End_Time IS NOT NULL 
		AND EXISTS (SELECT * FROM Round R WHERE R.Game_ID = NEW.Game_ID AND R.End_Time IS NULL) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Game Closure Hierarchy Violated For Game, Round still active';
		END IF;
	END//
    
-- Creates Community Cards for each Subround on new Subround Insert
DELIMITER //
CREATE TRIGGER Community_Cards_Trigger
AFTER INSERT ON Subround
FOR EACH ROW
	BEGIN
		
		DECLARE Curr_Subround_Name VARCHAR(20);
        DECLARE Random_Card_ID INT;
		
        INSERT INTO Debug_Temp (message)
		VALUES (CONCAT('Entered the Community_Cards_Trigger'));
		SELECT Subround_Name INTO Curr_Subround_Name FROM All_Subround_Types WHERE Subround_Type_ID = NEW.Subround_Type_ID;
        IF Curr_Subround_Name != 'Pre-Flop' THEN
			IF Curr_Subround_Name = 'Flop' THEN
				CALL InsertCards(3, 'CC', NEW.Subround_ID, NULL);
            ELSE 
				CALL InsertCards(1, 'CC', NEW.Subround_ID, NULL);
			END IF;
		END IF;
	END//

-- Obtains Game Statistics and Calls Round State Handler to Perform the neccessary Conditional checks of Round/Subround handling
DELIMITER //
CREATE TRIGGER Make_Bet_Trigger
AFTER INSERT ON Make_Bet
FOR EACH ROW
	BEGIN
	DECLARE Fold_Count INT DEFAULT 0;
    DECLARE All_In_Count INT DEFAULT 0;
	DECLARE Game_Accounts_Count INT DEFAULT 0;
	DECLARE Subround_Bet_Count INT DEFAULT 0;
    DECLARE Outer_Fold_Count INT DEFAULT 0;
    DECLARE Outer_All_In_Count INT DEFAULT 0;
    
    
	SET Fold_Count = ComputeGameStats(NEW.Subround_ID, NEW.Game_Account_ID, 'Fold_Count');
    SET Outer_Fold_Count = ComputeGameStats(NEW.Subround_ID, NEW.Game_Account_ID, 'Outer_Fold_Count');
    SET All_In_Count = ComputeGameStats(NEW.Subround_ID, NEW.Game_Account_ID, 'All_In_Count');
	SET Outer_All_In_Count = ComputeGameStats(NEW.Subround_ID, NEW.Game_Account_ID, 'Outer_All_In_Count');

    -- Obtain the total Bets made in the Subround
    SET Subround_Bet_Count = ComputeGameStats(NEW.Subround_ID, NEW.Game_Account_ID, 'Subround_Bet_Count');
    -- Count the total Game_Accounts associated with the current game
    SET Game_Accounts_Count = ComputeGameStats(NEW.Subround_ID, NEW.Game_Account_ID, 'Game_Accounts_Count');
    
    INSERT INTO Debug_Temp (message)
	VALUES (CONCAT('Entered the Make Bet Trigger'));

    CALL RoundStateHandler(NEW.Subround_ID, NEW.Game_Account_ID, Game_Accounts_Count, Fold_Count, 
		All_In_Count, Outer_Fold_Count, Outer_All_In_Count, Subround_Bet_Count);
        
	END//

DELIMITER ;

    
    