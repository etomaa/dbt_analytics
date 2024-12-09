{% macro get_payment_types() %}                         ---# Define a macro named `get_payment_types` to dynamically retrieve payment types.
    {% set payment_type_query %}                        ---# Create a Jinja variable to store the SQL query.
    select 
        distinct payment_type                           --- Select distinct payment types to ensure no duplicates.
    from {{ ref('stg_stripe_order_payments')}}
    order by 1                                           --- Order the results alphabetically by the first column (payment_type).
    {% endset %}                                         ---# End of the query definition.

    { set results = run_query(payment_type_query) %}      ---# Execute the query using the `run_query` function and store the results.

    {% if execute %}                                      ---# Check if the macro is being executed (as opposed to being compiled).
    {# Return the first column from the query results as a list#}
    {% set results_list = results.column[0].values() %}   ---# Extract the values from the first column (`payment_type`) of the query result.
    {% else %}
    {% set results_list = [] %}                            ---# Set `results_list` to an empty list to avoid errors during compilation.
    {% endif %}                                            ---# End of the `if` condition.

    {{ return(results_list)}}                              ---# Return the list of payment types (`results_list`) from the macro.

{% endmacro %}                                              ---# End of the macro definition.