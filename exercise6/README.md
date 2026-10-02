# Exercise 6: Real-Time Operations Monitoring and Alerting

## 🎯 Objective

Act as a DevOps engineer at **ZAPPTTO** managing a fast-paced delivery service.
Create a monitoring application that provides real-time insights into operational efficiency and delivery performance using Python, Prometheus, Grafana, and Jenkins.

---

## 🏗️ Scenario

A Python script simulates live delivery metrics (total, pending, on-the-way deliveries and average delivery time).
Prometheus scrapes these metrics, Grafana visualizes them on dashboards, alert rules fire when thresholds are breached,
and a Jenkins pipeline automates the whole setup.

---

## 📂 Files

```tree
exercise6/
└── delivery_monitoring/
    ├── delivery_metrics.py   # Python script to simulate and expose metrics
    ├── prometheus.yml        # Prometheus scrape & rule-file configuration
    ├── alert_rules.yml       # Alerting rules (high pending / high avg delivery time)
    └── Jenkinsfile           # Jenkins pipeline script
```

---

## 🚀 Steps

### Pre-requisites

Install the Prometheus Python client:

```bash
pip3 install prometheus-client
```

Ensure Docker, Python 3.10+, Jenkins, Prometheus and Grafana are available.

---

### Step 1: Write the Python Application

File: `delivery_monitoring/delivery_metrics.py`

The script defines four metrics and simulates random delivery data every second, exposing them on **http://localhost:8000/metrics**.

| Metric | Type | Description |
| :--- | :--- | :--- |
| `total_deliveries` | Gauge | Sum of pending + on-the-way + delivered |
| `pending_deliveries` | Gauge | Orders not yet dispatched |
| `on_the_way_deliveries` | Gauge | Orders en route |
| `average_delivery_time` | Summary | Observed delivery time (seconds) |

Run the script:

```bash
python3 delivery_metrics.py
```

**Sample output:**
```
[INFO] Starting the HTTP server on port 8000...
[INFO] HTTP server started. Simulating deliveries...
[DEBUG] Total deliveries: 69
[DEBUG] Pending deliveries: 20
[DEBUG] On-the-way deliveries: 17
[DEBUG] Average delivery time: 28.26 seconds
[INFO] Sleeping for 1 seconds...
```

Verify the metrics endpoint:

```bash
curl http://localhost:8000/metrics
```

**Sample output:**
```
# HELP total_deliveries Total number of deliveries
# TYPE total_deliveries gauge
total_deliveries 69.0
# HELP pending_deliveries Number of pending deliveries
# TYPE pending_deliveries gauge
pending_deliveries 20.0
# HELP on_the_way_deliveries Number of deliveries on the way
# TYPE on_the_way_deliveries gauge
on_the_way_deliveries 17.0
```

> **Note about `/metrics`:**
> - The endpoint is automatically created by `prometheus_client` when `start_http_server` is called.
> - Each metric has a **name**, **description**, and **type** (Counter, Gauge, Histogram, Summary).
> - `start_http_server(8000, addr="0.0.0.0")` binds to all interfaces so Docker containers can reach the host.

---

### Step 2a: Configure Prometheus

File: `delivery_monitoring/prometheus.yml`

Two scrape jobs are defined:

| Job | Target | Purpose |
| :--- | :--- | :--- |
| `prometheus` | `localhost:9090` | Prometheus self-monitoring |
| `delivery_service` | `172.17.0.1:8000` | Delivery metrics from the Python app |

> **Note:** On Linux/WSL, use `172.17.0.1` (the docker0 bridge IP). On macOS/Windows native, use `host.docker.internal`.

### Step 2b: Configure Alerts

File: `delivery_monitoring/alert_rules.yml`

| Alert | Expression | Severity | Condition |
| :--- | :--- | :--- | :--- |
| `HighPendingDeliveries` | `pending_deliveries > 10` | warning | Fires if sustained for 15 s |
| `HighAverageDeliveryTime` | `average_delivery_time_sum / average_delivery_time_count > 30` | critical | Fires immediately |

---

### Step 2c: Run Prometheus

```bash
docker run -d --name prometheus --network=host \
  -v ./prometheus.yml:/etc/prometheus/prometheus.yml \
  -v ./alert_rules.yml:/etc/prometheus/alert_rules.yml \
  prom/prometheus
```

**Output:**
```
44cfd54b489e8f813ad5645095833426b12d562dbf4062226f12dc5b1be3f9465
```

Verify:

```bash
docker ps -a | grep prom
```

```
44cfd54b489e   prom/prometheus   "/bin/prometheus --c…"   5 minutes ago   Up 5 minutes   prometheus
```

> `--network=host` makes Prometheus behave like a native process on the host, so it can reach `172.17.0.1:8000`.

Access Prometheus at **http://localhost:9090** and verify targets via **Status → Targets**.

---

### Step 3: Set Up Grafana

Run Grafana:

```bash
docker run -d --name grafana -p 3000:3000 grafana/grafana
```

**Output:**
```
d15b35389cd54e91aa9451f3093a6701934968d022ddd20e8fb382cb1f05736f
```

Find the docker0 IP:

```bash
ip addr show docker0
```

```
inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
```

#### Step 3a: Access Grafana

Open **http://localhost:3000** in a browser.

#### Step 3b: Log In

```
Username: admin
Password: admin
```

Skip the password-change prompt.

#### Step 3c: Add Prometheus as a Data Source

Navigate to **Home → Connections → Data sources → Prometheus** and enter:

```
URL: http://172.17.0.1:9090
```

Click **Save & Test** to confirm the connection.

#### Step 3d: Create a Dashboard

Add four panels with the following queries:

| Panel | PromQL Query |
| :--- | :--- |
| Total Deliveries | `total_deliveries` |
| Pending Deliveries | `pending_deliveries` |
| On-the-Way Deliveries | `on_the_way_deliveries` |
| Average Delivery Time | `average_delivery_time_sum / average_delivery_time_count` |

---

### Step 5: Create the Jenkins Pipeline

File: `delivery_monitoring/Jenkinsfile`

The pipeline has five stages:

| Stage | Action |
| :--- | :--- |
| `Pre-check Docker` | Verifies Docker is installed and the daemon is running |
| `Setup Workspace` | Copies metric/config files into the Jenkins workspace |
| `Build Docker Image` | Builds a Docker image tagged `delivery_metrics` |
| `Run Application` | Starts the metrics container on port 8000 |
| `Run Prometheus & Grafana` | Launches Prometheus and Grafana containers |

#### Step 5a: Check Existing Jenkins Status

```bash
docker ps -a | grep jenkins
```

Remove any stale container before starting fresh:

```bash
docker rm <container-id>
```

#### Step 5b: Start Jenkins

```bash
docker run -d -p 8080:8080 -p 50000:50000 \
  --name jenkins \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

Access Jenkins at **http://localhost:8080**.

Retrieve the initial admin password:

```bash
docker exec -it jenkins bash
cat /var/jenkins_home/secrets/initialAdminPassword
```

#### Step 5c: Create a Pipeline Job

1. Go to **New Item → Pipeline**.
2. Select **Pipeline script** and paste the contents of `Jenkinsfile`.
3. Save and click **Build Now**.

---

### Step 6: Simulate Alerts

To trigger the `HighPendingDeliveries` alert, modify `delivery_metrics.py`:

```python
# Before (normal range)
pending = random.randint(10, 20)

# After (exceeds threshold)
pending = random.randint(50, 100)
```

Restart the script and Prometheus. Verify the firing alert in:
- **Prometheus UI → Alerts**
- **Grafana → Alerting**

---

## ✅ Expected Outputs

| Component | URL | Expected Result |
| :--- | :--- | :--- |
| Metrics endpoint | http://localhost:8000/metrics | Raw Prometheus text with delivery gauges |
| Prometheus | http://localhost:9090 | Graphs for `total_deliveries`, `pending_deliveries`, `average_delivery_time` |
| Grafana dashboard | http://localhost:3000 | 4-panel delivery monitoring dashboard |
| Jenkins | http://localhost:8080 | Successful 5-stage pipeline build |
| Prometheus Alerts | http://localhost:9090/alerts | `HighPendingDeliveries` and `HighAverageDeliveryTime` firing |

---

## ❓ Q&A

**Q1. What is Prometheus and how does it collect metrics?**
> Prometheus is an open-source monitoring system that pulls (scrapes) metrics from configured HTTP endpoints at a regular interval (default 15 s). Each target exposes metrics in a plain-text format at `/metrics`. Prometheus stores them as time-series data identified by metric name and key-value labels.

**Q2. What is the difference between a Gauge and a Summary in Prometheus?**
> - **Gauge**: A single numeric value that can go up or down (e.g., current pending deliveries). Use for measurements and counts.
> - **Summary**: Tracks the distribution of observed values over time, exposing `_sum`, `_count`, and configurable quantiles (e.g., p50, p99). Use for latency or duration measurements.

**Q3. Why is `--network=host` used when running Prometheus?**
> With `--network=host`, the Prometheus container shares the host's network namespace. This lets it reach `172.17.0.1:8000` (the docker0 bridge IP) where the Python metrics server is running on the host, without extra port-forwarding or network configuration.

**Q4. What does the `for: 15s` clause do in an alert rule?**
> It specifies a **pending duration**. The alert condition must remain true continuously for at least 15 seconds before Prometheus transitions it from `pending` to `firing`. This prevents transient spikes from generating false-positive alerts.

**Q5. What is the purpose of the Jenkins pipeline in this exercise?**
> The Jenkinsfile automates the full deployment workflow: it validates Docker availability, copies configuration files into the workspace, builds the metrics container image, and starts the application alongside Prometheus and Grafana — replacing manual shell commands with a repeatable, auditable CI/CD pipeline.
