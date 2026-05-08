output "control_node_public_ip" {
  description = "Public IP of the control node: SSH here from your laptop"
  value       = aws_instance.control.public_ip
}

output "managed_node_public_ip" {
  description = "Public IP of the managed node: Minecraft server will be accessible here"
  value       = aws_instance.managed.public_ip
}

output "managed_node_private_ip" {
  description = "Private IP of the managed node: use this in the Ansible inventory"
  value       = aws_instance.managed.private_ip
}

output "ecr_repository_url" {
  description = "ECR repository URL: use this in the GitHub Actions workflow"
  value       = aws_ecr_repository.minecraft.repository_url
}
