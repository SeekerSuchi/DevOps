# Exercise 3: Scaling Flask App on Single Node using ReplicaSets

## 🛒 Real-Life Tech Use Case: E-commerce Flash Sale

During a flash sale on an e-commerce site (like Flipkart's Big Billion Days or Amazon Prime Day):

- A simple Flask service might normally handle **100 requests per minute**.
- Suddenly, traffic spikes to **10,000 requests per minute**.
- If the app runs on a **single Pod**, it will crash under the load.
- Using **ReplicaSets**, the system can scale out to **10 or 20 Pods** running the same app, distributing requests among them.
- Once the sale ends and traffic returns to normal, Kubernetes can **scale back down** to save resources.

---

## 🎯 Objective

- Understand ReplicaSets and Pods
- Scale Flask App deployment
- Observe pod distribution

---

## 📂 Files

```tree
exercise3/
├── app.py                      # Flash Sale Flask application
├── Dockerfile                  # Container build definition (gunicorn)
├── flashsale-replicaset.yaml   # ReplicaSet + ClusterIP Service manifest
└── README.md                   # This file
```

---

## 🐍 Application Endpoints

| Endpoint  | Method | Description |
| :-------- | :----- | :---------- |
| `/`       | GET    | Welcome message + pod hostname + timestamp |
| `/buy`    | GET    | Simulates a flash sale checkout (random item, optional `?user=` param) |
| `/health` | GET    | Readiness / liveness probe response |

The `served_by_pod` field in `/buy` responses lets you see **which Pod handled each request** — great for observing load distribution.

---

## 🚀 Steps

### Step 1: Clean Up Previous Minikube Cluster

If you already have a running cluster, stop and delete it first:

```bash
minikube stop
minikube delete
```

### Step 2: Start Minikube with a Single Node

```bash
minikube start --nodes=1
```

**Output:**
```
😄  minikube v1.34.0 on Ubuntu 24.04 (amd64)
✨  Automatically selected the docker driver
👍  Starting "minikube" primary control-plane node in "minikube" cluster
🐳  Preparing Kubernetes v1.31.0 on Docker 27.2.0 ...
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

Verify the node:
```bash
kubectl get nodes
```
```
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   42s   v1.31.0
```

---

### Step 3: Build Docker Image Inside Minikube's Docker Daemon

Point your shell to Minikube's Docker environment so the image is available inside the cluster:

```bash
minikube docker-env
eval $(minikube docker-env)      # Linux/macOS
# OR on Windows PowerShell:
# & minikube -p minikube docker-env --shell powershell | Invoke-Expression
```

Build and tag the image:

```bash
docker build -t flashsale:1.0 .
```

> **Tip:** You can also push to Docker Hub and update the image field in `flashsale-replicaset.yaml`:
> ```bash
> docker build -t <your-dockerhub-username>/flashsale:1.0 .
> docker push <your-dockerhub-username>/flashsale:1.0
> ```

---

### Step 4: Apply the ReplicaSet Configuration

```bash
kubectl apply -f flashsale-replicaset.yaml
```

**Output:**
```
replicaset.apps/flashsale-rs created
service/flashsale-svc created
```

---

### Step 5: Verify the ReplicaSet and Pods

```bash
kubectl get rs
```
```
NAME           DESIRED   CURRENT   READY   AGE
flashsale-rs   3         3         3       40s
```

```bash
kubectl get pods
```
```
NAME                   READY   STATUS    RESTARTS   AGE
flashsale-rs-8gbfp     1/1     Running   0          3m35s
flashsale-rs-f4gsl     1/1     Running   0          3m35s
flashsale-rs-nb5kl     1/1     Running   0          3m35s
```

---

### Step 6: Scale the ReplicaSet to 5 Replicas

```bash
kubectl scale rs flashsale-rs --replicas=5
```
```
replicaset.apps/flashsale-rs scaled
```

Verify the scale-up:
```bash
kubectl get rs
```
```
NAME           DESIRED   CURRENT   READY   AGE
flashsale-rs   5         5         5       7m38s
```

```bash
kubectl get pods
```
```
NAME                   READY   STATUS    RESTARTS   AGE
flashsale-rs-4nr6q     1/1     Running   0          7m55s
flashsale-rs-84v7x     1/1     Running   0          7m55s
flashsale-rs-nsmlx     1/1     Running   0          32s
flashsale-rs-rbwr4     1/1     Running   0          7m55s
flashsale-rs-wfbb4     1/1     Running   0          32s
```

---

### Step 7: Delete a Pod and Observe Self-Healing

```bash
kubectl delete pod flashsale-rs-84v7x
```
```
pod "flashsale-rs-84v7x" deleted
```

```bash
kubectl get pods
```
```
NAME                   READY   STATUS    RESTARTS   AGE
flashsale-rs-4nr6q     1/1     Running   0          9m19s
flashsale-rs-hqtm7     1/1     Running   0          51s     ← new replacement pod
flashsale-rs-nsmlx     1/1     Running   0          116s
flashsale-rs-rbwr4     1/1     Running   0          9m19s
flashsale-rs-wfbb4     1/1     Running   0          116s
```

Kubernetes **automatically recreated** the deleted pod to maintain 5 replicas.

---

### Step 8: View Pod Distribution Across Nodes

```bash
kubectl get pods -o wide
```
```
NAME                   READY   STATUS    RESTARTS   AGE     IP            NODE       NOMINATED NODE   READINESS GATES
flashsale-rs-4nr6q     1/1     Running   0          10m     10.244.0.9    minikube   <none>           <none>
flashsale-rs-hqtm7     1/1     Running   0          109s    10.244.0.12   minikube   <none>           <none>
flashsale-rs-nsmlx     1/1     Running   0          2m54s   10.244.0.11   minikube   <none>           <none>
flashsale-rs-rbwr4     1/1     Running   0          10m     10.244.0.7    minikube   <none>           <none>
flashsale-rs-wfbb4     1/1     Running   0          2m54s   10.244.0.10   minikube   <none>           <none>
```

All 5 pods run on the **single `minikube` node**.

---

## 💡 Key Observations & Learnings

| Concept | Explanation |
| :--- | :--- |
| **Pod Distribution** | Each Pod is like an identical worker. Scaling means creating clones of the app. |
| **Resiliency** | If one Pod fails, the ReplicaSet automatically creates another — users don't notice downtime. |
| **Efficiency** | Add Pods when demand spikes, remove them when demand is low. No over-provisioning. |
| **Real-World Scalability** | Exactly how Netflix, YouTube, and Swiggy scale their microservices during peak traffic. |

---

## ❓ Q&A

**Q1. What is the initial number of replicas in the ReplicaSet?**
> **3**

**Q2. How many pods are running after applying the ReplicaSet configuration?**
> **3**

**Q3. What happens when you scale the ReplicaSet to 5 replicas?**
> Kubernetes creates **2 additional pods** to meet the desired count. The ReplicaSet now has 5 running pods.

**Q4. What happens when you delete one pod?**
> Kubernetes **automatically creates a new pod** to replace the deleted one, maintaining the desired 5 replicas.

**Q5. How does Kubernetes maintain the desired number of replicas?**
> Kubernetes continuously monitors running pods vs the desired count. If there's a discrepancy, it creates or deletes pods to converge back to the desired state.

**Q6. How many nodes are running?**
> **1** (`minikube` node acting as both control-plane and worker)

**Q7. Where are the pods running with respect to nodes?**
> All 5 pods run on the **single node** (`minikube`).

---

## 🏋️ Additional Challenges

- Update `flashsale-replicaset.yaml` to use a different image version.
- Convert the ReplicaSet into a **Deployment** for rolling update support.
- Use `kubectl describe rs flashsale-rs` to inspect the ReplicaSet in detail.
- Use `kubectl logs <pod-name>` to view gunicorn access logs.
- Use `kubectl exec -it <pod-name> -- bash` to shell into a pod.
