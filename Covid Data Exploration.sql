Select * from [SQL PROJECT]..CovidDeaths
where continent is not null
order by 3,4

Select * from [SQL PROJECT]..CovidVaccination
order by 3,4

--select the data that we are goiing to be using


Select location, date, total_cases,new_cases, total_deaths,population
from [SQL PROJECT]..CovidDeaths
where continent is not null
order by 1, 2

--looking at total_cases vs total_death

Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from [SQL PROJECT]..CovidDeaths
where continent is not null
order by 1,2

Select location, date, population, total_cases,(total_cases/population)*100 as Affected_people_by_Covid
from [SQL PROJECT]..CovidDeaths
where location like  'India'
and continent is not null
order by 1,2

--countris with highest covid affected rate compare to population

Select location, population, max(total_cases),max(total_cases/population)*100 as percentPopulationInfected
from [SQL PROJECT]..CovidDeaths
--where location like  'India'
where continent is not null
group by location,population
order by percentPopulationInfected desc

--showing countries with highest death count percentage 

Select location, max(cast(total_deaths as int)) as total_death_count 
from [SQL PROJECT]..CovidDeaths
--where location like  'India' (use the country name here)
where continent is not null
group by location
order by total_death_count  desc


--global numbers of the death percentage

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percent
from [SQL PROJECT]..CovidDeaths
where continent is not null
group by date
order by 1,2

-- getting total numbers in world

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percent
from [SQL PROJECT]..CovidDeaths
where continent is not null
order by 1,2

--total population vs the total vaccination around the world

select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as commulative_data_vaccination
from [SQL PROJECT]..CovidDeaths dea
join [SQL PROJECT]..CovidVaccination as vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.date is not null
order by 2,3


--getting a CTE(CommonTableExpression)

with popvsvac (continent, location, date, population, new_vaccination,commulative_data_vaccination)
as
(select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as commulative_data_vaccination
from [SQL PROJECT]..CovidDeaths dea
join [SQL PROJECT]..CovidVaccination as vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.date is not null
)
select*, commulative_data_vaccination/population *100 as percentageVaccinated
from popvsvac

--MAKING THE TEMPORARY TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
commulative_data_vaccination numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as commulative_data_vaccination
From [SQL PROJECT]..CovidDeaths dea
Join [SQL PROJECT]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (commulative_data_vaccination/Population)*100
From #PercentPopulationVaccinated


--Creating a View to sotre data for later visualisation

Create view PercentagePopulationvaccinated as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as commulative_data_vaccination
from [SQL PROJECT]..CovidDeaths dea
join [SQL PROJECT]..CovidVaccination as vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.date is not null


Select * from PercentagePopulationvaccinated -- this is what I use for visualization 