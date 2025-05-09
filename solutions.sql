-- Netflix Project 
DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix
(
  show_id VARCHAR(6),
  type VARCHAR(10),
  title	VARCHAR(150),
  director VARCHAR(208),
  casts VARCHAR(1000),
  country VARCHAR(150),	
  date_added VARCHAR(50),
  release_year INT,
  rating VARCHAR(10),
  duration VARCHAR(15),
  listed_in	VARCHAR(100),
  description VARCHAR(250)
);

SELECT * FROM netflix;

SELECT 
COUNT(*) as total_content
FROM netflix;

SELECT DISTINCT TYPE FROM netflix;

--15 Business Problems
--1. Count the number of movies vs TV shows

SELECT type,
COUNT(*) as total_content
FROM netflix
GROUP BY type;

--2. Find the most common rating for movies and TV shows

SELECT 
type, rating
FROM 
(SELECT 
type, 
rating, 
COUNT(*),
RANK() OVER(PARTITION BY type ORDER BY count(*) DESC) as rank
FROM netflix
GROUP BY type,rating)
WHERE rank = 1;
--ORDER BY 1, 3 DESC;

--3. list all movies released in a specific year (e.g., 2020)

SELECT * FROM netflix;

SELECT title as movies_released_in_2020
from netflix
where type = 'Movie' AND release_year = 2020;

--4. Find the top 5 countries with the most content on netflix.
SELECT * FROM netflix;

select trim(unnest(string_to_array(country, ','))) as new_country, count(*) as total_content 
from netflix
group by new_country
order by 2 desc
limit 5;

--5. Identify the longest movie? 
SELECT title, duration
from netflix
where type = 'Movie' AND duration = (SELECT MAX(duration) FROM netflix);

--6. Find content added in the last 5 years? 

--STEP 1 :
TO_DATE(date_added 'Month DD, YYYY') 
--STEP 2 : 
SELECT CURRENT_DATE - INTERVAL '5 years' -- you will get the date 5 years before. 
--STEP 3 : (combine step 1 + step 2)
--WHERE date_added > = current_date - interval '5 years' (so the result will be greater than
-- the five year old date we got)

SELECT *
FROM netflix
WHERE 
TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'?

SELECT * from netflix
where director ILIKE '%Rajiv Chilaka%';

--8. List all TV shows with more than 5 seasons

SELECT * from netflix
where type = 'TV Show' AND SPLIT_PART(duration, ' ', 1)::numeric > 5;

--9.  Count the number of content items in each genre 
select
UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
count(show_id) as total_count
from netflix
group by 1

--10. Find each year and the average number of content release by India on netflix. return top 5
--years with highest average content release.

-- total content 333/972

SELECT EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year, 
count(*) as yearly_content, Round(
Count(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric*100,2) as
avg_content_per_year
from netflix
where country = 'India'
group by 1

--11. List all movies that are documentaries
SELECT type, title, listed_in
FROM netflix
where type = 'Movie' AND listed_in ILIKE '%Documentaries%'

--12. Find all content without a director
SELECT * FROM netflix where director IS NULL

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years.
select *
from netflix 
where type = 'Movie' AND casts ILIKE '%Salman Khan%' AND 
release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select 
UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
count(*) as tot_content 
from netflix 
where country ILIKE 'India' AND type = 'Movie'
group by 1
order by 2 desc 
limit 10

--15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the
--description field. Label content containing these keywords as 'Bad' and all other content as
--'Good'. Count how many items fall into each category.
With new_table
As
(
SELECT *,
CASE WHEN description ILIKE '%kill%' OR
    description ILIKE '%violence%' THEN 'Bad'
ELSE 'Good' 
END as category
FROM netflix
)
SELECT category, count(*) as total_content
FROM new_table
group by 1 
