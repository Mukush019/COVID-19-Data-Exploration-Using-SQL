Use COVIDANALSIS;

SELECT * FROM COVID19DEATH;
SELECT * FROM COVIDVAC;

-- Show continent, location, population, date, new cases, and total deaths
SELECT Dea.continent, Dea.location, Dea.population, Dea.date, Dea.new_cases, Dea.total_deaths
FROM COVID19DEATH Dea
ORDER BY 2,4;

-- Total cases VS Total deaths As a Percentile
SELECT Dea.location, 
       Dea.date, 
	   Dea.population,
	   Dea.new_deaths,
	   Dea.total_cases,
	   Dea.total_deaths, 
	   (total_deaths*1.0/total_cases)*100 AS TotalcasesVsDeathsPercent
FROM COVID19DEATH Dea
WHERE Dea.continent <> Dea.location
AND Dea.location LIKE '%Kenya%'
ORDER BY 1, 2;

-- Total cases vs population
SELECT Dea.location, 
       Dea.date, 
	   Dea.population,
	   Dea.new_deaths,
	   Dea.total_cases,
	   Dea.total_deaths, 
	   (total_cases*1.0/population*1.0)*100 AS TotalcasesVsPopulationpercent
FROM COVID19DEATH Dea
WHERE Dea.continent <> Dea.location
ORDER BY 1, 2;

-- Highest infection rate compared to population 
SELECT Dea.location, 
	   Dea.continent,
       Dea.population,
	   Dea.total_cases,
	   MAX(Dea.total_cases) AS Maximum_Total_Cases,
	   MAX((total_cases*1.0/population*1.0))*100 AS PopulationInfectedPercent,
	   Dea.total_deaths 
FROM COVID19DEATH Dea
WHERE Dea.continent <> Dea.location
GROUP BY Dea.location, Dea.total_cases, Dea.continent, Dea.population, Dea.total_cases, Dea.total_deaths
ORDER BY PopulationInfectedPercent desc;

-- Countries with highest death count
SELECT Dea.location, 
	   MAX(total_deaths) AS DeathCountPerCountry
FROM COVID19DEATH Dea
WHERE Dea.location <> continent
GROUP BY Dea.location, Dea.population
ORDER BY DeathCountPerCountry desc;

-- Death Count Per Continent
SELECT Dea.location, 
	   MAX(total_deaths) AS DeathCountPerContinent
FROM COVID19DEATH Dea
WHERE Dea.continent IS NULL
GROUP BY Dea.location
ORDER BY DeathCountPerContinent desc;

-- Illustrate the Global Numbers
SELECT SUM(Dea.new_cases) AS Total_Cases,
	   SUM(Dea.new_deaths) AS TOTAL_New_Deaths,
	   SUM(Dea.new_deaths*1.0)/SUM(Dea.new_cases*1.0) AS DeathPercentage
FROM COVID19DEATH Dea
WHERE Dea.continent IS NOT NULL
-- Group By Dea.population
--ORDER BY 1, 2;

-- Total Population VS Vaccination
SELECT 
	   Dea.date,
	   Dea.location, 
	   Dea.Continent,
	   Dea.population,
	   COVAC.new_vaccinations,
	   SUM(COVAC.new_vaccinations*1.0) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea. Date) AS RollingNewVac
FROM COVID19DEATH Dea
JOIN COVIDVAC COVAC
ON Dea.date = COVAC.date
JOIN COVIDVAC
ON COVAC.location = Dea.location
WHERE Dea.continent IS NOT NULL
AND COVAC.new_vaccinations IS NOT NULL
ORDER BY 1,2,3;

-- MaximumRollingNewVac VS population 
With VacVsPop(
Continent,
LOCATION,
Date,
Population,
New_vaccination,
RollingNewVac
) 
AS
(
SELECT 
	   Dea.date,
	   Dea.location, 
	   Dea.Continent,
	   Dea.population,
	   COVAC.new_vaccinations,
	   SUM(COVAC.new_vaccinations*1.0) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea. Date) AS RollingNewVac
FROM COVID19DEATH Dea
JOIN COVIDVAC COVAC
ON Dea.date = COVAC.date
JOIN COVIDVAC
ON COVAC.location = Dea.location
WHERE Dea.continent IS NOT NULL
AND COVAC.new_vaccinations IS NOT NULL
--ORDER BY 1,2,3
)
SELECT *, (RollingNewVac)/(population)
FROM VacVsPop
;

-- RollingNewVac VS Pop Using Temp Tables
DROP TABLE IF EXISTS #PercentPopVac
CREATE TABLE #PercentPopVac
(
Continent nvarchar (255),
Location NVARCHAR (255),
Date DATETIME,
Population numeric,
New_Vaccination numeric,
RollingNewVac numeric
)
INSERT INTO #PercentPopVac
SELECT 
	   Dea.date,
	   Dea.location, 
	   Dea.Continent,
	   Dea.population,
	   COVAC.new_vaccinations,
	   SUM(COVAC.new_vaccinations*1.0) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea. Date) AS RollingNewVac
FROM COVID19DEATH Dea
JOIN COVIDVAC COVAC
ON Dea.date = COVAC.date
JOIN COVIDVAC
ON COVAC.location = Dea.location
WHERE Dea.continent IS NOT NULL
AND COVAC.new_vaccinations IS NOT NULL
--ORDER BY 1,2,3
SELECT *, (RollingNewVac)/(population)
FROM #PercentPopVac
;

-- Creating a view

CREATE VIEW TotalcasesVsPopulationpercent AS
SELECT Dea.location, 
       Dea.date, 
	   Dea.population,
	   Dea.new_deaths,
	   Dea.total_cases,
	   Dea.total_deaths, 
	   (total_cases*1.0/population*1.0)*100 AS TotalcasesVsPopulationpercent
FROM COVID19DEATH Dea
WHERE Dea.continent <> Dea.location
--ORDER BY 1, 2;