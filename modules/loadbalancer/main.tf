# 로드밸런서가 사용할 고정 IP 예약
resource "google_compute_global_address" "lb_static_ip" {
  name = "lb-static-ip"
}

# Web 헬스 체크
resource "google_compute_health_check" "web_health_check" {
  name = "web-health-check"
  http_health_check {
    port = 80
  }
}

# web-mig와 로드밸런서 연결
resource "google_compute_backend_service" "web_backend" {
  name                  = "web-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.web_health_check.id]

  # 헬스체크 리소스가 완전히 만들어질 때까지 대기
  depends_on = [google_compute_health_check.web_health_check]

  backend {
    group = var.web_mig_instance_group 
  }
}

# URL 맵 
resource "google_compute_url_map" "web_map" {
  name            = "web-map"
  default_service = google_compute_backend_service.web_backend.id
}

# HTTP 타겟 프록시
resource "google_compute_target_http_proxy" "web_proxy" {
  name    = "web-proxy"
  url_map = google_compute_url_map.web_map.id
}

# 전역 전달 규칙 (최종 외부 입구 설정)
resource "google_compute_global_forwarding_rule" "web_forwarding_rule" {
  name                  = "web-forwarding-rule"
  ip_address            = google_compute_global_address.lb_static_ip.address
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.web_proxy.id
}

# App 헬스 체크 (App 서버 상태 확인)
resource "google_compute_health_check" "app_health_check" {
  name = "app-check"
  tcp_health_check {
    port = 8080 
  }
}

# app-mig와 로드밸런서 연결
resource "google_compute_region_backend_service" "app_backend" {
  name                  = "app-backend"
  region                = "asia-northeast3"
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.app_health_check.id]

  backend {
    group          = var.app_mig_instance_group
    balancing_mode = "CONNECTION"
  }
}

# 내부 전달 규칙 (Internal Load Balancer)
resource "google_compute_forwarding_rule" "app_ilb_forwarding_rule" {
  name                  = "app-ilb-forwarding-rule"
  region                = "asia-northeast3"
  network               = var.vpc_id
  subnetwork            = var.app_subnet_id
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  ports                 = ["8080"]
  backend_service       = google_compute_region_backend_service.app_backend.id
  
  # 고정 IP 하드코딩 대신 주석 처리하거나, 서브넷 대역 내 자동 할당 혹은 변수화 가능
  ip_address            = "10.0.2.100" 
}
