# Project 4: Prometheus + Grafana - Monitoring Stack with Dashboards as Code

> Build a full observability stack with system and application metrics visualised through provisioned Grafana dashboards. **[View source on GitHub](https://github.com/christosm-dev/portfolio/tree/main/mini-projects/project4-monitoring-stack)**

## Project Overview

This project demonstrates observability fundamentals by building a Prometheus and Grafana monitoring stack where all dashboards are defined as JSON code. A Flask application exposes custom metrics via `prometheus_client` while Node Exporter collects host system telemetry. Grafana loads both the Prometheus datasource and two purpose-built dashboards automatically on startup — no manual configuration required — showcasing the GitOps principle of treating dashboards as versioned, reproducible artefacts.

```
┌──────────────────────────────────────────────────────┐
│               Docker network: monitoring              │
│                                                      │
│  ┌─────────────┐   scrape :5000   ┌──────────────┐  │
│  │  Flask app  │◄─────────────────│              │  │
│  │  :5000      │                  │  Prometheus  │  │
│  └─────────────┘                  │  :9090       │  │
│                                   │              │  │
│  ┌─────────────┐   scrape :9100   │              │  │
│  │Node Exporter│◄─────────────────│              │  │
│  │  :9100      │                  └──────┬───────┘  │
│  └─────────────┘                         │          │
│                                    query │          │
│                                  ┌───────▼───────┐  │
│                                  │    Grafana    │  │
│                                  │    :3000      │  │
│                                  └───────────────┘  │
└──────────────────────────────────────────────────────┘
```

## Technology Stack

| Technology | Role |
|------------|------|
| Prometheus | Metrics collection and time-series storage |
| Grafana | Visualisation and dashboard provisioning |
| Node Exporter | Host system metrics (CPU, memory, disk, network) |
| Flask + prometheus_client | Demo application with custom instrumentation |
| Docker Compose | Orchestrates all four services locally |
| JSON + YAML | Dashboard and datasource configuration as code |

## Key Features

- Dashboards provisioned from JSON files — zero manual Grafana setup on startup
- Prometheus datasource auto-configured via YAML provisioning
- System metrics dashboard: CPU, memory, disk gauge, network I/O, load average (9 panels)
- Application metrics dashboard: request rate, p50/p95/p99 latency, error rate, endpoint breakdown (10 panels)
- Flask instrumented with Counter, Histogram, and Gauge metrics via before/after request hooks
- Load generator script with weighted endpoint distribution to populate dashboards

## Codebase Overview

```
project4-monitoring-stack/
├── docker-compose.yml                        # Four-service stack: Grafana, Prometheus, Node Exporter, app
├── prometheus/
│   └── prometheus.yml                        # Scrape configs for all three targets
├── app/
│   ├── app.py                                # Flask app with prometheus_client instrumentation
│   ├── Dockerfile
│   └── requirements.txt
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/prometheus.yml        # Auto-registers Prometheus datasource on startup
│   │   └── dashboards/dashboards.yml         # Points Grafana to the dashboard JSON directory
│   └── dashboards/
│       ├── system-metrics.json               # Host metrics dashboard (Node Exporter)
│       └── app-metrics.json                  # Application metrics dashboard (Flask)
├── scripts/
│   └── generate_load.sh                      # Weighted traffic generator for demo data
└── README.md
```

## Future Work

- [ ] Add Prometheus alerting rules and wire up Alertmanager for threshold notifications
- [ ] Instrument the Flask app with exemplars to enable trace-to-metrics correlation
- [ ] Add a Loki datasource and logs panel to the app dashboard for unified observability
- [ ] Parameterise dashboards with template variables (e.g. instance selector)
- [ ] Deploy the stack to Kubernetes and scrape pod metrics via the Prometheus operator

## Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Dashboard JSON Model](https://grafana.com/docs/grafana/latest/dashboards/json-model/)
- [Grafana Provisioning Docs](https://grafana.com/docs/grafana/latest/administration/provisioning/)
- [prometheus_client Python Library](https://github.com/prometheus/client_python)
- [Node Exporter Metrics Reference](https://prometheus.io/docs/guides/node-exporter/)
