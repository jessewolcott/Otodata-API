# ARC3-Tooling

Client libraries, example scripts, and API documentation for the **Otodata Nee-Vo API v29** — a web service for accessing Remote Tank Level Monitor (RTLM) readings and managing Otodata devices.

This repository contains:

- **POSH-Otodata** — A PowerShell module with 20 exported functions covering every API endpoint.
- **pyOtodata** — A Python package (`OtoDataClient` class) with 18 methods covering every API endpoint.
- **Example scripts** — 36 PowerShell scripts and 36 Python scripts (72 total) demonstrating every function and method.
- **API documentation** — The original API Blueprint spec plus an OpenAPI 3.0 spec and an interactive Swagger UI page.

---

## Table of Contents

1. [Repository Layout](#repository-layout)
2. [Prerequisites](#prerequisites)
3. [Quick Start — PowerShell](#quick-start--powershell)
4. [Quick Start — Python](#quick-start--python)
5. [PowerShell Module Reference](#powershell-module-reference)
   - [Connection Functions](#connection-functions)
   - [Device Functions](#device-functions)
   - [Tank Level Functions](#tank-level-functions)
   - [Report Functions](#report-functions)
   - [Return Request Functions](#return-request-functions)
   - [RMA Functions](#rma-functions)
   - [Gas Meter Functions](#gas-meter-functions)
6. [Python Module Reference](#python-module-reference)
   - [OtoDataClient Constructor](#otodataclient-constructor)
   - [Device Methods](#device-methods)
   - [Tank Level Methods](#tank-level-methods)
   - [Report Methods](#report-methods)
   - [Return Request Methods](#return-request-methods)
   - [RMA Methods](#rma-methods)
   - [Gas Meter Methods](#gas-meter-methods)
7. [Example Scripts](#example-scripts)
   - [PowerShell Examples](#powershell-examples)
   - [Python Examples](#python-examples)
8. [API Reference](#api-reference)
   - [Authentication](#authentication)
   - [Base URLs](#base-urls)
   - [Endpoint Summary](#endpoint-summary)
   - [Enumerations](#enumerations)
   - [Pagination](#pagination)
   - [Known Quirks](#known-quirks)
9. [API Documentation Files](#api-documentation-files)

---

## Repository Layout

```
ARC3-Tooling/
│
├── POSH-Otodata/               PowerShell module
│   ├── POSH-Otodata.psm1       Module implementation — all 20 functions
│   ├── POSH-Otodata.psd1       Module manifest
│   └── Examples/
│       ├── GetDevices.ps1          Module-style examples (18 scripts)
│       ├── GetDevice.ps1
│       ├── GetSampleDevice.ps1
│       ├── GetDeviceWarranties.ps1
│       ├── UpdateDevice.ps1
│       ├── ResetDevice.ps1
│       ├── CreateDispatch.ps1
│       ├── CancelDispatch.ps1
│       ├── GetTankLevels.ps1
│       ├── GetDeviceTankLevels.ps1
│       ├── DownloadReport.ps1
│       ├── GetReturnRequests.ps1
│       ├── GetReturnRequest.ps1
│       ├── UpdateReturnRequest.ps1
│       ├── GetRmas.ps1
│       ├── GetRma.ps1
│       ├── UpdateRmaItem.ps1
│       ├── GetGasMeters.ps1
│       ├── GetDevices-Raw.ps1      Raw HTTP examples (18 scripts)
│       ├── GetDevice-Raw.ps1
│       ├── GetSampleDevice-Raw.ps1
│       ├── GetDeviceWarranties-Raw.ps1
│       ├── UpdateDevice-Raw.ps1
│       ├── ResetDevice-Raw.ps1
│       ├── CreateDispatch-Raw.ps1
│       ├── CancelDispatch-Raw.ps1
│       ├── GetTankLevels-Raw.ps1
│       ├── GetDeviceTankLevels-Raw.ps1
│       ├── DownloadReport-Raw.ps1
│       ├── GetReturnRequests-Raw.ps1
│       ├── GetReturnRequest-Raw.ps1
│       ├── UpdateReturnRequest-Raw.ps1
│       ├── GetRmas-Raw.ps1
│       ├── GetRma-Raw.ps1
│       ├── UpdateRmaItem-Raw.ps1
│       └── GetGasMeters-Raw.ps1
│
├── pyOtodata/                  Python package
│   ├── __init__.py                 Package init — exports OtoDataClient
│   ├── client.py                   OtoDataClient implementation
│   └── Examples/
│       ├── get_devices.py          Module-style examples (18 scripts)
│       ├── get_device.py
│       ├── get_sample_device.py
│       ├── get_device_warranties.py
│       ├── update_device.py
│       ├── reset_device.py
│       ├── create_dispatch.py
│       ├── cancel_dispatch.py
│       ├── get_tank_levels.py
│       ├── get_device_tank_levels.py
│       ├── download_report.py
│       ├── get_return_requests.py
│       ├── get_return_request.py
│       ├── update_return_request.py
│       ├── get_rmas.py
│       ├── get_rma.py
│       ├── update_rma_item.py
│       ├── get_gas_meters.py
│       ├── get_devices_raw.py      Raw HTTP examples (18 scripts)
│       ├── get_device_raw.py
│       ├── get_sample_device_raw.py
│       ├── get_device_warranties_raw.py
│       ├── update_device_raw.py
│       ├── reset_device_raw.py
│       ├── create_dispatch_raw.py
│       ├── cancel_dispatch_raw.py
│       ├── get_tank_levels_raw.py
│       ├── get_device_tank_levels_raw.py
│       ├── download_report_raw.py
│       ├── get_return_requests_raw.py
│       ├── get_return_request_raw.py
│       ├── update_return_request_raw.py
│       ├── get_rmas_raw.py
│       ├── get_rma_raw.py
│       ├── update_rma_item_raw.py
│       └── get_gas_meters_raw.py
│
├── Source/
│   ├── Otodata_Nee-Vo_API.apib     Original API Blueprint spec (v29)
│   ├── Otodata_Nee-Vo_API (27).pdf Otodata vendor documentation PDF
│   └── SANDBOX-Otodata_Nee-Vo_API.postman_collection.json
│                                   Postman collection for sandbox testing
│
├── docs/
│   ├── openapi.yaml                OpenAPI 3.0 spec (all 18 endpoints)
│   └── index.html                  Interactive Swagger UI (open in browser)
│
├── .gitignore
└── README.md
```

---

## Prerequisites

### PowerShell

- **PowerShell 5.1 or higher** (PowerShell 7+ recommended for cross-platform use)
- **Network access** to `telematics.otodatanetwork.com:4431` (HTTPS, port 4431)
- No additional modules required — `Invoke-RestMethod` is built into PowerShell

Import the module by dot-sourcing the `.psm1` or using `Import-Module`:

```powershell
Import-Module .\POSH-Otodata\POSH-Otodata.psm1
```

Or add the module folder to your `$env:PSModulePath` for automatic loading.

### Python

- **Python 3.8 or higher**
- **`requests` library** — install with pip if not already present:

```bash
pip install requests
```

The package does not need to be installed — the example scripts add the repo root to `sys.path` automatically.  To use the client from your own code in the same repo:

```python
import sys, os
sys.path.insert(0, '/path/to/ARC3-Tooling')
from pyOtodata import OtoDataClient
```

---

## Quick Start — PowerShell

```powershell
# 1. Import the module
Import-Module .\POSH-Otodata\POSH-Otodata.psm1

# 2. Connect using your API key
Connect-OtoData -ApiKey 'YOUR_API_KEY_HERE'

# 3. List all devices
$devices = Get-OtoDataDevices
$devices | Select-Object Id, Name, LastLevel, Status | Format-Table

# 4. Get a specific device
$device = Get-OtoDataDevice -Id 20008447
Write-Output "Level: $($device.LastLevel * 100)%  Status: $($device.Status)"

# 5. Update a device name
Update-OtoDataDevice -Id 20008447 -Properties @{ Name = 'North Tank'; Route = 'Route 1' }

# 6. Download an Excel report
Export-OtoDataReport -Format Excel -OutPath .\tank_report.xlsx

# 7. Disconnect when done
Disconnect-OtoData
```

Enable verbose output to see request details and progress messages:

```powershell
$VerbosePreference = 'Continue'
Connect-OtoData -ApiKey 'YOUR_API_KEY_HERE'
Get-OtoDataDevices
```

---

## Quick Start — Python

```python
from pyOtodata import OtoDataClient

# 1. Create a client (connection is implicit — no separate connect step)
client = OtoDataClient(api_key='YOUR_API_KEY_HERE')

# 2. List all devices
devices = client.get_devices()
for d in devices:
    print(f"[{d['Id']}] {d.get('Name') or '—':<30s}  {d.get('Status'):<10s}  {d.get('LastLevel', 0):.1%}")

# 3. Get a specific device
device = client.get_device(20008447)
print(f"Level: {device['LastLevel']:.1%}  Status: {device['Status']}")

# 4. Update a device
client.update_device(20008447, {'Name': 'North Tank', 'Route': 'Route 1'})

# 5. Download an Excel report
data = client.download_report(fmt='Excel')
with open('tank_report.xlsx', 'wb') as f:
    f.write(data)
```

The Python client raises `pyOtodata.client.OtoDataError` on non-2xx responses:

```python
from pyOtodata.client import OtoDataError

try:
    device = client.get_device(999999)
except OtoDataError as e:
    print(f"API error {e.status_code}: {e}")
```

---

## PowerShell Module Reference

All functions require `Connect-OtoData` to have been called first, except `Get-OtoDataSampleDevice` which makes an unauthenticated request.

### Connection Functions

---

#### `Connect-OtoData`

Stores your API key (and optionally an alternate base URL) in the module's session state.  Must be called before any other function.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-ApiKey` | `string` | Yes | Your Otodata API key. |
| `-BaseUrl` | `string` | No | API base URL. Default: `https://telematics.otodatanetwork.com:4431` |

**Examples:**

```powershell
# Connect using the default primary server
Connect-OtoData -ApiKey 'd4QK5Fc9wdB8dr...'

# Connect using the Canadian server URL
Connect-OtoData -ApiKey 'd4QK5Fc9wdB8dr...' -BaseUrl 'https://neevo.otodata.ca/public/api/v1'
```

---

#### `Disconnect-OtoData`

Clears the stored API key from the module's session state.  Subsequent calls to API functions will throw until `Connect-OtoData` is called again.

**Parameters:** None.

**Examples:**

```powershell
Disconnect-OtoData
```

---

### Device Functions

---

#### `Get-OtoDataDevices`

Returns an array of all RTLM modules linked to the authenticated company.  Each element is a `PSCustomObject` matching the `Device` schema.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-LastDateUtc` | `string` | No | ISO8601 UTC date. Only return devices that have reported after this timestamp. Useful for incremental syncs. |

**Returns:** `PSCustomObject[]` — array of device objects.

**Examples:**

```powershell
# Get all devices
$devices = Get-OtoDataDevices

# Get devices updated since 1 Jan 2026
$devices = Get-OtoDataDevices -LastDateUtc '2026-01-01T00:00:00Z'

# Show a summary table
$devices | Select-Object Id, Name, @{N='Level%';E={'{0:P0}' -f $_.LastLevel}}, Status | Format-Table
```

---

#### `Get-OtoDataDevice`

Returns a single RTLM module by its serial number.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Id` | `long` | Yes | Device serial number. |
| `-Sensor` | `int` | No | Sensor index (0-based). Default: 0. |

**Returns:** `PSCustomObject` — single device object.

**Examples:**

```powershell
# Get device 20008447
$device = Get-OtoDataDevice -Id 20008447
Write-Output "$($device.Name) — $($device.LastLevel * 100)% full"

# Get the second sensor on a multi-sensor device
$device = Get-OtoDataDevice -Id 20008447 -Sensor 1
```

---

#### `Get-OtoDataSampleDevice`

Returns a dummy device populated with synthetic data.  Does **not** require authentication.  Useful for testing your client-side parsing without a live API key.

**Parameters:** None.

**Returns:** `PSCustomObject` — synthetic device object.

**Examples:**

```powershell
$sample = Get-OtoDataSampleDevice
Write-Output "Sample level: $($sample.LastLevel)"
```

---

#### `Get-OtoDataDeviceWarranties`

Returns the complete warranty history for a module, ordered newest to oldest.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Id` | `long` | Yes | Device serial number. |

**Returns:** `PSCustomObject[]` — array of warranty objects.  Each object contains `WarrantyType`, `WarrantyStatus`, `WarrantyStartDate`, `WarrantyEndDate`.

See [Enumerations](#enumerations) for `WarrantyType` and `WarrantyStatus` code values.

**Examples:**

```powershell
$warranties = Get-OtoDataDeviceWarranties -Id 20008447
$warranties | Format-Table WarrantyType, WarrantyStatus, WarrantyStartDate, WarrantyEndDate
```

---

#### `Update-OtoDataDevice`

Modifies one or more customer-configurable properties on a device.  Only fields included in the `-Properties` hashtable are changed; omitted fields are left unchanged.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Id` | `long` | Yes | Device serial number. |
| `-Properties` | `hashtable` | Yes | Fields to update. Any subset of the `DeviceUpdate` schema fields. |
| `-Sensor` | `int` | No | Sensor index (0-based). Default: 0. |
| `-EnforceValidation` | `bool` | No | When `$true`, the entire update is aborted if any single field fails validation. Error details are returned in the response. |

**Updatable fields:** `Name`, `TankFormatName`, `Address`, `City`, `Region`, `Country`, `PostalCode`, `CustomerId`, `DatabaseId`, `Email`, `GeneralLedgerLocation`, `IsInstalled`, `Latitude`, `Longitude`, `Note`, `Product`, `Route`, `TankName`, `TankNumber`, `TankSerialNumber`, `IsOnCall`, `LocationName`, `LocationNumber`.

**Returns:** `PSCustomObject` with an `Errors` array (empty on success).

**Examples:**

```powershell
# Update device name and route
Update-OtoDataDevice -Id 20008447 -Properties @{
    Name  = 'North Tank'
    Route = 'Route 1'
}

# Update with validation enforcement
$result = Update-OtoDataDevice -Id 20008447 -Properties @{ Product = 'Natural Gas' } -EnforceValidation $true
if ($result.Errors.Count -gt 0) {
    $result.Errors | ForEach-Object { Write-Warning "$($_.Property): $($_.Message)" }
}
```

---

#### `Reset-OtoDataDevice`

**Destructive operation.** Clears all customer-assigned data for a device from the Nee-Vo database.  This includes name, address, route, notes, product, and all other customer-configurable fields.

Pass an `-Exclude` array to preserve specific properties from being reset.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Id` | `long` | Yes | Device serial number. |
| `-Exclude` | `string[]` | No | Names of properties to preserve. Default: empty (reset everything). |

**Returns:** `$null` — empty response body on success.

**Examples:**

```powershell
# Reset everything
Reset-OtoDataDevice -Id 20008447

# Reset everything except the device name and tank serial number
Reset-OtoDataDevice -Id 20008447 -Exclude @('Name', 'TankSerialNumber')
```

---

#### `New-OtoDataDispatch`

Creates a dispatch for a device.  This action:
- Sends a push notification to end-users who have notifications enabled
- Fires any configured integration events (e.g. ERP, dispatch software)

> **Note:** Although the API Blueprint documents this as a POST request, the live service only accepts GET.  The module uses GET accordingly.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Id` | `long` | Yes | Device serial number. |
| `-Sensor` | `int` | No | Sensor index (0-based). Default: 0. |

**Returns:** `$null` — empty response body on success.

**Examples:**

```powershell
New-OtoDataDispatch -Id 20008447
```

---

#### `Stop-OtoDataDispatch`

Cancels an active dispatch for a device.  No push notification is sent, but integration events are fired if configured.

> **Note:** Although the API Blueprint documents this as a POST request, the live service only accepts GET.  The module uses GET accordingly.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Id` | `long` | Yes | Device serial number. |
| `-Sensor` | `int` | No | Sensor index (0-based). Default: 0. |

**Returns:** `$null` — empty response body on success.

**Examples:**

```powershell
Stop-OtoDataDispatch -Id 20008447
```

---

### Tank Level Functions

---

#### `Get-OtoDataTankLevels`

Gets historical level readings for **all** modules linked to the company within a date range.  Results are paginated at 10,000 readings per page.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-StartDateUtc` | `string` | Yes | ISO8601 UTC start date. Example: `'2025-01-01T00:00:00Z'` |
| `-EndDateUtc` | `string` | Yes | ISO8601 UTC end date. Example: `'2025-01-31T23:59:59Z'` |
| `-Page` | `int` | No | Page index (0-based). Default: 0. |

**Returns:** `PSCustomObject` with properties:
- `Count` — total readings in the response
- `StartDateUtc` / `EndDateUtc` — echoed from the request
- `Supplier` — always `"OTODATA"`
- `Logs` — array of log entries (see `TankLevelLog` schema)

**Examples:**

```powershell
# Get January 2025 readings
$history = Get-OtoDataTankLevels `
    -StartDateUtc '2025-01-01T00:00:00Z' `
    -EndDateUtc   '2025-01-31T23:59:59Z'
Write-Output "Total readings: $($history.Count)"
$history.Logs | Select-Object Id, Level, LogDateUtc | Format-Table

# Get page 2 (readings 10001-20000)
$page2 = Get-OtoDataTankLevels `
    -StartDateUtc '2025-01-01T00:00:00Z' `
    -EndDateUtc   '2025-12-31T23:59:59Z' `
    -Page 1
```

---

#### `Get-OtoDataDeviceTankLevels`

Gets historical level readings for a **single** module within a date range.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Id` | `long` | Yes | Device serial number. |
| `-StartDateUtc` | `string` | Yes | ISO8601 UTC start date. |
| `-EndDateUtc` | `string` | Yes | ISO8601 UTC end date. |
| `-Sensor` | `int` | No | Sensor index (0-based). Default: 0. |

**Returns:** Same structure as `Get-OtoDataTankLevels`.

**Examples:**

```powershell
$history = Get-OtoDataDeviceTankLevels `
    -Id           20008447 `
    -StartDateUtc '2025-01-01T00:00:00Z' `
    -EndDateUtc   '2025-01-31T23:59:59Z'
$history.Logs | ForEach-Object {
    Write-Output "$($_.LogDateUtc)  Level: $($_.Level * 100)%"
}
```

---

### Report Functions

---

#### `Export-OtoDataReport`

Downloads a summary report to a local file.  Supports Excel, CSV, and Suburban Software CSV formats.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-OutPath` | `string` | No | Destination file path. Default: `.\OtoData_Report_YYYYMMDD.xlsx` in the current directory. |
| `-Format` | `string` | No | File format: `Excel` (default), `CSV`, or `SuburbanSoftware`. |
| `-ExcludeNonInstalled` | `bool` | No | Exclude devices with `IsInstalled = $false`. |
| `-IncludeSubCompanies` | `bool` | No | Include devices from sub-company accounts. |

**Returns:** `FileInfo` object pointing to the saved file.

**Examples:**

```powershell
# Download a default Excel report
Export-OtoDataReport

# Download CSV excluding non-installed devices
Export-OtoDataReport -Format CSV -OutPath .\devices.csv -ExcludeNonInstalled $true

# Download all devices including sub-companies
Export-OtoDataReport -Format Excel -IncludeSubCompanies $true -OutPath .\full_report.xlsx
```

---

### Return Request Functions

---

#### `Get-OtoDataReturnRequests`

Gets return requests linked to the company, paginated at 100 records per page.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-IsOpen` | `bool` | Yes | `$true` = open/pending, `$false` = completed. |
| `-Page` | `int` | No | Page index (0-based). Default: 0. |

**Returns:** `PSCustomObject[]` — array of return request objects.  Each object has `ReturnRequestNumber`, `RmaNumber`, `Status`, `DeviceCount`, `RequesterName`, `RequesterEmail`, `Comment`, address fields, and a `ReturnRequestItems` array.

**Examples:**

```powershell
# Get all open return requests
$open = Get-OtoDataReturnRequests -IsOpen $true
Write-Output "Open requests: $($open.Count)"

# Get completed requests, page 2
$done = Get-OtoDataReturnRequests -IsOpen $false -Page 1
```

---

#### `Get-OtoDataReturnRequest`

Gets a single return request by its identifier.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Id` | `string` | Yes | Return request number, e.g. `'RR00001'`. |

**Returns:** `PSCustomObject` — single return request object with `ReturnRequestItems` array.

**Examples:**

```powershell
$rr = Get-OtoDataReturnRequest -Id 'RR00001'
Write-Output "Requester: $($rr.RequesterName)  Devices: $($rr.DeviceCount)"
$rr.ReturnRequestItems | Format-Table SerialNumber, Status, WarrantyStatus
```

---

#### `Update-OtoDataReturnRequest`

Updates the comment field on a return request.  This is the only customer-writable field.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Id` | `string` | Yes | Return request number, e.g. `'RR00001'`. |
| `-Comment` | `string` | Yes | New comment text (max 2048 characters). |

**Returns:** `PSCustomObject` with an `Errors` array (empty on success).

**Examples:**

```powershell
Update-OtoDataReturnRequest -Id 'RR00001' -Comment 'Shipped 2026-05-14 via FedEx tracking #XXXX'
```

---

### RMA Functions

---

#### `Get-OtoDataRmas`

Gets RMAs linked to the company, paginated at 100 records per page.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-IsOpen` | `bool` | Yes | `$true` = open/in-progress, `$false` = completed. |
| `-Page` | `int` | No | Page index (0-based). Default: 0. |

**Returns:** `PSCustomObject[]` — array of RMA objects.  Each object has `RmaNumber`, `CreatedDate`, `IsComplete`, and an `RmaItems` array.

**Examples:**

```powershell
$rmas = Get-OtoDataRmas -IsOpen $true
$rmas | Select-Object RmaNumber, CreatedDate, @{N='Items';E={$_.RmaItems.Count}} | Format-Table
```

---

#### `Get-OtoDataRma`

Gets a single RMA and all of its associated line items.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Id` | `string` | Yes | RMA number, e.g. `'RMA001'`. |

**Returns:** `PSCustomObject` — single RMA with `RmaItems` array.

**Examples:**

```powershell
$rma = Get-OtoDataRma -Id 'RMA001'
Write-Output "RMA: $($rma.RmaNumber)  Complete: $($rma.IsComplete)"
$rma.RmaItems | Format-Table SerialNumber, Status, IsReconciled, Conclusion
```

---

#### `Update-OtoDataRmaItem`

Updates the reconciliation status and/or customer comment on a specific RMA line item.  At least one of `-IsReconciled` or `-CustomerComment` must be provided.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-RmaId` | `string` | Yes | RMA number, e.g. `'RMA001'`. |
| `-DeviceId` | `long` | Yes | Device serial number. |
| `-IsReconciled` | `bool` | No | Mark the item as reconciled (`$true`) or not (`$false`). |
| `-CustomerComment` | `string` | No | Customer comment (max 2048 characters). |

**Returns:** `PSCustomObject` with an `Errors` array (empty on success).

**Examples:**

```powershell
# Mark as reconciled with a comment
Update-OtoDataRmaItem -RmaId 'RMA001' -DeviceId 20008447 `
    -IsReconciled $true `
    -CustomerComment "Confirmed received 2026-05-14"

# Update comment only, leave reconciliation unchanged
Update-OtoDataRmaItem -RmaId 'RMA001' -DeviceId 20008447 `
    -CustomerComment "Needs further inspection"
```

---

### Gas Meter Functions

---

#### `Get-OtoDataGasMeters`

Gets historical volumetric readings for all modules equipped with a gas meter sensor.  Paginated at 10,000 records per page.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-StartDateUtc` | `string` | Yes | ISO8601 UTC start date. |
| `-EndDateUtc` | `string` | Yes | ISO8601 UTC end date. |
| `-Page` | `int` | No | Page index (0-based). Default: 0. |

**Returns:** `PSCustomObject` with `Count`, `StartDateUtc`, `EndDateUtc`, `Supplier`, and a `Meters` array.  Each meter entry contains `AccountNumber`, `TankNumber`, `SerialNumber`, `IndexInitialValue`, `IndexFinalValue`, `PulseRate`, `Volume`, and `Units`.

**Examples:**

```powershell
$meters = Get-OtoDataGasMeters `
    -StartDateUtc '2025-01-01T00:00:00Z' `
    -EndDateUtc   '2025-02-01T00:00:00Z'
$meters.Meters | Format-Table SerialNumber, AccountNumber, Volume, Units
```

---

## Python Module Reference

### OtoDataClient Constructor

```python
from pyOtodata import OtoDataClient

client = OtoDataClient(api_key='YOUR_KEY')
# or specify an alternate base URL:
client = OtoDataClient(
    api_key='YOUR_KEY',
    base_url='https://neevo.otodata.ca/public/api/v1'
)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `api_key` | `str` | required | Your Otodata API key. |
| `base_url` | `str` | `'https://telematics.otodatanetwork.com:4431'` | API base URL. |

The constructor creates a `requests.Session` with `Authorization: Bearer {api_key}` and `Accept: application/json; charset=utf-8` headers pre-set.

**Error handling:** All methods raise `OtoDataError` (a subclass of `Exception`) on non-2xx responses.  The exception exposes `.status_code` (int) and a message string.

```python
from pyOtodata.client import OtoDataError

try:
    client.get_device(999999)
except OtoDataError as e:
    print(f"HTTP {e.status_code}: {e}")
```

---

### Device Methods

---

#### `get_devices(last_date_utc=None)`

Returns all modules linked to the authenticated company.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `last_date_utc` | `str \| None` | `None` | ISO8601 UTC date filter. Only return devices updated after this timestamp. |

**Returns:** `list[dict]` — list of device dicts.

**Examples:**

```python
# All devices
devices = client.get_devices()

# Incremental sync
devices = client.get_devices(last_date_utc='2026-01-01T00:00:00Z')

for d in devices:
    print(f"[{d['Id']}] {(d.get('Name') or '—'):<30s}  {d.get('LastLevel', 0):.1%}")
```

---

#### `get_device(device_id, sensor=None)`

Returns a single module by serial number.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `device_id` | `int` | required | Device serial number. |
| `sensor` | `int \| None` | `None` | Sensor index (0-based). Default: 0. |

**Returns:** `dict` — device dict.

**Examples:**

```python
device = client.get_device(20008447)
print(f"Level: {device['LastLevel']:.1%}  Battery: {device['BatteryLevel']}V")
```

---

#### `get_sample_device()`

Returns a dummy device for testing.  Does not require authentication.

**Returns:** `dict`

---

#### `get_device_warranties(device_id)`

Returns warranty history for a module, newest to oldest.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `device_id` | `int` | required | Device serial number. |

**Returns:** `list[dict]` with keys `WarrantyType`, `WarrantyStatus`, `WarrantyStartDate`, `WarrantyEndDate`.

See [Enumerations](#enumerations) for code values.

**Examples:**

```python
warranties = client.get_device_warranties(20008447)
for w in warranties:
    print(f"{w.get('WarrantyType'):<15s}  {w.get('WarrantyStatus'):<12s}  "
          f"{w.get('WarrantyStartDate', '?')} -> {w.get('WarrantyEndDate', '?')}")
```

---

#### `update_device(device_id, properties, sensor=None, enforce_validation=None)`

Modifies a module's customer-configurable properties.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `device_id` | `int` | required | Device serial number. |
| `properties` | `dict` | required | Fields to update. |
| `sensor` | `int \| None` | `None` | Sensor index. |
| `enforce_validation` | `bool \| None` | `None` | Abort all changes if any field fails. |

**Returns:** `dict` with `'Errors'` list.

**Examples:**

```python
client.update_device(20008447, {'Name': 'North Tank', 'Route': 'Route 1'})
```

---

#### `reset_device(device_id, exclude=None)`

**Destructive.** Clears all customer-assigned data for a device.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `device_id` | `int` | required | Device serial number. |
| `exclude` | `list[str] \| None` | `None` | Property names to preserve. |

**Returns:** `None`

**Examples:**

```python
client.reset_device(20008447, exclude=['Name', 'TankSerialNumber'])
```

---

#### `create_dispatch(device_id, sensor=None)`

Creates a dispatch — sends push notifications and fires integration events.

> **Note:** API Blueprint documents this as POST; live service requires GET.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `device_id` | `int` | required | Device serial number. |
| `sensor` | `int \| None` | `None` | Sensor index. |

**Returns:** `None`

---

#### `cancel_dispatch(device_id, sensor=None)`

Cancels an active dispatch.  Fires integration events but no push notification.

> **Note:** API Blueprint documents this as POST; live service requires GET.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `device_id` | `int` | required | Device serial number. |
| `sensor` | `int \| None` | `None` | Sensor index. |

**Returns:** `None`

---

### Tank Level Methods

---

#### `get_tank_levels(start_date_utc, end_date_utc, page=None)`

Gets historical level readings for all modules.  Paginated at 10,000 per page.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `start_date_utc` | `str` | required | ISO8601 UTC start date. |
| `end_date_utc` | `str` | required | ISO8601 UTC end date. |
| `page` | `int \| None` | `None` | Page index (0-based). |

**Returns:** `dict` with `Count`, `StartDateUtc`, `EndDateUtc`, `Supplier`, `Logs`.

**Examples:**

```python
history = client.get_tank_levels(
    start_date_utc='2025-01-01T00:00:00Z',
    end_date_utc='2025-01-31T23:59:59Z'
)
print(f"Readings: {history['Count']}")
```

---

#### `get_device_tank_levels(device_id, start_date_utc, end_date_utc, sensor=None)`

Gets historical level readings for a single module.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `device_id` | `int` | required | Device serial number. |
| `start_date_utc` | `str` | required | ISO8601 UTC start date. |
| `end_date_utc` | `str` | required | ISO8601 UTC end date. |
| `sensor` | `int \| None` | `None` | Sensor index. |

**Returns:** Same structure as `get_tank_levels`.

---

### Report Methods

---

#### `download_report(fmt='Excel', exclude_non_installed=None, include_sub_companies=None)`

Downloads a summary report as raw bytes.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `fmt` | `str` | `'Excel'` | `'Excel'`, `'CSV'`, or `'SuburbanSoftware'`. |
| `exclude_non_installed` | `bool \| None` | `None` | Exclude non-installed devices. |
| `include_sub_companies` | `bool \| None` | `None` | Include sub-company devices. |

**Returns:** `bytes`

**Examples:**

```python
data = client.download_report()
with open('report.xlsx', 'wb') as f:
    f.write(data)
```

---

### Return Request Methods

---

#### `get_return_requests(is_open, page=None)`

Gets return requests.  Paginated at 100 per page.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `is_open` | `bool` | required | `True` = open, `False` = completed. |
| `page` | `int \| None` | `None` | Page index. |

**Returns:** `list[dict]`

---

#### `get_return_request(request_id)`

Gets a single return request.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `request_id` | `str` | required | Return request number, e.g. `'RR00001'`. |

**Returns:** `dict`

---

#### `update_return_request(request_id, comment)`

Updates the comment on a return request.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `request_id` | `str` | required | Return request number. |
| `comment` | `str` | required | New comment (max 2048 chars). |

**Returns:** `dict` with `'Errors'` list.

---

### RMA Methods

---

#### `get_rmas(is_open, page=None)`

Gets RMAs.  Paginated at 100 per page.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `is_open` | `bool` | required | `True` = open, `False` = completed. |
| `page` | `int \| None` | `None` | Page index. |

**Returns:** `list[dict]`

---

#### `get_rma(rma_id)`

Gets a single RMA and all its line items.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `rma_id` | `str` | required | RMA number, e.g. `'RMA001'`. |

**Returns:** `dict`

---

#### `update_rma_item(rma_id, device_id, is_reconciled=None, customer_comment=None)`

Updates reconciliation status and/or customer comment on an RMA line item.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `rma_id` | `str` | required | RMA number. |
| `device_id` | `int` | required | Device serial number. |
| `is_reconciled` | `bool \| None` | `None` | Mark as reconciled. |
| `customer_comment` | `str \| None` | `None` | Customer comment (max 2048 chars). |

**Returns:** `dict` with `'Errors'` list.

**Examples:**

```python
client.update_rma_item(
    rma_id='RMA001',
    device_id=20008447,
    is_reconciled=True,
    customer_comment='Received OK — 2026-05-14',
)
```

---

### Gas Meter Methods

---

#### `get_gas_meters(start_date_utc, end_date_utc, page=None)`

Gets historical gas meter readings.  Paginated at 10,000 per page.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `start_date_utc` | `str` | required | ISO8601 UTC start date. |
| `end_date_utc` | `str` | required | ISO8601 UTC end date. |
| `page` | `int \| None` | `None` | Page index. |

**Returns:** `dict` with `Count`, `StartDateUtc`, `EndDateUtc`, `Supplier`, `Meters`.  Each meter entry has `AccountNumber`, `TankNumber`, `SerialNumber`, `IndexInitialValue`, `IndexFinalValue`, `PulseRate`, `Volume`, `Units`.

**Examples:**

```python
result = client.get_gas_meters(
    start_date_utc='2025-01-01T00:00:00Z',
    end_date_utc='2025-02-01T00:00:00Z'
)
for m in result.get('Meters', []):
    print(f"  [{m['SerialNumber']}] vol={m.get('Volume')} {m.get('Units')}")
```

---

## Example Scripts

Each endpoint has four scripts — a module-style PowerShell script, a raw-HTTP PowerShell script, a module-style Python script, and a raw-HTTP Python script.

The module scripts show idiomatic use of `POSH-Otodata` / `pyOtodata`.  The raw scripts show exactly what HTTP request is sent, useful when integrating with other tools or languages.

### PowerShell Examples

Scripts in `POSH-Otodata/Examples/`.  All scripts set `$VerbosePreference = 'Continue'` for detailed output and use `Write-Output` for data and `Write-Verbose` for status messages.

| Script | Description |
|--------|-------------|
| [GetDevices.ps1](POSH-Otodata/Examples/GetDevices.ps1) | Lists all devices with Id, Name, Level%, and Status. |
| [GetDevice.ps1](POSH-Otodata/Examples/GetDevice.ps1) | Gets a single device by serial number and prints full details. |
| [GetSampleDevice.ps1](POSH-Otodata/Examples/GetSampleDevice.ps1) | Gets the synthetic sample device — no API key required. |
| [GetDeviceWarranties.ps1](POSH-Otodata/Examples/GetDeviceWarranties.ps1) | Gets warranty history for a device. |
| [UpdateDevice.ps1](POSH-Otodata/Examples/UpdateDevice.ps1) | Updates name and note on a device, then reads back the new name. |
| [ResetDevice.ps1](POSH-Otodata/Examples/ResetDevice.ps1) | Interactive script that prompts for confirmation before resetting. |
| [CreateDispatch.ps1](POSH-Otodata/Examples/CreateDispatch.ps1) | Creates a dispatch for a device. |
| [CancelDispatch.ps1](POSH-Otodata/Examples/CancelDispatch.ps1) | Cancels an active dispatch. |
| [GetTankLevels.ps1](POSH-Otodata/Examples/GetTankLevels.ps1) | Gets the last 7 days of tank level history for all devices. |
| [GetDeviceTankLevels.ps1](POSH-Otodata/Examples/GetDeviceTankLevels.ps1) | Gets tank level history for a specific device. |
| [DownloadReport.ps1](POSH-Otodata/Examples/DownloadReport.ps1) | Downloads an Excel report to the current directory. |
| [GetReturnRequests.ps1](POSH-Otodata/Examples/GetReturnRequests.ps1) | Lists open return requests. |
| [GetReturnRequest.ps1](POSH-Otodata/Examples/GetReturnRequest.ps1) | Gets a single return request — auto-discovers ID from list. |
| [UpdateReturnRequest.ps1](POSH-Otodata/Examples/UpdateReturnRequest.ps1) | Updates a return request comment — auto-discovers ID. |
| [GetRmas.ps1](POSH-Otodata/Examples/GetRmas.ps1) | Lists open RMAs. |
| [GetRma.ps1](POSH-Otodata/Examples/GetRma.ps1) | Gets a single RMA — auto-discovers ID from list. |
| [UpdateRmaItem.ps1](POSH-Otodata/Examples/UpdateRmaItem.ps1) | Marks an RMA item reconciled — auto-discovers IDs. |
| [GetGasMeters.ps1](POSH-Otodata/Examples/GetGasMeters.ps1) | Gets gas meter readings for the last 30 days. |
| [GetDevices-Raw.ps1](POSH-Otodata/Examples/GetDevices-Raw.ps1) | Raw HTTP: GET /devices |
| [GetDevice-Raw.ps1](POSH-Otodata/Examples/GetDevice-Raw.ps1) | Raw HTTP: GET /devices/{id} |
| [GetSampleDevice-Raw.ps1](POSH-Otodata/Examples/GetSampleDevice-Raw.ps1) | Raw HTTP: GET /devices/sample |
| [GetDeviceWarranties-Raw.ps1](POSH-Otodata/Examples/GetDeviceWarranties-Raw.ps1) | Raw HTTP: GET /devices/{id}/warranties |
| [UpdateDevice-Raw.ps1](POSH-Otodata/Examples/UpdateDevice-Raw.ps1) | Raw HTTP: POST /devices/{id} |
| [ResetDevice-Raw.ps1](POSH-Otodata/Examples/ResetDevice-Raw.ps1) | Raw HTTP: POST /devices/{id}/reset |
| [CreateDispatch-Raw.ps1](POSH-Otodata/Examples/CreateDispatch-Raw.ps1) | Raw HTTP: GET /devices/{id}/createdispatch |
| [CancelDispatch-Raw.ps1](POSH-Otodata/Examples/CancelDispatch-Raw.ps1) | Raw HTTP: GET /devices/{id}/canceldispatch |
| [GetTankLevels-Raw.ps1](POSH-Otodata/Examples/GetTankLevels-Raw.ps1) | Raw HTTP: GET /tanklevels |
| [GetDeviceTankLevels-Raw.ps1](POSH-Otodata/Examples/GetDeviceTankLevels-Raw.ps1) | Raw HTTP: GET /devices/{id}/tanklevels |
| [DownloadReport-Raw.ps1](POSH-Otodata/Examples/DownloadReport-Raw.ps1) | Raw HTTP: GET /downloadReport |
| [GetReturnRequests-Raw.ps1](POSH-Otodata/Examples/GetReturnRequests-Raw.ps1) | Raw HTTP: GET /returnRequests |
| [GetReturnRequest-Raw.ps1](POSH-Otodata/Examples/GetReturnRequest-Raw.ps1) | Raw HTTP: GET /returnRequests/{id} |
| [UpdateReturnRequest-Raw.ps1](POSH-Otodata/Examples/UpdateReturnRequest-Raw.ps1) | Raw HTTP: POST /returnRequests/{id} |
| [GetRmas-Raw.ps1](POSH-Otodata/Examples/GetRmas-Raw.ps1) | Raw HTTP: GET /rmas |
| [GetRma-Raw.ps1](POSH-Otodata/Examples/GetRma-Raw.ps1) | Raw HTTP: GET /rmas/{id} |
| [UpdateRmaItem-Raw.ps1](POSH-Otodata/Examples/UpdateRmaItem-Raw.ps1) | Raw HTTP: POST /rmaItems/{rmaId}/devices/{deviceId} |
| [GetGasMeters-Raw.ps1](POSH-Otodata/Examples/GetGasMeters-Raw.ps1) | Raw HTTP: GET /meters |

### Python Examples

Scripts in `pyOtodata/Examples/`.  RMA and ReturnRequest scripts auto-discover IDs from list endpoints.  The reset script handles non-interactive environments gracefully.

| Script | Description |
|--------|-------------|
| [get_devices.py](pyOtodata/Examples/get_devices.py) | Lists all devices. |
| [get_device.py](pyOtodata/Examples/get_device.py) | Gets a single device and prints all fields. |
| [get_sample_device.py](pyOtodata/Examples/get_sample_device.py) | Gets the synthetic sample device. |
| [get_device_warranties.py](pyOtodata/Examples/get_device_warranties.py) | Gets warranty history for a device. |
| [update_device.py](pyOtodata/Examples/update_device.py) | Updates device name/note and reads back. |
| [reset_device.py](pyOtodata/Examples/reset_device.py) | Interactive reset with confirmation prompt. |
| [create_dispatch.py](pyOtodata/Examples/create_dispatch.py) | Creates a dispatch. |
| [cancel_dispatch.py](pyOtodata/Examples/cancel_dispatch.py) | Cancels a dispatch. |
| [get_tank_levels.py](pyOtodata/Examples/get_tank_levels.py) | Gets 7-day tank level history for all devices. |
| [get_device_tank_levels.py](pyOtodata/Examples/get_device_tank_levels.py) | Gets tank level history for a specific device. |
| [download_report.py](pyOtodata/Examples/download_report.py) | Downloads an Excel report and saves it. |
| [get_return_requests.py](pyOtodata/Examples/get_return_requests.py) | Lists open return requests. |
| [get_return_request.py](pyOtodata/Examples/get_return_request.py) | Gets a single return request — auto-discovers ID. |
| [update_return_request.py](pyOtodata/Examples/update_return_request.py) | Updates a return request comment — auto-discovers ID. |
| [get_rmas.py](pyOtodata/Examples/get_rmas.py) | Lists open RMAs. |
| [get_rma.py](pyOtodata/Examples/get_rma.py) | Gets a single RMA — auto-discovers ID. |
| [update_rma_item.py](pyOtodata/Examples/update_rma_item.py) | Marks an RMA item reconciled — auto-discovers IDs. |
| [get_gas_meters.py](pyOtodata/Examples/get_gas_meters.py) | Gets gas meter readings for the last 30 days. |
| [get_devices_raw.py](pyOtodata/Examples/get_devices_raw.py) | Raw HTTP: GET /devices |
| [get_device_raw.py](pyOtodata/Examples/get_device_raw.py) | Raw HTTP: GET /devices/{id} |
| [get_sample_device_raw.py](pyOtodata/Examples/get_sample_device_raw.py) | Raw HTTP: GET /devices/sample |
| [get_device_warranties_raw.py](pyOtodata/Examples/get_device_warranties_raw.py) | Raw HTTP: GET /devices/{id}/warranties |
| [update_device_raw.py](pyOtodata/Examples/update_device_raw.py) | Raw HTTP: POST /devices/{id} |
| [reset_device_raw.py](pyOtodata/Examples/reset_device_raw.py) | Raw HTTP: POST /devices/{id}/reset |
| [create_dispatch_raw.py](pyOtodata/Examples/create_dispatch_raw.py) | Raw HTTP: GET /devices/{id}/createdispatch |
| [cancel_dispatch_raw.py](pyOtodata/Examples/cancel_dispatch_raw.py) | Raw HTTP: GET /devices/{id}/canceldispatch |
| [get_tank_levels_raw.py](pyOtodata/Examples/get_tank_levels_raw.py) | Raw HTTP: GET /tanklevels |
| [get_device_tank_levels_raw.py](pyOtodata/Examples/get_device_tank_levels_raw.py) | Raw HTTP: GET /devices/{id}/tanklevels |
| [download_report_raw.py](pyOtodata/Examples/download_report_raw.py) | Raw HTTP: GET /downloadReport |
| [get_return_requests_raw.py](pyOtodata/Examples/get_return_requests_raw.py) | Raw HTTP: GET /returnRequests |
| [get_return_request_raw.py](pyOtodata/Examples/get_return_request_raw.py) | Raw HTTP: GET /returnRequests/{id} |
| [update_return_request_raw.py](pyOtodata/Examples/update_return_request_raw.py) | Raw HTTP: POST /returnRequests/{id} |
| [get_rmas_raw.py](pyOtodata/Examples/get_rmas_raw.py) | Raw HTTP: GET /rmas |
| [get_rma_raw.py](pyOtodata/Examples/get_rma_raw.py) | Raw HTTP: GET /rmas/{id} |
| [update_rma_item_raw.py](pyOtodata/Examples/update_rma_item_raw.py) | Raw HTTP: POST /rmaItems/{rmaId}/devices/{deviceId} |
| [get_gas_meters_raw.py](pyOtodata/Examples/get_gas_meters_raw.py) | Raw HTTP: GET /meters |

---

## API Reference

### Authentication

Every request (except `GET /devices/sample`) requires an API key.  Two methods are supported and can be used interchangeably:

**Bearer token (recommended):**
```
Authorization: Bearer YOUR_API_KEY
```

**Query string:**
```
GET /v1.0/DataService.svc/devices?k=YOUR_API_KEY
```

Both modules use the Bearer token method.

API keys are generated in the Nee-Vo web portal: https://neevo.otodata.ca/#/integrations/apikey

### Base URLs

| Environment | URL |
|-------------|-----|
| Primary (US/International) | `https://telematics.otodatanetwork.com:4431/v1.0/DataService.svc` |
| Primary (Canada) | `https://neevo.otodata.ca/public/api/v1/DataService.svc` |
| Secondary failover (US/International) | `https://telematics02.otodatanetwork.com:4431/v1.0/DataService.svc` |
| Secondary failover (Canada) | `https://neevo2.otodata.ca/public/api/v1/DataService.svc` |

The modules default to the US/International primary server.  Pass a different `BaseUrl` / `base_url` at connection time to switch servers.

### Endpoint Summary

| Method | Path | Operation | Auth Required |
|--------|------|-----------|---------------|
| GET | `/devices` | GetDevices | Yes |
| GET | `/devices/sample` | GetSampleDevice | No |
| GET | `/devices/{id}` | GetDevice | Yes |
| POST | `/devices/{id}` | UpdateDevice | Yes |
| GET | `/devices/{id}/warranties` | GetDeviceWarranties | Yes |
| POST | `/devices/{id}/reset` | ResetDevice | Yes |
| GET | `/devices/{id}/createdispatch` | CreateDispatch | Yes |
| GET | `/devices/{id}/canceldispatch` | CancelDispatch | Yes |
| GET | `/tanklevels` | GetTankLevels | Yes |
| GET | `/devices/{id}/tanklevels` | GetDeviceTankLevels | Yes |
| GET | `/downloadReport` | DownloadReport | Yes |
| GET | `/returnRequests` | GetReturnRequests | Yes |
| GET | `/returnRequests/{id}` | GetReturnRequest | Yes |
| POST | `/returnRequests/{id}` | UpdateReturnRequest | Yes |
| GET | `/rmas` | GetRmas | Yes |
| GET | `/rmas/{id}` | GetRma | Yes |
| POST | `/rmaItems/{rmaId}/devices/{deviceId}` | UpdateRmaItem | Yes |
| GET | `/meters` | GetGasMeters | Yes |

### Enumerations

#### WarrantyType

| Code | Name |
|------|------|
| 0 | Standard |
| 1 | Extended |
| 2 | BatteryPackOnly |

#### WarrantyStatus

| Code | Name |
|------|------|
| 2 | NotStarted |
| 3 | Expired |
| 4 | Active |
| 6 | Voided |
| 7 | Archived |

#### Report Format

| Value | Output | Notes |
|-------|--------|-------|
| `Excel` | `.xlsx` | Default. Full formatted spreadsheet. |
| `CSV` | `.csv` | Standard comma-separated values. |
| `SuburbanSoftware` | `.csv` | Formatted for Suburban Software dispatch import. |

### Pagination

Endpoints that can return large datasets are paginated.  Use the `page` parameter (0-based) to fetch subsequent pages.

| Endpoint | Page Size |
|----------|-----------|
| GetTankLevels | 10,000 readings |
| GetReturnRequests | 100 records (or 10,000 if not configured) |
| GetRmas | 100 records |
| GetGasMeters | 10,000 records |
| GetDevices, GetDevice, GetDeviceWarranties | Not paginated |

A response with fewer items than the page size indicates you have reached the last page.

### Known Quirks

**CreateDispatch and CancelDispatch use GET, not POST**

The official API Blueprint (`Source/Otodata_Nee-Vo_API.apib`) documents both `/devices/{id}/createdispatch` and `/devices/{id}/canceldispatch` as POST requests.  However, the live service returns HTTP 405 Method Not Allowed for POST and only accepts GET.

Both modules (PowerShell and Python) use GET for these endpoints.  The OpenAPI spec (`docs/openapi.yaml`) also reflects the live behaviour and notes the discrepancy.

**XML is the default response format**

The API defaults to XML unless the client explicitly requests JSON via:
```
Accept: application/json; charset=utf-8
```
Both modules always include this header.  Raw HTTP example scripts also include it.  If you call the API directly without this header you will receive XML.

**Nullable Name fields**

Some devices in the API have `Name: null` (the key is present but the value is null) rather than the key being absent.  Python code that uses `d.get('Name', '—')` for display will still receive `None` (not the default) in this case.  Use `(d.get('Name') or '—')` instead to handle both missing and null.

**Reset is irreversible**

`ResetDevice` / `reset_device` permanently deletes all customer data for a device.  It cannot be undone.  Both the module script and the example scripts include an interactive confirmation prompt.  The ResetDevice example scripts detect non-interactive (scripted) execution and print an instruction rather than crashing.

---

## API Documentation Files

| File | Description |
|------|-------------|
| [Source/Otodata_Nee-Vo_API.apib](Source/Otodata_Nee-Vo_API.apib) | Original API Blueprint specification (v29, the source of truth from Otodata). |
| [Source/Otodata_Nee-Vo_API (27).pdf](<Source/Otodata_Nee-Vo_API (27).pdf>) | Otodata vendor documentation PDF (API v27). |
| [Source/SANDBOX-Otodata_Nee-Vo_API.postman_collection.json](Source/SANDBOX-Otodata_Nee-Vo_API.postman_collection.json) | Postman collection pre-loaded with sandbox credentials for manual testing. |
| [docs/openapi.yaml](docs/openapi.yaml) | OpenAPI 3.0 specification derived from the API Blueprint. Corrects dispatch endpoints to GET (see Known Quirks). Can be imported into Postman, Insomnia, or any OpenAPI-compatible tool. |
| [docs/index.html](docs/index.html) | Interactive Swagger UI. Open this file directly in a browser — no web server required. The OpenAPI spec is embedded inline to avoid CORS issues with `file://` URLs. |

To open the Swagger UI, open [docs/index.html](docs/index.html) in your browser.  Click **Authorize** and paste your API key to enable Try-It-Out.
