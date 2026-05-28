# Cloudbasierter KI-Fitness-Coach (Modul 300 - V2)

## 1. Projektübersicht und Kernidee

Das Ziel meines Projekts ist die Entwicklung einer intelligenten, cloudbasierten Web-Applikation, die als mein persönlicher Fitness- und Gesundheitscoach fungiert. Das System führt die historischen und täglichen Vitaldaten meiner beiden Wearables (**Whoop-Band** und **Apple Watch**) in einer zentralen Datenbank zusammen. Eine KI (**OpenAI GPT-4o**) analysiert diese Daten anschliessend autonom und erstellt dynamische, tagesaktuelle Trainings-, Ernährungs- und Erholungspläne, die perfekt auf mein definiertes sportliches Ziel abgestimmt sind (z. B. einen Halbmarathon am 21.10.2026).

Um einen **Vendor Lock-in** zu vermeiden und die Kriterien für die Variante 2 (V2) des Moduls 300 optimal zu erfüllen, setze ich auf eine **cloud-agnostische Container-Architektur**. Das gesamte System wird so gebaut, dass es via Docker überall identisch läuft – sei es lokal auf meinem Entwicklungsrechner, auf AWS, Azure oder auf einem privaten Server.

---
## 2. Funktionsweise & Logik

Mein System basiert auf einem dreiteiligen, geschlossenen Kreislauf, bei dem der Trainingsplan aktiv "lebt" und sich täglich an meinen Körper anpasst:
### 1. Datenerfassung (Ist-Zustand)
* **Apple Watch:** Trackt meine absolvierten Trainingseinheiten (Pace, Puls, Distanz, Route) und sendet sie via Webhook (z. B. über die App *Health Auto Export*) an mein Backend.
* **Whoop-Band:** Liefert jeden Morgen meine Regenerationswerte (Schlafqualität, Erholung in %, körperliche Belastung) direkt über die Whoop-Cloud-API.
### 2. KI-Analyse & Personalisierung (Der Coach)
* Die KI kennt mein Hauptziel und meine Rahmenbedingungen (z. B. 3x Training pro Woche).
* Sie prüft jeden Morgen meine aktuellen Whoop-Werte. Ist meine Erholung im Keller (z. B. nur 20%), passt die KI den Plan für diesen Tag automatisch an (z. B. aktiver Ruhetag statt Intervalltraining, Fokus auf Hydration und Schlaf).
### 3. Das Interface (Meine Ansicht)
* In einer Web-App sehe ich in einer Kalenderansicht genau, was mein Coach heute für mich vorgesehen hat.
* Über ein integriertes Chat-Fenster kann ich dem Coach jederzeit direkt Fragen stellen ("Ich fühle mich müde, was soll ich essen?") oder den Plan per Sprache/Text anpassen.

---

## 3. Technische Umsetzung (Modul 300 Kriterien)

Für die Erfüllung der V2-Anforderungen und das Erreichen einer Bestnote setze ich folgende Technologien und Konzepte ein:

* **Infrastruktur als Code (IaC):** Die Bereitstellung der Server-Infrastruktur (z. B. virtuelle Maschinen, Netzwerk/Security Groups) wird mit **Terraform** komplett automatisiert.
* **Cloud-Agnostisch & Containerisierung (Docker):** Die gesamte Applikation wird in Docker-Container verpackt. Dadurch bin ich zu 100% unabhängig vom Cloud-Anbieter und kann die App ohne Code-Änderungen von AWS zu Azure oder lokal verschieben.
* **Datenbank:** Eine containerisierte **PostgreSQL-Datenbank** speichert alle Fitnessdaten, User-Profile und die generierten Pläne.
* **Backend:** Ein in **Python** geschriebener API-Service (FastAPI) übernimmt die Datenverarbeitung, die Kommunikation mit der Whoop-/OpenAI-API und die Logik.
* **Frontend:** Das Dashboard wird mit **Streamlit (Python)** gebaut, um schnell eine reaktive Oberfläche zu realisieren.
* **Sicherheitskonzept & Zugriffsschutz:** * **Authentifizierung:** Das Dashboard wird über eine Login-Maske (`streamlit-authenticator`) geschützt, sodass nur ich Zugriff auf meine sensiblen Gesundheitsdaten habe.
    * **Secret Management:** API-Keys (OpenAI, Whoop) werden über Umgebungsvariablen (`.env` oder Cloud-eigene Key-Stores) verschlüsselt injiziert und niemals im Code committet.
    * **Lokales Testing:** Für die Entwicklung und das Abfangen der Apple-Watch-Webhooks auf meinem lokalen PC setze ich einen sicheren **ngrok-Tunnel** ein.
* **CI/CD Pipeline:** Über **GitLab CI/CD** wird bei jedem Push ein automatisierter Prozess gestartet, der den Code prüft und die Container via Rolling Update auf die Ziel-Infrastruktur ausgrollt.

---
## 4. Struktur der Benutzeroberfläche (Streamlit-Tabs)

* **Tab 1: Dashboard:** Visuelle Übersicht meiner aktuellen Whoop- und Apple-Watch-Trends (Schlaf, Durchschnittspuls etc.) mit Grafana-ähnlichen Charts.
* **Tab 2: KI-Chat:** Mein direkter Draht zum Coach für Fragen, Anpassungen und spontanes Feedback.
* **Tab 3: Mein Kalender:** Die dynamische Agenda, die mir übersichtlich anzeigt, welche Trainings, Mahlzeiten und Trinkmengen für die aktuelle Woche anstehen.