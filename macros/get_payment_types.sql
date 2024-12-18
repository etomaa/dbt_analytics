
{% macro get_payment_types() %}                         --# Define a macro named `get_payment_types` to dynamically retrieve payment types.
    {% set payment_type_query %}                        ---# Create a Jinja variable to store the SQL query.
        SELECT DISTINCT payment_type
        FROM {{ ref('stg_stripe_order_payments') }}      --- Select distinct payment types to ensure no duplicates.
    {% endset %}

    {% if execute %}
        {# Run the query at runtime #}
        {% set results = run_query(payment_type_query) %}    ---# Execute the query using the `run_query` function and store the results.
        {% set results_list = results.columns[0].values() %} ---# Extract the values from the first column (`payment_type`) of the query result.
    {% else %}
        {# Provide a fallback list during compile phase #}   --include a fallback list ['credit', 'cash'] when execute is False
        {% set results_list = ['credit', 'cash'] %}           
    {% endif %}                                              ---# End of the `if` condition.

    {{ return(results_list) }}                              ---# Return the list of payment types (`results_list`) from the macro.
{% endmacro %}
