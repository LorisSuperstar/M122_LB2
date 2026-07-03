# KI-Dokumentation: Evaluation und Reflexion

**Projekt-Titel:** Portfolio Tracker.  
**Autor:** [Dein Name]  
**Datum:** 3. Juli 2026

---

## 1. Evaluation der KI-Werkzeuge (IDE-integriert)

Für die Entwicklung dieses Bash-Projekts stand die Bedingung im Vordergrund, dass die KI-Werkzeuge **direkt in die lokale Entwicklungsumgebung (z. B. VS Code) eingebunden werden können**, um den Workflow nicht zu unterbrechen. Es wurden zwei für Studierende kostenlose Werkzeuge evaluiert:

1. **GitHub Copilot:** Integrierte Code-Assistenz direkt in der IDE (kostenlos für Studierende über das _GitHub Student Developer Pack_).
2. **Codeium:** Eine KI-Erweiterung für die IDE, die in der Basisversion für Einzelpersonen und Studierende dauerhaft kostenlos ist und eine Alternative zu Copilot darstellt.

### Nutzwertanalyse (Scoring-Modell)

Die Bewertung erfolgt auf einer Skala von 1 (sehr schlecht) bis 5 (ausgezeichnet). Da die Integration in die Umgebung zwingend erforderlich war, ist dieses Kriterium am höchsten gewichtet.

| Kriterium                           | Gewichtung | GitHub Copilot (Score) | GitHub Copilot (Gewichtet) | Codeium (Score) | Codeium (Gewichtet) |
| :---------------------------------- | :--------: | :--------------------: | :------------------------: | :-------------: | :-----------------: |
| **IDE-Integration & UI-Qualität**   |    35%     |           5            |            1.75            |        4        |        1.40         |
| **Code-Vervollständigung (Inline)** |    25%     |           5            |            1.25            |        4        |        1.00         |
| **In-IDE Chat & Debugging**         |    20%     |           4            |            0.80            |        4        |        0.80         |
| **Kosten & barrierefreier Zugang**  |    10%     |           4            |            0.40            |        5        |        0.50         |
| **Kontextverständnis im Projekt**   |    10%     |           5            |            0.50            |        3        |        0.30         |
| **Gesamtergebnis**                  |  **100%**  |                        |          **4.70**          |                 |      **4.00**       |

### Begründung der Werkzeugwahl

Beide Werkzeuge erfüllen die Anforderung, sich nahtlos als Extension in die IDE (VS Code) einzubinden. Die Wahl fiel im Projekt primär auf **GitHub Copilot**.

_Begründung:_ Copilot zeigte im Test ein überlegenes Kontextverständnis. Es "liest" geöffnete Nachbardateien (z. B. eine `styles.css` oder ein JavaScript-Modul) intelligenter mit und macht dadurch passgenauere Vorschläge für den aktuellen Codeabschnitt. **Codeium** wurde als starker, kostenloser Backup-Assistent evaluiert, falls der GitHub-Studierendenstatus abläuft oder die Verbindung zu den GitHub-Servern blockiert ist.

---

## 2. Einsatz der KI im Projekt (Integration in die IDE)

Der größte Vorteil der Integration war, dass kein Wechsel in den Browser (zu ChatGPT o.ä.) notwendig war. Der Einsatz erfolgte direkt im Editor:

1. **Inline-Vervollständigung (Autopilot):** Während des Tippens schlugen beide Werkzeuge grauen "Ghost-Text" vor, der einfach mit der `Tab`-Taste übernommen werden konnte.
2. **In-Editor Chatsidebar:** Über das Seitenmenü der IDE konnten Fragen zu Codeabschnitten gestellt werden, ohne den Code zu verlassen.
3. **Automatische Kommentare & Dokumentation:** Markierter Code wurde von der KI direkt im Editor mit passenden JSDoc-Kommentaren versehen.

---

## 3. Praktische Beispiele aus der Entwicklungsumgebung

### Beispiel 1: Nutzen des In-IDE Chats für Refactoring (GitHub Copilot)

_Ziel: Eine verschachtelte `if-else`-Struktur in modernen, lesbaren JavaScript-Code umwandeln._

- **Vorgehen im Editor:** Code markieren, `Strg + I` (bzw. `Cmd + I`) drücken und den Befehl eingeben.
- **Prompt in der IDE:** `/refactor Optimiere diese Funktion mit einem Clean-Code-Ansatz`
- **Ergebnis direkt im Code-Fenster:** Die KI ersetzte das verschachtelte Konstrukt durch _Early Returns_ (Guard Clauses), was die Lesbarkeit im Projekt massiv verbesserte.

### Beispiel 2: Inline-Generierung von CSS-Klassen (Codeium)

_Ziel: Ein responsives Flexbox-Layout direkt beim Schreiben der CSS-Datei generieren._

- **Eingabe im CSS-File:**
    ```css
    /* Responsive Navigation Bar mit Flexbox, zentrierten Items und Abstand dazwischen */
    .navbar {
    ```
