"""get_sample_device (raw) — dummy device for testing. No API key or module required."""

import json, requests

BASE_URL = 'https://telematics.otodatanetwork.com:4431'
API_PATH = '/v1.0/DataService.svc'

r = requests.get(
    f'{BASE_URL}{API_PATH}/devices/sample',
    headers={'Accept': 'application/json; charset=utf-8'},
)
r.raise_for_status()
print(json.dumps(r.json(), indent=2, default=str))
