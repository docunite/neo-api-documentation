# Document Upload API Documentation

## Overview

This API enables uploading and processing of documents in our document management system. After upload, documents are automatically processed, including text extraction and optional classification.

## Endpoint

```
POST /document-management/documents
```

## Authentication

All requests require a valid API key, which must be provided in the header.

## Request

The endpoint expects a `multipart/form-data` request with the following parameters:

| Parameter      | Type        | Required | Description                                                                                                   |
|----------------|-------------|----------|---------------------------------------------------------------------------------------------------------------|
| file           | File(s)     | Yes      | One or more files to be uploaded. Supported formats are PDF, DOCX, JPG, PNG, etc.                             |
| entity_id      | String      | Yes      | The ID of the entity to which the document should be linked (e.g., customer ID, project ID)                   |
| classify       | Boolean     | No       | Indicates whether the documents should be classified automatically. Default is `true`                         |
| prompt_id      | Boolean     | No       | The ID of the prompt used for classification (found in the Settings menu under Prompts). Note: this must be a prompt ID, not a name |
| original_path  | String      | No       | Optional path to be stored with the document (e.g., original file path)                                       |

## Example

### cURL Example

```bash
curl -X POST "https://your-api-domain.com/document-management/documents" \
  -H "X-API-KEY: <YOUR_API_KEY>" \
  -F "file=@/path/to/your/file.pdf" \
  -F "entity_id=CUSTOMER123" \
  -F "classify=true"
```

### Example with Multiple Files

```bash
curl -X POST "https://your-api-domain.com/document-management/documents" \
  -H "X-API-KEY: <YOUR_API_KEY>" \
  -F "file=@/path/to/your/file1.pdf" \
  -F "file=@/path/to/your/file2.pdf" \
  -F "entity_id=PROJECT456" \
  -F "classify=true" \
  -F "original_path=/original/file/path/"
```

### Python Example

```python
import requests
import os
import json
from pathlib import Path

def upload_documents(api_url, api_key, files_path, entity_id, classify=True, original_path=None):
    """
    Uploads one or more documents via the API.

    Args:
        api_url (str): Base URL of the API (e.g., "https://api.example.com/api")
        api_key (str): API key for authentication
        files_path (str or list): Path to a file or list of file paths
        entity_id (str): ID of the entity to which the documents should be linked
        classify (bool): Whether the documents should be classified
        original_path (str, optional): Original path of the documents

    Returns:
        dict: The API response as a dictionary
    """
    # Endpoint URL
    url = f"{api_url}/document-management/documents"

    # Headers with API key for authentication
    headers = {
        "X-API-KEY": api_key,
    }

    # Form data
    form_data = {
        "entity_id": entity_id,
        "classify": str(classify).lower(),
    }

    if original_path:
        form_data["original_path"] = original_path

    # Prepare files for upload
    if isinstance(files_path, str):
        files_path = [files_path]

    files = []
    for file_path in files_path:
        file_name = Path(file_path).name
        files.append(
            ('file', (file_name, open(file_path, 'rb'), 'application/pdf'))
        )

    # Send POST request
    response = requests.post(
        url=url,
        headers=headers,
        data=form_data,
        files=files
    )

    # Close files
    for _, (_, file_obj, _) in files:
        file_obj.close()

    # Process response
    try:
        result = response.json()
        print(f"Status: {response.status_code}")
        print(json.dumps(result, indent=2))
        return result
    except json.JSONDecodeError:
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
        return {"error": "Invalid JSON response"}

if __name__ == "__main__":
    # Configuration
    API_URL = "https://your-api-domain.com"     # Adjust to your API URL
    API_KEY = "your-api-key"                    # Replace with your API key

    # Example for single file upload
    document_path = "./example_document.pdf"    # Path to your sample document
    entity_id = "<unique id>"                   # Example entity ID

    print("Example 1: Upload a single document")
    upload_documents(
        api_url=API_URL,
        api_key=API_KEY,
        files_path=document_path,
        entity_id=entity_id
    )

    # Example for multiple files
    print("\nExample 2: Upload multiple documents")
    multiple_docs = [
        "./document1.pdf",
        "./document2.pdf",
        "./invoice.pdf"
    ]

    upload_documents(
        api_url=API_URL,
        api_key=API_KEY,
        files_path=multiple_docs,
        entity_id="<unique id>",
        classify=True,
        original_path="/customer/project-456/documents"
    )

    print("\nExample 3: Upload document without classification")
    upload_documents(
        api_url=API_URL,
        api_key=API_KEY,
        files_path="./contract.pdf",
        entity_id="<unique id>",
        classify=False
    )
```

### Javascript Example

```javascript
async function uploadDocuments(apiUrl, apiKey, filesPath, entityId, classify = true, originalPath = null) {
  const url = `${apiUrl}/document-management/documents`;

  const headers = {
    "X-API-KEY": apiKey,
  };

  const formData = new FormData();
  formData.append("entity_id", entityId);
  formData.append("classify", classify.toString());

  if (originalPath) {
    formData.append("original_path", originalPath);
  }

  // Ensure filesPath is an array
  if (typeof filesPath === "string") {
    filesPath = [filesPath];
  }

  for (const filePath of filesPath) {
    const fileName = filePath.split("/").pop(); // Get file name from path

    // Read file as Blob (Node.js environment required for fs)
    const fileBlob = await readFileAsBlob(filePath);
    formData.append("file", fileBlob, fileName);
  }

  try {
    const response = await fetch(url, {
      method: "POST",
      headers: headers,
      body: formData
    });

    const contentType = response.headers.get("content-type");
    if (contentType && contentType.includes("application/json")) {
      const result = await response.json();
      console.log("Status:", response.status);
      console.log(JSON.stringify(result, null, 2));
      return result;
    } else {
      const text = await response.text();
      console.log("Status:", response.status);
      console.log("Response:", text);
      return { error: "Invalid JSON response" };
    }
  } catch (error) {
    console.error("Upload error:", error);
    return { error: error.message };
  }
}

// Helper function to read files as Blob (Node.js only)
const fs = require("fs");
const path = require("path");

function readFileAsBlob(filePath) {
  return new Promise((resolve, reject) => {
    fs.readFile(filePath, (err, data) => {
      if (err) return reject(err);
      const blob = new Blob([data], { type: "application/pdf" });
      resolve(blob);
    });
  });
}

// Example calls
const API_URL = "https://your-api-domain.com";
const API_KEY = "your-api-key";
const ENTITY_ID = "<unique id>";

// Example 1: Single document
uploadDocuments(API_URL, API_KEY, "./example_document.pdf", ENTITY_ID);

// Example 2: Multiple documents
uploadDocuments(API_URL, API_KEY, [
  "./document1.pdf",
  "./document2.pdf",
  "./invoice.pdf"
], "<unique id>", true, "/customer/project-456/documents");

// Example 3: Without classification
uploadDocuments(API_URL, API_KEY, "./contract.pdf", "<unique id>", false);
```

## Response

### Successful Response (200 OK)

```json
{
  "message": "Documents uploaded successfully",
  "correlation_id": "8f7d9c2e-1234-5678-90ab-cdef01234567"
}
```

Because documents are "unpacked" by NEO (e.g., attachments from emails), the `correlation_id` serves as a grouping for these documents. It can be used to track the status of the uploaded documents.

### Error Responses

- **400 Bad Request**: Invalid request, e.g., if no files were uploaded
  ```json
  {
    "error": "No files uploaded"
  }
  ```

- **403 Forbidden**: No valid tenant provided
  ```json
  {
    "error": "No valid tenant provided"
  }
  ```

- **500 Internal Server Error**: Internal server error during processing

## Webhook Notifications

To receive notifications about the completion of document processing:

1. Register a webhook URL via the `/webhooks` endpoint
2. Your registered webhook will be notified when processing is complete

## Asynchronous Processing

Please note that document processing occurs asynchronously:

1. The upload endpoint immediately returns a response with a `correlation_id`
2. Actual processing (OCR, classification) happens in the background
3. Status and results can be queried later via other API endpoints

## Processing Steps

Uploaded documents go through the following processing steps:

1. **Upload**: Storage of the original file
2. **Extraction**: Conversion to text via OCR (Optical Character Recognition)
3. **Classification** (optional): Automatic determination of document type
4. **Enrichment**: Extraction of specific information based on document type

## Notes

- For batch processing of large numbers of documents, we recommend sending several smaller requests
- The parameter `classify=false` can be used to skip automatic classification, which speeds up processing
