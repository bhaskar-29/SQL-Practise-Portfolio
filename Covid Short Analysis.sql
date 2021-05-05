select * 
from Covid_SQL_Portfolio..covid_deaths
order by 3, 4

--select * 
--from Covid_SQL_Portfolio..covid_vaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from Covid_SQL_Portfolio..covid_deaths
order by 1,2


-- Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathCasePct
from Covid_SQL_Portfolio..covid_deaths
where location = 'India'
order by 1,2 desc


--Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathCasePct
--from Covid_SQL_Portfolio..covid_deaths
--where location like '%states%'
--order by 1,2 desc

-- Pct of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as CasesPerPopulation
from Covid_SQL_Portfolio..covid_deaths
where location like '%india%'
order by 1,2 desc

-- Countires with Highest Infection Rates compared to population
Select location, population, max(total_cases) as HighestInfectionCount,  max((total_cases/population)*100) as CasesPerPopulation
from Covid_SQL_Portfolio..covid_deaths
group by location, population
order by 4 desc

-- Highest Death Count per Population
Select location, population, max(cast(total_deaths as int)) TotalDeaths, max(cast(total_deaths as int)/population) DeathtoPopulation
from Covid_SQL_Portfolio..covid_deaths
where continent is not null
group by location, population
order by 3 desc

-- Highest Death Count per Population for Continents
Select location, sum(population) Tot_Population, max(cast(total_deaths as int)) TotalDeaths, max(cast(total_deaths as int)/population) DeathtoPopulation
from Covid_SQL_Portfolio..covid_deaths
where continent is null and location <> 'World'
group by location
order by 3 desc

-- Global Level Timeline

select date, sum(new_cases) NewCases, sum(cast(new_deaths as int)) NewDeaths
from Covid_SQL_Portfolio..covid_deaths
where continent is not null
group by date
order by date desc

select date, avg(new_cases) NewCases, avg(cast(new_deaths as int)) NewDeaths
from Covid_SQL_Portfolio..covid_deaths
where continent is not null
group by date
order by date desc

-- Total Population vs Vaccination 

Select dea.continent, dea.location, dea.date, dea.population, vac.total_vaccinations
from Covid_SQL_Portfolio..covid_deaths dea
join Covid_SQL_Portfolio..covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and dea.location like 'India'
order by 2, 3

-- Running Total
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as int)) over (Partition by	dea.location order by dea.location, dea.date) NewVaccinationRunningTotal
from Covid_SQL_Portfolio..covid_deaths dea
join Covid_SQL_Portfolio..covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null -- and dea.location like 'India'
order by 2, 3


-- Using CTE

with PopvsVac (Continent, Location, Date, Population, NewVac, NewVacRunningTotal)
as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as int)) over (Partition by	dea.location order by dea.location, dea.date) NewVaccinationRunningTotal
from Covid_SQL_Portfolio..covid_deaths dea
join Covid_SQL_Portfolio..covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null -- and dea.location like 'India'
--order by 2, 3
)
Select *, (NewVacRunningTotal/Population)*100
From PopvsVac

-- Using Temp Table 

Drop Table if exists #PctPopVaccinated
Create Table #PctPopVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime, 
Population numeric, 
NewVac numeric, 
NewVacRunningTotal numeric
)

Insert into #PctPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as int)) over (Partition by	dea.location order by dea.location, dea.date) NewVaccinationRunningTotal
from Covid_SQL_Portfolio..covid_deaths dea
join Covid_SQL_Portfolio..covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null -- and dea.location like 'India'
--order by 2, 3


Select *, (NewVacRunningTotal/Population)*100
From #PctPopVaccinated
Go 

-- Creating View for Viz

Drop View if exists PctPopVaccinatedNew 
Go

CREATE VIEW PctPopVaccinatedNew as

(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(cast(vac.new_vaccinations as int)) over (Partition by	dea.location order by dea.location, dea.date) NewVaccinationRunningTotal
from Covid_SQL_Portfolio..covid_deaths dea
join Covid_SQL_Portfolio..covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
-- and dea.location like 'India'
-- order by 2, 3
)
Go


Select *
From PctPopVaccinatedNew