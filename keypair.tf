# Generate one ED25519 key — reused across all 3 regions
resource "tls_private_key" "fsvc_keypair" {
  algorithm = "ED25519"
}

locals {
  private_key_filename = "${var.prefix}-ssh-key.pem"
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.fsvc_keypair.private_key_openssh
  filename        = local.private_key_filename
  file_permission = "0400"
}

# Register in ap-southeast-1 — customer-profile
resource "aws_key_pair" "fsvc_keypair" {
  provider   = aws.sg
  key_name   = local.private_key_filename
  public_key = tls_private_key.fsvc_keypair.public_key_openssh
}

# Register in ap-southeast-2 — account
resource "aws_key_pair" "fsvc_keypair_au" {
  provider   = aws.au
  key_name   = local.private_key_filename
  public_key = tls_private_key.fsvc_keypair.public_key_openssh
}

# Register in ap-northeast-1 — statement
resource "aws_key_pair" "fsvc_keypair_jp" {
  provider   = aws.jp
  key_name   = local.private_key_filename
  public_key = tls_private_key.fsvc_keypair.public_key_openssh
}