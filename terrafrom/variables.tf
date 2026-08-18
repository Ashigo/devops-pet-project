variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro" # afterwards change to t3.small
}

variable "project_name" {
  description = "Prefix used to tag/name all resources, keeps this lab identifiable and easy to filter/destroy"
  type        = string
  default     = "kubeadm-lab"
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH (22) into the nodes. Defaults to auto-detecting the caller's public IP/32 via ifconfig.me; override to pin it explicitly."
  type        = string
  default     = null
}

variable "node_names" {
  type    = list(string)
  default = ["control-plane", "worker-1", "worker-2"]
}

# Static private IPs inside public_subnet_cidr (10.0.1.0/24), mirroring the
# predictability of the Vagrant lab's 192.168.56.0/24 private network.
variable "node_private_ips" {
  description = "Private IPs assigned to each node, in the same order as node_names"
  type        = list(string)
  default     = ["10.0.1.10", "10.0.1.11", "10.0.1.12"]
}
