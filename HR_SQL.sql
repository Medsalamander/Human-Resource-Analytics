SELECT *
FROM dbo.hr;

-- Inspecting the termdate column
SELECT termdate
FROM dbo.hr
ORDER BY termdate DESC;

-- Convert termdate from nvarchar datatype to date, extract only date component
UPDATE dbo.hr
SET termdate = FORMAT(CONVERT(DATETIME, LEFT(termdate, 19),120), 'yyyy-MM-dd');

-- Add a new column new_termdate.
ALTER TABLE dbo.hr
ADD new_termdate DATE;

--Copy converted time values from termdate to new_termdate

UPDATE dbo.hr
SET new_termdate = CASE	
					WHEN termdate IS NOT NULL AND ISDATE(termdate)=1 THEN CAST(termdate AS DATETIME) ELSE NULL END;

--Create new coulumn 'age'
ALTER TABLE dbo.hr
ADD age nVARCHAR(50);

-- Add values to the age column
UPDATE dbo.hr
SET age = DATEDIFF(YEAR, birthdate, GETDATE());

--What is the age distribution in the company
SELECT
	MIN(age) AS youngest,
	MAX(age) AS oldest
FROM dbo.hr
 
-- AGE_GROPU distribution
SELECT age_group,
	COUNT(*) AS count
FROM
(SELECT 
	CASE 
		WHEN AGE BETWEEN 18 AND 30 THEN '18-30' 
		WHEN AGE BETWEEN 31 AND 40 THEN '31-40' 
		WHEN AGE BETWEEN 41 AND 50 THEN '41-50' 
		WHEN AGE BETWEEN 51 AND 60 THEN '51-60'
		ELSE '60+'
	END AS age_group
FROM dbo.hr
WHERE new_termdate IS NULL
) AS subquery
GROUP BY age_group
ORDER BY age_group;

--AGE_GROUP distribution by gender

SELECT age_group, gender,
	COUNT(*) AS count
FROM
(SELECT 
	CASE 
		WHEN AGE BETWEEN 18 AND 30 THEN '18-30' 
		WHEN AGE BETWEEN 31 AND 40 THEN '31-40' 
		WHEN AGE BETWEEN 41 AND 50 THEN '41-50' 
		WHEN AGE BETWEEN 51 AND 60 THEN '51-60'
		ELSE '60+'
	END AS age_group,
	gender
FROM dbo.hr
WHERE new_termdate IS NULL
) AS subquery
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- What is the gender distribution in the company
SELECT gender,
COUNT(*) AS count
FROM dbo.hr
WHERE new_termdate IS NULL
GROUP BY gender
ORDER BY gender;

-- How does gender vary across dept and job titles
SELECT department, gender,
COUNT(*) AS count
FROM dbo.hr
WHERE new_termdate IS NULL
GROUP BY department, gender
ORDER BY department, gender;

--  job titles
SELECT department, jobtitle, gender,
COUNT(*) AS count
FROM dbo.hr
WHERE new_termdate IS NULL
GROUP BY department,jobtitle, gender
ORDER BY department,jobtitle, gender;

-- What is the race distribution in the company
SELECT
race,
COUNT(*) AS count
FROM dbo.hr
WHERE new_termdate IS NULL
GROUP BY race
ORDER BY count DESC;

-- What is the average lenght of employment in the company( former employees)
SELECT 
AVG(DATEDIFF(YEAR, hire_date, new_termdate)) AS tenure
FROM dbo.hr
WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE()

-- what is the average lenght of employment for current employees
 SELECT 
AVG(DATEDIFF(YEAR, hire_date, GETDATE())) AS tenure
FROM dbo.hr
WHERE new_termdate IS NULL

--Which department has the highest turnover rate
SELECT 
	department,
	total_count,	
	terminated_count,
	(ROUND((CAST(terminated_count AS FLOAT) / total_count),2))*100 AS turnover_rate 
FROM 
	(SELECT 
		department,
		COUNT(*) AS total_count,
		SUM(CASE WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0 END) AS terminated_count
	FROM dbo.hr
	GROUP BY department
	) AS subquery

ORDER BY turnover_rate;

--What is the tenure distribution for each department
SELECT 
department,
AVG(DATEDIFF(YEAR, hire_date, new_termdate)) AS tenure
FROM dbo.hr
WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE()
GROUP BY department
ORDER BY tenure;

-- How many employees work remotely for each department
SELECT 
	location,
	COUNT(*) AS count
FROM dbo.hr
WHERE new_termdate IS NULL
GROUP BY location

--What is the distribution of employees across different states
SELECT
	location_state,
	COUNT(*) AS count
FROM dbo.hr
WHERE new_termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;

-- What is the distribution of jobtitles in the company
SELECT
	jobtitle,
	COUNT(*) AS  count
FROM dbo.hr
WHERE new_termdate IS NULL
GROUP BY jobtitle
ORDER BY COUNT DESC;

-- Employee count change over time
-- calculate hires
-- calculate terminations
-- (hires - terminations) / hires %hire_change
SELECT
	hire_year,
	hires,
	terminations,
	hires - terminations  AS net_change,
	ROUND(((CAST((hires - terminations) AS FLOAT) / hires) * 100), 0) AS percent_hire_change
FROM
		(
		SELECT
		YEAR(hire_date) AS hire_year,
		COUNT(*) AS hires,
		SUM( CASE WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0 END) AS terminations
		FROM dbo.hr
		GROUP BY YEAR(hire_date)
		
		) AS subquery

ORDER BY percent_hire_change DESC;

