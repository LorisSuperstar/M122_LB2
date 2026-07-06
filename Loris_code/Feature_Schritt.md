# Auftrag

Jeder Feature-Schritt gleich mit Testdaten (OK/FAIL) testen und in einer Tabelle kurz dokumentieren. (Es soll immer darauf geachtet werden, dass bereits implementierte Features weiterhin korrekt ausgeführt werden, wenn die neu implementierten Features fertiggestellt sind.)

# Lösung zum Auftrag

Ich habe es beim lesen leider übersehen, ich werde dennoch das jetzt am ende des Projektes nachholen.

## Features

1. Als erstes habe ich alle Variablen definert die ich brauchen werde
2. Danach habe ich ein File gemacht indem man "Einstellungen" machen kann.
3. Danach habe ich eine kontrolle gemacht, die überprüft ob der User alle Programme/Dependencies hatt die er braucht.
4. Ich habe die requests an die apis gemacht
5. Ich bekomme die richtige zahl aus den Json text
6. Ich rechne die ergebnisse und schreibe sie in records
7. Ich printe das Resultat ins Terminal aus

| Test  | Feature / Modul        | Testfall-Beschreibung                       | Erwartetes Ergebnis                                            | Testdaten / Input                 |  Status  | Bemerkung                           |
| :---- | :--------------------- | :------------------------------------------ | :------------------------------------------------------------- | :-------------------------------- | :------: | :---------------------------------- |
| **1** | Variablen              | Definition aller benötigten Variablen       | Pfade, Startwerte und Basisdaten sind korrekt gesetzt          | Standard Asset Werte              |  **OK**  | Variablen erfolgreich initialisiert |
| **2** | Konfiguration          | Einstellungs-Datei (`.cfg`) laden           | Optionale Konfiguration überschreibt Standardwerte korrekt     | Vorhandene `portfolio.cfg`        |  **OK**  |                                     |
| **3** | Abhängigkeiten         | Kontrolle der Dependencies                  | Skript bricht mit Fehlermeldung ab, wenn curl/jq/awk fehlen    | Fehlendes `jq` (Simulation)       | **FAIL** | Skript bricht nicht ab              |
| **4** | Abhängigkeiten         | Kontrolle der Dependencies                  | Skript läuft normal durch, wenn alle Programme vorhanden sind  | curl, jq, awk installiert         |  **OK**  |                                     |
| **5** | API-Requests           | Anfragen an Krypto- & Finanz-APIs           | HTTP-Status 200 und gültiger JSON-String als Antwort           | URLs von Coinbase & Yahoo Finance |  **OK**  |                                     |
| **6** | JSON-Parsing           | Richtige Zahl aus JSON extrahieren          | Kurs-Werte werden via `jq` fehlerfrei isoliert                 | Roher JSON-Text der APIs          |  **OK**  |                                     |
| **7** | Berechnung und Records | Ergebnisse rechnen und in Records schreiben | Mathematisch korrekte Werte werden in die CSV exportiert       | Extrahierte Kurse & awk-Logik     |  **OK**  |                                     |
| **8** | Ausgabe                | Resultat ins Terminal printen               | Formatierter Snapshot wird übersichtlich im Terminal angezeigt | Berechnete Endvariablen           |  **OK**  |                                     |
