"""Otodata Nee-Vo API v29 client."""

from __future__ import annotations

from typing import Any, Dict, List, Optional

import requests

BASE_URL = "https://telematics.otodatanetwork.com:4431"
_API_PATH = "/v1.0/DataService.svc"


class OtoDataError(Exception):
    """Raised when the API returns a non-2xx response."""

    def __init__(self, status_code: int, message: str) -> None:
        self.status_code = status_code
        super().__init__(f"HTTP {status_code}: {message}")


class OtoDataClient:
    """
    Full-coverage client for the Otodata Nee-Vo API v29.

    Usage::

        from pyOtodata import OtoDataClient

        client = OtoDataClient(api_key="YOUR_KEY")
        devices = client.get_devices()
    """

    def __init__(self, api_key: str, base_url: str = BASE_URL) -> None:
        self.base_url = base_url.rstrip("/")
        self._session = requests.Session()
        self._session.headers.update(
            {
                "Authorization": f"Bearer {api_key}",
                "Accept": "application/json; charset=utf-8",
            }
        )

    # ── Internal helpers ──────────────────────────────────────────────────────

    def _url(self, path: str) -> str:
        return f"{self.base_url}{_API_PATH}{path}"

    def _clean(self, params: dict) -> dict:
        """Strip keys whose value is None so they're not sent as query params."""
        return {k: v for k, v in params.items() if v is not None}

    def _handle(self, response: requests.Response) -> Any:
        if response.status_code in (200, 201):
            if not response.content:
                return None
            try:
                return response.json()
            except ValueError:
                return response.content
        if response.status_code == 204:
            return None
        raise OtoDataError(response.status_code, response.text)

    def _get(self, path: str, params: Optional[dict] = None) -> Any:
        r = self._session.get(self._url(path), params=self._clean(params or {}))
        return self._handle(r)

    def _post(
        self,
        path: str,
        body: Optional[dict] = None,
        params: Optional[dict] = None,
    ) -> Any:
        r = self._session.post(
            self._url(path),
            json=body,
            params=self._clean(params or {}),
        )
        return self._handle(r)

    # ── Devices ───────────────────────────────────────────────────────────────

    def get_devices(self, last_date_utc: Optional[str] = None) -> List[Dict]:
        """
        Returns all modules linked to the authenticated company.

        :param last_date_utc: ISO8601 UTC filter — only return devices updated after this date.
                              Example: ``'2026-01-01T00:00:00Z'``
        """
        return self._get("/devices", {"lastDateUtc": last_date_utc})

    def get_device(self, device_id: int, sensor: Optional[int] = None) -> Dict:
        """
        Returns a single module by serial number.

        :param device_id: Integer device serial number.
        :param sensor: Sensor index (0-based). Default: 0.
        """
        return self._get(f"/devices/{device_id}", {"sensor": sensor})

    def get_sample_device(self) -> Dict:
        """Returns a dummy module for testing. Does not require authentication."""
        r = requests.get(
            f"{self.base_url}{_API_PATH}/devices/sample",
            headers={"Accept": "application/json; charset=utf-8"},
        )
        return self._handle(r)

    def get_device_warranties(self, device_id: int) -> List[Dict]:
        """
        Returns warranty history for a module, ordered newest to oldest.

        :param device_id: Integer device serial number.
        """
        return self._get(f"/devices/{device_id}/warranties")

    def update_device(
        self,
        device_id: int,
        properties: Dict,
        sensor: Optional[int] = None,
        enforce_validation: Optional[bool] = None,
    ) -> Dict:
        """
        Modifies a module's customer-configurable properties.

        :param device_id: Integer device serial number.
        :param properties: Dict of DeviceUpdate fields to change.
        :param sensor: Sensor index (0-based). Default: 0.
        :param enforce_validation: If True, cancels all changes when any field fails.
        """
        params: Dict = {"sensor": sensor}
        if enforce_validation is not None:
            params["enforceValidation"] = str(enforce_validation).lower()
        return self._post(f"/devices/{device_id}", body=properties, params=params)

    def reset_device(
        self,
        device_id: int,
        exclude: Optional[List[str]] = None,
    ) -> None:
        """
        Clears all customer data for a device from the Nee-Vo database.

        :param device_id: Integer device serial number.
        :param exclude: List of Device property names to preserve (not reset).
        """
        return self._post(
            f"/devices/{device_id}/reset",
            body={"Exclude": exclude or []},
        )

    def create_dispatch(
        self, device_id: int, sensor: Optional[int] = None
    ) -> None:
        """
        Creates a dispatch for a device. Sends push notifications and fires integration events.

        :param device_id: Integer device serial number.
        :param sensor: Sensor index (0-based). Default: 0.
        """
        return self._get(
            f"/devices/{device_id}/createdispatch", {"sensor": sensor}
        )

    def cancel_dispatch(
        self, device_id: int, sensor: Optional[int] = None
    ) -> None:
        """
        Cancels an active dispatch. Fires integration events but no push notification.

        :param device_id: Integer device serial number.
        :param sensor: Sensor index (0-based). Default: 0.
        """
        return self._get(
            f"/devices/{device_id}/canceldispatch", {"sensor": sensor}
        )

    # ── Tank Levels ───────────────────────────────────────────────────────────

    def get_tank_levels(
        self,
        start_date_utc: str,
        end_date_utc: str,
        page: Optional[int] = None,
    ) -> Dict:
        """
        Gets historical level readings for all modules. Paginated at 10,000 per page.

        :param start_date_utc: ISO8601 UTC start date. Example: ``'2025-01-01T00:00:00Z'``
        :param end_date_utc: ISO8601 UTC end date.
        :param page: Page index (0-based). Default: 0.
        """
        return self._get(
            "/tanklevels",
            {
                "startDateUtc": start_date_utc,
                "endDateUtc": end_date_utc,
                "page": page,
            },
        )

    def get_device_tank_levels(
        self,
        device_id: int,
        start_date_utc: str,
        end_date_utc: str,
        sensor: Optional[int] = None,
    ) -> Dict:
        """
        Gets historical level readings for a single module.

        :param device_id: Integer device serial number.
        :param start_date_utc: ISO8601 UTC start date.
        :param end_date_utc: ISO8601 UTC end date.
        :param sensor: Sensor index (0-based). Default: 0.
        """
        return self._get(
            f"/devices/{device_id}/tanklevels",
            {
                "startDateUtc": start_date_utc,
                "endDateUtc": end_date_utc,
                "sensor": sensor,
            },
        )

    # ── Reports ───────────────────────────────────────────────────────────────

    def download_report(
        self,
        fmt: str = "Excel",
        exclude_non_installed: Optional[bool] = None,
        include_sub_companies: Optional[bool] = None,
    ) -> bytes:
        """
        Downloads a summary report as raw bytes.

        :param fmt: File format — ``'Excel'`` (default), ``'CSV'``, or ``'SuburbanSoftware'``.
        :param exclude_non_installed: Exclude non-installed devices.
        :param include_sub_companies: Include sub-company devices.
        :returns: Raw file bytes (write to a file with the appropriate extension).
        """
        params: Dict = {"format": fmt}
        if exclude_non_installed is not None:
            params["excludeNonInstalled"] = str(exclude_non_installed).lower()
        if include_sub_companies is not None:
            params["includeSubCompanies"] = str(include_sub_companies).lower()
        r = self._session.get(
            self._url("/downloadReport"), params=self._clean(params)
        )
        if r.status_code in (200, 204):
            return r.content
        raise OtoDataError(r.status_code, r.text)

    # ── Return Requests ───────────────────────────────────────────────────────

    def get_return_requests(
        self, is_open: bool, page: Optional[int] = None
    ) -> List[Dict]:
        """
        Gets return requests linked to the company. Paginated at 100 per page.

        :param is_open: ``True`` = open/pending; ``False`` = completed.
        :param page: Page index (0-based). Default: 0.
        """
        return self._get(
            "/returnRequests",
            {"isOpen": str(is_open).lower(), "page": page},
        )

    def get_return_request(self, request_id: str) -> Dict:
        """
        Gets a single return request by ID.

        :param request_id: Return request number string, e.g. ``'RR00001'``.
        """
        return self._get(f"/returnRequests/{request_id}")

    def update_return_request(self, request_id: str, comment: str) -> Dict:
        """
        Updates the comment on a return request.

        :param request_id: Return request number string, e.g. ``'RR00001'``.
        :param comment: New comment text (max 2048 chars).
        """
        return self._post(
            f"/returnRequests/{request_id}", body={"Comment": comment}
        )

    # ── RMAs ──────────────────────────────────────────────────────────────────

    def get_rmas(self, is_open: bool, page: Optional[int] = None) -> List[Dict]:
        """
        Gets RMAs linked to the company. Paginated at 100 per page.

        :param is_open: ``True`` = open; ``False`` = completed.
        :param page: Page index (0-based). Default: 0.
        """
        return self._get(
            "/rmas", {"isOpen": str(is_open).lower(), "page": page}
        )

    def get_rma(self, rma_id: str) -> Dict:
        """
        Gets a single RMA and its associated items.

        :param rma_id: RMA number string, e.g. ``'RMA123'``.
        """
        return self._get(f"/rmas/{rma_id}")

    def update_rma_item(
        self,
        rma_id: str,
        device_id: int,
        is_reconciled: Optional[bool] = None,
        customer_comment: Optional[str] = None,
    ) -> Dict:
        """
        Updates reconciliation status and/or customer comment on an RMA item.

        :param rma_id: RMA number string, e.g. ``'RMA001'``.
        :param device_id: Device serial number (integer).
        :param is_reconciled: Mark item reconciled (True) or not (False).
        :param customer_comment: Customer comment (max 2048 chars).
        """
        body: Dict = {}
        if is_reconciled is not None:
            body["IsReconciled"] = is_reconciled
        if customer_comment is not None:
            body["CustomerComment"] = customer_comment
        return self._post(
            f"/rmaItems/{rma_id}/devices/{device_id}", body=body
        )

    # ── Gas Meters ────────────────────────────────────────────────────────────

    def get_gas_meters(
        self,
        start_date_utc: str,
        end_date_utc: str,
        page: Optional[int] = None,
    ) -> Dict:
        """
        Gets historical readings for all gas meter modules. Paginated at 10,000 per page.

        :param start_date_utc: ISO8601 UTC start date. Example: ``'2025-01-15T00:00:00Z'``
        :param end_date_utc: ISO8601 UTC end date.
        :param page: Page index (0-based). Default: 0.
        """
        return self._get(
            "/meters",
            {
                "startDateUtc": start_date_utc,
                "endDateUtc": end_date_utc,
                "page": page,
            },
        )
