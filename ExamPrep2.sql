CREATE TABLE Clients(
	ClientId INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Phone NVARCHAR(12) NOT NULL,
	CHECK (LEN(Phone) = 12)
)

CREATE TABLE Mechanics(
	MechanicId INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Address NVARCHAR(255) NOT NULL
)
CREATE TABLE Models(
	ModelId INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Jobs(
	JobId INT PRIMARY KEY IDENTITY NOT NULL,
	ModelId INT FOREIGN KEY REFERENCES Models(ModelId) NOT NULL,
	[Status] NVARCHAR(11) DEFAULT 'Pending' NOT NULL, 
	CHECK ([Status] IN ('Pending', 'In Progress', 'Finished')),
	ClientId INT FOREIGN KEY REFERENCES Clients(ClientId) NOT NULL,
	MechanicId INT FOREIGN KEY REFERENCES Mechanics(MechanicId),
	IssueDate DATE NOT NULL,
	FinishDate DATE
)

CREATE TABLE Orders(
	OrderId INT PRIMARY KEY IDENTITY NOT NULL,
	JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
	IssueDate DATE,
	Delivered BIT DEFAULT 0 NOT NULL
)
CREATE TABLE Vendors(
	VendorId INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Parts(
	PartId INT PRIMARY KEY IDENTITY NOT NULL,
	SerialNumber NVARCHAR(50) UNIQUE NOT NULL,
	[Description] NVARCHAR(255),
	Price DECIMAL(15,2) NOT NULL,
	CHECK (Price > 0),
	VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId) NOT NULL,
	StockQty INT DEFAULT 0 NOT NULL,
	CHECK (StockQty >= 0)
)

CREATE TABLE OrderParts(
	OrderId INT FOREIGN KEY REFERENCES Orders(OrderId) NOT NULL,
	PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
	Quantity INT DEFAULT 1 NOT NULL,
	CHECK (Quantity > 0),
	CONSTRAINT PK_OrderParts PRIMARY KEY(OrderId,PartId)
)

CREATE TABLE PartsNeeded(
	JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
	PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
	Quantity INT DEFAULT 1 NOT NULL,
	CHECK (Quantity > 0),
	CONSTRAINT PK_PartsNeeded PRIMARY KEY (JobId,PartId)
)


INSERT INTO Clients (FirstName, LastName, Phone)
VALUES
('Teri', 'Ennaco', '570-889-5187'),
('Merlyn', 'Lawler', '201-588-7810'),
('Georgene', 'Montezuma', '925-615-5185'),
('Jettie', 'Mconnell', '908-802-3564'),
('Lemuel', 'Latzke', '631-748-6479'),
('Melodie', 'Knipp', '805-690-1682'),
('Candida', 'Corbley', '908-275-8357')

INSERT INTO Parts (SerialNumber, Description, Price, VendorId)
VALUES 
('WP8182119', 'Door Boot Seal', 117.86, 2),
('W10780048', 'Suspension Rod', 42.81, 1),
('W10841140', 'Silicone Adhesive ', 6.77, 4),
('WPY055980', 'High Temperature Adhesive', 13.94, 3)

--3
UPDATE Jobs
SET Status = 'In Progress', MechanicId = 3
WHERE Status = 'Pending' 

--4
DELETE FROM OrderParts
WHERE OrderId =19

DELETE FROM Orders
WHERE OrderId =19

--5
SELECT FirstName, LastName, Phone
FROM Clients
ORDER BY LastName, ClientId

--6
SELECT [Status], IssueDate
FROM Jobs
WHERE [Status] != 'Finished'
ORDER BY IssueDate, JobId

--7
SELECT m.FirstName + ' ' + m.LastName AS [Mechanic],
		[Status],
		IssueDate 
FROM Jobs AS j
JOIN Mechanics AS m
ON m.MechanicId = j.MechanicId
ORDER BY m.MechanicId, IssueDate, JobId

--8
SELECT  c.FirstName + ' ' + c.LastName AS [Client],
		DATEDIFF(DAY, j.IssueDate, '04.24.2017') AS [Days going],
		[Status]
FROM Jobs AS j
JOIN Clients AS c
ON c.ClientId = j.ClientId
WHERE j.Status != 'Finished'
ORDER BY [Days going] DESC, c.ClientId ASC

--9
SELECT m.FirstName + ' ' + m.LastName AS [Mechanic],
		AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) AS [Average Days]
FROM Mechanics AS m
JOIN Jobs as j
On j.MechanicId = m.MechanicId
GROUP BY m.FirstName + ' ' + m.LastName, m.MechanicId

--10
SELECT TOP(3) m.FirstName + ' ' + m.LastName AS [Mechanic],
		COUNT(j.JobId) AS [Jobs]
FROM Mechanics AS m
JOIN JOBS AS j
ON j.MechanicId = m.MechanicId
WHERE j.Status != 'Finished'
GROUP BY m.FirstName + ' ' + m.LastName, m.MechanicId
HAVING COUNT(j.JobId) > 1
ORDER BY Jobs DESC, m.MechanicId ASC

--11
SELECT FirstName + ' ' + LastName AS [Availabe]
	FROM Mechanics AS m
	WHERE MechanicId NOT IN 
	(
		SELECT MechanicId
		FROM Jobs 
		WHERE Status != 'Finished' AND MechanicId IS NOT NULL
	)
	ORDER BY m.MechanicId

--12
SELECT ISNULL(SUM(p.Price * op.Quantity),0) AS [Parts Total]
 FROM Orders AS o
 JOIN OrderParts AS op
 ON op.OrderId = o.OrderId
 JOIN Parts AS p
 ON p.PartId = op.PartId
 WHERE DATEDIFF(WEEK, o.IssueDate, '04.24.2017') <= 3


 SELECT ISNULL(SUM(p.Price * op.Quantity), 0) AS [Parts Total]
 FROM Orders AS o
 JOIN OrderParts AS op
 ON op.OrderId = o.OrderId
 JOIN Parts AS p
 ON p.PartId = op.PartId
 WHERE o.IssueDate < '04.24.2017' AND o.IssueDate >= DATEADD(WEEK, -3, '04.24.2017') 

 --13
 SELECT j.JobId, ISNULL(SUM(p.Price * op.Quantity),0) AS [Total]
 FROM OrderParts AS op
 RIGHT JOIN Orders AS o
 ON o.OrderId = op.OrderId
 RIGHT JOIN Parts AS p
 ON p.PartId = op.PartId
 RIGHT JOIN Jobs AS j
 ON j.JobId = o.JobId
 WHERE j.Status = 'Finished'
 GROUP BY j.JobId
 ORDER BY Total DESC, j.JobId

 --14
 SELECT m.ModelId, m.Name, CONCAT(AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) ,' days') AS [Average Service Time]
 FROM Models AS m
 RIGHT JOIN Jobs AS j
 ON j.ModelId = m.ModelId
 GROUP BY m.ModelId, m.Name
 ORDER BY AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate))
 
 --15
 SELECT TOP (1) WITH TIES
				m.Name, 
				COUNT(j.JobId) AS [Times Serviced],
				(
					SELECT ISNULL(SUM(p.Price * op.Quantity), 0)
					FROM Parts AS p
					JOIN OrderParts as op
					ON op.PartId = p.PartId
					JOIN Orders AS o
					ON o.OrderId = op.OrderId
					JOIN Jobs AS j
					ON j.JobId = o.JobId
					WHERE j.ModelId = m.ModelId
				)
FROM Models AS m
 JOIN Jobs AS j
 ON j.ModelId = m.ModelId
 GROUP BY m.Name, m.ModelId
 ORDER BY [Times Serviced] DESC


 --16
 SELECT p.PartId, 
		p.[Description],
		SUM(pn.Quantity) AS [Required],
		SUM(p.StockQty) AS [In Stock],
		ISNULL(SUM(op.Quantity),0)  AS [Ordered]
	 FROM Parts AS p
	  JOIN PartsNeeded AS pn
		ON pn.PartId = p.PartId
	  JOIN Jobs AS j
		ON j.JobId = pn.JobId
	LEFT JOIN Orders AS o
		ON o.JobId = j.JobId
	LEFT JOIN OrderParts AS op
		On op.OrderId = o.OrderId
	WHERE j.Status <> 'Finished'
 GROUP BY p.PartId, p.[Description]
	HAVING SUM(pn.Quantity) > SUM(p.StockQty) + ISNULL(SUM(op.Quantity),0)
	ORDER BY p.PartId
 
 --17
 CREATE FUNCTION udf_GetCost(@jobId INT)
 RETURNS DECIMAL(15,2)
 AS
	BEGIN
		DECLARE @result DECIMAL(15,2) = 
		(
				(SELECT 
				 	ISNULL(SUM(p.Price * op.Quantity), 0)
				 FROM Orders AS o
				  JOIN OrderParts AS op
				 	ON op.OrderId = o.OrderId
				  JOIN Parts AS p
				 	ON p.PartId = op.PartId
				 	WHERE o.JobId = @jobId
				 	GROUP BY o.JobId
				)
		)

		IF @result IS NULL 
		BEGIN 
			RETURN 0;
		END
		RETURN @result;
	END

			
--18
CREATE PROC usp_PlaceOrder(@jobId INT, @partSerialNumber NVARCHAR(50), @quantity INT)
AS
	BEGIN
		DECLARE @partId INT = 
		(
			SELECT PartId
			FROM Parts
			WHERE SerialNumber = @partSerialNumber
		)

		DECLARE @orderId INT =
		(
			SELECT TOP 1 OrderId
			FROM Orders 
			WHERE JobId = @jobId AND IssueDate IS NULL
		)


		IF((SELECT JobId FROM Jobs WHERE  JobId = @jobId AND Status = 'Finished') IS NOT NULL )
			BEGIN
				;THROW 50011, 'This job is not active!', 1
			END

		IF(@quantity <=0)
			BEGIN
				;THROW 50012, 'Part quantity must be more than zero!', 1;
			END

		IF((SELECT JobId FROM Jobs WHERE JobId = @jobId) IS NULL)
			BEGIN
				;THROW 50013, 'Job not found!', 1
			END

		IF(@partId IS NULL)
			BEGIN
				;THROW 50014, 'Part not found!', 1
			END

			IF(@orderId IS NULL)
				BEGIN
					INSERT INTO Orders(JobId, IssueDate)
					VALUES
					(@jobId, NULL)

					DECLARE @id INT = 
					(
						SELECT TOP 1 OrderId
						FROM Orders
						WHERE JobId = @jobId
					)
					INSERT INTO OrderParts(OrderId, PartId,Quantity)
					VALUES
					(@id, @partId, @quantity)
				END
			ELSE
				BEGIN
					IF((SELECT PartId FROM OrderParts WHERE OrderId = @orderId AND PartId = @partId) IS NOT NULL)
						BEGIN 
							UPDATE OrderParts
							SET Quantity += @quantity
							WHERE OrderId = @orderId AND PartId = @partId
						END
					ELSE
						BEGIN
							INSERT INTO OrderParts(OrderId, PartId, Quantity)
							VALUES
							(@orderId, @partId, @quantity)
						END
				END
	END