{{ config(materialized='view') }}

select
    claim_id,
    nullif(patient_id, '') as patient_id,
    provider_id,
    try_to_numeric(claim_amount, 12, 2) as claim_amount,
    try_to_date(claim_date) as claim_date,
    diagnosis_code,
    _ingested_at
from {{ source('ehr_bronze', 'raw_claims') }}