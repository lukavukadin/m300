# Projektkonzept Modul 300 - V2

**Projektname:** High-Availability Gitea Deployment in der Google Cloud mittels Kubernetes (GKE)
**Datum:** Juni 2026

## 1. Ausgangslage & Use-Case

In modernen DevOps-Umgebungen ist die Versionsverwaltung (Git) das kritischste Tool. Ein Ausfall blockiert die gesamte Entwicklung. Gitea ist eine leichtgewichtige, performante Git-Alternative. In diesem Projekt wird Gitea nicht als simple Single-Instance deployt, sondern als hochverfügbares, ausfallsicheres System in der Cloud (GCP) realisiert.

## 2. Zielsetzung & Architektur (Scope)

Das Ziel ist die Erstellung einer produktionsbereiten, cloud-nativen Infrastruktur:

*   **Plattform:** Google Kubernetes Engine (GKE) Cluster.
*   **Load Balancing & Ingress:** Google Cloud Load Balancer gekoppelt mit Nginx-Ingress-Controller und automatischen TLS/SSL-Zertifikaten (Let's Encrypt) über eine eigene Domain.
*   **Frontend-Skalierung:** Gitea wird in mehreren Instanzen (Replicas) ausgeführt. Fällt ein Container aus, übernimmt der andere nahtlos (Load Balancing).
*   **Shared Storage:** Da mehrere Frontends aktiv sind, wird ein verteilter Speicher (ReadWriteMany) benötigt (Google Cloud Filestore / NFS), um Git-Repositories synchron zu halten.
*   **Database Cluster:** Ein hochverfügbares PostgreSQL-Cluster (z.B. mittels CloudNativePG Operator oder Bitnami), das Replikation und automatisches Failover beherrscht.

## 3. Erfüllung der Kriterien (Modul 300 V2)

Dieses Projekt deckt folgende fortgeschrittene Themen der Kompetenzmatrix ab:

*   **Kubernetes:** Pods, Deployments, Services, Ingress, PersistentVolumes.
*   **DevOps / Skalierung:** Multi-Replica Deployment, Health Checks (Liveness/Readiness Probes).
*   **Sicherheitskonzepte:** Automatisches SSL/TLS per Cert-Manager, Secret-Management für DB-Logins.
*   **Storage-Architektur:** Implementierung von ReadWriteMany (RWX) Storage in der Cloud.
