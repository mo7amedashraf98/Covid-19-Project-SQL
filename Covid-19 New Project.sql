SELECT * 
FROM Project..CovidDeaths
WHERE continent is not null
Order by 3,4

-- Selecting the data we'll use

SELECT location, date, total_cases, total_deaths, new_cases, population
FROM Project..CovidDeaths
where continent is not null
order by 1,2

-- Total Deaths vs Total Cases
-- Showing the likelihood of dying if you were infected by Covid in "Egypt"

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project..CovidDeaths
where location like '%Egypt%'
and continent is not null
order by 1,2

--Total Cases vs Population 
-- Percentage of Population infected with Covid in Egypt

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercnetagePopulationInfected
FROM Project..CovidDeaths
--where location like '%Egypt%'
order by 1,2

-- The countries with the highest infection rate

SELECT location, population,max(total_cases) as HighestInfections, MAX((total_cases/population))*100 as PercnetagePopulationInfected
FROM Project..CovidDeaths
--where location like '%Egypt%'
Group by location,population
order by 1,2

-- Countries with the highest death count

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCounts 
FROM Project..CovidDeaths
--where location like '%Egypt%'
where continent is not null
Group by location
order by TotalDeathCounts desc


-- Showing the Continents having the highest death count

SELECT continent, MAX(cast(total_deaths as int)) as ContinentTotalDeathCounts 
FROM Project..CovidDeaths
--where location like '%Egypt%'
where continent is not null
Group by continent
order by ContinentTotalDeathCounts desc


-- Population VS Vaccinations

-- Showing Vaccination Percenatge in comparison to Population

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM project..CovidDeaths dea
Join project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using a CTE to perform calculation on on RollingPeopleVaccinated in the previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM project..CovidDeaths dea
Join project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using a Temp Table to perform calculations on RollingPeopleVaccinated in the previous query
Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM project..CovidDeaths dea
Join project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From #PercentPopulationVaccinated