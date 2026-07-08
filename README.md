# M300 – Hochverfügbares Gitea auf GCP mit Kubernetes
Schulprojekt Modul 300 - Luka Vukadin

---
## Projektübersicht
- **Projektvariante:** V2 - Eigenes Projekt mit neuen Technologien
- **Applikation:** Gitea (selbst-gehosteter Git-Service)
- **Cloud:** Google Cloud Platform (GCP) – Google Kubernetes Engine (GKE)
- **Domain:** https://git.lukavukadin.ch
- **Projekt-Repository (Infrastruktur & Config):** https://github.com/lukavukadin/m300-gitea

---
## Eingesetzte Technologien
- **Terraform** - Infrastruktur als Code (VPC, GKE, DNS, Filestore)
- **Kubernetes** - Container-Orchestrierung (Ingress, TLS, HPA, Failover)
- **CloudNativePG** - PostgreSQL-Cluster (1 Primary + 2 Replicas)
- **GitHub Actions** - CI/CD Pipeline (automatisches Deployment)
- **GCP Monitoring** - Alerting bei Pod-Ausfall
- **Prometheus + Grafana** - Monitoring und Visualisierung

---
## Dokumentation

### [docs/](docs/)
- [Lernjournal](docs/Lernjournal.md) - Wöchentliches Lernjournal (21.05.–09.07.2026)
- [Umsetzung](docs/Umsetzung.md) - Schritt-für-Schritt Ausführung mit Screenshots (21 Schritte)

### [docs/konzepte/)](docs/konzepte/))
- [Technologieentscheid](docs/konzepte/Technologieentscheid.md) - Begründung der gewählten Technologien und Kosten
- [Testkonzept](docs/konzepte/Testkonzept.md) - Durchgeführte Tests (Failover, HPA, Monitoring, CI/CD, Grafana)
- [Rollenkonzept](docs/konzepte/Rollenkonzept.md) - Service Accounts und Berechtigungen (Least Privilege)
- [Projektreflexion](docs/konzepte/Projektreflexion.md) - Abschliessende Reflexion und Selbsteinschätzung

---
### [diagramme/](diagramme/)
- [Architekturdiagramm](diagramme/Architektursdiagramm.md) - Visualisierung der Gesamtarchitektur
- [Prozessdiagramm CI/CD](diagramme/Prozessdiagramm_CICD.md) - Ablauf der GitHub Actions Pipeline

---
### [images/](images/)
Screenshots und Beweise aus der Umsetzung.