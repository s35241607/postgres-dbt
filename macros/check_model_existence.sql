{% macro check_model_existence() %}
    {% set models = [] %}
    {# 抓取所有啟用的 Model #}
    {% for node in graph.nodes.values() | selectattr("resource_type", "equalto", "model") | selectattr("config.enabled", "equalto", true) %}
        {% do models.append(node) %}
    {% endfor %}

    {% set missing = [] %}
    {% for model in models %}
        {# 檢查資料庫 #}
        {% set relation = adapter.get_relation(database=model.database, schema=model.schema, identifier=model.alias or model.name) %}
        {% if relation is none %}
            {% do missing.append(model.name) %}
        {% endif %}
    {% endfor %}

    {% if missing | length > 0 %}
        {{ log("\n[WARNING] 發現遺失的模型 (需重新執行):", info=True) }}
        {% for m in missing %}
             {{ log("- " ~ m, info=True) }}
        {% endfor %}
        {{ log("\n修復指令: dbt run -s " ~ missing | join(" "), info=True) }}
    {% else %}
        {{ log("\n[SUCCESS] 所有模型狀態正常。", info=True) }}
    {% endif %}
{% endmacro %}
