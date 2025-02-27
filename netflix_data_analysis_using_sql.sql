----------- Creating Database---------------------------

-- DROP TABLE IF EXISTS netflix;

-- CREATE TABLE netflix
-- (
-- 	show_id	VARCHAR(6),
-- 	type	VARCHAR(10),
-- 	title	VARCHAR(150),
-- 	director	VARCHAR(210),
-- 	casts	VARCHAR(1000),
-- 	country	VARCHAR(150),
-- 	date_added	VARCHAR(50),
-- 	release_year	INT,
-- 	rating	VARCHAR(10),
-- 	duration	VARCHAR(15),
-- 	listed_in	VARCHAR(100),
-- 	description	VARCHAR(250)
-- )



----------------Queries-----------
-- SELECT * FROM netflix;

-- SELECT COUNT(*) AS total_rows
-- FROM netflix;

SELECT DISTINCT type
FROM netflix;


-------------- 15 Business Problems & Solutions-----------------------------

-- Problem#01. Count the number of Movies vs TV Shows
SELECT
	type,
	COUNT(*) AS total_content
FROM netflix
GROUP BY type
--ANSWER: Movies = 6131, TV Show = 2676


-- Problem#02. Find the most common rating for movies and TV shows
SELECT 
	type,
	rating
FROM
(
	SELECT
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix
	GROUP BY 1,2
	ORDER BY 1, 3 DESC
)as t1
WHERE 
	ranking = 1
--ANSWER: "TV-MA"



-- Problem#03. List all movies released in a specific year (e.g., 2020)
SELECT
	*
FROM
	netflix
WHERE
	type = 'Movie'
	AND
	release_year = 2020



-- Problem#04. Find the top 5 countries with the most content on Netflix
SELECT
	UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
	COUNT(show_id) AS total_content
FROM
	netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
--ANSWER: "United States", "India", "United Kingdom", " United States", "Canada"



-- Problem#05. Identify the longest movie
SELECT
	*
	-- SPLIT_PART(duration, ' ',1)::numeric AS minutes_duration
FROM 
	netflix
WHERE 
	type = 'Movie'
	AND
	SPLIT_PART(duration, ' ',1)::numeric = 
	(
		SELECT
			MAX(SPLIT_PART(duration, ' ',1)::numeric)
		FROM 
			netflix
		)
-- ANSWER: "Black Mirror: Bandersnatch"



-- Problem#06. Find content added in the last 5 years
SELECT
	*
FROM
	netflix
WHERE
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

SELECT CURRENT_DATE - INTERVAL '5 years'
SELECT TO_DATE(date_added, 'Month DD, YYYY') FROM netflix


-- Problem#07. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT
	*
FROM
	netflix
WHERE 
	director ILIKE '%Rajiv Chilaka%'



-- Problem#08. List all TV shows with more than 5 seasons
SELECT
	*
FROM
	netflix
WHERE
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ',1)::numeric > 5



-- Problem#09. Count the number of content items in each genre
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) AS genre,
	COUNT(show_id)
FROM 
	netflix
GROUP BY 1
ORDER BY 2 DESC



-- Problem#10.Find each year and the average numbers of content release in United States on netflix. 
-- return top 5 year with highest avg content release!
SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS date,
	COUNT(*),
	ROUND(
		COUNT(*)::numeric/(
			SELECT COUNT(*) 
			FROM netflix 
			WHERE country = 'United States'
		) * 100,
	2) AS avg_content_per_year
FROM
	netflix
WHERE
	country = 'United States'
GROUP BY date
ORDER BY avg_content_per_year DESC
LIMIT 5
	


-- Problem#11. List all movies that are documentaries
SELECT
	*
FROM
	netflix
WHERE
	listed_in ILIKE '%documentaries%'
	


-- Problem#12. Find all content without a director
SELECT
	*
FROM
	netflix
WHERE
	director IS NULL


-- Problem#13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT
	*
FROM
	netflix
WHERE
	casts ILIKE '%Akshay Kumar%'
	AND
	release_year > EXTRACT (YEAR FROM CURRENT_DATE) - 10


-- Problem#14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actors,
	COUNT(*) AS total_work
FROM
	netflix
WHERE
	country ILIKE '%india%'
GROUP BY 1
ORDER BY total_work DESC
LIMIT 10


-- Problem#15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad Content' and all other 
-- content as 'Good Content'. Count how many items fall into each category.
WITH new_table
AS 
(
	SELECT *,
	       CASE
	       		WHEN 
				   description ilike '% kill%' OR   
				   description ilike '% violence%' THEN 'Bad Content'
	            	ELSE 'Good Content'
	       		END category
	FROM   netflix
)
SELECT
	category,
	COUNT(*) AS total_content
FROM new_table
GROUP BY 1






