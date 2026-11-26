-- 1. Create Tables
CREATE TABLE IF NOT EXISTS accounts (
account_id INT PRIMARY KEY,
customer_name VARCHAR(100) NOT NULL,
balance DECIMAL(10, 2) NOT NULL,
last_interest_time DATETIME NULL
);

CREATE TABLE IF NOT EXISTS interest_log (
log_id INT AUTO_INCREMENT PRIMARY KEY,
account_id INT NOT NULL,
interest_added DECIMAL(10, 2) NOT NULL,
log_time DATETIME NOT NULL
);

-- 2. Insert Initial Data
INSERT INTO accounts (account_id, customer_name, balance, last_interest_time) VALUES
(1, 'Kasun', 9500.00, NULL),
(2, 'Nimal', 12000.00, NULL),
(3, 'Ravi', 20000.00, NULL)
ON DUPLICATE KEY UPDATE balance = VALUES(balance), last_interest_time = VALUES(last_interest_time);

-- 3. Create Event
DROP EVENT IF EXISTS add_interest;

DELIMITER $$  CREATE EVENT add_interest ON SCHEDULE EVERY 1 MINUTE DO BEGIN DECLARE v_log_time DATETIME; SET v_log_time = NOW();      -- Log interest calculated on original balance before updating account balance INSERT INTO interest_log (account_id, interest_added, log_time) SELECT account_id, ROUND(balance * 0.01, 2), v_log_time FROM accounts WHERE balance > 10000;      -- Update balance and last_interest_time for eligible accounts UPDATE accounts SET balance = ROUND(balance * 1.01, 2), last_interest_time = v_log_time WHERE balance > 10000; END$$

DELIMITER ;

-- 4. Testing Procedure for Q3:
-- SELECT * FROM accounts;
-- SELECT * FROM interest_log;