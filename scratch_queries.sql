USE poker_room;

DELETE FROM Game;
DELETE FROM Game_Account;
DELETE FROM Buy_In;

-- Insert an table that is open
INSERT INTO Game (Limit_Type_ID, Max_Seats_ID, Start_Time, End_Time)
VALUES (1, 1, NOW(), NULL);

-- Show existing empty tables
SELECT * FROM Game_Account;
SELECT * FROM Player WHERE Player_ID = 1;
SELECT * FROM Game;
SELECT * FROM Buy_In;

-- Create Buy in for new Game_Account
CALL SafeBuyIn(1, 10, NULL);
SET @g_ID := (SELECT Game_Account_ID FROM Game_Account ORDER BY Game_Account_ID DESC LIMIT 1);

-- Should show that the game account, buyin, and amount transfered occured 
SELECT * FROM Game_Account;
SELECT * FROM Player WHERE Player_ID = 1;
SELECT * FROM Game;
SELECT * FROM Buy_In;

-- Call the same game account to show buy in occurs for the same account
CALL SafeBuyIn(1, 10, @g_ID );

-- Create Buy in for existing Game_Account
SELECT * FROM Game_Account;
SELECT * FROM Player WHERE Player_ID = 1;
SELECT * FROM Game;
SELECT * FROM Buy_In;

-- Create Buy in for 6 more Game_Accounts until the existing game becomes full and a new game is generated

CALL SafeBuyIn(2, 10, NULL );
CALL SafeBuyIn(3, 10, NULL );
CALL SafeBuyIn(4, 10, NULL );
CALL SafeBuyIn(5, 10, NULL );
CALL SafeBuyIn(6, 10, NULL );
CALL SafeBuyIn(7, 10, NULL );

SELECT * FROM Game_Account;
SELECT * FROM Player WHERE Player_ID = 1;
SELECT * FROM Game;
SELECT * FROM Buy_In;

DELETE FROM Game;

-- Insert Closed Game
INSERT INTO Game (Limit_Type_ID, Max_Seats_ID, Start_Time, End_Time)
VALUES (1, 1, NOW(), NOW());

-- Show that a new Game is generated when the Game has ended
CALL SafeBuyIn(2, 10, NULL);



