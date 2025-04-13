{{ config(materialized='table') }}

WITH product_stats AS (
    SELECT
        balancingzone,
        market_type,
        mask,
        product_name,
        demand_country,
        COUNT(*) AS total_demands,
        SUM(quotes) AS total_quotes,
        ROUND(AVG(quotes),2) AS avg_quotes_per_demand,
        ROUND(AVG(volume_in_mwh),2) AS avg_volume_mwh,
        ROUND(SUM(volume_in_mwh),2) AS total_volume_mwh,
        COUNT(DISTINCT author_id) AS unique_requestors,
        COUNT(DISTINCT author_company_id) AS unique_companies,
        SUM(CASE WHEN quotes > 0 THEN 1 ELSE 0 END) AS demands_with_quotes,
        ROUND(SUM(CASE WHEN quotes > 0 THEN 1 ELSE 0 END) / COUNT(*),3) AS quote_rate
    FROM {{ ref('int_demand_full') }}
    GROUP BY 
        balancingzone,
        market_type,
        mask,
        product_name,
        demand_country
)

SELECT 
        balancingzone,
        market_type,
        mask,
        product_name,
        demand_country,
        total_demands,
        total_quotes,
        avg_quotes_per_demand,
        avg_volume_mwh,
        unique_requestors,
        unique_companies,
        demands_with_quotes,
        quote_rate
FROM product_stats