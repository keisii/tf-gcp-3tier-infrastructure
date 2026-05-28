# VPC 생성 (커스텀 모드)
resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = false
}

# 서브넷 생성 (Web, App, DB)
resource "google_compute_subnetwork" "web_subnet" {
  name          = "web-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "asia-northeast3"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "app_subnet" {
  name          = "app-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = "asia-northeast3"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "db_subnet" {
  name          = "db-subnet"
  ip_cidr_range = "10.0.3.0/24"
  region        = "asia-northeast3"
  network       = google_compute_network.vpc_network.id
}

# 방화벽: 구글 IAP 고정 IP를 통한 SSH 허용
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "allow-iap-ssh"
  network = google_compute_network.vpc_network.name

  source_ranges = ["35.235.240.0/20"] 
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# Cloud Router 생성
resource "google_compute_router" "router" {
  name    = "terraform-router"
  network = google_compute_network.vpc_network.id
  region  = "asia-northeast3"
}

# NAT Gateway 생성
resource "google_compute_router_nat" "nat" {
  name                               = "terraform-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# 방화벽 규칙 (외부 -> web-server)
resource "google_compute_firewall" "allow_web" {
  name    = "allow-web-traffic"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"] 
  target_tags   = ["web-server"] 
}

# 방화벽 규칙 (web-server -> app-server)
resource "google_compute_firewall" "allow_app_internal" {
  name    = "allow-app-internal-traffic"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["8080"] 
  }

  allow {
    protocol = "icmp" 
  }

  source_tags = ["web-server"]
  target_tags = ["app-server"]
}

# 방화벽 규칙 (app-server -> db-server)
resource "google_compute_firewall" "allow_db_internal" {
  name    = "allow-db-internal-traffic"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["3306"] 
  }

  allow {
    protocol = "icmp" 
  }

  source_tags = ["app-server"]
  target_tags = ["db-server"]
}

# Web 서버용 헬스체크 방화벽
resource "google_compute_firewall" "allow_health_check" {
  name    = "allow-health-check"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"] 
  target_tags   = ["web-server"]
}

# App 서버용 헬스체크 방화벽
resource "google_compute_firewall" "allow_app_health_check" {
  name    = "allow-app-health-check"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["app-server"]
}
