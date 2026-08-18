output "node_public_ips" {
  description = "Map of node name -> public IP"
  value = {
    for idx, name in var.node_names :
    name => aws_instance.node[idx].public_ip
  }
}

output "node_private_ips" {
  description = "Map of node name -> private IP"
  value = {
    for idx, name in var.node_names :
    name => aws_instance.node[idx].private_ip
  }
}

output "control_plane_public_ip" {
  description = "control-plane public IP"
  value       = aws_instance.node[0].public_ip
}

output "ssh_private_key_path" {
  description = "Local path to the generated SSG private key"
  value       = local_file.private_key.filename
}

output "ssh_allowed_cidr" {
  description = "CIDR that is allowed for SSH (auto-detected or overriden)"
  value       = local.ssh_cidr
}

output "ssh_command_example" {
  description = "Example SSH command to reach the control-plane node"
  value       = "ssh -i ${local_file.private_key.filename} ubuntu@${aws_instance.node[0].public_ip}"
}
