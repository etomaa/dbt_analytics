{{ config(materialized='table') }}

SELECT * FROM {{ ref('int_demand_full') }}