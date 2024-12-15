# Poker Room Database Management System

## Overview
The Poker Room Database Management System is designed to manage a poker game environment by handling game creation, player registration, betting transactions, and results processing. The database includes tables for storing player details, game states, betting transactions, and payouts. Additionally, it features stored procedures, triggers, and constraints to maintain game integrity.

## Features
### 1. **Database Schema**
- Structured relational tables to store **players, games, rounds, subrounds, bets, payouts, and rake processing**.
- Uses **foreign key constraints** to enforce relationships between entities.
- Supports **various game mechanics** like buy-ins, bet types, and seat limits.

### 2. **Triggers for Game Integrity**
- Prevents invalid deletions with **transaction constraints**.
- Enforces betting rules and round transitions automatically.
- Manages game state changes efficiently.

### 3. **Stored Procedures**
- `SafeBuyIn` ensures secure player buy-ins, prevents duplicate game accounts, and assigns players to active games.
- `SafeBuyOut` allows a player to leave the game while maintaining account integrity.
- `SafeMakeBet` handles betting transactions ensuring rule compliance.

### 4. **User Roles and Privileges**
- **Poker_Admin** role with full database access.
- **Poker_Player** role with access restricted to essential procedures.
- Example user **'BillyBob'** with limited privileges.

### 5. **Testing & Debugging Tools**
- `Debug_Temp` and `Debug_Money` tables store transaction logs.
- `scratch_queries.sql` contains test queries to verify game functions.
- `test_complete_database.sql` provides a full test suite for the system.

## Installation
### **Step 1: Set Up the Database**
Run the following command in MySQL to create the database:
```sql
CREATE DATABASE poker_room;
USE poker_room;
```

### **Step 2: Execute SQL Scripts**
Run the SQL files in the following order to set up the system properly:
```sh
mysql -u root -p poker_room < create_reference_tables.sql
mysql -u root -p poker_room < create_parent_tables.sql
mysql -u root -p poker_room < create_dependent_tables.sql
mysql -u root -p poker_room < create_all_tables.sql
mysql -u root -p poker_room < create_weak_entity_tables.sql
mysql -u root -p poker_room < create_all_triggers.sql
mysql -u root -p poker_room < create_user_admin_privilege.sql
```

### **Step 3: Verify the Schema**
Run the following command to ensure tables are correctly created:
```sql
SHOW TABLES;
```

## Usage
### **1. Player Registration and Buy-Ins**
Register a player by inserting into the `Player` table:
```sql
INSERT INTO Player (Player_Name, Address, Age, Credit_Card_Number)
VALUES ('JohnDoe', '123 Main St', 30, 1234567890123456);
```
Buy into a game securely:
```sql
CALL SafeBuyIn(1, 100.00);
```

### **2. Placing Bets**
Players can place bets during a round:
```sql
CALL SafeMakeBet(1, 10.00);
```

### **3. Checking Game Status**
To see active games and player details:
```sql
SELECT * FROM Game;
SELECT * FROM Player;
SELECT * FROM Make_Bet;
```

### **4. Ending Games and Cashing Out**
Players can leave a game using:
```sql
CALL SafeBuyOut(1, 50.00);
```

## Testing
### **Running Tests**
To run all test cases, execute:
```sh
mysql -u root -p poker_room < test_complete_database.sql
mysql -u root -p poker_room < test_SafeBuyIn.sql
```
This will simulate player buy-ins, betting rounds, and game progressions.

### **Debugging**
Check logs in the debug tables:
```sql
SELECT * FROM Debug_Temp;
SELECT * FROM Debug_Money;
```

## Resetting the Database
To drop all tables and reset the database, execute:
```sh
mysql -u root -p poker_room < drop_me_quickly.sql
```

## Additional Information
- For additional information check out the Poker_Database.pdf document for in-depth workings of the database



