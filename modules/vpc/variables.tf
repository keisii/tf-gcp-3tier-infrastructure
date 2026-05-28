variable "project_id" {
  type        = string
  description = "GCP 프로젝트 ID"
  default     = "project-5595e894-55c8-4921-b9f"
}

variable "region" {
  type        = string
  description = "인프라가 배포될 리전"
  default     = "asia-northeast3"
}
