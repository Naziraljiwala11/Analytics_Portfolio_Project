select * from Portfolio_project..CovidDeaths order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1,2;

-- Looking at total cases vs total deaths
-- shows the likehood of the person getting covid

select location, date, total_cases, total_deaths, ( total_deaths/total_cases )*100 as deathpercentage
from dbo.CovidDeaths
where location = 'India'
order by 1,2;

-- looking at total cases vs population
-- shows the percentage of population gets covid

select location, date, total_cases, population, ( total_cases/population )*100 as casepercentage
from dbo.CovidDeaths
-- where location = 'India'
order by 1,2;

-- looking for the maximum number of infections in different areas

select location, population, max(total_cases) as max_cases, max(( total_cases/population )*100) as max_case_percentage
from dbo.CovidDeaths
-- where location = 'India'
where continent is not null
group by location, population
order by max_cases desc;

-- looking for the maxi number of death count
-- total_deaths are in varchar but max works for int, float so we have to cast that

select location, max(cast(total_deaths as int)) as max_death
from dbo.CovidDeaths
where continent is not null
group by location
order by max_death desc;

-- Let's see things with the continent

select continent, max(cast(total_deaths as int)) as max_death
from dbo.CovidDeaths
where continent is not null
group by continent
order by max_death desc;

-- Let's check the continent with highest death rate

select continent, location, total_deaths
from dbo.CovidDeaths
where continent = 'Asia';

-- Global Numbers

select date, sum(new_cases) as total_new_cases, sum( cast(new_deaths as int)) as new_total_deaths, 
( sum( cast(new_deaths as int))/sum(new_cases) )*100 as new_death_percentage
from dbo.CovidDeaths
where continent is not null
group by date
order by date;

select sum(new_cases) as total_new_cases, sum( cast(new_deaths as int)) as new_total_deaths, 
( sum( cast(new_deaths as int))/sum(new_cases) )*100 as new_death_percentage
from dbo.CovidDeaths
where continent is not null;


-- looking for the total population vs. total vaccination

select cd.continent, cd.date, cd.location, cd.population, cv.new_vaccinations, 
sum( convert(int,cv.new_vaccinations) ) over ( partition by cd.location order by cd.date ) as rollingpoeplevaccination
from dbo.CovidDeaths cd
join dbo.CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null 
order by 1,3;

-- total percentage of vaccination done in each locations

select cd.continent, cd.date, cd.location, cd.population, cv.new_vaccinations, 
sum( convert(int,cv.new_vaccinations) ) over ( partition by cd.location order by cd.date ) as rollingpoeplevaccination,
( (sum( convert(int,cv.new_vaccinations) ) over ( partition by cd.location order by cd.date ))/cd.population )*100 
as total_per_vaccinated
from dbo.CovidDeaths cd
join dbo.CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null 
order by 1,3

-- use cte - contain equal row - Another method to do above query

with Popvsvac (continent, date, location, population, new_vaccinations, rollingpoeplevaccination)
as
(
select cd.continent, cd.date, cd.location, cd.population, cv.new_vaccinations, 
sum( convert(int,cv.new_vaccinations) ) over ( partition by cd.location order by cd.date ) as rollingpoeplevaccination
from dbo.CovidDeaths cd
join dbo.CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null 
)
select *, (rollingpoeplevaccination/population)*100
from Popvsvac;

-- Temp Table

drop table if exists #temp_pop_vac;

create table #temp_pop_vac (
continent nvarchar(255),
date datetime,
location nvarchar(255),
population numeric,
new_vaccinations numeric,
rollingpoeplevaccination numeric
)

insert into #temp_pop_vac
select cd.continent, cd.date, cd.location, cd.population, cv.new_vaccinations, 
sum( convert(int,cv.new_vaccinations) ) over ( partition by cd.location order by cd.date ) as rollingpoeplevaccination
from dbo.CovidDeaths cd
join dbo.CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null 
order by 1,3;

select *, max() ,(rollingpoeplevaccination/population)*100 as total_per_vac
from #temp_pop_vac;

