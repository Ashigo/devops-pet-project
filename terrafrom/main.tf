provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu_2404" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd*/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "node" {
  count = length(var.node_names)

  ami                    = data.aws_ami.ubuntu_2404.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  private_ip             = var.node_private_ips[count.index]
  vpc_security_group_ids = [aws_security_group.cluster.id]
  key_name               = aws_key_pair.this.key_name

  tags = {
    Name = var.node_names[count.index]
    Role = count.index == 0 ? "control-plane" : "worker"
  }
}
