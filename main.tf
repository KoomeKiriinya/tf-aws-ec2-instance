resource "aws_key_pair" "key_pair" {
  key_name   = var.instance_ssh_priv_key_file
  public_key = file("${var.instance_ssh_key_path}${var.instance_ssh_pub_key_file}")
  tags       = var.instance_key_pair_tags
}

resource "aws_instance" "instance" {
  ami                  = var.instance_ami
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  hibernation          = var.instance_hibernation

  subnet_id                   = var.instance_subnet_id
  vpc_security_group_ids      = var.vpc_sg_ids
  associate_public_ip_address = var.instance_set_public_address

  key_name = aws_key_pair.key_pair.key_name

  tags = var.instance_tags

  root_block_device {
    volume_size = var.instance_volume_size
    volume_type = var.instance_volume_type
    tags        = var.instance_volume_tags
  }

  # ansible ssh keys transfer
  connection {
    type        = "ssh"
    user        = var.ansible_vm_ssh_user
    timeout     = "500s"
    private_key = file("${var.instance_ssh_key_path}${var.ansible_vm_ssh_priv_key_file}")
    host        = var.ansible_vm_instance_ip
  }

  provisioner "file" {
    source      = "${var.instance_ssh_key_path}${var.instance_ssh_priv_key_file}"
    destination = "${var.instance_ssh_key_path}${var.instance_ssh_priv_key_file}"
  }
}