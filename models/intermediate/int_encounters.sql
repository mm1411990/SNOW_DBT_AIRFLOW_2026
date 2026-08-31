{{
  config(
    materialized = 'incremental',
    unique_key = 'encounter_id',
    incremental_strategy =  'merge',
    cluster_by=['admission_date']
    )
}}
select
    raw_encounter_id as encounter_id,
    raw_patient_id as patient_id,
    raw_provider_id as provider_id,
    upper(trim(encounter_type)) as encounter_type,
    admission_time,
    discharge_time,
    cast(admission_time as date) as admission_date,
    timestampdiff('hour', admission_time, coalesce(discharge_time, current_timestamp())) as length_of_stay_hours,
    total_cost,
    _ingested_at as updated_at
    from
    {{ ref('stg_ehr__encounters') }}
    where validation_status = 'VALID'

    {% if is_incremental() %}
      and _ingested_at >= coalesce((select max(updated_at) from {{ this }}), '1900-01-01')
    {% endif %}