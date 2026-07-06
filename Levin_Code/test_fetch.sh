#!/bin/bash
# ==============================================================================
# Testskript fuer die Kursdaten-APIs (BTC, USD, NOVN)
# M122 LB2 - Aufgabe D (Verifikation)
# 
# Zweck:  Sicherstellen, dass die APIs erreichbar sind und gueltige Werte liefern.
# Input:  Keine (Daten werden live von Web-APIs bezogen)
# Output: Konsolenausgabe der aktuellen Kurse
# ==============================================================================

# Abschnittskommentar: BTC-CHF Kurs abfragen
# WOZU: Testen der Coinbase API fuer Bitcoin.
sBtcRaw=$(curl -s "https://api.coinbase.com/v2/prices/BTC-CHF/spot")
dBitcoinPrice=$(echo "$sBtcRaw" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['amount'])")

# Abschnittskommentar: USD-CHF Kurs abfragen
# WOZU: Testen der Coinbase API fuer US-Dollar.
sUsdRaw=$(curl -s "https://api.coinbase.com/v2/prices/USD-CHF/spot")
dUsdPrice=$(echo "$sUsdRaw" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['amount'])")

# Abschnittskommentar: NOVN.SW Kurs abfragen
# WOZU: Testen der Yahoo Finance API fuer Novartis Aktien.
sNovnRaw=$(curl -s -H "User-Agent: Mozilla/5.0" "https://query1.finance.yahoo.com/v8/finance/chart/NOVN.SW?interval=1d&range=1d")
dNovartisPrice=$(echo "$sNovnRaw" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    meta = data['chart']['result'][0]['meta']
    # If regularMarketPrice is missing, try chart.result[0].indicators.quote[0].close[-1]
    price = meta.get('regularMarketPrice')
    if price is None:
        price = data['chart']['result'][0]['indicators']['quote'][0]['close'][-1]
    print(price)
except Exception as e:
    print('Error:', e)
")

# Abschnittskommentar: Ausgabe der Testergebnisse
# WOZU: Um visuell zu ueberpruefen, ob die abgerufenen Daten korrekt sind.
echo "BTC/CHF: $dBitcoinPrice"
echo "USD/CHF: $dUsdPrice"
echo "NOVN/CHF: $dNovartisPrice"
