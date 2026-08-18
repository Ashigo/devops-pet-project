data "http" "my_ip" {
  count = var.ssh_allowed_cidr == null ? 1 : 0
  url   = "https://ipv4.icanhazip.com"
}

locals {
  ssh_cidr = coalesce(
    var.ssh_allowed_cidr,
    "${chomp(data.http.my_ip[0].response_body)}/32"
  )
}

resource "aws_security_group" "cluster" {
  name        = "${var.project_name}-sg"
  description = "kubeadm-lab: Allow SSH from operator IP + full egress"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_in" {
  security_group_id = aws_security_group.cluster.id
  cidr_ipv4         = local.ssh_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.cluster.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "kube_apiserver" {
  security_group_id            = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.cluster.id
  from_port                    = 6443
  to_port                      = 6443
  ip_protocol                  = "tcp"
  description                  = "kube-apiserver"
}

resource "aws_vpc_security_group_ingress_rule" "etcd" {
  security_group_id            = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.cluster.id
  from_port                    = 2379
  to_port                      = 2380
  ip_protocol                  = "tcp"
  description                  = "etcd client + peer"
}

resource "aws_vpc_security_group_ingress_rule" "kubelet" {
  security_group_id            = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.cluster.id
  from_port                    = 10250
  to_port                      = 10250
  ip_protocol                  = "tcp"
  description                  = "kubelet API"
}

resource "aws_vpc_security_group_ingress_rule" "kube_scheduler" {
  security_group_id            = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.cluster.id
  from_port                    = 10259
  to_port                      = 10259
  ip_protocol                  = "tcp"
  description                  = "kube-scheduler"
}

resource "aws_vpc_security_group_ingress_rule" "kube_controller_manager" {
  security_group_id            = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.cluster.id
  from_port                    = 10257
  to_port                      = 10257
  ip_protocol                  = "tcp"
  description                  = "kube-controller-manager"
}

resource "aws_vpc_security_group_ingress_rule" "flannel_vxlan" {
  security_group_id            = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.cluster.id
  from_port                    = 8472
  to_port                      = 8472
  ip_protocol                  = "udp"
  description                  = "Flannel VXLAN overlay"
}
