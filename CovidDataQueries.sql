-- SELECTING ALL COLUMNS FROM THE COVIDDEATHS TABLE AND ORDERING BY LOCATION AND DATE

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..CovidDeaths
ORDER BY Location, date;

-- CALCULATING THE DEATH PERCENTAGE FROM TOTAL CASES AND TOTAL DEATHS

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE Location LIKE '%Canada%'
ORDER BY Location, date;

-- CALCULATING THE PERCENTAGE OF THE POPULATION THAT WAS INFECTED WITH COVID

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
FROM Portfolio_Project..CovidDeaths
WHERE Location LIKE '%Canada%'
ORDER BY Location, date;

-- FINDING THE COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS PercentagePopulationInfected
FROM Portfolio_Project..CovidDeaths
GROUP BY Location, population
ORDER BY PercentagePopulationInfected DESC;

-- FINDING THE COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT Location, MAX(CAST(total_deaths AS FLOAT)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- FINDING THE CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(CAST(Total_deaths AS FLOAT)) AS TotalDeathCount
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS FOR NEW CASES, NEW DEATHS, AND DEATH PERCENTAGE

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL;

-- NUMBERS BY DATE FOR NEW CASES, NEW DEATHS, AND DEATH PERCENTAGE

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM Portfolio_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- TOTAL POPULATION VS VACCINATIONS
-- CALCULATING THE PERCENTAGE OF THE POPULATION THAT HAS RECEIVED AT LEAST ONE COVID VACCINE

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
