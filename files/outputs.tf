output "cluster_name" {
  description = "Name des GKE Clusters"
  value       = google_container_cluster.gitea.name
}

output "cluster_endpoint" {
  description = "Endpoint des GKE Clusters"
  value       = google_container_cluster.gitea.endpoint
  sensitive   = true
}

output "region" {
  description = "Region"
  value       = var.region
}

output "dns_nameservers" {
  description = "Nameserver für lukavukadin.ch → beim Domain-Anbieter eintragen"
  value       = google_dns_managed_zone.gitea.name_servers
}

output "filestore_ip" {
  description = "IP-Adresse des Filestores"
  value       = google_filestore_instance.gitea.networks[0].ip_addresses[0]
}