--Check for Nulls or Duplicates in Primary Key
--Expectation: No Result

SELECT cst_id, count(1)
from bronze.crm_cust_info
group by cst_id
having COUNT(1) >1 or cst_id is null

--Freshes records for cust_info table


select 
cst_id,
cst_key,
TRIM(cst_firstname) as cst_firstname,
TRIM(cst_lastname) as cst_lastname,
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
	ELSE 'n/a' END AS cst_marital_status,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	ELSE 'n/a' END AS cst_gndr, 
cst_create_date
FROM (
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY cst_id order by cst_create_date DESC) as flag_last
FROM BRONZE.crm_cust_info
)t where flag_last = 1

-- Check for unwanted Spaces
-- Expectation: No Results
select cst_firstname
from silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

select cst_lastname
from bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)


SELECT cst_gndr
from bronze.crm_cust_info
where cst_gndr != trim(cst_gndr)


--Data Standardization & Consistency

SELECT DISTINCT cst_gndr
from silver.crm_cust_info

SELECT *
FROM silver.crm_cust_info


SELECT DISTINCT id
FROM bronze.erp_cust_az12


--Check for Nulls or Negative Numbers
-- Expectation: no results


SELECT * 
FROM bronze.crm_prd_info
where prd_end_dt < prd_start_dt 




SELECT *,
LEAD(prd_start_dt) over (PARTITION BY prd_key order by prd_start_dt)-1 as prd_end_date_test
FROM bronze.crm_prd_info
WHERE prd_key


Select prd_id,
COUNT(1)
From bronze.crm_prd_info
GROUP BY prd_id
Having COUNT(1)>1



SELECT *
FROM silver.crm_prd_info





SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
case when sls_order_dt = 0 or len(sls_order_dt) != 8 then null 
else CAST(CAST(sls_order_dt AS varchar) AS DATE) end as sls_order_dt,
case when sls_ship_dt = 0 or len(sls_ship_dt) != 8 then null 
else CAST(CAST(sls_ship_dt AS varchar) AS DATE) end as sls_ship_dt,
case when sls_due_dt = 0 or len(sls_due_dt) != 8 then null 
else CAST(CAST(sls_due_dt AS varchar) AS DATE) end as sls_due_dt,
CASE WHEN sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_price)
THEN sls_quantity * abs(sls_price)
ELSE sls_sales END AS sls_sales,
sls_quantity,
CASE WHEN sls_price <= 0 or sls_price is null 
	Then sls_sales / NULLIF(sls_quantity, 0)
	ELSE sls_price 
	END AS sls_price

from bronze.crm_sales_details

--Quality check for sales details
select distinct sls_sales,
sls_quantity,
sls_price
from silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales is null or sls_quantity is null or sls_price is null
OR sls_sales <= 0 or sls_quantity <= 0 or sls_price <=0
order by sls_sales, sls_quantity, sls_price



select *, NULLIF(sls_order_dt,0) sls_order_dt
from bronze.crm_sales_details
where sls_order_dt <= 0 or LEN(sls_order_dt) != 8 OR sls_order_dt > 

SELECT * 

FROM silver.crm_sales_details

SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
ELSE cid
END AS cid,
CASE WHEN bdate > GETDATE() THEN null
ELSE bdate 
END AS bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
ELSE 'n/a' 
END AS gen

from bronze.erp_cust_az12



SELECT distinct bdate
from bronze.erp_cust_az12
where bdate < '1924-01-01' or bdate > GETDATE()

SELECT DISTINCT CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
ELSE 'n/a' 
END AS gen
from bronze.erp_cust_az12


SELECT 
REPLACE(cid,'-','') cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
ELSE TRIM(cntry)
END AS cntry
from bronze.erp_loc_a101


INSERT INTO silver.erp_px_cat_g1v2
(id,
cat,
subcat,
maintenance) 


SELECT 
id,
cat,
subcat,
maintenance
FROM silver.erp_px_cat_g1v2

--Check for unwanted spaces
select *
from silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat !=TRIM(subcat) OR maintenance != TRIM(maintenance)


-- Data Standardization & consistency

SELECT DISTINCT 
cat
from silver.erp_px_cat_g1v2
