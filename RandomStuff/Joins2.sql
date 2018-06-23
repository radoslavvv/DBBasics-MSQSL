--11
SELECT MIN(sal.AverageSalary)
FROM
(
	SELECT AVG(Salary) AS AverageSalary
	FROM Employees AS e
	GROUP BY DepartmentID
) as sal

--12
SELECT mc.CountryCode, m.MountainRange, p.PeakName, p.Elevation
  FROM Peaks AS p
  JOIN Mountains AS m
	ON m.Id = p.MountainId
  JOIN MountainsCountries AS mc
	ON mc.MountainId = m.Id
 WHERE p.Elevation > 2835 AND mc.CountryCode = 'BG'
 ORDER BY p.Elevation DESC

--13
SELECT mc.CountryCode, COUNT(m.MountainRange) AS MountainRanges
  FROM Mountains AS m
  JOIN MountainsCountries AS mc
    ON mc.MountainId = m.Id
 WHERE mc.CountryCode IN ('BG','US','RU')
 GROUP BY mc.CountryCode

 --14
 SELECT TOP(5) c.CountryName, r.RiverName
   FROM Countries AS c
  FULL JOIN CountriesRivers AS cr
	 ON cr.CountryCode = c.CountryCode
  FULL JOIN Rivers AS r
	 ON r.Id = cr.RiverId
  WHERE c.ContinentCode = 'AF'
  ORDER BY CountryName

  --16
  SELECT COUNT(b.CountryCode) AS CountryCode
  FROM
  (
	SELECT c.CountryCode
	  FROM Countries AS c
	  LEFT JOIN MountainsCountries AS mc
	    ON mc.CountryCode = c.CountryCode
	  LEFT JOIN Mountains AS m
	    ON m.Id = mc.MountainId
	 WHERE MountainId IS NULL
 ) AS b

 --17
 SELECT TOP(5) c.CountryName, MAX(p.Elevation) AS HighestPeakElevation, MAX(r.Length) AS LongestRiverLength
 FROM Countries AS c
 LEFT JOIN CountriesRivers AS cr
 ON cr.CountryCode = c.CountryCode
 LEFT JOIN Rivers AS r
 ON r.Id = cr.RiverId
 LEFT JOIN MountainsCountries AS mc
 ON mc.CountryCode = c.CountryCode
 LEFT JOIN Mountains AS m
 ON m.Id = mc.MountainId
 LEFT JOIN Peaks AS p
 ON p.MountainId = m.Id
 GROUP BY c.CountryName
 ORDER BY MAX(p.Elevation) DESC, 
		  MAX(r.Length) DESC,
		  c.CountryName

  





