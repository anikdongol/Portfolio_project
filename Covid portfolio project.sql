SELECT  
    *
FROM `innate-carport-432918-n2.Data_project_coviddata.Covid_death` 

WHERE
continent is null
--ORDER BY 3,4

-- SELECT
  --*
-- FROM
    --innate-carport-432918-n2.Data_project_coviddata.Vaccination
--ORDER BY 3,4

SELECT
  location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population

FROM
  innate-carport-432918-n2.Data_project_coviddata.Covid_death
ORDER BY 1,2

-- Looking at total cases vs total deaths

SELECT
  location,
  date,
  total_cases,
  total_deaths,
  (total_deaths/total_cases)*100 as death_percentages
FROM
  innate-carport-432918-n2.Data_project_coviddata.Covid_death
WHERE location like "%States%"
ORDER BY 1,2

-- looking at total cases vs population--

SELECT
  location,
  date,
  population,
  total_cases,
  (total_cases/population)*100 as cases_percentage
FROM
  innate-carport-432918-n2.Data_project_coviddata.Covid_death
--WHERE location like "%States%"
ORDER BY 1,2

-- looking at countries with highest infection rate compared to population

SELECT
  location,
  population,
  MAX(total_cases) as highestInfectionCount,
  MAX((total_cases/population))*100 as percentage_population_infected

FROM
  innate-carport-432918-n2.Data_project_coviddata.Covid_death
--WHERE location like "%States%"

GROUP BY
    location,
    population
ORDER BY percentage_population_infected DESC

-- showing countries with highest death count per population


SELECT
  location,
  continent,
  MAX(total_deaths) as totalDeathCount,
  MAX((total_deaths/population)) as deathPercentage

 
FROM
  innate-carport-432918-n2.Data_project_coviddata.Covid_death
WHERE continent is not null

GROUP BY
    location,
    continent
ORDER BY totalDeathCount DESC

--LETS BREAK THINGS DOWN BY CONTINENT
-- showing continents with highest death counts per population
SELECT
  continent,
  MAX(total_deaths) as totalDeathCount,
  MAX((total_deaths/population)) as deathPercentage
 
FROM
  innate-carport-432918-n2.Data_project_coviddata.Covid_death
WHERE
  continent is not null
GROUP BY
    continent
ORDER BY totalDeathCount DESC


-- GLOBAL NUMBERS
--  DEATH PERCENTAGE OF WORLD PER DAY
SELECT
  date,
  SUM(new_cases) as sum_new_cases, 
  SUM(new_deaths) as sum_new_deaths, 
  SUM(new_deaths)/SUM(new_cases)*100 as death_percentages_worldwide
FROM
  innate-carport-432918-n2.Data_project_coviddata.Covid_death
WHERE continent is not null
GROUP BY
  date
ORDER BY 1,2

--  DEATH PERCENTAGE OF WORLD IN A NUTSHELL
SELECT
  SUM(new_cases) as sum_new_cases, 
  SUM(new_deaths) as sum_new_deaths, 
  SUM(new_deaths)/SUM(new_cases)*100 as death_percentages_worldwide
FROM
  innate-carport-432918-n2.Data_project_coviddata.Covid_death
WHERE continent is not null

-- JOINING THE DEATH AND VACCINATION TABLE

SELECT
  *
FROM
    innate-carport-432918-n2.Data_project_coviddata.Covid_death as dea
 JOIN
    innate-carport-432918-n2.Data_project_coviddata.Vaccination as vac
  ON
    dea.location = vac.location
  AND
     dea.date = vac.date

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS
-- VACCINE EACH DAY FOR EVERY LOCATION
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as sum_vaccine_each_day

FROM
    innate-carport-432918-n2.Data_project_coviddata.Covid_death as dea
 JOIN
    innate-carport-432918-n2.Data_project_coviddata.Vaccination as vac
  ON
    dea.location = vac.location
  AND
     dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE

with popvsvac as (
    SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as sum_vaccine_each_day

FROM
    innate-carport-432918-n2.Data_project_coviddata.Covid_death as dea
 JOIN
    innate-carport-432918-n2.Data_project_coviddata.Vaccination as vac
  ON
    dea.location = vac.location
  AND
     dea.date = vac.date
WHERE dea.continent is not null
)
SELECT
    *, (sum_vaccine_each_day/population)*100 as vaccine_percentage
FROM popvsvac

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

create view innate-carport-432918-n2.Data_project_coviddata.sum_vaccine_each_day as
  SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as sum_vaccine_each_day

FROM
    innate-carport-432918-n2.Data_project_coviddata.Covid_death as dea
 JOIN
    innate-carport-432918-n2.Data_project_coviddata.Vaccination as vac
  ON
    dea.location = vac.location
  AND
     dea.date = vac.date
WHERE dea.continent is not null

