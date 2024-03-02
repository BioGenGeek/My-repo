CREATE DATABASE MyProjects2;

USE Myprojects2;
--
SELECT * FROM hr;
--
ALTER TABLE hr
CHANGE COLUMN ï»¿id ID VARCHAR(20) NULL;
--
SELECT * FROM hr;
--
DESCRIBE hr;
--
SELECT birthdate FROM hr;
--
SET SQL_SAFE_UPDATES = 0;

UPDATE hr 
SET birthdate = CASE
    WHEN birthdate  LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE  NULL 
    END;
    
    ALTER TABLE hr
    MODIFY COLUMN birthdate DATE;
    
    SELECT birthdate FROM hr;
    --
    DESCRIBE hr;
UPDATE hr 
SET hire_date = CASE
    WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE  NULL 
    END;
ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

--
    SELECT termdate FROM hr; 
    -- it is correcr and no need to change
    
    
UPDATE hr 
SET termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate !='';

SELECT termdate FROM hr; 

ALTER TABLE hr
MODIFY COLUMN termdate DATE;
----
UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;

SELECT termdate from hr;

SET sql_mode = 'ALLOW_INVALID_DATES';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

----

ALTER TABLE hr ADD COLUMN age INT;

-- add age

UPDATE hr 
SET age= timestampdiff(YEAR,birthdate,CURDATE());


SELECT age FROM hr;
--

SELECT MIN(age) AS youngest,
       MAX(age) AS oldest
FROM hr;

SELECT COUNT(*) FROM hr  WHERE age <18 ;

-- gender breakdown of employees

SELECT gender, COUNT(*) AS count
FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY gender;

-- race/ethnity break down

SELECT race , COUNT(*) AS count
FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY COUNT(*) DESC;

-- age distribution

SELECT 
    MIN(age) AS youngest,
    MAX(age) AS oldest
FROM hr 
WHERE age >=18 AND termdate = '0000-00-00';

SELECT
     CASE 
         WHEN age >=18 AND age <=24 THEN '18-24'
         WHEN age >=25 AND age <=34 THEN '25-34'
         WHEN age >=35 AND age <=44 THEN '35-44'
		 WHEN age >=45 AND age <=54 THEN '44-54'
         WHEN age >=55 AND age <=64 THEN '55-64'
         ELSE '65+'
END AS age_group,
COUNT(*) AS count
FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY age_group
ORDER BY age_group;

SELECT
     CASE 
         WHEN age >=18 AND age <=24 THEN '18-24'
         WHEN age >=25 AND age <=34 THEN '25-34'
         WHEN age >=35 AND age <=44 THEN '35-44'
		 WHEN age >=45 AND age <=54 THEN '44-54'
         WHEN age >=55 AND age <=64 THEN '55-64'
         ELSE '65+'
END AS age_group, gender,
COUNT(*) AS count
FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY age_group, gender
ORDER BY age_group, gender;


-- number of employees

SELECT location , COUNT(*) AS count
FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY location;

-- work duration 

SELECT 
ROUND(AVG(DATEDIFF(termdate, hire_date))/356,0) AS avg_length_employment
FROM hr
WHERE termdate <= CURDATE() AND termdate <> '0000-00-00' AND age >=18;

-- gender variation

SELECT department , gender, COUNT(*) AS count
FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY department , gender
ORDER BY department;

-- job title

SELECT jobtitle, COUNT(*) AS count
FROM hr
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- department with highest turnover

SELECT department,
total_count,
terminated_count,
terminated_count/total_count AS termination_rate
FROM (
 SELECT department,COUNT(*) AS total_count,
 SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminated_count
 FROM hr
 WHERE age >=18 
 GROUP BY department 
) AS sunquery
ORDER BY termination_rate DESC;

-- city and state

SELECT location_state, COUNT(*) AS count
FROM hr 
WHERE age >=18 AND termdate = '0000-00-00'
GROUP BY location_state 
ORDER BY count DESC;

-- change of employees
SELECT year,hires, terminations, hires-terminations AS net_change,
       ROUND((hires-terminations)/hires *100,2) AS net_change
FROM (
      SELECT 
         YEAR(hire_date) AS year,
         COUNT(*) AS hires,
         SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <=CURDATE() THEN 1 ELSE 0 END)AS terminations
FROM hr
WHERE age >=18
GROUP BY YEAR(hire_date)
) AS subquery 
ORDER BY  year DESC;

-- change for each department

SELECT department , ROUND(AVG(DATEDIFF(termdate, hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate <= CURDATE() AND termdate <> '0000-00-00' AND age >=18
GROUP BY department;

         