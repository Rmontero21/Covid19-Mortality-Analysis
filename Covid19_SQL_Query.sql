 SELECT *
FROM Covid19_Deaths
ORDER BY 3,4;

SELECT *
FROM Covid19_Vaccination
ORDER BY 3,4;

-- Select the data that I'm going to work with
-- Which country in Central America had the first case

SELECT 
location, date, total_cases, population, total_deaths
FROM Covid19_Deaths
WHERE total_cases is not null and continent like '%Central America%'
ORDER BY date ASC;

-- Looking at total cases vs total deaths
-- How many cases are in Central America and how many deaths do they had * their entire cases

SELECT 
location, date, population, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathRatio
FROM Covid19_Deaths
WHERE total_cases is not null and continent like '%Central America%'
ORDER BY 1,2;

-- Looking at total cases vs population/total deaths
-- Shows what % of population got Covid

SELECT 
location, date, population, total_cases, 
(total_cases/population)*100 as Population_Infected,
(total_deaths/total_cases)*100 as DeathRatio
FROM Covid19_Deaths
WHERE total_cases is not null and continent like '%Central America%'
ORDER BY 1,2;

-- Looking at Countries with highest infection rate compared to population

SELECT 
location, population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM Covid19_Deaths
WHERE continent like '%Central America%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Showing Countries with highest death count per population & highest infection rate compared to population

SELECT 
location, population, 
MAX(total_deaths) as TotalDeathCount,
MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM Covid19_Deaths
WHERE continent like '%Central America%'
GROUP BY location, population
ORDER BY TotalDeathCount DESC;

-- Let's see a comparation between the other continents

SELECT 
continent, 
MAX(total_deaths) as TotalDeathCount
FROM Covid19_Deaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Global numers

SELECT SUM(DISTINCT population) as Total_Population, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
SUM(new_deaths)/SUM(new_cases)*100 as Death_Ratio,
SUM(new_cases)/SUM(DISTINCT population)*100 as Porcent_Peopple_Infected
FROM Covid19_Deaths
WHERE continent is not null
ORDER BY 1,2;

-- Population vs vaccinations.
-- Shows percentage of population that has received at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER by dea.location, dea.date) 
as LATAM_Total_Vaccinations
--(LATAM_Total_Vaccinations/dea.population)*100 as Porcentage
FROM Covid19_Deaths dea
JOIN Covid19_Vaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
and dea.continent like '%Central America%'
ORDER BY 2,3;

-- USE CTE to perform calculation on partition by in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, LATAM_Total_Vaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER by dea.location, dea.date) 
as LATAM_Total_Vaccinations
FROM Covid19_Deaths dea
JOIN Covid19_Vaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
and dea.continent like '%Central America%'
-- ORDER BY 2,3
)
SELECT *, (LATAM_Total_Vaccinations/population)*100 as Porcentage
FROM PopvsVac
ORDER BY 2,3;

-- Creating View to store data for later visualizations

CREATE VIEW VaccinationEfforts as
WITH PopvsVac (continent, location, date, population, new_vaccinations, LATAM_Total_Vaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea. population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER by dea.location, dea.date) 
as LATAM_Total_Vaccinations
FROM Covid19_Deaths dea
JOIN Covid19_Vaccination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
and dea.continent like '%Central America%'
-- ORDER BY 2,3
)
SELECT *, (LATAM_Total_Vaccinations/population)*100 as Porcentage
FROM PopvsVac
--ORDER BY 2,3;

CREATE VIEW GLOBALNUMBERS AS
SELECT SUM(DISTINCT population) as Total_Population, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
SUM(new_deaths)/SUM(new_cases)*100 as Death_Ratio,
SUM(new_cases)/SUM(DISTINCT population)*100 as Porcent_Peopple_Infected
FROM Covid19_Deaths
WHERE continent is not null
--ORDER BY 1,2;

CREATE VIEW InfectionVSDeath AS
SELECT 
location, population, 
MAX(total_deaths) as TotalDeathCount,
MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM Covid19_Deaths
WHERE continent like '%Central America%'
GROUP BY location, population
--ORDER BY TotalDeathCount DESC;

CREATE VIEW ContinentDeaths AS
SELECT 
continent, 
MAX(total_deaths) as TotalDeathCount
FROM Covid19_Deaths
WHERE continent is not null
GROUP BY continent
--ORDER BY TotalDeathCount DESC;