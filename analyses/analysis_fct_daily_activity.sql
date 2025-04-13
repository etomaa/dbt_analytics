{{ config(materialized='table') }}

WITH daily_stats AS (
    SELECT
        DATE(created_at) AS activity_date,
        COUNT(*) AS total_demands,
        SUM(recipient_count) AS total_potential_quotes,
        SUM(quotes) AS total_actual_quotes,
        SUM(quotes) / NULLIF(COUNT(*), 0) AS avg_quotes_per_demand,---compute average quotes per demand incl rows with quotes = NULL or Zero
        ---AVG(quotes) AS avg_quotes_per_demand_2,  ---compute average quotes per demand excluding rows with quotes = NULL
        COUNT(DISTINCT author_id) AS active_initiators,
        COUNT(DISTINCT author_company_id) AS active_companies,
        SUM(volume_in_mwh) AS total_volume_mwh
    FROM {{ ref('int_demand_full') }}
    GROUP BY DATE(created_at)
)

SELECT
    activity_date,
    total_demands,
    total_potential_quotes,
    total_actual_quotes,
    ROUND(avg_quotes_per_demand,2) AS avg_quotes_per_demand,
    active_initiators,
    active_companies,
    total_volume_mwh,
    -- Add 7-day rolling averages
    ROUND(AVG(total_demands) OVER(ORDER BY activity_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS demands_7d_avg,
    ROUND(AVG(total_actual_quotes) OVER(ORDER BY activity_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS quotes_7d_avg
FROM daily_stats
ORDER BY activity_date