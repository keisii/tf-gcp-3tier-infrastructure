output "load_balancer_ip" {
  description = "서비스의 공인 IP"
  value       = module.loadbalancer.lb_public_ip 
}
