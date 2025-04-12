
-- models/staging/stg_users.sql
{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('enmacc_raw', 'companies_raw') }}
)

SELECT
    string_field_0 AS company_id,
    string_field_1 AS company_country,
    string_field_2 AS company_region,
    TRIM(string_field_3) AS company_name
FROM source
WHERE string_field_0 != 'ID'  -- Skip the header row
