"""cancel_dispatch — cancels an active dispatch for a device.

Fires integration events but does NOT send a push notification to the end-user.
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

client.cancel_dispatch(DEVICE_ID)
print(f"Dispatch cancelled for device {DEVICE_ID}.")

# Target a specific sensor
# client.cancel_dispatch(DEVICE_ID, sensor=1)
