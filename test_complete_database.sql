USE poker_room;
-- Initial Buy In -- 

-- Create Game
INSERT INTO Game(Limit_Type_ID, Max_Seats_ID, Start_Time) VALUES (1, 1, CURRENT_TIMESTAMP(6));
SELECT * FROM Game;

-- One player buys in
CALL SafeBuyIn(1, 1);

-- Show the Buy Ins were successful 
-- Player and Game_Account should be updated

SELECT * FROM Buy_In;
SELECT * FROM Player;
SELECT * FROM Game_Account;

-- Show that no game was created because the Game_Accounts Associated is <2
-- Show no Players Cards were generated 
SELECT * FROM Game;
SELECT * FROM Round;
SELECT * FROM Subround;
SELECT * FROM Players_Cards;


-- Cascade the Start Game: Round, Subround, Player Cards -- 
-- Third Player Buys into the game, Show that the Game starts
-- First Round and Subround should be Generated
-- Player Cards Should be Generated
-- This is Set by the trigger Start_Game_Trigger and Start_Round_Trigger
CALL SafeBuyIn(2, 1);
SELECT * FROM Game_Account;
SELECT * FROM Game;
SELECT * FROM Round;
SELECT * FROM Subround;
SELECT * FROM Players_Cards;



-- Buy-In for the Rest of the Players
CALL SafeBuyIn(2, 1);
CALL SafeBuyIn(3, 1);
CALL SafeBuyIn(4, 1);
CALL SafeBuyIn(5, 1);
CALL SafeBuyIn(6, 1);



CALL SafeBuyIn(7, 8);
CALL SafeBuyIn(8, 4);
CALL SafeBuyIn(9, 9);
CALL SafeBuyIn(10, 0);
CALL SafeBuyIn(11, 3);
CALL SafeBuyIn(12, 9);

CALL SafeMakeBet(9, 1);
CALL SafeMakeBet(7, 1);
CALL SafeMakeBet(8, 1);
CALL SafeMakeBet(10, 1);
CALL SafeMakeBet(12, 1);
CALL SafeMakeBet(11, 1);
CALL SafeMakeBet(12, 1);




SELECT * FROM Game_Account;
-- Test Round 1: A full round with all the players just making bets 
-- However, due to their buyins being only a dollar we should see some go all go all in 

-- This Tests the following Conditionals:

-- All the players have placed their bets and the Subround is the River (last subround)
--  p_Subround_Type_ID != River_ID AND Subround_Bet_Count = (Game_Accounts_Count- (Outer_Fold_Count+ Outer_All_In_Count))

-- All the players have placed their bets and the Subround is NOT the river
-- p_Subround_Type_ID = River_ID AND Subround_Bet_Count = (Game_Accounts_Count- (Outer_Fold_Count + Outer_All_In_Count)) 


-- Pre-Flop 
CALL SafeMakeBet(1, 1);
CALL SafeMakeBet(2, 1);
CALL SafeMakeBet(3, 0);
CALL SafeMakeBet(4, 0);
CALL SafeMakeBet(5, 0);
CALL SafeMakeBet(6, 1);

-- Flop
CALL SafeMakeBet(1, 1);
CALL SafeMakeBet(2, 1);
CALL SafeMakeBet(3, 1);
CALL SafeMakeBet(4, 1);
CALL SafeMakeBet(5, 1);
CALL SafeMakeBet(6, 1);

-- Turn 
CALL SafeMakeBet(1, 1);
CALL SafeMakeBet(2, 1);
CALL SafeMakeBet(3, 1);
CALL SafeMakeBet(4, 1);
CALL SafeMakeBet(5, 1);
CALL SafeMakeBet(6, 1);

-- River
CALL SafeMakeBet(1, 1);
CALL SafeMakeBet(2, 1);
CALL SafeMakeBet(3, 1);
CALL SafeMakeBet(4, 1);
CALL SafeMakeBet(5, 1);
CALL SafeMakeBet(6, 1);

-- Show Player Cards, Community Cards, The Pay-Out, The Game_account to show winner got the money
-- Show all the bets placed in the round
-- Show that a new round is generated upon round closure and a new subround starts
SELECT * FROM Community_Cards;
SELECT * FROM Players_Cards;
SELECT * FROM Pay_Out;
SELECT * FROM Rake_Out;
SELECT * FROM Game_Account;
SELECT * FROM Make_Bet;
SELECT * FROM Subround;
SELECT * FROM Round;
SELECT * FROM Debug_Temp;



-- Test Round 2: Two player Quits on the Pre-Flop; One Player Folds on the Flop; Two Players fold on the Turn; Player 6 should win

-- This Tests the Main Conditional:

-- There is only one player who hasn't folded or left the game
-- IF (Game_Accounts_Count - Fold_Count) = 1 

-- Also tests robustness in handling quits preflop (with out having bet), multi round folding, detecting a loss of players
CALL SafeBuyOut(2, 2.340);


-- Show Account Game Account Closes
CALL SafeBuyOut(5, 0.200);
CALL SafeBuyOut(6, 0.300);

SELECT * FROM Game_Account; 
SELECT * FROM Buy_Out; 
SELECT * FROM Player; 

-- Test Round 2: Two player Quits on the Pre-Flop; One Player Folds on the Flop; Two Players fold on the Turn; Player 6 should win

-- Pre-Flop 
CALL SafeMakeBet(3, 1);
CALL SafeMakeBet(4, 1);
CALL SafeMakeBet(5, 1);
CALL SafeMakeBet(6, 1);

-- Flop
CALL SafeMakeBet(3, 1);
CALL SafeMakeBet(4, 1);
CALL SafeMakeBet(5, 1);
CALL SafeMakeBet(6, 0);

-- Turn 
CALL SafeMakeBet(4, 0);
CALL SafeMakeBet(5, 0);
CALL SafeMakeBet(3, 1);

SELECT * FROM Make_Bet;
SELECT * FROM Game_Account;
SELECT * FROM Pay_Out;
SELECT * FROM Subround;

-- Show Complex Query of the round, its Subround Types, the bet types, the amounts in each bet
SELECT 
    MB.Game_Account_ID, 
    BT.Bet_Type, 
    MB.Subround_ID, 
    MB.Bet_Amount, 
    AST.Subround_Name
FROM Make_Bet MB
JOIN All_Bet_Types BT ON MB.Bet_Type_ID = BT.Bet_Type_ID
JOIN Subround S ON MB.Subround_ID = S.Subround_ID
JOIN All_Subround_Types AST ON S.Subround_Type_ID = AST.Subround_Type_ID
WHERE MB.Subround_ID IN (
    SELECT Subround_ID
    FROM Subround
    WHERE Round_ID = 1
)
ORDER BY MB.Subround_ID ASC;


-- Test Round 3: 4 players left in the game, and some have their accounts low
--  keep them betting till one or all of them has to go all in
-- Tests the Main conditional 
-- All the players have either folded or went all-in
-- Game_Accounts_Count = (Fold_Count + All_In_Count) AND All_In_Count != 0 
-- Pre-Flop 
CALL SafeMakeBet(4, 1);
CALL SafeMakeBet(5, 1);
CALL SafeMakeBet(6, 1);

-- Flop
CALL SafeMakeBet(3, 1);
CALL SafeMakeBet(4, 1);
CALL SafeMakeBet(5, 1);
CALL SafeMakeBet(6, 1);

-- Turn 

CALL SafeMakeBet(4, 1);
CALL SafeMakeBet(5, 1);
CALL SafeMakeBet(3, 1);
CALL SafeMakeBet(6, 1);

-- River
CALL SafeMakeBet(3, 1);
CALL SafeMakeBet(4, 1);
CALL SafeMakeBet(5, 1);


CALL PlayerPokerRecords(Null, 1, 'All Players Cards Records');
CALL PlayerPokerRecords(Null, 1, 'All Community Cards Records');



CALL PlayerPokerRecords(Null, 1, 'All Bet Records');
SELECT 
    MB.Game_Account_ID, 
    BT.Bet_Type, 
    MB.Subround_ID, 
    MB.Bet_Amount, 
    AST.Subround_Name
FROM Make_Bet MB
JOIN All_Bet_Types BT ON MB.Bet_Type_ID = BT.Bet_Type_ID
JOIN Subround S ON MB.Subround_ID = S.Subround_ID
JOIN All_Subround_Types AST ON S.Subround_Type_ID = AST.Subround_Type_ID
WHERE MB.Subround_ID IN (
    SELECT Subround_ID
    FROM Subround
    WHERE Round_ID = (SELECT Round_ID FROM Subround WHERE Subround_ID = 8)
)
ORDER BY MB.Subround_ID ASC;

 

SELECT 
	SUM(CASE 
		WHEN MB.Bet_Type_ID = (SELECT Bet_Type_ID FROM All_Bet_Types WHERE Bet_Type = 'All-In') AND
		NOT EXISTS (
					SELECT 1
					FROM Game_Account GA
					WHERE GA.Game_Account_ID = MB.Game_Account_ID
					AND GA.Time_Closed IS NOT NULL AND GA.Game_ID IS NOT NULL)
		THEN 1 ELSE 0 END), MB.Game_Account_ID
	FROM Make_Bet MB
	JOIN Subround SR ON MB.Subround_ID = SR.Subround_ID
	JOIN Round R ON SR.Round_ID = R.Round_ID
	WHERE R.Round_ID = (
		SELECT SR.Round_ID FROM Subround SR
		WHERE SR.Subround_ID = p_Subround_ID
	); 

SELECT * FROM Game_Account;
SELECT * FROM Pay_Out;














SELECT * FROM Community_Cards;
SELECT * FROM Players_Cards;
    

SELECT * FROM Debug_Temp;
SELECT * FROM Make_Bet;

SELECT * FROM Game_Account;
SELECT * FROM Make_Bet;
SELECT * FROM Subround;
SELECT * FROM Round;

SELECT * FROM Rake_Out;
SELECT * FROM Debug_Money;

SELECT * FROM Community_Cards;
SELECT * FROM Players_Cards;

/**DELETE FROM Subround;
DELETE FROM Buy_Out;
DELETE FROM Game;
DELETE FROM Game_Account;
DELETE FROM Buy_In;
DELETE FROM Rake_Out;
DELETE FROM Make_Bet;
DELETE FROM Players_Cards;*/

/*SELECT * FROM Game_Account;
SELECT * FROM Make_Bet;
SELECT * FROM System_Register;
SELECT * FROM Subround;
SELECT * FROM Rake_Out;

SELECT * FROM Debug_Temp;
SELECT * FROM Make_Bet;
SELECT * FROM Pay_Out;
SELECT * FROM Community_Cards;
SELECT * FROM Game_Account;
SELECT * FROM Subround;
SELECT * FROM Round;

SELECT * FROM Community_Cards;
SELECT * FROM Players_Cards;
SELECT * FROM Pay_Out;

SELECT * FROM Player;
SELECT * FROM Buy_In;
SELECT * FROM Buy_Out;*/









-- SELECT LT.Limit_Type FROM All_Limit_Types LT WHERE exists(SELECT * FROM Game G WHERE G.Limit_Type_ID = LT.Limit_Type_ID);
-- SELECT MS.Max_Seats FROM All_Seat_Types MS WHERE exists(SELECT * FROM Game G WHERE G.Max_Seats_ID = MS.Max_Seats_ID);



















