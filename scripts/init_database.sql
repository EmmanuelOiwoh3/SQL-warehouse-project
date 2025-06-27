/*
============================================
Create Database and Schemas
============================================
Script Purpose:
	This script create a new database named 'DataWarehouse' after checking if it already exists.
	If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
	within the database: 'bronze', 'silver' and 'gold'.

Warning:
	Running this script will drop the entire 'DataWarehouse' database if it exists.
	All data in the database will be permanently deleted. Proceed with caution 
	and ensure you have proper backups before running this scripts
*/

-- Create Database 'DataWarehouse'

Use master;
Go

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse Set Single User with Rollback Immediate;
	Drop Database DataWarehouse;
End;
Go

-- Create the 'DataWarehouse' Database
Create Database DataWarehouse;

Use DataWarehouse;

Create Schema Bronze;
Go
Create Schema Silver;
Go
Create Schema Gold;
Go
