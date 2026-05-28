variable "vpc_id" {
  type        = string
  description = "VPC의 ID 값"
}

variable "vpc_name" {
  type        = string
  description = "VPC의 이름"
}

variable "web_subnet_id" {
  type        = string
  description = "Web 서브넷의 ID"
}

variable "app_subnet_id" {
  type        = string
  description = "App 서브넷의 ID"
}

variable "web_mig_instance_group" {
  type        = string
  description = "Compute 모듈에서 생성된 Web MIG의 instance_group 주소"
}

variable "app_mig_instance_group" {
  type        = string
  description = "Compute 모듈에서 생성된 App MIG의 instance_group 주소"
}
