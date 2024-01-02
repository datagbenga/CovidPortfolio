Select *
From CovidPortfolio..CovidDeaths
Where Continent is not null
Order by 3, 4


Select *
From CovidPortfolio..CovidVaccinations
Where Continent is not null
Order by 3, 4

-- SElect Data we are going to be using

Select location, date, total_cases, total_deaths, population
From CovidPortfolio..CovidDeaths
Where Continent is not null
Order by 1, 2

-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in the United Kingdom

Select location, date, total_cases, total_deaths, cast (total_deaths as float)/cast(total_cases as float)*100 as DeathPercentage
From CovidPortfolio..CovidDeaths
where location like '%United Kingdom%'
and Continent is not null
order by 1, 2

-- Looking atTotal Cases vs Populatiion
-- Shows what percentage of population got Covid

Select location, date, total_cases, population, cast (total_cases as int)/cast(population as int)*100 as PercentagePopulationInfected
From CovidPortfolio..CovidDeaths
where location like '%United Kingdom%' 
and Continent is not null
order by 1, 2

-- Showing the Countries with the Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max(cast(total_cases as float)/cast(population as float))*100 as PercentagePopulationInfected
From CovidPortfolio..CovidDeaths
Where Continent is not null
-- where location like '%United Kingdom%'
Group by Location, Population
order by PercentagePopulationInfected desc


-- Showing the Countries with the Highest Deat Count per Population

Select Location, MAX(Cast(total_deaths as int)) as TotalDeathsCount
From CovidPortfolio..CovidDeaths
Where Continent is not null
-- where location like '%United Kingdom%'
Group by Location
order by TotalDeathsCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
--  Showing the Continents with the Highest Death Count

Select Continent, MAX(Cast(total_deaths as int)) as TotalDeathsCount
From CovidPortfolio..CovidDeaths
Where Continent is not null
-- where location like '%United Kingdom%'
Group by Continent
order by TotalDeathsCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/nullif(SUM(New_Cases),0)*100 as DeathPercentage
From CovidPortfolio..CovidDeaths
--where location like '%United Kingdom%'
Where Continent is not null
Group by date
order by 1, 2

-- Looking at Total Population vs Vaccinations

Select *
From CovidPortfolio..CovidDeaths dea
Join CovidPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidPortfolio..CovidDeaths dea
Join CovidPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

-- Showing Rolling total of Vaccination by location and date


-- USE CTE 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100

From CovidPortfolio..CovidDeaths dea
Join CovidPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac 

-- TEMP TABLE

DROP Table if exists #PercentagePopulationVaccinated
Create Table  #PercentagePopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentagePopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100

From CovidPortfolio..CovidDeaths dea
Join CovidPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated

-- Creating View to Store Data for Later Visualisations

Create View PercenPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100

From CovidPortfolio..CovidDeaths dea
Join CovidPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

Select *
From PercenPopulationVaccinated