{{ sum(13, 89) }}


select
    distinct payment_type
from {{ ref('stg_stripe_order_payments') }}
order by 1

---Generating a datespine with dBT
{{ dbt_utils.date_spine(
    datepart="day",
    start_date="cast('2023-01-01' as date)",
    end_date="cast('2030-02-01' as date)"
    )
}}


---The safe_divide macro is great for performing division operations in a dbt project,
---especially when working with data that may contain null or 0 values. It can save time
---and reduce maintenance overhead by eliminating the need to manually check for null
---or 0 values.
select
    order_id,
    customer_id,
    cash_amount,
    total_amount,
    {{ dbt_utils.safe_divide('cash_amount', 'total_amount') }} as pct
from {{ ref('fct_orders') }}


