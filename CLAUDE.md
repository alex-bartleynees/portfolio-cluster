# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GitOps-based Kubernetes portfolio cluster that uses ArgoCD for continuous deployment, Ansible for infrastructure provisioning, and Kustomize for configuration management. It hosts multiple portfolio applications with comprehensive observability, security, and certificate management.

## Architecture

### Infrastructure Stack
- **GitOps**: ArgoCD manages all deployments from Git
- **Configuration**: Kustomize for Kubernetes manifest templating
- **Provisioning**: Ansible playbooks for infrastructure setup
- **Platform**: Kubernetes cluster (local Vagrant or cloud VPS)

### Key Components
- **Applications**: Portfolio site (React) and Product Feedback API (ASP.NET Core)
- **Ingress**: NGINX with automatic TLS via cert-manager
- **Database**: PostgreSQL with backup/restore capabilities
- **Observability**: Prometheus, Grafana, Loki, Jaeger, OpenTelemetry
- **Secrets**: KSOPS for encrypted secret management

## Common Commands

### Infrastructure Setup
```bash
# Local development
cd bootstrap/vps && vagrant up

# Production deployment
ansible-playbook -i inventory/inventory.ini site.yml --ask-vault-pass

# Individual components
ansible-playbook -i inventory/inventory.ini playbooks/install-kubernetes.yml
ansible-playbook -i inventory/inventory.ini playbooks/argo-cd.yml
```

### ArgoCD Management
```bash
# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode

# Sync applications
kubectl get applications -n argocd
kubectl describe application <app-name> -n argocd
```

### Application Deployment
```bash
# GitOps workflow (recommended)
git add components/
git commit -m "Update configuration"
git push origin main

# Manual deployment
kubectl apply -k components/
```

### Monitoring Access
```bash
# Grafana
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80

# Prometheus
kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090

# Jaeger
kubectl port-forward svc/jaeger-query -n observability 16686:16686
```

### Database Operations
```bash
# Access PostgreSQL
kubectl exec -it deployment/postgres -n database -- psql -U postgres

# Backup/restore
ansible-playbook -i inventory/inventory.ini playbooks/postgres-restore.yml
```

### Secret Management
```bash
# Deploy encrypted secrets
ansible-playbook -i inventory/inventory.ini playbooks/create-ksops-secret.yml

# Secrets are encrypted in components/secrets/secrets.encrypted.yaml
```

## Important File Locations

- `bootstrap/vps/site.yml` - Main Ansible orchestration
- `components/kustomization.yaml` - Kubernetes component management
- `root-app/values.yaml` - ArgoCD root application configuration
- `bootstrap/vps/inventory/inventory.ini` - Infrastructure inventory
- `components/secrets/secrets.encrypted.yaml` - Encrypted secrets via KSOPS

## Development Notes

- All deployments should go through GitOps (ArgoCD) by committing to Git
- Use `kubectl apply -k components/` only for testing/debugging
- Secrets must be encrypted with KSOPS before committing
- Applications pull from external Git repositories and Helm charts
- Infrastructure changes require Ansible playbook execution