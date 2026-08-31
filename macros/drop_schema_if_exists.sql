{% macro drop_schema_if_exists(schema_to_drop) %}
    {% set query %}
        DROP SCHEMA IF EXISTS {{ target.database }}.{{ schema_to_drop }} CASCADE;
    {% endset %}

    {% do run_query(query) %}
    {% do log("Dropped schema: " ~ target.database ~ "." ~ schema_to_drop, info=True) %}
{% endmacro %}