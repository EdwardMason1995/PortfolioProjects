SELECT *
FROM PortfolioProject..covid_deaths
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..covid_vaccinations
--ORDER BY 3,4

--Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM PortfolioProject..covid_deaths
WHERE total_cases IS NOT NULL AND location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as ContractionPercentage
FROM PortfolioProject..covid_deaths
WHERE total_cases IS NOT NULL AND location like '%states%'
ORDER BY 1,2

--Looking at conutries with highest infection rate compared to population
SELECT location, population, MAX(cast(total_cases as float)) as HighestInfectionCount, MAX((cast(total_cases as float)/cast(population as float))*100) as ContractionPercentage
FROM PortfolioProject..covid_deaths
WHERE total_cases IS NOT NULL
GROUP BY location, population
ORDER BY ContractionPercentage desc

-- Showing the countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covid_deaths
WHERE total_cases IS NOT NULL 
	AND continent is NOT NULL
GROUP BY location 
ORDER BY TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT
-- Total Deaths by continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covid_deaths
WHERE total_cases IS NOT NULL 
	AND continent is NULL 
	AND location not like '%income%'
GROUP BY location 
ORDER BY TotalDeathCount desc

-- Showing continents with the highest death counts per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covid_deaths
WHERE total_cases IS NOT NULL 
	AND continent is NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..covid_deaths
WHERE total_cases IS NOT NULL 
	AND continent is NOT NULL
  --AND location like '%states%'
--GROUP BY date
ORDER BY 1,2 


-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3


--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
FROM PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

