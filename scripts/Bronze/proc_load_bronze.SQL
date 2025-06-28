/*
==============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
==============================================================================
Script Purpose:
  It load data into the 'bronze' schema from an external CSV files.
  It performs the following actions
  -Truncates the table before loading the data
  -Uses the 'Bulk Insert' command to load data from CSV files to bronze tables.

Usage Example:
  EXEC bronze.load_bronze;
==============================================================================
*/
Create OR Alter Procedure bronze.load_bronze as
Begin
	Declare @start_time Datetime, @end_time Datetime, @batch_start_time Datetime, @batch_end_time Datetime;
	Begin Try
		Set @batch_start_time = GETDATE();
		Print '==================================================';
		Print 'Loading Bronze layer';
		Print '==================================================';

		Print '--------------------------------------------------';
		Print 'Loading CRM Tables';
		Print '--------------------------------------------------';

		Set @start_time = GETDATE();
		Print '>> Truncating Table: bronze.crm_cust_info';
		Truncate Table bronze.crm_cust_info

		Print '>> Inserting Data into: bronze.crm_cust_info';
		Bulk insert bronze.crm_cust_info
		From 'C:\Users\USER141\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		With (
			FirstRow = 2,
			FieldTerminator = ',',
			Tablock
		);
		Set @end_time = GETDATE();
		Print '>> Load Duration: ' + Cast(Datediff(Second, @start_time, @end_time) as Nvarchar) + 'seconds';
		Print '>> ------------';

		Set @start_time = GETDATE();
		Print '>> Truncating Table: bronze.crm_prd_info';
		Truncate Table bronze.crm_prd_info

		Print '>> Inserting Data into: bronze.crm_prd_info';
		Bulk insert bronze.crm_prd_info
		From 'C:\Users\USER141\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		With (
			FirstRow = 2,
			FieldTerminator = ',',
			Tablock
		);
		Set @end_time = GETDATE();
		Print '>> Load Duration: ' + Cast(Datediff(Second, @start_time, @end_time) as Nvarchar) + 'seconds';
		Print '>> ------------';

		Set @start_time = GETDATE();
		Print '>> Truncating Table: bronze.crm_sales_details';
		Truncate Table bronze.crm_sales_details

		Print '>> Inserting Data into: bronze.crm_sales_details';
		Bulk insert bronze.crm_sales_details
		From 'C:\Users\USER141\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		With (
			FirstRow = 2,
			FieldTerminator = ',',
			Tablock
		);
		Set @end_time = GETDATE();
		Print '>> Load Duration: ' + Cast(Datediff(Second, @start_time, @end_time) as Nvarchar) + 'seconds';
		Print '>> ------------';

		Print '--------------------------------------------------';
		Print 'Loading ERP Tables';
		Print '--------------------------------------------------';

		Set @start_time = GETDATE();
		Print '>> Truncating Table: bronze.erp_cust_az12';
		Truncate Table bronze.erp_cust_az12

		Print '>> Inserting Data into: bronze.erp_cust_az12';
		Bulk insert bronze.erp_cust_az12
		From 'C:\Users\USER141\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		With (
			FirstRow = 2,
			FieldTerminator = ',',
			Tablock
		);
		Set @end_time = GETDATE();
		Print '>> Load Duration: ' + Cast(Datediff(Second, @start_time, @end_time) as Nvarchar) + 'seconds';
		Print '>> ------------';

		Set @start_time = GETDATE();
		Print '>> Truncating Table: bronze.erp_loc_a101';
		Truncate Table bronze.erp_loc_a101

		Print '>> Inserting Data into: bronze.erp_loc_a101';
		Bulk insert bronze.erp_loc_a101
		From 'C:\Users\USER141\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		With (
			FirstRow = 2,
			FieldTerminator = ',',
			Tablock
		);
		Set @end_time = GETDATE();
		Print '>> Load Duration: ' + Cast(Datediff(Second, @start_time, @end_time) as Nvarchar) + 'seconds';
		Print '>> ------------';

		Set @start_time = GETDATE();
		Print '>> Truncating Table: bronze.erp_px_cat_g1v2';
		Truncate Table bronze.erp_px_cat_g1v2

		Print '>> Inserting Data into: bronze.erp_px_cat_g1v2';
		Bulk insert bronze.erp_px_cat_g1v2
		From 'C:\Users\USER141\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		With (
			FirstRow = 2,
			FieldTerminator = ',',
			Tablock
		);
		Set @end_time = GETDATE();
		Print '>> Load Duration: ' + Cast(Datediff(Second, @start_time, @end_time) as Nvarchar) + 'seconds';
		Print '>> ------------';

		Set @batch_end_time = GETDATE();
		Print '========================================'
		Print 'Loading Bronze Layer is Completed';
		Print ' - Total Load Duration: ' + Cast(Datediff(Second, @batch_start_time, @batch_end_time) as Nvarchar) + 'seconds';
		Print '========================================';
	End Try
	Begin Catch
		Print '==========================================================='
		Print 'Error occured during loading Bronze Layer'
		Print 'Error Message' + Error_Message();
		Print 'Error Message' + Cast(Error_Message() as Nvarchar);
		Print 'Error Message' + Cast(Error_State() as Nvarchar);
		Print '==========================================================='
	End Catch
	
End
