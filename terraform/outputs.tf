output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "master_public_ip" {
  description = "Kubernetes master public IP"
  value       = aws_instance.master.public_ip
}

output "worker_public_ip" {
  description = "Kubernetes worker public IP"
  value       = aws_instance.worker.public_ip
}

output "master_private_ip" {
  description = "Kubernetes master private IP"
  value       = aws_instance.master.private_ip
}

output "worker_private_ip" {
  description = "Kubernetes worker private IP"
  value       = aws_instance.worker.private_ip
}
