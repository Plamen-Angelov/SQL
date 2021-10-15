CREATE DATABASE ColonialJourney

USE ColonialJourney

-- Task 1

CREATE TABLE Planets(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE Spaceports(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
PlanetId INT FOREIGN KEY REFERENCES Planets(Id) NOT NULL
)

CREATE TABLE Spaceships(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
Manufacturer VARCHAR(30) NOT NULL,
LightSpeedRate INT DEFAULT 0
)

CREATE TABLE Colonists(
Id INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(20) NOT NULL,
LastName VARCHAR(20) NOT NULL,
Ucn VARCHAR(10) UNIQUE NOT NULL,
BirthDate DATE NOT NULL
)

CREATE TABLE Journeys(
Id INT PRIMARY KEY IDENTITY,
JourneyStart DATETIME NOT NULL,
JourneyEnd DATETIME NOT NULL,
Purpose VARCHAR(11) CHECK(Purpose IN ('Medical', 'Technical', 'Educational', 'Military')),
DestinationSpaceportId INT FOREIGN KEY REFERENCES Spaceports(Id) NOT NULL,
SpaceshipId INT FOREIGN KEY REFERENCES Spaceships(Id) NOT NULL
)

CREATE TABLE TravelCards(
Id INT PRIMARY KEY IDENTITY,
CardNumber CHAR(10) UNIQUE NOT NULL CHECK(LEN(CardNumber) = 10),
JobDuringJourney VARCHAR(8) CHECK(JobDuringJourney IN ('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook')),
ColonistId INT FOREIGN KEY REFERENCES Colonists(Id) NOT NULL,
JourneyId INT FOREIGN KEY REFERENCES Journeys(Id) NOT NULL
)

-- Task 2

INSERT INTO Planets
VALUES
('Mars'),
('Earth'),
('Jupiter'),
('Saturn')


INSERT INTO Spaceships
VALUES
('Golf',	'VW',	3),
('WakaWaka', 'Wakanda',	4),
('Falcon9',	'SpaceX',	1),
('Bed',	'Vidolov',	6)

-- Task 3

UPDATE Spaceships
SET LightSpeedRate += 1
WHERE Id BETWEEN 8 AND 12

-- Task 4

DELETE FROM TravelCards
WHERE JourneyId IN (1, 2, 3)

DELETE FROM Journeys
WHERE Id IN (1, 2, 3)

-- Task 5

  SELECT Id
		 ,FORMAT(JourneyStart, 'dd/MM/yyyy') AS JourneyStart
		 ,FORMAT(JourneyEnd, 'dd/MM/yyyy') AS JourneyEnd
    FROM Journeys
   WHERE Purpose = 'Military'
ORDER BY JourneyStart

-- Task 6

  SELECT c.Id
	   	 ,CONCAT(FirstName, ' ', LastName) AS FullName
    FROM Colonists AS c
    JOIN TravelCards AS t ON c.Id = t.ColonistId
   WHERE JobDuringJourney = 'pilot'
ORDER BY c.Id

-- Task 7

  SELECT COUNT(*) AS [Count]
    FROM Colonists AS c
    JOIN TravelCards AS t ON c.Id = t.ColonistId
	JOIN Journeys AS j ON t.JourneyId = j.Id
   WHERE j.Purpose = 'technical'

-- Task 8

  SELECT sc.[Name]
		 ,sc.Manufacturer
    FROM Spaceships As sc
    JOIN Journeys AS j ON sc.Id = j.SpaceshipId
    JOIN TravelCards AS tc ON sc.Id = tc.JourneyId
    JOIN Colonists AS c ON tc.ColonistId = c.Id
   WHERE (tc.JobDuringJourney = 'pilot') AND (DATEDIFF(YEAR, c.BirthDate, '2019-01-01') < 30)
ORDER BY sc.[Name]

-- TASK 9

  SELECT p.[Name] AS PlanetName
		 ,COUNT(j.Id) AS JourneysCount
    FROM Planets AS p
    JOIN Spaceports AS s ON p.Id = s.PlanetId
    JOIN Journeys AS j ON s.Id = j.DestinationSpaceportId
GROUP BY p.[Name]
ORDER BY JourneysCount DESC, p.[Name]

-- Task 10

SELECT JobDuringJourney
	   ,CONCAT(FirstName, ' ', LastName) AS FullName
	   ,[RANK] AS JobRank
  FROM (
		  SELECT c.FirstName
		  		,c.LastName
		  		,t.JobDuringJourney
		  		,DENSE_Rank() OVER (PARTITION BY t.JobDuringJourney ORDER BY c.BirthDate
		) AS [Rank]
 FROM Colonists AS c
 JOIN TravelCards AS t ON c.Id = t.ColonistId) AS RankingTable
 WHERE [Rank] = 2


 -- Task 11

 GO

CREATE FUNCTION udf_GetColonistsCount(@PlanetName VARCHAR (30))
RETURNS INT
AS
BEGIN

DECLARE @countOfColonists INT =
(SELECT COUNT(t.ColonistId)
FROM Planets AS p
JOIN Spaceports AS s ON p.Id = s.PlanetId
JOIN Journeys AS j ON s.Id = j.DestinationSpaceportId
JOIN TravelCards AS t ON j.Id = t.JourneyId
WHERE p.[Name] = @PlanetName)

RETURN @countOfColonists
END

GO

SELECT dbo.udf_GetColonistsCount('Otroyphus')

-- Task 12

GO

CREATE PROC usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(11))
AS
BEGIN

IF NOT EXISTS 
(SELECT *
FROM Journeys
WHERE Id = @JourneyId)
THROW 50000, 'The journey does not exist!', 1

IF EXISTS
(SELECT *
FROM Journeys
WHERE Id = @JourneyId AND Purpose = @NewPurpose)
THROW 50000, 'You cannot change the purpose!', 2

UPDATE Journeys
SET Purpose = @NewPurpose
WHERE Id = @JourneyId

END

GO

EXEC usp_ChangeJourneyPurpose 4, 'Technical'	
EXEC usp_ChangeJourneyPurpose 2, 'Educational'
EXEC usp_ChangeJourneyPurpose 196, 'Technical'
