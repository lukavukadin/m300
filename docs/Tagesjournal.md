# Lernjournal – Modul 300

|                     |                                              |
| ------------------- | -------------------------------------------- |
| **Lernender**       | Luka Vukadin                                 |
| **Modul**           | M300 – Cloudbasierter Service                |
| **Projekttitel**    | Hochverfügbares Gitea auf GCP mit Kubernetes |
| **Projektvariante** | V2 - Eigenes Projekt mit neuen Technologien  |
| **Zeitraum**        | 21.05.2026 – 09.07.2026                      |
| **Cloud-Plattform** | Google Cloud Platform (GCP)                  |
| **Domain**          | git.lukavukadin.ch                           |

----
## 21.05.2026 – Modulteiltag 1: Einstieg & Orientierung

- **Geplante Tagesziele:**
    - Lernumgebung einrichten, Git-Repo erstellen und Idee für Projekt-Variante 2 (V2) definieren.

- **Erreichte Resultate:**
    - Ich habe mein Repository initialisiert, den Link abggeben und mich für das Projekt "Hochverfügbares Gitea in der Cloud" entschieden.
    
- **Aufgetretene Probleme & Reflexion:**
    - Die Abgrenzung von V1 zu V2 war anfangs unklar. Ich habe mich für V2 und Kubernetes entschieden, da eine echte Skalierung mit Docker-Compose in der Cloud zu unprofessionell wäre.
    
- **Eingesetzte Ressourcen:**
    - Modulunterlagen M300, Gitea Cluster-Dokumentation.
    
----
##  28.05.2026 – Modulteiltag 2: Theorie & Konzeptionierung

- **Geplante Tagesziele:**
	- Den Theorie-Input der Lehrperson verstehen.
	- Anforderungen für die Gitea-Architektur recherchieren.
	- [Architektursdiagramm](/diagramme/Architektursdiagramm.md) erstellt

- **Erreichte Resultate:**
    - Ich habe das Kubernetes-Klassenbeispiel analysiert. Ich habe mich theoretisch eingelesen, wie Gitea mit mehreren Frontends umgehen kann. Zusätzlich habe ich ein [Architektursdiagramm](/diagramme/Architektursdiagramm.md) erstellt, damit man sich das Projekt Visuell besser vorstellen kann.

	- [Umsetzung](Umsetzung.md) Schritt 1

- **Aufgetretene Probleme & Reflexion:**
    - Ich habe gemerkt, dass Standard-Cloud-Speicher (ReadWriteOnce) für mein Vorhaben nicht ausreicht. Wenn mehrere Gitea-Pods auf dieselben Daten zugreifen, brauche ich zwingend einen Shared Storage (ReadWriteMany).

- **Eingesetzte Ressourcen:**
    - [K8s Example Repo Kebohn](https://github.com/kebohn/k8s_example), K8s Storage Dokumentation.

----
##  04.06.2026 – Modulteiltag 3: Terraform - Infrastructure as Code

- **Geplante Tagesziele:**
    - Terraform lokal installieren und GCP Provider konfigurieren.
	- Terraform-Code für VPC, Subnetz, GKE-Cluster und Cloud DNS schreiben.
	- GKE-Cluster mit `terraform apply` auf GCP deployen.
	- Zugriff auf Cluster mit kubectl verifizieren (`kubectl get nodes`).

-  **Erreichte Resultate:**
    
    - GCP-Projekt erstellt, APIs aktiviert, Terraform-Files geschrieben (VPC, Subnetz, GKE-Cluster, DNS-Zone, Filestore). Cluster steht, alle 3 Nodes sind `Ready`. 
    
	 - [Umsetzung](Umsetzung.md) Schritte 2-5
    
- **Aufgetretene Probleme & Reflexion:**
    - APIs waren im falschen Projekt aktiviert, dann ein SSD-Quota-Limit gesprengt (gelöst durch zonalen statt regionalen Cluster), und ein Cluster liess sich wegen `deletion_protection` nicht löschen. Zusätzlich blockierte das Schulnetz die Verbindung zu Google – auf dem Hotspot lief's dann sofort.
 
- **Eingesetzte Ressourcen:**
    - Terraform Dokumentation, GCP Console, gcloud CLI, kubectl.

----
##  11.06.2026 – Modulteiltag 4: Ingress, TLS & DNS

- **Geplante Tagesziele:**
    - Nginx Ingress installieren
    - cert-manager mit Let's Encrypt einrichten
    - DNS-Eintrag erstellen.
    
- **Erreichte Resultate:**
    - Nginx Ingress via Helm installiert (mit automatischem Load Balancer + öffentlicher IP), cert-manager + ClusterIssuer für Let's Encrypt eingerichtet, A-Record bei Hostpoint gesetzt.
    
    - [Umsetzung](Umsetzung.md) Schritte 6-8
    
- **Aufgetretene Probleme & Reflexion:**
	- Lief diesmal ohne grössere Probleme durch, da das Netzwerkproblem von letzer Woche schon gelöst war.

- **Eingesetzte Ressourcen:**
	- Helm Dokumentation, cert-manager Dokumentation, Hostpoint DNS-Verwaltung
        
----
## 18.06.2026 – Modulteiltag 5: Storage, PostgreSQL & Gitea Deployment

- **Geplante Tagesziele:**
    - Filestore als Shared Storage einbinden
    - PostgreSQL-Cluster deployen
    - Gitea installieren und über die Domain testen.

- **Erreichte Resultate:**
    - Filestore-CSI-Driver aktiviert, PostgreSQL-Cluster (1 Primary + 2 Replicas) läuft, Gitea erfolgreich deployt. 
    
    - Gitea ist unter `https://git.lukavukadin.ch` erreichbar, mit gültigem HTTPS und funktionierendem Admin-Login. 
    
    - [Umsetzung](Umsetzung.md) Schritte 9-13
    
- **Aufgetretene Probleme & Reflexion:**
	- Das war eindeutig der härteste Teil und hat sich über Tage gezogen. Zuerst hat ein Bug im Filestore-Treiber den Mount blockiert, am Ende half nur das bestehende Filestore-Volume von Hand einzubinden. Kaum war das gelöst, gab es Probleme mit Helm und einem PVC, das sich nicht löschen liess. Zum Schluss hat mich die Domain nochmal ausgebremst, weil ich vergessen hatte, dass Cloudflare meine DNS-Einträge überschreibt.

    
- **Eingesetzte Ressourcen:**
    - CloudNativePG Dokumentation, Gitea Helm Chart, GCP Filestore Dokumentation, Cloudflare DNS-Verwaltung

----
##  25.06.2026 – Hochverfügbarkeit, HPA & Tests

- **Geplante Tagesziele:**
    - Gitea auf 3 Replicas skalieren
    - HPA konfigurieren
    - Failover-Tests (Pod- und DB-Ausfall) durchführen.
    
- **Erreichte Resultate:**
    - Auf 3 Replicas skaliert, beide Failover-Tests erfolgreich (Gitea-Pod und PostgreSQL-Primary), HPA eingerichtet und mit Last getestet.
    
	- [Umsetzung](Umsetzung.md) Schritte 14-16
    
- **Aufgetretene Probleme & Reflexion:**
    - HPA brauchte erst Resource-Requests, um überhaupt zu messen. Bei starker Last kam nicht Gitea, sondern der ganze Cluster an seine Grenze – ein Postgres-Pod wurde kurz unhealthy, erholte sich aber selbst.
    
- **Eingesetzte Ressourcen:**
    - Kubernetes HPA Dokumentation
	- kubectl CLI
	- CloudNativePG Dokumentation
	
----
##  02.07.2026 – Modulteiltag 7: CI/CD Pipeline & Sicherheit

- **Geplante Tagesziele:**
    - Monitoring einrichten und Alerting konfigurieren.
	- GitHub Actions Pipeline für automatisches Deployment einrichten (CI/CD).
    
- **Erreichte Resultate:**
    - Zwei Alert-Richtlinien eingerichtet und getestet (E-Mail kam automatisch). GitHub Actions Workflow erstellt - bei jedem Push deployt er Gitea automatisch auf GKE. Passwörter durch GitHub Secrets ersetzt.
    
	- [Umsetzung](Umsetzung.md) Schritte 17 - 18
    

- **Aufgetretene Probleme & Reflexion:**
    - Service Account Key war durch GCP-Richtlinie verboten - deshalb Workload Identity Federation eingerichtet. Passwörter wurden beim ersten Push versehentlich mitgepusht und sofort wieder entfernt.

- **Eingesetzte Ressourcen:**
    - GCP Monitoring Console
	- GitHub Actions Dokumentation
	- kubectl CLI
    
-----
##  09.07.2026 – Modulteiltag 8: Abgabe & Finalisierung

- **Geplante Tagesziele:**
    - Dokumentation fertigstellen
    - Repo aufräumen
    - Projekt abgeben
    
- **Erreichte Resultate:**
    
    - Technologieentscheid (A1), Testkonzept (B1) und Rollenkonzept (I1) dokumentiert.
    - Lernjournal vollständig ausgefüllt, Abschlussreflexion geschrieben, Projekt abgegeben.
    
- **Aufgetretene Probleme & Reflexion:**
    
    - Keine
        
- **Eingesetzte Ressourcen:**
    
    - Alle bisherigen Ressourcen
    - GitHub Repository (finale Version)