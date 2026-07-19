YOUTUBE TRENDING DATA LAKEHOUSE WITH SNOWFLAKE
==============================================

Project overview
----------------
This repository contains a Snowflake data-lakehouse assignment that ingests,
cleans, and analyses a multi-country YouTube Trending Videos dataset.

The dataset covers daily trending videos from 12 August 2020 through
15 April 2024 for ten regions:

  IN  India
  US  United States
  GB  Great Britain
  DE  Germany
  CA  Canada
  FR  France
  BR  Brazil
  MX  Mexico
  KR  South Korea
  JP  Japan

Trending records are stored as CSV files and regional category mappings are
stored as JSON files. The source files are placed in Azure Blob Storage and
queried from Snowflake through an external stage.

High-level data flow
--------------------

  YouTube Trending CSV and category JSON files
                    |
                    v
          Azure Blob Storage container
                    |
                    v
        Snowflake external stage
             stage_assignment
                    |
                    v
      External tables for CSV and JSON
        ex_table_youtube_trending
        ex_table_youtube_category
                    |
                    v
       Materialized Snowflake tables
          table_youtube_trending
          table_youtube_category
                    |
                    v
        Joined analytical table
          table_youtube_final
                    |
                    v
       Cleaning, analysis, and business findings

Repository contents
-------------------

Report_Assignment_1_Shreyash_Narayane.pdf
  Handover report describing the ingestion pipeline, transformations, cleaning
  operations, analytical queries, results, and business recommendation.

part_1.sql
  Creates the Snowflake database and Azure-backed stage, defines external CSV
  and JSON tables, materializes the source data, and joins the trending and
  category datasets into table_youtube_final.

part_2.sql
  Profiles and cleans table_youtube_final. It repairs missing category titles,
  removes invalid '#NAME?' video IDs, identifies lower-view duplicate rows with
  ROW_NUMBER(), deletes those duplicates, and validates the final row count.

part_3.sql
  Contains analytical queries for country-level rankings, BTS-related videos,
  monthly top videos and like ratios, leading categories by country, and the
  channel producing the most distinct videos.

part_4.sql
  Despite its filename, the uploaded file contains the assignment brief rather
  than executable Part 4 business-analysis SQL. The business queries and final
  recommendation are documented in the report, but a standalone executable
  Part 4 SQL script is not present in the current repository contents.

Snowflake objects
-----------------

Database
  assignment_1

Stage
  stage_assignment

External tables
  ex_table_youtube_trending
  ex_table_youtube_category

Internal tables
  table_youtube_trending
  table_youtube_category
  table_youtube_final
  table_youtube_duplicates

Core table model
----------------

table_youtube_trending includes:
  video_id, title, channelid, channeltitle, publishedat, trending_date,
  view_count, likes, dislikes, comment_count, categoryid, country

table_youtube_category includes:
  country, category_id, category_title

table_youtube_final adds:
  id              UUID generated with UUID_STRING()
  category_title  joined by country and category ID

The LEFT JOIN used to build table_youtube_final preserves all trending rows,
even where a regional category lookup is initially missing.

Execution order
---------------

1. Upload the regional CSV and JSON source files to an Azure Blob Storage
   container.

2. Open part_1.sql and replace the stage URL and credentials with values for
   your own Azure environment.

3. Run part_1.sql in Snowflake. Confirm these expected counts:

     table_youtube_trending   2,667,041 rows
     table_youtube_category         311 rows
     table_youtube_final      2,667,041 rows before cleaning

4. Run part_2.sql once. It mutates table_youtube_final, so rerunning only part
   of the script may produce different counts. Expected cleaning results are:

     Missing category title category ID       29
     Missing titles updated                1,563
     Invalid '#NAME?' records deleted     32,081
     Lower-view duplicate rows deleted    37,466
     Final cleaned row count            2,597,494

5. Run part_3.sql after cleaning. The analysis expects table_youtube_final to
   contain the cleaned data.

6. Use the report for the Part 4 interpretation and recommendation. Create a
   separate executable Part 4 SQL file before treating the repository as a
   fully reproducible four-part submission.

Data-cleaning logic
-------------------

The cleaning workflow performs the following checks and corrections:

* Finds category names mapped to more than one category ID.
* Identifies category names appearing in only one country.
* Locates records with missing category titles and restores the title using
  the category mapping for category ID 29.
* Finds the video with a missing channel title.
* Deletes records whose video_id is '#NAME?'.
* Treats rows sharing video_id, country, and trending_date as duplicates.
* Retains the row with the highest view_count and removes lower-ranked rows.

Key analysis queries
--------------------

part_3.sql answers the following questions:

* What are the three most-viewed Gaming videos per country on 1 April 2024?
* How many distinct videos with 'BTS' in the title appear in each country?
* What is the most-viewed video per country and month in 2024, and what is its
  likes-to-views percentage?
* Which category has the most distinct videos per country from 2022 onward,
  and what percentage of that country's distinct videos does it represent?
* Which channel produced the most distinct videos?

The reported result for the last query is Vijay Television with 2,049 distinct
videos.

Business finding
----------------

The report evaluates categories for a new globally oriented YouTube channel
while excluding Music and Entertainment. Gaming records the strongest overall
viewership and the most consistent cross-country performance. The report
therefore recommends Gaming as the most broadly viable category, while noting
that People & Blogs can be regionally concentrated and Sports can depend on
local interests and major events.

Security warning
----------------

part_1.sql currently contains an Azure SAS token in plain text. Treat that token
as exposed. Revoke or rotate it, remove it from version control and commit
history, and replace it with a placeholder or a secure Snowflake storage
integration before publishing or sharing this repository.

Do not commit cloud credentials, account identifiers, private storage URLs, or
other secrets. A safer pattern is:

  CREDENTIALS=(AZURE_SAS_TOKEN='<AZURE_SAS_TOKEN>')

For production use, prefer a Snowflake STORAGE INTEGRATION with least-privilege,
read-only access rather than embedding a SAS token in SQL.

Known limitations
-----------------

* The SQL assumes source filenames begin with a two-letter country code.
* External-table refresh is disabled; newly uploaded files require an explicit
  refresh or recreation workflow.
* part_2.sql is destructive and is not fully idempotent.
* Duplicate retention is deterministic only when view_count differs. Equal
  view counts have no secondary tie-breaker.
* part_3.sql labels the ratio as likes_ratio and calculates a percentage rounded
  to two decimals.
* Data ends on 15 April 2024, so 2024 comparisons cover only a partial year.
* The current part_4.sql is an assignment specification, not an executable
  business-analysis script.

Suggested repository improvements
---------------------------------

* Replace embedded credentials with a secure storage integration.
* Add an explicit schema and warehouse setup section.
* Move exploratory or rough-work queries out of part_1.sql.
* Add deterministic duplicate tie-breakers, such as likes, comments, or ID.
* Wrap destructive cleaning steps in a transaction or build a cleaned table
  instead of mutating the source-derived final table.
* Add a valid part_4.sql containing the business-analysis queries used in the
  report.
* Add automated row-count and null-count assertions after each pipeline stage.

Author and academic context
---------------------------

Author: Shreyash Narayane
Course: 94693 - Big Data Engineering
Program: Master of Data Science and Innovation
Institution: University of Technology Sydney
Term: Spring 2025
