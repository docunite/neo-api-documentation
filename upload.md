
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
| prompt_id | Boolean | Nein | Die ID des Prompts der für die Klassifizierung verwendet werden soll (zu finden im Settings Menü unter Prompts). Wichtig zu beachten ist, dass es sich um einen Prompt vom Aufgaben-Typ "Klassifizierung" handeln muss. Wird keine Prompt-ID angegeben, wird der von NEO vorgegebene Prompt verwendet.|
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

### Python Beispiel

```python
import requests
import os
import json
from pathlib import Path

def upload_documents(api_url, api_key, files_path, entity_id, classify=True, original_path=None):
    """
    Lädt ein oder mehrere Dokumente über die API hoch.
    
    Args:
        api_url (str): Basis-URL der API (z.B. "https://api.example.com/api")
        api_key (str): API-Schlüssel für die Authentifizierung
        files_path (str or list): Pfad zu einer Datei oder Liste von Dateipfaden
        entity_id (str): ID der Entität, mit der die Dokumente verknüpft werden sollen
        classify (bool): Ob die Dokumente klassifiziert werden sollen
        original_path (str, optional): Originalpfad der Dokumente
        
    Returns:
        dict: Die API-Antwort als Dictionary
    """
    # Endpoint-URL
    url = f"{api_url}/document-management/documents"
    
    # Headers mit API-Key für die Authentifizierung
    headers = {
        "X-API-KEY": api_key,
    }
    
    # Formular-Daten
    form_data = {
        "entity_id": entity_id,
        "classify": str(classify).lower(),
    }
    
    if original_path:
        form_data["original_path"] = original_path
    
    # Dateien für den Upload vorbereiten
    if isinstance(files_path, str):
        files_path = [files_path]  # Einzelnen Pfad in Liste umwandeln
    
    files = []
    for file_path in files_path:
        file_name = Path(file_path).name
        files.append(
            ('file', (file_name, open(file_path, 'rb'), 'application/pdf'))
        )
    
    # POST-Anfrage senden
    response = requests.post(
        url=url,
        headers=headers,
        data=form_data,
        files=files
    )
    
    # Dateien schließen
    for _, (_, file_obj, _) in files:
        file_obj.close()
    
    # Antwort verarbeiten
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
    # Konfiguration
    API_URL = "https://your-api-domain.com"  # Passen Sie dies an Ihre API-URL an
    API_KEY = "your-api-key"                     # Ersetzen Sie dies durch Ihren API-Schlüssel
    
    # Beispiel für einen einzelnen Datei-Upload
    document_path = "./example_document.pdf"     # Pfad zu Ihrem Beispieldokument
    entity_id = "<unique id>"                   # Beispiel-Entitäts-ID
    
    print("Beispiel 1: Einzelnes Dokument hochladen")
    upload_documents(
        api_url=API_URL,
        api_key=API_KEY,
        files_path=document_path,
        entity_id=entity_id
    )
    
    # Beispiel für mehrere Dateien
    print("\nBeispiel 2: Mehrere Dokumente hochladen")
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
    
    print("\nBeispiel 3: Dokument ohne Klassifizierung hochladen")
    upload_documents(
        api_url=API_URL,
        api_key=API_KEY,
        files_path="./contract.pdf",
        entity_id="<unique id>",
        classify=False
    )
```

### Javascript Beispiel

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
    console.error("Fehler beim Hochladen:", error);
    return { error: error.message };
  }
}

// Hilfsfunktion zum Lesen von Dateien als Blob (nur in Node.js)
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

// Beispiel-Aufrufe
const API_URL = "https://your-api-domain.com";
const API_KEY = "your-api-key";
const ENTITY_ID = "<unique id>";

// Beispiel 1: Einzelnes Dokument
uploadDocuments(API_URL, API_KEY, "./example_document.pdf", ENTITY_ID);

// Beispiel 2: Mehrere Dokumente
uploadDocuments(API_URL, API_KEY, [
  "./document1.pdf",
  "./document2.pdf",
  "./invoice.pdf"
], "<unique id>", true, "/customer/project-456/documents");

// Beispiel 3: Ohne Klassifizierung
uploadDocuments(API_URL, API_KEY, "./contract.pdf", "<unique id>", false);

```

## Antwort

### Erfolgreiche Antwort (200 OK)

```json
{
  "message": "Documents uploaded successfully",
  "correlation_id": "8f7d9c2e-1234-5678-90ab-cdef01234567"
}
```

Da Dokumente von NEO "entpackt" werden, bspw. Anhänge aus E-Mails, dient die `correlation_id` dazu eine Klammer um diese Dokumente zu bilden. Sie kann verwendet werden, um den Status des hochgeladenen und der daraus entpackten Dokumente über den ```/document-management/documents/batch``` Endpoint abzufragen. 

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
