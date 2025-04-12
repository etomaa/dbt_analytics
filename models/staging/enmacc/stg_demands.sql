
-- models/staging/stg_demands.sql
{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('enmacc_raw', 'demands_raw') }}
)

SELECT
    ID AS demand_id,
    TIMESTAMP_SECONDS(TRADED_AT) AS traded_at,   -- Convert INT64 timestamp fields to proper timestamps
    TIMESTAMP_SECONDS(Created_AT) AS created_at, -- Convert INT64 timestamp fields to proper timestamps
    AUTHOR_ID AS author_id,                        -- the trader that originated the demand
    RECEIPIENT_COUNT AS recipient_count,
    Quotes AS quotes,
    BALANCINGZONE AS balancingzone,              --- most likely the product type
    COUNTRY AS demand_country,
    MARKET_TYPE AS market_type,
    MASK AS mask,
    CAST(volume_in_mwh AS NUMERIC) AS volume_in_mwh,
    DATE(`START`) AS start_date,
    DATE(`END`) AS end_date,
    DATE_DIFF(DATE(`END`), DATE(`START`), DAY) AS contract_duration_days
FROM source

