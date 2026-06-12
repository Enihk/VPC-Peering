# Different Region VPC Peering

A Terraform project that provisions VPCs in different region in  AWS environment hosting three independent microservices:

* Customer Profile Service (`9091`) (`Singapore Region`)
* Account Service (`9092`) (`Sydney Region`)
* Statement Service (`9093`) (`Tokyo Region`)

Each service is deployed on a dedicated EC2 instance and isolated within its own VPC. Inter-service communication is enabled through VPC Peering while maintaining strict security boundaries using Security Groups and Route Tables.

---

## Architecture Overview

```text
                    Internet
                        │
                        ▼
                Customer Service
                 Port: 9091
             Customer-Profile-VPC
                  10.0.0.0/16
                        │
                        │ VPC Peering
                        ▼
                  Account Service
                    Port: 9092
                   Account-VPC
                   10.1.0.0/16
                        │
                        │ VPC Peering
                        ▼
                 Statement Service
                    Port: 9093
                  Statement-VPC
                  192.168.0.0/16
```

Service communication follows a linear chain:

```text
Customer → Account → Statement
```

No direct communication exists between Customer and Statement services.
Users cannot access Account and Statement Services directly.

---


## VPC Layout

| VPC                  | CIDR Block     | Service           |
| -------------------- | -------------- | ----------------- |
| customer-profile-vpc | 10.0.0.0/16    | Customer Service  |
| account-vpc          | 10.1.0.0/16    | Account Service   |
| statement-vpc        | 192.168.0.0/16  | Statement Service |

---

## Service Ports

| Service          | Port |
| ---------------- | ---- |
| Customer Profile | 9091 |
| Account          | 9092 |
| Statement        | 9093 |

---

## Security Design

### Customer Service

Accepts:

* HTTP requests from Internet
* Responses from Account Service

### Account Service

Accepts:

* Requests from Customer Service
* Responses from Statement Service

### Statement Service

Accepts:

* Requests only from Account Service

This design follows the Principle of Least Privilege by allowing only required traffic between services.

---

## Deployment Workflow

### Initialize Terraform

```bash
terraform init
```

### Validate Configuration

```bash
terraform validate
```

### Review Plan

```bash
terraform plan
```

### Deploy Infrastructure

```bash
terraform apply
```

---

## Project Structure

```text
.
├── data.tf
├── ec2.tf
├── keypair.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars
├── vpc.tf
├── variables.tf
├── scripts/
│   ├── customer-profile.sh
│   ├── account.sh
│   └── statement.sh
└── README.md
```

---

## Key Learning Outcomes

This project demonstrates:

* AWS Networking Fundamentals
* VPC Design
* Route Table Management
* Security Group Design
* VPC Peering
* Infrastructure as Code with Terraform
* Linux Service Management (systemd)
* Microservice Networking Concepts

---

## Challenges Encountered

### Upstream Service Configuration

During deployment, the Customer Service failed to communicate with the Account Service due to an incorrect Terraform variable interpolation in the user-data script.

Issue:

```text
UPSTREAM_URIS=http://${account_private_ip}:9092
```

The variable was not rendered correctly, causing the application to crash when processing requests.

Resolution:

* Corrected variable interpolation
* Confirmed upstream connectivity using curl and journalctl

This troubleshooting process reinforced the importance of validating infrastructure templates and application configuration during automated deployments.

```
```
