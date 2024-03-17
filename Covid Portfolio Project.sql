Select *
From PortfolioProject..CovidDeaths
where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
Order by 1,2

--Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--where location like '%Pakistan%'
Order by 1,2

--Total Cases vs Population
Select location, date, population, total_cases, (total_cases/population)*100 as ContractionPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--where location like'%Pakistan%'
Order by 1,2

--Countries with the Highest Infection count
Select location, population, Max(total_cases) as HighestContractionCount, Max((total_cases/population))*100 as HighestContractionPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
Order by HighestContractionPercentage Desc

--Countries with Highest Death count
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount Desc

--Continents with Highest Death count
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount Desc

--Global Numbers
Select Sum(new_cases) as TotalCases, Sum(new_deaths) as TotalDeaths, (Sum(new_deaths)/Sum(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Order by 1,2

--Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(bigint, new_vaccinations)) over (partition by dea.location order by dea.location, convert(date, dea.date)) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location=vac.location and dea.date=vac.date 
where dea.continent is not null
Order by 2,3

--Using CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(bigint, new_vaccinations)) over (partition by dea.location order by dea.location, convert(date, dea.date)) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location=vac.location and dea.date=vac.date 
where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Using Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(bigint, new_vaccinations)) over (partition by dea.location order by dea.location, convert(date, dea.date)) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location=vac.location and dea.date=vac.date 
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 as PercentRollingPeopleVaccinated
From #PercentPopulationVaccinated

--Creating View to store data for later visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(bigint, new_vaccinations)) over (partition by dea.location order by dea.location, convert(date, dea.date)) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location=vac.location and dea.date=vac.date 
where dea.continent is not null

Select *
From PercentPopulationVaccinated
