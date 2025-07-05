/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
  This Script creates views in the Gold layer in the data warehouse. 
  The Gold layer represents the final dimension and fact tables (star schema)

  Each view performs transformations and combines data from the Silver layer
  to produce a clean, enriched, and business-ready dataset.

Usage:
  - These views can be queried directly for analytics and reporting.
  
================================================================================
*/

--==============================================================================
--Create Dimension: gold.dim_customers
--==============================================================================

If Object_id ('gold.dim_customers', 'v') is not null
	Drop view gold.dim_customers;
Go

Create View gold.dim_customers As
select 
	ROW_NUMBER() Over (Order by cst_id) As Customer_key,
	ci.cst_id As Customer_id,
	ci.cst_key As Customer_number,
	ci.cst_firstname As First_name,
	ci.cst_lastname As Last_name,
	la.CNTRY As Country,
	ci.cst_marital_status As Marital_status,
	Case When ci.cst_gndr != 'n/a' then ci.cst_gndr
		 Else coalesce(ca.GEN, 'n/a')
	End As Gender,
	ca.BDATE As Birthdate,
	ci.cst_create_date As Create_date
from Silver.crm_cust_info ci
left join Silver.erp_cust_az12 ca
on		ci.cst_key = ca.CID
left join Silver.erp_loc_a101 la
on		ci.cst_key = la.CID

If Object_id ('gold.dim_products', 'v') is not null
	Drop view gold.dim_products;
Go

Create View gold.dim_products As
Select 
	ROW_NUMBER() Over( Order by pn.prd_start_dt, pn.prd_key) As Product_key,
	pn.prd_id As Product_id,
	pn.prd_key As Product_number,
	pn.prd_nm As Product_name,
	pn.cat_id As Category_id,
	pc.CAT As Category,
	pc.SUBCAT As Subcategory,
	pc.MAINTENANCE,
	pn.prd_cost As Cost,
	pn.prd_line As Product_line,
	pn.prd_start_dt As Start_date
From silver.crm_prd_info pn
Left join silver.erp_px_cat_g1v2 pc
on		pn.cat_id = pc.ID
Where prd_end_dt is null -- filter out all historical data

If Object_id ('gold.fact_sales', 'v') is not null
	Drop view gold.fact_sales;
Go

Create View gold.fact_sales As
Select 
sd.sls_ord_num As Order_number,
pr.Product_key,
cu.Customer_key,
sd.sls_order_dt As Order_date,
sd.sls_ship_dt As Shipping_date,
sd.sls_due_dt As Due_date,
sd.sls_sales As Sales_amount,
sd.sls_quantity As Quantity,
sd.sls_price As Price
From Silver.crm_sales_details sd
Left Join gold.dim_products pr
on sd.sls_prd_key = pr.Product_number
Left Join Gold.dim_customers cu
on sd.sls_cust_id = cu.Customer_id
