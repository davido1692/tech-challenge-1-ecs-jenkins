output "frontend_alb_dns" {
  value = aws_lb.frontend.dns_name
}

output "backend_alb_dns" {
  value = aws_lb.backend.dns_name
}

output "ecr_frontend_repo" {
  value = aws_ecr_repository.frontend.repository_url
}

output "ecr_backend_repo" {
  value = aws_ecr_repository.backend.repository_url
}
