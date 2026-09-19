# Exercise 4: Docker Networking with Multiple Containers

## 🎯 Objective

Understand Docker networking concepts and configure a multi-container application.

---

## 🏗️ Scenario

Develop a web application with:

| Container | Role |
| :--- | :--- |
| **Container 1** | Python Flask web server |
| **Container 2** | MySQL database |
| **Container 3** | Redis cache |

---

## 📂 Files

```tree
exercise4/
├── app.py              # Simple Flask REST API (/about endpoint)
├── requirements.txt    # Python dependencies (Flask==2.0.1)
├── Dockerfile          # Container build definition
└── README.md           # This file
```

---

## 🚀 Steps

### Task 1: Create a Bridge Network

```bash
docker network create --driver bridge my-bridge-net
```

**Output:**
```
87c23b491f5994c74e497f4f4f4f4f4f4f4f4
```

---

### Task 2: Verify the Network

```bash
docker network ls
```

**Output:**
```
NETWORK ID     NAME            DRIVER    SCOPE
87c23b491f59   my-bridge-net   bridge    local
```

---

### Task 3: Inspect the Network

```bash
docker network inspect my-bridge-net
```

**Output:**
```json
[
    {
        "Name": "my-bridge-net",
        "Id": "87c23b491f5994c74e497f4f4f4f4f4f4f4f4",
        "Created": "2023-02-20T14:30:45.421654Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
```

---

### Task 4: Build the Flask Image & Launch Containers

Build the Flask image:

```bash
docker build -t flask-api .
```

**Output:**
```
Sending build context to Docker daemon  3.584kB
Step 1/5 : FROM python:3.9-slim
...
Successfully built flask-api
```

Launch all three containers on the bridge network (`-d` = detached/background mode):

```bash
docker run -d --name mysql --net=my-bridge-net mysql:latest
docker run -d --name redis --net=my-bridge-net redis:latest
docker run -d --name flask --net=my-bridge-net -p 5001:5001 flask-api
```

**Output:**
```
mysql container ID: 237c941f4f4f
redis container ID: 456c941f4f4f
flask container ID: 678c941f4f4f
```

---

### Task 5: Test Connectivity Between Containers

Exec into the Flask container:

```bash
docker exec -it flask bash
```

Ping the MySQL container by name:

```bash
ping mysql
```

**Output:**
```
PING mysql (172.18.0.2) 56(84) bytes of data.
64 bytes from mysql (172.18.0.2): icmp_seq=1 ttl=64 time=0.078 ms
```

Ping the Redis container by name:

```bash
ping redis
```

**Output:**
```
PING redis (172.18.0.3) 56(84) bytes of data.
64 bytes from redis (172.18.0.3): icmp_seq=1 ttl=64 time=0.078 ms
```

> Containers on the same bridge network can reach each other using their **container names** as hostnames — Docker's built-in DNS handles the resolution.

---

### Task 6: Clean Up

Stop and remove all containers:

```bash
docker stop mysql redis flask && docker rm mysql redis flask
```

Remove the custom network:

```bash
docker network rm my-bridge-net
```

**Output:**
```
my-bridge-net
```

---

## ❓ Q&A

**Q1. What is the purpose of the `--net` flag in `docker run`?**
> It specifies which network the container should connect to. Containers on the same network can communicate with each other.

**Q2. How do containers communicate with each other on the same network?**
> Containers communicate using their **container names** or **IP addresses**. Docker provides a built-in DNS resolver so container names resolve automatically within the same network.

**Q3. What is the difference between a bridge network and a host network?**
> - **Bridge Network**: Containers live in a private, isolated network namespace. They communicate through a virtual bridge — like being in a **private room with a door** to the outside.
> - **Host Network**: Containers share the host's network stack directly — like being in the **same room as the host**, with no isolation.

**Q4. How can you expose a container's port to the host machine?**
> Use the `-p` flag: `-p <host-port>:<container-port>`. For example, `-p 5001:5001` maps the container's port 5001 to the host's port 5001, making the service accessible from outside Docker.
