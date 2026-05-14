"""reset_device — clears ALL customer data for a device from the Nee-Vo database.

WARNING: Destructive. Use the exclude list to preserve specific fields.
"""

import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from pyOtodata import OtoDataClient

import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
DEVICE_ID = 20008447
client    = OtoDataClient(api_key=API_KEY)

try:
    confirm = input(f"Reset ALL customer data for device {DEVICE_ID}? Type YES to confirm: ")
except EOFError:
    print("reset_device requires an interactive session. Run in a terminal and type YES when prompted.")
    sys.exit(0)

if confirm == 'YES':
    client.reset_device(DEVICE_ID, exclude=['Name', 'TankSerialNumber'])
    print('Device reset complete.')
else:
    print('Cancelled.')

# Full wipe (no exclusions)
# client.reset_device(DEVICE_ID)
