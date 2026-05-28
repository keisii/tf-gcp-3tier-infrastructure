variable "web_subnet_id" {
  type        = string
  description = "VPC 모듈로부터 전달받을 Web 서브넷 ID"
}

variable "app_subnet_id" {
  type        = string
  description = "VPC 모듈로부터 전달받을 App 서브넷 ID"
}

variable "db_subnet_id" {
  type        = string
  description = "VPC 모듈로부터 전달받을 DB 서브넷 ID"
}

variable "web_health_check_id" {
  type        = string
  description = "Loadbalancer 모듈로부터 전달받을 Web 헬스체크 ID"
}

variable "app_health_check_id" {
  type        = string
  description = "Loadbalancer 모듈로부터 전달받을 App 헬스체크 ID"
}
