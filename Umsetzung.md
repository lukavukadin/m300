
1. Schritt: GCP-Projekt & Tools einrichten:

   Free Trial aktiviert, Projekt `m300-gitea` erstellt und die benötigten API's aktiviert (Compute Engine, Kubernetes Engine, Cloud DNS, Filestore). Lokal habe ich: gcloud CLI, Terraform, kubectl, Helm installliert. Bei GCP authentifiziert.

<img src="Bilder/gcloud_free_trial.png" width="600" />

----
2. Schritt: Terraform-Infrastruktur geschrieben:

    Drei Terraform-Files erstellt (`main.tf`, `variables.tf`, `outputs.tf`) die folgende Ressourcen definieren: VPC-Netzwerk, Subnetz mit sekundären IP-Bereichen für Pods/Services, GKE-Cluster, Node-Pool, Cloud DNS Zone, Filestore-Instanz.
    [Hier geht es zu den Files](files/)

<img src="Bilder/vs_einblick.png" width="600" />

----
3. Schritt: Terraform Apply (mit Problemlösung)

Ich habe `terraform init` und `terraform apply` ausgeführt. Aufgetretene Probleme: fehlende API-Aktivierung im richtigen Projekt, SSD-Quota-Limit überschritten (Lösung: Wechsel von regionalem zu zonalem Cluster):

<img src="Bilder/cluster_erstellt.png" width="600" />


----
4. Schritt: kubectl mit GKE-Cluster verbunden
`gcloud container clusters get-credentials` ausgeführt. Aufgetretenes Problem: TLS-Zertifikatsfehler durch Schul-Netzwerk/Proxy. Ich konnte es lösen indem ich auf Mobile-Hotspot gewechselt habe:

<img src="Bilder/gke_cluster.png" width="600" />


---
5. Schritt: Nginx Ingress Controller installiert

Via Helm installiert (`ingress-nginx` Chart). Erstellt automatisch einen GCP Load Balancer mit öffentlicher IP-Adresse:

<img src="Bilder/nginx.png" width="600" />
   
---

6. Schritt: cert-manager installiert + ClusterIssuer konfiguriert

cert-manager via Helm installiert für automatische TLS-Zertifikate. `ClusterIssuer` für Let's Encrypt erstellt (`letsencrypt-prod`):

<img src="Bilder/clusterissuer.png" width="600" />

-----

7. Schritt: DNS konfiguriert

Bei Hostpoint einen A-Record erstellt: `git.lukavukadin.ch` → `34.53.135.70`:
<img src="Bilder/hostpoint_eintrag.png" width="600" />

---
8. Schritt: Filestore CSI Driver aktiviert

Ursprünglicher Gitea-Helm-Install schlug fehl wegen fehlender `ReadWriteMany`-StorageClass. Filestore-CSI-Driver auf dem Cluster aktiviert (`gcloud container clusters update --update-addons=GcpFilestoreCsiDriver=ENABLED`), wodurch `standard-rwx` StorageClass verfügbar wurde.

<img src="Bilder/filestore.png" width="700" />

----
9. Schritt: PostgreSQL-Cluster (CloudNativePG) installiert

CloudNativePG Operator via Helm installiert. PostgreSQL-Cluster mit 1 Primary + 2 Replicas erstellt (`postgres-cluster.yaml`):

<img src="Bilder/postgress.png" width="600" />

---

10. Schritt: Gitea via Helm installiert (in Bearbeitung)
   
   Gitea-Konfiguration (`gitea-values.yaml`) erstellt mit Verbindung zu PostgreSQL-Primary (`gitea-postgres-rw`), TLS via cert-manager, 3 Replicas. Aktuelles Problem: Filestore-Mount hängt bei Init-Phase (`MountVolume.MountDevice failed ... Aborted`) — wird aktuell debuggt.
   
   <img src="Bilder/Gitea_Pods_(Init-Phase).png" width="370" />

