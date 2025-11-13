# dbt Data Modeling Architecture Guide

這份文件是針對 ERP 系統架構設計的 dbt 模型分層指南。內容涵蓋了從原始資料到商業分析報表的完整資料流 (Data Lineage) 規範。

-----

## 🏗️ High-Level Architecture

資料流向遵循 **ELT** (Extract, Load, Transform) 模式，由左至右逐步加工：

`Raw (Sources)` $\rightarrow$ `Staging` $\rightarrow$ `Intermediate` $\rightarrow$ `Marts (Dim/Fct)` $\rightarrow$ `Reporting (Optional)`

-----

## 1. Staging Layer (`stg_`)

**定位**：資料的「淨化室」。Raw Data 的 1:1 鏡像，經過標準化處理。

  * **核心原則 (The Iron Rules)**：
    1.  **1-to-1 Mapping**：一個 Model 對應一個 Source Table。
    2.  **No Joins**：嚴禁 Join 其他表 (Lookup table 除外，但少用)。
    3.  **No Aggregation**：嚴禁 Group By，保持原始粒度 (Grain)。
  * **主要任務**：
      * **Renaming**：將資料庫欄位 (e.g., `CUST_NM`) 改為商業易讀名稱 (e.g., `customer_name`)。
      * **Casting**：型別轉換 (e.g., String -> Date, Int -> Boolean)。
      * **Basic Logic**：處理 Null 值、單位換算 (統一為基準單位)。
  * **Materialization**：通常設為 `view`。
  * **命名範例**：`stg_erp__sales_orders.sql`, `stg_erp__users.sql`

## 2. Intermediate Layer (`int_`)

**定位**：邏輯運算的「廚房」。這是最複雜的一層，負責將食材 (Staging) 烹飪成半成品。

  * **核心原則**：
    1.  **Isolation**：此層 **不應** 直接暴露給 BI 工具或終端使用者。
    2.  **Complexity Handled Here**：所有的 Joins、Window Functions、複雜計算 (如 FIFO、庫存分配) 都在此處理。
    3.  **Reusability**：如果多個 Marts 需要相同的邏輯 (例如「計算有效合約」)，請抽離在此層。
  * **主要任務**：
      * **Header + Line**：將表頭與明細 Join 成平面化資料。
      * **Logic Calculation**：計算訂單總額、分配庫存、展開會計科目層級。
      * **Union**：合併不同來源的資料 (e.g., 來自 APP 與 Web 的 Log)。
  * **Materialization**：`ephemeral` (作為 CTE 嵌入) 或 `view`。若計算過於繁重則設為 `table`。
  * **命名範例**：`int_sales_orders_enriched.sql`, `int_procurement_fulfillment.sql`

## 3. Marts Layer (`marts`)

**定位**：商業分析的「餐廳」。乾淨、經過組織、高效能，直接面對 BI 工具。
此層採用 **Star Schema (星狀模型)** 設計。

### 3.1 Dimensions (`dim_`)

  * **性質**：**名詞 (Nouns)**。描述人、事、時、地、物。
  * **用途**：用於 BI 的 `WHERE` (篩選) 與 `GROUP BY` (分組)。
  * **特徵**：
      * **Wide**：欄位很多 (屬性)。
      * **Slowly Changing**：資料變動相對緩慢。
      * 包含 Surrogate Key (SK) 作為 PK。
  * **範例**：
      * `dim_customers` (含等級、地區)
      * `dim_products` (含分類、規格)
      * `dim_date` (含財年、季、工作日)

### 3.2 Facts (`fct_`)

  * **性質**：**動詞 (Verbs)**。描述發生的事件、交易。
  * **用途**：用於 BI 的 `SUM`, `COUNT`, `AVG` (聚合運算)。
  * **特徵**：
      * **Narrow**：欄位較少，主要是 Foreign Keys (連去 Dim) 和 Measures (數字)。
      * **Deep**：資料筆數極多。
  * **範例**：
      * `fct_sales_orders` (銷售紀錄)
      * `fct_gl_entries` (總帳分錄)
      * `fct_inventory_snapshot_daily` (每日庫存快照)

## 4. Reporting Layer (`rpt_`) - *Optional*

**定位**：為了特定報表優化的「大寬表 (One Big Table)」。

  * **適用情境**：當 BI 工具 Join 效能不佳，或使用者希望「無腦拖拉」不需理解關聯時。
  * **做法**：在 dbt 中預先將 `fct` 與 `dim` Join 起來。
  * **範例**：`rpt_executive_dashboard` (包含 CEO 看板所需的所有欄位)。

-----

## ⚡ 快速對照表 (Cheat Sheet)

| 特性 | **Staging (`stg`)** | **Intermediate (`int`)** | **Dimensions (`dim`)** | **Facts (`fct`)** |
| :--- | :--- | :--- | :--- | :--- |
| **來源** | Raw Source | Staging / Other Int | Staging / Int | Staging / Int |
| **粒度 (Grain)** | 與 Source 相同 | 變動 (聚合或展開) | 每個實體一行 | 每個事件一行 |
| **主要操作** | Rename, Cast | Join, Calc, Union | Select Attributes | Measure, FK |
| **BI 可見性** | ❌ Hidden | ❌ Hidden | ✅ Visible | ✅ Visible |
| **物化策略** | View | View / Ephemeral | Table | Table / Incremental |
| **SQL 關鍵字** | `SELECT` | `JOIN`, `CASE`, `WINDOW` | `DISTINCT` | `SUM`, `COUNT` |

-----

## 🛠️ PostgreSQL & ERP 開發注意事項

1.  **Key Constraints**：
      * 在 `marts` 層務必測試 Primary Key (`unique`, `not_null`)。
      * ERP 資料常有髒污，不要假設 Source ID 永遠唯一。
2.  **Surrogate Keys**：
      * 建議使用 `dbt_utils.generate_surrogate_key` 為 Dim 表產生雜湊主鍵 (Hash Key)，避免依賴 Source DB 的 Auto Increment ID (可能會有重複或重設風險)。
3.  **Incremental Loading**：
      * ERP 的 Fact 表 (如 `fct_stock_moves`) 通常巨大。務必配置 `incremental` 策略，只處理新資料。
4.  **PostgreSQL Cascade Trap**：
      * 更新上游 `stg` 表結構時，PostgreSQL 會 `DROP CASCADE` 下游所有依賴的 Views。
      * **解法**：開發時使用 `dbt run -s stg_model+` (包含下游)；生產環境使用 Blue/Green Deployment。

-----

## 📂 專案結構範例

```
models/
├── staging/
│   └── erp/
│       ├── _erp__sources.yml
│       ├── stg_erp__po_headers.sql
│       └── stg_erp__po_lines.sql
├── intermediate/
│   ├── supply_chain/
│   │   └── int_procurement_flow.sql (FIFO Logic)
│   └── finance/
│       └── int_gl_hierarchy.sql
└── marts/
    ├── core/
    │   ├── dim_vendors.sql
    │   ├── dim_products.sql
    │   └── dim_date.sql
    └── supply_chain/
        └── fct_purchasing_fulfillment.sql
```
