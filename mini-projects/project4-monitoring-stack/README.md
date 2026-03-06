# Project 4: Prometheus + Grafana - Monitoring Stack with Dashboards as Code

> Build a full observability stack — metrics, logs, and alerting — with Prometheus alerting rules, Alertmanager Slack routing, Loki log aggregation, and provisioned Grafana dashboards. **[View source on GitHub](https://github.com/christosm-dev/portfolio/tree/main/mini-projects/project4-monitoring-stack)**

## Project Overview

This project demonstrates observability fundamentals by building a Prometheus and Grafana monitoring stack where all dashboards are defined as JSON code. A Flask application exposes custom metrics via `prometheus_client` while Node Exporter collects host system telemetry. Alertmanager routes firing alerts to Slack with severity-based channel routing and inhibition rules. Loki aggregates container logs shipped by Promtail, surfaced in a logs panel on the app dashboard alongside the metrics panels. Grafana loads all datasources and dashboards automatically on startup — no manual configuration required.

```
┌──────────────────────────────────────────────────────────────────┐
│                   Docker network: monitoring                      │
│                                                                  │
│  ┌─────────────┐   scrape :5000   ┌──────────────────────────┐  │
│  │  Flask app  │◄─────────────────│                          │  │
│  │  :5000      │                  │  Prometheus  :9090       │  │
│  └──────┬──────┘   scrape :9100   │                          │  │
│         │logs  ┌───────────────── │  (evaluates alert rules) │  │
│  ┌──────▼──────┐  ┌─────────────┐ └──────────┬───────────────┘  │
│  │  Promtail   │  │Node Exporter│◄────────────┘   │ alerts       │
│  │  :9080      │  │  :9100      │            ┌────▼───────────┐  │
│  └──────┬──────┘  └─────────────┘            │  Alertmanager  │  │
│         │push logs                           │  :9093         │  │
│  ┌──────▼──────┐                             │  → Slack       │  │
│  │    Loki     │                             └────────────────┘  │
│  │  :3100      │                                                  │
│  └──────┬──────┘                                                  │
│         │query                                                    │
│  ┌──────▼──────────────────────────┐                             │
│  │           Grafana  :3000        │                             │
│  │  Prometheus datasource (metrics)│                             │
│  │  Loki datasource      (logs)    │                             │
│  └─────────────────────────────────┘                             │
└──────────────────────────────────────────────────────────────────┘
```

## Technology Stack

| Technology | Role |
|------------|------|
| Prometheus | Metrics collection, time-series storage, alert rule evaluation |
| Alertmanager | Alert routing — severity-based Slack channel routing, inhibition rules |
| Grafana | Visualisation, dashboard provisioning, Loki log panels |
| Loki | Log aggregation and querying |
| Promtail | Log collector — ships Docker container logs to Loki |
| Node Exporter | Host system metrics (CPU, memory, disk, network) |
| Flask + prometheus_client | Demo application with custom metrics instrumentation |
| Docker Compose | Orchestrates all seven services locally |
| JSON + YAML | Dashboards, datasources, and alert rules as code |

## Key Features

- Dashboards provisioned from JSON files — zero manual Grafana setup on startup
- Prometheus and Loki datasources auto-configured via YAML provisioning
- System metrics dashboard: CPU, memory, disk gauge, network I/O, load average (9 panels)
- Application metrics dashboard: request rate, p50/p95/p99 latency, error rate, endpoint breakdown, live log stream (11 panels)
- Flask instrumented with Counter, Histogram, and Gauge metrics via before/after request hooks; structured log output captured by Promtail
- Eight alerting rules across two rule files: FlaskAppDown, HighErrorRate, CriticalErrorRate, HighP95Latency, CriticalP99Latency, HighCPUUsage, HighMemoryUsage, DiskSpaceLow
- Alertmanager routes warning alerts to `#alerts` and critical alerts to `#alerts-critical`; inhibition rules suppress warning noise when a critical alert is already firing
- Load generator script with weighted endpoint distribution to populate dashboards

## Codebase Overview

```
project4-monitoring-stack/
├── docker-compose.yml                        # Seven-service stack: app, Prometheus, Alertmanager, Grafana, Node Exporter, Loki, Promtail
├── prometheus/
│   ├── prometheus.yml                        # Scrape configs, alerting endpoint, rule_files glob
│   └── rules/
│       ├── flask-app.rules.yml               # FlaskAppDown, error rate, and latency alert rules
│       └── node.rules.yml                    # CPU, memory, disk, and NodeExporter alert rules
├── alertmanager/
│   └── alertmanager.yml                      # Slack routing: warnings → #alerts, critical → #alerts-critical
├── loki/
│   └── loki.yml                              # Single-binary mode, local filesystem storage
├── promtail/
│   └── promtail.yml                          # Docker socket discovery, labels from Compose metadata
├── app/
│   ├── app.py                                # Flask app: prometheus_client instrumentation + structured logging
│   ├── Dockerfile
│   └── requirements.txt
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/
│   │   │   ├── prometheus.yml                # Auto-registers Prometheus datasource
│   │   │   └── loki.yml                      # Auto-registers Loki datasource
│   │   └── dashboards/dashboards.yml         # Points Grafana to the dashboard JSON directory
│   └── dashboards/
│       ├── system-metrics.json               # Host metrics dashboard (Node Exporter) — 9 panels
│       └── app-metrics.json                  # Application metrics + logs dashboard — 11 panels
├── scripts/
│   └── generate_load.sh                      # Weighted traffic generator for demo data
└── README.md
```

## Quick Start

### Prerequisites

```bash
docker compose version   # must be v2.x
```

### Start the stack

```bash
cd mini-projects/project4-monitoring-stack

docker compose up -d

# Verify all seven services are running
docker compose ps
```

### Access the dashboards

Open Grafana at `http://localhost:3000` — username `admin`, password `admin`.

The dashboards and datasources are pre-provisioned and available immediately:

- **System Metrics** — CPU, memory, disk, network I/O from Node Exporter
- **App Metrics** — request rate, p50/p95/p99 latency, error rate, live log stream from the Flask app

### Generate load for meaningful data

```bash
# Run the weighted traffic generator in the background
./scripts/generate_load.sh &
LOAD_PID=$!

# Let it run for a minute, then stop it
sleep 60 && kill $LOAD_PID
```

The dashboards populate in real time as Prometheus scrapes the targets every 15 seconds. The logs panel in App Metrics populates immediately as requests hit the Flask app.

### Inspect alert rules and firing alerts

```bash
# View all loaded alert rules
open http://localhost:9090/rules

# View currently firing or pending alerts
open http://localhost:9090/alerts
```

To trigger the `HighErrorRate` alert manually, hit the `/error` endpoint repeatedly with the load generator running — the endpoint returns 500 approximately 50% of the time.

### Access Alertmanager

```bash
open http://localhost:9093
```

The Alertmanager UI shows the current alert routing tree, active silences, and firing alert groups. To send real Slack notifications, replace the placeholder webhook URL in [alertmanager/alertmanager.yml](alertmanager/alertmanager.yml).

### Query logs directly in Loki

```bash
# Loki query API — returns the last 10 log lines from the Flask app
curl -G http://localhost:3100/loki/api/v1/query_range \
  --data-urlencode 'query={service="app"}' \
  --data-urlencode 'limit=10'
```

Or use the Grafana Explore view: select the Loki datasource and enter `{service="app"}`.

### Inspect Prometheus directly

```bash
# Open the Prometheus UI to explore raw metrics and query PromQL
open http://localhost:9090

# Example: query request rate for the Flask app
# rate(http_requests_total[1m])
```

### Tear down

```bash
docker compose down

# To also remove all data volumes (Prometheus, Loki, Alertmanager, Grafana)
docker compose down -v
```

## Future Work

- [ ] Instrument the Flask app with exemplars to enable trace-to-metrics correlation
- [ ] Parameterise dashboards with template variables (e.g. instance selector dropdown)
- [ ] Deploy the stack to Kubernetes and scrape pod metrics via the Prometheus operator
- [ ] Add a Loki alerting rule that fires on a pattern match (e.g. repeated ERROR log lines)
- [ ] Configure Alertmanager with a dead man's switch — an always-firing alert that verifies the pipeline is working end-to-end

## Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Prometheus Alerting Rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)
- [Alertmanager Configuration](https://prometheus.io/docs/alerting/latest/configuration/)
- [Grafana Dashboard JSON Model](https://grafana.com/docs/grafana/latest/dashboards/json-model/)
- [Grafana Provisioning Docs](https://grafana.com/docs/grafana/latest/administration/provisioning/)
- [Loki Documentation](https://grafana.com/docs/loki/latest/)
- [Promtail Docker Service Discovery](https://grafana.com/docs/loki/latest/send-data/promtail/configuration/#docker_sd_config)
- [prometheus_client Python Library](https://github.com/prometheus/client_python)
- [Node Exporter Metrics Reference](https://prometheus.io/docs/guides/node-exporter/)
