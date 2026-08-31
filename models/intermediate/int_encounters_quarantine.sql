{{ config(
    materialized='incremental',
    unique_key='raw_encounter_id'
) }}

select
    raw_encounter_id,
    raw_patient_id,
    validation_status,
    _ingested_at as quarantined_at
from {{ ref('stg_ehr__encounters') }}
where validation_status != 'VALID'

{% if is_incremental() %}
  and _ingested_at > (select max(quarantined_at) from {{ this }})
{% endif %}