
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

10. Schritt: Gitea via Helm installiert - Filestore-Mount-Problem gelöst
   
   Gitea-Konfiguration (`gitea-values.yaml`) erstellt, mit Verbindung zu PostgreSQL und TLS via cert-manager. Beim ersten Deployment blieben die Pods tagelang bei `Init:0/3` hängen, mit dem Fehler `MountVolume.MountDevice failed: DeadlineExceeded`. Das war ein bekannter Bug im Filestore-CSI-Treiber – der Mount blockierte dauerhaft auf Node-Ebene, selbst ein Node-Replace half nicht. Gelöst habe ich es, indem ich statt eines neuen automatisch erstellten Volumes das bereits stabile Filestore-Volume aus Terraform manuell als PersistentVolume eingebunden habe.
   
`Hier sieht man die Drei Gitea-Pods am fest hängen:`
   <img src="Bilder/Gitea_Pods_(Init-Phase).png" width="370" />
   
`Fehler beim Mounten:`
<img src="Bilder/warning_Failedmount.png" width="750" />

`Lösung: ~gitea-shared-storage erfolgreich gebunden (RWX, standard-rwx):`
<img src="Bilder/gitea_shared_bound.png" width="850" />

----

11. Schritt: PVC-Konflikt und hängender Finalizer behoben

Beim manuellen Einbinden des PersistentVolumes gab es gleich zwei Folgefehler: Helm wollte das PVC nicht übernehmen (fehlende Ownership-Labels), und die Grösse passte nicht zur Helm-Konfiguration. Nach der Korrektur blieb das PVC dann im Status `Terminating` stecken - das liess sich nur lösen, indem ich den Kubernetes-Finalizer manuell per Patch entfernt habe.

- `PV/PVC manuell erstellt als Workaround:`					<img src="Bilder/gitea_pv_apply.png" width="450" />

- `Helm-Konflikt mit dem manuellen PVC`	<img src="Bilder/apply_failed_with_gitea_values.png" width="990" />

- `Lösung: Patch behebt den Konflikt, Volume wieder frei:`	<img src="Bilder/patch_pvc.png" width="999" />

----

12. Schritt: Datenbank-Passwort-Mismatch behoben

