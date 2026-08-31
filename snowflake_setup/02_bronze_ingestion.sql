USE DATABASE HEALTHCARE_PROD_DB;
USE SCHEMA BRONZE;

-- Create File Formats
CREATE OR REPLACE FILE FORMAT csv_ff
  TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null', '')
  ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE;

CREATE OR REPLACE FILE FORMAT json_ff
  TYPE = 'JSON';

-- Create External Stages
CREATE OR REPLACE STAGE adls_claims_stage
  STORAGE_INTEGRATION = azure_adls_int
  URL = 'azure://adlshealthcareprod.blob.core.windows.net/healthcare-data/claims_raw/'
  FILE_FORMAT = csv_ff;

CREATE OR REPLACE STAGE adls_fhir_stage
  STORAGE_INTEGRATION = azure_adls_int
  URL = 'azure://adlshealthcareprod.blob.core.windows.net/healthcare-data/fhir_raw/'
  FILE_FORMAT = json_ff;

-- 1. BRONZE STRUCTURED TABLE (Claims CSV)
CREATE OR REPLACE TABLE raw_claims (
    claim_id VARCHAR,
    patient_id VARCHAR,
    provider_id VARCHAR,
    claim_amount VARCHAR,
    claim_date VARCHAR,
    diagnosis_code VARCHAR,
    _file_name VARCHAR,
    _ingested_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- 2. BRONZE SEMI-STRUCTURED TABLE (FHIR JSON)
CREATE OR REPLACE TABLE raw_fhir_encounters (
    raw_payload VARIANT,
    _file_name VARCHAR,
    _ingested_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- INGEST DATA (Pre-Bronze Ingestion execution using COPY INTO)
-- Structured Load with ON_ERROR = 'CONTINUE' (Pre-Bronze DLQ pattern)
COPY INTO raw_claims (claim_id, patient_id, provider_id, claim_amount, claim_date, diagnosis_code, _file_name)
FROM (
    SELECT $1, $2, $3, $4, $5, $6, METADATA$FILENAME
    FROM @adls_claims_stage
)
ON_ERROR = 'CONTINUE';

-- Semi-Structured Load
COPY INTO raw_fhir_encounters (raw_payload, _file_name)
FROM (
    SELECT $1, METADATA$FILENAME
    FROM @adls_fhir_stage
)
ON_ERROR = 'CONTINUE';