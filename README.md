# Azure Infrastructure Terraform - Home Lab

This repository contains **Terraform IaC** to deploy a secure basic Azure environment for my home lab.

## Architecture
- Resource Group
- Virtual Network + Subnet
- Network Security Group (SSH only)
- Static Public IP
- Linux Virtual Machine (Ubuntu 22.04 with Docker)

## Technologies Used
- **Terraform** ~> 1.5
- **AzureRM Provider** ~> 4.0
- Ubuntu 22.04 LTS

## How to Deploy

```bash
# Clone the repository
git clone https://github.com/javierafloresgarcia20-png/azure-infra-terraform.git
cd azure-infra-terraform

# Copy example variables
cp terraform.tfvars.example terraform.tfvars   # Then edit if needed

# Initialize and deploy
terraform init
terraform plan
terraform apply
