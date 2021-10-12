-- Task 1

CREATE DATABASE WMS
USE WMS

CREATE TABLE Clients(
ClientId INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(50)NOT NULL,
LastName VARCHAR(50)NOT NULL,
Phone VARCHAR(12) CHECK(LEN(Phone) = 12)
)

CREATE TABLE Mechanics(
MechanicId INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(50)NOT NULL,
LastName VARCHAR(50)NOT NULL,
[Address] VARCHAR(255) NOT NULL
)


CREATE TABLE Models(
ModelId INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Jobs(
JobId INT PRIMARY KEY IDENTITY,
ModelId INT FOREIGN KEY REFERENCES Models([ModelId]) NOT NULL,
[Status] VARCHAR(11) DEFAULT 'Pending' CHECK([Status] IN ('Pending', 'In Progress', 'Finished')) NOT NULL,
ClientId INT FOREIGN KEY REFERENCES Clients([ClientId]) NOT NULL,
MechanicId INT FOREIGN KEY REFERENCES Mechanics([MechanicId]),
IssueDate DATE NOT NULL,
FinishDate DATE
)

CREATE TABLE Orders(
OrderId INT PRIMARY KEY IDENTITY,
JobId INT FOREIGN KEY REFERENCES Jobs([JobId]) NOT NULL,
IssueDate DATE,
Delivered BIT DEFAULT 0 NOT NULL
)

CREATE TABLE Vendors(
VendorId INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Parts(
PartId INT PRIMARY KEY IDENTITY,
SerialNumber VARCHAR(50) UNIQUE NOT NULL,
[Description] VARCHAR(255),
Price DECIMAL(6,2) NOT NULL CHECK(Price > 0),
VendorId INT FOREIGN KEY REFERENCES Vendors([VendorId]) NOT NULL,
StockQty INT DEFAULT 0 NOT NULL CHECK(StockQty >= 0)
)

CREATE TABLE OrderParts(
OrderId INT FOREIGN KEY REFERENCES Orders([OrderId]) NOT NULL,
PartId INT FOREIGN KEY REFERENCES Parts([PartId]) NOT NULL,
PRIMARY KEY (OrderId, PartId),
Quantity INT DEFAULT 1 NOT NULL CHECK(Quantity > 0)
)

CREATE TABLE PartsNeeded(
JobId INT FOREIGN KEY REFERENCES Jobs([JobId]) NOT NULL,
PartId INT FOREIGN KEY REFERENCES Parts([PartId]) NOT NULL,
PRIMARY KEY (JobId, PartId),
Quantity INT DEFAULT 1 NOT NULL CHECK(Quantity > 0)
)

-- Task 2

INSERT INTO Clients
VALUES
('Teri', 'Ennaco', '570-889-5187'),
('Merlyn', 'Lawler', '201-588-7810'),
('Georgene', 'Montezuma', '925-615-5185'),
('Jettie', 'Mconnell', '908-802-3564'),
('Lemuel', 'Latzke', '631-748-6479'),
('Melodie', 'Knipp', '805-690-1682'),
('Candida', 'Corbley', '908-275-8357')


INSERT INTO Parts(SerialNumber, [Description], Price, VendorId)
VALUES
('WP8182119', 'Door Boot Seal', 117.86, 2),
('W10780048', 'Suspension Rod', 42.81, 1),
('W10841140', 'Silicone Adhesive ', 6.77, 4),
('WPY055980', 'High Temperature Adhesive', 13.94, 3)

-- Task 3

UPDATE Jobs
SET MechanicId = 3
WHERE [Status] = 'Pending'

UPDATE Jobs
SET [Status] = 'In Progress'
WHERE [Status] = 'Pending'

-- Task 4

DELETE FROM OrderParts
WHERE OrderId = 19

DELETE FROM OrderParts
WHERE OrderId = 19

-- Task 5

SELECT CONCAT(FirstName, ' ', LastName) AS Mechanic,
		[Status],
		IssueDate
FROM Mechanics AS m
LEFT JOIN Jobs AS j ON m.MechanicId = j.MechanicId
ORDER BY m.MechanicId, IssueDate, j.JobId

-- Task 6

SELECT Client, [Days going], [Status]
FROM(
		SELECT CONCAT(FirstName, ' ', LastName) AS Client,
				DATEDIFF(DAY, j.IssueDate, '2017-04-24') AS [Days going],
				j.[Status],
				c.ClientId
		FROM Clients AS c
		LEFT JOIN Jobs AS j ON c.ClientId = j.ClientId
		WHERE j.[Status] <> 'Finished') AS tab
ORDER BY [Days going] DESC, ClientId


-- Task 7

SELECT CONCAT(m.FirstName, ' ', m.LastName) AS Mechanic,
		AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) AS [Average Days]
FROM Mechanics AS m
LEFT JOIN Jobs AS j ON m.MechanicId = j.MechanicId
WHERE j.[Status] = 'Finished'
GROUP BY m.FirstName, m.LastName, m.MechanicId
ORDER BY m.MechanicId


-- Task 8

SELECT CONCAT(m.FirstName, ' ', m.LastName) AS Available
FROM Mechanics AS m
WHERE MechanicId NOT IN (SELECT DISTINCT m.MechanicId
							FROM Mechanics AS m
							LEFT JOIN Jobs AS j ON m.MechanicId = j.MechanicId
							WHERE j.[Status]  IN ('In Progress', 'Pending'))
ORDER BY MechanicId



-- Task 9

  SELECT JobId,
	     SUM(PartAmount) As Total
    FROM (
			 SELECT j.JobId,
			 		j.[Status],
			 		(ISNULL(p.Price,0) * ISNULL(op.Quantity, 0)) AS PartAmount
			 FROM Jobs AS j
			 LEFT JOIN Orders AS o ON j.JobId = o.JobId
			 LEFT JOIN OrderParts AS op ON o.OrderId = op.OrderId
			 LEFT JOIN Parts AS p ON op.PartId = p.PartId
			 WHERE [Status] = 'Finished'
		 ) AS sorted
GROUP BY JobId
ORDER BY Total DESC, JobId


-- Task 10

SELECT *
FROM(
SELECT p.PartId,
		p.[Description],
		ISNULL(pn.Quantity, 0) AS [Required],
		ISNULL(p.StockQty, 0) AS [In Stock],
		ISNULL(op.Quantity, 0) AS Ordered
--SELECT *
FROM Jobs AS j
LEFT JOIN PartsNeeded AS pn ON j.JobId = pn.JobId
LEFT JOIN Parts AS p ON pn.PartId = p.PartId
LEFT JOIN Orders AS o ON j.JobId = o.JobId
LEFT JOIN OrderParts AS op ON o.OrderId = op.OrderId
WHERE j.[Status] <> 'Finished' ) sorted
WHERE [Required] > ([In Stock] + Ordered)
ORDER BY PartId



--Task 12

GO

CREATE FUNCTION udf_GetCost(@jobId INT)
RETURNS DECIMAL(8,2)
AS
BEGIN

DECLARE @ordersCount INT
DECLARE @ordersAmount DECIMAL(8,2)

SET @ordersCount = (SELECT COUNT(*)
					  FROM Jobs As j
					  JOIN Orders AS o ON j.JobId = o.JobId
					 WHERE j.JobId = @jobID)

SET @ordersAmount = (SELECT SUM(op.Quantity * p.Price) AS Result
					   FROM Jobs As j
					   JOIN Orders AS o ON j.JobId = o.JobId
					   JOIN OrderParts AS op ON o.OrderId = op.OrderId
					   JOIN Parts AS p ON op.PartId = p.PartId
					  WHERE j.JobId = @jobId
				   GROUP BY j.JobId)

IF(@ordersCount = 0)
	RETURN 0


RETURN @ordersAmount

END
GO

SELECT dbo.udf_GetCost(3)