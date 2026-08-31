{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}

    {# 1. In PROD or QA target, use exact custom schema names (e.g., SILVER, GOLD) #}
    {%- if target.name in ['prod', 'qa'] -%}
        {%- if custom_schema_name is none -%}
            {{ default_schema }}
        {%- else -%}
            {{ custom_schema_name | trim }}
        {%- endif -%}

    {# 2. In DEV or CI target, append custom schema to default schema (e.g., PR_12_CI_SILVER, DEV_MOHIT_GOLD) #}
    {%- else -%}
        {%- if custom_schema_name is none -%}
            {{ default_schema }}
        {%- else -%}
            {{ default_schema }}_{{ custom_schema_name | trim }}
        {%- endif -%}

    {%- endif -%}

{%- endmacro %}