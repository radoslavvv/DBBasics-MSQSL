WITH CTE_CountriesInfo(CountryName, PeakName, Elevation, Mountain) 
AS (
SELECT c.CountryName, p.PeakName, MAX(p.Elevation), m.MountainRange
  FROM Countries AS c
  LEFT JOIN MountainsCountries AS mc
    ON mc.CountryCode = c.CountryCode
  LEFT JOIN Mountains AS m
	ON m.Id = mc.MountainId
  LEFT JOIN Peaks AS p
	ON p.MountainId = m.Id
	GROUP BY c.CountryName, p.PeakName, m.MountainRange)

SELECT TOP(5) e.CountryName, 
       ISNULL(cci.PeakName,'(no highest peak)') AS [Highest Peak Name], 
       ISNULL(cci.Elevation,0) AS [Highest Peak Elevation], 
       ISNULL(cci.Mountain,'(no mountain)') AS [Mountain]
FROM
(
	SELECT Countryname, MAX(Elevation) AS MaxElevation
	FROM CTE_CountriesInfo
	GROUP BY CountryName
) AS e 
LEFT JOIN CTE_CountriesInfo AS cci
ON cci.CountryName = e.CountryName 
AND cci.Elevation = e.MaxElevation
ORDER BY e.CountryName, cci.PeakName



--15
WITH CTE_CountriesInfo(ContinentCode, CurrencyCode, CurrencyUsage) AS(
SELECT ContinentCode, CurrencyCode, COUNT(CurrencyCode) AS CurrencyUsage
FROM Countries
GROUP BY ContinentCode, CurrencyCode
HAVING COUNT(CurrencyCode) >1
)



SELECT e.ContinentCode, cci.CurrencyCode, e.CurrencyUsage FROM(
SELECT ContinentCode, MAX(CurrencyUsage) AS CurrencyUsage
FROM CTE_CountriesInfo
GROUP BY ContinentCode
) AS e
JOIN CTE_CountriesInfo AS cci
ON cci.ContinentCode = e.ContinentCode
AND cci.CurrencyUsage = e.CurrencyUsage
ORDER BY ContinentCode