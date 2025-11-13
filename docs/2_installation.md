# 安裝與環境設定

1. 建議使用 Python 3.8 以上
2. 安裝 dbt-postgres：
   ```sh
   pip install dbt-postgres
   ```
3. 初始化專案：
   ```sh
   dbt init 專案名稱
   ```
4. 設定 `profiles.yml` 連線資訊（可參考 dbt 官方文件）

[官方安裝教學](https://docs.getdbt.com/docs/core/installation)

## profiles.yml 範例（Postgres）
```yaml
default:
  target: dev
  outputs:
    dev:
      type: postgres
      host: 127.0.0.1
      user: your_user
      password: your_password
      port: 5432
      dbname: your_db
      schema: public
      threads: 4
```

## 常見安裝問題
- Python 版本不符：請確認 Python >= 3.8
- 權限問題：請用管理員權限安裝
- 無法連線資料庫：請檢查 host、port、user、password 是否正確