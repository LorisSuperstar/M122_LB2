#!/bin/bash
# ==============================================================================
# Zentrales Automationsscript fuer das Aktuelle Wertschriften-Depot
# M122 LB2 - Aufgabe D
# 
# Zweck:  Automatisierte Abfrage von Kursdaten, Berechnung der Depotwerte 
#         und Protokollierung.
# Input:  depot.cfg (Bestaende und historische Kaufpreise), Parameter (Optionen)
# Output: depot.log (Protokoll), depot_history.csv (Werteverlauf), 
#         data.zip (Rohdaten), info.mail (Benachrichtigung), Terminalausgabe.
# ==============================================================================

# WOZU: Skript-Verzeichnis ermitteln, damit relative Pfade robust funktionieren.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Konstanten Definitionen (GROSS_CONST)
CONFIG_FILE="$SCRIPT_DIR/depot.cfg"
ZIP_FILE="$SCRIPT_DIR/data.zip"
MAIL_FILE="$SCRIPT_DIR/info.mail"

# Variablen fuer dynamische Pfade (s... fuer String gemäss TBZ-Konvention)
sLogFile=""
sHistoryFile=""

# ==============================================================================
# Zweck:  Zeigt das Hilfemenue auf dem Terminal an.
# Input:  Keine
# Output: Text auf Standardausgabe
# ==============================================================================
showHelp() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -c, --config <file>     Path to custom configuration file"
    echo "  -l, --log <file>        Path to custom log file"
    echo "  -s, --history <file>    Path to custom history CSV file"
    echo "  -h, --help              Show this help message"
    exit 0
}

# Abschnittskommentar: Kommandozeilenargumente parsen
# WOZU: Um benutzerdefinierte Pfade fuer Config, Log und History zu uebernehmen.
while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -l|--log)
            sLogFile="$2"
            shift 2
            ;;
        -s|--history)
            sHistoryFile="$2"
            shift 2
            ;;
        -h|--help)
            showHelp
            ;;
        *)
            echo "Unknown option: $1" >&2
            showHelp
            ;;
    esac
done

# Abschnittskommentar: Konfiguration laden
# WOZU: Einlesen der Depot-Bestaende aus der Config-Datei.
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Error: Configuration file not found at $CONFIG_FILE" >&2
    exit 1
fi

# Fallback auf Standardpfade, falls keine ueber Parameter gesetzt wurden
sLogFile="${sLogFile:-$SCRIPT_DIR/depot.log}"
sHistoryFile="${sHistoryFile:-$SCRIPT_DIR/depot_history.csv}"

# ==============================================================================
# Zweck:  Schreibt eine Nachricht mit Zeitstempel in das Logfile.
# Input:  $1: sLevel (Loglevel, z.B. INFO, ERROR)
#         $2: sMessage (Die eigentliche Nachricht)
# Output: Zeile in der Log-Datei
# ==============================================================================
logMessage() {
    local sLevel="$1"
    local sMessage="$2"
    # WOZU: Einfache Protokollierung der Skriptaktivitaeten fuer die Nachverfolgung
    echo "$(date +"%Y-%m-%d %H:%M:%S") [$sLevel] $sMessage" >> "$sLogFile"
}

logMessage "INFO" "Starting Wertschriften-Depot run."

# Abschnittskommentar: Datenabfrage ueber APIs
# WOZU: Die aktuellen Kurse werden von den konfigurierten APIs abgerufen.

logMessage "INFO" "Fetching Bitcoin rate from Coinbase API..."
sBtcRaw=$(curl -s --connect-timeout 10 --max-time 15 "https://api.coinbase.com/v2/prices/BTC-CHF/spot")
if [ $? -ne 0 ] || [ -z "$sBtcRaw" ]; then
    logMessage "ERROR" "Failed to fetch Bitcoin rate."
    echo "Error: Failed to fetch Bitcoin rate." >&2
    exit 1
fi

logMessage "INFO" "Fetching USD rate from Coinbase API..."
sUsdRaw=$(curl -s --connect-timeout 10 --max-time 15 "https://api.coinbase.com/v2/prices/USD-CHF/spot")
if [ $? -ne 0 ] || [ -z "$sUsdRaw" ]; then
    logMessage "ERROR" "Failed to fetch USD rate."
    echo "Error: Failed to fetch USD rate." >&2
    exit 1
fi

logMessage "INFO" "Fetching Novartis rate from Yahoo Finance..."
sNovnRaw=$(curl -s -H "User-Agent: Mozilla/5.0" --connect-timeout 10 --max-time 15 "https://query1.finance.yahoo.com/v8/finance/chart/NOVN.SW?interval=1d&range=1d")
if [ $? -ne 0 ] || [ -z "$sNovnRaw" ]; then
    logMessage "ERROR" "Failed to fetch Novartis rate."
    echo "Error: Failed to fetch Novartis rate." >&2
    exit 1
fi

# Abschnittskommentar: Archivierung der Rohdaten
# WOZU: Um die JSON-Responses bei Fehlern analysieren zu koennen.
sTempDir=$(mktemp -d)
echo "$sBtcRaw" > "$sTempDir/btc.raw"
echo "$sUsdRaw" > "$sTempDir/usd.raw"
echo "$sNovnRaw" > "$sTempDir/novn.raw"
python3 -c "import zipfile; z = zipfile.ZipFile('$ZIP_FILE', 'w'); z.write('$sTempDir/btc.raw', 'btc.raw'); z.write('$sTempDir/usd.raw', 'usd.raw'); z.write('$sTempDir/novn.raw', 'novn.raw'); z.close()"
rm -rf "$sTempDir"
logMessage "INFO" "Raw data zipped to $ZIP_FILE"

# Variablen an Umgebung uebergeben fuer Python-Skript
export sBtcRaw sUsdRaw sNovnRaw
export STOCK_QTY STOCK_HIST_CHF USD_QTY USD_HIST_CHF BTC_QTY BTC_HIST_CHF

# Abschnittskommentar: Berechnungen mittels Python
# WOZU: Python kann JSON einfach verarbeiten und rechnet mit Fliesskommazahlen genauer.
sCalcResults=$(python3 -c "
import os, sys, json
try:
    btcData = json.loads(os.environ['sBtcRaw'])
    usdData = json.loads(os.environ['sUsdRaw'])
    novnData = json.loads(os.environ['sNovnRaw'])

    dBitcoinPrice = float(btcData['data']['amount'])
    dUsdPrice = float(usdData['data']['amount'])

    novnMeta = novnData['chart']['result'][0]['meta']
    dNovartisPrice = novnMeta.get('regularMarketPrice')
    if dNovartisPrice is None:
        dNovartisPrice = novnData['chart']['result'][0]['indicators']['quote'][0]['close'][-1]
    dNovartisPrice = float(dNovartisPrice)

    dStockQuantity = float(os.environ['STOCK_QTY'])
    dUsdQuantity = float(os.environ['USD_QTY'])
    dBitcoinQuantity = float(os.environ['BTC_QTY'])

    dStockHistorical = float(os.environ['STOCK_HIST_CHF'])
    dUsdHistorical = float(os.environ['USD_HIST_CHF'])
    dBitcoinHistorical = float(os.environ['BTC_HIST_CHF'])

    dStockValue = dStockQuantity * dNovartisPrice
    dUsdValue = dUsdQuantity * dUsdPrice
    dBitcoinValue = dBitcoinQuantity * dBitcoinPrice

    dCurrentTotal = dStockValue + dUsdValue + dBitcoinValue
    dHistoricalTotal = dStockHistorical + dUsdHistorical + dBitcoinHistorical
    dProfitLoss = dCurrentTotal - dHistoricalTotal
    dPercentChange = (dProfitLoss / dHistoricalTotal) * 100 if dHistoricalTotal != 0 else 0.0

    print(f'{dBitcoinPrice:.2f} {dUsdPrice:.4f} {dNovartisPrice:.2f} {dStockValue:.2f} {dUsdValue:.2f} {dBitcoinValue:.2f} {dCurrentTotal:.2f} {dHistoricalTotal:.2f} {dProfitLoss:.2f} {dPercentChange:.2f}')
except Exception as e:
    print('ERROR:', e, file=sys.stderr)
    sys.exit(1)
" 2>>"$sLogFile")

if [ $? -ne 0 ] || [ -z "$sCalcResults" ]; then
    logMessage "ERROR" "Failed to parse API data or run calculations."
    echo "Error: Calculation failed. See $sLogFile for details." >&2
    exit 1
fi

# Werte aus Python-Ausgabe in Bash-Variablen uebernehmen
read -r dBitcoinPrice dUsdPrice dNovartisPrice dStockValue dUsdValue dBitcoinValue dCurrentTotal dHistoricalTotal dProfitLoss dPercentChange <<< "$sCalcResults"

logMessage "INFO" "Calculation successful. Total: $dCurrentTotal CHF, Profit: $dProfitLoss CHF ($dPercentChange%)"

# Abschnittskommentar: Historie speichern (CSV)
# WOZU: Langfristige Aufzeichnung der Portfolio-Entwicklung.
if [ ! -f "$sHistoryFile" ]; then
    echo "Date,Time,BTC_Price_CHF,USD_Price_CHF,NOVN_Price_CHF,STOCK_Val_CHF,USD_Val_CHF,BTC_Val_CHF,Total_Current_Val_CHF,Total_Hist_Val_CHF,Profit_Loss_CHF,Pct_Change" > "$sHistoryFile"
fi
sDateString=$(date +"%Y-%m-%d")
sTimeString=$(date +"%H:%M:%S")
echo "$sDateString,$sTimeString,$dBitcoinPrice,$dUsdPrice,$dNovartisPrice,$dStockValue,$dUsdValue,$dBitcoinValue,$dCurrentTotal,$dHistoricalTotal,$dProfitLoss,$dPercentChange" >> "$sHistoryFile"

# Vorzeichen ermitteln
if [[ "$dProfitLoss" == -* ]]; then
    sSign=""
else
    sSign="+"
fi

# Abschnittskommentar: Admin-Benachrichtigung generieren
# WOZU: Eine simulierte Mail wird geschrieben, um den Status extern zu kommunizieren.
cat <<EOF > "$MAIL_FILE"
To: admin@company.com
Subject: Depot Status Update ($sDateString $sTimeString)

Depot Status Report:
- Current Value: $dCurrentTotal CHF
- Historical Cost: $dHistoricalTotal CHF
- Net Performance: $sSign$dProfitLoss CHF ($sSign$dPercentChange%)

Breakdown:
- Novartis Stock (10 Shares): $dStockValue CHF (Price: $dNovartisPrice CHF)
- USD Cash (3000 USD): $dUsdValue CHF (Price: $dUsdPrice CHF)
- Bitcoin (0.1 BTC): $dBitcoinValue CHF (Price: $dBitcoinPrice CHF)

Log file and CSV history updated.
EOF
logMessage "INFO" "Mock email updated in $MAIL_FILE"

# Abschnittskommentar: Terminal Zusammenfassung
# WOZU: Dem Benutzer beim manuellen Ausfuehren einen schoenen Ueberblick geben.
echo "=================================================="
echo "WERT-DEPOT TRACKER SUMMARY ($sDateString $sTimeString)"
echo "=================================================="
printf "%-15s | %-9s | %-13s | %-12s\n" "Asset Class" "Qty" "Price (CHF)" "Value (CHF)"
echo "----------------+-----------+---------------+------------"
printf "%-15s | %-9g | %-13.2f | %-12.2f\n" "Novartis Stock" "$STOCK_QTY" "$dNovartisPrice" "$dStockValue"
printf "%-15s | %-9g | %-13.4f | %-12.2f\n" "USD Cash" "$USD_QTY" "$dUsdPrice" "$dUsdValue"
printf "%-15s | %-9g | %-13.2f | %-12.2f\n" "Bitcoin Crypto" "$BTC_QTY" "$dBitcoinPrice" "$dBitcoinValue"
echo "----------------+-----------+---------------+------------"
printf "Current Portfolio Value:  %12.2f CHF\n" "$dCurrentTotal"
printf "Historical Purchase Cost: %12.2f CHF\n" "$dHistoricalTotal"
printf "Net Profit/Loss:         %12.2f CHF (%s%.2f%%)\n" "$dProfitLoss" "$sSign" "$dPercentChange"
echo "=================================================="
