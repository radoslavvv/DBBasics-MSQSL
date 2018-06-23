CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	CategoryName NVARCHAR(50) NOT NULL,
	DailyRate FLOAT NOT NULL,
	WeeklyRate FLOAT NOT NULL,
	MonthlyRate FLOAT NOT NULL,
	WeekendRate FLOAT NOT NULL,
)

CREATE TABLE Cars (
	Id INT PRIMARY KEY IDENTITY,
	PlateNumber NVARCHAR(50) NOT NULL,
	Manufacturer NVARCHAR(50) NOT NULL,
	Model NVARCHAR(50) NOT NULL,
	CarYear INT NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
	Doors INT NOT NULL,
	Picture NVARCHAR(MAX) NOT NULL,
	Condition Nvarchar(50) NOT NULL,
	Available BIT NOT NULL
)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX) 
)

CREATE TABLE Customers(
	Id INT PRIMARY KEY IDENTITY,
	DriverLicenceNumber NVARCHAR(50) NOT NULL,
	FullName NVARCHAR(50) NOT NULL,
	[Address] NVARCHAR(50) NOT NULL,
	City NVARCHAR(50) NOT NULL,
	ZIPCOde INT NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE RentalOrders(
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
	CustomerId INT FOREIGN KEY REFERENCES Customers(Id),
	CarId INT FOREIGN KEY REFERENCES Cars(Id),
	TankLevel INT NOT NULL,
	KilometrageStart INT NOT NULL,
	KilometrageEnd INT NOT NULL,
	TotalKilometrage INT NOT NULL,
	StartDate DATETIME NOT NULL,
	EndDate DATETIME NOT NULL,
	TotalDays INT NOT NULL,
	RateApplied FLOAT NOT NULL,
	TaxRate FLOAT NOT NULL,
	OrderStatus NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX),
)

INSERT INTO Categories (CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate)
VALUES  ('Category1', 1,1,1,1),
		('Category2', 1,1,1,1),
		('Category3', 1,1,1,1)

INSERT INTO Cars (PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Picture, Condition, Available)
VALUES  ('Plate1', 'Man1', 'Model1', 1999, 1, 4, 445, 'New', 1),
		('Plate2', 'Man2', 'Model2', 1999, 1, 4, 445, 'New', 1),
		('Plate3', 'Man3', 'Model3', 1999, 1, 4, 445, 'New', 1)

INSERT INTO Employees (FirstName, LastName, Title, Notes)
VALUES  ('FirstName1', 'LastName1', 'Title1','Notes1'),
		('FirstName2', 'LastName2', 'Title2','Notes2'),
		('FirstName3', 'LastName3', 'Title3','Notes3')

INSERT INTO Customers (DriverLicenceNumber, FullName, [Address], City, ZIPCOde, Notes)
VALUES  ('DrLi1', 'FullName1', 'Address1', 'City1', 1, 'Notes1'),
		('DrLi2', 'FullName2', 'Address2', 'City2', 1, 'Notes2'),
		('DrLi3', 'FullName3', 'Address3', 'City3', 1, 'Notes3')

INSERT INTO RentalOrders (EmployeeId, CustomerId, CarId, TankLevel, KilometrageStart, KilometrageEnd, TotalKilometrage, StartDate, EndDate, TotalDays, RateApplied, TaxRate, OrderStatus, Notes)
VALUES  (1,1,1,1,1,1,1,1/1/2016, 1/6/2016, 100,1,1 ,'Processing', 'Notes1' ),
		(1,1,1,1,1,1,1,1/1/2016, 1/6/2016, 100,1,1 ,'Processing', 'Notes2' ),
		(1,1,1,1,1,1,1,1/1/2016, 1/6/2016, 100,1,1 ,'Processing', 'Notes3' )
