# Entity-Management API Dokumentation

## Übersicht

Diese API ermöglicht die Verwaltung von Entitäten (Spaces) in NEO. Entitäten fungieren als Container oder Organisationseinheiten für Dokumente und müssen vor dem Hochladen von Dokumenten erstellt werden.

> **Wichtig:** Bevor Sie Dokumente hochladen können, muss mindestens eine Entität (Space) erstellt werden. Die Dokument-Upload-API erfordert eine gültige `entity_id` als Pflichtparameter.

## Authentifizierung

Für alle Anfragen ist ein gültiger API-Schlüssel erforderlich, der im Header übermittelt werden muss.

## Endpunkte

### Alle Entitäten abrufen

Ruft alle Entitäten für den aktuellen Mandanten (Tenant) ab.

```
GET /entity-management/entities
```

#### Anfrage

Keine zusätzlichen Parameter erforderlich. Die Tenant-ID wird automatisch aus dem Authentifizierungskontext ermittelt.

#### Beispiel

```bash
curl -X GET "https://ihre-api-domain.de/entity-management/entities" \
  -H "Authorization: Bearer IHR_API_SCHLÜSSEL"
```

#### Erfolgreiche Antwort (200 OK)

```json
[
  {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "name": "Kundenverträge",
    "description": "Verträge mit allen Kunden",
    "created_at": "2024-03-19T10:30:00Z"
  },
  {
    "id": "456e7890-e21d-34f5-a678-426614174001",
    "name": "Rechnungen",
    "description": "Eingehende Lieferantenrechnungen",
    "created_at": "2024-03-20T09:15:00Z"
  }
]
```

### Neue Entität erstellen

Erstellt eine neue Entität für den aktuellen Mandanten.

```
POST /entity-management/entities
```

#### Anfrage

| Parameter | Typ | Erforderlich | Beschreibung |
|-----------|-----|--------------|--------------|
| name | String | Ja | Der Name der zu erstellenden Entität (max. Länge: 255) |
| description | String | Nein | Eine Beschreibung der Entität |

#### Beispiel

```bash
curl -X POST "https://ihre-api-domain.de/entity-management/entities" \
  -H "Authorization: Bearer IHR_API_SCHLÜSSEL" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Neue Entität",
    "description": "Beschreibung der neuen Entität"
  }'
```

#### Erfolgreiche Antwort (201 Created)

```json
{
  "id": "789e0123-f45g-67h8-b901-426614174002",
  "name": "Neue Entität",
  "description": "Beschreibung der neuen Entität",
  "created_at": "2024-03-25T14:45:00Z"
}
```

### Spezifische Entität abrufen

Ruft eine spezifische Entität anhand ihrer ID ab.

```
GET /entity-management/entities/{entity_id}
```

#### Parameter

| Parameter | Typ | Erforderlich | Beschreibung |
|-----------|-----|--------------|--------------|
| entity_id | String | Ja | Die eindeutige ID der abzurufenden Entität |

#### Beispiel

```bash
curl -X GET "https://ihre-api-domain.de/entity-management/entities/123e4567-e89b-12d3-a456-426614174000" \
  -H "Authorization: Bearer IHR_API_SCHLÜSSEL"
```

#### Erfolgreiche Antwort (200 OK)

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Kundenverträge",
  "description": "Verträge mit allen Kunden",
  "created_at": "2024-03-19T10:30:00Z"
}
```

### Entität aktualisieren

Aktualisiert eine bestehende Entität.

```
PUT /entity-management/entities/{entity_id}
```

#### Parameter URL

| Parameter | Typ | Erforderlich | Beschreibung |
|-----------|-----|--------------|--------------|
| entity_id | String | Ja | Die eindeutige ID der zu aktualisierenden Entität |

#### Parameter Body

| Parameter | Typ | Erforderlich | Beschreibung |
|-----------|-----|--------------|--------------|
| name | String | Ja | Der neue Name der Entität |
| description | String | Nein | Eine neue Beschreibung der Entität |

#### Beispiel

```bash
curl -X PUT "https://ihre-api-domain.de/entity-management/entities/123e4567-e89b-12d3-a456-426614174000" \
  -H "Authorization: Bearer IHR_API_SCHLÜSSEL" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Aktualisierter Entitätsname",
    "description": "Aktualisierte Entitätsbeschreibung"
  }'
```

#### Erfolgreiche Antwort (200 OK)

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Aktualisierter Entitätsname",
  "description": "Aktualisierte Entitätsbeschreibung",
  "created_at": "2024-03-19T10:30:00Z",
  "updated_at": "2024-03-26T08:20:00Z"
}
```

### Entität löschen

Löscht eine Entität und alle zugehörigen Daten (einschließlich Dokumente).

```
DELETE /entity-management/entities/{entity_id}
```

#### Parameter

| Parameter | Typ | Erforderlich | Beschreibung |
|-----------|-----|--------------|--------------|
| entity_id | String | Ja | Die eindeutige ID der zu löschenden Entität |

#### Beispiel

```bash
curl -X DELETE "https://ihre-api-domain.de/entity-management/entities/123e4567-e89b-12d3-a456-426614174000" \
  -H "Authorization: Bearer IHR_API_SCHLÜSSEL"
```

#### Erfolgreiche Antwort (200 OK)

```json
{
  "message": "Entity deleted successfully",
  "deleted_id": "123e4567-e89b-12d3-a456-426614174000"
}
```

## Zusammenhang mit Dokumenten-Upload

Bevor Sie Dokumente über die Dokument-Upload-API hochladen können, müssen Sie mindestens eine Entität erstellen. Die Entitäts-ID (`entity_id`) wird bei jedem Dokument-Upload als Pflichtparameter benötigt, um die Zuordnung zwischen Dokumenten und Entitäten herzustellen.

### Workflow-Beispiel:

1. **Entität erstellen**:
   ```bash
   curl -X POST "https://ihre-api-domain.de/entity-management/entities" \
     -H "Authorization: Bearer IHR_API_SCHLÜSSEL" \
     -H "Content-Type: application/json" \
     -d '{
       "name": "Projektzusammenarbeit XYZ",
       "description": "Dokumente für Projekt XYZ"
     }'
   ```

2. **Die erhaltene Entitäts-ID für den Dokument-Upload verwenden**:
   ```bash
   curl -X POST "https://ihre-api-domain.de/document-management/documents" \
     -H "Authorization: Bearer IHR_API_SCHLÜSSEL" \
     -F "file=@/pfad/zu/dokument.pdf" \
     -F "entity_id=123e4567-e89b-12d3-a456-426614174000" \
     -F "classify=true"
   ```

## Fehlerantworten

- **400 Bad Request**: Fehlerhafte Anfrage (z.B. ungültige Parameter)
  ```json
  {
    "error": "Invalid input data"
  }
  ```

- **401 Unauthorized**: Ungültiger oder fehlender API-Schlüssel
  ```json
  {
    "error": "Unauthorized - Invalid or missing API key"
  }
  ```

- **403 Forbidden**: API-Schlüssel hat keine ausreichenden Berechtigungen
  ```json
  {
    "error": "Forbidden - API key does not have sufficient permissions"
  }
  ```

- **404 Not Found**: Entität nicht gefunden
  ```json
  {
    "error": "Entity not found"
  }
  ```

- **500 Internal Server Error**: Interner Serverfehler bei der Verarbeitung

## Entitäts-Verwaltung Best Practices

1. **Sinnvolle Organisationsstruktur**: Erstellen Sie Entitäten, die Ihrer Organisationsstruktur oder Ihren Geschäftsprozessen entsprechen (z.B. Abteilungen, Projekte, Kundengruppen)

2. **Konsistente Benennung**: Verwenden Sie ein konsistentes Benennungsschema für Entitäten, um die Navigation zu erleichtern

3. **Beschreibende Informationen**: Nutzen Sie das Beschreibungsfeld, um zusätzliche Kontextinformationen zur Entität zu bieten

4. **Regelmäßige Bereinigung**: Löschen Sie nicht mehr benötigte Entitäten, um Ihre Umgebung übersichtlich zu halten (beachten Sie, dass dabei auch alle zugehörigen Dokumente gelöscht werden)

5. **Entitäts-Hierarchie**: Planen Sie Ihre Entitätsstruktur sorgfältig, da das System derzeit keine direkten Hierarchien oder Unterordner innerhalb von Entitäten unterstützt
