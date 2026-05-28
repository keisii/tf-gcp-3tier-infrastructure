output "web_subnet_id" {
  value = google_compute_subnetwork.web_subnet.id
}

output "app_subnet_id" {
  value = google_compute_subnetwork.app_subnet.id
}

output "db_subnet_id" {
  value = google_compute_subnetwork.db_subnet.id
}

output "vpc_id" {
  value = google_compute_network.vpc_network.id
}

output "vpc_name" {
  value = google_compute_network.vpc_network.name
}
