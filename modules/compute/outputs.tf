output "web_mig_instance_group" {
  description = "웹 인스턴스 그룹 주소"
  value       = google_compute_region_instance_group_manager.web_mig.instance_group
}

output "app_mig_instance_group" {
  description = "앱 인스턴스 그룹 주소"
  value       = google_compute_region_instance_group_manager.app_mig.instance_group
}
