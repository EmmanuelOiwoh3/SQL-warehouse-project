/*
==============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
==============================================================================
Script Purpose:
  It performs the ETL (Extract, Transform and Load) process to populate the 'Silver' Schema tables
  from the 'bronze' schema.
  It performs the following actions
  -Truncates the silver table
  -Insert the transformed and cleaned data from Bronze into silver tables.

Usage Example:
  EXEC silver.load_bronze;
==============================================================================
*/



Create or Alter Procedure Silver.load_silver As
Begin
  Declare @start_time Datetime, @end_time Datetime, @batch_start_time Datetime, @batch_end_time Datetime;
  BEGIN TRY
	Set @batch_start_time = GETDATE();
    Print '==================================================';
	Print 'Loading Silver layer';
	Print '==================================================';

	Print '--------------------------------------------------';
	Print 'Loading CRM Tables';
	Print '--------------------------------------------------';

	Set @start_time = GETDATE();
	PRINT '>> Truncating Table: Silver.crm_cust_info'
	Truncate Table Silver.crm_cust_info;
	PRINT '>> Inserting Data Into : Silver.crm_cust_info'
	Insert Into Silver.crm_cust_info (
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date)

	Select 
	cst_id,
	cst_key,
	Trim(cst_firstname) As cst_firstname,
	Trim(cst_lastname) As cst_lastname,
	Case When Upper(Trim(cst_marital_status)) ='S' Then 'Single'
		 When Upper(Trim(cst_marital_status)) = 'M' Then 'Married'
		 Else 'n/a'
	End cst_marital_status,
	Case When Upper(Trim(cst_gndr)) ='F' Then 'Female'
		 When Upper(Trim(cst_gndr)) = 'M' Then 'Male'
		 Else 'n/a'
	End cst_gndr,
	cst_create_date 
	From (
		Select *,
		Row_Number() Over (Partition by cst_id Order by Cst_create_Date Desc) Flag_Last
		from bronze.crm_cust_info
		Where cst_id IS NOT NULL
	)t Where Flag_Last = 1
	Set @end_time = GETDATE();
	Print '>> Load Duration: ' + Cast(Datediff(Second, @start_time, @end_time) as Nvarchar) + 'seconds';
	Print '>> ------------';

	Set @start_time = GETDATE();
	PRINT '>> Truncating Table: Silver.crm_prd_info'
	Truncate Table Silver.crm_prd_info;
	PRINT '>> Inserting Data Into : Silver.crm_prd_info'
	INSERT INTO Silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)
	SELECT 
		prd_id,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-','_') As cat_id,
		SUBSTRING(prd_key, 7, LEN(prd_key)) As prd_key,
		prd_nm,
		Coalesce(prd_cost, 0) As prd_cost,
		Case When Upper(Trim(prd_line)) = 'M' then 'Mountain'
			 When Upper(Trim(prd_line)) = 'R' then 'Road'
			 When Upper(Trim(prd_line)) = 'S' then 'Other Sales'
			 When Upper(Trim(prd_line)) = 'T' then 'Touring'
			 Else 'n/a'
		End prd_line,
		Cast(prd_start_dt As Date) As prd_start_dt,
		Cast(Lead(prd_start_dt) Over (Partition by prd_key Order by Prd_start_dt) - 1 As Date) As prd_end_dt
	FROM Bronze.crm_prd_info
	Set @end_time = GETDATE();
	Print '>> Load Duration: ' + Cast(Datediff(Second, @start_time, @end_time) as Nvarchar) + 'seconds';
	Print '>> ------------';

	Set @start_time = GETDATE();
	PRINT '>> Truncating Table: silver.crm_sales_details'
	Truncate Table silver.crm_sales_details;
	PRINT '>> Inserting Data Into : silver.crm_sales_details'
	INSERT INTO silver.crm_sales_details (
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
	)
	Select 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	Case When sls_order_dt = 0 OR LEN(sls_order_dt) != 8 Then NULL
		 Else Cast(Cast(sls_order_dt As varchar) As DATE)
	End sls_order_dt,
	Case When sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 Then NULL
		 Else Cast(Cast(sls_ship_dt As varchar) As DATE)
	End sls_ship_dt,
	Case When sls_due_dt = 0 OR LEN(sls_due_dt) != 8 Then NULL
		 Else Cast(Cast(sls_due_dt As varchar) As DATE)
	End sls_due_dt,
	Case When sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
			Then sls_quantity * ABS(sls_price)
		Else sls_sales
	End As sls_sales,
	sls_quantity,
	Case When sls_price IS NULL OR sls_price <= 0
			Then sls_sales / NULLIF(sls_quantity, 0)
		Else sls_price
	End As sls_price
	from Bronze.crm_sales_details
	Set @end_time = GETDATE();
	Print '>> Load Duration: ' + Cast(Datediff(Second, @start_time, @end_time) as Nvarchar) + 'seconds';
	Print '>> ------------';

	Print '--------------------------------------------------';
	Print 'Loading ERP Tables';
	Print '--------------------------------------------------';

	Set @start_time = GETDATE();
	PRINT '>> Truncating Table: Silver.erp_cust_az12'
	Truncate Table Silver.erp_cust_az12;
	PRINT '>> Inserting Data Into : Silver.erp_cust_az12'
	INSERT INTO Silver.erp_cust_az12 (CID, BDATE, GEN)
	Select 
	Case When CID LIKE 'NAS%' Then SUBSTRING(cid, 4, len(CID))
		 Else cid
	End CID,
	CASE WHEN BDATE > GETDATE() THEN NULL
		 Else BDATE
	End BDATE,
	Case When Upper(Trim(gen)) IN ('F', 'FEMALE') THEN 'Female'
		 When Upper(Trim(gen)) IN ('M', 'MALE') THEN 'Male'
		 ELSE 'n/a'
	End as GEN
	from Bronze.erp_cust_az12
	Set @end_time = GETDATE();
	Print '>> Load Duration: ' + Cast(Datediff(Second, @start_time, @end_time) as Nvarchar) + 'seconds';
	Print '>> ------------';

	Set @start_time = GETDATE();
	PRINT '>> Truncating Table: Silver.erp_loc_a101'
	Truncate Table Silver.erp_loc_a101;
	PRINT '>> Inserting Data Into : Silver.erp_loc_a101'
	INSERT INTO Silver.erp_loc_a101 (CID, CNTRY)
	Select 
	REPLACE(CID, '-','') CID,
	CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
		 WHEN TRIM(CNTRY) IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
		 WHEN TRIM(CNTRY) = '' OR CNTRY is null then 'n/a'
		 Else Trim(cntry)
	End CNTRY
	from Bronze.erp_loc_a101
	Set @end_time = GETDATE();
	Print '>> Load Duration: ' + Cast(Datediff(Second, @start_time, @end_time) as Nvarchar) + 'seconds';
	Print '>> ------------';

	Set @start_time = GETDATE();
	PRINT '>> Truncating Table: SILVER.erp_px_cat_g1v2'
	Truncate Table SILVER.erp_px_cat_g1v2;
	PRINT '>> Inserting Data Into : SILVER.erp_px_cat_g1v2'
	INSERT INTO SILVER.erp_px_cat_g1v2(
		ID,
		CAT,
		SUBCAT,
		MAINTENANCE
	)
	Select 
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
	From Bronze.erp_px_cat_g1v2
	Set @end_time = GETDATE();
	Print '>> Load Duration: ' + Cast(Datediff(Second, @start_time, @end_time) as Nvarchar) + 'seconds';
	Print '>> ------------';

	Set @batch_end_time = GETDATE();
	Print '========================================'
	Print 'Loading Bronze Layer is Completed';
	Print ' - Total Load Duration: ' + Cast(Datediff(Second, @batch_start_time, @batch_end_time) as Nvarchar) + 'seconds';
	Print '========================================';
  END TRY
  BEGIN CATCH
		Print '==========================================================='
		Print 'Error occured during loading Bronze Layer'
		Print 'Error Message' + Error_Message();
		Print 'Error Message' + Cast(Error_Message() as Nvarchar);
		Print 'Error Message' + Cast(Error_State() as Nvarchar);
		Print '==========================================================='
  END CATCH
End
