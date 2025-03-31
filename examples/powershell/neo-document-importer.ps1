param (
    [string]$DirectoryPath,  # Das Verzeichnis, aus dem die Dokumente hochgeladen werden
    [string]$ApiUrl, # API-Endpoint
    [string]$ApiKey,  # API-Schlüssel für Authentifizierung
    [string]$EntityId,  # Erforderliche Entity-ID für die API
    [string[]]$FileExtensions = @(".pdf", ".doc", ".docx", ".dotx", ".xls", ".xlsx", ".xlsm", ".ppt", ".pptx", ".ppsx", ".rtf", ".odt", ".msg", "bmp", "eps", "gif", "jpg", "jpeg", "png", "tiff", "tif", "webp"),  # Erlaubte Dateierweiterungen
    [switch]$Resume,  # Flag für Resume-Modus
    [string]$StateFile = "upload_state.json"  # Pfad zur State-Datei
)

$LogFile = "upload_log.txt"

# Funktion zum Berechnen des Pfad-Identifiers
function Get-PathIdentifier {
    param (
        [string]$FilePath
    )
    if ([string]::IsNullOrEmpty($FilePath)) {
        Write-Log "Leerer Dateipfad übergeben" "ERROR"
        return $null
    }
    
    try {
        # Normalisiere den Pfad (entferne doppelte Slashes, normalisiere Separatoren)
        $normalizedPath = [System.IO.Path]::GetFullPath($FilePath)
        
        # Einfachere Hash-Methode verwenden
        return [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($normalizedPath))
    }
    catch {
        Write-Log "Fehler beim Erstellen des Pfad-Identifiers für $FilePath : $_" "ERROR"
        return $null
    }
}

# Funktion zum Laden des Upload-States
function Load-UploadState {
    if (Test-Path $StateFile) {
        try {
            $state = Get-Content $StateFile -ErrorAction Stop | ConvertFrom-Json
            # Konvertiere zu Hashtable für bessere Performance
            $hashtable = @{}
            $state.PSObject.Properties | ForEach-Object {
                $hashtable[$_.Name] = $_.Value
            }
            Write-Log "Upload-State geladen: $($hashtable.Count) Dateien gefunden" "INFO"
            return $hashtable
        }
        catch {
            Write-Log "Fehler beim Laden des Upload-States: $_" "ERROR"
            return @{}
        }
    }
    return @{}
}

# Funktion zum Speichern des Upload-States
function Save-UploadState {
    param (
        [hashtable]$State
    )
    try {
        $State | ConvertTo-Json | Set-Content $StateFile
        Write-Log "Upload-State gespeichert" "INFO"
    }
    catch {
        Write-Log "Fehler beim Speichern des Upload-States: $_" "ERROR"
    }
}

# Funktion für Logging
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    try {
        $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $LogEntry = "[$Timestamp] [$Level] $Message"
        
        # Zum Log-File hinzufügen
        Add-Content -Path $LogFile -Value $LogEntry
        
        # Farbliche Darstellung in der Konsole
        switch ($Level) {
            "SUCCESS" { 
                Write-Host "[$Timestamp] " -NoNewline
                Write-Host "[$Level]" -ForegroundColor Green -NoNewline
                Write-Host " $Message" 
            }
            "INFO" { 
                Write-Host "[$Timestamp] " -NoNewline
                Write-Host "[$Level]" -ForegroundColor Cyan -NoNewline
                Write-Host " $Message" 
            }
            "WARNING" { 
                Write-Host "[$Timestamp] " -NoNewline
                Write-Host "[$Level]" -ForegroundColor Yellow -NoNewline
                Write-Host " $Message" 
            }
            "ERROR" { 
                Write-Host "[$Timestamp] " -NoNewline
                Write-Host "[$Level]" -ForegroundColor Red -NoNewline
                Write-Host " $Message" -ForegroundColor Red
            }
            default { Write-Host $LogEntry }
        }
    } catch {
        Write-Host "Fehler beim Schreiben ins Log: $_" -ForegroundColor Red
    }
}

# Visuelle Trennlinie für bessere Lesbarkeit
function Write-Separator {
    param([string]$Title = "")
    
    $width = 80
    $line = "-" * $width
    
    Write-Host "`n$line" -ForegroundColor DarkGray
    if ($Title) {
        $padding = " " * [Math]::Max(0, [Math]::Floor(($width - $Title.Length) / 2))
        Write-Host "$padding$Title$padding" -ForegroundColor White
        Write-Host "$line`n" -ForegroundColor DarkGray
    }
}

# Zeige Start-Banner
Write-Separator "Dokument Upload Tool"
Write-Log "Starte Dokumenten-Upload-Prozess..." "INFO"

# Prüfen, ob das Verzeichnis existiert
if (!(Test-Path -Path $DirectoryPath -PathType Container)) {
    Write-Log "Das angegebene Verzeichnis existiert nicht." "ERROR"
    exit 1
}

# Lade den Upload-State
$uploadState = Load-UploadState

# Funktion zum Hochladen eines Dokuments
function Upload-Document {
    param (
        [string]$FilePath,
        [string]$RelativePath
    )
    
    if ([string]::IsNullOrEmpty($FilePath)) {
        Write-Log "Leerer Dateipfad übergeben" "ERROR"
        return $false
    }
    
    $FileName = [System.IO.Path]::GetFileName($FilePath)
    $pathIdentifier = Get-PathIdentifier -FilePath $FilePath
    
    if ([string]::IsNullOrEmpty($pathIdentifier)) {
        Write-Log "Konnte keinen gültigen Pfad-Identifier erstellen für: $FilePath" "ERROR"
        return $false
    }
    
    # Prüfe, ob die Datei bereits erfolgreich hochgeladen wurde
    if ($uploadState -and $uploadState.ContainsKey($pathIdentifier)) {
        Write-Log "Datei bereits erfolgreich hochgeladen: $FilePath" "INFO"
        return $true
    }
    
    try {
        Write-Log "Hochladen von: $FilePath" "INFO"
        
        # Boundary für multipart/form-data
        $boundary = [System.Guid]::NewGuid().ToString()
        $ContentType = "multipart/form-data; boundary=$boundary"
        
        # Erstelle den Body für multipart/form-data
        $bodyLines = @()
        
        # Füge entity_id zum Body hinzu
        $bodyLines += "--$boundary"
        $bodyLines += "Content-Disposition: form-data; name=`"entity_id`""
        $bodyLines += ""
        $bodyLines += $EntityId
        
        # Füge classify zum Body hinzu
        $bodyLines += "--$boundary"
        $bodyLines += "Content-Disposition: form-data; name=`"classify`""
        $bodyLines += ""
        $bodyLines += "true"
        
        # Füge original_path zum Body hinzu (wenn vorhanden)
        if ($RelativePath) {
            $bodyLines += "--$boundary"
            $bodyLines += "Content-Disposition: form-data; name=`"original_path`""
            $bodyLines += ""
            $bodyLines += $RelativePath
        }
        
        # Füge Datei zum Body hinzu
        $bodyLines += "--$boundary"
        $bodyLines += "Content-Disposition: form-data; name=`"file`"; filename=`"$FileName`""
        $bodyLines += "Content-Type: application/octet-stream"
        $bodyLines += ""
        
        # Wandle die Zeilen in einen String um und füge Zeilenumbrüche hinzu
        $bodyStart = [System.Text.Encoding]::UTF8.GetBytes(($bodyLines -join "`r`n") + "`r`n")
        
        # Lese die Datei als Byte-Array
        $fileContent = [System.IO.File]::ReadAllBytes($FilePath)
        
        # Abschluss des Bodies
        $bodyEnd = [System.Text.Encoding]::UTF8.GetBytes("`r`n--$boundary--`r`n")
        
        # Erstelle ein MemoryStream-Objekt für die Kombination der Teile
        $requestBody = New-Object System.IO.MemoryStream
        $requestBody.Write($bodyStart, 0, $bodyStart.Length)
        $requestBody.Write($fileContent, 0, $fileContent.Length)
        $requestBody.Write($bodyEnd, 0, $bodyEnd.Length)
        $requestBody.Position = 0
        
        # Sende die Anfrage
        $webRequest = [System.Net.WebRequest]::Create($ApiUrl)
        $webRequest.Method = "POST"
        $webRequest.ContentType = $ContentType
        $webRequest.Headers.Add("X-API-KEY", "$ApiKey")
        $webRequest.ContentLength = $requestBody.Length
        
        # Stream zum Senden der Daten
        Write-Log "Starte Upload von: $FilePath" "INFO"
        $requestStream = $webRequest.GetRequestStream()
        $requestBody.CopyTo($requestStream)
        $requestStream.Close()
        
        # Erhalte die Antwort
        Write-Log "Erhalte Antwort..." "INFO"
        $response = $webRequest.GetResponse()
        $responseStream = $response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($responseStream)
        $responseContent = $reader.ReadToEnd()
        Write-Log "Antwort erhalten: $responseContent" "INFO"
        
        # Speichere den erfolgreichen Upload im State
        if ($null -eq $uploadState) {
            Write-Log "Kein Upload-State vorhanden, erstelle neuen State" "INFO"
            $uploadState = @{}
        }
        $uploadState[$pathIdentifier] = @{
            FilePath = $FilePath
            UploadDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
        Write-Log "Speichere Upload-State" "INFO"
        Save-UploadState -State $uploadState
        Write-Log "Upload-State gespeichert" "INFO"
        
        Write-Log "Erfolgreich hochgeladen: $FilePath" "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Fehler beim Hochladen: $FilePath - $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Alternative Methode zur Verarbeitung langer Pfade mit Get-ChildItem
Write-Log "Scanne Verzeichnis: $DirectoryPath" "INFO"
$ResolvedPath = Resolve-Path -Path $DirectoryPath
$Files = Get-ChildItem -Path $ResolvedPath -Recurse -File | Where-Object { $FileExtensions -contains $_.Extension.ToLower() }

$TotalFiles = $Files.Count
$Counter = 0
$Successful = 0
$Failed = 0
$Skipped = 0

Write-Log "Gefilterte Dateien nach Erweiterungen ($($FileExtensions -join ",")): $TotalFiles" "INFO"

if ($TotalFiles -eq 0) {
    Write-Log "Keine passenden Dateien gefunden!" "WARNING"
} else {
    Write-Separator "Start Upload Prozess"
    
    foreach ($File in $Files) {
        $Counter++
        $FullPath = $File.FullName
        
        if ([string]::IsNullOrEmpty($FullPath)) {
            Write-Log "Ungültiger Dateipfad gefunden, überspringe..." "ERROR"
            $Failed++
            continue
        }
        
        # Extrahiere nur den Verzeichnispfad ohne Dateinamen
        $DirectoryOnly = [System.IO.Path]::GetDirectoryName($FullPath)
        $RelativePath = $DirectoryOnly.Replace($ResolvedPath, '').TrimStart('\')
        
        # Nur relativen Pfad verwenden, wenn es tatsächlich ein Unterverzeichnis gibt
        if ($RelativePath -eq "") {
            $RelativePath = $null
        }
        
        $ProgressPercent = [Math]::Round(($Counter / $TotalFiles) * 100)
        Write-Progress -Activity "Dokumente hochladen" -Status "Datei $Counter von $TotalFiles" -PercentComplete $ProgressPercent
        
        Write-Log "[$Counter/$TotalFiles] Verarbeitung: $FullPath" "INFO"
        
        # Prüfe, ob die Datei bereits erfolgreich hochgeladen wurde
        $pathIdentifier = Get-PathIdentifier -FilePath $FullPath
        if ($pathIdentifier -and $uploadState -and $uploadState.ContainsKey($pathIdentifier)) {
            Write-Log "Datei bereits erfolgreich hochgeladen: $FullPath" "INFO"
            $Skipped++
            continue
        }
        
        $result = Upload-Document -FilePath $FullPath -RelativePath $RelativePath
        
        if ($result) {
            $Successful++
        } else {
            $Failed++
        }
    }
    
    Write-Progress -Activity "Dokumente hochladen" -Completed
}

Write-Separator "Zusammenfassung"
Write-Log "Upload-Prozess abgeschlossen." "INFO"
Write-Log "Ergebnis: $Successful erfolgreich, $Failed fehlgeschlagen, $Skipped übersprungen von insgesamt $TotalFiles Dateien" $(if ($Failed -eq 0) { "SUCCESS" } else { "WARNING" }) 
