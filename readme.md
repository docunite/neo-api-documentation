# NEO-API Documentation (wip)

## Overview

Welcome to the documentation for the NEO-API. This API enables programmatic management of documents, entities (Spaces), and document types.

With this API you can:

- Upload and process documents
- Create and manage entities (Spaces) as containers for documents
- Query and utilize document types
- Perform text extraction, classification, and enrichment of documents
- Query and analyze document content
- Create and manage your own prompts and schemas for classification and enrichment

## Table of Contents

- [Getting Started](#getting-started)
- [Authentication](#authentication)
- [API Endpoints](#api-endpoints)
- [Error Handling](#error-handling)
- [Rate Limiting](#rate-limiting)
- [Webhooks](#webhooks)
- [Best Practices](#best-practices)

## Getting Started

To use the API, you need:

1. A registered NEO account
2. A valid API key, which can be generated in the administration area
3. Basic knowledge of RESTful APIs and HTTP requests

### Typical Workflow

A typical workflow for using the API involves the following steps:

1. **Create an Entity**: First, create an entity (Space) to serve as a container for your documents.
2. **Upload Documents**: Upload documents and assign them to the created entity.
3. **Monitor Processing Status**: Monitor the processing status of uploaded documents.
4. **Query Document Content**: Query metadata, extracted text, or classified information.

## Authentication

All API requests require authentication using an API key, which must be sent in the HTTP header of each request.

```
X-API-KEY:  <YOUR_API_KEY>
```

API keys can be generated and managed in the administration area of the document management system. Each key is assigned to a specific tenant and determines the permissions for API access.

> **Security Note**: Treat your API key like a password. Do not share it with third parties and do not store it in plain text in your source code.

## API Endpoints

The API is divided into several logical areas:

### [Entity Management](entities.md)

Endpoints for managing entities (Spaces), which serve as containers for documents.

### [Document Management](upload.md)

Endpoints for uploading, processing, and querying documents.

### [Document Types](document-types.md)

Endpoints for querying document types.

### [Schemas](schemas.md)

Endpoints for managing schemas.

### [Prompts](prompts.md)

Endpoints for managing prompts.

## Error Handling

The API uses standard HTTP status codes to indicate the success or failure of a request:

- **2xx** - Successful requests (e.g., 200 OK, 201 Created)
- **4xx** - Client errors (e.g., 400 Bad Request, 401 Unauthorized, 404 Not Found)
- **5xx** - Server errors (e.g., 500 Internal Server Error)

Error messages are returned in JSON format:

```json
{
  "error": "Description of the error",
  "details": "Additional information (optional)"
}
```

### Common Errors

| Status | Description            | Possible Cause                       |
|--------|------------------------|--------------------------------------|
| 400    | Bad Request            | Missing or invalid parameters        |
| 401    | Unauthorized           | Invalid or missing API key           |
| 403    | Forbidden              | Insufficient permissions             |
| 404    | Not Found              | Resource not found                   |
| 413    | Payload Too Large      | File too large                       |
| 429    | Too Many Requests      | Rate limit exceeded                  |
| 500    | Internal Server Error  | Server error                         |

## Rate Limiting

The API is subject to rate limits to ensure consistent service quality for all users. The exact limits vary depending on the license type and are included in the HTTP headers of each response:

- `X-RateLimit-Limit`: Maximum number of requests per period
- `X-RateLimit-Remaining`: Remaining requests in the current period
- `X-RateLimit-Reset`: Time when the limit resets (Unix timestamp)

If the limits are exceeded, a 429 Too Many Requests status is returned.

## Webhooks

For asynchronous processes such as document processing, the system offers webhook notifications:

1. Register a webhook endpoint via the API
2. Select the events you want to be notified about
3. Receive real-time updates when the selected events occur

Typical events for webhooks:
- Text extraction completed
- Classification completed
- Enrichment completed

## Best Practices

### General Recommendations

1. **Implement Error Handling**: Capture error codes and respond appropriately.
2. **Use Pagination**: Use pagination parameters for large data sets.
3. **Minimize Data Volume**: Only request the data you actually need.
4. **Implement Caching**: Cache frequently requested, static data locally.
5. **Backoff Strategies**: Implement exponential backoff for retry attempts.

### Document Upload

1. **Batching**: Split large numbers of documents into smaller batches.
2. **Check File Types**: Ensure that uploaded files conform to supported formats.
3. **Correlation IDs**: Store the returned correlation IDs to track processing results.

### Security

1. **Use HTTPS**: Only send requests via HTTPS, never via unencrypted HTTP connections.
2. **Store API Keys Securely**: Store API keys in environment variables or secure key stores.
3. **Minimal Permissions**: Use API keys with the least privileges necessary.

## Support and Contact

If you have questions or issues with the API, please contact our support team.

---

© 2025 docunite GmbH. All rights reserved.

```
