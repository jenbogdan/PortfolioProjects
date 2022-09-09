SELECT *
FROM COVIDProject..CovidDeaths
where continent is not null
ORDER BY 3,4

--Select data that we are going to be using


Select continent, Location, date, total_cases, new_cases, total_deaths, population
from COVIDProject..CovidDeaths
where continent is not null
--group by continent, location
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select continent, Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from COVIDProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select continent, Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from COVIDProject..CovidDeaths
-- where location like '%states%'
where continent is not null
order by 1,2


-- Looking at countries with highest infection rate compared to population

Select continent, Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from COVIDProject..CovidDeaths
-- where location like '%states%'
where continent is not null
Group by continent, Location, population
order by PercentPopulationInfected desc


-- Showing the countries with the highest death count per population
-- use CAST to change datatype for total_deaths to integer, currently varchar

Select continent, Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from COVIDProject..CovidDeaths
-- where location like '%states%'
where continent is not null
Group by continent, Location
order by TotalDeathCount desc


-- Let's break things down by continent

-- Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from COVIDProject..CovidDeaths
-- where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers in total

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
from COVIDProject..CovidDeaths
where continent is not null
order by 1,2

-- Global numbers by date

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
from COVIDProject..CovidDeaths
where continent is not null
group by date
order by 1,2


-- Join Vaccination table

-- looking at total population vs vaccinations


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from COVIDProject..CovidDeaths dea
join COVIDProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
from COVIDProject..CovidDeaths dea
join COVIDProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
from COVIDProject..CovidDeaths dea
join COVIDProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Use temp table


Drop table if exists #PercentPopulationVaccinated
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
from COVIDProject..CovidDeaths dea
join COVIDProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- creating view to store data for later viz

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
from COVIDProject..CovidDeaths dea
join COVIDProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *
from PercentPopulationVaccinated







