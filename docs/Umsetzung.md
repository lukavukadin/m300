# Umsetzung



### 1. Schritt: Architektursdiagramm:

Als erstes habe ich ein [[Architektursdiagramm]] erstellt und konnte so nachdenken und überlegen wie ich mein Projekt aufgebaut werden soll

<img src="/images/planung_m300.jpg" width="600" />

----
<br>

### 2. Schritt: GCP-Projekt & Tools einrichten:

   Free Trial aktiviert, Projekt `m300-gitea` erstellt und die benötigten API's aktiviert (Compute Engine, Kubernetes Engine, Cloud DNS, Filestore). Lokal habe ich: gcloud CLI, Terraform, kubectl, Helm installliert. Bei GCP authentifiziert.

<img src="/images/gcloud_free_trial.png" width="600" />

----
<br>

### 3. Schritt: Terraform-Infrastruktur geschrieben:

Drei Terraform-Files erstellt (`main.tf`, `variables.tf`, `outputs.tf`) die folgende Ressourcen definieren: VPC-Netzwerk, Subnetz mit sekundären IP-Bereichen für Pods/Services, GKE-Cluster, Node-Pool, Cloud DNS Zone, Filestore-Instanz.
[Hier geht es zu den Files](/.files)

<img src="/images/vs_einblick.png" width="600" />

----
<br>

### 4. Schritt: Terraform Apply (mit Problemlösung)

Ich habe `terraform init` und `terraform apply` ausgeführt. Aufgetretene Probleme: fehlende API-Aktivierung im richtigen Projekt, SSD-Quota-Limit überschritten (Lösung: Wechsel von regionalem zu zonalem Cluster):

<img src="/images/cluster_erstellt.png" width="600" />


----
<br>

### 5. Schritt: kubectl mit GKE-Cluster verbunden

`gcloud container clusters get-credentials` ausgeführt. Aufgetretenes Problem: TLS-Zertifikatsfehler durch Schul-Netzwerk/Proxy. Ich konnte es lösen indem ich auf Mobile-Hotspot gewechselt habe:

<img src="/images/gke_cluster.png" width="600" />


---
<br>

### 6. Schritt: Nginx Ingress Controller installiert

Via Helm installiert (`ingress-nginx` Chart). Erstellt automatisch einen GCP Load Balancer mit öffentlicher IP-Adresse:

<img src="/images/nginx.png" width="600" />
   
---
<br>

### 7. Schritt: cert-manager installiert + ClusterIssuer konfiguriert

cert-manager via Helm installiert für automatische TLS-Zertifikate. `ClusterIssuer` für Let's Encrypt erstellt (`letsencrypt-prod`):

<img src="/images/clusterissuer.png" width="600" />

-----
<br>

### 8. Schritt: DNS konfiguriert

Bei Hostpoint einen A-Record erstellt: `git.lukavukadin.ch` → `34.53.135.70`:
<img src="/images/hostpoint_eintrag.png" width="600" />

---
<br>

### 9. Schritt: Filestore CSI Driver aktiviert

Ursprünglicher Gitea-Helm-Install schlug fehl wegen fehlender `ReadWriteMany`-StorageClass. Filestore-CSI-Driver auf dem Cluster aktiviert (`gcloud container clusters update --update-addons=GcpFilestoreCsiDriver=ENABLED`), wodurch `standard-rwx` StorageClass verfügbar wurde.

<img src="/images/filestore.png" width="700" />

----
<br>

### 10. Schritt: PostgreSQL-Cluster (CloudNativePG) installiert

CloudNativePG Operator via Helm installiert. PostgreSQL-Cluster mit 1 Primary + 2 Replicas erstellt (`postgres-cluster.yaml`):

<img src="/images/postgress.png" width="600" />

---
<br>

### 11. Schritt: Gitea via Helm installiert - Filestore-Mount-Problem gelöst
   
   Gitea-Konfiguration (`gitea-values.yaml`) erstellt, mit Verbindung zu PostgreSQL und TLS via cert-manager. Beim ersten Deployment blieben die Pods tagelang bei `Init:0/3` hängen, mit dem Fehler `MountVolume.MountDevice failed: DeadlineExceeded`. Das war ein bekannter Bug im Filestore-CSI-Treiber – der Mount blockierte dauerhaft auf Node-Ebene, selbst ein Node-Replace half nicht. Gelöst habe ich es, indem ich statt eines neuen automatisch erstellten Volumes das bereits stabile Filestore-Volume aus Terraform manuell als PersistentVolume eingebunden habe. 
   
- Hier sieht man die Drei Gitea-Pods am fest hängen:

   <img src="/images/Gitea_Pods_(Init-Phase).png" width="370" />

- Fehler beim Mounten

<img src="/images/warning_Failedmount.png" width="750" />

- Lösung: ~gitea-shared-storage erfolgreich gebunden (RWX, standard-rwx):

<img src="/images/gitea_shared_bound.png" width="850" />

----
<br>

### 12. Schritt: PVC-Konflikt und hängender Finalizer behoben

Beim manuellen Einbinden des PersistentVolumes gab es gleich zwei Folgefehler: Helm wollte das PVC nicht übernehmen (fehlende Ownership-Labels), und die Grösse passte nicht zur Helm-Konfiguration. Nach der Korrektur blieb das PVC dann im Status `Terminating` stecken - das liess sich nur lösen, indem ich den Kubernetes-Finalizer manuell per Patch entfernt habe.

- PV/PVC manuell erstellt als Workaround:				

<img src="/images/gitea_pv_apply.png" width="450" />

- Helm-Konflikt mit dem manuellen PVC	

<img src="/images/apply_failed_with_gitea_values.png" width="990" />

- Lösung: Patch behebt den Konflikt, Volume wieder frei:	

<img src="/images/patch_pvc.png" width="999" />

----
<br>

### 13. Schritt: DNS/Cloudflare-Konflikt gelöst & Gitea live getestet

Der DNS-Eintrag bei Hostpoint war korrekt, trotzdem zeigte `nslookup` weiterhin Cloudflare-IPs statt meiner Load-Balancer-IP. 

Grund: Ich habe vergessen das ich meine Domain zusätzlich über Cloudflare verwalte, das die Hostpoint-Einträge überschreibt. Lösung: A-Record direkt in Cloudflare erstellt. Danach war Gitea unter `https://git.lukavukadin.ch` mit gültigem HTTPS erreichbar, Admin-Login funktionierte.

- A-Record in Cloudflare erstellt:

<img src="/images/cloudflare_record.png" width="400" />


- Gitea unter `git.lukavukadin.ch` erreichbar:

<img src="/images/git_erreichbar_ueber_domain.png" width="900" />



- Erfolgreich als Admin eingeloggt:

<img src="/images/erfolgreich_eingeloggt.png" width="900" />

----
<br>
### 14. Schritt: Failover-Test - Gitea-Pod gelöscht, Webseite blieb online

Nach dem Hochskalieren auf 3 Replicas habe ich einen Pod-Ausfall simuliert, um die Hochverfügbarkeit zu testen. Ich habe einen laufenden Gitea-Pod manuell gelöscht und parallel die Webseite im Browser mehrmals neu geladen. Kubernetes hat sofort einen Ersatz-Pod erstellt, die Webseite war zu keinem Zeitpunkt nicht erreichbar.

- replicaCount auf 3 erhöht:
<img src="/images/replicacount_3.png" width="400" />

- Mit helm den befehl gegeben 3 gitea pods zu erstellen:
<img src="/images/gitea_upgraden.png" width="700" />

- Erfolgreich 3 pods erstellt
<img src="/images/drei_gitea_pods_am_laufen.png" width="400" />

- Den Pod `gitea-759f75554f-4vdwh` gelöscht:
<img src="/images/pod_gelöscht.png" width="500" />

- Dann wurde ein neuer Pod `gitea-759f75554f-pg9vw` erstellt und gestartet:
<img src="/images/pod_erfolgreich_gestartet.png" width="500" />

Hier sieht man den Test Live:

<img src="/images/erfolgreicher_failover_test.gif" alt="Failover Test" width="100%">

---

