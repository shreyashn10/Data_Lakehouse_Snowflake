USE DATABASE assignment_1;

--1.) category_title having duplicates in “table_youtube_category” 
SELECT category_title
FROM table_youtube_category
GROUP BY category_title
HAVING COUNT(DISTINCT category_id) > 1;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--2.) category_title appearing only in one country
SELECT category_title, country
FROM (SELECT category_title,
      COUNT(DISTINCT country) AS country_count,
      MIN(country) AS country
      FROM table_youtube_category
      GROUP BY category_title
     ) AS iq
WHERE country_count = 1;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--3.) categoryid of the missing category_titles

SELECT DISTINCT categoryid
FROM table_youtube_final
WHERE category_title IS NULL OR category_title = '';

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--4.) Update category_title : replace the NULL values with the answer from the previous question.
--fetching null counts 
SELECT COUNT(1) AS null_titles
FROM table_youtube_final
WHERE category_title IS NULL OR category_title = '';

--select category_title with the answer from the previous question.
SELECT category_title
FROM table_youtube_category
WHERE category_id=(SELECT DISTINCT categoryid
FROM table_youtube_final
WHERE category_title IS NULL OR category_title = '');

--Update statement:
UPDATE table_youtube_final
SET category_title = (SELECT category_title
                      FROM table_youtube_category
                      WHERE category_id=(SELECT DISTINCT categoryid
                      FROM table_youtube_final
                      WHERE category_title IS NULL OR category_title = '')
                      )
WHERE category_title IS NULL OR category_title = '';

SELECT COUNT(1) AS null_titles
FROM table_youtube_final AS TYF
WHERE TYF.category_title IS NULL;
--Zero null values expected here

SELECT COUNT(1) AS not_null_titles
FROM table_youtube_final AS TYF
WHERE TYF.category_title IS NOT NULL;
--2597494 rowcount

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--5.) Video not having a channeltitle
SELECT title
FROM table_youtube_final
WHERE channeltitle IS NULL OR channeltitle = '';

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--6.) Delete records having video_id = “#NAME?”
SELECT COUNT(1) FROM table_youtube_final
WHERE video_id = '#NAME?';
--32081 records with video_id = '#NAME?'

SELECT COUNT(1) FROM table_youtube_final
WHERE video_id <> '#NAME?';
--2634960 records

DELETE FROM table_youtube_final
WHERE video_id = '#NAME?';
--32081 records deleted

SELECT COUNT(1) FROM table_youtube_final
WHERE video_id = '#NAME?';
--Zero records

SELECT Count(1) FROM table_youtube_final;
--Latest count = 2634960 as expected

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--7.) Create a new table called “table_youtube_duplicates” containing only the “bad” duplicates using the row_number() function.

--Rows having view_count AND video_id AND country AND trending_date having all NULL
SELECT COUNT(1) FROM table_youtube_final
WHERE view_count IS NULL
AND video_id IS NULL
AND country IS NULL
AND trending_date IS NULL;

-----------------------------------------

CREATE OR REPLACE TABLE table_youtube_duplicates AS
SELECT *
FROM (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY video_id, country, trending_date
      ORDER BY view_count DESC
    ) AS ronum
  FROM table_youtube_final
)
WHERE ronum > 1;

----------------------------------------------
SELECT COUNT(1) FROM table_youtube_duplicates;
--Count expected 37466

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--8.) Delete the duplicates in “table_youtube_final“ by using “table_youtube_duplicates”
SELECT COUNT(1) FROM table_youtube_final;
--Latest count = 2634960

SELECT COUNT(1) FROM table_youtube_duplicates;
--Count expected to be deleted 37466

SELECT 2634960-37466 FROM DUAL;
--2597494 records expected to be remaining

SELECT COUNT(1) FROM table_youtube_final
WHERE id IN (SELECT id FROM table_youtube_duplicates);
--Count expected to be deleted 37466

--deleting duplicate records:
DELETE FROM table_youtube_final
WHERE id IN (SELECT id FROM table_youtube_duplicates);

SELECT COUNT(1) FROM table_youtube_final
WHERE id IN (SELECT id FROM table_youtube_duplicates);
--ZERO records as the "bad" duplicates were deleted from main table

SELECT COUNT(1) FROM table_youtube_final;
--2597494 records remaining post deletion

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--9.) Count the number of rows in “table_youtube_final“ and check that it is equal to 2,597,494 rows
SELECT COUNT(1) FROM table_youtube_final;
--Latest count = 2597494 rows

-------------------------------------------END-----------------------------------------------------------
---------------------------------------------------------------------------------------------------------