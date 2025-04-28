# NEO-API Dokumentation (wip)

## Übersicht

Willkommen zur Dokumentation der NEO-API. Diese API ermöglicht die programmatische Verwaltung von Dokumenten, Entitäten (Spaces) und Dokumenttypen.

Mit dieser API können Sie:

- Dokumente hochladen und verarbeiten
- Entitäten (Spaces) als Container für Dokumente erstellen und verwalten
- Dokumenttypen abfragen und nutzen
- Textextraktion, Klassifizierung und Anreicherung von Dokumenten durchführen
- Dokumenteninhalte abfragen und analysieren
- Eigene Prompts und Schemas für die Klassifizierung und Anreicherung erstellen und verwalten

## Inhaltsverzeichnis

- [Erste Schritte](#erste-schritte)
- [Authentifizierung](#authentifizierung)
- [API-Endpunkte](#api-endpunkte)
- [Fehlerbehandlung](#fehlerbehandlung)
- [Ratenbegrenzung](#ratenbegrenzung)
- [Webhooks](#webhooks)
- [Best Practices](#best-practices)

## Erste Schritte

Um die API nutzen zu können, benötigen Sie:

1. Ein registriertes Konto für NEO
2. Einen gültigen API-Schlüssel, der im Administrationsbereich generiert werden kann
3. Grundkenntnisse über RESTful APIs und HTTP-Anfragen

### Typischer Workflow

Ein typischer Workflow zur Nutzung der API umfasst folgende Schritte:

1. **Entität erstellen**: Erstellen Sie zunächst eine Entität (Space), die als Container für Ihre Dokumente dient.
2. **Dokumente hochladen**: Laden Sie Dokumente hoch und ordnen Sie sie der erstellten Entität zu.
3. **Verarbeitungsstatus überwachen**: Überwachen Sie den Verarbeitungsstatus der hochgeladenen Dokumente.
4. **Dokumenteninhalte abfragen**: Fragen Sie Metadaten, extrahierten Text oder klassifizierte Informationen ab.

## Authentifizierung

Alle API-Anfragen erfordern eine Authentifizierung mittels eines API-Schlüssels, der im HTTP-Header jeder Anfrage mitgesendet werden muss.

```
X-API-KEY:  <IHR_API_SCHLÜSSEL>
```

API-Schlüssel können im Administrationsbereich des Dokumentenmanagementsystems generiert und verwaltet werden. Jeder Schlüssel ist einem bestimmten Mandanten (Tenant) zugeordnet und bestimmt die verfügbaren Berechtigungen.

> **Sicherheitshinweis**: Behandeln Sie Ihren API-Schlüssel wie ein Passwort. Teilen Sie ihn nicht mit Dritten und speichern Sie ihn nicht im Klartext in Ihrem Quellcode.

## API-Endpunkte

Die API ist in mehrere logische Bereiche unterteilt:

### [Entitäten-Management](entities.md)

Endpunkte zur Verwaltung von Entitäten (Spaces), die als Container für Dokumente dienen.

### [Dokumenten-Management](upload.md)

Endpunkte zum Hochladen, Verarbeiten und Abfragen von Dokumenten.


### [Dokumenttypen](document-types.md)

Endpunkte zur Abfrage von Dokumenttypen.

### [Schemas](schemas.md)

Endpunkte zur Verwaltungs von Schemas.

### [Prompts](prompts.md)

Endpunkte zur Verwaltung von Prompts.

## Fehlerbehandlung

Die API verwendet standardmäßige HTTP-Statuscodes, um den Erfolg oder Misserfolg einer Anfrage anzuzeigen:

- **2xx** - Erfolgreiche Anfragen (z.B. 200 OK, 201 Created)
- **4xx** - Clientseitige Fehler (z.B. 400 Bad Request, 401 Unauthorized, 404 Not Found)
- **5xx** - Serverseitige Fehler (z.B. 500 Internal Server Error)

Fehlermeldungen werden im JSON-Format zurückgegeben:

```json
{
  "error": "Beschreibung des Fehlers",
  "details": "Zusätzliche Informationen (optional)"
}
```

### Häufige Fehler

| Status | Beschreibung | Mögliche Ursache |
|--------|--------------|------------------|
| 400    | Bad Request  | Fehlende oder ungültige Parameter |
| 401    | Unauthorized | Ungültiger oder fehlender API-Schlüssel |
| 403    | Forbidden    | Unzureichende Berechtigungen |
| 404    | Not Found    | Ressource nicht gefunden |
| 413    | Payload Too Large | Datei zu groß |
| 429    | Too Many Requests | Ratenbegrenzung überschritten |
| 500    | Internal Server Error | Serverfehler |

## Ratenbegrenzung

Die API unterliegt Ratenbegrenzungen, um eine gleichmäßige Servicequalität für alle Benutzer zu gewährleisten. Die genauen Limits variieren je nach Lizenztyp und werden in den HTTP-Headern jeder Antwort angegeben:

- `X-RateLimit-Limit`: Maximale Anzahl der Anfragen pro Zeitraum
- `X-RateLimit-Remaining`: Verbleibende Anfragen im aktuellen Zeitraum
- `X-RateLimit-Reset`: Zeitpunkt, zu dem das Limit zurückgesetzt wird (Unix-Timestamp)

Bei Überschreitung der Limits wird ein 429 Too Many Requests Status zurückgegeben.

## Webhooks

Für asynchrone Prozesse wie die Dokumentenverarbeitung bietet das System Webhook-Benachrichtigungen:

1. Registrieren Sie einen Webhook-Endpunkt über die API
2. Wählen Sie die Ereignisse aus, für die Sie benachrichtigt werden möchten
3. Erhalten Sie Echtzeit-Updates, wenn die ausgewählten Ereignisse eintreten

Typische Ereignisse für Webhooks:
- Textextraktion abgeschlossen
- Klassifizierung abgeschlossen
- Anreicherung abgeschlossen

## Best Practices

### Allgemeine Empfehlungen

1. **Fehlerbehandlung implementieren**: Fangen Sie Fehlercodes ab und reagieren Sie entsprechend.
2. **Pagination nutzen**: Verwenden Sie bei großen Datenmengen Pagination-Parameter.
3. **Datenvolumen minimieren**: Fordern Sie nur die Daten an, die Sie tatsächlich benötigen.
4. **Caching implementieren**: Speichern Sie häufig abgefragte, statische Daten lokal zwischen.
5. **Backoff-Strategien**: Implementieren Sie exponentielles Backoff bei Wiederholungsversuchen.

### Dokumenten-Upload

1. **Batching**: Teilen Sie große Mengen von Dokumenten in kleinere Batches auf.
2. **Dateitypen prüfen**: Stellen Sie sicher, dass die hochgeladenen Dateien den unterstützten Formaten entsprechen.
3. **Korrelations-IDs**: Speichern Sie die zurückgegebenen Korrelations-IDs, um Verarbeitungsergebnisse zu verfolgen.

### Sicherheit

1. **HTTPS verwenden**: Senden Sie Anfragen nur über HTTPS, niemals über unverschlüsselte HTTP-Verbindungen.
2. **API-Schlüssel sicher speichern**: Speichern Sie API-Schlüssel in Umgebungsvariablen oder sicheren Schlüsselspeichern.
3. **Minimale Berechtigungen**: Verwenden Sie API-Schlüssel mit den geringstmöglichen Berechtigungen.

## Support und Kontakt

Bei Fragen oder Problemen mit der API kontaktieren Sie bitte unseren Support.

---

© 2025 docunite GmbH. Alle Rechte vorbehalten.
