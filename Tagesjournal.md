
## 21.05.2026 – Modulteiltag 1: Einstieg & Orientierung

- **Geplante Tagesziele:**
    - Lernumgebung einrichten, Git-Repo erstellen und Idee für Projekt-Variante 2 (V2) definieren.

- **Erreichte Resultate:**
    - Ich habe mein Repository initialisiert, den Link abggeben und mich für das Projekt "Hochverfügbares Gitea in der Cloud" entschieden.
    
- **Aufgetretene Probleme & Reflexion:**
    - Die Abgrenzung von V1 zu V2 war anfangs unklar. Ich habe mich für V2 und Kubernetes entschieden, da eine echte Skalierung mit Docker-Compose in der Cloud zu unprofessionell wäre.
    
- **Eingesetzte Ressourcen:**
    - Modulunterlagen M300, Gitea Cluster-Dokumentation.
        

##  28.05.2026 – Modulteiltag 2: Theorie & Konzeptionierung

- **Geplante Tagesziele:**
    
    - Den Theorie-Input der Lehrperson verstehen. Anforderungen für die Gitea-Architektur recherchieren.
        
- **Erreichte Resultate:**
    
    - Ich habe das Kubernetes-Klassenbeispiel analysiert. Ich habe mich theoretisch eingelesen, wie Gitea mit mehreren Frontends umgehen kann.
        
- **Aufgetretene Probleme & Reflexion:**
    
    - Ich habe gemerkt, dass Standard-Cloud-Speicher (ReadWriteOnce) für mein Vorhaben nicht ausreicht. Wenn mehrere Gitea-Pods auf dieselben Daten zugreifen, brauche ich zwingend einen Shared Storage (ReadWriteMany).
    
- **Eingesetzte Ressourcen:**
    
    - [K8s Example Repo Kebohn](https://github.com/kebohn/k8s_example), K8s Storage Dokumentation.
    

##  04.06.2026 – Modulteiltag 3:  (Google Cloud & GKE Setup)

- **Geplante Tagesziele:**
    
    - Google Cloud (GCP) Zugang einrichten, lokale Tools (`gcloud`, `kubectl`) installieren und mein GKE-Cluster erstellen.
        
- **Erreichte Resultate:**
    
    - Ich habe das GCP-Konto aktiviert und die CLIs lokal eingerichtet. Das GKE-Cluster mit 3 Nodes steht, und ich kann mich per `kubectl` erfolgreich von meinem PC aus damit verbinden.

- **Aufgetretene Probleme & Reflexion:**
    
    - -
 
- **Eingesetzte Ressourcen:**
    
    - Google Cloud Console, GKE Dokumentation, Google SDK Installationsanleitung.


##  11.06.2026 – Modulteiltag 4: Das Datenbank-Cluster

- **Geplante Tagesziele:**
    
    - Bereitstellung eines hochverfügbaren PostgreSQL-Clusters in Kubernetes (mittels Helm und z.B. Bitnami PostgreSQL-HA).
        
- **Erreichte Resultate:**
    - Da die lokale CLI Rechte-Probleme machte, habe ich das GKE-Cluster (3 Nodes, e2-medium) erfolgreich direkt über die Google Cloud Web-Konsole erstellt. Die Vorbereitungen für das PostgreSQL-HA-Setup stehen.
    
- **Aufgetretene Probleme & Reflexion:**
	- Die `gcloud`-CLI blockierte die API-Aktivierung wegen eines IAM-Konflikts. Der Wechsel auf die Web-Oberfläche als Workaround hat das Problem sofort gelöst

- **Eingesetzte Ressourcen:**
    - Google Cloud Web Console, GKE Dashboard, Bitnami PostgreSQL Helm-Dokumentation.
        

## 18.06.2026 – Modulteiltag 5: Shared Storage & Gitea Frontend

- **Geplante Tagesziele:**
    
    - Google Cloud Filestore (NFS) als ReadWriteMany Storage einrichten. Gitea-Deployment mit 2 Replicas starten und mit der DB verbinden.
        
- **Erreichte Resultate:**
    
    - _O_
        
- **Aufgetretene Probleme & Reflexion:**
    
    - _O_
        
- **Eingesetzte Ressourcen:**
    
    - _O_
        

##  25.06.2026 – Modulteiltag 6: Ingress, Domain & SSL

- **Geplante Tagesziele:**
    
    - Nginx-Ingress-Controller installieren. Meine eigene Domain via DNS auf den Google Load Balancer zeigen lassen. SSL via Let's Encrypt einrichten.
        
- **Erreichte Resultate:**
    
    - _O_
        
- **Aufgetretene Probleme & Reflexion:**
    
    - _O_
        
- **Eingesetzte Ressourcen:**
    
    - _O_
        

##  02.07.2026 – Modulteiltag 7: Failover-Testing & Optimierung

- **Geplante Tagesziele:**
    
    - Testkonzept durchführen: Einen Gitea-Pod im Betrieb löschen und prüfen, ob die Webseite online bleibt (Load Balancing Test). DB-Ausfall simulieren.
        
- **Erreichte Resultate:**
    
    - _O_
        
- **Aufgetretene Probleme & Reflexion:**
    
    - _O_
        
- **Eingesetzte Ressourcen:**
    
    - _O_
        

##  09.07.2026 – Modulteiltag 8: Abgabe & Finalisierung

- **Geplante Tagesziele:**
    
    - Technische Dokumentation fertig schreiben, Selbsteinschätzung ausfüllen, Repo aufräumen und Projekt in Teams final abgeben.
        
- **Erreichte Resultate:**
    
    - _O_
        
- **Aufgetretene Probleme & Reflexion:**
    
    - _O_
        
- **Eingesetzte Ressourcen:**
    
    - _O_