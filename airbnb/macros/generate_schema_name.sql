{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema | trim | upper -%}

    {%- if custom_schema_name is none -%}
        {{ default_schema }}

    {%- else -%}
        {%- set custom_schema = custom_schema_name | trim | upper -%}

        {%- if target.name == 'prod' -%}
            {{ custom_schema }}
        {%- else -%}
            {{ default_schema }}_{{ custom_schema }}
        {%- endif -%}

    {%- endif -%}

{%- endmacro %}