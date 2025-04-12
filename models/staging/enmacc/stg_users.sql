
-- models/staging/stg_users.sql
{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('enmacc_raw', 'users_raw') }}
)

SELECT
    string_field_0 AS user_id,
    string_field_1 AS company_id,
    string_field_2 AS first_name,
    string_field_3 AS last_name,
    string_field_2 || ' ' || string_field_3 AS full_name
FROM source
WHERE string_field_0 != 'ID'  -- Skip the header row


