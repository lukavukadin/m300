# Technologieentscheid


### Warum Google Cloud?

Kubernetes wurde ursprünglich von Google entwickelt und als Open-Source veröffentlicht. Da ich mich zum ersten Mal wirklich tief mit Kubernetes auseinandergesetzt habe, war es für mich logisch, das direkt beim Erfinder zu machen also auf Google Cloud Platform mit GKE (Google Kubernetes Engine).

----
<br>

### Warum `e2-standard-2` als Maschinentyp?

Der e2-standard-2 bietet 2 vCPU und 8 GB RAM. Ich habe mich bewusst gegen kleinere Instanzen wie e2-micro entschieden, weil diese oft zu schwach sind für mehrere gleichzeitige Pods. Mit 3 Nodes dieser Grösse konnte ich Hochverfügbarkeit demonstrieren. Die gesamten GCP-Kosten für das Projekt betrugen ca. 206 CHF (vom Free-Trial-Guthaben von ~236 CHF) der grösste Kostenfaktor waren die 3 laufenden GKE-Nodes über mehrere Wochen.

<img src="/images/gcp_kosten.png" width="800" />

---
<br>

### Sicherheitskonzept

- **TLS via Let's Encrypt**:
	Alle Verbindungen laufen über HTTPS, kein unverschlüsselter Traffic.
- **Kubernetes Secrets**:
	Datenbankpasswörter nie im Klartext in YAML-Files, sondern als Secrets verwaltet.
- **GitHub Secrets**: 
	Passwörter im CI/CD-Workflow nicht im Code sichtbar, sondern als verschlüsselte GitHub Secrets gespeichert.
- **Minimale Berechtigungen**:
	Der GitHub Actions Service Account hat nur container.developer-Rechte, nicht Owner oder Admin.

