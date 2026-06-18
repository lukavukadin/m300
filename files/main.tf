terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ============================================
# VPC Netzwerk
# ============================================
resource "google_compute_network" "gitea_vpc" {
  name                    = "gitea-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gitea_subnet" {
  name          = "gitea-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.gitea_vpc.id

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/16"
  }
}

# ============================================
# GKE Cluster
# ============================================
resource "google_container_cluster" "gitea" {
  name                 = var.cluster_name
  location             = var.zone
  deletion_protection  = false

  network    = google_compute_network.gitea_vpc.name
  subnetwork = google_compute_subnetwork.gitea_subnet.name

  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "gitea_nodes" {
  name       = "gitea-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.gitea.name
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    disk_size_gb = 30
    disk_type    = "pd-standard"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      project = "m300-gitea"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# ============================================
# Cloud DNS Zone
# ============================================
resource "google_dns_managed_zone" "gitea" {
  name        = "gitea-zone"
  dns_name    = "lukavukadin.ch."
  description = "DNS Zone für Gitea"
}

# ============================================
# Filestore (Shared Storage für Gitea Pods)
# ============================================
resource "google_filestore_instance" "gitea" {
  name     = "gitea-filestore"
  location = var.zone
  tier     = "BASIC_HDD"

  file_shares {
    capacity_gb = 1024
    name        = "gitea_data"
  }

  networks {
    network = google_compute_network.gitea_vpc.name
    modes   = ["MODE_IPV4"]
  }
}