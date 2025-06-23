# Entity Management API Documentation

## Overview

This API enables the management of entities (Spaces) in NEO. Entities serve as containers or organizational units for documents and must be created before uploading documents.

> **Important:** Before you can upload documents, at least one entity (Space) must be created. The document upload API requires a valid `entity_id` as a mandatory parameter.

## Authentication

A valid API key is required for all requests, which must be provided in the header.

## Endpoints

### Retrieve All Entities

Retrieves all entities for the current tenant.

```
GET /entity-management/entities
```

#### Request

No additional parameters required. The tenant ID is automatically determined from the authentication context.

#### Example

```bash
curl -X GET "https://your-api-domain.com/entity-management/entities" \
  -H "X-API-KEY: <YOUR_API_KEY>"
```

#### Successful Response (200 OK)

```json
[
  {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "name": "Customer Contracts",
    "description": "Contracts with all customers",
    "created_at": "2024-03-19T10:30:00Z"
  },
  {
    "id": "456e7890-e21d-34f5-a678-426614174001",
    "name": "Invoices",
    "description": "Incoming supplier invoices",
    "created_at": "2024-03-20T09:15:00Z"
  }
]
```

### Create New Entity

Creates a new entity for the current tenant.

```
POST /entity-management/entities
```

#### Request

| Parameter   | Type   | Required | Description                                   |
|-------------|--------|----------|-----------------------------------------------|
| name        | String | Yes      | Name of the entity to be created (max. 255)   |
| description | String | No       | A description of the entity                   |

#### Example

```bash
curl -X POST "https://your-api-domain.com/entity-management/entities" \
  -H "X-API-KEY: <YOUR_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Entity",
    "description": "Description of the new entity"
  }'
```

#### Successful Response (201 Created)

```json
{
  "id": "789e0123-f45g-67h8-b901-426614174002",
  "name": "New Entity",
  "description": "Description of the new entity",
  "created_at": "2024-03-25T14:45:00Z"
}
```

### Retrieve Specific Entity

Retrieves a specific entity by its ID.

```
GET /entity-management/entities/{entity_id}
```

#### Parameters

| Parameter | Type   | Required | Description                              |
|-----------|--------|----------|------------------------------------------|
| entity_id | String | Yes      | The unique ID of the entity to retrieve  |

#### Example

```bash
curl -X GET "https://your-api-domain.com/entity-management/entities/123e4567-e89b-12d3-a456-426614174000" \
  -H "X-API-KEY: <YOUR_API_KEY>"
```

#### Successful Response (200 OK)

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Customer Contracts",
  "description": "Contracts with all customers",
  "created_at": "2024-03-19T10:30:00Z"
}
```

### Update Entity

Updates an existing entity.

```
PUT /entity-management/entities/{entity_id}
```

#### URL Parameters

| Parameter | Type   | Required | Description                               |
|-----------|--------|----------|-------------------------------------------|
| entity_id | String | Yes      | The unique ID of the entity to update     |

#### Body Parameters

| Parameter   | Type   | Required | Description                             |
|-------------|--------|----------|-----------------------------------------|
| name        | String | Yes      | The new name of the entity              |
| description | String | No       | A new description of the entity         |

#### Example

```bash
curl -X PUT "https://your-api-domain.com/entity-management/entities/123e4567-e89b-12d3-a456-426614174000" \
  -H "X-API-KEY: <YOUR_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Entity Name",
    "description": "Updated entity description"
  }'
```

#### Successful Response (200 OK)

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Updated Entity Name",
  "description": "Updated entity description",
  "created_at": "2024-03-19T10:30:00Z",
  "updated_at": "2024-03-26T08:20:00Z"
}
```

### Delete Entity

Deletes an entity and all associated data (including documents).

```
DELETE /entity-management/entities/{entity_id}
```

#### Parameters

| Parameter | Type   | Required | Description                              |
|-----------|--------|----------|------------------------------------------|
| entity_id | String | Yes      | The unique ID of the entity to delete    |

#### Example

```bash
curl -X DELETE "https://your-api-domain.com/entity-management/entities/123e4567-e89b-12d3-a456-426614174000" \
  -H "X-API-KEY: <YOUR_API_KEY>"
```

#### Successful Response (200 OK)

```json
{
  "message": "Entity deleted successfully",
  "deleted_id": "123e4567-e89b-12d3-a456-426614174000"
}
```

## Relationship with Document Upload

Before uploading documents via the document upload API, you must create at least one entity. The entity ID (`entity_id`) is a required parameter for every document upload.

### Workflow Example:

1. **Create Entity**:
   ```bash
   curl -X POST "https://your-api-domain.com/entity-management/entities" \
     -H "X-API-KEY: <YOUR_API_KEY>" \
     -H "Content-Type: application/json" \
     -d '{
       "name": "Project Collaboration XYZ",
       "description": "Documents for Project XYZ"
     }'
   ```

2. **Use the received entity ID for document upload**:
   ```bash
   curl -X POST "https://your-api-domain.com/document-management/documents" \
     -H "X-API-KEY: <YOUR_API_KEY>" \
     -F "file=@/path/to/document.pdf" \
     -F "entity_id=123e4567-e89b-12d3-a456-426614174000" \
     -F "classify=true"
   ```

## Error Responses

- **400 Bad Request**: Invalid request (e.g., invalid parameters)
  ```json
  {
    "error": "Invalid input data"
  }
  ```

- **401 Unauthorized**: Invalid or missing API key
  ```json
  {
    "error": "Unauthorized - Invalid or missing API key"
  }
  ```

- **403 Forbidden**: API key does not have sufficient permissions
  ```json
  {
    "error": "Forbidden - API key does not have sufficient permissions"
  }
  ```

- **404 Not Found**: Entity not found
  ```json
  {
    "error": "Entity not found"
  }
  ```

- **500 Internal Server Error**: Internal server error during processing

## Entity Management Best Practices

1. **Meaningful Organizational Structure**: Create entities that reflect your organizational structure or business processes (e.g., departments, projects, customer groups)

2. **Consistent Naming**: Use a consistent naming scheme for entities to facilitate navigation

3. **Descriptive Information**: Use the description field to provide additional context information about the entity

4. **Regular Cleanup**: Delete entities that are no longer needed to keep your environment organized (note that this will also delete all associated documents)

5. **Entity Hierarchy**: Plan your entity structure carefully, as the system currently does not support direct hierarchies or subfolders within entities

```
