select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidVaccinations
where continent is not null
order by 3,4

--data to be selected - LOCATION
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--total cases and total deaths
--chances of dying
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as deathPecentage
from PortfolioProject..CovidDeaths
where location like '%canada%' and continent is not null
order by 1,2


--total cases vs population
--population contracted covid
select location, date, total_cases, new_cases, total_deaths, population, (total_cases/population)*100 as casesPecentage
from PortfolioProject..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2


-- infection rate vs population
select location, population, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population))*100 as 
	PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%canada%' and continent is not null
group by location, population
order by 4 desc

--death rate vs population
select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where  continent is not null
group by location, population
order by TotalDeathCount desc


--data to be selected - CONTINENT

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where  continent is not null
group by continent
order by TotalDeathCount desc

--Facts check
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where  continent is null
group by location
order by TotalDeathCount desc

--continent with the highest deathCount per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where  continent is not null
group by continent
order by TotalDeathCount desc

--Numbers globally
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as deathPecentage
from PortfolioProject..CovidDeaths
where  continent is not null
order by 1,2

select date, sum(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, sum(new_cases)/SUM(cast(new_deaths as int))
	as DeathPecentage
from PortfolioProject..CovidDeaths
where  continent is not null
group by date
order by 1,2

--total new cases vs total deaths
select sum(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, SUM(cast(new_deaths as int))/sum(new_cases)*100
	as DeathPecentage

where  continent is not null
order by 1,2


--joining covidDeaths and covidVaccinations tables
--total population vs vaccinations

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, 
dea.Date) as TotalPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
 on 
	dea.location = vac.location and 
	dea.date = vac.date
	where  dea.continent is not null 
	order by 2,3

	--use CTE table

	with PopvsVac (continent, Location, Date, Population, New_Vaccinations, TotalPeopleVaccinated)
	as
	(
	select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, 
	dea.Date) as TotalPeopleVaccinated
	from PortfolioProject..CovidDeaths dea
	join  PortfolioProject..CovidVaccinations vac
	 on 
		dea.location = vac.location and 
		dea.date = vac.date
		where  dea.continent is not null 
		--order by 2,3
		)
	select*,(TotalPeopleVaccinated/Population) as PopulationVaccinated
	From PopvsVac

	--Temp Table
	DROP Table if exists #PercentPopulationVaccinated
	create table #PercentPopulationVaccinated
	(
	continent nvarchar(255), 
	location nvarchar(255), 
	date time, 
	population numeric,
	New_vaccinations numeric,
	TotalPeopleVaccinated numeric
	)


	insert into #PercentPopulationVaccinated
	select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, 
	dea.Date) as TotalPeopleVaccinated
	from PortfolioProject..CovidDeaths dea
	join  PortfolioProject..CovidVaccinations vac
	 on 
		dea.location = vac.location and 
		dea.date = vac.date
		where  dea.continent is not null 
		--order by 2,3

	select*,(TotalPeopleVaccinated/Population) as PopulationVaccinated
	From #PercentPopulationVaccinated


	--View creating for data visualisation
	create view PercentPopulationVaccinated as
	select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, 
	dea.Date) as TotalPeopleVaccinated
	from PortfolioProject..CovidDeaths dea
	join  PortfolioProject..CovidVaccinations vac
	 on 
		dea.location = vac.location and 
		dea.date = vac.date
		where  dea.continent is not null 
		--order by 2,3

		select *
		from PercentPopulationVaccinated
