# Lab-Safe WordPress Terraform

This repo deploys a **WordPress site on AWS** in a **VocLabs sandbox**:

- VPC with public & private subnets  
- NAT gateway for private subnet internet access  
- RDS MySQL database  
- Bastion host for SSH access  
- Auto Scaling Group (ASG) with Launch Template  
- Application Load Balancer (ALB)  
- WordPress installed via `userdata.sh`

![Architecture Diagram](./diagram.png)

---

### Deployment Steps

1. Set your variables in `terraform.tfvars`
2. Initialize Terraform
```bash
terraform init
# CapstoneRecording
aws project with wordpress
