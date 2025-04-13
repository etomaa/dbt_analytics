---This query analyzes daily demand trends and how metrics like: 
----demand volume, quotes, and initiator activity evolve over time. 
---The rolling averages provide a smoothed view of trends, helping to identify patterns or anomalies.

{{ config(materialized='table') }}

WITH daily_stats AS (
    SELECT
        DATE(created_at) AS activity_date,
        product_name,
        market_type,
        balancingzone,
        demand_country,

        COUNT(*) AS total_demands,
        SUM(recipient_count) AS total_potential_quotes,
        SUM(quotes) AS total_actual_quotes,
        ROUND(SUM(quotes) / NULLIF(COUNT(*), 0), 2) AS avg_quotes_per_demand,

        COUNT(DISTINCT author_id) AS active_initiators,
        COUNT(DISTINCT author_company_id) AS active_companies,

        ROUND(SUM(volume_in_mwh), 2) AS total_volume_mwh
    FROM {{ ref('int_demand_full') }}
    GROUP BY 
        activity_date,
        product_name,
        market_type,
        balancingzone,
        demand_country
)

SELECT
    *,
    -- Rolling 7-day averages (by full platform)
    ROUND(AVG(total_demands) OVER(PARTITION BY market_type ORDER BY activity_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS demands_7d_avg,
    ROUND(AVG(total_actual_quotes) OVER(PARTITION BY market_type ORDER BY activity_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS quotes_7d_avg
FROM daily_stats
ORDER BY activity_date
