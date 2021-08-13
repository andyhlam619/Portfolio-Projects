-- All data 

SELECT *
FROM CovidPortfolioProject..CovidDeaths

-- Total Cases vs Total Death in United States

SELECT
	location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidPortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Total Cases vs Population in United States

SELECT
	location, date, total_cases, population, (total_cases/population)*100 AS covid_percentage
FROM CovidPortfolioProject..CovidDeaths
WHERE location like '%states%' 
ORDER BY 1,2

-- Country's Infection Rate Compared to Population

SELECT
	location, MAX(total_cases) AS highst_infctn_cnt, population, MAX((total_cases/population))*100 AS percent_population_infected
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY population, location
ORDER BY percent_population_infected DESC

-- Highest Death Count per Country

SELECT
	location, MAX(CAST(total_deaths as int)) AS highst_death_cnt, population
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY population, location
ORDER BY highst_death_cnt DESC

-- Highest Death Count per Continent

SELECT
	location, MAX(CAST(total_deaths as int)) AS highst_death_cnt
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is null AND location NOT IN ('world', 'international')
GROUP BY location
ORDER BY highst_death_cnt DESC

-- Global Covid Numbers per Day

SELECT
	date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_death, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS death_percentage
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY date
ORDER BY date

-- General Global Covid Numbers

SELECT
	SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_death, (SUM(CAST(total_deaths as int))/SUM(total_cases))*100 AS death_percentage
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null 

-- Total Population vs Vaccinations using Temp Table and Joins

WITH 
	all_data  (continent, location, date, population, new_vaccinations, rolling_total_vax)
	AS
(
SELECT 
	death.continent, death.location, death.date, death.population, vax.new_vaccinations, 
	SUM(CAST(vax.new_vaccinations as int)) OVER (PARTITION BY death.location Order by death.location, death.date) as rolling_total_vax
FROM CovidPortfolioProject..CovidDeaths death
JOIN CovidPortfolioProject..CovidVaccinations vax
	ON death.location = vax.location AND death.date = vax.date
WHERE vax.new_vaccinations is not null AND death.continent is not null 
)
SELECT *, (rolling_total_vax/population)*100 AS total_pop_vax_percentage
FROM all_data

-- Temp Table Method 2

DROP TABLE IF exists #percent_pop_vax
CREATE TABLE #percent_pop_vax
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric,
new_vaccinations numeric, 
rolling_total_vax numeric
)
INSERT INTO #percent_pop_vax
SELECT 
	death.continent, death.location, death.date, death.population, vax.new_vaccinations, 
	SUM(CAST(vax.new_vaccinations as int)) OVER (PARTITION BY death.location Order by death.location, death.date) as rolling_total_vax
FROM CovidPortfolioProject..CovidDeaths death
JOIN CovidPortfolioProject..CovidVaccinations vax
	ON death.location = vax.location AND death.date = vax.date
WHERE vax.new_vaccinations is not null AND death.continent is not null 

SELECT *, (rolling_total_vax/population)*100 AS total_pop_vax_percentage
FROM #percent_pop_vax

-- Creating Views

CREATE VIEW percent_pop_vax as 
SELECT 
	death.continent, death.location, death.date, death.population, vax.new_vaccinations, 
	SUM(CAST(vax.new_vaccinations as int)) OVER (PARTITION BY death.location Order by death.location, death.date) as rolling_total_vax
FROM CovidPortfolioProject..CovidDeaths death
JOIN CovidPortfolioProject..CovidVaccinations vax
	ON death.location = vax.location AND death.date = vax.date
WHERE vax.new_vaccinations is not null AND death.continent is not null 



