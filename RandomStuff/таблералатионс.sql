--1
CREATE TABLE Persons(
	PersonID INT PRIMARY KEY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	Salary DECIMAL NOT NULL,
	PassportID INT UNIQUE NOT NULL,
)

CREATE TABLE Passports(
	PassportID INT PRIMARY KEY NOT NULL,
	PassportNumber NVARCHAR(50) NOT NULL,
)

ALTER TABLE Persons
ADD CONSTRAINT FK_Persons_Passports FOREIGN KEY (PassportID)
REFERENCES Passports(PassportID)

INSERT INTO Passports
VALUES
(101, 'N34FG21B'),
(102, 'K65LO4R7'),
(103, 'ZE657QP2')

INSERT INTO Persons
VALUES
(1, 'Roberto', 43300, 102),
(2, 'Tom', 56100, 103),
(3, 'Yana',60200,101)



--2
CREATE TABLE Manufacturers(
	ManufacturerID INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	EstablishedOn DATETIME NOT NULL,

	CONSTRAINT PK_Manufacturers
	PRIMARY KEY (ManufacturerID)
)

CREATE TABLE Models(
	ModelID INT NOT NULL,
	[Name] NVARCHAR(50),
	ManufacturerID INT NOT NULL,

	CONSTRAINT PK_Models
	PRIMARY KEY (ModelID),

	CONSTRAINT FK_Models_Manufacturers
	FOREIGN KEY (ManufacturerID)
	REFERENCES Manufacturers(ManufacturerID)
)

INSERT INTO Manufacturers
VALUES 
(1, 'BMW', '07/03/1916'),
(2, 'Tesla', '01/01/2003'),
(3, 'Lada', '01/05/1966')

INSERT INTO Models
VALUES 
(101, 'X1', 1),
(102, 'i6', 1),
(103, 'Model S', 2),
(104, 'Model X', 2),
(105, 'Model 3', 2),
(106, 'Nova', 3)


--3
CREATE TABLE Students(
	StudentID INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,

	CONSTRAINT PK_Students
	PRIMARY KEY (StudentID)
)

CREATE TABLE Exams(
	ExamID INT NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,

	CONSTRAINT PK_Exams
	PRIMARY KEY (ExamID)
)

CREATE TABLE StudentsExams(
	StudentID INT NOT NULL,
	ExamID INT NOT NULL,

	CONSTRAINT FK_StudentsExams_Students
	FOREIGN KEY (StudentID)
	REFERENCES Students(StudentID),

	CONSTRAINT FK_StudentsExams_Exams
	FOREIGN KEY (ExamID)
	REFERENCES Exams(ExamID),
	
	CONSTRAINT PK_StudentsExams
	PRIMARY KEY (StudentID, ExamID)
)

INSERT INTO Students
VALUES
(1, 'Mila'),
(2, 'Toni'),
(3, 'Ron')

INSERT INTO Exams
VALUES
(101, 'SpringMVC'),
(102, 'Neo4j'),
(103, 'Oracle 11g')

INSERT INTO StudentsExams
VALUES 
(1, 101),
(1, 102),
(2, 101),
(3, 103),
(2, 102),
(2, 103)
 