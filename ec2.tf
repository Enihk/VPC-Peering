# ==============================================================================
# SECURITY GROUPS WITH CROSS-VPC TRUST PIPES
# ==============================================================================

resource "aws_security_group" "sg_customer" {
  provider    = aws.sg
  name        = "${var.prefix}-${var.environment}-customer-sg"
  description = "Public access on 9091 and Admin SSH"
  vpc_id      = aws_vpc.vpc_customer.id

  ingress {
    from_port   = 9091
    to_port     = 9091
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.prefix}-${var.environment}-customer-sg" }
}

resource "aws_security_group" "sg_account" {
  provider    = aws.au
  name        = "${var.prefix}-${var.environment}-account-sg"
  description = "Allow entry from Customer VPC"
  vpc_id      = aws_vpc.vpc_account.id

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = [var.customer_vpc_cidr]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.customer_vpc_cidr] # Allows Bastion hop from Customer
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.prefix}-${var.environment}-account-sg" }
}

resource "aws_security_group" "sg_statement" {
  provider    = aws.jp
  name        = "${var.prefix}-${var.environment}-statement-sg"
  description = "Allow entry from Account VPC"
  vpc_id      = aws_vpc.vpc_statement.id

  ingress {
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = [var.account_vpc_cidr]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.account_vpc_cidr] # Allows Bastion hop from Account
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.prefix}-${var.environment}-statement-sg" }
}


# ==============================================================================
# COMPUTE INSTANCES REFACTORING
# ==============================================================================

resource "aws_instance" "statement" {
  provider               = aws.jp
  ami                    = data.aws_ami.jp.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.priv_statement[0].id
  vpc_security_group_ids = [aws_security_group.sg_statement.id]
  key_name               = aws_key_pair.fsvc_keypair_jp.key_name

  user_data = templatefile("${path.module}/scripts/statement.sh", {})

  depends_on = [
    aws_route.route_sta_to_acc_priv,
    aws_route.route_sta_to_acc_pub
  ]

  tags = { Name = "statement" }
}

resource "aws_instance" "account" {
  provider               = aws.au
  ami                    = data.aws_ami.au.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.priv_account[0].id
  vpc_security_group_ids = [aws_security_group.sg_account.id]
  key_name               = aws_key_pair.fsvc_keypair_au.key_name

  user_data = templatefile("${path.module}/scripts/account.sh", {
    statement_private_ip = aws_instance.statement.private_ip
  })

  depends_on = [
    aws_vpc_peering_connection_accepter.account_accepter,
    aws_vpc_peering_connection_accepter.statement_accepter,
    aws_route.route_acc_to_cus_priv,
    aws_route.route_acc_to_sta_priv
  ]

  tags = { Name = "account" }
}

resource "aws_instance" "customer" {
  provider               = aws.sg
  ami                    = data.aws_ami.sg.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.pub_customer[0].id
  vpc_security_group_ids = [aws_security_group.sg_customer.id]
  key_name               = aws_key_pair.fsvc_keypair.key_name

  user_data = templatefile("${path.module}/scripts/customer-profile.sh", {
    account_private_ip = aws_instance.account.private_ip
  })

  depends_on = [
    aws_route.route_cus_to_acc_priv,
    aws_route.route_cus_to_acc_pub
  ]

  tags = { Name = "customer" }
}