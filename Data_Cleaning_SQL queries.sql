--DELETING Dupliactes- Finding duplicates

SELECT country,year, CONCAT(country,year), COUNT(CONCAT(country,year))
FROM world_life_expectancy
GROUP BY country,year, CONCAT(country,year)
HAVING COUNT(CONCAT(country,year)) >1;

--DELETING Dupliactes- Finding duplicates- Finding the row_number;

SELECT *
FROM(
	SELECT Row_ID,
		CONCAT(country,year),
		ROW_NUMBER() OVER(PARTITION BY CONCAT(country,year) ORDER BY CONCAT(country,year)) as Row_num
		FROM world_life_expectancy) AS Row_tab
        WHERE row_num >1;

-- DELETING the duplicate row:

DELETE FROM world_life_expectancy
WHERE Row_ID IN ( SELECT Row_ID
FROM(
	SELECT Row_ID,
		CONCAT(country,year),
		ROW_NUMBER() OVER(PARTITION BY CONCAT(country,year) ORDER BY CONCAT(country,year)) as Row_num
		FROM world_life_expectancy) AS Row_tab
        WHERE row_num >1);

--DEALING With no values- Identifying null VALUES for status

SELECT *
FROM world_life_expectancy
WHERE status='';

--DEALING With no values- Identifying the string in Status that we want to pupulate the row with no values;
SELECT DISTINCT (status)
FROM world_life_expectancy
WHERE status!='';

--DEALING With no values- NOW updating the blank values with relevent information;

UPDATE world_life_expectancy
SET status = 'Developing'
WHERE status = ''
AND country IN (
    SELECT country FROM (
        SELECT country
        FROM world_life_expectancy
        WHERE status = 'Developing'
    ) AS subquery
);

UPDATE world_life_expectancy
SET status='Developed'
WHERE status=''
	AND country IN (
		SELECT country FROM ( 
					SELECT country
					FROM world_life_expectancy
                    WHERE status='Developed') AS subquery);
					
--DEALING With no values- Identifying null VALUES for life_expectancy

SELECT * 
FROM world_life_expectancy
WHERE `Life expectancy`='';

--DEALING With no values- Identifying null VALUES for life_expectancy-filling the missing value with AVG

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
ON t1.country=t2.country
AND t1.year=t2.year-1
JOIN world_life_expectancy t3
ON t1.country=t3.country
AND t1.year=t3.year+1
SET t1.`Life expectancy`= ROUND((t2.`Life expectancy`+t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy`='';
