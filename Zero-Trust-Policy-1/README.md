Kubernetes NetworkPolicy: Default-Deny + DNS + Frontend→Backend (8080)
This repo demonstrates a minimal, reproducible setup of Kubernetes NetworkPolicies that:

Enforce a namespace-wide default deny for ingress and egress.

Allow DNS so workloads can resolve names.

Allow only the frontend pod to reach the backend on TCP 8080, while blocking other ports.

Prerequisites
A Kubernetes cluster with a CNI that implements NetworkPolicy (e.g., Calico, Cilium, Weave Net).

kubectl configured to talk to the cluster.

Quick start
Create namespace and sample pods/services


kubectl create ns zt

# Backend: simple HTTP echo, exposed via Service on 8080
kubectl -n zt run backend \
  --image=hashicorp/http-echo --restart=Never -- -text="ok"
kubectl -n zt expose pod backend --name backend --port 8080 --target-port 5678
kubectl -n zt label pod backend app=backend --overwrite

# Frontend: test client
kubectl -n zt run frontend \
  --image=busybox:1.36 --restart=Never --labels app=frontend -- sleep 600

Apply policies

zt-deny-all.yaml

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: zt-deny-all
  namespace: zt
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  - 
allow-dns.yaml

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: zt
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
      
allow-frontend-to-backend.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: zt
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080

(Optional) Restrict frontend egress strictly to backend:8080

allow-frontend-egress-to-backend.yaml

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-egress-to-backend
  namespace: zt
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 8080
      
Apply all:
kubectl apply -f zt-deny-all.yaml
kubectl apply -f allow-dns.yaml
kubectl apply -f allow-frontend-to-backend.yaml
# optional
kubectl apply -f allow-frontend-egress-to-backend.yaml

Verify resources

kubectl -n zt get pod -L app -o wide
kubectl -n zt get svc -o wide
kubectl -n zt get netpol -o wide

You should see:

Pods: frontend (app=frontend), backend (app=backend)

Service: backend on 8080/TCP with selector app=backend

Policies: zt-deny-all, allow-dns, allow-frontend-to-backend (and optional egress policy)

Tests
Allowed (frontend → backend:8080):
kubectl -n zt exec frontend -- wget -qO- http://backend:8080
# Expected output:
# ok

Blocked (frontend → backend:9090):
kubectl -n zt exec frontend -- wget -qO- http://backend:9090 || echo "blocked"
# Expected: connection error and prints "blocked"


How it works
Default Deny: zt-deny-all selects all pods in the namespace and enables both Ingress and Egress policy types, which isolates every pod by default until an allow rule is added.

DNS Allow: allow-dns permits egress on TCP/UDP 53 so pods can resolve names while remaining otherwise restricted.

Frontend→Backend Ingress Allow: allow-frontend-to-backend applies to pods with app=backend and only allows ingress from pods labeled app=frontend on TCP 8080.

Optional Egress Constrain: allow-frontend-egress-to-backend confines frontend’s egress to backend:8080, making the policy intent symmetric.

NetworkPolicies are additive. The effective rules are the union of all policies that select a given pod. A default deny policy doesn’t “block” other policies; instead, it ensures nothing is allowed unless explicitly permitted by other policies.
