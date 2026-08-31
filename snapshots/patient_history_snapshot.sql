{% snapshot patient_history_snapshot %}

{{
   config(
       target_database='HEALTHCARE_PROD_DB',
       target_schema='GOLD_SNAPSHOTS',
       unique_key='patient_id',

       strategy='timestamp',
       updated_at='_ingested_at',
   )
}}
select
patient_id,provider_id,_ingested_at
from
{{ ref('stg_ehr__claims') }}


{% endsnapshot %}