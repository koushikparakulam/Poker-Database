USE poker_room;

DROP USER IF EXISTS 'BillyBob'@'localhost';

DROP ROLE IF EXISTS 'Poker_Admin'@'localhost';
DROP ROLE IF EXISTS 'Poker_Player'@'localhost';

CREATE ROLE 'Poker_Admin'@'localhost';
CREATE ROLE 'Poker_Player'@'localhost';

-- Admin can make changes to anything related to the schema
GRANT ALL PRIVILEGES ON poker_room.* TO 'Poker_Admin'@'localhost';

-- Only Procedural Access for Player
GRANT EXECUTE ON PROCEDURE poker_room.PlayerPokerRecords TO 'Poker_Player'@'localhost';
GRANT EXECUTE ON PROCEDURE poker_room.SafeBuyIn TO 'Poker_Player'@'localhost';
GRANT EXECUTE ON PROCEDURE poker_room.SafeBuyOut TO 'Poker_Player'@'localhost';
GRANT EXECUTE ON PROCEDURE poker_room.SafeMakeBet TO 'Poker_Player'@'localhost';



CREATE USER 'BillyBob'@'localhost' IDENTIFIED BY 'Bobismyname';
GRANT 'Poker_Player'@'localhost' TO 'BillyBob'@'localhost';
SET DEFAULT ROLE 'Poker_Player'@'localhost' TO 'BillyBob'@'localhost';


-- Activate automatic role activation on login
SET PERSIST activate_all_roles_on_login = ON;

-- Refresh privileges
FLUSH PRIVILEGES;

SHOW GRANTS FOR 'Poker_Player'@'localhost';
