{{ config(materialized='view') }}

with raw_source as (
    select
        raw_payload:encounter_id::varchar as raw_encounter_id,
        raw_payload:patient_id::varchar as raw_patient_id,
        raw_payload:provider_id::varchar as raw_provider_id,
        raw_payload:encounter_type::varchar as encounter_type,
        try_to_timestamp(raw_payload:admission_time::varchar) as admission_time,
        try_to_timestamp(raw_payload:discharge_time::varchar) as discharge_time,
        try_to_numeric(raw_payload:total_cost::varchar, 12, 2) as total_cost,
        _ingested_at
    from {{ source('ehr_bronze', 'raw_fhir_encounters') }}
),

classified as (
    select
        *,
        case
            when raw_encounter_id is null then 'REJECT_MISSING_ENCOUNTER_ID'
            when raw_patient_id is null then 'REJECT_MISSING_PATIENT_ID'
            when admission_time is null then 'REJECT_INVALID_ADMISSION_DATE'
            when discharge_time is not null and discharge_time < admission_time then 'REJECT_INVALID_DISCHARGE_ORDER'
            else 'VALID'
        end as validation_status
    from raw_source
)

select * from classified