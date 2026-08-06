/*
===============================================================================
DDL Script: Database and Schema Creation
Project     : Olist Brazilian E-commerce Data Warehouse
Database    : OlistDW
Description : Creates the data warehouse database and Medallion schemas.
===============================================================================
*/

-- ============================================================================
-- Create Database
-- ============================================================================

USE master;
GO

IF DB_ID('OlistDW') IS NULL
BEGIN
    CREATE DATABASE OlistDW;
    PRINT 'Database OlistDW created successfully.';
END
ELSE
BEGIN
    PRINT 'Database OlistDW already exists.';
END
GO

-- ============================================================================
-- Use OlistDW Database
-- ============================================================================

USE OlistDW;
GO

SET NOCOUNT ON;
GO

-- ============================================================================
-- Create Bronze Schema
-- ============================================================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'bronze'
)
BEGIN
    EXEC('CREATE SCHEMA bronze');
    PRINT 'Schema bronze created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema bronze already exists.';
END
GO

-- ============================================================================
-- Create Silver Schema
-- ============================================================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'silver'
)
BEGIN
    EXEC('CREATE SCHEMA silver');
    PRINT 'Schema silver created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema silver already exists.';
END
GO

-- ============================================================================
-- Create Gold Schema
-- ============================================================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'gold'
)
BEGIN
    EXEC('CREATE SCHEMA gold');
    PRINT 'Schema gold created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema gold already exists.';
END
GO

PRINT 'Database initialization completed successfully.';
GO