import csv
import random
from datetime import datetime, timedelta

def generate_claims_data(filename="data_sample/raw_claims_5k.csv", num_records=5000):
    header = ["CLAIM_ID", "PATIENT_ID", "PROVIDER_ID", "CLAIM_AMOUNT", "CLAIM_DATE", "DIAGNOSIS_CODE"]
    diag_codes = ["I10", "E11.9", "J45.909", "M25.50", "Z00.00", "INVALID_CODE"]
    
    start_date = datetime(2026, 1, 1)
    
    with open(filename, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(header)
        
        for i in range(1, num_records + 1):
            claim_id = f"CLM{100000 + i}"
            # Introduce intentional bad record (missing patient_id) for DLQ testing
            patient_id = "" if i == 500 else f"PAT{random.randint(1000, 2000)}"
            provider_id = f"PRV{random.randint(100, 300)}"
            # Introduce intentional bad numeric amount
            claim_amount = "BAD_AMT" if i == 1000 else round(random.uniform(150.0, 15000.0), 2)
            claim_date = (start_date + timedelta(days=random.randint(0, 200))).strftime("%Y-%m-%d")
            diag_code = random.choice(diag_codes)
            
            writer.writerow([claim_id, patient_id, provider_id, claim_amount, claim_date, diag_code])

    print(f"Successfully generated {num_records} CSV rows in {filename}")

if __name__ == "__main__":
    generate_claims_data()