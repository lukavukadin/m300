# Rollenkonzept und Berechtigungen

Im Projekt wurden folgende Service Accounts und Rollen eingesetzt:


| Account / Rolle                                   | Berechtigungen                                  | Zweck                                                         |
| :------------------------------------------------ | :---------------------------------------------- | :------------------------------------------------------------ |
| luka.vukadin7@gmail.com                           | roles/owner                                     | Projektbesitzer - volle Kontrolle über GCP                    |
| github-actions@m300-gitea.iam.gserviceaccount.com | roles/container.developer                       | GitHub Actions CI/CD - nur Kubernetes-Zugriff, kein GCP-Admin |
| GKE Node Service Account                          | roles/container.defaultNodeServiceAgent         | GKE-Nodes - automatisch von GCP verwaltet                     |
| Kubernetes Secrets                                | Nur innerhalb des Clusters sichtbar             | Datenbankpasswörter, TLS-Zertifikate                          |

Prinzip der minimalen Berechtigungen (Least Privilege):

Der GitHub Actions Service Account hat bewusst nur container.developer-Rechte erhalten, er kann Kubernetes-Ressourcen verwalten, aber keine GCP-Infrastruktur erstellen, löschen oder ändern. Das verhindert, dass ein kompromittierter GitHub-Workflow grösseren Schaden anrichten könnte.

TLS-Zertifikate werden von cert-manager automatisch verwaltet und als Kubernetes Secrets gespeichert nur Pods im selben Namespace haben Zugriff darauf.