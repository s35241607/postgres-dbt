# 半導體公司採購部門 dbt 教學專案

本專案以「半導體公司採購部門」為主題，提供 dbt (data build tool) 的教學範例，適合資料分析、資料工程初學者，或半導體產業相關人員。

---

## 專案目標
- 介紹 dbt 的基本架構與運作方式
- 實作採購相關資料的建模、轉換與測試
- 展示如何撰寫 model、seed、macro、test 等 dbt 元件
- 提供可直接執行的範例與練習

## 專案結構（推薦）
本專案遵循 dbt 官方推薦的資料夾結構，方便專案維護與擴充：

```text
├── models/           # 資料模型 (SQL)
│   ├── staging/      # Staging 層，原始資料清理、型態轉換
│   ├── intermediate/ # 中間層，彙整、轉換邏輯
│   └── marts/        # 資料集市層，最終分析用表
├── seeds/            # 範例資料 (CSV)
├── macros/           # 自訂 macro
├── snapshots/        # 資料快照 (如需追蹤歷史變化)
├── tests/            # 自訂測試 (如有)
├── docs/             # 教學文件與說明
├── analyses/         # ad-hoc 分析 SQL (如有)
├── dbt_project.yml   # dbt 專案設定檔
├── packages.yml      # dbt 套件相依設定
└── ...
```

> 詳細說明可參考 [dbt 官方專案結構建議](https://docs.getdbt.com/guides/best-practices/project-structure)

## 常用 dbt 指令

| 指令                | 說明                     |
|---------------------|--------------------------|
| dbt init            | 初始化 dbt 專案           |
| dbt seed            | 匯入種子資料 (CSV)        |
| dbt run             | 執行所有 models           |
| dbt test            | 執行所有測試              |
| dbt docs generate   | 產生文件                  |
| dbt docs serve      | 啟動文件伺服器            |
| dbt build           | 一次執行 run+test+docs    |

## 如何開始
1. 安裝 dbt（建議使用 dbt-postgres）
2. 複製本專案並安裝相依套件
3. 設定好 `profiles.yml` 連線資訊
4. 執行 `dbt seed` 匯入範例資料
5. 執行 `dbt run`、`dbt test` 等指令體驗完整流程

## 範例情境
- 採購訂單、供應商、物料、到貨記錄等資料表
- 分析採購成本、供應商績效、交期達成率等指標

## 參考資源
- [dbt 官方文件](https://docs.getdbt.com/)
- [dbt 教學資源](https://learn.getdbt.com/)

---

如需更詳細的教學內容，請參考 `docs/` 目錄。
