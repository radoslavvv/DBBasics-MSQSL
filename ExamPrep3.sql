--1
CREATE TABLE Clients(
	Id INT IDENTITY NOT NULL,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Gender CHAR(1),
	BirthDate DATETIME,
	CreditCard NVARCHAR(30) NOT NULL,
	CardValidity DATETIME,
	Email NVARCHAR(50) NOT NULL

	CONSTRAINT PK_Clients
	PRIMARY KEY (Id),

	CONSTRAINT CHK_Clients_Gender
	CHECK (Gender = 'M' OR Gender = 'F')
)

CREATE TABLE Towns(
	Id INT IDENTITY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL

	CONSTRAINT PK_Towns
	PRIMARY KEY (Id)
)

CREATE TABLE Offices(
	Id INT IDENTITY NOT NULL,
	[Name] NVARCHAR(40),
	ParkingPlaces INT,
	TownId INT NOT NULL,


	CONSTRAINT PK_Offices
	PRIMARY KEY (Id),

	CONSTRAINT FK_Offices_Towns
	FOREIGN KEY (TownId)
	REFERENCES Towns(Id)
)

CREATE TABLE Models(
	Id INT IDENTITY NOT NULL,
	Manufacturer NVARCHAR(50) NOT NULL,
	Model NVARCHAR(50) NOT NULL,
	ProductionYear DATETIME,
	Seats INT,
	Class NVARCHAR(10),
	Consumption DECIMAL(14,2)

	
	CONSTRAINT PK_Models
	PRIMARY KEY (Id)
)

CREATE TABLE Vehicles (
	Id INT IDENTITY NOT NULL,
	ModelId INT NOT NULL,
	OfficeId INT NOT NULL,
	Mileage INT ,

	CONSTRAINT PK_Vehicles
	PRIMARY KEY (Id),

	CONSTRAINT FK_Vehicles_Models
	FOREIGN KEY (ModelId)
	REFERENCES Models(Id),

	CONSTRAINT FK_Vehicles_Offices
	FOREIGN KEY (OfficeId)
	REFERENCES Offices(Id)
)

CREATE TABLE Orders(
	Id INT IDENTITY NOT NULL,
	ClientId INT NOT NULL,
	TownId INT NOT NULL,
	VehicleId INT NOT NULL,
	CollectionDate DATETIME NOT NULL,
	CollectionOfficeId INT,
	ReturnDate DATETIME,
	ReturnOfficeId INT,
	Bill DECIMAL(14,2),
	TotalMileage INT,

	CONSTRAINT PK_Orders
	PRIMARY KEY (Id),

	CONSTRAINT FK_Orders_Clients
	FOREIGN KEY (ClientId)
	REFERENCES Clients(Id),

	CONSTRAINT FK_Orders_Towns
	FOREIGN KEY (TownId)
	REFERENCES Towns(Id),

	CONSTRAINT FK_Orders_Vehicles
	FOREIGN KEY (VehicleId)
	REFERENCES Vehicles(Id),

	CONSTRAINT FK_Orders_Offices_Collection
	FOREIGN KEY (CollectionOfficeId)
	REFERENCES Offices(Id),

	CONSTRAINT FK_Orders_Offices_Return
	FOREIGN KEY (ReturnOfficeId)
	REFERENCES Offices(Id)
)


--2
INSERT INTO Models (Manufacturer, Model, ProductionYear, Seats, Class, Consumption)
VALUES
('Chevrolet',	'Astro',	'2005-07-27 00:00:00.000',	4,	'Economy',	12.60),
('Toyota',		'Solara',	'2009-10-15 00:00:00.000',	7,	'Family',	13.80),
('Volvo',		'S40',		'2010-10-12 00:00:00.000',	3,	'Average',	11.30),
('Suzuki',		'Swift',	'2000-02-03 00:00:00.000',	7,	'Economy',	16.20)

INSERT INTO Orders(ClientId, TownId, VehicleId, CollectionDate, CollectionOfficeId, ReturnDate, ReturnOfficeId, Bill, TotalMileage)
VALUES
(17,	2,	52,	'2017-08-08', 	30,	'2017-09-04', 	42,	2360.00,	7434),
(78,	17,	50,	'2017-04-22', 	10,	'2017-05-09', 	12,	2326.00,	7326),
(27,	13,	28,	'2017-04-25', 	21,	'2017-05-09', 	34,	597.00,		1880)


--3
UPDATE Models
SET Class = 'Luxury'
WHERE Consumption > 20

--4
DELETE Orders
WHERE ReturnDate IS NULL

--5
SELECT Manufacturer, Model
FROM Models
ORDER BY Manufacturer, Id DESC

--6
SELECT FirstName, LastName
FROM Clients
WHERE YEAR(BirthDate) BETWEEN 1977 AND 1994
ORDER BY FirstName, LastName, Id

--7
SELECT t.Name AS [TownName], 
		o.Name AS [OfficeName], 
		o.ParkingPlaces AS [ParkingPlaces]
FROM Offices AS o
JOIN Towns AS t
ON t.Id = o.TownId
WHERE ParkingPlaces > 25
ORDER BY t.Name, o.Id

--8
SELECT m.Model, m.Seats, v.Mileage
FROM Models AS m
JOIN Vehicles AS v
ON v.ModelId = m.Id
WHERE v.Id NOT IN (
	SELECT o.VehicleId
	FROM Orders AS o
	WHERE o.ReturnDate IS NULL
)
ORDER BY v.Mileage, m.Seats DESC, m.Id 


--9
SELECT t.Name, COUNT(o.Id) AS [OfficesNumber]
FROM Towns AS t
JOIN Offices AS o
ON o.TownId = t.Id
GROUP BY t.Name
ORDER BY [OfficesNumber] DESC, t.Name

--10
SELECT m.Manufacturer, m.Model, COUNT(o.ID) AS [TimesOrdered]
FROM Vehicles AS v
RIGHT JOIN Orders AS o
ON o.VehicleId = v.Id
RIGHT JOIN Models AS m
ON m.Id = v.ModelId
GROUP BY m.Manufacturer, m.Model
ORDER BY [TimesOrdered] DESC, m.Manufacturer DESC, m.Model


SELECT Manufacturer, Model, SUM(CountOfOrdersById) AS TimesOrdered
FROM(
	SELECT m.Manufacturer, m.Model, v.Id, COUNT(v.Id) AS CountOfOrdersById
	FROM Orders AS o
	LEFT JOIN Vehicles AS v
	ON v.Id = o.VehicleId
	RIGHT JOIN Models AS m
	ON m.Id = v.ModelId
	GROUP BY m.Manufacturer, m.Model, v.Id
	) AS H1
GROUP BY Manufacturer, Model
ORDER BY TimesOrdered DESC, Manufacturer DESC, Model

--11
SELECT Names, Class
FROM (
		SELECT CONCAT(c.FirstName, ' ', c.LastName) AS Names,
				m.Class AS Class,
				RANK() OVER (PARTITION BY (CONCAT(c.FirstName, ' ', c.LastName)) ORDER BY COUNT(m.Class) DESC) AS MostFrequentOrdered
		FROM Orders AS o
		JOIN Clients AS c
		ON c.Id = o.ClientId
		JOIN Vehicles AS v
		ON v.Id = o.VehicleId
		JOIN Models AS m
		ON m.Id = v.ModelId
		GROUP BY CONCAT(c.FirstName, ' ', c.LastName), m.Class
	 ) AS H
WHERE MostFrequentOrdered = 1
ORDER BY Names, Class

--12
SELECT AgeGroup = 
		(CASE
			WHEN YEAR(BirthDate) BETWEEN 1970 AND 1979 THEN '70''s'
			WHEN YEAR(BirthDate) BETWEEN 1980 AND 1989 THEN '80''s'
			WHEN YEAR(BirthDate) BETWEEN 1990 AND 1999 THEN '90''s'
			ELSE 'Others'
		 END),
		SUM(o.Bill) AS Revenue,
		AVG(o.TotalMileage) AS AverageMileage
FROM Clients AS c
	RIGHT JOIN Orders AS o
ON o.ClientId = c.Id
GROUP BY
	(CASE
		WHEN YEAR(BirthDate) BETWEEN 1970 AND 1979 THEN '70''s'
		WHEN YEAR(BirthDate) BETWEEN 1980 AND 1989 THEN '80''s'
		WHEN YEAR(BirthDate) BETWEEN 1990 AND 1999 THEN '90''s'
		ELSE 'Others'
	END)
ORDER BY 
	(CASE
		WHEN YEAR(BirthDate) BETWEEN 1970 AND 1979 THEN '70''s'
		WHEN YEAR(BirthDate) BETWEEN 1980 AND 1989 THEN '80''s'
		WHEN YEAR(BirthDate) BETWEEN 1990 AND 1999 THEN '90''s'
		ELSE 'Others'
	END)

--13
SELECT H.Manufacturer, H.AverageConsumption
FROM 
	(
		SELECT TOP(7) m.Manufacturer, 
				COUNT(o.CollectionDate) AS [Count], 
				AVG(m.Consumption) AS AverageConsumption
		FROM Orders AS o
		JOIN Vehicles AS v
		ON v.Id = o.VehicleId
		JOIN Models AS m
		ON m.Id = v.ModelId
		GROUP BY m.Manufacturer, m.Model
		ORDER BY [Count] DESC
	) AS H
WHERE AverageConsumption BETWEEN 5 AND 15
ORDER BY H.Manufacturer, H.AverageConsumption

--14
SELECT Names, Emails, Bills, TownsName
FROM (
		SELECT ROW_NUMBER() OVER (PARTITION BY t.Name ORDER BY o.Bill DESC) AS OrderByHighestBillDesc,
			CONCAT(c.FirstName, ' ', c.LastName) AS Names,
			c.Email AS Emails,
			o.Bill AS Bills,
			t.[Name] AS TownsName,
			c.Id AS ClientId
		FROM Orders AS o
		JOIN Clients AS c
		ON c.Id = o.ClientId
		JOIN Towns AS t
		ON t.Id = o.TownId
		WHERE c.CardValidity < o.CollectionDate AND o.Bill IS NOT NULL
	) AS H
WHERE OrderByHighestBillDesc IN (1, 2)
ORDER BY TownsName, Bills, ClientId


--15

SELECT t.Name AS [TownName],
	SUM((H.M) * 100) / (ISNULL(SUM(H.M), 0) + ISNULL(SUM(H.F), 0)) AS MalePercentage,
	SUM((H.F) * 100) / (ISNULL(SUM(H.M), 0) + ISNULL(SUM(H.F), 0))AS FemalePercentage
FROM
	(
	SELECT o.TownId,
		CASE WHEN Gender = 'M' THEN COUNT(o.Id) END AS M,
		CASE WHEN Gender = 'F' THEN COUNT(o.Id) END AS F
	FROM Orders AS o
	JOIN Clients AS c
	On c.Id = o.ClientId
	GROUP BY c.Gender, o.TownId
)AS H
JOIN Towns AS t
ON t.Id = h.TownId
GROUP BY t.Name

--16

WITH cte_Ranks (ReturnOfficeId, OfficeId, Id, Manufacturer, Model)
AS
(
	SELECT  RankedByDateDesc.ReturnOfficeId,
			RankedByDateDesc.OfficeId,
			RankedByDateDesc.Id,
			RankedByDateDesc.Model
	FROM
		(
			SELECT DENSE_RANK() OVER (PARTITION BY v.Id ORDER BY o.CollectionDate DESC) AS [LatestRentedCars],
					o.ReturnOfficeId,
					v.OfficeId,
					m.Manufacturer,
					m.Model,
					v.Id
			FROM Orders AS o
			RIGHT JOIN Vehicles AS v
			ON v.Id = o.VehicleId
			JOIN Models AS m
			ON m.Id = v.ModelId
		) AS RankedByDateDesc
	WHERE LatestRentedCars = 1
)

SELECT CONCAT(Manufacturer, ' - ', Model) AS Vehicle,
	Location = 
		CASE
			WHEN 
			(
				SELECT COUNT(*)
				FROM Orders AS o
				WHERE o.VehicleId = cte_Ranks.Id
			) = 0
			THEN 'home'

			WHEN 
			(
				cte_Ranks.ReturnOfficeId IS NULL
			)
			THEN 'on a rent'

			WHEN
			(
				cte_Ranks.OfficeId != cte_Ranks.ReturnOfficeId
			)
			THEN 
			(
				SELECT CONCAT(t.Name, ' - ', o.Name)
				FROM Towns AS t
				JOIN Offices AS o
				ON o.TownId = t.Id
				WHERE o.Id = cte_Ranks.ReturnOfficeId
			)
		END
FROM cte_Ranks
ORDER BY Vehicle, cte_Ranks.Id
GO




--17
CREATE FUNCTION udf_CheckForVehicle(@townName NVARCHAR(MAX), @seatsNumber INT)
RETURNS NVARCHAR(MAX)
AS
	BEGIN

		DECLARE @result VARCHAR(100) = (
			SELECT TOP(1) CONCAT(o.Name, ' - ', m.Model)
			FROM Offices AS o
			JOIN Towns AS t
			ON t.Id = o.TownId
			JOIN Vehicles AS v
			ON v.OfficeId = o.Id
			JOIN Models AS m
			ON m.Id = v.ModelId
			WHERE t.Name = @townName AND m.Seats = @seatsNumber
			ORDER BY o.Name
		)
		IF(@result IS NULL)
			BEGIN
				RETURN 'NO SUCH VEHICLE FOUND'
			END

		RETURN @result;
	END
	GO

--18
CREATE PROC usp_MoveVehicle(@vehicleId INT, @officeId INT)
AS
	BEGIN
		BEGIN TRANSACTION

			UPDATE Vehicles
			SET OfficeId = @officeId
			WHERE Id = @vehicleId

		DECLARE @vehiclesInOffice INT = 
		(
			SELECT COUNT(Id)
			FROM Vehicles
			WHERE OfficeId = @officeId
		)

		DECLARE @parkingSpace INT = 
		(
			SELECT ParkingPlaces
			FROM Offices
			WHERE Id = @officeId
		)

		IF (@vehiclesInOffice > @parkingSpace)
			BEGIN
				ROLLBACK;
				RAISERROR('Not enough room in this office!', 16,1);
				RETURN;
			END

		COMMIT
	END

EXEC usp_MoveVehicle 7, 32;
SELECT OfficeId FROM Vehicles WHERE Id = 7


EXEC usp_MoveVehicle 7, 32;
SELECT OfficeId FROM Vehicles WHERE Id = 7


--19
CREATE TRIGGER tr_MoveTheTally
ON Orders
AFTER UPDATE
AS
	BEGIN
		DECLARE @newValue INT =
		(
			SELECT TotalMileage FROM inserted
		)
		DECLARE @oldValue INT =
		(
			SELECT TotalMileage FROM deleted
		)

		DECLARE @vehicleId INT = 
		(
			SELECT VehicleId FROM inserted
		)

		IF(@oldValue IS NULL AND @vehicleId IS NOT NULL)
			BEGIN
				UPDATE Vehicles
				SET Mileage += @newValue
				WHERE Id = @vehicleId
			END
	END