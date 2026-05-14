"""
pyOtodata — Python client for the Otodata Nee-Vo API v29.

Quick start::

    from pyOtodata import OtoDataClient

    client = OtoDataClient(api_key="YOUR_KEY")
    devices = client.get_devices()
    for d in devices:
        print(d["Id"], d["Name"], d["Status"], f"{d['LastLevel']:.1%}")
"""

from .client import OtoDataClient, OtoDataError

__all__ = ["OtoDataClient", "OtoDataError"]
__version__ = "1.0.0"
