select * 
from portofolioproject ..CovidDeaths$ 
where continent is not null
order by 3,4 

select * 
from portofolioproject ..Covidvacc$ 
where continent is not null
order by 3,4

-- select data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From portofolioproject ..CovidDeaths$ 
where continent is not null
order by 1,2

-- Looking at Total cases vs total deaths
-- shows likelihood of dying if you interact covid in ur country

Select Location, date, total_cases, total_deaths,(total_deaths / total_cases ) * 100 as Deathpercentage
From portofolioproject ..CovidDeaths$ 
Where location like '%states%'
and continent is not null
order by 1,2

--lookaing at total cases vs populations
-- shows what percentage of pop got covid

Select Location, date,population , total_cases,(total_cases / population  ) * 100 as Deathpercentage
From portofolioproject ..CovidDeaths$ 
-- Where location like '%states%'
where continent is not null
order by 1,2

-- looking at countries with highest infection rate comapared to population

Select Location,population , MAX(total_cases) as highinfectioncount ,(MAX(total_cases) / population  ) * 100 as percentpopinfected
From portofolioproject ..CovidDeaths$ 
-- Where location like '%states%'
where continent is not null
Group by location , population 
order by percentpopinfected desc

-- showing countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as Totaldeathcount 
From portofolioproject ..CovidDeaths$ 
-- Where location like '%states%'
where continent is not null
Group by location  
order by Totaldeathcount  desc

-- lets break this by continent


Select continent  , MAX(cast(total_deaths as int)) as Totaldeathcount 
From portofolioproject ..CovidDeaths$ 
-- Where location like '%states%'
where continent is not null
Group by continent   
order by Totaldeathcount  desc

-- showing continents with highest death count per population

Select continent  , MAX(cast(total_deaths as int)) as Totaldeathcount 
From portofolioproject ..CovidDeaths$ 
-- Where location like '%states%'
where continent is not null
Group by continent   
order by Totaldeathcount  desc

--GLOBAL NUMBERS

Select  SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/ SUM(new_cases) * 100 as Deathpercentage
From portofolioproject ..CovidDeaths$ 
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2 

-- looking at total population vs vaccinations

Select d.continent,d.location ,d.date, d.population
, v.new_vaccinations , sum(cast(v.new_vaccinations as int)) OVER (Partition by d.location, d.date) as rollingpeoplevaccinated
-- ,(rollingpeoplevaccinated / population) * 100
from portofolioproject ..CovidDeaths$ d 
Join portofolioproject ..Covidvacc$ v
On d.location = v.location 
and d.date = v.date 
Where d.continent is not null
order by 2, 3

-- use CTE

With popvsvac (continent, location, date, population,new_vaccinations,rollingpeoplevaccinated)
as
(
Select d.continent,d.location ,d.date, d.population
, v.new_vaccinations , sum(cast(v.new_vaccinations as int)) OVER (Partition by d.location, d.date) as rollingpeoplevaccinated
-- ,(rollingpeoplevaccinated / population) * 100
from portofolioproject ..CovidDeaths$ d 
Join portofolioproject ..Covidvacc$ v
On d.location = v.location 
and d.date = v.date 
Where d.continent is not null
-- order by 2,3
)
select*,(rollingpeoplevaccinated / population) * 100 from popvsvac 

-- Temp table


DROP table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)


Insert into #percentpopulationvaccinated
Select d.continent,d.location ,d.date, d.population
, v.new_vaccinations , sum(cast(v.new_vaccinations as int)) OVER (Partition by d.location, d.date) as rollingpeoplevaccinated
-- ,(rollingpeoplevaccinated / population) * 100
from portofolioproject ..CovidDeaths$ d 
Join portofolioproject ..Covidvacc$ v
On d.location = v.location 
and d.date = v.date 
Where d.continent is not null
-- order by 2,3

select*,(rollingpeoplevaccinated / population) * 100
from #percentpopulationvaccinated

-- creating view to store data for visualizations

create view percentpopulationvaccinated as
Select d.continent,d.location ,d.date, d.population
, v.new_vaccinations , sum(cast(v.new_vaccinations as int)) OVER (Partition by d.location, d.date) as rollingpeoplevaccinated
-- ,(rollingpeoplevaccinated / population) * 100
from portofolioproject ..CovidDeaths$ d 
Join portofolioproject ..Covidvacc$ v
On d.location = v.location 
and d.date = v.date 
Where d.continent is not null
-- order by 2,3


select * 
from  percentpopulationvaccinated




