terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}
provider "google" {
  credentials = file("/Users/Pranshu/Downloads/pranshu-001-e1ea1a7da83e.json")

  project = "pranshu-001"
  region  = "europe-north1"
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network-custom-001"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "public-subnet" {
  name = "public-subnet-0011"

  ip_cidr_range = "10.0.0.0/24"
  region        = "europe-north1"
  network = google_compute_network.vpc_network.name
}
# Create a private subnet

resource "google_compute_subnetwork" "private-subnet" {
  name          = "private-subnet-0011"
  ip_cidr_range = "10.10.0.0/20"
  network       = google_compute_network.vpc_network.name
  region        = "europe-north1"
}

## For creating NAT , Router is required so will create Router 1st
## Create Cloud Router

resource "google_compute_router" "router" {
  project = "pranshu-001"
  name    = "router-for-nat-001"
  network = google_compute_network.vpc_network.name
  region  = "europe-north1"
}

## Create NAT
resource "google_compute_router_nat" "nat" {
  name                               = "nat-001"
  router                             = google_compute_router.router.name
  region                             = "europe-north1"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  icmp_idle_timeout_sec              = 60
}
