DELIMITER //

CREATE PROCEDURE SafeBuyIn (
    IN p_Player_ID INT,
    IN p_Buy_In_Amount FLOAT8
)
BEGIN
    DECLARE v_Game_ID INT;
    DECLARE v_Game_Account_ID INT;
    DECLARE v_Max_Seats INT;
    DECLARE v_Current_Seats INT;
    DECLARE v_Game_Type_ID VARCHAR(20) DEFAULT 'Standard';  -- Replace with appropriate Game_Type_ID if needed
    DECLARE v_Max_Seats_ID INT DEFAULT 1;  -- Replace with appropriate Max_Seats_ID if needed

    -- Start transaction
    START TRANSACTION;

    -- Check if the player has enough balance
    IF (SELECT Account_Balance FROM Player WHERE Player_ID = p_Player_ID) < p_Buy_In_Amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds';
    END IF;

    -- Find an available Game_ID with seats and no End_Time
    SELECT Game.Game_ID, All_Seat_Types.Max_Seats, COUNT(Game_Account.Game_Account_ID) AS Current_Seats
		INTO v_Game_ID, v_Max_Seats, v_Current_Seats
		FROM Game
			JOIN All_Seat_Types ON Game.Max_Seats_ID = All_Seat_Types.Max_Seats_ID
			LEFT JOIN Game_Account ON Game.Game_ID = Game_Account.Game_ID
			WHERE Game.End_Time IS NULL  -- Ensure the game has not ended
				GROUP BY Game.Game_ID, All_Seat_Types.Max_Seats
				HAVING Current_Seats < Max_Seats
	LIMIT 1;

    -- If no open game is available, create a new game
    IF v_Game_ID IS NULL THEN
        INSERT INTO Game (Game_Type_ID, Max_Seats_ID, Start_Time)
        VALUES (v_Game_Type_ID, v_Max_Seats_ID, NOW());

        -- Get the newly created Game_ID
        SET v_Game_ID = LAST_INSERT_ID();
    END IF;

    -- Create a new Game_Account record
    INSERT INTO Game_Account (Game_ID, Chip_Stack, Time_Created)
		VALUES (v_Game_ID, p_Buy_In_Amount, NOW());

    -- Get the newly created Game_Account_ID
    SET v_Game_Account_ID = LAST_INSERT_ID();

    -- Create the Buy_In record with the newly generated Game_Account_ID
    INSERT INTO Buy_In (Buy_In_Time, Game_Account_ID, Player_ID, Buy_In_Amount)
		VALUES (NOW(), v_Game_Account_ID, p_Player_ID, p_Buy_In_Amount);

    -- Deduct the Buy_In_Amount from the player's account balance
    UPDATE Player
		SET Account_Balance = Account_Balance - p_Buy_In_Amount
		WHERE Player_ID = p_Player_ID;

    -- Commit the transaction
    COMMIT;

END //

DELIMITER ;