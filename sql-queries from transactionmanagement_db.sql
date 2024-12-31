-- Database Creation
CREATE DATABASE TransactionHistory_db;

-- Table Creation
CREATE TABLE UserTable (
    UserId INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(30),
    Email VARCHAR(20),
    PhoneNumber INT,
    UserType VARCHAR(20),
    WalletBalance INT
);

CREATE TABLE TransactionTable (
    TransactionId INT AUTO_INCREMENT PRIMARY KEY,
    SenderId INT,
    ReceiverId INT,
    MerchantId INT,
    Amount INT,
    TransactionDate DATE,
    Status VARCHAR(10),
    FOREIGN KEY(SenderId) REFERENCES UserTable(UserId),
    FOREIGN KEY(ReceiverId) REFERENCES UserTable(UserId),
    FOREIGN KEY(MerchantId) REFERENCES UserTable(UserId)
);

CREATE TABLE ProductTable (
    ProductId INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(20),
    Category VARCHAR(20),
    Price INT,
    MerchantId INT,
    FOREIGN KEY(MerchantId) REFERENCES UserTable(UserId)
);

CREATE TABLE TransactionHistory (
    HistoryID INT AUTO_INCREMENT PRIMARY KEY,
    TransactionID INT,
    changedAmount DECIMAL(10,2),
    BalanceBefore DECIMAL(10,2),
    BalanceAfter DECIMAL(10,2),
    PaymentMethod VARCHAR(20)
);

-- Data Insertion
INSERT INTO UserTable VALUES
(1, 'Gaurab Khanal', 'gaurabkhanal0555@gmail.com', 9800000000, 'Sender', 1000),
(2, 'Neo Shakya', 'neoshakya@gmail.com', 9800000001, 'Receiver', 2000),
(3, 'Pragyan Shrestha', 'pragyanshrestha@gmail.com', 9800000002, 'Sender', 3000),
(4, 'Kathmandu University', 'ku.edu.np', 071577259, 'Merchant', 20000),
(5, 'ITTI', 'itti.com.np', 071577260, 'Merchant', 30000),
(6, 'Mudita', 'mudita.com.np', 071577261, 'Merchant', 40000);

INSERT INTO TransactionHistory VALUES
(301, 101, -500.00, 1500.50, 1000.50, 'Credit Card'),
(302, 102, -1500.00, 2000.00, 500.00, 'esewa'),
(303, 103, -5000.00, 20000.00, 15000.00, 'Debit Card'),
(304, 104, -1000.00, 1500.50, 500.50, 'Credit Card'),
(305, 105, -200.00, 2000.00, 1800.00, 'khalti');

INSERT INTO ProductTable VALUES
(1001, 'Smartphone', 'Electronics', 799.99, 4),
(1002, 'Laptop', 'Electronics', 1200.00, 4),
(1003, 'Headphones', 'Electronics', 199.99, 5),
(1004, 'Washing Machine', 'Home Appliances', 450.00, 5),
(1005, 'Refrigerator', 'Home Appliances', 850.00, 6);

INSERT INTO TransactionTable VALUES
(101, 1, 2, NULL, 500, '2024-12-25', 'Completed'),
(102, 3, 2, NULL, 1500, '2024-12-26', 'Completed'),
(103, 4, NULL, 5, 5000, '2024-12-27', 'Completed'),
(104, 1, 3, NULL, 1000, '2024-12-28', 'Pending'),
(105, 3, NULL, 5, 200, '2024-12-29', 'Completed');

-- Basic Queries
SELECT * FROM UserTable;
SELECT * FROM TransactionTable;
SELECT * FROM ProductTable;
SELECT * FROM TransactionHistory;

-- Join Operations
-- Inner Join between TransactionTable and TransactionHistory
SELECT t.TransactionID, t.Amount, th.PaymentMethod, th.BalanceBefore, th.BalanceAfter 
FROM TransactionTable t 
INNER JOIN TransactionHistory th 
ON t.TransactionID = th.TransactionID;

-- Inner Join between TransactionTable, UserTable and TransactionHistory
SELECT t.TransactionID, u.FullName, t.Amount, th.PaymentMethod 
FROM TransactionTable t 
INNER JOIN UserTable u ON t.SenderId = u.UserId 
INNER JOIN TransactionHistory th ON t.TransactionID = th.TransactionID;

-- Left Join
SELECT t.TransactionID, u.FullName, t.Amount, th.PaymentMethod 
FROM TransactionTable t 
LEFT JOIN UserTable u ON t.SenderId = u.UserId 
LEFT JOIN TransactionHistory th ON t.TransactionID = th.TransactionID;

-- Right Join
SELECT t.TransactionID, t.Amount, th.PaymentMethod, th.BalanceBefore, th.BalanceAfter 
FROM TransactionTable t 
RIGHT JOIN TransactionHistory th 
ON t.TransactionID = th.TransactionID;

-- Transaction Management Procedures

-- Transaction with error scenario
DELIMITER //
CREATE PROCEDURE transaction_error_case()
BEGIN
    START TRANSACTION;
    
    -- Deduct balance from Gaurab Khanal
    UPDATE UserTable
    SET WalletBalance = WalletBalance - 100
    WHERE FullName = 'Gaurab Khanal';
    
    -- Attempt to add balance to a non-existent user
    UPDATE UserTable 
    SET WalletBalance = WalletBalance + 100
    WHERE FullName = 'NonExistent';
    
    COMMIT;
END //
DELIMITER ;

-- Successful Transaction without Rollback scenario
DELIMITER //
CREATE PROCEDURE transaction_success()
BEGIN
    START TRANSACTION;
    
    UPDATE UserTable SET WalletBalance=WalletBalance-100 WHERE FullName='Gaurab Khanal';
    UPDATE UserTable SET WalletBalance=WalletBalance+100 WHERE FullName='Neo Shakya';
    
    COMMIT;
END //
DELIMITER ;

-- Transaction with error handling
DELIMITER //
CREATE PROCEDURE transaction_with_error_handling()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transaction failed,rollback executed' AS message;
    END;
    
    START TRANSACTION;
    
    UPDATE UserTable SET WalletBalance=WalletBalance-100 WHERE FullName='Gaurab Khanal';
    UPDATE UserTable SET WalletBalance=WalletBalance+100 WHERE FullName='Neo Shakya';
    
    COMMIT;
END //
DELIMITER ;
