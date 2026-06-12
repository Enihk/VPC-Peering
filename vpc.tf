# ==============================================================================
# 1. REGION: ap-southeast-1 (Customer VPC - No NAT Gateway)
# ==============================================================================

data "aws_availability_zones" "az_sg" {
  provider = aws.sg
  state    = "available"
}

resource "aws_vpc" "vpc_customer" {
  provider             = aws.sg
  cidr_block           = var.customer_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "${var.prefix}-${var.environment}-vpc-customer" }
}

resource "aws_internet_gateway" "igw_customer" {
  provider = aws.sg
  vpc_id   = aws_vpc.vpc_customer.id
  tags     = { Name = "${var.prefix}-${var.environment}-igw-customer" }
}

resource "aws_subnet" "pub_customer" {
  count                   = 3
  provider                = aws.sg
  vpc_id                  = aws_vpc.vpc_customer.id
  cidr_block              = var.customer_public_cidr[count.index]
  availability_zone       = data.aws_availability_zones.az_sg.names[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.prefix}-${var.environment}-pub-customer-${count.index}" }
}

resource "aws_subnet" "priv_customer" {
  count             = 3
  provider          = aws.sg
  vpc_id            = aws_vpc.vpc_customer.id
  cidr_block        = var.customer_private_cidr[count.index]
  availability_zone = data.aws_availability_zones.az_sg.names[count.index]
  tags              = { Name = "${var.prefix}-${var.environment}-priv-customer-${count.index}" }
}

resource "aws_route_table" "pub_rt_customer" {
  provider = aws.sg
  vpc_id   = aws_vpc.vpc_customer.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_customer.id
  }
  tags = { Name = "${var.prefix}-${var.environment}-pub-rt-customer" }
}

resource "aws_route_table" "priv_rt_customer" {
  provider = aws.sg
  vpc_id   = aws_vpc.vpc_customer.id
  tags     = { Name = "${var.prefix}-${var.environment}-priv-rt-customer" }
}

resource "aws_route_table_association" "pub_assoc_customer" {
  count          = 3
  provider       = aws.sg
  subnet_id      = aws_subnet.pub_customer[count.index].id
  route_table_id = aws_route_table.pub_rt_customer.id
}

resource "aws_route_table_association" "priv_assoc_customer" {
  count          = 3
  provider       = aws.sg
  subnet_id      = aws_subnet.priv_customer[count.index].id
  route_table_id = aws_route_table.priv_rt_customer.id
}


# ==============================================================================
# 2. REGION: ap-southeast-2 (Account VPC - Has NAT Gateway)
# ==============================================================================

data "aws_availability_zones" "az_au" {
  provider = aws.au
  state    = "available"
}

resource "aws_vpc" "vpc_account" {
  provider             = aws.au
  cidr_block           = var.account_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "${var.prefix}-${var.environment}-vpc-account" }
}

resource "aws_internet_gateway" "igw_account" {
  provider = aws.au
  vpc_id   = aws_vpc.vpc_account.id
  tags     = { Name = "${var.prefix}-${var.environment}-igw-account" }
}

resource "aws_eip" "nat_eip_account" {
  provider   = aws.au
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw_account]
}

resource "aws_subnet" "pub_account" {
  count                   = 3
  provider                = aws.au
  vpc_id                  = aws_vpc.vpc_account.id
  cidr_block              = var.account_public_cidr[count.index]
  availability_zone       = data.aws_availability_zones.az_au.names[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.prefix}-${var.environment}-pub-account-${count.index}" }
}

resource "aws_nat_gateway" "nat_account" {
  provider      = aws.au
  allocation_id = aws_eip.nat_eip_account.id
  subnet_id     = aws_subnet.pub_account[0].id
  tags          = { Name = "${var.prefix}-${var.environment}-nat-account" }
}

resource "aws_subnet" "priv_account" {
  count             = 3
  provider          = aws.au
  vpc_id            = aws_vpc.vpc_account.id
  cidr_block        = var.account_private_cidr[count.index]
  availability_zone = data.aws_availability_zones.az_au.names[count.index]
  tags              = { Name = "${var.prefix}-${var.environment}-priv-account-${count.index}" }
}

resource "aws_route_table" "pub_rt_account" {
  provider = aws.au
  vpc_id   = aws_vpc.vpc_account.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_account.id
  }
  tags = { Name = "${var.prefix}-${var.environment}-pub-rt-account" }
}

resource "aws_route_table" "priv_rt_account" {
  provider = aws.au
  vpc_id   = aws_vpc.vpc_account.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_account.id
  }
  tags = { Name = "${var.prefix}-${var.environment}-priv-rt-account" }
}

resource "aws_route_table_association" "pub_assoc_account" {
  count          = 3
  provider       = aws.au
  subnet_id      = aws_subnet.pub_account[count.index].id
  route_table_id = aws_route_table.pub_rt_account.id
}

resource "aws_route_table_association" "priv_assoc_account" {
  count          = 3
  provider       = aws.au
  subnet_id      = aws_subnet.priv_account[count.index].id
  route_table_id = aws_route_table.priv_rt_account.id
}


# ==============================================================================
# 3. REGION: ap-northeast-1 (Statement VPC - Has NAT Gateway)
# ==============================================================================

data "aws_availability_zones" "az_jp" {
  provider = aws.jp
  state    = "available"
}

resource "aws_vpc" "vpc_statement" {
  provider             = aws.jp
  cidr_block           = var.statement_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "${var.prefix}-${var.environment}-vpc-statement" }
}

resource "aws_internet_gateway" "igw_statement" {
  provider = aws.jp
  vpc_id   = aws_vpc.vpc_statement.id
  tags     = { Name = "${var.prefix}-${var.environment}-igw-statement" }
}

resource "aws_eip" "nat_eip_statement" {
  provider   = aws.jp
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw_statement]
}

resource "aws_subnet" "pub_statement" {
  count                   = 3
  provider                = aws.jp
  vpc_id                  = aws_vpc.vpc_statement.id
  cidr_block              = var.statement_public_cidr[count.index]
  availability_zone       = data.aws_availability_zones.az_jp.names[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.prefix}-${var.environment}-pub-statement-${count.index}" }
}

resource "aws_nat_gateway" "nat_statement" {
  provider      = aws.jp
  allocation_id = aws_eip.nat_eip_statement.id
  subnet_id     = aws_subnet.pub_statement[0].id
  tags          = { Name = "${var.prefix}-${var.environment}-nat-statement" }
}

resource "aws_subnet" "priv_statement" {
  count             = 3
  provider          = aws.jp
  vpc_id            = aws_vpc.vpc_statement.id
  cidr_block        = var.statement_private_cidr[count.index]
  availability_zone = data.aws_availability_zones.az_jp.names[count.index]
  tags              = { Name = "${var.prefix}-${var.environment}-priv-statement-${count.index}" }
}

resource "aws_route_table" "pub_rt_statement" {
  provider = aws.jp
  vpc_id   = aws_vpc.vpc_statement.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_statement.id
  }
  tags = { Name = "${var.prefix}-${var.environment}-pub-rt-statement" }
}

resource "aws_route_table" "priv_rt_statement" {
  provider = aws.jp
  vpc_id   = aws_vpc.vpc_statement.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_statement.id
  }
  tags = { Name = "${var.prefix}-${var.environment}-priv-rt-statement" }
}

resource "aws_route_table_association" "pub_assoc_statement" {
  count          = 3
  provider       = aws.jp
  subnet_id      = aws_subnet.pub_statement[count.index].id
  route_table_id = aws_route_table.pub_rt_statement.id
}

resource "aws_route_table_association" "priv_assoc_statement" {
  count          = 3
  provider       = aws.jp
  subnet_id      = aws_subnet.priv_statement[count.index].id
  route_table_id = aws_route_table.priv_rt_statement.id
}


# ==============================================================================
# CROSS-REGION VPC PEERING
# ==============================================================================

# Connection A: Customer (ap-southeast-1) <-> Account (ap-southeast-2)
resource "aws_vpc_peering_connection" "customer_to_account" {
  provider    = aws.sg
  vpc_id      = aws_vpc.vpc_customer.id
  peer_vpc_id = aws_vpc.vpc_account.id
  peer_region = var.au
  tags        = { Name = "${var.prefix}-${var.environment}-peer-cus-acc" }
}

resource "aws_vpc_peering_connection_accepter" "account_accepter" {
  provider                  = aws.au
  vpc_peering_connection_id = aws_vpc_peering_connection.customer_to_account.id
  auto_accept               = true
  tags                      = { Name = "${var.prefix}-${var.environment}-peer-account-accepter" }
}

# Connection B: Account (ap-southeast-2) <-> Statement (ap-northeast-1)
resource "aws_vpc_peering_connection" "account_to_statement" {
  provider    = aws.au
  vpc_id      = aws_vpc.vpc_account.id
  peer_vpc_id = aws_vpc.vpc_statement.id
  peer_region = var.jp
  tags        = { Name = "${var.prefix}-${var.environment}-peer-acc-to-sta" }
}

resource "aws_vpc_peering_connection_accepter" "statement_accepter" {
  provider                  = aws.jp
  vpc_peering_connection_id = aws_vpc_peering_connection.account_to_statement.id
  auto_accept               = true
  tags                      = { Name = "${var.prefix}-${var.environment}-peer-sta-accepter" }
}


# ==============================================================================
# CORRECTED CROSS-PEER ROUTE TABLES
# ==============================================================================

# --- CUSTOMER VPC (ap-southeast-1) ---
# Route to Account VPC via Peering
resource "aws_route" "route_cus_to_acc_pub" {
  provider                  = aws.sg
  route_table_id            = aws_route_table.pub_rt_customer.id
  destination_cidr_block    = var.account_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.customer_to_account.id
}
resource "aws_route" "route_cus_to_acc_priv" {
  provider                  = aws.sg
  route_table_id            = aws_route_table.priv_rt_customer.id
  destination_cidr_block    = var.account_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.customer_to_account.id
}


# --- ACCOUNT VPC (ap-southeast-2) ---
# Route back to Customer VPC via Peering
resource "aws_route" "route_acc_to_cus_pub" {
  provider                  = aws.au
  route_table_id            = aws_route_table.pub_rt_account.id
  destination_cidr_block    = var.customer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.customer_to_account.id
}
resource "aws_route" "route_acc_to_cus_priv" {
  provider                  = aws.au
  route_table_id            = aws_route_table.priv_rt_account.id
  destination_cidr_block    = var.customer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.customer_to_account.id
}

# Route forward to Statement VPC via Peering
resource "aws_route" "route_acc_to_sta_pub" {
  provider                  = aws.au
  route_table_id            = aws_route_table.pub_rt_account.id
  destination_cidr_block    = var.statement_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.account_to_statement.id
}
resource "aws_route" "route_acc_to_sta_priv" {
  provider                  = aws.au
  route_table_id            = aws_route_table.priv_rt_account.id
  destination_cidr_block    = var.statement_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.account_to_statement.id
}


# --- STATEMENT VPC (ap-northeast-1) ---
# Route back to Account VPC via Peering
resource "aws_route" "route_sta_to_acc_pub" {
  provider                  = aws.jp
  route_table_id            = aws_route_table.pub_rt_statement.id
  destination_cidr_block    = var.account_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.account_to_statement.id
}
resource "aws_route" "route_sta_to_acc_priv" {
  provider                  = aws.jp
  route_table_id            = aws_route_table.priv_rt_statement.id
  destination_cidr_block    = var.account_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.account_to_statement.id
}