select distinct
    md5(patient_id) as patient_sk,
    patient_id
from {{ ref('int_encounters') }}