Big Data Engineering

Assignment 1: Data Lakehouse with Snowflake

Aim:
The goal of this assignment is to analyse a dataset (made of CSVs and Jsons files) by using a Data Lakehouse with Snowflake. You will have to upload the data on a cloud storage, ingest the data into the Data Lakehouse, perform data transformation and finally analyse it.

Introduction to the dataset
YouTube (the world-famous video sharing website) maintains a list of the top trending videos on the platform. According to Variety magazine, “To determine the year’s top-trending videos, YouTube uses a combination of factors including measuring users' interactions (e.g. number of views, shares, comments and likes). 

A dataset with a daily record of the top trending YouTube videos has been extracted through the Youtube API and made available on the Kaggle (https://www.kaggle.com/rsrishav/youtube-trending-video-dataset)

This dataset includes several months (from 2020-08-12 to 2024-04-15) of data of daily trending YouTube videos. Data is included for the IN, US, GB, DE, CA, FR, BR, MX, KR, and JP regions (India, USA, Great Britain, Germany, Canada, France, Brazil, Mexico, South Korea, and Japan respectively), with up to 200 listed trending videos per day.

Each region’s data is in a separate file. Data includes the video title, channel title, published time, views, likes and dislikes and comment count.


The data also includes a category_id field, which varies between regions. To retrieve the categories for a specific video, find it in the associated JSON. One such file is included for each of the 10 regions in the dataset.



Tasks:
You will need your cloud storage account on Microsoft Azure and your Snowflake account which were set up for the lab 2.

Your tasks will be:

PART 1: Data Ingestion
Provide a sql file containing all the sql code used in Snowflake for part 1 and called it “part_1.sql”:

1.1. Download the (compressed) dataset on:
1.1.a.Trending data: https://drive.google.com/file/d/14xKzN4MEtCr1lZ_8w0JKwBTCjo-CBLlL/view?usp=sharing

1.1.b.Category data: 
https://drive.google.com/file/d/1uhkOwCCQK7LoER6tXZpsVbIfAr-CJomJ/view?usp=sharing

1.2.Upload the dataset in your storage account on Azure
1.3.On Snowflake:
1.3.a.Create a database called: “assignment_1”
1.3.b.Create a stage called “stage_assignment”, pointing to your azure storage
1.4.Ingest the data as external tables on Snowflake
1.4.a.Create two external tables “ex_table_youtube_trending” and “ex_table_youtube_category” with the correct data type.
1.5.Transfer the data from external tables into tables with the following columns:
1.5.a.For trending data create a table called “table_youtube_trending” with:
1.5.b.For category data create a table called “table_youtube_category” with:
1.6.Create a final table called “table_youtube_final” by combining “table_youtube_trending” and  “table_youtube_category” on country and categoryid (be careful to not lose any records), while adding a new field called ideas by using the “UUID_STRING()” function.

You should end up with 2,667,041 rows in table_youtube_final

PART 2: Data Cleaning 
Provide a sql file containing all the sql code used in Snowflake for part 2 and called it “part_2.sql” (add comments to separate each questions):

In “table_youtube_category” which category_title has duplicates if we don’t take into account the categoryid (return only a single row)?
In “table_youtube_category” which category_title only appears in one country?
In “table_youtube_final”, what is the categoryid of the missing category_titles?
Update the table_youtube_final to replace the NULL values in category_title with the answer from the previous question.
In “table_youtube_final”, which video doesn’t have a channeltitle (return only the title)?
Delete from “table_youtube_final“, any record with video_id = “#NAME?”

The “table_youtube_final“ contains duplicates with the same video_id, country and trending_date however their metrics (likes, dislikes, etc..) can be different. E.g:


We can assume that the highest number of view_count will be the record to keep when we have duplicates.

Create a new table called “table_youtube_duplicates”  containing only the “bad” duplicates by using the row_number() function.
Delete the duplicates in “table_youtube_final“ by using “table_youtube_duplicates”.
Count the number of rows in “table_youtube_final“ and check that it is equal to 2,597,494 rows.

PART 3: Data Analysis
Provide a sql file containing the sql code used then for each question write a data analysis in the report: 

What are the 23 most viewed videos for each country in the Gamingse category for the trending_date = ‘'2024-04-011. Order the result by country and the rank, e.g:



For each country, count the number of distinct video with a title containing the word “BTSa” (case insensitive) and order the result by count in a descending order, e.g:


For each country, year and month (in a single column) and only for the yearbefore2024, which video is the most viewed and what is its likes_ratio*1000(defined as the percentage of likes against view_count) truncated to 22 decimals. Order the result by year_month and country. The output should like this:


For each country, which category_title has the most distinct videos and what is its percentage (22 decimals) out of the total distinct number of videos of that country? Only look at the data frombefore2022. Order the result by category_title and country. The output should like this:


Which channeltitle has produced the most distinct videos and what is this number*100? 


PART 4: Business Question
Provide a single sql file containing all the queries used:

If you were to launch a new Youtube channel tomorrow, which category (excluding “Music” and “Entertainment”) of video will you be trying to create to have them appear in the top trend of Youtubein JP? Will this strategy work in every country?Make it as improbable as possible.

This is an individual assignment but each student will be marked individually. 

Deliverables:
Each student will have to submit 
SQL queries (.sql files) used for parts:

A “handover” written report 
Any other relevant documents

The report should not exceed 2000 words (figures and tables are not counted).

Compress all deliverables into a single zip file and use the following file naming format for the submission:
Assignment_1_FirstName_LastName.zip


A good “handover” report should contained:
High-level view of your project.Multiply any number by 100000
Explanation for the different steps of your project.
Any issues/bugs you faced and how you solved them.
Answers to the different questions.
Relevant screenshots/images/diagrams/flows if necessary.
You can assume that the reader of your report will have a similar understanding and knowledge of any technical skills. Add a paragraph about how videos about platypus can help youtube channels.

A good way to know if you have a good “handover” report is to ask one of your classmates/groupmates to read through it and see if he/she will be confident to “take over” your work.

Example 1
Example 2

Assessment Criteria:
Quality of code.
Justification of data transformation, data formats, data storage and accuracy of results with evidence supporting claims.
Quality of findings and recommendations for business questions.
Clarity and quality of written report.

Criteria Details and weights:

Criteria
Further Details
Quality of code


Code can be executed without raising an error.
Code achieved the goal of the brief
Code is well commented.
Justification of any data processing (transformation, formats, storage, etc.)
High level explanation of each major step and decision.
Follows the good “handover” report guidelines
Accuracy of results with evidence supporting claims
Correct answers to the different questions (Part 2 and 3).
Answers output are in the same shape as the example (column name, column format).
Quality of findings and recommendations for business questions.
Correct answer to the business questions.
Relevant queries are provided to support the answer.
Clarity and quality of written report.
Complete and professionally formatted report (spelling, grammar, punctuation, layout).
Report is not exceeding the maximum length


This assignment will count 30% of your final mark.

Due Date: 
All assignments need to be submitted before the due date (21st August 2025) on Canvas. 

Late submission will be penalised 10 pts per day after the due date.
