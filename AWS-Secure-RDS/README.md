# AWS Secure RDS Infrastructure (Security-by-Design)

## Project Overview
This project demonstrates a "Security-by-Design" approach to cloud infrastructure using **Terraform (IaC)**. It automates the deployment of a hardened Amazon RDS instance within a custom VPC to ensure data isolation and network security.

## Architecture Highlights
* **VPC Isolation:** All database resources are hosted in **Private Subnets** with no direct internet access.
* **Granular Access Control:** Implements **IAM roles and Security Groups** using the Principle of Least Privilege.
* **Modular Code:** Resources are built using reusable Terraform modules for scalability and consistency.
* **Environment:** Developed using **WSL 2 (Ubuntu)** and **VS Code**.
* **Data Protection:** Enforces AES-256 Storage Encryption via custom AWS KMS Keys with automated rotation enabled. 


## Key AWS Services
* **VPC** (Subnets, Route Tables, NAT Gateways)
* **RDS** (Hardened PostgreSQL/MySQL instance)
* **IAM** (Policies and Roles)

## How to Use
1. Clone the repository.
2. Initialize Terraform: `terraform init`
3. Review the plan: `terraform plan`
4. Apply infrastructure: `terraform apply`
