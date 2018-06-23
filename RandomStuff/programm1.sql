--1
CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000
AS
BEGIN
	SELECT FirstName, LastName
	FROM Employees
	WHERE Salary > 35000
END

EXEC usp_GetEmployeesSalaryAbove35000

--2
CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber(@number DECIMAL(18,4))
AS
BEGIN
	SELECT FirstName, LastName
	FROM Employees
	WHERE Salary >= @number
END

EXEC usp_GetEmployeesSalaryAboveNumber 5000

--3
CREATE OR ALTER PROC usp_GetTownsStartingWith(@string NVARCHAR(200))
AS
BEGIN
	SELECT [Name]
	FROM Towns
	WHERE [Name] LIKE @string  + '%'
END
 
 EXEC usp_GetTownsStartingWith 'B'

 --4
 CREATE PROC usp_GetEmployeesFromTown(@townName NVARCHAR(50))
 AS
 BEGIN
	DECLARE @townID NVARCHAR(50) = 
	(
		SELECT TownID 
		FROM Towns
		WHERE [Name] = @townName
	)

	SELECT FirstName, LastName
	FROM Employees AS e
	JOIN Addresses AS a
	ON a.AddressID = e.AddressID
	WHERE a.TownID = @townID
END

EXEC usp_GetEmployeesFromTown 'Sofia'
--5
CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS NVARCHAR(50)
AS
BEGIN 
	DECLARE @salaryLevel NVARCHAR(50);
	IF(@salary < 30000) 
		BEGIN
			SET @salaryLevel = 'Low';
		END
	ELSE IF(@salary >= 30000 AND @salary <=50000) 
		BEGIN
			SET @salaryLevel= 'Average';
		END
	ELSE
		BEGIN
			SET @salaryLevel= 'High';
		END
	RETURN @salaryLevel;
END

--6
CREATE PROC usp_EmployeesBySalaryLevel(@levelOfSalary NVARCHAR(50))
AS
BEGIN 
	SELECT  FirstName AS [First Name], 
			LastName AS [Last Name]
	FROM Employees
	WHERE dbo.ufn_GetSalaryLevel(Salary) = @levelOfSalary
END

exec usp_EmployeesBySalaryLevel 'High'

--7
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters NVARCHAR(50), @word NVARCHAR(50))
RETURNS BIT
BEGIN
	DECLARE @index INT = 1;
	DECLARE @char CHAR(1);

	WHILE(@index <= LEN(@word))
	BEGIN
		SET @char = SUBSTRING(@word, @index, 1);

		IF(CHARINDEX(@char, @setOfLetters) = 0)
			BEGIN
				RETURN 0;
				BREAK;
			END
		ELSE
			BEGIN 
				SET @index = @index + 1;
				SET @char = SUBSTRING(@word, @index, 1);
			END
	END
		RETURN 1;
END

PRINT dbo.ufn_IsWordComprised('oistmiahf', 'Sofia')
--8
CREATE PROC usp_DeleteEmployeesFromDepartment(@departmentId INT)
AS
  ALTER TABLE Departments
    ALTER COLUMN ManagerID INT NULL

  DELETE FROM EmployeesProjects
  WHERE EmployeeID IN
        (
          SELECT EmployeeID
          FROM Employees
          WHERE DepartmentID = @departmentId
        )

  UPDATE Employees
  SET ManagerID = NULL
  WHERE ManagerID IN
        (
          SELECT EmployeeID
          FROM Employees
          WHERE DepartmentID = @departmentId
        )

  UPDATE Departments
  SET ManagerID = NULL
  WHERE ManagerID IN
        (
          SELECT EmployeeID
          FROM Employees
          WHERE DepartmentID = @departmentId
        )

  DELETE FROM Employees
  WHERE EmployeeID IN
        (
          SELECT EmployeeID
          FROM Employees
          WHERE DepartmentID = @departmentId
        )

  DELETE FROM Departments
  WHERE DepartmentID = @departmentId

  SELECT COUNT(*) AS [Employees Count]
  FROM Employees AS E
    JOIN Departments AS D
      ON D.DepartmentID = E.DepartmentID
  WHERE E.DepartmentID = @departmentId
--9
CREATE PROC usp_GetHoldersFullName
AS
BEGIN 
	SELECT FirstName + ' ' + LastName AS [Full Name]
	FROM AccountHolders
END

EXEC usp_GetHoldersFullName

--10
CREATE PROC usp_GetHoldersWithBalanceHigherThan(@number DECIMAL(16,2))
AS 
BEGIN
	WITH CTE_AccountHolderBalance (AccountHolderId, Balance) AS (
		SELECT AccountHolderId, SUM(Balance) AS TotalBalance
		FROM Accounts
		GROUP BY AccountHolderId)
	
	SELECT FirstName, LastName
	FROM AccountHolders AS ah
	JOIN CTE_AccountHolderBalance AS cab
	ON cab.AccountHolderId = ah.Id
	WHERE cab.Balance > @number
	ORDER BY ah.LastName, ah.FirstName
END

EXEC usp_GetHoldersWithBalanceHigherThan 15000

--11
CREATE OR ALTER FUNCTION ufn_CalculateFutureValue(@sum DECIMAL(15,2), @yearlyInterestRate FLOAT, @yearsCount INT)
RETURNS DECIMAL(15,4)
AS
BEGIN 
	RETURN @sum * (POWER((1 + @yearlyInterestRate), @yearsCount));
END

PRINT dbo.ufn_CalculateFutureValue(1000, 0.1, 5)

--12
CREATE OR ALTER PROC usp_CalculateFutureValueForAccount(@accountId INT, @interestRate FLOAT)
AS
BEGIN
	SELECT TOP(1) AccountHolderId, FirstName, LastName, Balance, dbo.ufn_CalculateFutureValue(Balance,@interestRate, 5)
	FROM Accounts AS a
	JOIN AccountHolders AS ah
	ON ah.Id = a.AccountHolderId
	WHERE AccountHolderId = @accountId
END

exec usp_CalculateFutureValueForAccount 1 ,0.1

--13
CREATE FUNCTION ufn_CashInUsersGames (@gameName NVARCHAR(50))
RETURNS TABLE
AS 
RETURN(
	SELECT SUM(e.Cash) AS SumCash 
	FROM(
		SELECT g.Id, 
			ug.Cash, 
			ROW_NUMBER() OVER(ORDER BY ug.Cash DESC) AS RowNumber
		FROM Games AS g
		JOIN UsersGames AS ug
		ON ug.GameId = g.Id
		WHERE g.Name = @gameName
	) AS e
	WHERE e.RowNumber % 2 =1
)

--14
CREATE TABLE Logs(
	LogId INT IDENTITY NOT NULL,
	AccountId INT,
	OldSum DECIMAL(15,2),
	NewSum DECIMAL(15,2)
)

CREATE TRIGGER tr_Accounts
ON Accounts
AFTER UPDATE
AS
BEGIN
	DECLARE @accountId INT =
	(
		SELECT Id 
		FROM inserted
	)

	DECLARE @oldSum DECIMAL(15,2) = 
	(
		SELECT Balance
		FROM deleted
	)

	DECLARE @newSum DECIMAL(15,2) = 
	(
		SELECT Balance 
		FROM inserted
	)

	INSERT INTO Logs
	VALUES
	(@accountId, @oldSum, @newSum)
END

--15
CREATE TRIGGER CreteNewNotificationEmail
ON Logs
AFTER INSERT
AS
	BEGIN
		DECLARE @accId INT = (SELECT AccountId FROM inserted)
		DECLARE @date DATETIME = (SELECT GETDATE() FROM inserted)
		DECLARE @oldSum DECIMAL(15,2) = (SELECT OldSum FROM inserted)
		DECLARE @newSum DECIMAL(15,2) = (SELECT NewSum FROM inserted)

		INSERT INTO NotificationEmails
		VALUES
		(
			(@accId),
			CONCAT('Balance change for account: ',(@accId)),
			CONCAT('On ', (@date), ' your balance was changed from ', (@oldSum),' to ', (@newSum), '.')
		)
	END

--16
CREATE PROC usp_DepositMoney(@accountId INT, @moneyAmount MONEY)
AS
	BEGIN TRANSACTION

		UPDATE Accounts
		SET Balance += @moneyAmount
		WHERE Id = @accountId

		IF(@@ROWCOUNT <> 1)
			BEGIN
				RAISERROR('Inalid account',16,1);
				ROLLBACK;
				RETURN;
			END
	COMMIT

--17
CREATE PROC usp_WithdrawMoney(@accountId INT, @moneyAmount MONEY)
AS
	BEGIN TRANSACTION
		UPDATE Accounts
		SET Balance -= @moneyAmount
		WHERE Id = @accountId
	COMMIT

--18
CREATE PROC usp_TransferMoney(@senderId INT, @recieverId INT, @amount DECIMAL(15,4))
AS
	BEGIN
		BEGIN TRANSACTION
			EXEC dbo.usp_WithdrawMoney @senderId, @amount
			EXEC dbo.usp_DepositMoney @recieverId, @amount

			DECLARE @senderBalance DECIMAL(15,4) = 
			(
				SELECT Balance 
				FROM Accounts
				WHERE Id = @senderId
			)
	
			IF(@senderBalance < 0)
				BEGIN
					ROLLBACK
				END
			ELSE
				BEGIN
					COMMIT
				END
	END
--20
DECLARE @gameName NVARCHAR(50) = 'Safflower'
DECLARE @username NVARCHAR(50) = 'Stamat'

DECLARE @userGameId INT = (
  SELECT ug.Id
  FROM UsersGames AS ug
    JOIN Users AS u
      ON ug.UserId = u.Id
    JOIN Games AS g
      ON ug.GameId = g.Id
  WHERE u.Username = @username AND g.Name = @gameName)

DECLARE @userGameLevel INT = (SELECT Level
                              FROM UsersGames
                              WHERE Id = @userGameId)
DECLARE @itemsCost MONEY, @availableCash MONEY, @minLevel INT, @maxLevel INT

SET @minLevel = 11
SET @maxLevel = 12
SET @availableCash = (SELECT Cash
                      FROM UsersGames
                      WHERE Id = @userGameId)
SET @itemsCost = (SELECT SUM(Price)
                  FROM Items
                  WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

IF (@availableCash >= @itemsCost AND @userGameLevel >= @maxLevel)

  BEGIN
    BEGIN TRANSACTION
    UPDATE UsersGames
    SET Cash -= @itemsCost
    WHERE Id = @userGameId
    IF (@@ROWCOUNT <> 1)
      BEGIN
        ROLLBACK
        RAISERROR ('Could not make payment', 16, 1)
      END
    ELSE
      BEGIN
        INSERT INTO UserGameItems (ItemId, UserGameId)
          (SELECT
             Id,
             @userGameId
           FROM Items
           WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

        IF ((SELECT COUNT(*)
             FROM Items
             WHERE MinLevel BETWEEN @minLevel AND @maxLevel) <> @@ROWCOUNT)
          BEGIN
            ROLLBACK;
            RAISERROR ('Could not buy items', 16, 1)
          END
        ELSE COMMIT;
      END
  END

SET @minLevel = 19
SET @maxLevel = 21
SET @availableCash = (SELECT Cash
                      FROM UsersGames
                      WHERE Id = @userGameId)
SET @itemsCost = (SELECT SUM(Price)
                  FROM Items
                  WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

IF (@availableCash >= @itemsCost AND @userGameLevel >= @maxLevel)

  BEGIN
    BEGIN TRANSACTION
    UPDATE UsersGames
    SET Cash -= @itemsCost
    WHERE Id = @userGameId

    IF (@@ROWCOUNT <> 1)
      BEGIN
        ROLLBACK
        RAISERROR ('Could not make payment', 16, 1)
      END
    ELSE
      BEGIN
        INSERT INTO UserGameItems (ItemId, UserGameId)
          (SELECT
             Id,
             @userGameId
           FROM Items
           WHERE MinLevel BETWEEN @minLevel AND @maxLevel)

        IF ((SELECT COUNT(*)
             FROM Items
             WHERE MinLevel BETWEEN @minLevel AND @maxLevel) <> @@ROWCOUNT)
          BEGIN
            ROLLBACK
            RAISERROR ('Could not buy items', 16, 1)
          END
        ELSE COMMIT;
      END
  END

SELECT i.Name AS [Item Name]
FROM UserGameItems AS ugi
  JOIN Items AS i
    ON i.Id = ugi.ItemId
  JOIN UsersGames AS ug
    ON ug.Id = ugi.UserGameId
  JOIN Games AS g
    ON g.Id = ug.GameId
WHERE g.Name = @gameName
ORDER BY [Item Name]
--21
CREATE PROC usp_AssignProject(@employeeId INT, @projectId INT)
AS
	BEGIN
		BEGIN TRANSACTION
			INSERT INTO EmployeesProjects
			VALUES
			(@employeeId, @projectId)

			DECLARE @projectsCount INT = 
			(
				SELECT COUNT(ProjectID) 
				FROM EmployeesProjects 
				WHERE EmployeeID = @employeeId
			)
			IF(@projectsCount >3)
				BEGIN
					RAISERROR ('The employee has too many projects!', 16, 1)
					ROLLBACK
					RETURN
				END
			COMMIT
		END

--22
CREATE TABLE Deleted_Employees
(
  EmployeeId INT PRIMARY KEY IDENTITY,
  FirstName VARCHAR(50) NOT NULL,
  LastName VARCHAR(50) NOT NULL,
  MiddleName VARCHAR(50),
  JobTitle VARCHAR(50),
  DepartmentId INT,
  Salary DECIMAL(15, 2)
)

CREATE TRIGGER tr_DeleteEmployees
	ON Employees
	AFTER DELETE
AS
	BEGIN
		INSERT INTO Deleted_Employees
			SELECT
				FirstName,
				LastName,
				MiddleName,
				JobTitle,
				DepartmentID,
				Salary
			FROM deleted
	END