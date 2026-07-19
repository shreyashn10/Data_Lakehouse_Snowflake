CREATE OR REPLACE DATABASE assignment_1;
--Database created

USE DATABASE assignment_1;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--Creating stage with azure url and azure SAS token
CREATE OR REPLACE STAGE stage_assignment
URL='azure://ustbdeshreyash.blob.core.windows.net/bdeassignment1'
CREDENTIALS=(AZURE_SAS_TOKEN='sv=2024-11-04&ss=b&srt=co&sp=rwdlaciytfx&se=2026-08-19T12:27:25Z&st=2025-08-19T04:12:25Z&spr=https&sig=aysFm4ZLtxaPrH12g3XguhZ%2B25AhzEHGFpXSYL%2BYHW0%3D')
;

list @stage_assignment;
--listing stage
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
--creating new external table ex_table_youtube_trending using stage_assignment
CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_trending (
  video_id       STRING         AS (VALUE:c1::STRING),
  title          STRING         AS (VALUE:c2::STRING),
  publishedat    TIMESTAMP_NTZ  AS (TO_TIMESTAMP_NTZ(VALUE:c3::STRING)),
  channelid      STRING         AS (VALUE:c4::STRING),
  channeltitle   STRING         AS (VALUE:c5::STRING),
  categoryid     NUMBER         AS (TRY_TO_NUMBER(VALUE:c6::STRING)),
  trending_date  DATE           AS (TO_DATE(VALUE:c7::STRING)),
  view_count     NUMBER         AS (TRY_TO_NUMBER(VALUE:c8::STRING)),
  likes          NUMBER         AS (TRY_TO_NUMBER(VALUE:c9::STRING)),
  dislikes       NUMBER         AS (TRY_TO_NUMBER(VALUE:c10::STRING)),
  comment_count  NUMBER         AS (TRY_TO_NUMBER(VALUE:c11::STRING)),
  country        STRING         AS (
    UPPER(REGEXP_SUBSTR(METADATA$FILENAME, '(^|/)([A-Za-z]{2})_', 1, 1, 'e', 2)) ))
WITH LOCATION = @stage_assignment
FILE_FORMAT = (
  TYPE = CSV
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  TRIM_SPACE = TRUE
  NULL_IF = ('', 'NULL', 'null')
)PATTERN = '.*\\.csv$'
AUTO_REFRESH = FALSE;

--fetching rowcount to ensure the table is created
SELECT COUNT(1) FROM ex_table_youtube_trending;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

-- External table on the JSON files
CREATE OR REPLACE EXTERNAL TABLE ex_table_youtube_category (raw VARIANT AS (value))
WITH LOCATION = @stage_assignment
FILE_FORMAT = (TYPE = JSON)
PATTERN = '.*_category_id\\.json$'
AUTO_REFRESH = FALSE;

--fetching rowcount to ensure the table is created:
SELECT count(1) FROM ex_table_youtube_category;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
--creating new table table_youtube_trending from ex_table_youtube_trending
CREATE OR REPLACE TABLE table_youtube_trending AS
SELECT
  video_id,
  title,
  channelid,
  channeltitle,
  publishedat,
  trending_date,
  view_count,
  likes,
  dislikes,
  comment_count,
  categoryid,
  country
FROM ex_table_youtube_trending;

--fetching rowcount to ensure the table is created:
SELECT COUNT(1) AS rows_in_table_trending FROM table_youtube_trending;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
--creating new table table_youtube_category from ex_table_youtube_category
CREATE OR REPLACE TABLE table_youtube_category AS
SELECT DISTINCT
  UPPER(REGEXP_SUBSTR(METADATA$FILENAME, '([A-Za-z]{2})_', 1, 1, 'e', 1)) AS country,
  TRY_TO_NUMBER(item.value:id::string) AS category_id,
  item.value:snippet:title::string AS category_title
FROM ex_table_youtube_category,
     LATERAL FLATTEN(input => raw:items) AS item;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

SELECT COUNT(1) FROM table_youtube_trending;
--2667041

SELECT COUNT(1) FROM table_youtube_category;
--311

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
--merging table_youtube_category and table_youtube_trending to create a final table called : table_youtube_final 
--new column name : 'id' added 
CREATE OR REPLACE TABLE table_youtube_final AS
SELECT UUID_STRING() AS id,
  t.video_id,
  t.title,
  t.channelid,
  t.channeltitle,
  t.publishedat,
  t.trending_date,
  t.view_count,
  t.likes,
  t.dislikes,
  t.comment_count,
  t.categoryid,
  t.country,
  c.category_title
FROM table_youtube_trending t
LEFT JOIN table_youtube_category c
  ON  t.country = c.country
  AND t.categoryid = c.category_id;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

-- Checking count
SELECT COUNT(1) AS final_row_count FROM table_youtube_final;
--expected count 2,667,041

-------------------------------------------END-----------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--Rough work below--
SELECT * FROM table_youtube_category; 

---------------------------------------------------------------------------------------------------------

SELECT COUNT(*) AS null_category_titles
FROM table_youtube_final
WHERE category_title IS NULL;
--expected 1563 

SELECT COUNT(1) AS rows_trending FROM table_youtube_trending;
SELECT COUNT(1) AS rows_category FROM table_youtube_category;

SELECT COUNT(1) AS ROWS_FINAL FROM TABLE_YOUTUBE_FINAL;
--COUNT = 2667041

SELECT count(1) FROM table_youtube_trending;

SELECT count(1) FROM table_youtube_category;

SELECT count(1) FROM TABLE_YOUTUBE_FINAL where category_title is null;

SELECT count(1) FROM TABLE_YOUTUBE_FINAL where category_title is not null;

-------------------------------------------END-----------------------------------------------------------
---------------------------------------------------------------------------------------------------------