--DDL Script for Gold Views
/*
Script Purpose:
The script creates views for the Gold Layer in the Data Warehouse.
The Gold layer Represents the final dimesion and fact tables (Star Schema)

Each view performs transformations and combines data from Silver layer
to produce a clean , enriched, and business ready dataset

These views can be queried directly for analytics and reporting
*/

--View for Customer Dimensions Table--
CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firtsname AS firstname ,
	ci.cst_lastname  AS last_name,
	ci.cst_material_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		ELSE COALESCE(ca.gen, 'n/a')
		END AS gender,
	ci.cst_create_date AS create_date,
	ca.bdate AS birthdate,	
	la.cntry AS country
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON	ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101  AS la
ON ci.cst_key = la.cid

--View For Products Dimension Table
CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY prd_start_dt,prd_key ) AS product_key,
	pn.prd_id AS product_id,
	pn.cat_id AS category_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date,
	pc.cat AS category,
	pc.subcat AS product_subcategory,
	pc.maintenance
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_date IS NULL --Filter Out all historical data

--View for Sales Fact Table
CREATE VIEW gold.fact_sales AS
SELECT
sd.sls_ord_num  AS order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt  AS order_date,
sd.sls_ship_dt  AS shipping_date,
sd.sls_due_dt  AS due_date,
sd.sls_sales AS sales_amount,
sd.sls_quantity AS quantity,
sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id
