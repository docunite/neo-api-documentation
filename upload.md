
# Dokumenten-Upload API Dokumentation

## Übersicht

Diese API ermöglicht das Hochladen und Verarbeiten von Dokumenten in unserem Dokumentenmanagementsystem. Nach dem Upload werden die Dokumente automatisch verarbeitet, was die Textextraktion und optional eine Klassifizierung umfasst. Vor dem Upload muss zunächst eine Entität/ein Space erstellt werden, siehe ["Neue Entität erstellen"](https://github.com/docunite/neo-api-documentation/blob/main/entities.md).

## Endpunkt

```
POST /document-management/documents
```

## Authentifizierung

Für alle Anfragen ist ein gültiger API-Schlüssel erforderlich, der im Header übermittelt werden muss.

## Anfrage

Der Endpunkt erwartet eine `multipart/form-data`-Anfrage mit folgenden Parametern:

| Parameter | Typ | Erforderlich | Beschreibung |
|-----------|-----|--------------|--------------|
| file | Datei(en) | Ja | Eine oder mehrere Dateien, die hochgeladen werden sollen. Unterstützte Formate sind PDF, DOCX, JPG, PNG, etc. |
| entity_id | String | Ja | Die ID der Entität, mit der das Dokument verknüpft werden soll (z.B. Kunden-ID, Projekt-ID) |
| classify | Boolean | Nein | Gibt an, ob die Dokumente automatisch klassifiziert werden sollen. Standardwert ist `true` |
| original_path | String | Nein | Optionaler Pfad, der mit dem Dokument gespeichert werden soll (z.B. der ursprüngliche Dateipfad) |

## Beispiel

### cURL Beispiel

```bash
curl -X POST "https://ihre-api-domain.de/document-management/documents" \
  -H "X-API-KEY: <IHR_API_SCHLÜSSEL>" \
  -F "file=@/pfad/zu/ihrer/datei.pdf" \
  -F "entity_id=KUNDE123" \
  -F "classify=true"
```

### Beispiel mit mehreren Dateien

```bash
curl -X POST "https://ihre-api-domain.de/document-management/documents" \
  -H "X-API-KEY: <IHR_API_SCHLÜSSEL>" \
  -F "file=@/pfad/zu/ihrer/datei1.pdf" \
  -F "file=@/pfad/zu/ihrer/datei2.pdf" \
  -F "entity_id=PROJEKT456" \
  -F "classify=true" \
  -F "original_path=/originaler/dateipfad/"
```

## Antwort

### Erfolgreiche Antwort (200 OK)

```json
{
  "message": "Documents uploaded successfully",
  "correlation_id": "8f7d9c2e-1234-5678-90ab-cdef01234567"
}
```

Die `correlation_id` kann verwendet werden, um den Status der Dokumentenverarbeitung über andere API-Endpunkte abzufragen.

### Fehlerantworten

- **400 Bad Request**: Fehlerhafte Anfrage, z.B. wenn keine Dateien hochgeladen wurden
  ```json
  {
    "error": "No files uploaded"
  }
  ```

- **403 Forbidden**: Kein gültiger Tenant bereitgestellt
  ```json
  {
    "error": "No valid tenant provided"
  }
  ```

- **500 Internal Server Error**: Interner Serverfehler bei der Verarbeitung

## Webhook-Benachrichtigungen

Um Benachrichtigungen über den Abschluss der Dokumentenverarbeitung zu erhalten:

1. Registrieren Sie eine Webhook-URL über den `/webhooks`-Endpunkt
2. Ihr registrierter Webhook wird benachrichtigt, wenn die Verarbeitung abgeschlossen ist

## Asynchrone Verarbeitung

Bitte beachten Sie, dass die Dokumentenverarbeitung asynchron erfolgt:

1. Der Upload-Endpunkt gibt sofort eine Antwort mit einer `correlation_id` zurück
2. Die eigentliche Verarbeitung (OCR, Klassifizierung) erfolgt im Hintergrund
3. Der Status und die Ergebnisse können später über andere API-Endpunkte abgefragt werden

## Verarbeitungsschritte

Die hochgeladenen Dokumente durchlaufen folgende Verarbeitungsschritte:

1. **Upload**: Speicherung der Originaldatei
2. **Extraktion**: Umwandlung in Text mittels OCR (Optical Character Recognition)
3. **Klassifizierung** (optional): Automatische Bestimmung des Dokumententyps
4. **Anreicherung**: Extraktion spezifischer Informationen basierend auf dem Dokumententyp

## Hinweise

- Für die Batch-Verarbeitung großer Mengen an Dokumenten empfehlen wir, mehrere kleinere Anfragen zu senden
- Der Parameter `classify=false` kann verwendet werden, um die automatische Klassifizierung zu überspringen, was die Verarbeitung beschleunigt
```
