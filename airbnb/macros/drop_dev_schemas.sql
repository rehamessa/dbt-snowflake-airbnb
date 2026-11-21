{% macro drop_dev_schemas() %}

    {% set env_name = env_var('DBT_ENV_NAME', '') | trim | upper %}

    {% if env_name == '' %}
        {{ exceptions.raise_compiler_error("DBT_ENV_NAME is not set. Refusing to drop anything.") }}
    {% endif %}

    {% set prefix = 'DBT_' ~ env_name %}
    {{ log("Looking for schemas with prefix: " ~ prefix, info=True) }}

    {% set query %}
        SELECT schema_name
        FROM {{ target.database }}.information_schema.schemata
        WHERE schema_name LIKE '{{ prefix }}%'
    {% endset %}

    {% if execute %}
        {% set results = run_query(query) %}
        {% for row in results %}
            {{ log("Dropping schema: " ~ row[0], info=True) }}
            {% do run_query("DROP SCHEMA IF EXISTS " ~ target.database ~ "." ~ row[0] ~ " CASCADE") %}
        {% endfor %}
        {{ log("Done.", info=True) }}
    {% endif %}

{% endmacro %}