--This script creates a new database named 'DataWareHouse.Additionally , the script sets up three schemas
--Within the database : 'Bronze','Silver', 'Gold'--
USE master;
--CREATING THE DATABASE
CREATE DATABASE DataWarehouse;

USE DataWarehouse;
GO
--CREATE SCHEMA
CREATE SCHEMA bronze;
GO
--CREATE SCHEMA
CREATE SCHEMA silver;
GO
--CREATE SCHEMA
CREATE SCHEMA gold;
GO
