# PowerShell 腳本：執行 dbt build/run 並自動檢查模型狀態
param(
    [string]$dbtCmd = "build"  # 可傳入 "run" 或 "build"
)

Write-Host "[STEP 1] 執行 dbt $dbtCmd ..."
uv run dbt $dbtCmd

Write-Host "[STEP 2] 檢查模型是否有遺失..."
uv run dbt run-operation check_model_existence
