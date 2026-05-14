"""download_report (raw) — downloads a summary report to a local file. No module required.

Supported formats: 'Excel' (default), 'CSV', 'SuburbanSoftware'
"""

import requests
from datetime import datetime

BASE_URL = 'https://telematics.otodatanetwork.com:4431'
API_PATH = '/v1.0/DataService.svc'
import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')

headers = {'Authorization': f'Bearer {API_KEY}'}

r = requests.get(f'{BASE_URL}{API_PATH}/downloadReport', headers=headers, params={'format': 'CSV'})
r.raise_for_status()

out = f"OtoData_{datetime.now().strftime('%Y%m%d')}.csv"
with open(out, 'wb') as fh:
    fh.write(r.content)
print(f"Saved: {out}  ({len(r.content):,} bytes)")

# Excel (default)
# r = requests.get(f'{BASE_URL}{API_PATH}/downloadReport', headers=headers)
# with open('report.xlsx', 'wb') as f: f.write(r.content)
