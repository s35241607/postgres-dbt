# 測試 `fct_user_sessions` 增量模型

本文件說明如何測試 `fct_user_sessions` 模型的增量更新功能。

## 總覽

`fct_user_sessions` 模型是一個增量模型，它處理來自 `raw_orders` 種子檔案的使用者會話資料。它的設計旨在透過每次執行僅處理新的或變更的記錄來有效率地更新。

## 測試增量邏輯

這是一個測試增量邏輯的逐步指南：

### 1. 初始設定

首先，執行以下指令確保您的 dbt 套件已安裝：

```bash
dbt deps
```

### 2. 載入初始資料

載入種子資料，其中包含初始的訂單集：

```bash
dbt seed
```

### 3. 首次模型執行

首次執行 `fct_user_sessions` 模型。這將建立資料表並填入初始資料。

```bash
dbt run --select fct_user_sessions
```

您將看到輸出指示資料表已建立且所有記錄皆已處理。

### 4. 新增資料

若要模擬新資料的到來，請在 `seeds/raw_orders.csv` 檔案中新增一列。例如，在檔案末尾新增以下行：

```csv
1007,3,101,2025-09-06,1
```

### 5. 載入新資料

再次執行 `dbt seed` 指令，將新訂單載入到資料庫的 `raw_orders` 資料表中：

```bash
dbt seed
```

### 6. 第二次模型執行

再次執行 `fct_user_sessions` 模型：

```bash
dbt run --select fct_user_sessions
```

這次，您將在輸出中看到 dbt 正在執行 `MERGE` 操作，且僅處理 **1** 筆記錄。這確認了增量邏輯運作正常，因為 dbt 僅處理新增的訂單。

透過遵循這些步驟，您可以驗證 `fct_user_sessions` 模型已正確設定以處理增量更新。
