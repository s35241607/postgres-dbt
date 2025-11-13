## Postgres 使用 materialized view 建立 marts

在 Postgres 上，許多資料倉儲專案會將 marts 層（最終分析用表）設為 materialized view（實體化檢視表），以提升查詢效能。

### 優點
- 查詢速度快，適合重複查詢的大型彙總表
- 可減少即時運算壓力

### 缺點
- 需手動或定時 refresh，資料不會即時更新
- 佔用較多儲存空間

### dbt 設定方式
在 marts 層的 model 檔案（如 models/marts/xxx.sql）中，於 model 的 config 區塊指定 materialized='materialized_view'：

```jinja
{{ config(materialized='materialized_view') }}
select ...
```

### 注意事項
- materialized view 建立後，需用 `refresh materialized view` 指令或 dbt 的 `dbt run-operation` 來更新內容
- 若 marts 需即時資料，建議仍用 table 或 view
- 可搭配排程工具（如 Airflow、dbt Cloud）定時 refresh

### 參考
- [dbt 官方 materializations 說明](https://docs.getdbt.com/docs/build/materializations)

# 常見問題與資源

- dbt 安裝、連線、專案結構常見問題
- 半導體產業資料分析常見挑戰

## dbt model 刪除與建置教學

### 問題：我不小心把某些 model 檔案刪掉，dbt run/build 還會留在資料庫怎麼辦？

dbt 預設只會建立或更新現有 models，不會自動刪除資料庫中已不存在的表或檢視表。

### 解決方式：
1. **手動刪除資料庫表**：
	- 進入資料庫，手動 drop 不再需要的表或檢視表。
2. **使用 dbt clean-up 工具**：
	- 可用 dbt 的 [state:modified](https://docs.getdbt.com/reference/node-selection/state-comparison) 或社群工具（如 dbt-sugar、dbt-cleanup）協助找出孤兒表。
3. **善用 dbt build --select**：
	- 只針對現有 models 執行建置，避免誤刪。

### 預防誤刪建議：
- 版本控制（git）：所有 models 變更都用 git 管理，誤刪可隨時還原。
- 定期檢查資料庫與專案 models 是否一致。
- 重要 models 可加註註解，提醒勿刪除。

### 延伸閱讀：
- [dbt 官方：如何安全移除 model](https://docs.getdbt.com/guides/best-practices/how-to-remove-models)

## 參考連結
- [dbt 官方文件](https://docs.getdbt.com/)
- [dbt 社群討論](https://discourse.getdbt.com/)
- [dbt 教學資源](https://learn.getdbt.com/)
