# Testprotokoll - M122 LB2 (Wertschriften-Depot)

In diesem Dokument werden die einzelnen Features anhand von Testdaten geprüft und dokumentiert. Gemäss der Aufgabenstellung wurde darauf geachtet, dass bereits implementierte Features weiterhin korrekt ausgeführt werden, wenn die neu implementierten Features fertiggestellt sind.

| Feature / Schritt | Testdaten / Beschreibung | Erwartetes Ergebnis | Resultat |
| :--- | :--- | :--- | :--- |
| **1. Konfiguration laden** | `depot.cfg` anpassen (z.B. `STOCK_QTY=10`) | Werte werden fehlerfrei in die Konstanten/Variablen übernommen. | OK |
| **2. API Abfrage: BTC** | Aufruf der Coinbase API via `test_fetch.sh` | Gültiger Fliesskommawert in CHF (z.B. `60000.00`). | OK |
| **3. API Abfrage: USD** | Aufruf der Coinbase API via `test_fetch.sh` | Gültiger Fliesskommawert in CHF (z.B. `0.90`). | OK |
| **4. API Abfrage: NOVN** | Aufruf Yahoo Finance via `test_fetch.sh` | Gültiger Fliesskommawert in CHF (z.B. `85.50`). | OK |
| **5. Rohdaten archivieren** | Prüfen der Datei `data.zip` nach Ausführung | `data.zip` enthält die korrekten Raw-JSON-Dateien: `btc.raw`, `usd.raw`, `novn.raw`. | OK |
| **6. Werte berechnen** | Manuelle Nachrechnung anhand Terminal-Output | Berechnete Summen (Bestand * Kurs) stimmen exakt mit dem Portfolio-Total überein. | OK |
| **7. Historie speichern** | Ausführen von `automate.sh` und `depot_history.csv` prüfen | Neue CSV-Zeile mit Datum, Zeit, Einzelkursen und Gesamt-Werten wird korrekt angehängt. | OK |
| **8. Email generieren** | Datei `info.mail` überprüfen | Korrekter Mail-Aufbau, die Totalwerte & der Profit/Loss stimmen überein. | OK |
