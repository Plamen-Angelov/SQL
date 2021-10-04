use Gringotts

-- Task 1

SELECT COUNT(*) [Count]
  FROM WizzardDeposits


-- Task 2

SELECT MAX(MagicWandSize) AS LongestMagicWand
  FROM WizzardDeposits

-- Task 3

    SELECT DepositGroup,
	       MAX(MagicWandSize) AS LongestMagicWand
      FROM WizzardDeposits
  GROUP BY DepositGroup


  -- Task 4

    SELECT TOP (2) DepositGroup
      FROM WizzardDeposits
  GROUP BY DepositGroup
  ORDER BY AVG(MagicWandSize)


--  Task 5

  SELECT DepositGroup,
	     SUM(DepositAmount) AS TotalSum
    FROM WizzardDeposits
GROUP BY DepositGroup


-- Task 6

 SELECT DepositGroup,
	    SUM(DepositAmount) AS TotalSum
   FROM WizzardDeposits
   WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup

-- Task 7

  SELECT DepositGroup,
	     SUM(DepositAmount) AS TotalSum
    FROM WizzardDeposits
   WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
  HAVING SUM(DepositAmount) < 150000
ORDER BY TotalSum DESC


-- Task 8

  SELECT DepositGroup,
	     MagicWandCreator,
	     MIN(DepositCharge) AS MinDepositCharge
    FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup


-- Task 9

SELECT AgeGroup,
	   COUNT(FirstName) AS WizardCount
FROM (SELECT FirstName,
	             CASE
		         WHEN Age <= 10 THEN '[0-10]'
		         WHEN Age > 10 AND Age <= 20 THEN '[11-20]'
		         WHEN Age > 20 AND Age <= 30 THEN '[21-30]'
		         WHEN Age > 30 AND Age <= 40 THEN '[31-40]'
		         WHEN Age > 40 AND Age <= 50 THEN '[41-50]'
		         WHEN Age > 50 AND Age <= 60 THEN '[51-60]'
		         ElSE '[61+]'
		         END AS AgeGroup
            FROM WizzardDeposits) AS s
GROUP BY AgeGroup


-- Task 10

  SELECT *
	FROM (
		 SELECT LEFT(FirstName,1) AS FirstLetter
		 FROM WizzardDeposits
		 WHERE DepositGroup = 'Troll Chest'
		 ) AS FirstLetterColumn
GROUP BY FirstLetter
ORDER BY FirstLetter


-- Task 11

  SELECT DepositGroup
         ,IsDepositExpired
   	     ,AVG(DepositInterest) AS AverageInterest
    FROM WizzardDeposits
   WHERE DepositStartDate > '1985-01-01'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired

-- Task 12

SELECT SUM([Difference]) AS SumDifference
  FROM (SELECT *, 
			   [Host Wizard Deposit] - [Guest Wizard Deposit] AS [Difference]
		  FROM (SELECT FirstName AS [Host Wizzard],
	                   DepositAmount AS [Host Wizard Deposit],
			           LEAD(FirstName) OVER (ORDER BY ID) AS [Guest Wizard],
			           LEAD(DepositAmount) OVER (ORDER BY ID) AS [Guest Wizard Deposit]
				  FROM WizzardDeposits
				) AS Comparision
		) AS Diff

GO

USE SoftUni

GO

-- Task 13

  SELECT DepartmentID,
	     SUM(Salary)
    FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID

-- Task 14

  SELECT DepartmentID,
		 MIN(Salary) AS MinimumSalary
    FROM Employees
   WHERE DepartmentID IN (2, 5, 7) AND HireDate > '2000-01-01'
GROUP BY DepartmentID

-- Task 15

SELECT *
  INTO HighSalaryTable
  FROM Employees
 WHERE Salary > 30000

DELETE FROM HighSalaryTable
 WHERE ManagerID = 42

UPDATE HighSalaryTable
   SET Salary += 5000
 WHERE DepartmentID = 1

  SELECT DepartmentID
	  	 ,AVG(Salary) AS AverageSalary
    FROM HighSalaryTable
GROUP BY DepartmentID

-- Task 16

  SELECT DepartmentID,
	  	 MAX(Salary) AS MaxSalary
    FROM Employees
GROUP BY DepartmentID
  HAVING MAX(Salary) < 30000 OR MAX(Salary) > 70000

-- Task 17

SELECT COUNT(Salary) AS [Count]
 FROM (
		SELECT *
		  FROM Employees
		 WHERE ManagerID IS NULL
	  ) AS m

-- Task 18

SELECT DISTINCT DepartmentID,
				Salary AS ThirdHighestSalary
		   FROM (
					SELECT DepartmentID,
		                   Salary,
						   DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS SalaryRank
				      FROM Employees
				) AS sr
		  WHERE SalaryRank = 3


-- Task 19

SELECT TOP(10) FirstName,
			   LastName,
			   e.DepartmentID
		  FROM Employees AS e
		  JOIN
	           (
	              SELECT DepartmentID,
	           		 	 AVG(Salary) AS AverageSalary
	               	FROM Employees
	           	GROUP BY DepartmentID
	           ) AS [avg]
			ON e.DepartmentID = [avg].DepartmentID
		 WHERE Salary > AverageSalary
	  ORDER BY e.DepartmentID