import json
import random
from datetime import datetime, timedelta

def generate_fhir_data(filename="data_sample/raw_fhir_encounters_5k.json", num_records=5000):
    start_date = datetime(2026, 1, 1)
    encounter_types = ["inpatient", "outpatient", "emergency"]
    
    records = []
    for i in range(1, num_records + 1):
        adm_dt = start_date + timedelta(days=random.randint(0, 200), hours=random.randint(0, 23))
        dis_dt = adm_dt + timedelta(hours=random.randint(2, 120))
        
        # Introduce intentional bad record (missing encounter_id) for DLQ testing
        enc_id = None if i == 250 else f"ENC{200000 + i}"
        
        payload = {
            "resourceType": "Encounter",
            "encounter_id": enc_id,
            "patient_id": f"PAT{random.randint(1000, 2000)}",
            "provider_id": f"PRV{random.randint(100, 300)}",
            "encounter_type": random.choice(encounter_types),
            "admission_time": adm_dt.strftime("%Y-%m-%dT%H:%M:%SZ"),
            # Introduce invalid discharge date order for DLQ testing
            "discharge_time": (adm_dt - timedelta(days=2)).strftime("%Y-%m-%dT%H:%M:%SZ") if i == 750 else dis_dt.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "total_cost": str(round(random.uniform(500.0, 50000.0), 2))
        }
        records.append(payload)
    
    with open(filename, 'w') as f:
        for record in records:
            f.write(json.dumps(record) + '\n')
            
    print(f"Successfully generated {num_records} JSON records in {filename}")

if __name__ == "__main__":
    generate_fhir_data()