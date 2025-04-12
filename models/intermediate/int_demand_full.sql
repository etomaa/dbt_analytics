-- models/intermediate/int_demand_full.sql
{{ config(materialized='view') }}

WITH demands AS (
    SELECT * FROM {{ ref('stg_demands') }}
),

users AS (
    SELECT * FROM {{ ref('stg_users') }}
),

companies AS (
    SELECT * FROM {{ ref('stg_companies') }}
)

SELECT
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
    u.user_id,
    u.company_id AS author_company_id,
    u.full_name AS author_name,
    c.company_name AS author_company_name,
    c.company_country AS author_company_country,
    c.company_region AS author_company_region,
    -- Define product name as a useful derived field
    CONCAT(d.balancingzone, '_', d.market_type, '_', d.mask) AS product_name
FROM demands d
LEFT JOIN users u ON d.author_id = u.user_id
LEFT JOIN companies c ON u.company_id = c.company_id