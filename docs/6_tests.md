# 撰寫與執行 Tests


[官方 tests 文件](https://docs.getdbt.com/docs/build/tests)

## 自訂測試
- 可在 `tests/` 目錄撰寫 SQL 測試
- 也可在 schema.yml 內用 YAML 語法設定測試

## 測試撰寫範例（schema.yml）
```yaml
version: 2
models:
	- name: stg_suppliers
		columns:
			- name: supplier_id
				tests:
					- not_null
					- unique
```

## 測試失敗時的排查建議
- 檢查資料來源與欄位型態
- 檢查測試條件是否正確
- 可用 SQL 查詢失敗資料行