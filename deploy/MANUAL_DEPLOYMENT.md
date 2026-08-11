# GCP Backend Manual & Automated Deployment Guide

This guide details how to manually deploy the FluentSoul **Backend (FastAPI)** and **Database (Cloud SQL / Docker Postgres)** onto a **Google Cloud Platform (GCP) Compute Engine** VM instance, as well as how to configure automated deployments using **GitHub Actions**.

---

## Architecture Overview

- **Backend Service** (`port 8000` / `port 80`): FastAPI application running Uvicorn with auto database migration via Alembic on container startup.
- **Database**:
  - **Option A (Cloud SQL - Recommended)**: Managed GCP PostgreSQL instance.
  - **Option B (VM Containerized DB)**: PostgreSQL 16 Docker container running on the VM with `flountsoul` database.

---

## 1. Manual Deployment Guide (Step-by-Step)

### Step 1: Create GCP Compute Engine VM Instance

Open Google Cloud Shell or run on your local terminal with `gcloud` CLI installed:

```bash
gcloud compute instances create fluentsoul-backend-vm \
    --zone=us-central1-a \
    --machine-type=e2-small \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --tags=http-server,https-server \
    --boot-disk-size=20GB
```

### Step 2: Configure GCP Firewall Rules

Allow HTTP (port 80) and API (port 8000) traffic to the instance:

```bash
gcloud compute firewall-rules create allow-backend-ports \
    --allow=tcp:80,tcp:8000 \
    --target-tags=http-server,https-server
```

### Step 3: SSH into the GCP Instance & Install Docker

```bash
gcloud compute ssh fluentsoul-backend-vm --zone=us-central1-a
```

Once inside the VM:

```bash
# Update and install Docker + Git
sudo apt update && sudo apt install -y docker.io docker-compose-v2 git

# Add current user to Docker group
sudo usermod aG docker $USER
newgrp docker
```

### Step 4: Clone Repository & Create Production `.env`

```bash
git clone https://github.com/Maran1947/soulfluent.git
cd soulfluent

cat << 'EOF' > .env.prod
POSTGRES_USER=fluentsoul
POSTGRES_PASSWORD=your_secure_password_here
POSTGRES_DB=flountsoul
DATABASE_URL=postgresql+asyncpg://fluentsoul:your_secure_password_here@db:5432/flountsoul
SECRET_KEY=your_jwt_secret_key_here
FRONTEND_ORIGIN=*
EOF
```

> **Note for GCP Cloud SQL (Managed DB)**: If using Cloud SQL, replace `@db:5432` in `DATABASE_URL` with your Cloud SQL instance private IP address.

### Step 5: Launch Backend Container Stack

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d --build
```

### Step 6: Verify Deployment

Check running containers:
```bash
docker compose -f docker-compose.prod.yml ps
```

Check logs:
```bash
docker compose -f docker-compose.prod.yml logs -f backend
```

Test backend health check:
```bash
curl http://localhost:8000/health
```

## 2. Automated CI/CD Deployment Trigger

The GitHub Actions pipeline is configured to automatically run **only when a Pull Request is merged into `main` with the `deploy` label attached** (or when manually triggered via `workflow_dispatch`).

### Trigger Workflow Requirements:
1. Open a Pull Request pointing to `main`.
2. Add the **`deploy`** label to the PR on GitHub.
3. Merge the PR.

---

## 3. GitHub Actions Secrets Configuration

Set up the following secrets in your GitHub repository under `Settings > Secrets and variables > Actions`:

| Secret Name | Description / Example Value |
|---|---|
| `GCP_VM_IP` | Public IP of your GCP Compute Engine VM (e.g. `34.123.45.67`) |
| `GCP_VM_USERNAME` | SSH User on GCP VM (e.g. `ubuntu`) |
| `GCP_SSH_PRIVATE_KEY` | Contents of `~/.ssh/id_rsa` (Private Key corresponding to VM `~/.ssh/authorized_keys`) |
| `POSTGRES_DB` | `flountsoul` |
| `DATABASE_URL` | `postgresql+asyncpg://fluentsoul:password@db:5432/flountsoul` |
| `JWT_SECRET_KEY` | Random secret key for backend authentication JWT tokens |
