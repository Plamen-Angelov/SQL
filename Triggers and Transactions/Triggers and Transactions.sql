use Bank

-- Task 1 / 14



CREATE TABLE Logs(
LogId INT PRIMARY KEY IDENTITY,
AccountId INT,
OldSum MONEY NOT NULL,
NewSum MONEY NOT NULL
)

GO

CREATE TRIGGER tr_SaveSumChanges
ON Accounts
FOR UPDATE
AS
	INSERT INTO Logs
	SELECT i.Id, d.Balance, i.Balance
	FROM Inserted AS i, Deleted AS d



UPDATE Accounts
SET Balance = 200
WHERE Id = 1

GO

-- Task 2 / 15

CREATE TABLE NotificationEmails(
Id INT PRIMARY KEY IDENTITY,
Recipient INT NOT NULL,
[Subject] VARCHAR(70) NOT NULL,
Body VARCHAR(300) NOT NULL
)


CREATE TRIGGER tr_NotificationEmail
ON Logs
FOR INSERT
AS
BEGIN
	DECLARE @recipient INT 
	DECLARE @subject varchar(70) 
	DECLARE @oldBalance money 
	DECLARE @newBalance money 
	DECLARE @body varchar(300)

	SET @recipient = (SELECT AccountId FROM inserted)
	SET @subject = ('Balance change for account: ' + CAST(@recipient AS varchar(12)))
	SET @oldBalance = (SELECT OldSum from inserted)
	SET @newBalance = (SELECT NewSum from inserted)
	SET @body = 'On ' + CAST(GETDATE() AS varchar(12)) + ' your balance was changed from ' + CAST(@oldBalance AS varchar(20)) 
	+ ' to ' + CAST(@newBalance AS varchar(20))


	INSERT INTO NotificationEmails
	VALUES (@recipient, @subject, @body)

END

GO

UPDATE Accounts
SET Balance = 1000
WHERE Id = 2

-- Task 3 / 16

GO

CREATE PROC usp_DepositMoney(@AccountId INT, @MoneyAmount DECIMAL(18, 4))
AS
BEGIN TRANSACTION
			IF (@MoneyAmount < 0 OR @MoneyAmount IS NULL)
			BEGIN
				ROLLBACK
				RAISERROR('Invalid Amount', 1, 1)
				RETURN
			END

			IF (NOT EXISTS(SELECT Id FROM Accounts
						   WHERE Id = @AccountId) OR @AccountId IS NULL)
			BEGIN
				ROLLBACK
				RAISERROR('Invalid AccountId', 1, 1)
				RETURN
			END

			UPDATE Accounts
			   SET Balance += @MoneyAmount
			 WHERE Id = @AccountId
COMMIT

EXEC usp_DepositMoney 1, 10.0000

GO

-- Task 4 / 17

CREATE PROC usp_WithdrawMoney (@accountId INT, @moneyAmount DECIMAL(16,4))
AS
BEGIN TRANSACTION
		IF (@moneyAmount < 0 OR @moneyAmount IS NULL)
		BEGIN
			ROLLBACK
			RAISERROR('Invalid amount', 16, 2)
		END
		
		IF (NOT EXISTS (SELECT Id 
						FROM Accounts
						WHERE Id = @accountId) OR @accountId IS NULL)
		BEGIN 
			ROLLBACK
			RAISERROR('Invalid accountId', 16, 1)
		END
		
		UPDATE Accounts
		SET Balance -= @moneyAmount
		WHERE Id = @accountId
COMMIT


-- Task 5 / 18

GO

CREATE PROC usp_TransferMoney(@senderId INT, @receiverId INT, @amount DECIMAL(16, 4))
AS
BEGIN
BEGIN TRANSACTION
		EXEC usp_WithdrawMoney @senderId, @amount
		EXEC usp_DepositMoney @receiverId, @amount
COMMIT
END
GO

------------

use SoftUni

-- Task 8 / 21

GO
CREATE PROC usp_AssignProject(@emloyeeId INT, @projectID INT)
AS
BEGIN
	BEGIN TRANSACTION

		IF ((SELECT COUNT(ProjectID)
			FROM EmployeesProjects
			WHERE EmployeeID = @emloyeeId) >= 3)
		BEGIN
				RAISERROR('The employee has too many projects!', 16, 1)
				ROLLBACK
		END

		INSERT INTO EmployeesProjects
		VALUES (@emloyeeId, @projectID)
	COMMIT
END

-- Task 9 / 22

GO
CREATE TRIGGER tr_DeletedEmployees
ON Employees
FOR DELETE
AS
	INSERT INTO Deleted_Employees
	SELECT FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary
	FROM deleted
