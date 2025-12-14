# ECS Fargate CI/CD with Terraform & GitHub Actions 🚀

This project demonstrates a **production-grade DevOps workflow** where cloud infrastructure is provisioned using **Terraform** and application delivery is automated using **GitHub Actions** with **OIDC-based authentication** (no long-lived AWS access keys).

The setup follows real-world best practices used by DevOps teams.

---

## 🧱 Architecture Overview

**High-level flow:**

1. Developer pushes code to GitHub
2. GitHub Actions pipeline triggers
3. Docker image is built and tagged (commit-based)
4. Image is pushed to Amazon ECR
5. ECS task definition revision is created (image updated only)
6. ECS service performs a rolling deployment
7. Traffic flows via ALB → ECS tasks (Fargate)

---

## 🏗 Infrastructure (Terraform)

Provisioned using Terraform:

### Networking

* VPC (`10.0.0.0/16`)
* 2 Public Subnets (ALB)
* 2 Private Subnets (ECS Fargate tasks)
* Internet Gateway
* NAT Gateway
* Route Tables (public & private)

### Load Balancing

* Application Load Balancer (Public)
* HTTPS (443) with ACM certificate
* HTTP → HTTPS redirect
* Target Group:

  * Protocol: HTTP
  * Port: 5000
  * Target type: IP
  * Health check: `/`

### Compute

* ECS Cluster (Fargate)
* ECS Task Definition
* ECS Service
* Auto Scaling (CPU-based)

### Security

* Security Groups (ALB + ECS)
* IAM Roles:

  * ECS Task Execution Role
  * GitHub Actions OIDC Role

---

## 🔐 Authentication (OIDC – Best Practice)

GitHub Actions authenticates to AWS using **OIDC**, eliminating the need for storing AWS access keys.

* IAM OIDC Provider: `token.actions.githubusercontent.com`
* Trust policy restricted to:

  * Repository
  * Branch
* Permissions limited to:

  * ECR push
  * ECS task/service update

---

## 🔄 CI/CD Pipeline (GitHub Actions)

### Pipeline Capabilities

* Uses OIDC to assume AWS IAM role
* Builds Docker image
* Tags image using:

  ```
  <commit-sha>-<date>
  ```
* Pushes image to Amazon ECR
* Fetches existing ECS task definition
* Updates **only the image field**
* Registers a new task definition revision
* Updates ECS service (rolling deployment)

### Why this approach?

✅ Terraform manages infrastructure

✅ CI/CD manages deployments

✅ No Terraform re-apply on every release

✅ Matches real production workflows

---

## 📂 Repository Structure

```
.
├── terraform/
│   ├── vpc.tf
│   ├── alb.tf
│   ├── ecs.tf
│   ├── iam.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── main.tf
│
├── docker/
│   └── Dockerfile
│
├── app/
│   └── application source code
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
└── README.md
```

---

## 🌐 Traffic Flow

```
User
 ↓
Domain (DNS)
 ↓
ALB (Public Subnet)
 ↓
Target Group (HTTP :5000)
 ↓
ECS Fargate Tasks (Private Subnet)
```

Outbound traffic from ECS (e.g., ECR pulls) flows via **NAT Gateway**.

---

## 🧪 Deployment Strategy

* Zero-downtime rolling deployments
* ALB health checks ensure only healthy tasks receive traffic
* Old tasks are drained gracefully

---

## 💡 Key Learnings

* How real DevOps teams separate **infra** and **deployments**
* Secure CI/CD with OIDC
* ECS task definition versioning
* ALB → ECS networking model
* Terraform project structuring

---

## 🚀 Why This Project Matters

This project is **not a demo-only setup**. It reflects:

* Real-world AWS architecture
* Production CI/CD patterns
* Security best practices
* Scalable infrastructure design

Perfect for:

* DevOps portfolios
* Technical interviews
* LinkedIn project showcase

---

## 📌 Future Enhancements

* Add CloudFront in front of ALB
* Blue/Green deployments
* Terraform remote backend
* Monitoring with CloudWatch / Prometheus
* Secrets management via AWS Secrets Manager

---

## 👨‍💻 Author

Built by **Yogesh Kumar**

If you found this useful, feel free to ⭐ the repo and connect on LinkedIn.

