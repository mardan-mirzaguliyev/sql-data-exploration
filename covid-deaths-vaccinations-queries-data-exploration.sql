 --Test
SELECT *
FROM  CovidDeaths
WHERE continent is not NULL
ORDER BY 3, 4
------


--Main portion of data to be analyzed
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not NULL
ORDER BY 1, 2 
------


--Total cases vs total deaths
-- Likelihood of dying of COVID19
SELECT location, date, total_cases, total_deaths,
CAST((total_deaths / total_cases) AS INT) * 100 AS DeathPercentage
FROM CovidDeaths
--WHERE Location like '%States%'
ORDER BY 1, 2
------


--Total cases vs population
--Percentage of people infected
SELECT location, date, Population, total_cases,
CAST((total_cases / population) AS INT) * 100 AS InvectionPercentage
FROM CovidDeaths
WHERE location = 'Azerbaijan'
ORDER BY 1, 2
------


--Countries with highest infection rates compared to population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,
MAX((total_cases / population)) * 100 AS InvectionPercentage
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY InvectionPercentage DESC
------


--Countries with highest death count rates per population
SELECT Location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount,
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC
------


--GROUP BY continent
--FIRST QUERY GETS WRONG ANSWERS. FOR Example, taking into account only US in North America
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount,
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC
------


--This query gets more correct results
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount,
FROM CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
------


--GLOBAL NUMBERS
--version 1
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths) /SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
--WHERE Location like '%States%' AND continent is not NULL
WHERE continent is not NULL
GROUP BY date
ORDER BY 1, 2

version 2
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths) /SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
--WHERE Location like '%States%' AND continent is not NULL
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1, 2
------


--Join two tables: deaths and vaccinations
SELECT *
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
-----


--Total vaccinations vs total population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2, 3
-----


--PARTITION BY

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM((Vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2, 3

--USE CTE (Common Table expression)
WITH PopvsVac AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM((Vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated / Population) * 100 AS RollVacvsPop
FROM PopvsVac
-----

--TEMP table

CREATE TABLE PercentPopulationVaccinated
(
Contient nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition BY dea.Location ORDER by dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3
-----


--CREATE view
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2, 3
