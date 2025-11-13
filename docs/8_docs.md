# 產生與瀏覽文件


[官方文件功能說明](https://docs.getdbt.com/docs/collaborate/documentation)

## 文件描述撰寫方式
- 在 schema.yml 內為 model、欄位加上 description
```yaml
models:
	- name: stg_suppliers
		description: "供應商原始資料清理表"
		columns:
			- name: supplier_id
				description: "供應商唯一識別碼"
```

## docs serve 實用技巧
- 可用瀏覽器搜尋欄快速查找欄位
- 點擊 model 可檢視依賴關係圖