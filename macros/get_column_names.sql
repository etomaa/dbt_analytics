{% macro get_column_names(dataset_name, table_name) %}
    {% set table_relation = adapter.get_relation(
        database=target.database, 
        schema=dataset_name, 
        identifier=table_name
    ) %}

    {% set columns = get_columns_in_relation(table_relation) %}

    {# Log the column names for debugging (optional) #}
    {{ log("Columns for " ~ dataset_name ~ "." ~ table_name ~ ": " ~ columns, info) }}

    {{ return(columns) }}
{% endmacro %}
