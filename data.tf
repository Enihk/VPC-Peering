# ==============================================================================
# UBUNTU AMI
# ==============================================================================

# Ubuntu 22.04 LTS — ap-southeast-1 (Singapore) — customer-profile
data "aws_ami" "sg" {
  provider    = aws.sg
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Ubuntu 22.04 LTS — ap-southeast-2 (Sydney) — account
data "aws_ami" "au" {
  provider    = aws.au
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Ubuntu 22.04 LTS — ap-northeast-1 (Tokyo) — statement
data "aws_ami" "jp" {
  provider    = aws.jp
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}