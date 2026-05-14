"""download_report — downloads a summary report to a local file.

Supported formats: 'Excel' (default), 'CSV', 'SuburbanSoftware'
"""

import sys, os
from datetime import datetime
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from pyOtodata import OtoDataClient

import json as _json
from pathlib import Path as _Path
_col    = list(_Path(__file__).parent.glob('*.postman_collection.json'))
API_KEY = next((v['value'] for f in _col[:1] for v in _json.load(open(f)).get('variable', []) if v.get('key') == 'API_KEY'), 'YOUR_API_KEY_HERE')
client  = OtoDataClient(api_key=API_KEY)

# CSV report
data = client.download_report(fmt='CSV')
out  = f"OtoData_{datetime.now().strftime('%Y%m%d')}.csv"
with open(out, 'wb') as fh:
    fh.write(data)
print(f"Saved: {out}  ({len(data):,} bytes)")

# Excel (default)
# data = client.download_report()
# with open('report.xlsx', 'wb') as f: f.write(data)

# Excel, exclude non-installed, include sub-companies
# data = client.download_report(fmt='Excel', exclude_non_installed=True, include_sub_companies=True)
