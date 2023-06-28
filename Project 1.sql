--Select all data from Covid Deaths Table and Vaccinations Table
SELECT *
FROM PortfolioProject.dbo.CovidDeathsUpdated
Order by 3,4


SELECT *
FROM PortfolioProject..CovidVaccinationsUpdated
order by 3,4;

--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/(cast(total_cases as float)))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeathsUpdated
--WHERE location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (cast(total_cases as float)/population)*100 AS CoVidPercent
FROM PortfolioProject..CovidDeathsUpdated
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Populations

SELECT location, population, MAX(cast(total_cases as bigint)) AS HighestInfected, MAX(cast(total_cases as float)/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeathsUpdated
group by population, location
order by 1,2

-- Showing Countries with Highest Death Count per Population

SELECT location, population, MAX(cast(total_deaths as bigint)) AS HighestDeaths, MAX(cast(total_deaths as float)/population)*100 AS PercentPopulationDeath
FROM PortfolioProject..CovidDeathsUpdated
group by population, location
order by 1,2


-- Let's break things down by continent
-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeathsUpdated
Where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeathsUpdated
Where continent is not null
--Group by date
order by 1,2;

-- Look at Vaccinations table and join to covid table
-- Looking at Total Population vs Vaccinations
--one of the code chunks where you need to convert new_vaccinations column to integer, the sum value now has exceeded 2,147,483,647. So instead of converting it to "int", you will need to convert to "bigint"

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated, 
(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeathsUpdated dea
Join PortfolioProject..CovidVaccinationsUpdated vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3;

--need to use a CTE or temp table for above ^^ to work


-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeathsUpdated dea
Join PortfolioProject..CovidVaccinationsUpdated vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeathsUpdated dea
Join PortfolioProject..CovidVaccinationsUpdated vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null AND dea.location like '%states%'
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Use PortfolioProject
Go
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeathsUpdated dea
Join PortfolioProject..CovidVaccinationsUpdated vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
