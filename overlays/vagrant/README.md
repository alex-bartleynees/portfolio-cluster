# Vagrant Overlay for Local Testing

This Kustomize overlay adapts the production Kubernetes configuration for local Vagrant testing.

## What This Overlay Does

### 1. **MetalLB IP Address Pool**
- **Production**: Uses public IP `51.161.130.194/32`
- **Vagrant**: Uses private network range `192.168.56.200-192.168.56.250`

### 2. **SSL Certificates**
- **Production**: Let's Encrypt with HTTP-01 ACME challenge
- **Vagrant**: Self-signed certificates (no public domain validation needed)

### 3. **Domain Names**
- **Production**: `alexbartleynees.com` and subdomains
- **Vagrant**: `*.192.168.56.10.nip.io` (automatically resolves to 192.168.56.10)

#### Service URLs in Vagrant:
- Portfolio Site: `http://portfolio.192.168.56.10.nip.io`
- Product Feedback API: `http://api.192.168.56.10.nip.io`
- Product Feedback App: `http://app.192.168.56.10.nip.io`
- ArgoCD: `http://argocd.192.168.56.10.nip.io`
- Grafana: `http://grafana.192.168.56.10.nip.io`
- Redis Proxy: `http://redis-api.192.168.56.10.nip.io`

### 4. **Storage Requests**
Reduced for Vagrant VM disk constraints (100GB total):

| Component | Production | Vagrant |
|-----------|-----------|---------|
| Prometheus | 50Gi | 5Gi |
| Alertmanager | 10Gi | 1Gi |
| Grafana | 10Gi | 2Gi |
| Redis Master | 8Gi | 1Gi |
| Redis Replica | 8Gi | 1Gi |
| Loki | 10Gi | 2Gi |
| **Total** | ~96Gi | ~12Gi |

### 5. **Resource Limits**
Reduced for Vagrant VM specs (4 CPU, 4GB RAM):

| Component | Production Limits | Vagrant Limits |
|-----------|------------------|----------------|
| Jaeger | 1 CPU / 1Gi RAM | 500m CPU / 512Mi RAM |
| Loki | 1 CPU / 1Gi RAM | 500m CPU / 512Mi RAM |

## Usage

### Option 1: Apply Directly with Kustomize
```bash
# From the repository root
kubectl apply -k overlays/vagrant
```

### Option 2: Use with ArgoCD
Update your ArgoCD Application to use the overlay:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root-app
  namespace: argocd
spec:
  source:
    repoURL: https://github.com/alex-bartleynees/portfolio-cluster.git
    targetRevision: HEAD
    path: overlays/vagrant  # Instead of 'components'
```

### Option 3: Ansible Playbook Integration
Update your Ansible playbook to deploy the overlay:

```yaml
- name: Deploy Kubernetes manifests for Vagrant
  ansible.builtin.shell:
    cmd: kubectl apply -k overlays/vagrant
    chdir: /path/to/portfolio-cluster
```

## Testing the Overlay

### 1. Start Vagrant VM
```bash
cd bootstrap/vps
vagrant up
```

### 2. Deploy with Vagrant Overlay
```bash
# From repository root
kubectl apply -k overlays/vagrant
```

### 3. Verify Deployments
```bash
# Check all pods
kubectl get pods -A

# Check ingresses with new domains
kubectl get ingress -A

# Check MetalLB IP assignment
kubectl get svc -n ingress-nginx
```

### 4. Access Services
Add to your `/etc/hosts` (optional, nip.io handles DNS):
```
192.168.56.10 argocd.192.168.56.10.nip.io
192.168.56.10 grafana.192.168.56.10.nip.io
192.168.56.10 portfolio.192.168.56.10.nip.io
```

Or just use the nip.io domains directly in your browser:
- http://argocd.192.168.56.10.nip.io
- http://grafana.192.168.56.10.nip.io

## Disabling Resource-Intensive Services

For minimal testing, you can disable non-essential services by uncommenting the `patchesStrategicMerge` section in `kustomization.yaml`:

Services that can be disabled:
- Jellyfin (media server)
- Jellyseer (media requests)
- Immich (photo management)
- Obsidian LiveSync
- Seafiles (file sync)
- LibreOffice Online

This will further reduce resource usage on your Vagrant VM.

## Troubleshooting

### Pods stuck in Pending
Check PVC status:
```bash
kubectl get pvc -A
```
Ensure storage class is available:
```bash
kubectl get storageclass
```

### MetalLB not assigning IPs
Check MetalLB pods:
```bash
kubectl get pods -n metallb-system
kubectl logs -n metallb-system -l app=metallb
```

### Certificate issues
Self-signed certs will show browser warnings - this is expected. Accept the certificate to proceed.

### Out of memory
Reduce replica counts or disable more services in the kustomization.yaml.

## Reverting to Production

To deploy production configuration:
```bash
kubectl apply -k components
```

Or update ArgoCD Application path back to `components`.
