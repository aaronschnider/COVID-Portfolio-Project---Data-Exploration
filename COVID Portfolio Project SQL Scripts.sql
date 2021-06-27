Select *
From Covid_Portfolio_Project ..CovidDeaths
Where continent is NOT NULL
order by 3,4

--Select *
--From Covid_Portfolio_Project ..CovidVaccinations
--Where continent is NOT NULL
--order by 3,4

-- Select data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From Covid_Portfolio_Project..CovidDeaths
Where continent is NOT NULL
order by 1,2


-- Looking at the Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid_Portfolio_Project..CovidDeaths
Where continent is NOT NULL
and location like '%States%'
order by 1,2

-- Looking at Total Cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From Covid_Portfolio_Project..CovidDeaths
Where continent is NOT NULL
and location like '%States%'
order by 1,2

-- Countries with highest cases compared to population
Select location, MAX(total_cases) as HighestCase, population, MAX((total_cases/population))*100 as HighestCasePercentage
From Covid_Portfolio_Project..CovidDeaths
Where continent is NOT NULL
Group by location, population
order by 4 Desc

-- BREAKING DOWN BY CONTINENT

-- Continents with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid_Portfolio_Project..CovidDeaths
Where continent is NULL
Group by location
order by 2 Desc

-- Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Covid_Portfolio_Project..CovidDeaths
Where continent is NOT NULL
order by 1,2


-- Looking at Total Population vs Vaccinations
--USE CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingTotalVaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as int)) OVER (Partition By d.location Order by d.location, d.date) as RollingTotalVaccinated
--, (RunningTotalVaccinated / population) * 100
From Covid_Portfolio_Project..CovidDeaths d
Join Covid_Portfolio_Project..CovidVaccinations v
    ON d.location = v.location
	and d.date = v.date
Where d.continent is NOT NULL
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopVsVac
Order by 2,3


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations int,
RollingTotalVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as int)) OVER (Partition By d.location Order by d.location, d.date) as RollingTotalVaccinated
--, (RunningTotalVaccinated / population) * 100
From Covid_Portfolio_Project..CovidDeaths d
Join Covid_Portfolio_Project..CovidVaccinations v
    ON d.location = v.location
	and d.date = v.date
Where d.continent is NOT NULL

Select * , (RollingTotalVaccinated/Population)*100
From #PercentPopulationVaccinated
Order by 2,3

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as int)) OVER (Partition By d.location Order by d.location, d.date) as RollingTotalVaccinated
--, (RunningTotalVaccinated / population) * 100
From Covid_Portfolio_Project..CovidDeaths d
Join Covid_Portfolio_Project..CovidVaccinations v
    ON d.location = v.location
	and d.date = v.date
Where d.continent is NOT NULL
--order by 2,3

Select *
From PercentPopulationVaccinated