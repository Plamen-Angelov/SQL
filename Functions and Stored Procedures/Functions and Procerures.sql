--USE SoftUni

-- Task 1


CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000
AS
	SELECT FirstName, LastName
	FROM Employees
	WHERE Salary > 35000

	
-- Task 2

CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber (@salaryBorder decimal(18,4))
AS
	SELECT FirstName
		   ,LastName
	FROM Employees
	WHERE Salary >= @salaryBorder


EXEC usp_GetEmployeesSalaryAboveNumber 48100


-- Task 3

CREATE PROC usp_GetTownsStartingWith (@startingSring nvarchar(10))
AS
	SELECT [Name] AS Town
	  FROM Towns
	 WHERE LEFT([Name], LEN(@startingSring)) = @startingSring


EXEC usp_GetTownsStartingWith 'B'


-- Task 4
GO

CREATE PROC usp_GetEmployeesFromTown (@town varchar(50))
AS
	SELECT e.FirstName
		   ,e.LastName
	  FROM Employees AS e
	  JOIN Addresses AS a ON e.AddressID = a.AddressID
	  JOIN Towns AS t ON a.TownID = t.TownID
	 WHERE t.[Name] = @town

EXEC usp_GetEmployeesFromTown 'Sofia'

GO

-- Таск 5

CREATE FUNCTION ufn_GetSalaryLevel(@salary decimal(18,4))
RETURNS varchar(7)
AS
BEGIN
	DECLARE @salaryLevel varchar(7)

	IF(@salary < 30000)
	SET @salaryLevel = 'Low'
	ELSE IF(@salary <= 50000)
	SET @salaryLevel = 'Average'
	ELSE
	SET @salaryLevel = 'High'

	RETURN @salaryLevel
END


SELECT Salary,
		dbo.ufn_GetSalaryLevel(Salary) AS SalaryLevel
FROM Employees

-- Task 6

CREATE PROC usp_EmployeesBySalaryLevel (@salaryLevel varchar(7))
AS
	SELECT FirstName
		   ,LastName
	  FROM (SELECT FirstName
				   ,LastName
			 	   ,dbo.ufn_GetSalaryLevel(Salary) AS SalaryLevel
		      FROM Employees
		   ) AS sl
	 WHERE SalaryLevel = @salaryLevel


EXEC usp_EmployeesBySalaryLevel 'high'


-- Task 7

CREATE FUNCTION ufn_IsWordComprised(@setOfLetters varchar(30), @word varchar(30))
RETURNS BIT
AS
BEGIN
	DECLARE @count INT = 1
	DECLARE @letter CHAR(1)

	WHILE (@count <= LEN(@word))
		BEGIN
		SET @letter = SUBSTRING(@word, @count, 1)
		IF @setOfLetters NOT LIKE '%' + @letter + '%'
			RETURN 0

		SET @count += 1
		END
RETURN 1
END

SELECT dbo.ufn_IsWordComprised('oistmiahf', 'Sofia') AS Result
SELECT dbo.ufn_IsWordComprised('oistmiahf', 'halves') AS Result

-- Task 8

CREATE PROC usp_DeleteEmployeesFromDepartment (@departmentId INT)
AS
	DELETE FROM EmployeesProjects
	WHERE EmployeeID IN (SELECT EmployeeID 
						   FROM Employees
						  WHERE DepartmentID = @departmentId)

	UPDATE Employees
	   SET ManagerID = NULL
	 WHERE ManagerID IN (SELECT EmployeeID
						   FROM Employees
					      WHERE DepartmentID = @departmentId)

	ALTER TABLE Departments 
	ALTER COLUMN ManagerID INT NULL

	UPDATE Departments
	   SET ManagerID = NULL 
	 WHERE DepartmentID = @departmentID

	DELETE FROM Employees
	 WHERE DepartmentID = @departmentId

	DELETE FROM Departments
	 WHERE DepartmentID = @departmentId

	SELECT COUNT(*)
	  FROM Employees
	 WHERE DepartmentID = @departmentId


EXEC usp_DeleteEmployeesFromDepartment 3

-------
GO
use Bank
GO

-- Task 9

CREATE PROC usp_GetHoldersFullName
AS
	SELECT CONCAT(FirstName, ' ', LastName) AS [Full Name]
	  FROM AccountHolders


EXEC usp_GetHoldersFullName

-- Task 10

CREATE PROC usp_GetHoldersWithBalanceHigherThan (@amount decimal)
AS
SELECT h.FirstName,
		h.LastName
FROM AccountHolders AS h
JOIN Accounts AS a ON h.Id = a.AccountHolderId
GROUP BY h.FirstName, h.LastName
HAVING SUM(a.Balance) > @amount
ORDER BY FirstName, LastName


--Task 11

CREATE FUNCTION ufn_CalculateFutureValue (@sum decimal, @interest float, @years int)
RETURNS decimal(18, 4)
AS
BEGIN
RETURN @sum*(POWER((1 + @interest), @years))
END

SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5)


-- Task 12

CREATE PROC usp_CalculateFutureValueForAccount (@accountID int, @interest float)
AS
SELECT a.Id AS [Account Id]
	   ,FirstName
	   ,LastName
	   ,Balance AS [Current Balance]
	   ,dbo.ufn_CalculateFutureValue(Balance, @interest, 5) AS [Balance in 5 years]
FROM AccountHolders AS h
JOIN Accounts AS a ON h.Id = a.AccountHolderId
WHERE a.Id = @accountID

EXEC usp_CalculateFutureValueForAccount 1, 0.1

------

use Diablo

-- Task 13

GO

CREATE FUNCTION ufn_CashInUsersGames(@gameName VARCHAR(50))
RETURNS TABLE 
AS
RETURN(SELECT SUM(Cash) AS SumCash
		 FROM (SELECT Cash
					  ,ROW_NUMBER() OVER (ORDER BY ug.Cash DESC) AS [Rank]
				 FROM UsersGames AS ug
				 JOIN Games AS g ON ug.GameId = g.Id
				WHERE g.[Name] = @gameName) AS RankTable
		WHERE [Rank] % 2 = 1
	   )

SELECT * FROM dbo.ufn_CashInUsersGames ('Love in a mist')