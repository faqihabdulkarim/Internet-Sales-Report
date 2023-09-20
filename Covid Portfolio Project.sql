
SELECT DISTINCT *
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM Portfolio_Project..CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..CovidDeaths
WHERE continent is not null
Order by 1,2

--looking at total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
From Portfolio_Project..CovidDeaths
Where location like '%States%' and continent is not null
Order by 1,2

--looking at total cases vs population
--shows what percentage of population that got covid

Select location, date, population, total_cases, (total_cases/population)*100 AS Got_Covid_Percentage
From Portfolio_Project..CovidDeaths
Where continent is not null
Order by 1,2

--looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population)*100) AS Percentage_Population_Infected
From Portfolio_Project..CovidDeaths
Where continent is not null
Group By location, population
Order by Percentage_Population_Infected DESC

-- showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as Highest_Death_Count
From Portfolio_Project..CovidDeaths
Where continent is not null
Group By location
Order by Highest_Death_Count DESC

--Lets Break Things Down By Continent

Select location, MAX(cast(total_deaths as int)) as Total_Death_Count
From Portfolio_Project..CovidDeaths
Where continent is null
Group By location
Order by Total_Death_Count DESC

Select continent, MAX(cast(total_deaths as int)) as Total_Death_Count
From Portfolio_Project..CovidDeaths
Where continent is not null
Group By continent
Order by Total_Death_Count DESC

--Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- USE CTE 
WITH PopvsVacs (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
AS 
(
-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS Rolling_People_Vaccinated
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT DISTINCT*, (Rolling_People_Vaccinated/population)*100
FROM PopvsVacs

-- TEMP Table

DROP TABLE IF exists #Percent_People_Vaccinated
CREATE TABLE #Percent_People_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #Percent_People_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3


SELECT *, (Rolling_People_Vaccinated/population)*100
FROM #Percent_People_Vaccinated


-- Creating View to Store Data for Later Visualizations


CREATE VIEW Percent_Peoples_Vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT*
FROM Percent_Peoples_Vaccinated