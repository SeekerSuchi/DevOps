# Exercise 5: Docker Security with AppArmor and Python

## 🎯 Objective

Understand how to secure Docker containers using AppArmor profiles with Python for enforcement.
Apply AppArmor profiles using the Docker SDK for Python and test restricted actions within the container.

---

## 🏗️ Scenario

A Python Flask application is containerized and secured using Docker's AppArmor integration.
The AppArmor profile restricts access to sensitive directories and prevents unauthorized actions
such as executing binaries or reading restricted files. The Docker SDK for Python is used to
apply and verify the profiles programmatically.

---

## 📂 Files

```tree
exercise5/
├── app.py                    # Simple Flask application (port 5000)
├── Dockerfile                # Container build definition
├── requirements.txt          # Python dependencies (flask, docker)
├── my-apparmor-profile       # AppArmor profile restricting sensitive access
├── apply_apparmor.py         # Docker SDK script to build & run with AppArmor
├── test_restricted_actions.py # Script to test AppArmor-restricted actions
└── README.md                 # This file
```

---

## 🚀 Steps

### Task 1: Write a Basic Python Flask Application

File: `app.py` — a simple Flask app that serves a message on port 5000.

---

### Task 2: Containerize the Flask Application Using a Dockerfile

Build the Docker image:

```bash
docker build -t flask-apparmor .
```

**Output:**
```
Sending build context to Docker daemon  3.072kB
Step 1/5 : FROM python:3.8-slim
 ---> e83d9d28b2f6
Step 2/5 : WORKDIR /app
 ---> Using cache
 ---> 2c4979d5c6f3
Step 3/5 : COPY . /app
 ---> 91d94a789d7a
Step 4/5 : RUN pip install flask
 ---> Running in 7fd028e9370d
...
Successfully built flask-apparmor
```

---

### Task 3: Create and Apply AppArmor Profile

File: `my-apparmor-profile`

The profile is stored at `/etc/apparmor.d/my-apparmor-profile` on Linux hosts.

**a. Install AppArmor utilities (Ubuntu/Debian):**

```bash
sudo apt-get update
sudo apt-get install apparmor-utils
```

**b. Copy and load the profile:**

```bash
sudo cp my-apparmor-profile /etc/apparmor.d/my-apparmor-profile
sudo apparmor_parser -r /etc/apparmor.d/my-apparmor-profile
```

**c. Run the container with the profile applied:**

```bash
docker run --security-opt="apparmor=my-apparmor-profile" -p 5000:5000 flask-apparmor
```

**Profile restrictions enforced:**

| Rule | Effect |
| :--- | :--- |
| `deny /etc/** r` | Blocks reading sensitive config files (e.g. `/etc/passwd`) |
| `deny /var/** rw` | Blocks read/write to `/var` (logs, runtime data) |
| `deny /bin/** rmix` | Prevents execution of system binaries in `/bin` |
| `deny /usr/bin/** rmix` | Prevents execution of binaries in `/usr/bin` |
| `deny capability sys_admin` | Blocks privileged system administration operations |
| `capability net_bind_service` | Allows binding to port 5000 |

---

### Task 4: Use Docker SDK for Python to Apply AppArmor Profile

Install the Docker SDK:

```bash
pip install docker
```

Run the script:

```bash
python apply_apparmor.py
```

**Expected Output:**
```
Container started: f8c2a7f9b9b8
AppArmor profile applied: ['apparmor=my-apparmor-profile']
```

---

### Task 5: Test Restricted Actions

Run the test script:

```bash
python test_restricted_actions.py
```

**Expected Output:**
```
Attempt to read /etc/passwd: Exit Code 1, Output: 
Attempt to execute /bin/bash: Exit Code 126, Output: 
```

> Exit Code `1` for `/etc/passwd` — permission denied by AppArmor.  
> Exit Code `126` for `/bin/bash` — execution blocked by AppArmor (`rmix` denial).

---

## ❓ Q&A

**Q1. What is AppArmor and how does it work with Docker?**
> AppArmor (Application Armor) is a Linux kernel security module that enforces per-program security policies (profiles). Docker supports AppArmor natively — you can attach a profile to a container via `--security-opt="apparmor=<profile-name>"`, and the kernel enforces the profile's rules for every process inside the container.

**Q2. What does the `deny /etc/** r` rule do?**
> It prevents any process inside the container from reading files under `/etc/`, blocking access to sensitive configuration files like `/etc/passwd`, `/etc/shadow`, and `/etc/hosts`.

**Q3. What is the difference between `r`, `w`, `x`, and `m` in AppArmor rules?**
> - `r` — read access  
> - `w` — write access  
> - `x` — execute access  
> - `m` — memory-map as executable (used with shared libraries)  
> - `i` — inherit the profile on exec  
> The combination `rmix` in deny rules blocks reading, memory-mapping, and executing binaries.

**Q4. Why use the Docker SDK for Python instead of the CLI?**
> The Docker SDK enables programmatic, repeatable container management within Python applications or CI/CD pipelines — you can build images, run containers with specific security options, inspect configuration, and stop containers all from a single script without shell scripting.

**Q5. What is the purpose of `capability net_bind_service` in the profile?**
> It explicitly allows the Flask process to bind to a privileged or well-known port (ports below 1024 typically require this capability). Without it, the app would fail to start on restricted ports. Port 5000 is above 1024 but the capability is included as a best-practice allowance.
