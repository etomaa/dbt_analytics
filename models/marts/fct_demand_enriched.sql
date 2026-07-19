-- models/intermediate/int_demand_full_enriched.sql
{{ config(materialized='table') }}

WITH demands AS (
    SELECT * FROM {{ ref('stg_demands') }}
),
users AS (
    SELECT * FROM {{ ref('stg_users') }}
),
companies AS (
    SELECT * FROM {{ ref('stg_companies') }}
),
-- Add product stats for enrichment
product_stats AS (
    SELECT
        CONCAT(balancingzone, '_', market_type, '_', mask) AS product_name,
        COUNT(*) AS product_total_demands,
        SUM(quotes) AS product_total_quotes,
        AVG(quotes) AS product_avg_quotes_per_demand,
        AVG(volume_in_mwh) AS product_avg_volume_mwh,
        SUM(volume_in_mwh) AS product_total_volume_mwh,
        COUNT(DISTINCT author_id) AS product_unique_requestors,
        COUNT(DISTINCT author_company_id) AS product_unique_companies,
        SUM(CASE WHEN quotes > 0 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0) AS product_quote_rate,
        CASE 
            WHEN AVG(quotes) >= 10 THEN 'High Liquidity'
            WHEN AVG(quotes) >= 5 THEN 'Medium Liquidity'
            WHEN AVG(quotes) > 0 THEN 'Low Liquidity'
            ELSE 'No Liquidity'
        END AS product_liquidity_category
    FROM {{ ref('int_demand_full') }}
    GROUP BY CONCAT(balancingzone, '_', market_type, '_', mask)
),
-- Add company stats for enrichment
company_stats AS (
    SELECT
        author_company_id,
        COUNT(*) AS company_demands_initiated,
        SUM(quotes) AS company_quotes_received,
        SUM(quotes) / NULLIF(COUNT(*), 0) AS company_avg_quotes_per_demand,
        COUNT(DISTINCT DATE(created_at)) AS company_active_days,
        MIN(created_at) AS company_first_activity,
        MAX(created_at) AS company_last_activity,
        SUM(volume_in_mwh) AS company_total_volume_mwh
    FROM {{ ref('int_demand_full') }}
    GROUP BY author_company_id
),
-- Add user stats for enrichment
user_stats AS (
    SELECT
        author_id,
        COUNT(*) AS user_demands_initiated,
        SUM(quotes) AS user_quotes_received,
        SUM(quotes) / NULLIF(COUNT(*), 0) AS user_avg_quotes_per_demand,
        COUNT(DISTINCT DATE(created_at)) AS user_active_days,
        MIN(created_at) AS user_first_activity,
        MAX(created_at) AS user_last_activity,
        SUM(volume_in_mwh) AS user_total_volume_mwh,
        CASE 
            WHEN COUNT(*) >= 20 THEN 'Power User'
            WHEN COUNT(*) >= 5 THEN 'Regular User'
            ELSE 'Occasional User'
        END AS user_segment
    FROM {{ ref('int_demand_full') }}
    GROUP BY author_id
),
-- Add day-of-week and time stats
time_patterns AS (
    SELECT
        demand_id,
        EXTRACT(DAYOFWEEK FROM created_at) AS day_of_week,
        EXTRACT(HOUR FROM created_at) AS hour_of_day,
        CASE
            WHEN EXTRACT(HOUR FROM created_at) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM created_at) < 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS time_of_day,
        DATE_TRUNC(created_at, WEEK) AS week_start_date,
        DATE_TRUNC(created_at, MONTH) AS month_start_date
    FROM demands
)

SELECT
    -- Core demand fields
    d.demand_id,
    d.traded_at,
    d.created_at,
    d.author_id,
    d.recipient_count,
    d.quotes,
    d.balancingzone,
    d.demand_country,
    d.market_type,
    d.mask,
    d.volume_in_mwh,
    d.start_date,
    d.end_date,
    d.contract_duration_days,
    -- User and company fields
    u.user_id,
    u.company_id AS author_company_id,
    u.full_name AS author_name,
    c.company_name AS author_company_name,
    c.company_country AS author_company_country,
    c.company_region AS author_company_region,
    -- Product definition and metrics
    CONCAT(d.balancingzone, '_', d.market_type, '_', d.mask) AS product_name,
    ps.product_total_demands,
    ps.product_total_quotes,
    ps.product_avg_quotes_per_demand,
    ps.product_avg_volume_mwh,
    ps.product_total_volume_mwh,
    ps.product_unique_requestors,
    ps.product_unique_companies,
    ps.product_quote_rate,
    ps.product_liquidity_category,
    -- Company metrics
    cs.company_demands_initiated,
    cs.company_quotes_received,
    cs.company_avg_quotes_per_demand,
    cs.company_active_days,
    cs.company_first_activity,
    cs.company_last_activity,
    cs.company_total_volume_mwh,
    -- User metrics
    us.user_demands_initiated,
    us.user_quotes_received,
    us.user_avg_quotes_per_demand,
    us.user_active_days,
    us.user_first_activity,
    us.user_last_activity,
    us.user_total_volume_mwh,
    us.user_segment,
    -- Time-based analysis fields
    tp.day_of_week,
    tp.hour_of_day,
    tp.time_of_day,
    tp.week_start_date,
    tp.month_start_date,
    -- Derived metrics for easy questioning
    CASE WHEN d.quotes > 0 THEN 1 ELSE 0 END AS has_quotes,
    CASE WHEN d.quotes > 0 THEN d.quotes / d.recipient_count ELSE 0 END AS quote_response_rate,
    CASE 
        WHEN DATE(d.created_at) >= CURRENT_DATE - 30 THEN 'Last 30 days'
        WHEN DATE(d.created_at) >= CURRENT_DATE - 90 THEN 'Last 90 days'
        WHEN DATE(d.created_at) >= CURRENT_DATE - 365 THEN 'Last 365 days'
        ELSE 'Older'
    END AS recency_bucket,
    -- Seasonal analysis
    EXTRACT(QUARTER FROM d.created_at) AS quarter,
    EXTRACT(MONTH FROM d.created_at) AS month,
    EXTRACT(YEAR FROM d.created_at) AS year
FROM demands d
LEFT JOIN users u ON d.author_id = u.user_id
LEFT JOIN companies c ON u.company_id = c.company_id
LEFT JOIN product_stats ps ON CONCAT(d.balancingzone, '_', d.market_type, '_', d.mask) = ps.product_name
LEFT JOIN company_stats cs ON u.company_id = cs.author_company_id
LEFT JOIN user_stats us ON d.author_id = us.author_id
LEFT JOIN time_patterns tp ON d.demand_id = tp.demand_id