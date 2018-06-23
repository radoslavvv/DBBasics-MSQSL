SELECT e.AgeGroup, COUNT(e.AgeGroup) AS WizzardsCount FROM (
SELECT 
	CASE
		WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
		WHEN AGE BETWEEN 11 AND 20 THEN '[11-20]'
		WHEN AGE BETWEEN 21 AND 30 THEN '[21-30]'
		WHEN AGE BETWEEN 31 AND 40 THEN '[31-40]'
		WHEN AGE BETWEEN 41 AND 50 THEN '[41-50]'
		WHEN AGE BETWEEN 51 AND 60 THEN '[51-60]'
		WHEN AGE >= 61  THEN '[61+]'
	END AS AgeGroup
FROM WizzardDeposits) AS e
GROUP BY AgeGroup

--10
SELECT LEFT(FirstName, 1) AS [FirstLetter]
FROM WizzardDeposits
WHERE DepositGroup LIKE 'Troll Chest'
GROUP BY LEFT(FirstName, 1)
ORDER BY [FirstLetter]

--11
SELECT DepositGroup, IsDepositExpired, AVG(DepositInterest) AS [AverageInterest]
FROM WizzardDeposits
WHERE DepositStartDate > '01/01/1985'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC

--13
USE SoftUni

SELECT DepartmentID, SUM(Salary) AS TotalSalary
FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID

--14
SELECT DepartmentID, MIN(Salary)
FROM Employees
WHERE DepartmentID IN (2,5,7) AND HireDate > '01/01/2000'
GROUP BY DepartmentID

--15
SELECT DepartmentID, AVG(Salary) AS AverageSalary
FROM Employees

GROUP BY DepartmentID

--15
SELECT * INTO EmployeeAverageSalary
FROM Employees
WHERE Salary > 30000

DELETE FROM EmployeeAverageSalary
WHERE ManagerID = 42

UPDATE EmployeeAverageSalary
SET Salary = Salary + 5000
WHERE DepartmentID = 1

SELECT DepartmentID, AVG(Salary) As AverageSalary
FROM EmployeeAverageSalary
GROUP BY DepartmentID

--16
SELECT DepartmentID, MAX(Salary) AS [MaxSalary]
FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

--17
SELECT COUNT(*) AS Count
FROM Employees
WHERE ManagerID IS NULL

--12
USE Gringotts

SELECT SUM(e.Diff) AS [TotalSum] 
FROM (
	SELECT DepositAmount - LEAD(DepositAmount) OVER (ORDER BY Id) AS Diff
	FROM WizzardDeposits
) AS e


--18
SELECT DISTINCT DEpartmentID, Salary FROM (
SELECT DepartmentID, Salary, DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY SALARY DESC) AS [SalaryRank]
FROM Employees ) AS e
WHERE SalaryRank = 3

--19
SELECT TOP(10) FirstName, LastName, DepartmentID
FROM Employees AS Emp
WHERE SALARY > (SELECT AVG(Salary) FROM Employees WHERE DepartmentId = Emp.DepartmentId)
ORDER BY DepartmentId