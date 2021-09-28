-- Problem 1

SELECT FirstName, LastName 
  FROM Employees
 WHERE LEFT(FirstName, 2) = 'Sa'


SELECT FirstName, LastName
  FROM Employees
 Where FirstName LIKE 'Sa%'


-- Problem 2

SELECT FirstName, LastName
  FROM Employees
 WHERE CHARINDEX('ei', LastName, 1) <> 0


 SELECT FirstName, LastName
 FROM Employees
 WHERE LastName like '%ei%'


 -- Problem 3

 SELECT FirstName
   FROM Employees
  WHERE DepartmentID in(3,10) AND (Year(HireDate) BETWEEN 1995 AND 2005)


 SELECT FirstName
   FROM Employees
  WHERE DepartmentID in (3,10) and DATEPART(Year, HireDate) BETWEEN 1995 AND 2005


  -- Problem 4

  SELECT FirstName, LastName
    FROM Employees
   WHERE CHARINDEX('engineer', JobTitle, 1) = 0


  SELECT FirstName, LastName
    FROM Employees
   WHERE JobTitle not like '%engineer%'


  -- Problem 5

  SELECT Name
    FROM Towns
   WHERE LEN(Name) in (5,6)
   ORDER BY Name


   -- Problem 6

      SELECT TownID, Name
        FROM Towns
       WHERE LEFT(Name, 1) in ('M', 'K', 'B', 'E')
	ORDER BY Name


	-- Problem 7

      SELECT TownID, Name
        FROM Towns
       WHERE LEFT(Name, 1) not in ('R','B', 'D')
	ORDER BY Name


	-- Problem 8

	CREATE view V_EmployeesHiredAfter2000
	AS
	SELECT FirstName, LastName
	FROM Employees
	Where YEAR(HireDate) > 2000


	CREATE view V_EmployeesHiredAfter2000
	AS
	SELECT FirstName, LastName
	  FROM Employees
	 Where DATEPART(YEAR, HireDate) > 2000

	-- Problem 9

	SELECT FirstName, LastName
	FROM Employees
	WHERE LEN(LastName) = 5

	-- Problem 10

	SELECT EmployeeID, FirstName, LastName, Salary,
	DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS Rank
	FROM Employees
	WHERE Salary BETWEEN 10000 AND 50000
	ORDER BY Salary DESC

	-- Problem 11

	  SELECT * 
	    FROM 
	         (SELECT EmployeeID, FirstName, LastName, Salary,
	                 DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS Rank
	           FROM Employees
	          WHERE Salary BETWEEN 10000 AND 50000) AS RankTable
	   WHERE RANK = 2
	ORDER BY Salary DESC
	--

	use Geography

	-- Problem 12

	  SELECT CountryName as [Country Name], IsoCode as [ISO Code]
	    FROM Countries
	   WHERE CountryName Like '%a%a%a%'
	ORDER BY [ISO Code]

	-- Problem 13

	  SELECT p.PeakName, r.RiverName, LOWER(STUFF(p.PeakName, LEN(p.PeakName), 1, r.RiverName)) as Mix
	    FROM Peaks as p, Rivers as r
	   WHERE RIGHT(p.PeakName, 1) = LEFT(r.RiverName, 1)
	ORDER BY Mix


	  SELECT p.PeakName, r.RiverName, 
			 LOWER(CONCAT(LEFT(p.PeakName, LEN(p.PeakName) - 1), r.RiverName)) as Mix
	    FROM Peaks as p, Rivers as r
	   WHERE LOWER(RIGHT(p.PeakName, 1)) = LOWER(LEFT(r.RiverName, 1))
	ORDER BY Mix


	--

	USE Diablo

	-- Problem 14

	  SELECT TOP 50 Name,  FORMAT(Start, 'yyyy-MM-dd') as Start
	    FROM Games
	   WHERE YEAR(Start) in (2011, 2012)
	ORDER BY Start, Name


	-- Problem 15

	  SELECT Username, RIGHT(Email, LEN(Email) - Charindex('@', Email, 1)) as [Email Provider]
	    FROM Users
	   WHERE Email is not null
	ORDER BY [Email Provider], Username


	-- Problem 16

	  SELECT Username, IpAddress as [IP Address]
	    FROM Users
	   WHERE IpAddress like '___.1_%._%.___'
	ORDER BY Username

	-- Problem 17

	SELECT 
		Name as Game
		, CASE
			WHEN DATEPART(HOUR, Start) >= 0 AND DATEPART(HOUR, Start) < 12 THEN 'Morning'
			WHEN DATEPART(HOUR, Start) >= 12 AND DATEPART(HOUR, Start) < 18 THEN 'Afternoon'
			WHEN DATEPART(HOUR, Start) >= 18 AND DATEPART(HOUR, Start) < 24 THEN 'Evening'
		END AS [Part of the Day]
		, CASE 
			WHEN Duration <=3 THEN 'Extra Short'
			WHEN Duration >= 4 AND Duration <= 6 THEN 'Short'
			WHEN Duration > 6 THEN 'Long'
			WHEN Duration is null THEN 'Extra Long'
		END AS Duration
	FROM Games
	ORDER BY Game, Duration, [Part of the Day]
	--

	use Orders

	-- Problem 18

	SELECT 
		ProductName
		, OrderDate
		,DATEADD(DAY, 3, OrderDate) as [Pay Due]
		,DATEADD(MONTH, 1, OrderDate) as [Deliver Due]
	FROM Orders
	--

	use Demo

	-- Problem 19


	Create table People(
	Id int primary key identity,
	Name varchar(50) not null,
	Birthdate datetime2 not null
	)

	insert into People(Name, Birthdate)
	Values
	('Victor', '2000-12-07 00:00:00.000')
	,('Steven', '1992-09-10 00:00:00.000')
	,('Stephen', '1910-09-19 00:00:00.000')
	,('John', '2010-01-06 00:00:00.000')
	,('Plamen', '1987-11-22 00:00:00.000')

	SELECT
		Name
		,DATEDIFF(YEAR, Birthdate, GEtDATE()) as [Age in Years]
		,DATEDIFF(MONTH, Birthdate, GETDATE()) as [Age in Months]
		,DATEDIFF(DAY, Birthdate, GETDATE()) as [Age in Days]
		,DATEDIFF(Minute, Birthdate, GETDATE()) as [Age in Minutes]
	FROM People