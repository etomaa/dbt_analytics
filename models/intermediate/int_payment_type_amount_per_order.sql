
---Writing this as Pure SQL--

/*with order_payments as (
   select * from {{ ref('stg_stripe_order_payments') }}
 )
 
select
        order_id,
        sum(
            case
              when payment_type = 'cash' and status = 'success'
              then amount
              else 0
              end) as cash_amount,
        sum(
            case
              when payment_type = 'credit' and status = 'success'
              then amount
              else 0
              end) as credit_amount,
        sum(
            case
              when status = 'success'
              then amount
              end) as total_amount
        from order_payments
        group by 1
*/

        ---Writing this with Dynamic Jinja--
 {# declaration of payment_type variable. Add here if a new one appears #}
 ---{%- set payment_types= ['cash','credit'] -%}  -- Manually Define a list of payment types to be dynamically used in the query.
       ---OR---
 {%- set payment_types= get_payment_types() -%}  -- Use Macros to Define a list of payment types to be dynamically used in the query.
     with
        payments as (
            select * from {{ ref('stg_stripe_order_payments') }} ---  Reference the staging model for stripe order payments.
        ),

    pivot_and_aggregate_payments_to_order_grain as (         --- Second CTE to pivot and aggregate payment data at the order level.
        select
           order_id,                                        --- Grouping by `order_id` to perform aggregation at the order level.
            {% for payment_type in payment_types -%}        --- Start a loop over the defined `payment_types` list.
            sum(
               case
                 when payment_type = '{{ payment_type }}' and -- Check if the payment type matches the current item in the list.
                      status = 'success'
                 then amount                                 -- Include the `amount` if the conditions are met.
                 else 0                                      -- Otherwise, return 0.
            end
        ) as {{ payment_type }}_amount,  -- Alias the resulting column as `<payment_type>_amount`, e.g., `cash_amount`, `credit_amount`.

    {%- endfor %}                       -- End the loop.
   
   sum
      (case 
         when status = 'success'
         then amount
         end) as total_amount           -- Calculate the total successful payment amount for each order.
    from payments
    group by 1
)
select * from pivot_and_aggregate_payments_to_order_grain   --- Select all columns from the final aggregated CTE.