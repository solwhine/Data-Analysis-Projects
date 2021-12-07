SELECT * FROM PortfolioProject..CovidDeaths  
WHERE continent is not null ORDER BY location,date;

SELECT * FROM PortfolioProject..CovidVaccinations 
WHERE continent is not null ORDER BY location,date;


--Selecting the columns in CovidDeaths table

SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM PortfolioProject..CovidDeaths WHERE continent is not null ORDER BY location,date;


--Total cases Vs Total deaths
--Shows likelihood of dying if we are affected by Covid in India
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths WHERE continent is not null AND location='India' ORDER BY location,date;

--Totl cases Vs Population
--Shows the percentage of people affected by Covid in India
SELECT location,date,population,total_cases,(total_cases/population)*100 AS affected_percentage
FROM PortfolioProject..CovidDeaths WHERE  continent is not null AND location='India' ORDER BY location,date;


--Countries with Highest Infection Rate compared to population
SELECT location,population,MAX(total_cases) AS Infection_rate, MAX((total_cases/population))*100 AS infected_percentage
FROM PortfolioProject..CovidDeaths WHERE continent is not null
GROUP BY location,population 
ORDER BY infected_percentage DESC;

--Countries with Highest death count per population
SELECT location,MAX(cast(total_deaths AS int)) AS death_count
FROM PortfolioProject..CovidDeaths WHERE continent is not null 
GROUP BY location
ORDER BY death_count DESC;

--Continents with Highest death count per population
SELECT continent,MAX(cast(total_deaths AS int)) AS death_count
FROM PortfolioProject..CovidDeaths WHERE continent is not null 
GROUP BY continent
ORDER BY death_count DESC;



--GLOBAL NUMBERS

--Date wise numbers

SELECT date,SUM(new_cases) AS total_cases,SUM(cast(new_deaths AS int)) AS total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS deathPercentage
FROM PortfolioProject..CovidDeaths WHERE continent is not null GROUP BY date 
ORDER BY 1,2;

--In totality
SELECT SUM(new_cases) AS total_cases,SUM(cast(new_deaths AS int)) AS total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS deathPercentage
FROM PortfolioProject..CovidDeaths WHERE continent is not null --GROUP BY date 
ORDER BY 1,2;


--Looking at Total population Vs Vaccination

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

--Common Table Expression
With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,Rolling_people_vaccinated) AS
(SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not null
)
SELECT *, (Rolling_people_vaccinated/Population)*100
FROM PopvsVac;



--Temp Table

DROP TABLE IF EXISTS #Percent_population_vaccinated
CREATE TABLE #Percent_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_people_vaccinated numeric
)

INSERT INTO #Percent_population_vaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date;

SELECT *, (Rolling_people_vaccinated/Population)*100
FROM #Percent_population_vaccinated;

--Creating View to store data for later visualizations

DROP VIEW IF EXISTS PercentPopulationVaccinated;

create view PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not null;

SELECT * FROM PercentPopulationVaccinated;












