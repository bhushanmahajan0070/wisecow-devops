# 🔒 Kubernetes NetworkPolicy Demo: Default-Deny + DNS + Frontend → Backend (8080)

This repository demonstrates a **minimal, reproducible setup** of Kubernetes `NetworkPolicy` to enforce **Zero Trust networking** inside a namespace.  

It covers:  
✅ Namespace-wide **default deny** (Ingress + Egress)  
✅ Allowing **DNS resolution**  
✅ Allowing only **frontend → backend communication on TCP 8080**  
✅ (Optional) Restricting **frontend egress strictly to backend:8080**

---

## 🚀 Prerequisites

- A Kubernetes cluster with a CNI that implements `NetworkPolicy`  
  _(e.g., [Calico](https://projectcalico.docs.tigera.io/), [Cilium](https://cilium.io/), [Weave Net](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/))_
- `kubectl` configured to talk to your cluster

---

## ⚡ Quick Start

### 1️⃣ Create namespace & sample pods/services

```bash
kubectl create ns zt

# Backend: simple HTTP echo, exposed via Service on 8080
kubectl -n zt run backend \
  --image=hashicorp/http-echo --restart=Never -- -text="ok"
kubectl -n zt expose pod backend --name backend --port 8080 --target-port 5678
kubectl -n zt label pod backend app=backend --overwrite

# Frontend: test client
kubectl -n zt run frontend \
  --image=busybox:1.36 --restart=Never --labels app=frontend -- sleep 600
