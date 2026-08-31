with source_data as (
    select
        md5(e.encounter_id) as encounter_sk,
        e.encounter_id,
        md5(e.patient_id) as patient_sk,
        md5(coalesce(e.provider_id, 'UNKNOWN')) as provider_sk,
        e.admission_date,
        e.length_of_stay_hours,
        e.total_cost,
        e.updated_at
    from {{ ref('int_encounters') }} e
)

{% if is_incremental() %}
, max_target as (
    select coalesce(max(updated_at), '1900-01-01'::timestamp_ntz) as max_updated_at 
    from {{ this }}
)
select s.*
from source_data s
cross join max_target m
where s.updated_at > m.max_updated_at
{% else %}
select * from source_data
{% endif %}