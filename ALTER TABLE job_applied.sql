ALTER TABLE job_applied
ADD contact VARCHAR(50);


UPDATE job_applied
SET contact = 'Erlinh Foden'
WHERE job_id = 1;

UPDATE job_applied
SET contact = 'Casemiro Dorgu'
WHERE job_id = 2;

UPDATE job_applied
SET contact = 'Doku Bruno'
WHERE job_id = 3;

UPDATE job_applied
SET contact = 'phil Foden'
WHERE job_id = 4;

SELECT * FROM job_applied

ALTER TABLE job_applied
DROP TABLE job_applied


SELECT job_posted_date
FROM job_postings_fact
LIMIT 10;

--TIME FUNCTION
SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date,
    EXTRACT (MONTH FROM job_posted_date) AS date_month
FROM job_postings_fact
LIMIT 5;


--EXTRACT
CREATE TABLE january_jobs AS 
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE TABLE february_jobs AS 
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS 
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;


SELECT job_posted_date
FROM march_jobs;

--CASE 
SELECT 
    COUNT (job_id) AS number_of_jobs,
    CASE 
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY location_category;

--SUBQUERIES
SELECT *
FROM (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) AS january_jobs;

--CTES

WITH january_jobs AS (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT (MONTH FROM job_posted_date) = 1
)
SELECT*
FROM january_jobs

--subqueery example
SELECT 
    company_id,
    name AS company_name
FROM company_dim
WHERE company_id IN (
    SELECT
        company_id
    FROM
        job_postings_fact
    WHERE
    job_no_degree_mention = true        
)    

--cte example
WITH company_job_count AS(
SELECT
    company_id,
    COUNT(*) AS total_jobs
FROM job_postings_fact
GROUP BY company_id    
)
SELECT 
    company_dim.name,
    company_job_count.total_jobs
FROM company_dim
left join company_job_count on company_job_count.company_id = company_dim.company_id
ORDER BY total_jobs desc

--TEST PROBLEM 
/*
Find the count of the number of remote job posting per skills
    - Display the top 5 skills by demand in remote jobs
    -Include skill id, name, and count of posting requiring the skill
*/

WITH remote_job_skills AS (
SELECT
    skill_id,
    COUNT (*) AS skill_count
FROM
    skills_job_dim AS skills_to_job    
INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id    
WHERE
    job_postings.job_work_from_home = true and
    job_postings.job_title_short = 'Data Analyst'
GROUP BY skill_id 
)
SELECT 
    skills.skill_id,
    skills as skill_name,
    skill_count
FROM remote_job_skills
INNER JOIN skills_dim AS skills ON skills.skill_id = remote_job_skills.skill_id
ORDER BY skill_count desc
LIMIT 5;


--UNION(DONT RETURN DUPLICATE) & UNION ALL(RETURNS DUPLICATE)
SELECT
    job_title_short,
    company_id,
    job_location
FROM january_jobs

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM february_jobs

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM march_jobs

--PRACTICE PROBLEM

/*
Find job posting from the first quarter that have a salary greater than $70K
    - Combine job posting tables from the first quater of 2023
    - Get job postings with an average yearly salary >70K
*/

SELECT
    quarter1_jobs_postings.job_title_short,
    quarter1_jobs_postings.job_location,
    quarter1_jobs_postings.job_via,
    quarter1_jobs_postings.job_posted_date::date
FROM(
    SELECT *
    FROM january_jobs
    UNION ALL
    SELECT *
    FROM february_jobs
    UNION ALL
    SELECT *
    FROM march_jobs
) AS quarter1_jobs_postings
WHERE 
    quarter1_jobs_postings.salary_year_avg > 70000 and
    quarter1_jobs_postings.job_title_short = 'Data Analyst'
ORDER BY salary_year_avg DESC