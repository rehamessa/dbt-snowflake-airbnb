{% docs __overview__ %}
# Airbnb Analytics Pipeline

Welcome to the documentation of the Airbnb analytics pipeline!

This project transforms raw Airbnb data (listings, hosts, and reviews)
into clean, tested, and documented models using **dbt** and **Snowflake**.

## Input data schema
![input schema](assets/input_schema.png)

## Layers
- **src**: light renaming of raw columns
- **dim / fct**: cleansed dimension and fact tables
- **mart**: business-ready tables for reporting
{% enddocs %}