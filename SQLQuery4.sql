
--Tables details

SELECT * 
  FROM [PortfolioProject].[dbo].[Covid_Deaths]
 

SELECT COUNT(*) AS TotalRows
FROM [PortfolioProject].[dbo].[Covid_Deaths]

SELECT COUNT(*) AS TotalRows
FROM [PortfolioProject].[dbo].[Covid_Vaccination]

-- distinct count of continents and countries(location)

select continent,count(distinct(continent)) as count
from [PortfolioProject].[dbo].[Covid_Deaths]
group by continent
order by continent

select location, count(distinct(location)) as count
from [PortfolioProject].[dbo].[Covid_Vaccination]
--where continent is not null
group by location
order by location


--creating stored procedure with the data we are using for this analysis

CREATE PROCEDURE CovidDetails AS 
  	(SELECT [continent]
		  ,[location]
		  ,[date]
		  ,[population]
		  ,[total_cases]
		  ,[new_cases]
		  ,[total_deaths]
		  ,[new_deaths]
		  ,[hosp_patients]
		  ,[icu_patients]
       
	  FROM [PortfolioProject].[dbo].[Covid_Deaths])

	--executing procedure  

  exec CovidDetails

   -- date wise covid details

  SELECT location, date, population,total_cases,total_deaths
		  ,new_cases,new_deaths	
  FROM [PortfolioProject].[dbo].[Covid_Deaths]
  order by location, date
   


--  death percentage -location & continent wise based on totalcase, total death 


  SELECT location, sum(convert(float,new_cases)) as TotalCases,sum(convert(float,new_deaths)) as TotalDeaths
		  ,concat(round(sum(CONVERT(float, new_deaths)) / NULLIF(sum(CONVERT(float, new_cases)), 0)*100 ,2), '%')as DeathPercentage
  FROM [PortfolioProject].[dbo].[Covid_Deaths]
  WHERE continent is not null
  group by location
  order by DeathPercentage desc


  SELECT continent, sum(convert(float,new_cases)) as TotalCases
		  ,sum(convert(float,new_deaths)) as TotalDeaths
		  ,concat(round(sum(CONVERT(float, new_deaths)) / NULLIF(sum(CONVERT(float, new_cases)), 0)*100 ,2), '%')as DeathPercentage
  FROM [PortfolioProject].[dbo].[Covid_Deaths]
  WHERE continent is not null
  group by continent
  order by DeathPercentage desc

  --countires with highest number of death and cases

  SELECT location
		  ,max(cast(total_cases as float)) as HighestNewCase
		  ,max(cast(total_deaths as float)) as HighestDeathCase
  FROM [PortfolioProject].[dbo].[Covid_Deaths]
  WHERE continent is not null
  group by location
  order by HighestNewCase desc
   
  
  
--new cases Vs new deaths , calculating death percentage

 
SELECT  location,population,sum(new_cases) AS TotalNewcases,sum(new_deaths) AS TotalNewDeaths
		,concat(round(sum(new_deaths)/nullif(sum(new_cases),0)* 100,2),'%') AS PercentageOfDeath
FROM [PortfolioProject].[dbo].[Covid_Deaths]
WHERE continent is not null
group by location, population
order by PercentageOfDeath desc


SELECT  location,population,sum(new_cases) AS TotalNewcases,sum(new_deaths) AS TotalNewDeaths
		,concat(round(sum(new_deaths)/sum(new_cases)* 100,2),'%') AS PercentageOfDeath
FROM [PortfolioProject].[dbo].[Covid_Deaths]
WHERE location like 'India' 
group by location, population
order by PercentageOfDeath desc

  --location wise ratios of infection and death
  -- converting null vlues to zero
  --ratios by condition

  SELECT location, population
		,coalesce(SUM(convert(float,new_cases)),0) AS TotalNewCases
		,coalesce(SUM(convert(float,new_deaths)),0) AS TotalNewDeathCases
		,coalesce(round(SUM(convert(float,new_cases) )/population *100,2),0)  As InfectionRatioPercent
		,coalesce(round(SUM(convert(float,new_deaths))/population *100,2),0)  As DeathPercentage
  FROM [PortfolioProject].[dbo].[Covid_Deaths]
  where continent is not null
  --WHERE  location = 'India' OR location like '%united%'
  GROUP BY location,population
 -- order by DeathPercentage desc
  order by InfectionRatioPercent desc

  -- highest infection and death percent based on total case , deaths per population

  SELECT location, population,date
		--,coalesce(MAX(CAST(total_cases as float)),0) AS  HighestNoInfection
		,coalesce(MAX(CAST(total_deaths as float)),0) As HighestNoOfDeath
		--,coalesce(MAX(CAST(total_cases as float)/population) *100,0)  As HighestInfectionPercent
		,coalesce(MAX(CAST(total_deaths as float)/population )*100,0)As HighestDeathPercent
  FROM [PortfolioProject].[dbo].[Covid_Deaths]
  WHERE  continent is not null
  GROUP BY location,population,date
 -- order by HighestInfectionPercent desc
  ORDER BY HighestDeathPercent desc


   --death and infection percentage based on total population, new cases and deaths by continent 

 SELECT continent, SUM(population) AS TotalPopulation
		,SUM(CAST(new_cases as bigint)) AS TotalNewCases
		,SUM(CAST(new_deaths as bigint)) AS TotalNewDeathCases
		,round(SUM(CAST(new_cases as float))/SUM(population)*100,5) As InfectionRatioByPopulation
		,round(SUM(CAST(new_deaths as float))/SUM(population)*100,5) As DeathPercentByPopulation
		,round(SUM(CAST(new_deaths as float))/SUM(CAST(new_cases as float))*100,5) AS DeathPercentByCase
  FROM [PortfolioProject].[dbo].[Covid_Deaths]
   WHERE continent is not null
  GROUP BY continent
  order by InfectionRatioByPopulation desc

  SELECT continent, SUM(population) AS TotalPopulation
		,max(CAST(total_cases as bigint)) AS HighestNoOfCases
		,max(CAST(total_deaths as bigint)) AS HighestNoOfDeath
		,round(max(CAST(total_cases as float))/SUM(population)*100,5) As InfectionRatioByPopulation
		,round(max(cast(total_deaths as float))/SUM(population)*100,5) As DeathPercentByPopulation
		,round(max(CAST(total_deaths as float))/max(CAST(total_cases as float))*100,5) AS DeathPercentByCase
  FROM [PortfolioProject].[dbo].[Covid_Deaths]
   WHERE continent is not null
  GROUP BY continent
  order by InfectionRatioByPopulation desc


  --average cases

 SELECT continent, location,
 ROUND(AVG((total_cases / population) * 100), 2) AS AvgOfInfectedPopulation
 FROM [PortfolioProject].[dbo].[Covid_Deaths]
 --where continent is not null
 GROUP BY continent,location
 ORDER BY AvgOfInfectedPopulation  DESC

   
 
  -- changing data types using cast & convert
  -- changing null values to zero

 
  SELECT continent, location
		,SUM(COALESCE(CONVERT(INT,new_cases),0)) AS TotalNewCovidCases
		,SUM(COALESCE(CAST(new_deaths as int),0)) AS TotalNewDeathCases
		
  FROM [PortfolioProject].[dbo].[Covid_Deaths]
  WHERE continent is not null
  group by continent,location
  order by continent




  --continent wise details(continent contains null & without null)

SELECT continent
		,SUM(population) AS TotalPopulation
		,SUM(CONVERT(INT,new_cases)) AS TotalCovidCases
		,SUM(CONVERT(INT,new_deaths)) AS TotalDeathCases
  FROM [PortfolioProject].[dbo].[Covid_Deaths]
  where continent is not null
  group by continent--,total_cases,total_deaths
  order by continent

  


--Details of continent & country with highest death cases 

SELECT  top(1)continent,location,population, total_cases,convert(float,total_deaths) as HighestDeathCase
FROM [PortfolioProject].[dbo].[Covid_Deaths]
WHERE continent is not null
group by continent,location,population,total_cases,total_deaths
order by  HighestDeathCase desc


SELECT continent,location
		,SUM(population) AS TotalPopulation
		,MAX(CAST(total_cases as bigint)) AS HighestNumberOfTotalCases
		,MAX(CAST(total_deaths AS BIGINT)) AS HighestNoOfTotalDeaths
		,MAX(CAST(new_cases as bigint)) AS HighestNoOfNewCases
		,MAX(CAST(new_deaths as bigint)) AS HighestNoOfNewDeathCases
FROM [PortfolioProject].[dbo].[Covid_Deaths]
WHERE continent is not null
group by continent,location


--percentage of hospitalized cases per continent


SELECT continent,sum(CAST(hosp_patients AS float)) as total_hosp_patients
	, sum(CAST(icu_patients AS float)) as total_icu_patients
	,round(sum(convert(float,icu_patients))/sum(convert(float,hosp_patients))*100,2) AS PercentageOfHospitalizedCases
FROM [PortfolioProject].[dbo].[Covid_Deaths]
WHERE continent is not null and hosp_patients is not null and total_cases is not null
GROUP BY continent
ORDER BY PercentageOfHospitalizedCases desc

--percentage of hospitalized cases per location


--SELECT location,MAX(CAST(hosp_patients AS float)) AS hosp_pateints_highest_count 
--	, MAX(CAST(icu_patients AS float))as icu_pateints_highest_count
--	,round(MAX(CAST(icu_patients AS float))/max(CAST(hosp_patients AS float))*100,2) AS PercentageOfHospitalizedCases
--FROM [PortfolioProject].[dbo].[Covid_Deaths]
--WHERE continent is not null and hosp_patients is not null and total_cases is not null
--GROUP BY location
--ORDER BY PercentageOfHospitalizedCases desc


SELECT location,sum(CAST(hosp_patients AS float)) as total_hosp_patients
	, sum(CAST(icu_patients AS float)) as total_icu_patients
	,round(sum(convert(float,icu_patients))/sum(convert(float,hosp_patients))*100,2) AS PercentageOfHospitalizedCases
FROM [PortfolioProject].[dbo].[Covid_Deaths]
WHERE continent is not null and hosp_patients is not null and total_cases is not null
GROUP BY location
ORDER BY PercentageOfHospitalizedCases desc



--Covid Vaccination data

SELECT * 
  FROM [PortfolioProject].[dbo].[Covid_Vaccination]

create procedure VaccinationTable as
select continent,location,date,total_tests,new_tests,total_vaccinations,people_vaccinated,new_vaccinations
from PortfolioProject.dbo.Covid_Vaccination

exec  VaccinationTable


--details of new covid measures in the year 2020-23 using subquery in different method

--2020-2021 covid measures
-- using WITH clause(CTE)

with year20_21 as 
				(select location,date,new_tests,new_vaccinations
			     from PortfolioProject.dbo.Covid_Vaccination
				 where DATEPART(year,date) between 2020 and 2021
				 group by location,date,new_tests,new_vaccinations) 

select d.continent,DATEPART(year,d.date) as year,d.location,d.population
		,sum(convert(float,d.new_cases))as Cases_20_21,sum(convert(float,d.new_deaths))as Deaths_20_21
		,sum(convert(float,y.new_tests))as Tests_20_21,sum(convert(float,y.new_vaccinations))as New_Vaccinations_20_21
from PortfolioProject.dbo.Covid_Deaths AS d
inner join year20_21 y
	on d.location = y.location
	and d.date = y.date
where d.continent is not null 
group by DATEPART(year,d.date), d.continent,d.location,d.population
order by d.continent, year

--using subquery

select d.continent,DATEPART(year,d.date) as year,d.location,d.population
		,sum(convert(float,d.new_cases))as Cases_20_21,sum(convert(float,d.new_deaths))as Deaths_20_21
		,sum(convert(float,v.new_tests))as Tests_20_21,sum(convert(float,v.new_vaccinations))as New_Vaccinations_20_21
from PortfolioProject.dbo.Covid_Deaths AS d
inner join
PortfolioProject.dbo.Covid_Vaccination AS v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null 
	  and d.date in (select date
				     from PortfolioProject.dbo.Covid_Vaccination
					 where DATEPART(year,date) between 2020 and 2021
					 group by  date)
group by DATEPART(year,d.date), d.continent,d.location,d.population--,d.new_cases,d.new_deaths,v.new_tests,v.new_vaccinations

order by d.continent,year	 


--2022-2023 covid measures using WITH clause

with year22_23 as 
				(select location,date,new_tests,new_vaccinations
			     from PortfolioProject.dbo.Covid_Vaccination
				 where DATEPART(year,date) between 2022 and 2023
				 group by location,date,new_tests,new_vaccinations) 

select d.continent,DATEPART(year,d.date) as year,d.location,d.population
		,sum(convert(float,d.new_cases))as Cases_22_23,sum(convert(float,d.new_deaths))as Deaths_22_23
		,sum(convert(float,y.new_tests))as Tests_22_23,sum(convert(float,y.new_vaccinations))as New_Vaccinations_22_23
from PortfolioProject.dbo.Covid_Deaths AS d
inner join year22_23 y
	on d.location = y.location
	and d.date = y.date
where d.continent is not null 
group by DATEPART(year,d.date), d.continent,d.location,d.population
order by d.continent, year

-- year 2022-2023 daily covid details

with year22_23 as 
				(select location,date,new_tests,new_vaccinations
			     from PortfolioProject.dbo.Covid_Vaccination
				 where DATEPART(year,date) between 2022 and 2023
				 group by location,date,new_tests,new_vaccinations) 

select d.continent,d.date,d.location,d.population,d.new_cases,d.new_deaths,y.new_tests,y.new_vaccinations
from PortfolioProject.dbo.Covid_Deaths AS d
inner join year22_23 y
	on d.location = y.location
	and d.date = y.date
where d.continent is not null 
order by date

-- using subquery

select d.continent,DATEPART(year,d.date) as year,d.location,d.population
		,sum(convert(float,d.new_cases))as Cases_22_23,sum(convert(float,d.new_deaths))as Deaths_22_23
		,sum(convert(float,v.new_tests))as Tests_22_23,sum(convert(float,v.new_vaccinations))as New_Vaccinations_22_23
from PortfolioProject.dbo.Covid_Deaths AS d
inner join
PortfolioProject.dbo.Covid_Vaccination AS v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null 
	  and d.date in (select date
				     from PortfolioProject.dbo.Covid_Vaccination
					 where DATEPART(year,date) between 2022 and 2023
					 group by  date)
group by DATEPART(year,d.date), d.continent,d.location,d.population
order by d.continent,year	

	
--Rolling vaccination

select d.continent,d.location,d.date,d.population,v.new_vaccinations
	 ,sum(convert(float,v.new_vaccinations)) over (partition by d.location order by d.date ) as RollingVaccination
from PortfolioProject.dbo.Covid_Deaths AS d
join
PortfolioProject.dbo.Covid_Vaccination AS v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null 
group by d.continent,d.location,d.date,d.population,v.new_vaccinations
order by d.location,d.date



--WITH clause (CTE-common table expression)

with VacPopulation(continent,location,year,population--,people_vaccinated,new_vaccinations, total_vaccinations
	,RollingVaccination,HighestCountOfPeopleVaccinated) 
as
(
select d.continent,d.location,datepart(year,d.date),d.population
	 --,v.people_vaccinated,v.new_vaccinations, v.total_vaccinations
	 ,sum(convert(float,v.new_vaccinations))
	 over (partition by d.location order by datepart(year,d.date) ) as RollingVaccination
	 ,max(convert(float, v.people_vaccinated))
	  over (partition by d.location order by datepart(year,d.date) ) as HighestCountOfPeopleVaccinated
from PortfolioProject.dbo.Covid_Deaths AS d
join
PortfolioProject.dbo.Covid_Vaccination AS v
	on d.location = v.location
	 and d.date = v.date
where d.continent is not null 
group by d.continent,d.location,d.date,d.population,v.people_vaccinated,v.new_vaccinations, v.total_vaccinations
)

select * 
		,round((RollingVaccination/population) *100,2) as PercentOfVaccPerPopulation
		, round((HighestCountOfPeopleVaccinated/population) *100,2) as PercentHighestCountOfPeopleVaccinated
from VacPopulation
order by location, year desc


--temporary table

drop table  if exists #PercentageOfVaccinatedPeople
create table #PercentageOfVaccinatedPeople
			( continent nvarchar(255)
			,location nvarchar(255)
			,date datetime
			,population numeric
			,new_vaccinations numeric
			,RollingCountOfVaccination numeric
			)

insert into #PercentageOfVaccinatedPeople

select d.continent,d.location,d.date,d.population,v.new_vaccinations
	 ,sum(convert(float,v.new_vaccinations))over (partition by d.location order by d.date) as RollingCountOfVaccination
from PortfolioProject.dbo.Covid_Deaths AS d
inner join
PortfolioProject.dbo.Covid_Vaccination AS v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null 
group by d.continent,d.location,d.date,d.population,v.new_vaccinations--,v.total_vaccinations
--order by d.location, d.date


select *,concat(round((RollingCountOfVaccination/population)*100,2),'%')as RollingVaccPercentage
from #PercentageOfVaccinatedPeople


--creating views

create view VaccinatedPeoplePercentage as

select d.continent,d.location,d.date,d.population,v.new_vaccinations
	 ,sum(convert(float,v.new_vaccinations))over (partition by d.location order by d.date) as RollingCountOfVaccination
from PortfolioProject.dbo.Covid_Deaths AS d
inner join
PortfolioProject.dbo.Covid_Vaccination AS v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null 
group by d.continent,d.location,d.date,d.population,v.new_vaccinations--,v.total_vaccinations
--order by d.location, d.date




