--1
SELECT TOP(5) Emp.EmployeeID, Emp.JobTitle, [Add].AddressID, [Add].AddressText
  FROM Employees AS Emp
  JOIN Addresses AS [Add]
    ON [Add].AddressID = Emp.AddressID
 ORDER BY [Add].AddressID

--2
SELECT TOP(50) e.FirstName, e.LastName, t.Name, a.AddressText
  FROM Employees AS e
  JOIN Addresses AS a
    ON a.AddressID = e.AddressID
  JOIN Towns AS t
    ON t.TownID = a.TownID
 ORDER BY e.FirstName, e.LastName

--3
SELECT E.EmployeeID, E.FirstName, E.LastName, D.Name
  FROM Employees AS E
  JOIN Departments AS D
    ON D.DepartmentID = E.DepartmentID
 WHERE D.Name = 'Sales'
 ORDER BY E.EmployeeID

 --4
 SELECT TOP(5) e.EmployeeID, e.FirstName, e.Salary, d.Name
   FROM Employees AS e
   JOIN Departments AS d
     ON d.DepartmentID = e.DepartmentID
  WHERE e.Salary > 15000
  ORDER BY d.DepartmentID

 --5
 SELECT TOP(3) EmployeeID, FirstName 
   FROM Employees AS s
  WHERE s.EmployeeID NOT IN 
	 (
		 SELECT e.EmployeeID
		 FROM Employees AS e
		 RIGHT JOIN EmployeesProjects AS p
		 ON p.EmployeeID = e.EmployeeID
	) 
  ORDER BY EmployeeID

--6
SELECT E.FirstName, E.LastName, E.HireDate, D.Name AS DeptName
  FROM Employees AS E
  JOIN Departments AS D
    ON D.DepartmentID = E.DepartmentID
 WHERE E.HireDate > '1/1/1999' AND D.Name IN ('Sales', 'Finance')
 ORDER BY E.HireDate

--7
SELECT TOP(5) e.EmployeeID, e.FirstName, p.Name
  FROM Employees AS e
  JOIN EmployeesProjects AS ep
    ON ep.EmployeeID = e.EmployeeID
  JOIN Projects as p
    ON p.ProjectID = ep.ProjectID
 WHERE p.StartDate > '08/13/2002'
 ORDER BY E.EmployeeID

--8
SELECT e.EmployeeID, e.FirstName, 
(CASE 
	WHEN DATEPART(YEAR, p.StartDate) >= 2005 THEN NULL
	ELSE p.Name
END) AS ProjectName
  FROM Employees AS e
  JOIN EmployeesProjects AS ep
    ON ep.EmployeeID = e.EmployeeID
  JOIN Projects as p
    ON p.ProjectID = ep.ProjectID
 WHERE e.EmployeeID = 24

 --9
 SELECT emp.EmployeeID, emp.FirstName, man.EmployeeID , man.FirstName AS ManagerName
   FROM Employees AS emp
   JOIN Employees AS man
     ON man.EmployeeID = emp.ManagerID
  WHERE man.EmployeeID IN (3,7)
  ORDER BY emp.EmployeeID

--10
SELECT TOP(50) emp.EmployeeID, 
				emp.FirstName + ' ' + emp.LastName AS EmployeeName, 
				man.FirstName + ' ' + man.LastName AS ManagerName, 
				dep.Name AS DepartmentName
FROM Employees AS emp
JOIN Employees AS man
ON man.EmployeeID = emp.ManagerID
JOIN Departments AS dep
ON dep.DepartmentID = emp.DepartmentID 
ORDER BY emp.EmployeeID

