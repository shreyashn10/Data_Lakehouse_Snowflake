USE DATABASE assignment_1;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--1.) 3 most viewed videos for each country in the 'Gaming' category where trending_date = "2024-04-01". Order by country and rank
SELECT country, title, channeltitle, view_count,
  ROW_NUMBER() OVER (
                    PARTITION BY country
                    ORDER BY view_count DESC
                    ) AS ROWNUM
FROM table_youtube_final
WHERE trending_date = '2024-04-01'
  AND category_title = 'Gaming'
QUALIFY ROWNUM <= 3
ORDER BY country, ROWNUM ASC;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--2.) Distinct count of video with title containing the word “BTS”, group by country and order the result by count in a descending order
SELECT country, COUNT(DISTINCT video_id) AS CT   
FROM table_youtube_final
WHERE UPPER(title) ILIKE '%BTS%'   
GROUP BY country
ORDER BY ct DESC, country ASC;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--3.) Most viewed video for each country and every month of 2024 with their likes_ratio, order by year_month and country.
WITH base AS (
  SELECT country, DATE_TRUNC('month', trending_date) AS year_month, title, channeltitle, category_title, view_count, likes
  FROM table_youtube_final
  WHERE trending_date >= '2024-01-01'
    AND trending_date <  '2025-01-01'
),
ranked AS (
  SELECT b.*, ROW_NUMBER() OVER (
  PARTITION BY country, year_month
      ORDER BY view_count DESC
    ) AS rn
  FROM base b
)
SELECT country, year_month, title, channeltitle, category_title, view_count, ROUND((likes / NULLIF(view_count, 0)) * 100, 2) AS likes_ratio
FROM ranked
WHERE rn = 1
ORDER BY year_month, country;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--4.) category_title having most distinct videos from 2022 and its percentage of the country’s total distinct videos
WITH country_dist AS (      -- Calculate count of distinct videos for each country and category from 2022
    SELECT country, trim(lower(category_title)) as category_title, COUNT(DISTINCT video_id) AS total_category_video
    FROM table_youtube_final
    WHERE EXTRACT(YEAR FROM trending_date) >= 2022
      AND category_title IS NOT NULL
    GROUP BY country, category_title),
country_total AS (          -- Calculate total distinct videos for each country after 2022
    SELECT country, COUNT(DISTINCT video_id) AS total_country_video
    FROM table_youtube_final
    WHERE EXTRACT(YEAR FROM trending_date) >= 2022
    AND category_title IS NOT NULL
    GROUP BY country),
category_percentage AS (    -- Calculate percentage and rank the categories by distinct videos grouping country
    SELECT cd.country, cd.category_title, cd.total_category_video, ct.total_country_video, ROUND((cd.total_category_video * 100.0 / ct.total_country_video), 2) AS percentage,
    ROW_NUMBER() OVER (PARTITION BY cd.country ORDER BY cd.total_category_video DESC) AS rank_num
    FROM country_dist cd
    JOIN country_total ct ON cd.country = ct.country)
-- Select the top most categories for each country
SELECT country, category_title, total_category_video, total_country_video, percentage
FROM category_percentage
WHERE rank_num = 1
ORDER BY category_title, country;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--5.) channeltitle producing most distinct videos
SELECT channeltitle, COUNT(DISTINCT video_id) AS distinct_videos
FROM table_youtube_final
GROUP BY channeltitle
ORDER BY distinct_videos DESC, channeltitle ASC
LIMIT 1;
--channeltitle = Vijay Television && distinct_videos = 2049

-------------------------------------------END-----------------------------------------------------------
---------------------------------------------------------------------------------------------------------