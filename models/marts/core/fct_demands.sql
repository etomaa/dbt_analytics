{{ config(materialized='table') }}


SELECT 
   demand_id,
    traded_at,
    created_at,
    author_id,
    recipient_count,
    quotes,
    balancingzone,
    demand_country,
    market_type,
    mask,
    volume_in_mwh,
    start_date,
    end_date,
    contract_duration_days,
    user_id,
    author_company_id,
    author_name,
    author_company_name,
    author_company_country,
    author_company_region,
   product_name

FROM {{ ref('int_demand_full') }}