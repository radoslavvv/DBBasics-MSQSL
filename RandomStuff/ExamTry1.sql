CREATE TABLE Clients(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Gender NVARCHAR(1) NOT NULL,
	BirthDate DATETIME NOT NULL,
	CreditCard NVARCHAR(30) NOT NULL,
	CardValidity DATETIME NOT NULL,
	Email NVARCHAR(30) NOT NULL
)
GO

CREATE TABLE Towns(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL
)
GO

CREATE TABLE Offices(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(40) NOT NULL,
	ParkingPlaces INT NOT NULL,
	TownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL
)
GO

CREATE TABLE Models(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Manufacturer NVARCHAR(50) NOT NULL,
	Model NVARCHAR(50) NOT NULL,
	ProductionYear DATETIME NOT NULL,
	Seats INT NOT NULL,
	Class NVARCHAR(10) NOT NULL,
	Consumption DECIMAL(14,2) NOT NULL
)
GO

CREATE TABLE Vehicles(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	ModelId INT FOREIGN KEY REFERENCES Models(Id) NOT NULL,
	OfficeId INT FOREIGN KEY REFERENCES Offices(Id) NOT NULL,
	Mileage INT NOT NULL
)
GO

CREATE TABLE Orders(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	ClientId INT FOREIGN KEY REFERENCES Clients(Id) NOT NULL,
	TownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL,
	VehiclesId INT FOREIGN KEY REFERENCES Vehicles(Id) NOT NULL,
	CollectionDate DATETIME NOT NULL,
	CollectionOfficeId INT FOREIGN KEY REFERENCES Offices(Id) NOT NULL,
	ReturnDate DATETIME NOT NULL,
	ReturnOfficeId INT FOREIGN KEY REFERENCES Offices(Id) NOT NULL,
	Bill DECIMAL(14,2) NOT NULL,
	TotalMileage INT NOT NULL
)
GO