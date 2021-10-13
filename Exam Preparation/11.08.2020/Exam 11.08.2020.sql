CREATE DATABASE Bakery

USE Bakery

-- Task 1

CREATE TABLE Countries(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) UNIQUE
)

CREATE TABLE Customers(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(25),
LastName NVARCHAR(25),
Gender CHAR(1) CHECK(Gender in ('M', 'F')),
Age INT,
PhoneNumber NCHAR(10) CHECK(LEN(PhoneNumber) = 10),
CountryId INT FOREiGN KEY REFERENCES Countries(Id)
)

CREATE TABLE Products(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(25) UNIQUE,
[Description] NVARCHAR(250),
Recipe NVARCHAR(MAX),
Price DECIMAL(16,2) CHECK(Price > 0)
)

CREATE TABLE Feedbacks(
Id INT PRIMARY KEY IDENTITY,
[Description] NVARCHAR(255),
Rate DECIMAL(4, 2) CHECK(Rate BETWEEN 0 AND 10),
ProductId INT FOREIGN KEY REFERENCES Products(Id),
CustomerId INT FOREIGN KEY REFERENCES Customers(Id)
)

CREATE TABLE Distributors(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(25) UNIQUE,
AddressText NVARCHAR(30),
Summary NVARCHAR(200),
CountryId INT FOREIGN KEY REFERENCES Countries(Id)
)

CREATE TABLE Ingredients(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30),
[Description] NVARCHAR(200),
OriginCountryId INT FOREIGN KEY REFERENCES Countries(Id),
DistributorId INT FOREIGN KEY REFERENCES Distributors(Id)
)

CREATE TABLE ProductsIngredients(
ProductId INT FOREIGN KEY REFERENCES Products(Id),
IngredientId INT FOREIGN KEY REFERENCES Ingredients(Id)
PRIMARY KEY(ProductId, IngredientId)
)

-- Task 2

INSERT INTO Distributors ([Name], CountryId, AddressText, Summary)
VALUES
('Deloitte & Touche', 2, '6 Arch St #9757', 'Customizable neutral traveling'),
('Congress Title', 13, '58 Hancock St', 'Customer loyalty'),
('Kitchen People', 1, '3 E 31st St #77', 'Triple-buffered stable delivery'),
('General Color Co Inc', 21, '6185 Bohn St #72', 'Focus group'),
('Beck Corporation', 23, '21 E 64th Ave', 'Quality-focused 4th generation hardware')

INSERT INTO Customers(FirstName, LastName, Age, Gender, PhoneNumber, CountryId)
VALUES
('Francoise', 'Rautenstrauch', 15, 'M', '0195698399', 5),
('Kendra', 'Loud', 22, 'F', '0063631526', 11),
('Lourdes', 'Bauswell', 50, 'M', '0139037043', 8),
('Hannah', 'Edmison', 18, 'F', '0043343686', 1),
('Tom', 'Loeza', 31, 'M', '0144876096', 23),
('Queenie', 'Kramarczyk', 30, 'F', '0064215793', 29),
('Hiu', 'Portaro', 25, 'M', '0068277755', 16),
('Josefa', 'Opitz', 43, 'F', '0197887645', 17)


-- Task 3

UPDATE Ingredients
SET DistributorId = 35
WHERE [Name]  IN ('Bay Leaf', 'Paprika', 'Poppy')

UPDATE Ingredients
SET OriginCountryId = 14
WHERE OriginCountryId = 8

-- Task 4

DELETE FROM Feedbacks
WHERE CustomerId = 14 OR ProductId = 5

-- Task 5

  SELECT [Name],
		 Price,
		 [Description]
    FROM Products
ORDER BY Price DESC, [Name]

-- Task 6

  SELECT f.ProductId,
		 f.Rate,
		 f.[Description],
		 c.Id,
		 c.Age,
		 c.Gender
    FROM Feedbacks AS f
    JOIN Customers AS c ON f.CustomerId = c.Id
   WHERE Rate < 5
ORDER BY ProductId DESC, Rate


-- Task 7

   SELECT CONCAT(FirstName, ' ', LastName) AS CustomerName,
		  c.PhoneNumber,
		  c.Gender
     FROM Customers AS c
LEFT JOIN Feedbacks AS f ON c.Id = f.CustomerId
    WHERE f.Id IS NULL
 ORDER BY c.Id

 -- Task 8

    SELECT c.FirstName,
		   c.Age,
	  	   c.PhoneNumber
      FROM Customers AS c
 LEFT JOIN Countries AS co ON c.CountryId = co.Id
     WHERE (c.Age >= 21 AND c.FirstName LIKE '%an%') OR (c.PhoneNumber LIKE '%38' AND co.[Name] <> 'Greece')
  ORDER BY c.FirstName, c.Age DESC

  -- Task 9

    SELECT d.[Name] AS DistributorName,
		   i.[Name] AS IngredientName,
		   p.[Name] AS ProductName,
		   AVG(Rate) AS AverageRate
	  FROM Distributors AS d
	  JOIN Ingredients AS i ON d.Id = i.DistributorId
	  JOIN ProductsIngredients AS [pi] ON i.Id = [pi].IngredientId
	  JOIN Products AS p ON [pi].ProductId = p.Id
      JOIN Feedbacks AS f ON p.Id = f.ProductId
  GROUP BY d.[Name], p.[Name], i.[Name]
    HAVING AVG(Rate) BETWEEN 5 AND 8
  ORDER BY d.[Name],  i.[Name], p.[Name]


  -- Task 10

  SELECT CountryName, DisributorName
  FROM(
		SELECT *,
			   DENSE_RANK() OVER (PARTITION BY CountryName ORDER BY IngredientCount DESC) AS [Rank]
		  FROM (
				    SELECT c.[Name] AS CountryName, 
				    	   d.[Name] AS DisributorName,
				    	   COUNT(i.[Name]) AS IngredientCount
				      FROM Countries AS c
				      LEFT JOIN Distributors AS d ON c.Id = d.CountryId
				      LEFT JOIN Ingredients AS i ON d.Id = i.DistributorId
				      GROUP BY c.[Name], d.[Name]
			    ) AS g
	   ) AS t
  WHERE [Rank] = 1
  ORDER BY CountryName, DisributorName

 -- Task 11

 GO

 CREATE VIEW v_UserWithCountries
 AS
 SELECT CONCAT(FirstName, ' ', LastName) AS CustomerName,
		c.Age,
		c.Gender,
		co.[Name] AS CountryName
 FROM Customers AS c
 JOIN Countries AS co ON c.CountryId = co.Id

 GO

 SELECT TOP 5 *
  FROM v_UserWithCountries
 ORDER BY Age


 -- Task 12

 GO

 CREATE TRIGGER tr_DeleteRelations
 ON Products
 INSTEAD OF DELETE
 AS
 BEGIN
 
DECLARE @deletedProductID INT = (SELECT p.Id
								   FROM Products AS P
								   JOIN deleted as d ON p.Id = d.Id)

DELETE FROM Feedbacks
WHERE ProductId = @deletedProductID

DELETE FROM ProductsIngredients
WHERE ProductId = @deletedProductID

DELETE FROM Products
WHERE Id = @deletedProductID

END
 GO