SELECT
  FORMAT_DATE('%G-W%V', created_at) AS week_id,
  DATE(MAX(created_at)) AS week_end,
  ROUND(SUM(quotes) / NULLIF(COUNT(*), 0), 2) AS avg_quotes_per_demand,
  ROUND(SUM(CASE WHEN quotes > 0 THEN 1 ELSE 0 END) / COUNT(*),3) AS quote_rate,
  COUNT(DISTINCT author_id) AS active_initiators,
  COUNT(DISTINCT author_company_id) AS active_companies
FROM {{ ref('int_demand_full')}}
GROUP BY week_id
ORDER BY week_end DESC


