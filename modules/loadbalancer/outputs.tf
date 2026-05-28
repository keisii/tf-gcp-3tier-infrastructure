output "lb_public_ip" {
  description = "로드밸런서의 공인 IP 주소"
  value       = google_compute_global_address.lb_static_ip.address
}

output "web_health_check_id" {
  description = "Web 헬스체크 ID"
  value       = google_compute_health_check.web_health_check.id
}

output "app_health_check_id" {
  description = "App 헬스체크 ID"
  value       = google_compute_health_check.app_health_check.id
}
