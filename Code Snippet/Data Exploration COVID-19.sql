
--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths


--Looking at the Total Cases VS Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deaths_percentage
FROM PortfolioProject..CovidDeaths


--Looking at the Total Cases VS Total Deaths in Malaysia
--Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deaths_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%malaysia%'


--Looking at Total Cases VS Population
--Shows what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%malaysia%'


--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS percent_population_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population 
ORDER BY percent_population_infected DESC


--Showing Countries with Highest Death Count per Population
--Changing total_deaths data type from nvarchar to int

SELECT location, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location  
ORDER BY total_death_count DESC


--BREAKING THINS DOWN BY CONTINENT

--Showing continents with the Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths AS int)) AS total_deaths_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths_count DESC




--GLOBAL NUMBERS

SELECT SUM(new_cases) AS global_total_cases, SUM(CAST(new_deaths AS int)) AS global_total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS global_death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY global_total_cases, global_total_deaths


--Join Covid Deaths Table and Covid Vaccinations Table
--Looking at Total Population VS Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--(rolling_peope_vaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	 ON dea.location = vac.location
	 AND	dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3




--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS

(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--,(rolling_peope_vaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	 ON dea.location = vac.location
	 AND	dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM PopvsVac



--TEMP TABLE

DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE  #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--,(rolling_peope_vaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	 ON dea.location = vac.location
	 AND	dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100
FROM #percent_population_vaccinated




--Creating view to store data for later visualization

CREATE VIEW percent_vaccination_populated AS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--,(rolling_peope_vaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	 ON dea.location = vac.location
	 AND	dea.date = vac.date
WHERE dea.continent IS NOT NULL
