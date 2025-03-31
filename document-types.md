# Dokumententyp-API Dokumentation

## Übersicht

Diese API ermöglicht den Zugriff auf Dokumententypen in NEO. Dokumententypen definieren die verschiedenen Arten von Dokumenten, die im System verarbeitet werden können, und steuern die spezifische Verarbeitung und Kategorisierung von Dokumenten.

## Authentifizierung

Für alle Anfragen ist ein gültiger API-Schlüssel erforderlich, der im Header übermittelt werden muss.

## Endpunkte

### Alle Dokumententypen abrufen

Ruft alle verfügbaren Dokumententypen für den aktuellen Mandanten (Tenant) ab.

```
GET /document-type-management/document-types
```

#### Anfrage

Keine zusätzlichen Parameter erforderlich. Die Tenant-ID wird automatisch aus dem Authentifizierungskontext ermittelt.

#### Beispiel

```bash
curl -X GET "https://ihre-api-domain.de/document-type-management/document-types" \
  -H "Authorization: Bearer IHR_API_SCHLÜSSEL"
```

#### Erfolgreiche Antwort (200 OK)

```json
[
  {
    "id": "1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p",
    "name_de": "Rechnung",
    "name_en": "Invoice",
    "description": "",
    "synonym_of": ""
    "has_enrichment_prompt": false
    "created": "2023-04-15T14:30:00Z",
    "modified": "2023-04-15T14:30:00Z"
  },
  {
    "id": "2b3c4d5e-6f7g-8h9i-0j1k-2l3m4n5o6p7q",
    "name_de": "Mietvertrag",
    "name_de": "Contract",
    "description": "",
    "synonym_of": "060cb344-fa93-4d4c-a194-3f9ea11d034e"
    "has_enrichment_prompt": true
    "created": "2023-04-10T09:15:00Z",
    "modified": "2023-04-12T11:20:00Z"
  }
]
```

### Spezifischen Dokumententyp abrufen

Ruft einen einzelnen Dokumententyp anhand seiner ID ab.

```
GET /document-type-management/document-types/{document_type_id}
```

#### Parameter

| Parameter | Typ | Erforderlich | Beschreibung |
|-----------|-----|--------------|--------------|
| document_type_id | String | Ja | Die eindeutige ID des abzurufenden Dokumententyps |

#### Beispiel

```bash
curl -X GET "https://ihre-api-domain.de/document-type-management/document-types/1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p" \
  -H "Authorization: Bearer IHR_API_SCHLÜSSEL"
```

#### Erfolgreiche Antwort (200 OK)

```json
{
  "id": "1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p",
  "name": "Rechnung",
  "description": "Eingangsrechnungen von Lieferanten",
  "synonym_of": "060cb344-fa93-4d4c-a194-3f9ea11d034e"
  "created": "2023-04-15T14:30:00Z",
  "modified": "2023-04-15T14:30:00Z"
}
```

## Fehlerantworten

- **403 Forbidden**: Kein gültiger Tenant bereitgestellt
  ```json
  {
    "error": "No valid tenant provided"
  }
  ```

- **404 Not Found**: Dokumententyp nicht gefunden (nur bei Abfrage eines spezifischen Dokumententyps)
  ```json
  {
    "error": "Document type 1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p not found"
  }
  ```

- **500 Internal Server Error**: Interner Serverfehler bei der Verarbeitung

# Dokumenttyp-Hierarchie: Entwicklerleitfaden

## Überblick

In NEO können Dokumenttypen hierarchisch organisiert werden, wobei ein Dokumenttyp ein Synonym (oder Untertyp) eines anderen sein kann. Diese Beziehung wird über das Attribut `synonym_of` abgebildet. Dieser Leitfaden erklärt, wie Entwickler den vollständigen hierarchischen Pfad eines Dokumenttyps ermitteln können.

## Das Attribut `synonym_of`

Das Feld `synonym_of` in einem Dokumenttyp enthält die ID des übergeordneten Dokumenttyps. Wenn `synonym_of` null oder leer ist, handelt es sich um einen Dokumenttyp der obersten Ebene. Diese Struktur ermöglicht eine Baumdarstellung von Dokumenttypen.

Beispiel für eine Hierarchie:
- Vertrag (oberste Ebene, `synonym_of` = null)
  - Arbeitsvertrag (`synonym_of` = ID von "Vertrag")
    - Befristeter Arbeitsvertrag (`synonym_of` = ID von "Arbeitsvertrag")
  - Kaufvertrag (`synonym_of` = ID von "Vertrag")
  - Mietvertrag (`synonym_of` = ID von "Vertrag")

## Verwendung von Dokumententypen

Dokumententypen werden in verschiedenen Szenarien verwendet:

1. **Dokumentenklassifizierung**: Beim Hochladen und Verarbeiten von Dokumenten wird der passende Dokumententyp automatisch erkannt oder kann manuell zugewiesen werden.

2. **Dokumentenverarbeitung**: Basierend auf dem Dokumententyp werden spezifische Verarbeitungsschritte durchgeführt, wie die Extraktion bestimmter Datenfelder.

3. **Dokumentensuche**: Dokumente können nach ihrem Typ gefiltert werden, um die Suche zu erleichtern.

4. **Berichterstellung**: Statistiken und Berichte können nach Dokumententypen gruppiert werden.

## Hinweise
- Die Dokumententypen sind mandantenspezifisch (tenant-specific)
- Die Abfrageergebnisse enthalten nur Dokumententypen, auf die der aktuelle Mandant Zugriff hat
- Die IDs der Dokumententypen werden bei der Dokumentenklassifizierung und -aktualisierung verwendet
