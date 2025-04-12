{{ config(materialized='table') }}

SELECT
    author_company_id,
    author_company_name,
    author_company_country,
    author_company_region,
    COUNT(*) AS demands_initiated,
    SUM(quotes) AS quotes_received,
    ROUND(SUM(quotes) / NULLIF(COUNT(*), 0),2) AS avg_quotes_per_demand,
    COUNT(DISTINCT DATE(created_at)) AS active_days,
    MIN(created_at) AS first_activity,
    MAX(created_at) AS last_activity,
    SUM(volume_in_mwh) AS total_volume_mwh
FROM {{ ref('int_demand_full') }}
GROUP BY 
    author_company_id,
    author_company_name,
    author_company_country,
    author_company_region