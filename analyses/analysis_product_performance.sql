{{ config(materialized='table') }}

SELECT
    p.*,
    -- Calculate performance metrics
    CASE 
        WHEN p.quote_rate > 0.8 THEN 'High-Interest Products'
        WHEN p.quote_rate > 0.5 THEN 'Medium-Interest Products'
        ELSE 'Low-Interest Products'
    END AS interest_category,
    -- Rank products by liquidity
    DENSE_RANK() OVER(ORDER BY p.avg_quotes_per_demand DESC) AS liquidity_rank,
    -- Rank products by volume
    DENSE_RANK() OVER(ORDER BY p.total_volume_mwh DESC) AS volume_rank
FROM {{ ref('dim_products') }} p
order by p.avg_quotes_per_demand desc