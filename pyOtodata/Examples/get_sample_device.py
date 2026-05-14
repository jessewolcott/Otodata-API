"""get_sample_device — returns a dummy device for testing. No API key required."""

import json, sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from pyOtodata import OtoDataClient

# Base URL is required to construct the URL, but no API key needed for this endpoint
client = OtoDataClient(api_key='')

sample = client.get_sample_device()
print(json.dumps(sample, indent=2, default=str))
