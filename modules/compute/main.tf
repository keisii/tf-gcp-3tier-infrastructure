# Web Tier: 외부와 통신하는 웹 서버
resource "google_compute_instance_template" "web_template" {
  name         = "web-server-template"
  machine_type = "e2-micro"

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = var.web_subnet_id
  }

  tags = ["web-server"]

  metadata_startup_script = "sudo apt-get update; sudo apt-get install -y nginx"
}

# Web 관리형 인스턴스 그룹 (MIG)
resource "google_compute_region_instance_group_manager" "web_mig" {
  name               = "web-mig"
  base_instance_name = "web-server"
  region             = "asia-northeast3"
  # target_size        = 2

  version {
    instance_template = google_compute_instance_template.web_template.id
  }

  distribution_policy_zones = ["asia-northeast3-a", "asia-northeast3-b"]

  auto_healing_policies {
    health_check      = var.web_health_check_id
    initial_delay_sec = 120
  }
}

# Web 오토스케일러 리소스
resource "google_compute_region_autoscaler" "web_autoscaler" {
  name   = "web-autoscaler"
  region = "asia-northeast3"
  target = google_compute_region_instance_group_manager.web_mig.id # web_mig에 장착

  autoscaling_policy {
    max_replicas    = 4
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.7
    }
  }
}

# App Tier: 로직을 처리하는 서버 (외부 IP 없음)
resource "google_compute_instance_template" "app_template" {
  name         = "app-server-template"
  machine_type = "e2-micro"

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = var.app_subnet_id 
  }

  tags = ["app-server"]

  metadata_startup_script = <<-EOF
    sudo apt-get update
    sudo apt-get install -y nginx
    sudo sed -i 's/listen 80 default_server;/listen 8080 default_server;/g' /etc/nginx/sites-available/default
    sudo systemctl restart nginx
  EOF
}

# App 관리형 인스턴스 그룹 (MIG)
resource "google_compute_region_instance_group_manager" "app_mig" {
  name               = "app-mig"
  base_instance_name = "app-server"
  region             = "asia-northeast3"
  # target_size        = 2

  version {
    instance_template = google_compute_instance_template.app_template.id
  }

  distribution_policy_zones = ["asia-northeast3-a", "asia-northeast3-b"]

  auto_healing_policies {
    health_check      = var.app_health_check_id
    initial_delay_sec = 120
  }
}

# App 오토스케일러 리소스
resource "google_compute_region_autoscaler" "app_autoscaler" {
  name   = "app-autoscaler"
  region = "asia-northeast3"
  target = google_compute_region_instance_group_manager.app_mig.id # app_mig에 장착

  autoscaling_policy {
    max_replicas    = 4
    min_replicas    = 2
    cooldown_period = 60 

    cpu_utilization {
      target = 0.7
    }
  }
}

# DB Tier
resource "google_compute_instance" "db_server" {
  name         = "db-server"
  machine_type = "e2-micro"
  zone         = "asia-northeast3-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = var.db_subnet_id
  }

  tags         = ["db-server"] 
}
