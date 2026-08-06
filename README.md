# DevOps Pet Project

A cross-technology homelab: local kubeadm bootstrap → configuration management → cloud IaC → app + Helm → CI/CD → policy-as-code.

## Repository layout

```
.
├── vagrant-lab/     # local 3-node kubeadm cluster (Vagrant + VirtualBox)
├── ansible/         # roles: kubeadm bootstrap, Jenkins, app deploy
├── terraform/        # cloud provisioning (DigitalOcean)
├── helm-charts/      # custom Helm charts
├── helmfile/          # Helmfile wrapper for multi-release management
├── apps/
│   └── metrics-app/   # Go/Python app reading k8s API for metrics
└── ci/                # Jenkinsfile / pipeline configs, policy-as-code
```

## Architecture

```
                    ┌───────────────────────┐
                    │   Terraform (cloud)   │
                    │   or Vagrant (local)  │
                    └──────────┬────────────┘
                               │ provisions VMs
                               ▼
                    ┌──────────────────────┐
                    │   Ansible roles      │
                    │  kubeadm bootstrap   │
                    └──────────┬───────────┘
                               │
                               ▼
                 ┌────────────────────────────┐
                 │   Kubernetes cluster       │
                 │  (control-plane + workers) │
                 └────────────┬───────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
   ┌───────────────┐    ┌───────────────┐    ┌─────────────────┐
   │ Jenkins       │    │ metrics-app   │    │ Trivy / Kyverno │
   │ (in-cluster)  │    │ (client-go)   │    │ policy checks   │
   └──────┬────────┘    └───────────────┘    └─────────────────┘
          │ builds & deploys via Helm/Helmfile
          ▼
   back into the same cluster
```

## Stages and what each one demonstrates

| Stage | Tools | Pattern demonstrated |
|---|---|---|
| 1. Local k8s lab | Vagrant, VirtualBox, kubeadm, Flannel | Control-plane internals: networking, CNI, sysctl/cgroups |
| 2. Config management | Ansible | Idempotent configuration management (same pattern as Puppet/Chef/Salt) |
| 3. Cloud provisioning | Terraform, DigitalOcean | IaC: state, plan/apply, declarative infra (same pattern as Pulumi/CloudFormation) |
| 4. App + packaging | Go/Python (client-go), Docker, Helm | API-driven control-plane interaction (same pattern as k8s operators); templated release management (same pattern as Kustomize) |
| 5. CI/CD | Jenkins (in-cluster), Kubernetes Plugin | Pipeline-as-code, CI/CD orchestration (same pattern as GitLab CI/GitHub Actions) |
| 6. Policy-as-code | Trivy, Kyverno/OPA | Automated security/compliance gates in the pipeline |
| 7. Release orchestration | Helmfile | Managing multiple Helm releases as one unit |

## Status

Task tracking happens in [GitHub Issues/Projects](../../issues) for this repo. This README's Roadmap section below is the stable high-level view — what's planned and why — not a day-to-day task list.

## Roadmap

### Stage 1 — Local k8s lab (Vagrant) ✅
- [x] Vagrantfile, 3 nodes (control-plane + 2 workers) via VirtualBox
- [x] Manual bootstrap per node: swap off, sysctl/br_netfilter, containerd, kubeadm/kubelet/kubectl
- [x] `kubeadm init` on control-plane
- [x] CNI installed (Flannel)
- [x] `kubeadm join` for both workers
- [x] Verified cross-node pod-to-pod connectivity
- [x] Diagnosed and fixed a real issue: Flannel defaulted to eth0 (NAT) instead of eth1 (private network) → `--iface=eth1`

### Stage 2 — Ansible automation
- [ ] Destroy and rebuild the lab via Ansible, formalizing the manual steps above (incl. `/etc/hosts`, Flannel `--iface` patch)
- [ ] Idempotency checks (skip already-initialized control-plane / already-joined worker)
- [ ] Capture join command via `kubeadm token create --print-join-command`

### Stage 3 — Cloud (Terraform)
- [ ] Provision equivalent VMs on DigitalOcean
- [ ] Apply the same Ansible role to cloud VMs unchanged

### Stage 4 — App + Helm
- [ ] Go/Python app reading k8s API for metrics (client-go, ServiceAccount + RBAC)
- [ ] Dockerfile
- [ ] Helm chart for the app

### Stage 5 — CI/CD
- [ ] Jenkins in-cluster (PVC for JENKINS_HOME)
- [ ] Kubernetes Plugin (build agents as pods)
- [ ] Pipeline: build image → push to registry → deploy to the same cluster
- [ ] Ansible role for deploying simple apps to plain VMs (non-cluster target)

### Stage 6 — Policy-as-code
- [ ] Trivy image scan in the Jenkins pipeline
- [ ] One Kyverno/OPA policy (e.g. deny deploys without resource limits)

### Stage 7 — Helmfile
- [ ] Helmfile wrapper once there are 2-3 charts
