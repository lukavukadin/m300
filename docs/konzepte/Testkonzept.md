# Testkonzept und durchgeführte Tests

Da es sich um ein Infrastruktur-Projekt handelt, habe ich keine klassischen Unit-Tests geschrieben. Stattdessen folgende Integrations- und Verfügbarkeitstests durchgeführt und dokumentiert:

| Test               | Vorgehen                                                   | Erwartetes Ergebnis                           | Tatsächliches Ergebnis                                 |
| :----------------- | :--------------------------------------------------------- | :-------------------------------------------- | ------------------------------------------------------ |
| DNS-Konnektivität  | nslookup git.lukavukadin.ch                                | IP `34.53.135.70`                             | Korrekt aufgelöst                                      |
| HTTPS-Verbindung   | Browser-Aufruf `https://git.lukavukadin.ch`                | Gültiges TLS-Zertifikat                       | Let's Encrypt Zertifikat aktiv                         |
| Gitea-Login        | Admin-Login mit Benutzername/Passwort                      | Erfolgreicher Login                           | Login funktioniert                                     |
| Pod-Failover       | kubectl delete pod <gitea-pod>                             | Webseite bleibt erreichbar, neuer Pod startet | Ersatz-Pod in Sekunden erstellt                        |
| DB-Failover        | `kubectl delete pod gitea-postgres-2` (Primary)            | Replica wird automatisch Primary              | Failover in ~3:46 Min, Login blieb funktionsfähig      |
| HPA-Lasttest       | 60+ parallele `busybox`-Pods                               | CPU steigt, HPA misst korrekt                 | CPU stieg bis 70%, Metriken korrekt                    |
| Monitoring-Alert   | kubectl exec ... kill 1                                    | E-Mail-Benachrichtigung von GCP               | E-Mail kam sofort an                                   |
| Grafana Monitoring | `https://grafana.lukavukadin.ch` aufrufen, Login mit Admin | Dashboard mit Cluster-Metriken sichtbar       | CPU 4.72%, Memory 31.1%, Nodes 3, Pods 62 alle Running |
| CI/CD-Pipeline     | Push auf GitHub `main`                                     | Automatisches Deployment                      | Helm upgrade läuft automatisch                         |







