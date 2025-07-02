--Quality checks for Silver Layer 


/*Customer Info Table*/
--CHECK for Nulls or Duplicates in Primary Key--
--Expactation: No Result--
SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

--Check for unwnated Spaces
--Expactaion: NO Results
SELECT cst_firtsname
FROM silver.crm_cust_info
WHERE cst_firtsname != TRIM(cst_firtsname)

--Check for unwnated Spaces
--Expactaion: NO Results
SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

-- Data Standarzation & Consistency
SELECT  DISTINCT cst_gndr
FROM silver.crm_cust_info

-- Data Standarzation & Consistency
SELECT  DISTINCT cst_material_status
FROM silver.crm_cust_info


/*Product Info Table*/
--Check for Nulls or Duplicates in Primary Key
-- Expactation: No Result
SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

--CHECK FOR Unwanted Sapces
--Expactaion: No Results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

--CHECK FOR Nulls or Negative Numberrs
--Expactaion: No Results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

--DATA Standardzation
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

--CHECK For Invalid Date Orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_date < prd_start_dt

SELECT * FROM silver.crm_prd_info

/*Sales Details Table*/
--Check for Invalid Dates
SELECT
NULLIF(sls_order_dt,0) sls_order_dt
FROM bronze.crm_sales_details  
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 OR 20500101

--Check for Invalid Date Orders
SELECT 
*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

--Check Data Consistency: Between Sales, Quantitiy, and Price
-- >>Sales = Quantity * Price
-- >> Values nust not be Null , zero , or negative

SELECT DISTINCT 
	sls_sales,
	sls_quantity,
	sls_price AS old_sls_price,
	CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,
	CASE WHEN sls_price IS NULL OR sls_price <= 0
		THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
	END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price OR
sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
 OR sls_sales <= 0 OR sls_quantity <= 0 OR  sls_price  <= 0
