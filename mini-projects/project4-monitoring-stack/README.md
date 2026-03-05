# Project 4: Prometheus + Grafana Monitoring Stack

> Dashboards-as-code monitoring stack for system and application metrics. **[View source on GitHub](https://github.com/christosm-dev/portfolio/tree/main/mini-projects/project4-monitoring-stack)**

## Project Overview

This project demonstrates observability fundamentals by building a complete monitoring stack using Prometheus and Grafana — with all dashboards defined as code. A Flask application exposes custom business metrics alongside a Node Exporter collecting host system telemetry. Both are scraped by Prometheus and visualised through two provisioned Grafana dashboards that load automatically on startup with no manual configuration.

The emphasis is on the dashboards themselves: meaningful PromQL queries, appropriate visualisations for each metric type, threshold colouring, and a layout that tells a clear operational story.

## Technology Stack

| Technology | Role |
|------------|------|
| Prometheus | Metrics collection and time-series storage |
| Grafana | Visualisation and dashboard provisioning |
| Node Exporter | Host system metrics (CPU, memory, disk, network) |
| Flask + prometheus_client | Demo application with custom instrumentation |
| Docker Compose | Orchestrates all four services locally |
| JSON + YAML | Dashboard and provisioning configuration as code |

## Key Features

- Dashboards provisioned from JSON files — no manual Grafana setup required
- Prometheus datasource auto-configured via YAML provisioning
- Two purpose-built dashboards: system infrastructure and application layer
- Custom Flask metrics: request counter, latency histogram, active requests gauge
- Simulated variable latency and a `/error` endpoint to exercise error-rate panels
- Load generator script to populate dashboards with realistic traffic patterns
- Transmit traffic displayed on negative Y-axis (standard network I/O convention)

## Codebase Overview

```
project4-monitoring-stack/
├── docker-compose.yml                        # Four-service stack definition
├── prometheus/
│   └── prometheus.yml                        # Scrape configs for all three targets
├── app/
│   ├── app.py                                # Flask app with prometheus_client instrumentation
│   ├── Dockerfile
│   └── requirements.txt
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/prometheus.yml        # Auto-registers Prometheus datasource
│   │   └── dashboards/dashboards.yml         # Tells Grafana where to find dashboard JSON
│   └── dashboards/
│       ├── system-metrics.json               # Host metrics dashboard (9 panels)
│       └── app-metrics.json                  # Application metrics dashboard (10 panels)
└── scripts/
    └── generate_load.sh                      # Weighted traffic generator
```

## Quick Start

**Prerequisites**: Docker and Docker Compose installed.

```bash
# 1. Start the stack
docker compose up -d

# 2. Wait ~15 seconds for Prometheus to complete its first scrape, then open Grafana
open http://localhost:3000
# Login: admin / admin

# 3. Navigate to Dashboards — both dashboards are pre-loaded

# 4. (Optional) Generate traffic to populate the app metrics dashboard
./scripts/generate_load.sh
```

**Service URLs**

| Service | URL |
|---------|-----|
| Grafana | http://localhost:3000 |
| Prometheus | http://localhost:9090 |
| Flask app | http://localhost:5000 |
| App metrics endpoint | http://localhost:5000/metrics |
| Node Exporter metrics | http://localhost:9100/metrics |

## Dashboards

### System Metrics

Monitors host-level telemetry collected by Node Exporter.

| Panel | Type | PromQL |
|-------|------|--------|
| CPU Usage (current) | Stat | `100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)` |
| Memory Usage (current) | Stat | `(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100` |
| Disk Usage (current) | Stat | `100 - (free / size * 100)` on mountpoint `/` |
| System Uptime | Stat | `time() - node_boot_time_seconds` |
| CPU Usage Over Time | Time series | Per-CPU breakdown using `irate` |
| Memory Over Time | Time series | Used % and Cached+Buffered % |
| Network I/O | Time series | Receive up / Transmit mirrored on negative Y |
| Disk Usage | Gauge | Single fill gauge with threshold colouring |
| System Load Average | Time series | 1m / 5m / 15m plus CPU core count as reference line |

**Threshold logic**: green below 70%, yellow 70–85%, red above 85% for CPU; 75/90% for memory and disk.

### Application Metrics

Monitors the Flask application via its `/metrics` endpoint.

| Panel | Type | PromQL |
|-------|------|--------|
| Total Requests | Stat | `sum(http_requests_total)` |
| Request Rate | Stat | `sum(rate(http_requests_total[5m]))` |
| Error Rate | Stat | 5xx rate as % of total — threshold colours at 1% and 5% |
| Active Requests | Stat | `sum(http_active_requests)` |
| Request Rate by Status | Time series | Split by HTTP status code; 500s forced red |
| Error Rate Over Time | Time series | 5xx% with threshold shading at 1% and 5% |
| Latency Percentiles | Time series | p50 (green), p95 (orange), p99 (red) via `histogram_quantile` |
| Active Requests | Gauge | In-flight request count with threshold fill |
| Request Rate by Endpoint | Bar chart | Instant query, one bar per endpoint |
| Status Code Distribution | Pie chart | `increase()` over last 1h, value + percent labels |

## Flask Application Metrics

The app uses `prometheus_client` to expose three metrics:

```python
# How many requests have completed, by method, endpoint and status code
http_requests_total (Counter)   labels: method, endpoint, http_status

# How long each request took (bucketed histogram for quantile calculation)
http_request_duration_seconds (Histogram)   labels: method, endpoint

# How many requests are currently in-flight
http_active_requests (Gauge)   labels: endpoint
```

Metrics are incremented in Flask's `before_request` / `after_request` / `teardown_request` hooks — the routes themselves contain only business logic and simulated latency.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Docker network: monitoring          │
│                                                     │
│  ┌─────────────┐     scrape      ┌───────────────┐  │
│  │  Flask app  │◄────:5000───────│               │  │
│  │  :5000      │                 │  Prometheus   │  │
│  └─────────────┘                 │  :9090        │  │
│                                  │               │  │
│  ┌─────────────┐     scrape      │               │  │
│  │Node Exporter│◄────:9100───────│               │  │
│  │  :9100      │                 └───────┬───────┘  │
│  └─────────────┘                         │          │
│                                    query │          │
│                                  ┌───────▼───────┐  │
│                                  │    Grafana    │  │
│                                  │    :3000      │  │
│                                  └───────────────┘  │
└─────────────────────────────────────────────────────┘
```

## Dashboards as Code — How it Works

Grafana provisioning removes the need to manually configure anything. On startup Grafana reads two directories mounted into the container:

```
/etc/grafana/provisioning/
  datasources/prometheus.yml   → registers Prometheus with uid "prometheus"
  dashboards/dashboards.yml    → tells Grafana to watch /var/lib/grafana/dashboards/

/var/lib/grafana/dashboards/
  system-metrics.json          → loaded as "System Metrics" dashboard
  app-metrics.json             → loaded as "Application Metrics" dashboard
```

The dashboard JSON files reference the datasource by `uid: "prometheus"`, which matches the uid set in the datasource provisioning file. This means the same files work identically on any Grafana instance that has this provisioning applied — local, staging or production.

## Generating Load

```bash
# Default: 60 seconds, 0.5s between requests
./scripts/generate_load.sh

# Custom duration and rate
DURATION=120 INTERVAL=0.2 ./scripts/generate_load.sh

# Target a different host (e.g. remote VPS)
APP_URL=http://your-vps:5000 ./scripts/generate_load.sh
```

The script uses weighted random selection to simulate realistic traffic: 35% reads, 20% writes, 15% health checks, 10% the `/error` endpoint (which returns 500 ~50% of the time, exercising the error-rate panels).

## Stopping the Stack

```bash
# Stop containers, preserve volume data
docker compose down

# Stop and delete all data (metrics history, Grafana state)
docker compose down -v
```

## Interview Talking Points

**Why Grafana provisioning instead of manual dashboard creation?**
Provisioning treats dashboards as code — they live in version control, can be reviewed in pull requests, and are guaranteed to be identical across all environments. Manual dashboards are undocumented configuration drift waiting to happen.

**Why histogram for latency rather than a summary?**
Histograms are scraped and stored as raw bucket counts, so you can aggregate across multiple instances with `sum by(le)` before calling `histogram_quantile`. Prometheus summaries compute quantiles client-side and cannot be aggregated — a critical limitation in any multi-instance deployment.

**What do the `irate` vs `rate` choices mean?**
`irate` uses only the last two data points, making it responsive to sudden spikes — appropriate for CPU usage where you want to see brief bursts. `rate` averages over the full window, smoothing out noise — better for request rates where trend matters more than momentary spikes.

**How would this extend to production?**
The same dashboard JSON and provisioning YAML files are used in the VPS demo platform project, deployed via Terraform and loaded by Grafana running inside Kubernetes. The local Docker Compose stack here serves as a development and testing environment for the dashboards themselves.
