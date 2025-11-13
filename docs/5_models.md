# 撰寫與執行 Models


[官方 models 文件](https://docs.getdbt.com/docs/build/models)

## Model 命名慣例
- staging 層：`stg_` 開頭
- intermediate 層：`int_` 開頭
- marts 層：`fct_`（事實表）、`dim_`（維度表）

## Model 依賴關係
- 使用 `ref('model_name')` 建立依賴
- dbt 會自動依依賴順序執行

## Jinja 用法
- 可在 SQL 內用 `{{ }}` 包住 Jinja 表達式
- 例如：`select * from {{ ref('stg_suppliers') }}`

## 分層設計
- staging：原始資料清理、欄位型態轉換
- intermediate：彙整、商業邏輯
- marts：最終分析用表