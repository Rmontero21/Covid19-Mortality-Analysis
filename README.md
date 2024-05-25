# Covid19 Mortality Analysis

### Table of Contents
- [Exploratory Data Analysis](#Exploratory-Data-Analysis)
- [SQL Query Data Analysis](#SQL-Query-Data-Analysis)
- [Results & Findings](#Results-&-Findings)
- [Limitations](#Limitations)

### Project Overview and Objetives
---

This data analysis project assess the COVID-19 mortality rates globally, analyzing variations among countries, while the pace of infection with each nation's vaccination campaigns..  

- Evaluate and compare COVID-19 mortality rates across multiple countries to identify disparities and trends in pandemic severity.
- Analyze the relationship between the speed of COVID-19 infections and the progress of vaccination efforts within each nation to understand the impact of vaccination campaigns on controlling the pandemic.
<img width="603" alt="Screenshot 2024-05-24 171335" src="https://github.com/Rmontero21/Covid19-Mortality-Analysis/assets/169692846/a2077a59-276f-4ab6-aba6-7de18e687346">


---
### Data Sources

The datasets that I used for this analysis is the "owid-covid-data.csv" file with almost 400k rows that contain detailed information about the pandemic from 2020 until 2024.

---
### Tools

- Excel - Data Cleaning 🧹
- SQL Server - Create the database / Data Analysis 💻
- PowerBI - Connect PowerBI to the Database / Data Visualization 📈

---
### Data Cleaning/Preparation

In the initial data preparation phase, we performed the following tasks:
1. Data loading and inspection.
2. Handling null values.
3. Data cleaning and formatting.

---
### Exploratory Data Analysis

The EDA involved exploring the data to answer key questions, such as:

- How many cases are in each country and how many deaths do they had * their entire cases?
<img width="268" alt="Infection x country" src="https://github.com/Rmontero21/Covid19-Mortality-Analysis/assets/169692846/4c0124c2-478e-4a88-bb75-7d045a9b1151">
  
- Infection vs vaccinations, how many people has received at least one Covid Vaccine?
<img width="637" alt="Infection vs vaccination" src="https://github.com/Rmontero21/Covid19-Mortality-Analysis/assets/169692846/c5bd96e6-9206-47e7-97f0-a6430eabbc5d">

- Which are the countries that were more affected by the pandemic?
<img width="632" alt="Map" src="https://github.com/Rmontero21/Covid19-Mortality-Analysis/assets/169692846/6278ce94-d8ce-452a-9cc4-0706c24dc6d9">

---
### SQL Query Data Analysis

Include some interesting code/features that I worked with, please note that some of my inicial queries were focused in Central America data that I later changed to a global view. 

```sql
-- Looking at total cases vs population/total deaths
-- Shows what % of population got Covid

SELECT 
location, date, population, total_cases, 
(total_cases/population)*100 as Population_Infected,
(total_deaths/total_cases)*100 as DeathRatio
FROM Covid19_Deaths
WHERE total_cases is not null
ORDER BY 1,2;
```
```sql
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
```
```sql
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
```
```sql
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
```

---
### Results & Findings

The analysis results are summarized as follows:
1. The United States is the country with more deaths registered with 1.19M along with 103.44M of people infected.
2. Europe is the Continent with more deaths registered with 2.1M.
3. Global Numbers:
   - Total Cases 775.45M
   - Total Deaths 7.05M
   - Total Vaccines used 10.86Bn
   - Global Death Ratio 0.91%
   - Global people infected 9.64%

---
### Limitations

1. I had to replace all null data with 0 values in numeric columns because they would have affected the accuracy of my conclucions from the analysis. 
2. I had to change the continent of all countries that are parth of Central America due to they were count as if they belong to North America and that would have increased the numbers for that continent, leaving Central America with 0 values.

---

