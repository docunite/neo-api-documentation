# Dokument-Status

Ein Dokument hat während der Verarbeitungsschritte verschiedene Status. Diese sind als Enum implementiert und stellen sich wie folgt dar:

    UNSUPPORTED = -2
    ERROR = -1
    QUEUED = 0
    EXTRACTING = 1
    EXTRACTED = 2
    CLASSIFYING = 3
    CLASSIFIED = 4
    ENRICHING = 5
    ENRICHED = 6
