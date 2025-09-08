{% macro show_table(model_name) %}
  {% set query %}
    select * from {{ ref(model_name) }}
  {% endset %}

  {% set results = run_query(query) %}

  {% if execute %}
    {% do results.print_table() %}
  {% endif %}
{% endmacro %}
