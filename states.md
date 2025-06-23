# Document Status

A document goes through various statuses during the processing steps. These statuses are implemented as an enum and are as follows:

    UNSUPPORTED = -2
    ERROR = -1
    QUEUED = 0
    EXTRACTING = 1
    EXTRACTED = 2
    CLASSIFYING = 3
    CLASSIFIED = 4
    ENRICHING = 5
    ENRICHED = 6
    UNRECOGNIZED = 9
    SPLITTING = 10
    SPLITTED = 11
