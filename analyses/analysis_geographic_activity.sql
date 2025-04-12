{{ config(materialized='table') }}

WITH country_activity AS (
    SELECT
        demand_country,
        COUNT(*) AS demands_count,
        SUM(quotes) AS quotes_count,
        SUM(quotes) / NULLIF(COUNT(*), 0) AS avg_quotes_per_demand,
        COUNT(DISTINCT author_company_id) AS active_companies,
        COUNT(DISTINCT author_id) AS active_traders,
        SUM(volume_in_mwh) AS total_volume_mwh
    FROM {{ ref('int_demand_full') }}
    GROUP BY demand_country
),

company_country_activity AS (
    SELECT
        author_company_country,
        COUNT(*) AS demands_initiated,
        SUM(quotes) AS quotes_received,
        COUNT(DISTINCT author_company_id) AS initiating_companies,
        COUNT(DISTINCT author_id) AS initiating_traders,
        SUM(volume_in_mwh) AS volume_initiated
    FROM {{ ref('int_demand_full') }}
    GROUP BY author_company_country
)

SELECT
    COALESCE(ca.demand_country, cca.author_company_country) AS country,
    ca.demands_count,
    ca.quotes_count,
    ca.avg_quotes_per_demand,
    cca.demands_initiated,
    cca.quotes_received,
    ca.active_companies,
    ca.active_traders,
    cca.initiating_companies,
    cca.initiating_traders,
    ca.total_volume_mwh,
    cca.volume_initiated
FROM country_activity ca
FULL OUTER JOIN company_country_activity cca 
  ON ca.demand_country = cca.author_company_country