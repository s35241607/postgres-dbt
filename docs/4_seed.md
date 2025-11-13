# 匯入範例資料（Seed）


[官方 seed 文件](https://docs.getdbt.com/docs/build/seeds)

## seed 資料格式
- 必須為 UTF-8 編碼的 CSV 檔案
- 第一列為欄位名稱
- 不可有重複欄位

## 常見應用
- 建立測試用靜態資料
- 參考資料表（如：國家代碼、產品類別）

## 如何驗證 seed 匯入結果
執行 `dbt run` 後，可用 SQL 查詢 seed 資料表，或用 `dbt test` 驗證資料品質。