use SoftUni

-- Tast 1

SELECT TOP(5) 
		 e.EmployeeID
		,e.JobTitle
		,a.AddressID
		,a.AddressText
    FROM Employees as e
    JOIN Addresses as a on e.AddressID = a.AddressID
ORDER BY a.AddressID

-- Task 2

  SELECT top(50)
		  e.FirstName
		 ,e.LastName
		 ,t.Name as Town
		 ,a.AddressText
    FROM Employees as e
    JOIN Addresses as a on e.AddressID = a.AddressID
    JOIN Towns as t on a.TownID = t.TownID
ORDER BY FirstName, LastName

-- Task 3

  SELECT e.EmployeeID
		 ,e.FirstName
		 ,e.LastName
		 ,d.Name as DepartmentName
    FROM Employees as e
    JOIN Departments as d on e.DepartmentID = d.DepartmentID
   WHERE d.Name = 'Sales'
ORDER BY e.EmployeeID

-- Task 4

  SELECT top (5)
		 e.EmployeeID
		 ,e.FirstName
		 ,e.Salary
		 ,d.Name as DepartmentName
    FROM Employees as e
    JOIN Departments as d on e.DepartmentID = d.DepartmentID
   WHERE e.Salary > 15000
ORDER BY d.DepartmentID

-- Task 5

SELECT top (3) e.EmployeeID
		       ,e.FirstName
     FROM Employees as e
LEFT JOIN EmployeesProjects as ep on e.EmployeeID = ep.EmployeeID
    WHERE ep.ProjectID is null
 ORDER BY e.EmployeeID

-- Task 6

  SELECT e.FirstName
		 ,e.LastName
		 ,e.HireDate
		 ,d.[Name] as DeptName
    FROM Employees as e
    JOIN Departments as d on e.DepartmentID = d.DepartmentID
   WHERE HireDate > 1999-01-01 and d.[Name] in ('Sales', 'Finance')
ORDER BY HireDate

-- Task 7

SELECT TOP(5) e.EmployeeID
		      ,e.FirstName
		      ,p.[Name] as ProjectName
         FROM Employees as e
         JOIN EmployeesProjects as ep on e.EmployeeID = ep.EmployeeID
         JOIN Projects as p on ep.ProjectID = p.ProjectID
        WHERE p.StartDate > '2002-08-13' AND p.EndDate is null
     ORDER BY e.EmployeeID

-- Task 8

SELECT e.EmployeeID
		,e.FirstName
		, CASE
			WHEN DATEPART(YEAR, p.StartDate) >= 2005 then null
			else p.[Name]
		END AS ProjectName
FROM Employees as e
JOIN EmployeesProjects as ep on e.EmployeeID = ep.EmployeeID
JOIN Projects as p on ep.ProjectID = p.ProjectID
WHERE e.EmployeeID = 24

--Task 9

  SELECT e.EmployeeID
		 ,e.FirstName
		 , e.ManagerID
		 ,m.FirstName as ManagerName
    FROM Employees as e
    JOIN Employees as m on e.ManagerID = m.EmployeeID
   WHERE e.ManagerID in (3, 7)
ORDER BY e.EmployeeID

-- Task 10

  SELECT top(50)
		 e.EmployeeID
		 ,CONCAT(e.FirstName, ' ', e.LastName) as EmployeeName
		 ,CONCAT(m.FirstName, ' ', m.LastName) as ManagerName
		 ,d.Name as DepartmentName
    FROM Employees as e
    JOIN Employees as m on e.ManagerID = m.EmployeeID
    JOIN Departments as d on e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID

-- Task 11

  SELECT TOP(1) AVG(Salary) as MinAverageSalary
    FROM Employees
GROUP BY DepartmentID
ORDER BY MinAverageSalary

------------------------------------
SELECT MIN(AverageSalaries) as MinAverageSalary
  FROM (SELECT AVG(Salary) AS AverageSalaries
  	    FROM Employees as e
  	    GROUP BY DepartmentID) AS AvgSalaries

----

use Geography

-- Task 12

SELECT c.CountryCode
	   ,m.MountainRange
	   ,p.PeakName
	   ,p.Elevation
FROM Countries as c
JOIN MountainsCountries as mc ON c.CountryCode = mc.CountryCode
JOIN Mountains as m ON mc.MountainId = m.Id
JOIN Peaks as p ON m.Id = p.MountainId
WHERE c.CountryCode = 'BG' AND p.Elevation > 2835
ORDER BY p.Elevation DESC

-- Task 13

SELECT c.CountryCode
	   ,COUNT(m.MountainRange) AS MaountainRanges
FROM Countries AS c
JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
JOIN Mountains AS m ON mc.MountainId = m.Id
WHERE c.CountryCode IN ('US', 'RU', 'BG')
GROUP BY c.CountryCode

-- Task 14

SELECT TOP(5) c.CountryName
			  ,r.RiverName
         FROM Countries AS c
    LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
    LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
        WHERE c.ContinentCode = 'AF'
     ORDER BY c.CountryName

-- Task 15

SELECT ContinentCode
	   ,CurrencyCode
	   ,CurrencyUsage
FROM
        (SELECT *, 
        		  DENSE_RANK() OVER (PARTITION BY ContinentCode ORDER BY CurrencyUsage DESC) AS CurrencyRank
         FROM (
        				SELECT ContinentCode,
        	                   CurrencyCode,
        	                   COUNT(CountryCode) AS CurrencyUsage
                        FROM Countries
                        GROUP BY ContinentCode, CurrencyCode) AS ccc
        WHERE CurrencyUsage > 1) AS cr
WHERE CurrencyRank = 1



-- Task 16

   SELECT COUNT(c.CountryName) AS [Count]
     FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
    WHERE m.MountainRange IS NULL
 GROUP BY m.MountainRange


-- Task 17

   SELECT TOP(5) c.CountryName
			  ,MAX(p.Elevation) AS HighestPeakElevation
			  ,MAX(r.Length) AS LongestRiverLength
     FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
LEFT JOIN Peaks AS p ON m.Id = p.MountainId
LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
 GROUP BY c.CountryName
 ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, CountryName

-- Task 18

	SELECT TOP(5) CountryName AS Country
		          ,ISNULL(PeakName, '(no highest peak)') AS [Highest Peak Name]
		          ,ISNULL(Elevation, 0) AS [Highest Peak Elevation]
		          ,ISNULL(MountainRange, '(no mountain)') AS Mountain
            FROM
                      (SELECT c.CountryName
                  			,p.PeakName
                  			,p.Elevation
                  			,m.MountainRange
                  			,DENSE_RANK() OVER(PARTITION BY c.CountryName ORDER BY p.Elevation DESC) AS [Rank]
                       FROM Countries AS c
                  LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
                  LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
                  LEFT JOIN Peaks AS p ON m.Id = p.MountainId) AS PeaksRanking
           WHERE PeaksRanking.[Rank] = 1
        ORDER BY Country, [Highest Peak Name]