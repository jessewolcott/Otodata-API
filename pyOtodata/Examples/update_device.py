"""update_device — modifies customer-configurable properties on a device.

Only include keys you want to change; all others are left untouched.
Setting TankFormatName auto-sets: Capacity, TankFormType, Depth, Height, Width, Offset, MaxUllage.
"""

import sys, os
from datetime import datetime, timezone
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from pyOtodata import OtoDataClient

import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
DEVICE_ID = 20008447
client    = OtoDataClient(api_key=API_KEY)

result = client.update_device(
    DEVICE_ID,
    properties={
        'Name':           'North Tank',
        'Route':          'Route A',
        'Note':           f"Updated {datetime.now(timezone.utc).strftime('%Y-%m-%d')} via pyOtodata",
        'LocationName':   'Site A',
        'LocationNumber': 'LOC001',
    },
)
errors = result.get('Errors', []) if result else []
if not errors:
    print('Device updated successfully.')
else:
    for err in errors:
        print(f"  Field '{err.get('Property')}': {err.get('Message')}")

# Cancel all changes if any single field fails
# result = client.update_device(DEVICE_ID, {'TankFormatName': 'Propane 1000 gal'}, enforce_validation=True)
