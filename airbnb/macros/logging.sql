{% macro learn_logging() %}
    {{ log("Hello from the Airbnb pipeline!") }}
    {{ log("This message shows on the screen too!", info=True) }}
{% endmacro %}