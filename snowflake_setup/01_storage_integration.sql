-- Create Core Databases and Warehouses
CREATE DATABASE IF NOT EXISTS HEALTHCARE_PROD_DB;
CREATE DATABASE IF NOT EXISTS HEALTHCARE_DEV_DB;
CREATE WAREHOUSE IF NOT EXISTS HEALTHCARE_WH WITH WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60 AUTO_RESUME = TRUE;

USE DATABASE HEALTHCARE_PROD_DB;
CREATE SCHEMA IF NOT EXISTS BRONZE;
CREATE SCHEMA IF NOT EXISTS SILVER;
CREATE SCHEMA IF NOT EXISTS GOLD;
CREATE SCHEMA IF NOT EXISTS GOLD_SNAPSHOTS;

-- Create Storage Integration pointing to ADLS Gen2
-- Note: Replace <azure_tenant_id> with your Azure Active Directory Tenant ID
CREATE OR REPLACE STORAGE INTEGRATION azure_adls_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'AZURE'
  ENABLED = TRUE
  AZURE_TENANT_ID = '<azure_tenant_id>'
  STORAGE_ALLOWED_LOCATIONS = ('azure://adlshealthcareprod.blob.core.windows.net/healthcare-data/');

-- Retrieve Azure Service Principal Information for Consent
DESC STORAGE INTEGRATION azure_adls_int;
-- IMPORTANT: Take AZURE_CONSENT_URL from output, open in browser, and accept enterprise consent.
-- Assign "Storage Blob Data Reader" role to AZURE_MULTI_TENANT_APP_NAME in Azure Portal for the storage account.