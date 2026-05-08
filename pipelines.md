# Pipeline Execution API Documentation

## Overview

Pipelines are automated processing workflows in NEO that can be executed on documents. A pipeline consists of multiple processing nodes that run sequentially or in parallel.

With the Pipeline API you can:

- Execute a pipeline on an existing document
- Execute a pipeline automatically during document upload
- Poll the execution status to track progress

## Authentication

All requests require a valid API key, which must be provided in the header.

```
X-API-KEY: <YOUR_API_KEY>
```

## Endpoints

### Start Pipeline Execution

Starts a pipeline execution on an existing document.

```
POST /document-management/documents/{documentId}/pipelines/{pipelineId}/executions
```

#### Path Parameters

| Parameter    | Type | Required | Description                              |
|--------------|------|----------|------------------------------------------|
| documentId   | UUID | Yes      | The ID of the document to process        |
| pipelineId   | UUID | Yes      | The ID of the pipeline to execute        |

#### Request Body (JSON, optional)

| Parameter  | Type              | Required | Description                                            |
|------------|-------------------|----------|--------------------------------------------------------|
| parameters | Object (key/value)| No       | Key-value pairs for pipeline parameters. Parameter names must match the pipeline definition. |

#### Example

```bash
curl -X POST "https://your-api-domain.com/document-management/documents/123e4567-e89b-12d3-a456-426614174000/pipelines/789e0123-f45g-67h8-b901-426614174002/executions" \
  -H "X-API-KEY: <YOUR_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "parameters": {
      "language": "de",
      "output_format": "json"
    }
  }'
```

#### Example without Parameters

```bash
curl -X POST "https://your-api-domain.com/document-management/documents/123e4567-e89b-12d3-a456-426614174000/pipelines/789e0123-f45g-67h8-b901-426614174002/executions" \
  -H "X-API-KEY: <YOUR_API_KEY>"
```

#### Successful Response (202 Accepted)

```json
{
  "execution_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

The `execution_id` can be used to poll the execution status.

#### Error Responses

- **400 Bad Request**: Missing required pipeline parameters or invalid values
- **404 Not Found**: Document or pipeline not found

---

### Get Pipeline Execution Status

Retrieves the current status of a pipeline execution. Use this endpoint to poll for completion after starting a pipeline.

```
GET /document-management/pipelines/executions/{executionId}
```

#### Path Parameters

| Parameter   | Type | Required | Description                               |
|-------------|------|----------|-------------------------------------------|
| executionId | UUID | Yes      | The execution ID returned when starting a pipeline |

#### Example

```bash
curl -X GET "https://your-api-domain.com/document-management/pipelines/executions/a1b2c3d4-e5f6-7890-abcd-ef1234567890" \
  -H "X-API-KEY: <YOUR_API_KEY>"
```

#### Successful Response (200 OK)

```json
{
  "execution_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "document_id": "123e4567-e89b-12d3-a456-426614174000",
  "pipeline_id": "789e0123-f45g-67h8-b901-426614174002",
  "pipeline_version": 1,
  "state": "running",
  "progress": {
    "completed": 2,
    "total": 5
  },
  "started_at": "2026-05-08T12:00:00Z",
  "ended_at": null,
  "error_message": null
}
```

#### Response Fields

| Field            | Type     | Description                                                      |
|------------------|----------|------------------------------------------------------------------|
| execution_id     | UUID     | Unique identifier of the execution                               |
| document_id      | UUID     | ID of the document being processed                               |
| pipeline_id      | UUID     | ID of the executed pipeline                                      |
| pipeline_version | Integer  | Version of the pipeline definition used                          |
| state            | String   | Current state (see below)                                        |
| progress         | Object   | Node progress with `completed` and `total` counts                |
| started_at       | DateTime | Timestamp when the execution started                             |
| ended_at         | DateTime | Timestamp when the execution ended (`null` if still running)     |
| error_message    | String   | Error details if the execution failed (`null` otherwise)         |

#### Execution States

| State       | Description                                      |
|-------------|--------------------------------------------------|
| created     | Execution has been created but not yet started    |
| running     | Execution is currently in progress                |
| completed   | Execution finished successfully                   |
| failed      | Execution failed (see `error_message` for details)|
| cancelled   | Execution was cancelled                           |

#### Error Responses

- **404 Not Found**: Execution not found

---

### Pipeline Execution via Document Upload

Pipelines can also be triggered automatically during document upload by providing the `pipeline_id` parameter. See the [Document Upload](upload.md) documentation for details.

```bash
curl -X POST "https://your-api-domain.com/document-management/documents" \
  -H "X-API-KEY: <YOUR_API_KEY>" \
  -F "file=@/path/to/document.pdf" \
  -F "entity_id=123e4567-e89b-12d3-a456-426614174000" \
  -F "pipeline_id=789e0123-f45g-67h8-b901-426614174002" \
  -F "pipeline_parameters={\"language\": \"de\"}"
```

## Polling for Completion

After starting a pipeline execution, you can poll for its completion using the status endpoint. Here is a recommended approach:

### Example: Polling Workflow (Python)

```python
import requests
import time

API_URL = "https://your-api-domain.com"
API_KEY = "your-api-key"
HEADERS = {"X-API-KEY": API_KEY}

# Step 1: Start pipeline execution
response = requests.post(
    f"{API_URL}/document-management/documents/{document_id}/pipelines/{pipeline_id}/executions",
    headers={**HEADERS, "Content-Type": "application/json"},
    json={"parameters": {"language": "de"}}
)
execution_id = response.json()["execution_id"]

# Step 2: Poll for completion
while True:
    status = requests.get(
        f"{API_URL}/document-management/pipelines/executions/{execution_id}",
        headers=HEADERS
    ).json()

    print(f"State: {status['state']} - Progress: {status['progress']['completed']}/{status['progress']['total']}")

    if status["state"] in ("completed", "failed", "cancelled"):
        break

    time.sleep(2)  # Poll every 2 seconds

# Step 3: Handle result
if status["state"] == "completed":
    print("Pipeline finished successfully!")
elif status["state"] == "failed":
    print(f"Pipeline failed: {status['error_message']}")
```

### Example: Polling Workflow (JavaScript)

```javascript
const API_URL = "https://your-api-domain.com";
const API_KEY = "your-api-key";
const HEADERS = { "X-API-KEY": API_KEY };

async function executePipelineAndWait(documentId, pipelineId, parameters = {}) {
  // Step 1: Start pipeline execution
  const startResponse = await fetch(
    `${API_URL}/document-management/documents/${documentId}/pipelines/${pipelineId}/executions`,
    {
      method: "POST",
      headers: { ...HEADERS, "Content-Type": "application/json" },
      body: JSON.stringify({ parameters })
    }
  );
  const { execution_id } = await startResponse.json();

  // Step 2: Poll for completion
  while (true) {
    const statusResponse = await fetch(
      `${API_URL}/document-management/pipelines/executions/${execution_id}`,
      { headers: HEADERS }
    );
    const status = await statusResponse.json();

    console.log(`State: ${status.state} - Progress: ${status.progress.completed}/${status.progress.total}`);

    if (["completed", "failed", "cancelled"].includes(status.state)) {
      return status;
    }

    await new Promise(resolve => setTimeout(resolve, 2000)); // Poll every 2 seconds
  }
}

// Usage
executePipelineAndWait("document-uuid", "pipeline-uuid", { language: "de" })
  .then(result => {
    if (result.state === "completed") {
      console.log("Pipeline finished successfully!");
    } else if (result.state === "failed") {
      console.log(`Pipeline failed: ${result.error_message}`);
    }
  });
```

## Best Practices

1. **Polling Interval**: Use a polling interval of 2-5 seconds. Avoid polling too frequently to reduce unnecessary load.
2. **Timeout**: Implement a maximum polling duration to avoid indefinite waiting in case of unexpected issues.
3. **Pipeline Parameters**: Check the pipeline definition for required and optional parameters before starting an execution.
4. **Error Handling**: Always check the `error_message` field when a pipeline execution fails.
