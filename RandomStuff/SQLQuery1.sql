USE Gringotts
--1
SELECT COUNT(*) AS [Count]
FROM WizzardDeposits

--2
SELECT MAX(MagicWandSize) AS [LongestMagicWand]
FROM WizzardDeposits

--3
SELECT DepositGroup, MAX(MagicWandSize) As [LongestMagicWand]
FROM WizzardDeposits
GROUP BY DepositGroup

--4
SELECT TOP(2) DepositGroup
FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize) ASC

--5
SELECT DepositGroup, SUM(DepositAmount) AS [TotalSum]
FROM WizzardDeposits
GROUP BY DepositGroup

--6
SELECT DepositGroup, SUM(DepositAmount) AS [TotalSum]
FROM WizzardDeposits 
WHERE (MagicWandCreator) LIKE 'Ollivander family'
GROUP BY DepositGroup

--7
SELECT DepositGroup, SUM(DepositAmount) AS [TotalSum]
FROM WizzardDeposits
WHERE MagicWandCreator LIKE 'Ollivander family'
GROUP BY DepositGroup
HAVING SUM(DepositAmount) < 150000
ORDER BY TotalSum DESC

--8
SELECT DepositGroup, MagicWandCreator, MIN(DepositCharge) As [MinDepositCharge]
FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup

--9
SELECT Age, COUNT(*)
FROM WizzardDeposits
GROUP BY Age



