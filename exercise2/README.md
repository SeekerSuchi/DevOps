# Exercise 2: Deploy a Flask App on Minikube Using kubectl and YAML

## 🎯 Objective
Learn Kubernetes basics using Minikube to set up a single-node cluster and deploy Python applications.  
This exercise involves containerizing and deploying a Flask web application using Minikube, managing Kubernetes Deployments, setting image pull policies, and exposing services with NodePort.

---

## 📚 Prerequisites
- [The Illustrated Children’s Guide to Kubernetes](https://www.cncf.io/phippy/the-childrens-illustrated-guide-to-kubernetes/)
- [Video: The Children's Illustrated Guide to Kubernetes](https://www.youtube.com/watch?v=3I9PkvZ80BQ)
- [Install Minikube](https://minikube.sigs.k8s.io/docs/)
- Follow the Minikube installation guide for your operating system (Windows / Linux / macOS).
- **Watch:** [Origins of Kubernetes with Tim Hockin of Google](https://www.youtube.com/watch?v=xSztxKexDXM)
- **Watch:** [Keynote: A Vision for Vision (in the era of AI) - Kubernetes in Its Second Decade - Tim Hockin](https://www.youtube.com/watch?v=WqeShpaztZY)

---

## ⚡ Minikube Cheat Sheet - Frequently Used Commands

```bash
# 1. Starting and Stopping Minikube
minikube start                              # Start Minikube with default settings
minikube start --kubernetes-version=v1.21.2  # Start with a specific Kubernetes version
minikube stop                               # Stop Minikube without deleting
minikube delete                             # Delete Minikube cluster

# 2. Checking Status and Information
minikube status                             # Check Minikube status
kubectl cluster-info                        # Display cluster information

# 3. Accessing Services
minikube service <service-name>             # Open specified service in browser
minikube service list                       # List URLs of all services
minikube tunnel                             # Create a network tunnel to access LoadBalancer services

# 4. Docker with Minikube
eval $(minikube docker-env)                 # Use Minikube's Docker daemon (Bash/Zsh)
minikube -p minikube docker-env --shell powershell | Invoke-Expression # PowerShell
docker build -t my-image .                  # Build image directly in Minikube
minikube image load my-image                # Load a local image into Minikube

# 5. Debugging and Logs
minikube logs                               # View Minikube logs
minikube dashboard                          # Open the Kubernetes dashboard
minikube ssh                                # SSH into the Minikube VM
```

---

## 📂 Project Structure

```tree
exercise2/
├── README.md                  # Comprehensive lab guide & Q&A
├── app.py                     # Flask application source code (port 15000)
├── Dockerfile                 # Docker container build definition
├── requirements.txt           # Python dependency file
├── flask-deployment.yaml      # Combined Deployment & NodePort Service manifest
├── manifests/
│   ├── deployment.yaml        # Standalone Deployment manifest
│   └── service.yaml           # Standalone NodePort Service manifest
└── scripts/
    ├── deploy.sh              # Linux / macOS / WSL automation deployment script
    ├── deploy.ps1             # Windows PowerShell automation deployment script
    ├── cleanup.sh             # Linux / macOS / WSL cleanup script
    └── cleanup.ps1            # Windows PowerShell cleanup script
```

---

## 🛠️ Step-by-Step Implementation

### Step 1: Start Minikube
Start your local single-node Kubernetes cluster:
```bash
minikube start
```

---

### Step 2: Create a Flask Application
Create `app.py`:
```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return "Hello from Flask on Kubernetes!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=15000)
```

---

### Step 3: Create a Dockerfile for Flask Application
Create `Dockerfile`:
```dockerfile
FROM python:3.8-slim
WORKDIR /app
COPY . /app
RUN pip install --no-cache-dir flask
CMD ["python", "app.py"]
```

---

### Step 4: Build the Docker Image with Minikube’s Docker Daemon
Run the following command to see what environment variables need to be set:
```bash
minikube docker-env
```
This set of variable export statements configures your operating system's Docker CLI to use Minikube’s internal Docker daemon instead of your host daemon:

- **Linux / macOS / WSL (Bash/Zsh):**
  ```bash
  eval $(minikube docker-env)
  docker build -t flask-app:latest .
  ```

- **Windows PowerShell:**
  ```powershell
  & minikube -p minikube docker-env --shell powershell | Invoke-Expression
  docker build -t flask-app:latest .
  ```

---

### Step 5: Create a Kubernetes Deployment YAML File

#### Note: About `imagePullPolicy: Never`
Kubernetes provides three image pull policies:
1. **`Always`:** Kubernetes always pulls the image from the remote registry, even if it exists locally.
2. **`IfNotPresent`:** Kubernetes pulls the image only if it doesn't exist locally.
3. **`Never`:** Kubernetes never pulls the image from the registry; it only uses local images.

By setting `imagePullPolicy: Never`, we ensure that Kubernetes uses our local `flask-app:latest` image built directly in Minikube's Docker daemon and does not try to pull from Docker Hub.

**File:** `flask-deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
      - name: flask-app
        image: flask-app:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 15000
```

---

### Step 6: Deploy the Application
Use `kubectl` to apply the YAML file and deploy the Flask application:
```bash
kubectl apply -f flask-deployment.yaml
```

---

### Step 7: Check Deployment Status
Verify that the deployment was created successfully and inspect the replica status:
```bash
kubectl get deployments
```
**Example Output:**
```text
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
flask-app    1/1     1            1           5s
```

---

### Step 8: Verify Pods Created by the Deployment
Check if the deployment successfully started the expected Pods:
```bash
kubectl get pods -l app=flask-app
```
**Example Output:**
```text
NAME                          READY   STATUS    RESTARTS   AGE
flask-app-b8cd75b6f-tpdpr     1/1     Running   0          5s
```

---

### Step 9: Describe the Deployment
Inspect detailed configuration, status conditions, and rollout events:
```bash
kubectl describe deployment flask-app
```

---

### Step 10: View Deployment Logs
Verify that the Flask application is running properly and listening on port 15000:
```bash
kubectl logs -l app=flask-app
```
**Example Output:**
```text
 * Serving Flask app 'app'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:15000
 * Running on http://10.0.0.210:15000
Press CTRL+C to quit
```

---

### Step 11: Check Existing Services
Check services running in the cluster:
```bash
kubectl get services
```
Notice that without a dedicated service, only the internal `kubernetes` ClusterIP service is listed.

---

### Step 12: Attempting Direct Access (Port 15000)
If you try to run:
```bash
curl http://127.0.0.1:15000
```
You will receive:
```text
curl: (7) Failed to connect to 127.0.0.1 port 15000 after 1 ms: Couldn't connect to server
```
**Why this fails:**
1. Minikube runs inside an isolated virtual or containerized environment.
2. The application exposes port 15000 only inside its Pod container, not to the outside host machine.

---

### Step 13: Update Deployment with Service Section to Access Port 15000

Update `flask-deployment.yaml` with a NodePort `Service`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
      - name: flask-app
        image: flask-app:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 15000
---
apiVersion: v1
kind: Service
metadata:
  name: flask-app-service
spec:
  selector:
    app: flask-app
  ports:
  - port: 15000
    targetPort: 15000
  type: NodePort
```

Apply the updated file:
```bash
kubectl apply -f flask-deployment.yaml
```

#### 🔍 Explanation of Service Ports
- **`port` (Service Port):**  
  The port exposed by the Kubernetes Service within the cluster.
- **`targetPort` (Container Port):**  
  The port on which the container application is listening (`15000` in Flask).

**Traffic Flow:**
$$\text{External Request (NodePort/Service Port)} \longrightarrow \text{Kubernetes Service (port: 15000)} \longrightarrow \text{Flask Container (targetPort: 15000)}$$

#### 🌐 Accessing the Application
Run:
```bash
minikube service flask-app-service --url
```
Example Output:
```text
http://127.0.0.1:36157
```

In your browser or terminal, access the generated URL:
```bash
curl http://127.0.0.1:36157
```
**Response:**
```text
Hello from Flask on Kubernetes!
```

---

## ❓ Questions & Answers (Exercise Review)

**Q1: What is the purpose of `minikube service flask-app-service --url`?**  
**A1:** To provide the URL (IP and dynamically allocated port) for accessing the `flask-app-service` running in Minikube.

**Q2: What happens when you run `minikube service flask-app-service --url`?**  
**A2:** Minikube checks if the service is running, sets up port forwarding/tunneling if necessary, generates an accessible URL, and displays it in the terminal.

**Q3: Why is `targetPort` used in Kubernetes Service configuration?**  
**A3:** To specify the exact port number on which the container inside the Pod is actively listening for requests.

**Q4: What is the difference between `port` and `targetPort` in Kubernetes Service configuration?**  
**A4:** `port` is the port exposed by the Service to other components or clients, while `targetPort` is the port on the container to which the Service forwards incoming traffic.

**Q5: How do you access a Flask application running in Minikube?**  
**A5:** Use `minikube service <service-name> --url` to get the access URL, or use `minikube service <service-name>` to automatically open it in your default web browser.

**Q6: Why does the terminal need to remain open when using Docker driver on Linux with Minikube?**  
**A6:** Because the Docker driver on Linux relies on a live port-forwarding process running in the background of that terminal session to maintain external reachability from the host to the container network.

**Q7: What is the benefit of using `--url` flag with `minikube service` command?**  
**A7:** It outputs only the direct HTTP endpoint URL without attempting to open an interactive web browser window, making it ideal for scripts and CLI testing (`curl`).

**Q8: What command is used to expose a service in Kubernetes?**  
**A8:** `kubectl expose deployment flask-app --type=NodePort --port=15000` (imperatively) or `kubectl apply -f <service.yaml>` (declaratively).

**Q9: How does Minikube help in local Kubernetes testing?**  
**A9:** Minikube runs a single-node Kubernetes cluster locally inside a VM or container, allowing developers to test production-like deployments, networking, and scaling without needing remote cloud clusters.

**Q10: What is the role of `kubectl` in this setup?**  
**A10:** `kubectl` is the official Kubernetes command-line interface used to communicate with the cluster's API server to deploy, inspect, configure, and manage cluster resources.

---

## 🚀 Quick Automation Scripts

- **Deploy:**
  ```powershell
  # Windows PowerShell
  .\exercise2\scripts\deploy.ps1
  ```
  ```bash
  # Linux / macOS / WSL
  ./exercise2/scripts/deploy.sh
  ```

- **Cleanup:**
  ```powershell
  # Windows PowerShell
  .\exercise2\scripts\cleanup.ps1
  ```
  ```bash
  # Linux / macOS / WSL
  ./exercise2/scripts/cleanup.sh
  ```
