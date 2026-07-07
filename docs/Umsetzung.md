# Umsetzung



### 1. Schritt: Architektursdiagramm:

Als erstes habe ich ein [Architektursdiagramm](../Architektursdiagramm.md) erstellt und konnte so nachdenken und überlegen wie ich mein Projekt aufgebaut werden soll

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

- Die Files sind im anderen REPO: https://github.com/lukavukadin/m300-gitea

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

- Hier sieht man den Test Live:

<img src="/images/erfolgreicher_failover_test.gif" alt="Failover Test" width="100%">

---
<br>

### 15. Schritt: Failover-Test -PostgreSQL-Primary gelöscht, automatischer Wechsel

Anschliessend habe ich den Datenbank-Failover getestet. Ich habe geprüft, welcher PostgreSQL-Pod aktuell der Primary ist, diesen gelöscht und beobachtet, wie CloudNativePG automatisch eine Replica zum neuen Primary befördert. Während des gesamten Vorgangs (ca. 3:46 Minuten) habe ich wiederholt versucht, mich bei Gitea einzuloggen - der Login funktionierte durchgehend ohne Unterbruch.

- `gitea-postgres-2` ist der Primary:

<img src="/images/gitea_postgres_primary.png" width="550" />


- Primary gelöscht:

<img src="/images/primary_gelöscht.png" width="550" />


- Hier sieht man den automatischen Prozess von Kubernetes und zwar wie er dem 'gitea-postgres-1' die rolle Primary zuteilt und wie der neue pod erstellt und gestartet wird:

<img src="/images/postgres_primary_wechsel.png" width="750" />


- Alle Pods sind nach kurzer Zeit wieder auf den Beinen:

<img src="/images/erfolgreicher_postgres_failover.png" width="750" />


- Hier sieht man den Test Live:

<img src="/images/erfolgreicher_postgres_failover.gif" alt="Failover Test" width="100%">

----
<br>

### 16. Schritt: Horizontal Pod Autoscaler (HPA) konfiguriert und getestet

HPA eingerichtet, der Gitea zwischen 3 und 6 Pods skaliert, abhängig von der CPU-Auslastung (Ziel: 70%). Dafür mussten erst Resource-Requests/Limits ergänzt werden, da diese fehlten.

Zum Testen habe ich mit `busybox`-Pods künstliche Last erzeugt. Mit ca. 60 parallelen Lasttest-Pods stieg die CPU bis auf 70%, blieb aber knapp unter der Schwelle - Kubernetes skaliert erst bei klarer Überschreitung, um Flackern zu vermeiden. Mit 200 Lasttest-Pods kam dann nicht mehr Gitea, sondern der ganze Cluster an seine Grenze: Ein PostgreSQL-Pod konnte seine Health-Checks kurz nicht mehr beantworten und wurde automatisch neu gestartet. Nach dem Test hat sich alles innerhalb wenigen Minuten von selbst erholt, ohne Datenverlust.

- Als ich den befehl `kubectl get hpa` durchgeführt habe kam als cpu unknown:

```
C:\Users\vukadinl\m300-gitea> kubectl get hpa
NAME  REFERENCE TARGETS MINPODS MAXPODS REPLICAS AGE 
gitea Deployment/gitea cpu: <unknown>/70% 3 6 3 97s
```


- Deswegen habe ich Resource-Requests/Limits ergänzt, damit HPA überhaupt messen kann:

<img src="/images/gitea_values.png" width="300" />

- Nach der Anpassung liefert der HPA jetzt echte CPU-Werte:

<img src="/images/hpa.png" width="550" />


- Hier sieht man den CPU-Verlauf während des Lasttests:

<img src="/images/cpu_steigt.png" width="550" />

----
<br>

### Schritt 17: Monitoring & Alerting eingerichtet

GCP Monitoring sammelt automatisch Metriken vom GKE-Cluster. Über das GKE Cluster Monitoring Dashboard lassen sich CPU, Memory, Netzwerk und Pod-Status in Echtzeit beobachten.


Zusätzlich habe ich zwei Benachrichtigungsrichtlinien eingerichtet, die mich per E-Mail warnen:

- Gitea Pod Crash Alert - feuert wenn ein Container neu startet (Restart Count > 0), z.B. bei CrashLoopBackOff

- Gitea Pod Down Alert - feuert wenn ein Container länger als 5 Minuten keine Metriken mehr sendet. Die 5-Minuten-Schwelle habe ich gewählt, weil Kubernetes bei einem Ausfall innerhalb von Sekunden automatisch einen Ersatz Pod startet - ein kurzfristiger Neustart löst also keinen unnötigen Alarm aus.

Um den Crash Alert zu testen, habe ich mit `kubectl exec` den Hauptprozess eines Gitea-Pods manuell gekilled. Der Pod wurde sofort automatisch neugestartet, und kurz danach kam die E-Mail-Benachrichtigung.


**Richtlinie erstellt**

- Messwert `Restart count` ausgewählt für den Crash Alert:

<img src="/images/messwert_restart_countt.png" width="750" />



- E-Mail als Benachrichtigungskanal eingetragen:

<img src="/images/übersicht_benachrichtigung.png" width="850" />


- Beide Alerts erstellt und sind aktiv in der Übersicht:

<img src="/images/überblick_monitoring_richtlinien.png" width="850" />


**Alert-Test**

- Zuerst habe ich mit `kubectl exec` den Hauptprozess eines Gitea-Pods manuell beendet

Kubernetes hat den Pod sofort automatisch neugestartet. GCP hat den Anstieg des Restart Counts erkannt und direkt eine E-Mail ausgelöst:

<img src="/images/alert_pod_löschen.png" width="850" />



- Automatische E-Mail von GCP: "Alert firing - Kubernetes Container Restart count is above threshold of 0:

<img src="/images/alert_email_benachrichtigung.png" width="650" />


- GCP Monitoring zeigt den Vorfall live mit dem Restart-Count-Anstieg:

<img src="/images/gcloud_übersicht_alert.png" width="950" />

---
<br>

### Schritt 18: CI/CD mit GitHub Actions eingerichtet

Das Projekt-Repository wurde auf GitHub erstellt (lukavukadin/m300-gitea, privat). Bei jedem Push auf main deployt GitHub Actions automatisch Gitea auf den GKE-Cluster.


- Erster Fehler - Service Account Key nicht erlaubt:

Weil GCP die Erstellung von Service Account Keys blockiert hat, musste ich stattdessen Workload Identity Federation einrichten - die modernere und sicherere Methode ohne Key-File.

<img src="/images/service_key_error.png" width="950" />


- Workload Identity Pool und Provider erstellt:

Workload Identity Pool und Provider erfolgreich erstellt, Service Account verknüpft. GitHub Actions kann sich damit ohne Key direkt bei GCP authentifizieren.

<img src="/images/workload_identity_setup.png" width="950" />


- Workflow-File erstellt:

Der Workflow `.github/workflows/deploy.yml` definiert die CI/CD-Pipeline - er wird bei jedem Push auf `main` automatisch ausgelöst und führt GCP-Login, kubectl-Konfiguration, Helm-Installation und Gitea-Deployment aus.

```
name: Deploy Gitea to GKE

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write

    steps:
      - name: Code holen
        uses: actions/checkout@v3

      - name: Bei GCP einloggen (Workload Identity)
        uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: "projects/317129508741/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
          service_account: "github-actions@m300-gitea.iam.gserviceaccount.com"

      - name: kubectl konfigurieren
        uses: google-github-actions/get-gke-credentials@v2
        with:
          cluster_name: gitea-cluster
          location: europe-west1-b
          project_id: m300-gitea

      - name: Helm installieren
        uses: azure/setup-helm@v3

      - name: Gitea deployen
        run: |
          helm repo add gitea-charts https://dl.gitea.com/charts/
          helm repo update
          helm upgrade gitea gitea-charts/gitea -f kubernetes/gitea-values.yaml --namespace default --wait
```


- Versehentlich gepushter Key - sofort behoben:

<img src="/images/git_rm_key.png" width="550" />


- GitHub Actions läuft automatisch bei jedem Push:

<img src="/images/github_actions_uebersicht.png" width="980" />


- Alle Schritte erfolgreich durchgelaufen:

<img src="/images/github_actions_detail.png" width="980" />

----
<br>

### Schritt 19: Secrets-Management – Passwörter aus Code entfernt

Nachdem das Repository auf GitHub gepusht wurde, waren die Passwörter in gitea-values.yaml und postgres-cluster.yaml noch im Klartext sichtbar. Da das Repo privat ist, war das kein unmittelbares Sicherheitsproblem, aber trotzdem schlechte Praxis.

**Lösung:** Passwörter durch PLACEHOLDER ersetzt und die echten Werte als GitHub Secrets gespeichert. Der GitHub Actions Workflow übergibt die Secrets beim Deployment via --set an Helm - so sind sie nie im Code sichtbar.

- Drei Secrets erfolgreich erstellt:

<img src="/images/github_secrets.png" width="980" />


- Hier sieht man als beispiel einen Placeholder in diesem File:

<img src="/images/placeholder.png" width="350" />


- deploy.yml angepasst:

<img src="/images/deploy_angepasst.png" width="550" />

---
<br>

### Schritt 20: Projekt auf eigener Gitea-Instanz gehostet


Als letzten Schritt habe ich beide Repositories auf meiner eigenen Gitea-Instanz unter `git.lukavukadin.ch` gespiegelt, das Projekt hostet sich damit selbst auf der Infrastruktur, die es beschreibt.

- Zuerst habe ich das Projekt-Repository (m300-gitea) auf Gitea erstellt und gepusht. Beim ersten Push öffnete sich automatisch ein Browser-Fenster zur OAuth-Authentifizierung bei meiner eigenen Gitea-Instanz, nach der Bestätigung lief der Push erfolgreich durch:

- git push:
<img src="/images/gitea_m300_gepusht.png" width="450" />

- OAuth-Authentifizierung:
<img src="/images/OAuth_Autorisierung.png" width="850" />

- Erfolgreich auf meine Git:
<img src="/images/m300-gitea_erfolgreich_gepusht.png" width="850" />


- Beim Pushen der Dokumentation (`m300`) trat ein **HTTP 413-Fehler** auf - das Repository war 18 MB gross und der Nginx Ingress blockierte den Upload wegen einer zu kleinen Standard-Request-Grösse:

<img src="/images/gitea_413_error.png" width="450" />


**Lösung**:

- Gelöst durch das Hinzufügen der Annotation `nginx.ingress.kubernetes.io/proxy-body-size: "50m"` in der gitea-values.yaml. Diese Annotation sagt dem Nginx Ingress Controller, dass er Requests bis zu 50 MB akzeptieren soll statt dem Standard von 1 MB:

<img src="/images/gitea_values_proxy_body.png" width="450" />


- Nun auch die Dokumentation erfolgreich gepusht:

<img src="/images/m300_erfolgreich_gepusht.png" width="650" />


- Hier sieht man die beiden Repos erfolgreich auf meinem Git:

<img src="/images/repos_erfolgreich_auf_gitea.png" width="950" />
