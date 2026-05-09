# Azure Infrastructure Terraform - Home Lab

This repository contains Terraform code to deploy basic Azure infrastructure for a home lab environment.

## Architecture
- Resource Group
- Virtual Network + Subnet  
- Network Security Group (SSH allowed)
- Public IP
- Linux Virtual Machine (Ubuntu 22.04)

## Technologies Used
- Terraform ~> 1.5
- AzureRM Provider ~> 4.0
- Ubuntu 22.04 LTS

## How to Deploy

```bash
# 1. Clone the repo
git clone https://github.com/yourusername/azure-infra-terraform.git
cd azure-infra-terraform

# 2. Copy example variables
cp terraform.tfvars.example terraform.tfvars

# 3. Initialize Terraform
terraform init

# 4. Review the plan
terraform plan

# 5. Deploy
terraform apply
