# Document Status API Documentation

## Overview

This endpoint returns the current processing status of a single document as one simple value.
It provides an easy way for external systems (e.g., a DMS such as ELO) to poll a document and
react to the outcome — without needing to know whether the document is processed by the standard
workflow (extraction, classification, enrichment) or by a [pipeline](pipelines.md). Both are
treated the same: *a process running over the document*.

## Endpoint

```
GET /document-management/documents/{documentId}/status
```

## Authentication

All requests require a valid API key, which must be provided in the header.

```
X-API-KEY: <YOUR_API_KEY>
```

## Request

| Parameter    | Type         | In   | Required | Description                        |
|--------------|--------------|------|----------|------------------------------------|
| documentId   | String (UUID)| Path | Yes      | The ID of the document to query    |

## Response

### Successful Response (200 OK)

```json
{
  "document_id": "3854b9bd-5c17-4d2c-8d3b-1f95401ee89a",
  "status": "running",
  "error_message": null
}
```

| Field           | Type            | Description                                                                    |
|-----------------|-----------------|--------------------------------------------------------------------------------|
| document_id     | String (UUID)   | The queried document ID                                                        |
| status          | String          | The current processing status (see table below)                               |
| error_message   | String or null  | The technical error message. Only populated when `status` is `error`, otherwise `null` |

### Status Values

| Status      | Description                                                                 |
|-------------|-----------------------------------------------------------------------------|
| `queued`    | The document is enqueued for processing but has not started yet             |
| `running`   | A process is currently running over the document                            |
| `completed` | The process finished successfully                                           |
| `error`     | The process failed; `error_message` contains the technical reason           |
| `cancelled` | The process was cancelled by the user                                       |

The status reflects the most relevant current activity across the standard workflow and any
pipeline executions: an active run (`running`/`queued`) takes precedence; otherwise the outcome
of the most recent run is returned (`completed`/`error`/`cancelled`).

### Error Responses

- **404 Not Found**: The document ID is unknown
  ```json
  {
    "error": "Document not found"
  }
  ```

## Example

### cURL Example

```bash
curl -X GET "https://your-api-domain.com/document-management/documents/<DOCUMENT_ID>/status" \
  -H "X-API-KEY: <YOUR_API_KEY>"
```

### Python Example

```python
import requests
import time

def get_document_status(api_url, api_key, document_id):
    """Fetches the current processing status of a document."""
    url = f"{api_url}/document-management/documents/{document_id}/status"
    headers = {"X-API-KEY": api_key}

    response = requests.get(url, headers=headers)
    if response.status_code == 404:
        return None
    response.raise_for_status()
    return response.json()


def wait_until_done(api_url, api_key, document_id, interval=5, timeout=600):
    """Polls the status until the document reaches a terminal state."""
    deadline = time.time() + timeout
    while time.time() < deadline:
        status = get_document_status(api_url, api_key, document_id)
        if status is None:
            raise ValueError("Document not found")

        print(f"status={status['status']}")
        if status["status"] in ("completed", "error", "cancelled"):
            return status
        time.sleep(interval)

    raise TimeoutError("Document did not reach a terminal state in time")


if __name__ == "__main__":
    API_URL = "https://your-api-domain.com"
    API_KEY = "your-api-key"
    DOCUMENT_ID = "<DOCUMENT_ID>"

    result = wait_until_done(API_URL, API_KEY, DOCUMENT_ID)
    print(result)
    if result["status"] == "error":
        print("Processing failed:", result["error_message"])
```

## Notes

- **Polling**: The endpoint is designed for lightweight polling. Use a sensible interval (e.g.,
  every few seconds) and an exponential backoff strategy, and stop once a terminal status
  (`completed`, `error`, `cancelled`) is reached.
- **Retries are internal**: If a worker retries a processing step internally, the status remains
  `running`. There is no separate retry status.
- **Reprocessing**: When a document is processed again, an active run reports `running`/`queued`
  again and supersedes the previous outcome.
- **Error message lifetime**: `error_message` is served live from the failed run and reflects the
  most recent failure. It is not a persisted document field.
