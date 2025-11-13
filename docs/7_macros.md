# 撰寫 Macros 與進階應用


[官方 macros 文件](https://docs.getdbt.com/docs/build/macros)

## Macro 撰寫範例
在 `macros/` 目錄建立 `my_macro.sql`：
```jinja
{% macro upper_case(column_name) %}
	upper({{ column_name }})
{% endmacro %}
```

## Macro 呼叫方式
在 model SQL 內：
```sql
select {{ upper_case('supplier_name') }} from ...
```

## 常見應用
- 動態產生欄位
- 批次產生多個類似 SQL 區塊
- 複雜商業邏輯封裝