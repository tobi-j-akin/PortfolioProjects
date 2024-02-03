---- Daily percentage of cases that led to fatalities by country
SELECT
	location,date,total_cases,total_deaths,ROUND(total_deaths/total_cases*100,2) AS mortality_percentage
FROM
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$
WHERE
	total_cases IS NOT NULL
	AND total_deaths IS NOT NULL
	AND continent IS NOT NULL
ORDER BY 
	location, date;

-- View Creation
CREATE VIEW daily_mortality_percent_countries AS 
SELECT
	location,date,total_cases,total_deaths,ROUND(total_deaths/total_cases*100,2) AS mortality_percentage
FROM
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$
WHERE
	total_cases IS NOT NULL
	AND total_deaths IS NOT NULL
	AND continent IS NOT NULL;

---- Total number cases of COVID contraction VS population by country, date 
SELECT
	location, date, total_cases,population, ROUND((total_cases/population)*100, 4) contraction_rate
FROM 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$
WHERE
	total_cases IS NOT NULL 
	AND population IS NOT NULL
	AND continent IS NOT NULL
ORDER BY
	1,2;

-- View Creation
CREATE VIEW infection_rate_vs_pop_countries AS 
SELECT
	location, date, total_cases,population, ROUND((total_cases/population)*100, 4) contraction_rate
FROM 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$
WHERE
	total_cases IS NOT NULL 
	AND population IS NOT NULL
	AND continent IS NOT NULL;

---- Countries with highest peak COVID contraction rate 
SELECT
	location, MAX(total_cases) max_infection_count, MAX(ROUND((total_cases/population)*100, 4)) contraction_rate
FROM 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$
WHERE
	total_cases IS NOT NULL
	AND population IS NOT NULL
	AND continent IS NOT NULL
GROUP BY
	location
ORDER BY
	3 DESC;

-- View Creation
CREATE VIEW highest_peak_infection_rates_countries AS 
SELECT
	continent, MAX(ROUND((total_deaths/population)*100, 4)) peak_mortality_rate
FROM 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$
WHERE
	total_deaths IS NOT NULL
	AND population IS NOT NULL
	AND continent IS NOT NULL
GROUP BY
	continent;

---- Continents with highest peak COVID contraction rate
SELECT
	continent, MAX(total_cases) max_infection_count, MAX(ROUND((total_cases/population)*100, 4)) contraction_rate
FROM 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$
WHERE
	total_cases IS NOT NULL
	AND population IS NOT NULL
	AND continent IS NOT NULL
GROUP BY
	continent
ORDER BY
	3 DESC;

-- View Creation
CREATE VIEW highest_peak_infection_rates_continents AS 
SELECT
	continent, MAX(ROUND((total_deaths/population)*100, 4)) peak_mortality_rate
FROM 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$
WHERE
	total_deaths IS NOT NULL
	AND population IS NOT NULL
	AND continent IS NOT NULL
GROUP BY
	continent;


---- Countries with highest peak mortality counts
SELECT
	location, MAX(CAST(total_deaths as int)) max_mortality_count
FROM 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$
WHERE
	total_deaths IS NOT NULL
	AND continent IS NOT NULL
GROUP BY
	location
ORDER BY
	2 DESC;

-- View Creation
CREATE VIEW highest_peak_mortality_rates_countries AS 
SELECT
	location, MAX(CAST(total_deaths as int)) max_mortality_count
FROM 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$
WHERE
	total_deaths IS NOT NULL
	AND continent IS NOT NULL
GROUP BY
	location;

---- Continents with highest peak mortality counts
SELECT
	continent, MAX(CAST(total_deaths as int)) max_mortality_count
FROM 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$
WHERE
	total_deaths IS NOT NULL
	AND continent IS NOT NULL
GROUP BY
	continent
ORDER BY
	2 DESC;

-- View Creation
CREATE VIEW highest_peak_mortality_rates_continents AS 
SELECT
	continent, MAX(CAST(total_deaths as int)) max_mortality_count
FROM 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$
WHERE
	total_deaths IS NOT NULL
	AND continent IS NOT NULL
GROUP BY
	continent;

------Global numbers
----Rate of global deaths VS global cases 
SELECT
	date, SUM(CAST (new_deaths AS int)) total_deaths_globally
	, SUM(new_cases) total_cases_globally
	, ROUND(SUM(CAST (new_deaths AS int))/SUM(new_cases)*100, 1) global_deaths_vs_contracted
FROM
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$
WHERE
	new_cases IS NOT NULL
	AND continent IS NOT NULL
GROUP BY 
	date
ORDER BY 
	1,2;

-- View Creation
CREATE VIEW global_deaths_vs_global_cases AS 
SELECT
	continent, MAX(ROUND((total_deaths/population)*100, 4)) peak_mortality_rate
FROM 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$
WHERE
	total_deaths IS NOT NULL
	AND population IS NOT NULL
	AND continent IS NOT NULL
GROUP BY
	continent;

---- Percentage of population vaccinated  
--CTE 
WITH CTE_popVSVaccines (Continent, Location, Date, Population, New_Vaccinations, RollingPplVaccinated) AS
(SELECT
	CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
	,SUM(CAST (CovidVaccinations.new_vaccinations AS int)) 
	OVER (Partition by CovidVaccinations.location 
	ORDER BY CovidDeaths.location, CovidDeaths.date) rolling_count_new_vaccinations
--	, (rolling_count_new_vaccinations/population)*100
FROM 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$ CovidDeaths
JOIN 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidVaccinations$ CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	AND CovidDeaths.date = CovidVaccinations.date
WHERE
	CovidDeaths.continent IS NOT NULL
	AND population IS NOT NULL)

-- Calling for CTE 'popVSVaccines'
SELECT
	*
	, ROUND((RollingPplVaccinated/population)*100, 2) percent_pop_vaccinated
FROM
	CTE_popVSVaccines;

--TempTable
DROP TABLE IF EXISTS #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(Continent nvarchar(50), Location nvarchar(100), Date datetime, Population bigint, New_Vaccinations int, RollingPplVaccinated int)

INSERT INTO #PercentPopVaccinated
SELECT
	CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
	,SUM(CAST (CovidVaccinations.new_vaccinations AS int)) 
	OVER (Partition by CovidVaccinations.location 
	ORDER BY CovidDeaths.location, CovidDeaths.date) rolling_count_new_vaccinations
--	, (rolling_count_new_vaccinations/population)*100
FROM 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$ CovidDeaths
JOIN 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidVaccinations$ CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	AND CovidDeaths.date = CovidVaccinations.date
WHERE
	CovidDeaths.continent IS NOT NULL
	AND population IS NOT NULL

SELECT 
	*
	, ROUND((RollingPplVaccinated/population)*100, 2) percent_pop_vaccinated
FROM
	#PercentPopVaccinated;

-- View Creation
CREATE VIEW PercentPopVaccinated AS 
SELECT
	CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
	,SUM(CAST (CovidVaccinations.new_vaccinations AS int)) 
	OVER (Partition by CovidVaccinations.location 
	ORDER BY CovidDeaths.location, CovidDeaths.date) rolling_count_new_vaccinations
--	, (rolling_count_new_vaccinations/population)*100
FROM 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$ CovidDeaths
JOIN 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidVaccinations$ CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	AND CovidDeaths.date = CovidVaccinations.date
WHERE
	CovidDeaths.continent IS NOT NULL
	AND population IS NOT NULL;

---- New tests vs positive rate 
--CTE 
WITH CTE_NewTestsAndPositiveTestRates (Continent, Location, Date, Population, new_tests, positive_rate) AS
(SELECT
	CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_tests
	, CovidVaccinations.positive_rate
FROM 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$ CovidDeaths
JOIN 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidVaccinations$ CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	AND CovidDeaths.date = CovidVaccinations.date
WHERE
	CovidDeaths.continent IS NOT NULL
	AND population IS NOT NULL)

--Calling for CTE 'NewTestsAndPositiveTestRates'
SELECT
	* 
FROM
	CTE_NewTestsAndPositiveTestRates;

--TempTable
DROP TABLE IF EXISTS #NewTestsAndPositiveTestRates
CREATE TABLE #NewTestsAndPositiveTestRates
(Continent nvarchar(50), Location nvarchar(100), Date datetime, Population int, new_tests int, positive_rate float)

INSERT INTO #NewTestsAndPositiveTestRates
SELECT
	CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_tests
	, CovidVaccinations.positive_rate
FROM 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$ CovidDeaths
JOIN 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidVaccinations$ CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	AND CovidDeaths.date = CovidVaccinations.date
WHERE
	CovidDeaths.continent IS NOT NULL
	AND population IS NOT NULL

SELECT 
	*
FROM
	#NewTestsAndPositiveTestRates;

--View Creation
CREATE VIEW NewTestsAndPositiveTestRates AS
SELECT
	CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_tests
	, CovidVaccinations.positive_rate
FROM 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidDeaths$ CovidDeaths
JOIN 
	[Portfolio Project 1 - SQL Data Exploration].dbo.CovidVaccinations$ CovidVaccinations
	ON CovidDeaths.location = CovidVaccinations.location
	AND CovidDeaths.date = CovidVaccinations.date
WHERE
	CovidDeaths.continent IS NOT NULL
	AND population IS NOT NULL;






