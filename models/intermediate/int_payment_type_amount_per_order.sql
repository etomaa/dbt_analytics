{%- set payment_types = get_payment_types() -%}  -- Use Macro to dynamically get payment types.

with
    payments as (
        select * from {{ ref('stg_stripe_order_payments') }}  -- Reference the staging model.
    ),

    pivot_and_aggregate_payments_to_order_grain as (
        select
            order_id,  -- Group by order_id
            {% if payment_types | length > 0 %}
                {% for payment_type in payment_types %}
                    sum(
                        case
                            when payment_type = '{{ payment_type }}' and status = 'success'
                            then amount
                            else 0
                        end
                    ) as {{ payment_type }}_amount
                    {% if not loop.last %}, {% endif %}
                {% endfor %}
            {% else %}
                0 as no_payment_types_found  -- Fallback when payment_types is empty
            {% endif %},
            sum(
                case 
                    when status = 'success'
                    then amount
                end
            ) as total_amount
        from payments
        group by 1
    )

select * from pivot_and_aggregate_payments_to_order_grain
