# Document Type API Documentation

## Overview

This API enables access to document types in NEO. Document types define the various kinds of documents that can be processed in the system and control the specific processing logic for each type.

## Authentication

A valid API key is required for all requests, which must be submitted in the header.

## Endpoints

### Retrieve All Document Types

Retrieves all available document types for the current tenant.

```
GET /document-type-management/document-types
```

#### Request

No additional parameters required. The tenant ID is automatically determined from the authentication context.

#### Example

```bash
curl -X GET "https://your-api-domain.com/document-type-management/document-types" \
  -H "X-API-KEY: <YOUR_API_KEY>"
```

#### Successful Response (200 OK)

```json
[
  {
    "id": "1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p",
    "name_de": "Rechnung",
    "name_en": "Invoice",
    "description": "",
    "synonym_of": "",
    "has_enrichment_prompt": false,
    "created": "2023-04-15T14:30:00Z",
    "modified": "2023-04-15T14:30:00Z"
  },
  {
    "id": "2b3c4d5e-6f7g-8h9i-0j1k-2l3m4n5o6p7q",
    "name_de": "Mietvertrag",
    "name_en": "Contract",
    "description": "",
    "synonym_of": "060cb344-fa93-4d4c-a194-3f9ea11d034e",
    "has_enrichment_prompt": true,
    "created": "2023-04-10T09:15:00Z",
    "modified": "2023-04-12T11:20:00Z"
  }
]
```

### Retrieve a Specific Document Type

Retrieves a single document type by its ID.

```
GET /document-type-management/document-types/{document_type_id}
```

#### Parameters

| Parameter         | Type   | Required | Description                                  |
|-------------------|--------|----------|----------------------------------------------|
| document_type_id  | String | Yes      | The unique ID of the document type to fetch  |

#### Example

```bash
curl -X GET "https://your-api-domain.com/document-type-management/document-types/1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p" \
  -H "X-API-KEY: <YOUR_API_KEY>"
```

#### Successful Response (200 OK)

```json
{
  "id": "1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p",
  "name": "Invoice",
  "description": "Incoming invoices from suppliers",
  "synonym_of": "060cb344-fa93-4d4c-a194-3f9ea11d034e",
  "created": "2023-04-15T14:30:00Z",
  "modified": "2023-04-15T14:30:00Z"
}
```

## Error Responses

- **403 Forbidden**: No valid tenant provided
  ```json
  {
    "error": "No valid tenant provided"
  }
  ```

- **404 Not Found**: Document type not found (only when querying a specific document type)
  ```json
  {
    "error": "Document type 1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p not found"
  }
  ```

- **500 Internal Server Error**: Internal server error during processing

# Document Type Hierarchy

In NEO, document types can be organized hierarchically, where a document type can be a synonym (or subtype) of another. This relationship is represented using the `synonym_of` attribute.

## The `synonym_of` Attribute

The `synonym_of` field in a document type contains the ID of the parent document type. If `synonym_of` is null or empty, it is a top-level document type. This structure enables the representation of com[...]

Example of a hierarchy:
- Contract (top level, `synonym_of` = null)
  - Employment Contract (`synonym_of` = ID of "Contract")
    - Fixed-Term Employment Contract (`synonym_of` = ID of "Employment Contract")
  - Purchase Agreement (`synonym_of` = ID of "Contract")
  - Rental Agreement (`synonym_of` = ID of "Contract")

## Usage of Document Types

Document types are used in various scenarios:

1. **Document Classification**: When uploading and processing documents, the appropriate document type is automatically recognized or can be assigned manually.

2. **Document Processing**: Based on the document type, specific processing steps are performed, such as the extraction of certain data fields.

3. **Document Search**: Documents can be filtered by their type to facilitate searching.

4. **Reporting**: Statistics and reports can be grouped by document types.

## Notes

- Document types are tenant-specific
- Query results only include document types accessible to the current tenant. Standardized document types are provided out-of-the-box. Individual document types can be added per tenant as needed.
- The IDs of document types are used for document classification and update operations.
