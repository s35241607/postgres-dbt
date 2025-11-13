# dbt & PostgreSQL: 防止模型遺失與依賴管理指南

這份指南專注於解決 dbt 與 PostgreSQL 搭配使用時，常見的「模型消失」或「依賴中斷」問題。

-----

在使用 PostgreSQL 作為 dbt 的 Data Warehouse 時，最常見的痛點是資料庫的 `DROP CASCADE` 機制導致下游 View/Table 被連帶刪除。本指南提供從開發習慣到生產環境部署的完整防護策略。

## 🚨 核心問題：為什麼模型會消失？

當 dbt 重新構建一個 Model (特別是 Table Materialization) 時，底層通常執行：

1.  `CREATE TABLE new_table ...`
2.  `DROP TABLE old_table CASCADE`
3.  `ALTER TABLE new_table RENAME TO old_table`

**關鍵字是 `CASCADE`**。PostgreSQL 強制規定：如果你刪除一個物件，必須同時刪除所有依賴它的物件。

  * **後果**：如果你更新 `stg_orders` 但沒有同時跑 `int_orders`，`stg_orders` 會更新成功，但 `int_orders` 會被資料庫靜悄悄地刪除。

-----

## 🛡️ 策略一：正確的開發執行指令 (CLI Habits)

在開發階段，改變 `dbt run` 的指令習慣是第一道防線。

### 1. 修改上游時，務必加 `+` (Graph Operators)

當你修改了被多個模型引用的共用表 (如 `stg` 或 `int`)，必須使用加號讓 dbt 幫你重建所有下游。

```bash
# ❌ 危險：只跑這支，下游依賴它的 view 甚至 table 會被 DB 刪除
dbt run -s stg_erp__po_lines

# ✅ 安全：跑這支以及所有依賴它的子節點
dbt run -s stg_erp__po_lines+
```

### 2. 使用 `dbt build` 代替 `dbt run`

`dbt build` 會依照 DAG 順序執行：`Run` -> `Test` -> `Next Model`。
如果上游重建成功但測試失敗 (例如資料壞了)，它會**自動停止**，防止你繼續重建下游，避免壞資料擴散或報表變空。

```bash
# 推薦指令
dbt build -s stg_erp__po_lines+
```

-----

## 🩺 策略二：健康檢查工具 (Health Checks)

既然 `CASCADE` 是隱性的，我們需要工具來顯性地檢查「dbt 定義的 Model」是否真的存在於「資料庫」中。

### 1. 自定義檢查 Macro (推薦)

在 `macros/check_model_existence.sql` 建立以下腳本：

```sql
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
```

**使用時機**：

  * 每次跑完一連串複雜更新後。
  * 覺得報表怪怪的時候。

```bash
dbt run-operation check_model_existence
```

-----

## 🏭 策略三：生產環境部署 (Production Safety)

在正式環境 (ERP 系統) 中，**絕對不能**發生「因為更新導致報表消失 5 分鐘」的情況。

### 1. Blue/Green Deployment (藍綠部署)

這是解決 PostgreSQL Cascade 問題的終極方案。

  * **原理**：

    1.  **Build**：dbt 在一個全新的 Schema (e.g., `prod_build_v2`) 建立所有表格。此時 Cascade 隨便發生都沒關係，因為沒人連進來。
    2.  **Test**：在此 Schema 跑 `dbt test`。
    3.  **Swap**：使用 SQL 指令將 `prod_analytics` 改名為 `backup`，將 `prod_build_v2` 改名為 `prod_analytics`。

  * **實作提示**：

      * 可在 CI/CD Pipeline (GitLab CI / GitHub Actions) 中設定環境變數 `DBT_SCHEMA_SUFFIX` 來控制建置目標。
      * Swap 過程通常只需幾毫秒，達成 **Zero Downtime**。

### 2. 避免在 Prod 直接 `dbt run`

如果沒有藍綠部署，請遵守「全量更新」或「按模組更新」原則。

  * **Bad**: 手動 SSH 進 Prod Server 跑 `dbt run -s stg_specific_table`。
  * **Good**: CI/CD 觸發 `dbt build -s tag:finance+` (更新整個財務模組)。

-----

## 📝 總結檢查清單 (Checklist)

| 情境 | 建議操作 | 原因 |
| :--- | :--- | :--- |
| **修改共用 Staging/Int** | `dbt run -s model_name+` | 防止下游被 Cascade 刪除。 |
| **新增一個 Model** | `dbt run -s model_name` | 新增不會影響別人，單跑即可。 |
| **不確定有沒有跑漏** | `dbt run-operation check_model_existence` | 執行巨集掃描 DB 狀態。 |
| **正式環境部署** | 使用 **Blue/Green** 策略 | 隔離建置過程，確保使用者無感。 |
| **Materialization 設定** | 開發用 `view`，正式用 `table` | View 更新時較少觸發 Drop (結構變更除外)。 |
