--1
CREATE TABLE Users
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Username NVARCHAR(30) UNIQUE NOT NULL,
	[Password] NVARCHAR(50) NOT NULL,
	[Name] NVARCHAR(50),
	Gender CHAR(1) CHECK(Gender IN ('M', 'F')),
	BirthDate DATETIME,
	Age INT,
	Email NVARCHAR(50) NOT NULL
)

CREATE TABLE Departments
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Employees
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(25),
	LastName NVARCHAR(25),
	Gender CHAR(1) CHECK(Gender IN('M', 'F')),
	BirthDate DATETIME,
	Age INT,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL
)

CREATE TABLE Categories
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE Status
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Label NVARCHAR(30) NOT NULL
)

CREATE TABLE Reports
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	StatusId INT FOREIGN KEY REFERENCES Status(Id) NOT NULL,
	OpenDate DATETIME NOT NULL,
	CloseDate DATETIME,
	[Description] NVARCHAR(200),
	UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
)

--2
INSERT INTO Employees(FirstName, LastName, Gender, BirthDate, DepartmentId)
VALUES
('Marlo', 'O’Malley', 'M', '9/21/1958', 1),
('Niki', 'Stanaghan', 'F', '11/26/1969', 4),
('Ayrton', 'Senna', 'M', '03/21/1960 ', 9),
('Ronnie', 'Peterson', 'M', '02/14/1944', 9),
('Giovanna', 'Amati', 'F', '07/20/1959', 5)

INSERT INTO Reports(CategoryId, StatusId,OpenDate, CloseDate, [Description], UserId, EmployeeId)
VALUES
(1, 1, '04/13/2017', '', 'Stuck Road on Str.133', 6, 2),
(6, 3, '09/05/2015', '12/06/2015', 'Charity trail running', 3, 5),
(14, 2, '09/07/2015', '', 'Falling bricks on Str.58', 5, 2),
(4, 3, '07/03/2017', '07/06/2017', 'Cut off streetlight on Str.11', 1, 1)

--3
UPDATE Reports
SET StatusId = 2
WHERE StatusId = 1 AND CategoryId = 4

--4
DELETE FROM Reports
WHERE StatusId = 4
SELECT * FROM Status

--5
SELECT Username, Age
FROM Users
ORDER BY Age, Username DESC

--6
SELECT Description, OpenDate
FROM Reports
WHERE EmployeeId IS NULL
ORDER BY OpenDate, Description

--7
SELECT FirstName, LastName, Description, FORMAT(OpenDate, 'yyyy-MM-dd') AS OpenDate
FROM Employees AS e
JOIN Reports AS r
ON r.EmployeeId = e.Id
ORDER BY e.Id, r.OpenDate, r.Id

--8
SELECT c.Name, COUNT(*) AS ReportsNumber
FROM Reports As r
JOIN Categories AS c
ON c.Id = r.CategoryId
GROUP BY c.Name
ORDER BY COUNT(*) DESC,c.Name

--9
SELECT c.Name AS [CategoryName], COUNT(*) AS [Employees Number]
FROM Employees AS e
JOIN Categories AS c
ON c.DepartmentId = e.DepartmentId
GROUP BY c.Name
ORDER BY c.Name

--10
SELECT DISTINCT e.FirstName + ' ' + e.LastName AS [Name],
		COUNT(r.UserId) AS [Users Number]
FROM Employees AS e
LEFT JOIN Reports AS r
ON r.EmployeeId = e.Id
GROUP BY e.FirstName + ' ' + e.LastName
ORDER BY [Users Number] DESC, [Name] ASC

--11
SELECT r.OpenDate, r.Description, u.Email
  FROM Reports AS r
  JOIN Categories AS c
	ON c.Id = r.CategoryId
  JOIN Users AS u
	ON u.Id = r.UserId
 WHERE (CloseDate IS NULL) AND (LEN(Description) > 20 AND Description LIKE '%str%') AND (c.DepartmentId IN(1, 4, 5))
 ORDER BY r.OpenDate, u.Email, r.Id

 --12
 SELECT DISTINCT c.Name AS [Category Name]
 FROM Users AS u
 JOIN Reports AS r
 ON r.UserId = u.Id
 JOIN Categories AS c
 ON c.Id = r.CategoryId
 WHERE (MONTH(u.BirthDate) = MONTH(r.OpenDate)) AND (DAY(u.BirthDate) = DAY(r.OpenDate))
 ORDER BY [Category Name]

--13
SELECT DISTINCT u.Username
FROM Users AS u
JOIN Reports AS r
ON r.UserId = u.Id
WHERE (u.Username LIKE '[0-9]%' AND r.CategoryId LIKE SUBSTRING(u.Username, 1, 1)) OR
(u.Username LIKE '%[0-9]' AND r.CategoryId LIKE SUBSTRING(u.Username, LEN(u.Username), 1))
ORDER BY u.Username

--14

SELECT  e.FirstName + ' ' + e.LastName AS [Name],
		ISNULL(CONVERT(VARCHAR, CloseSum.Sum), 0) + '/' +
		ISNULL(CONVERT(VARCHAR, OpenSum.SUM), 0) AS [Closed Open Reports]
FROM Employees AS e
JOIN (	SELECT 
		EmployeeId,
		COUNT(*) AS [Sum]
		FROM Reports
		WHERE YEAR(OpenDate) = 2016
		GROUP BY EmployeeId
	) AS OpenSum
	ON e.Id = OpenSum.EmployeeId
	LEFT JOIN (SELECT
				EmployeeID,
				COUNT(*) AS [Sum]
				FROM Reports
				WHERE YEAR(CloseDate) = 2016
				GROUP BY EmployeeId
				) AS CloseSum
			ON e.Id = CloseSum.EmployeeId
	ORDER BY Name

--15
SELECT d.Name, ISNULL(CONVERT(VARCHAR, AVG(DATEDIFF(DAY, r.OpenDate, r.CloseDate))), 'no info') AS [Average Duration]
FROM Departments AS d
JOIN Categories AS c
ON c.DepartmentId = d.Id
JOIN Reports AS r
ON r.CategoryId = c.Id
GROUP BY d.Name
ORDER BY d.Name

--16

SELECT Department, Category, Percentage FROM
(
SELECT d.Name AS Department, c.Name AS Category,
CAST(
	ROUND(
		COUNT(*) OVER (PARTITION BY c.Id)
		 * 100.00 / 
		COUNT(*) OVER (PARTITION BY d.Id), 0) AS INT
		) AS Percentage
FROM Departments AS d
JOIN Categories AS c
ON c.DepartmentId = d.Id
JOIN Reports AS r
ON R.CategoryId = c.Id
)AS Stats
GROUP BY Department, Category, Percentage
ORDER BY Department, Category, Percentage


--17
CREATE FUNCTION udf_GetReportsCount(@employeeId INT, @statusId INT)
RETURNS INT
AS
	BEGIN
		DECLARE @count INT = 
		(
			 SELECT COUNT(*)
			 FROM Reports
			 WHERE StatusId = @statusId AND EmployeeId = @employeeId
		)

		RETURN @count;
	END

SELECT 
	Id,
	FirstName,
	LastName,
	dbo.udf_GetReportsCount(Id,2)
FROM Employees
ORDER BY Id

--18
CREATE PROC usp_AssignEmployeeToReport(@employeeId INT, @reportId INT)
AS
	BEGIN
		BEGIN TRANSACTION
		DECLARE @categoryId INT = 
		(
			SELECT CategoryId
			FROM Reports
			WHERE Id= @reportId
		)
		DECLARE @employeeDepId INT = 
		(
			SELECT DepartmentId
			FROM Employees
			WHERE Id = @employeeId
		)
		DECLARE @categoryDepId INT = 
		(
			SELECT DepartmentId
			FROM Categories
			WHERE Id = @categoryId
		)

	UPDATE Reports
	SET EmployeeId = @employeeId
	WHERE Id = @reportId

	IF(@employeeId IS NOT NULL AND @categoryDepId <> @employeeDepId)
		BEGIN 
			ROLLBACK;
			THROW 50013, 'Employee doesn''t belong to the appropriate department!', 1;
		END
	COMMIT
END

EXEC usp_AssignEmployeeToReport 17,2
SELECT EmployeeID FROM Reports WHERE Id = 2

--19
CREATE TRIGGER t_CloseReport
ON Reports
AFTER UPDATE
AS
	BEGIN
		DECLARE @statusId INT = 
		(
			SELECT Id
			FROM Status
			WHERE Label = 'completed'
		)
	UPDATE Reports
	SET StatusId = @statusId
	WHERE Id IN (
		SELECT Id
		FROM inserted
		WHERE Id IN(
			SELECT Id
			FROM deleted
			WHERE CloseDate IS NULL)
				AND Reports.CloseDate IS NOT NULL

				)

				END
--20
SELECT
  c.Name   AS [Category Name],
  count(1) AS [Reports Number],
  CASE
  WHEN InProgressCount > WaitingCount
    THEN 'in progress'
  WHEN InProgressCount < WaitingCount
    THEN 'waiting'
  ELSE 'equal'
  END      AS [MainStatus]
FROM Categories AS c
  JOIN Reports AS r
    ON c.Id = r.CategoryId
  JOIN Status AS s
    ON r.StatusId = s.Id
  JOIN (SELECT
          r.CategoryId,
          sum(CASE WHEN s.Label = 'in progress'
            THEN 1
              ELSE 0
              END) AS InProgressCount,
          sum(CASE WHEN s.Label = 'waiting'
            THEN 1
              ELSE 0
              END) AS WaitingCount
        FROM Reports AS r
          JOIN Status AS s
            ON r.StatusId = s.Id
        WHERE Label IN ('waiting', 'in progress')
        GROUP BY r.CategoryId
       ) AS sc
    ON sc.CategoryId = c.Id
WHERE r.StatusId IN (
  SELECT Status.Id
  FROM Status
  WHERE Label IN ('waiting', 'in progress')
)
GROUP BY c.Name,
  CASE
  WHEN InProgressCount > WaitingCount
    THEN 'in progress'
  WHEN InProgressCount < WaitingCount
    THEN 'waiting'
  ELSE 'equal'
  END
ORDER BY [Category Name], [Reports Number], [MainStatus]