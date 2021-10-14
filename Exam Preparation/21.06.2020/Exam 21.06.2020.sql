CREATE DATABASE TripService

use TripService

-- Task 1

CREATE TABLE Cities(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(20) NOT NULL,
CountryCode VARCHAR(2) NOT NULL CHECK(LEN(CountryCode) = 2)
)

CREATE TABLE Hotels(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30) NOT NULL,
CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
EmployeeCount INT NOT NULL,
BaseRate DECIMAL(6,2)
)

CREATE TABLE Rooms(
Id INT PRIMARY KEY IDENTITY,
Price DECIMAL(8,2) NOT NULL,
[Type] NVARCHAR(20) NOT NULL,
Beds INT NOT NULL,
HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL
)

CREATE TABLE Trips(
Id INT PRIMARY KEY IDENTITY,
RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL,
BookDate DATE NOT NULL,
ArrivalDate DATE NOT NULL,
ReturnDate DATE NOT NULL,
CancelDate DATE
)

CREATE TABLE Accounts(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50) NOT NULL,
MiddleName NVARCHAR(20),
LastName NVARCHAR(50) NOT NULL,
CityId INT FOREIGN KEY REFERENCES Cities(Id) NOT NULL,
BirthDate DATE NOT NULL,
Email VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE AccountsTrips(
AccountId INT FOREIGN KEY REFERENCES Accounts(Id) NOT NULL,
TripId INT FOREIGN KEY REFERENCES Trips(Id) NOT NULL,
PRIMARY KEY(AccountId, TripId),
Luggage INT NOT NULL CHECK(Luggage >= 0)
)

-- Task 2

INSERT INTO Accounts
VALUES
('John',	 'Smith',	'Smith', 34,	'1975-07-21',	'j_smith@gmail.com'),
('Gosho',	NULL, 'Petrov',	11,	'1978-05-16',	'g_petrov@gmail.com'),
('Ivan', 'Petrovich', 'Pavlov', 59, '1849-09-26', 'i_pavlov@softuni.bg'),
('Friedrich',	'Wilhelm',	'Nietzsche',	2,	'1844-10-15',	'f_nietzsche@softuni.bg')

INSERT INTO Trips
VALUES
(101,	'2015-04-12',	'2015-04-14',	'2015-04-20',	'2015-02-02'),
(102,	'2015-07-07',	'2015-07-15',	'2015-07-22',	'2015-04-29'),
(103,	'2013-07-17',	'2013-07-23',	'2013-07-24',	NULL),
(104,	'2012-03-17',	'2012-03-31',	'2012-04-01',	'2012-01-10'),
(109,	'2017-08-07',	'2017-08-28',	'2017-08-29',	NULL)

-- Task 3

UPDATE Rooms
SET Price *= 1.14
WHERE HotelId IN (5, 7, 9)


-- Task 4


DELETE FROM AccountsTrips
WHERE AccountId = 47

-- Task 5

  SELECT a.FirstName
		 ,a.LastName
		 ,FORMAT(a.BirthDate, 'MM-dd-yyyy')
		 ,c.[Name] AS Hometown
		 ,a.Email
    FROM Accounts AS a
    JOIN Cities AS c ON a.CityId = c.Id
   WHERE Email LIKE 'e%'
ORDER BY c.[Name]

-- Task 6

  SELECT c.[Name]
		 ,COUNT(h.[Name]) AS Hotels
    FROM Cities AS c
    JOIN Hotels AS h ON c.Id = h.CityId
GROUP BY c.[Name]
ORDER BY COUNT(h.[Name]) DESC, c.[Name]

-- Task 7

   SELECT AccountId 
		  ,FullName
		  ,MAX(TripDays) AS LongestTrip
		  , MIN(TripDays) AS ShortestTrip
     FROM (
			     SELECT a.Id AS AccountId
			    		,CONCAT(a.FirstName, ' ', LastName) AS FullName
			    		,DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate) AS TripDays
			      FROM Accounts AS a
			      JOIN AccountsTrips AS at ON a.Id = at.AccountId
			      JOIN Trips As t ON at.TripId = t.Id
			     WHERE a.MiddleName IS NULL AND t.CancelDate IS NULL
		  ) AS w
GROUP BY AccountId, FullName
ORDER BY LongestTrip DESC, ShortestTrip


-- Task 8

SELECT TOP (10) c.Id
				,c.[Name] AS City
				,c.CountryCode AS Country
				,COUNT(a.Id)
		   FROM Cities AS c
		   JOIN Accounts AS a ON c.Id = a.CityId
	   GROUP BY c.CountryCode, c.Id, c.[Name]
	   ORDER BY COUNT(a.Id) DESC

-- Task 9

  SELECT Id
		 ,Email
		 ,City
		 ,Count(tripId)
   FROM (
			 SELECT a.Id
			 		 ,a.Email
			 		 ,c.[Name] AS City
			 		 ,t.Id AS tripId
			   FROM Accounts AS a
			   JOIN Cities AS c ON a.CityId = c.Id
			   JOIN AccountsTrips AS at ON a.Id = at.AccountId
			   JOIN Trips As t ON at.TripId = t.Id
			   JOIN Rooms AS r ON t.RoomId = r.Id
			   JOIN Hotels AS ht ON r.HotelId = ht.Id
			  WHERE ht.CityId = c.Id
	     ) AS w
GROUP BY Id, Email, City
ORDER BY Count(tripId) DESC, Id

-- Task 10

SELECT t.Id
		,CONCAT(a.FirstName, ' ', MiddleName, ' ', LastName) AS [Full Name]
		,c.[Name] AS [From]
		,ct.[Name] AS [To]
		,CASE
			WHEN t.CancelDate IS NOT NULL THEN 'Canceled'
			ELSE CONCAT(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate), ' ', 'days')
			END AS Duration
FROM Accounts AS a
JOIN Cities AS c ON a.CityId = c.Id
JOIN AccountsTrips AS [at] ON a.Id = [at].AccountId
JOIN Trips AS t ON [at].TripId = t.Id
JOIN Rooms AS r ON t.RoomId = r.Id
JOIN Hotels AS h ON r.HotelId = h.Id
JOIN Cities AS ct ON h.CityId = ct.Id
ORDER BY [Full Name], Id


-- Task 12

GO

CREATE PROC usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS
BEGIN

DECLARE @tripHotelId INT
DECLARE @targetHotelId INT

SET @tripHotelId = 
(SELECT h.Id
FROM Rooms AS r
JOIN Trips AS t ON r.Id = t.RoomId
JOIN Hotels AS h ON r.HotelId = h.Id
WHERE t.Id = @TripId)

SET @targetHotelId = 
(SELECT h.Id
FROM Hotels AS h
JOIN Rooms AS r ON h.Id = r.HotelId
WHERE r.Id = @TargetRoomId)

IF @tripHotelId <> @targetHotelId
THROW 51000, 'Target room is in another hotel!', 2

DECLARE @tourists INT
DECLARE @targetRoomBeds INT

SET @tourists =
(SELECT COUNT(AccountId)
FROM Trips AS t
JOIN AccountsTrips AS [at] ON t.Id = [at].TripId
WHERE t.Id = @TripId)

SET @targetRoomBeds =
(SELECT Beds
FROM Rooms
WHERE Id = @TargetRoomId)

IF @tourists > @targetRoomBeds
THROW 51000, 'Not enough beds in target room!', 1

UPDATE Trips
SET RoomId = @TargetRoomId
WHERE Id = @TripId

END