# Terraform Project Setup

This guide will walk you through the process of installing Terraform and running this project.

## Prerequisites

Before you begin, ensure you have the following:
- A terminal (Linux/Mac) or command prompt (Windows).
- Access to the internet to download Terraform.

## 1. Install Terraform

Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently.

### On macOS

1. **Using Homebrew** (Recommended):
   ```sh
   brew tap hashicorp/tap
   brew install hashicorp/tap/terraform

2. **Verify the installation**
    terraform -v

3. **Initialize Terraform**
    terraform init

