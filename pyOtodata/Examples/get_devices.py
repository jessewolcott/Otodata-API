"""get_devices — returns all modules linked to the authenticated company."""

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from pyOtodata import OtoDataClient

import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
client  = OtoDataClient(api_key=API_KEY)

# All devices
devices = client.get_devices()
print(f"Total devices: {len(devices)}")
for d in devices[:20]:
    print(f"  [{d['Id']}] {(d.get('Name') or '—'):30s}  {(d.get('Status') or '—'):20s}  {d.get('LastLevel',0):.1%}")

# Only devices updated since a given date
# devices = client.get_devices(last_date_utc='2026-01-01T00:00:00Z')
