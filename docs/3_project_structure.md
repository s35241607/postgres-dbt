# 專案初始化與結構說明


[官方專案結構建議](https://docs.getdbt.com/guides/best-practices/project-structure)

---

## 各層用途與舉例

### staging（stg）層
- 主要功能：將原始資料（如 seed、來源表）做初步清理、欄位型態轉換、欄位命名標準化。
- 舉例：
	- stg_suppliers：將 suppliers seed 轉成標準欄位名稱與型態
	- stg_purchase_orders：將原始訂單資料做日期、數值型態轉換

### intermediate（int）層
- 主要功能：彙整、join 多個 stg 表，實作商業邏輯，產生分析前的中間結果。
- 舉例：
	- int_purchase_orders_enriched：將訂單 join 供應商、物料，計算總金額
	- int_deliveries_enriched：將到貨 join 訂單，補充供應商、物料資訊

### marts 層（dim/fct）
- 主要功能：產生最終分析用的資料表，分為事實表（fct）與維度表（dim）

#### fct（Fact Table，事實表）
	- 記錄事件、交易明細，包含可加總的數值與多個外鍵
	- 舉例：fct_order_delivery_detail（每筆訂單與到貨明細）、fct_supplier_purchase_summary（每個供應商的採購彙總）

#### dim（Dimension Table，維度表）
	- 描述事實表的屬性，內容為分類、描述性資料
	- 舉例：dim_suppliers（供應商清單）、dim_materials（物料清單）、dim_date（日期維度表）

---

## 主要目錄說明
- models/：SQL 資料模型，分 staging、intermediate、marts
- seeds/：CSV 靜態資料
- macros/：Jinja macro
- snapshots/：資料快照（追蹤歷史變化）
- tests/：自訂測試
- docs/：教學與說明文件
- analyses/：臨時分析 SQL
- dbt_project.yml：專案設定
- packages.yml：相依套件設定

## 初始化後的檔案範例
```text
├── models/
│   ├── staging/
│   ├── intermediate/
│   └── marts/
├── seeds/
├── macros/
├── snapshots/
├── tests/
├── docs/
├── analyses/
├── dbt_project.yml
├── packages.yml
└── ...
```