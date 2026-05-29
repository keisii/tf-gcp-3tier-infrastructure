# 구글 프로바이더 설정
provider "google" {
  project = var.project_id
  region  = "asia-northeast3"
}

# 네트워크 부품 조립
module "vpc" {
  source = "../../modules/vpc"
}

# 로드밸런서 부품 조립 (VPC의 Output을 가져옴)
module "loadbalancer" {
  source                 = "../../modules/loadbalancer"
  vpc_id                 = module.vpc.vpc_id
  vpc_name               = module.vpc.vpc_name
  web_subnet_id          = module.vpc.web_subnet_id
  app_subnet_id          = module.vpc.app_subnet_id
  web_mig_instance_group = module.compute.web_mig_instance_group
  app_mig_instance_group = module.compute.app_mig_instance_group
}

# 컴퓨팅 부품 조립 (VPC와 로드밸런서의 Output을 모두 가져옴)
module "compute" {
  source              = "../../modules/compute"
  web_subnet_id       = module.vpc.web_subnet_id
  app_subnet_id       = module.vpc.app_subnet_id
  db_subnet_id        = module.vpc.db_subnet_id
  web_health_check_id = module.loadbalancer.web_health_check_id
  app_health_check_id = module.loadbalancer.app_health_check_id
}
