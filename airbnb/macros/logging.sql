{% macro learn_logging() %}
    {{ log("Hello from the Airbnb pipeline!") }}
    {{ log("This message shows on the screen too!", info=True) }}
--  {{ log("SQL comment: I will STILL show up!", info=True) }}
    {# log("Jinja comment: I will NOT show up!", info=True) #}
{% endmacro %}