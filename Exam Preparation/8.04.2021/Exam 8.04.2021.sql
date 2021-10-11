-- TASK 1

CREATE DATABASE Service
USE Service


CREATE TABLE Users(
Id INT PRIMARY KEY IDENTITY NOT NULL,
Username NVARCHAR(30) UNIQUE NOT NULL,
[Password] NVARCHAR(50) NOT NULL,
[Name] NVARCHAR(50),
Birthdate DATETIME2,
Age INT CHECK(Age >= 14 AND Age <= 110),
Email NVARCHAR(50) NOT NULL
)

CREATE TABLE Departments(
Id INT PRIMARY KEY IDENTITY NOT NULL,
[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Employees(
Id INT PRIMARY KEY IDENTITY NOT NULL,
FirstName NVARCHAR(25),
LastName NVARCHAR(25),
Birthdate DATETIME2,
Age INT CHECK(Age >= 18 AND Age <= 110),
DepartmentId INT FOREIGN KEY REFERENCES Departments (Id) 
)

CREATE TABLE Categories(
Id INT PRIMARY KEY IDENTITY NOT NULL,
[Name] NVARCHAR(50) NOT NULL,
DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL
)

CREATE TABLE [Status](
Id INT PRIMARY KEY IDENTITY NOT NULL,
[Label] NVARCHAR(30) NOT NULL
)

CREATE TABLE Reports(
Id INT PRIMARY KEY IDENTITY NOT NULL,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
StatusId INT FOREIGN KEY REFERENCES [Status](Id) NOT NULL,
OpenDate DATETIME2 NOT NULL,
CloseDate DATETIME2,
[Description] NVARCHAR(200) NOT NULL,
UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
)

-- Task 2

INSERT INTO Employees(FirstName, LastName, Birthdate, DepartmentId)
VALUES
('Marlo', 'O''Malley', CONVERT(DATETIME2, '1958-9-21'), 1),
('Niki', 'Stanaghan', CONVERT(DATETIME2, '1969-11-26'), 4),
('Ayrton', 'Senna', CONVERT(DATETIME2, '1960-03-21'), 9),
('Ronnie', 'Peterson', CONVERT(DATETIME2, '1944-02-14'), 9),
('Giovanna', 'Amati', CONVERT(DATETIME2, '1959-07-20'), 5)

INSERT INTO Reports
VALUES
(1, 1, CONVERT(DATETIME2, '2017-04-13'), NULL, 'Stuck Road on Str.133', 6, 2),
(6, 3, CONVERT(DATETIME2, '2015-09-05'), CONVERT(DATETIME2, '2015-12-06'), 'Charity trail running', 3, 5),
(14, 2, CONVERT(DATETIME2, '2015-09-07'), NULL, 'Falling bricks on Str.58', 5, 2),
(4, 3, CONVERT(DATETIME2, '2017-07-03'), CONVERT(DATETIME2, '2017-07-06'), 'Cut off streetlight on Str.11', 1, 1)


-- Task 3

UPDATE Reports
SET CloseDate = GETDATE()
WHERE CloseDate IS NULL

-- Task 4

DELETE FROM Reports
WHERE [StatusId] = 4

-- Task 5

SELECT [Description],
	    FORMAT(OpenDate, 'dd-MM-yyyy') AS OpenDate
FROM(
		SELECT [Description],
		       CONVERT(DATE, OpenDate) AS OpenDate
		  FROM Reports
	 	 WHERE EmployeeId IS NULL) AS m
ORDER BY DATEPART(YEAR, OpenDate), DATEPART(MONTH, OpenDate), DATEPART(DAY, OpenDate), [Description]



SELECT [Description],
	   FORMAT(OpenDate, 'dd-MM-yyyy') AS OpenDate
  FROM (SELECT [Description],
	           CONVERT(DATE, OpenDate) AS OpenDate,
		       ROW_NUMBER() OVER (ORDER BY OpenDate) AS [Rank]
	      FROM Reports
	     WHERE EmployeeId IS NULL) as m
ORDER BY [Rank]


-- Task 6

  SELECT [Description],
	  	 c.[Name]
    FROM Reports AS r
    JOIN Categories AS c ON r.CategoryId = C.Id
ORDER BY [Description], c.[Name]


-- Task 7


  SELECT TOP(5) *
    FROM (SELECT c.[Name],
			     COUNT(r.Id) AS ReportsPerCategory
		    FROM Categories AS c
		    JOIN Reports AS r ON c.Id = r.CategoryId
	    GROUP BY c.[Name]) AS m
ORDER BY ReportsPerCategory DESC, [Name]


-- Task 8

  SELECT u.Username,
	     c.[Name]
    FROM Reports AS r
    JOIN Users AS u ON r.UserId = u.Id
    JOIN Categories AS c ON r.CategoryId = c.Id
   WHERE DATEPART(MONTH, r.OpenDate) = DATEPART(MONTH, u.Birthdate) AND DATEPART(DAY, r.OpenDate) = DATEPART(DAY, u.Birthdate)
ORDER BY u.Username, c.[Name]


-- Task 9

   SELECT *
     FROM (SELECT CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
		  COUNT(u.Id) AS UsersCount
     FROM Employees AS e
LEFT JOIN Reports AS r ON e.Id = r.EmployeeId
LEFT JOIN Users AS u ON r.UserId = u.Id
 GROUP BY e.FirstName, e.LastName) AS uc
 ORDER BY UsersCount DESC, FullName


-- Task 10

   SELECT CASE 
			WHEN COALESCE(e.FirstName, e.LastName) IS NOT NULL
			THEN CONCAT(e.FirstName, ' ', e.LastName)
			ELSE 'None'
	      END AS Employee,
		  ISNULL(d.[Name], 'None')  AS Department,
		  ISNULL(c.[Name], 'None') AS Category,
		  ISNULL(r.[Description], 'None'),
		  ISNULL(FORMAT(r.OpenDate, 'dd.MM.yyyy'), 'None') AS OpenDate,
		  ISNULL(s.[Label], 'None') AS [Status],
		  ISNULL(u.[Name], 'None')
     FROM Reports AS r
LEFT JOIN Employees AS e ON r.EmployeeId = e.Id
LEFT JOIN Users AS u ON r.UserId = u.Id
LEFT JOIN Departments AS d ON e.DepartmentId = d.Id
LEFT JOIN Categories AS c ON r.CategoryId = c.Id
LEFT JOIN [Status] AS s ON r.StatusId = s.Id
 ORDER BY e.FirstName DESC, e.LastName DESC, d.[Name], c.[Name], r.[Description], r.OpenDate, s.[Label], u.[Name]

 -- Task 11

 GO

 CREATE FUNCTION udf_HoursToComplete (@StartDate DATETIME, @EndDate DATETIME)
 RETURNS INT
 AS
 BEGIN
		DECLARE @HoursNeeded INT
		IF @StartDate IS NULL OR @EndDate IS NULL
			RETURN 0
		ELSE
			SET @HoursNeeded = DATEDIFF(HOUR, @StartDate, @EndDate)

		RETURN @HoursNeeded
 END

 GO

 SELECT dbo.udf_HoursToComplete(OpenDate, CloseDate) AS TotalHours
   FROM Reports

 --Task 12

 GO

 CREATE PROC usp_AssignEmployeeToReport(@EmployeeId INT, @ReportId INT)
 AS
 BEGIN
	DECLARE @EmployeesDepartmentId INT
	DECLARE @ReportsDepartmentId INT

	SET @EmployeesDepartmentId = (SELECT DepartmentId
								   FROM Employees 
								  WHERE Id = @EmployeeId)

	SET @ReportsDepartmentId = (SELECT d.Id
								 FROM Reports AS r
								 JOIN Categories AS c ON r.CategoryId = c.Id
								 JOIN Departments AS d ON c.DepartmentId = d.Id
								WHERE r.Id = @ReportId)

	IF @EmployeesDepartmentId = @ReportsDepartmentId
		UPDATE Reports
		   SET EmployeeId = @EmployeeId
		 WHERE Id = @ReportId
	ELSE
		THROW 51000, 'Employee doesn''t belong to the appropriate department!', 12
 END

 GO

 EXEC usp_AssignEmployeeToReport 30, 1
 EXEC usp_AssignEmployeeToReport 17, 2