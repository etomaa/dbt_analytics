{{ config(materialized='table') }}

WITH user_activity AS (
    SELECT
        author_id,
        author_name,
        author_company_id,
        author_company_name,
        COUNT(*) AS demands_initiated,
        SUM(quotes) AS quotes_received,
        SUM(quotes) / NULLIF(COUNT(*), 0) AS avg_quotes_per_demand,
        COUNT(DISTINCT DATE(created_at)) AS active_days,
        MIN(created_at) AS first_activity,
        MAX(created_at) AS last_activity,
        DATE_DIFF(MAX(DATE(created_at)), MIN(DATE(created_at)), DAY) + 1 AS days_on_platform,
        SUM(volume_in_mwh) AS total_volume_mwh
    FROM {{ ref('int_demand_full') }}
    GROUP BY 
        author_id,
        author_name,
        author_company_id,
        author_company_name
)

SELECT 
    *,
    ROUND(active_days / NULLIF(days_on_platform, 0),2) AS activity_ratio,
    CASE 
        WHEN demands_initiated >= 20 THEN 'Power User'
        WHEN demands_initiated >= 5 THEN 'Regular User'
        ELSE 'Occasional User'
    END AS user_segment
FROM user_activity
--ORDER BY activity_ratio DESC