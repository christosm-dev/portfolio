import time
import random
import logging
from flask import Flask, jsonify, Response, request, g
from prometheus_client import (
    Counter, Histogram, Gauge, Info,
    generate_latest, CONTENT_TYPE_LATEST,
)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
logger = logging.getLogger("metrics-app")

app = Flask(__name__)

# ── Metrics ────────────────────────────────────────────────────────────────────

REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP request count",
    ["method", "endpoint", "http_status"],
)

REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency in seconds",
    ["method", "endpoint"],
    buckets=[0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5],
)

ACTIVE_REQUESTS = Gauge(
    "http_active_requests",
    "Number of currently in-flight HTTP requests",
    ["endpoint"],
)

APP_INFO = Info("app", "Application build information")
APP_INFO.info({"version": "1.0.0", "environment": "demo"})

# ── Request lifecycle hooks ────────────────────────────────────────────────────

@app.before_request
def before_request():
    g.start_time = time.time()
    if request.endpoint and request.endpoint != "metrics":
        ACTIVE_REQUESTS.labels(endpoint=request.endpoint).inc()


@app.teardown_request
def teardown_request(exc):
    if request.endpoint and request.endpoint != "metrics":
        ACTIVE_REQUESTS.labels(endpoint=request.endpoint).dec()


@app.after_request
def after_request(response):
    if request.endpoint and request.endpoint != "metrics":
        duration = time.time() - g.start_time
        REQUEST_COUNT.labels(
            method=request.method,
            endpoint=request.endpoint,
            http_status=str(response.status_code),
        ).inc()
        REQUEST_LATENCY.labels(
            method=request.method,
            endpoint=request.endpoint,
        ).observe(duration)
    return response

# ── In-memory data store ───────────────────────────────────────────────────────

_items = [
    {"id": 1, "name": "Widget A", "value": 42},
    {"id": 2, "name": "Widget B", "value": 17},
    {"id": 3, "name": "Widget C", "value": 88},
]
_next_id = 4

# ── Routes ─────────────────────────────────────────────────────────────────────

@app.route("/")
def index():
    return jsonify({
        "service": "metrics-demo-app",
        "version": "1.0.0",
        "endpoints": ["/", "/health", "/items", "/error", "/metrics"],
    })


@app.route("/health")
def health():
    return jsonify({"status": "healthy", "timestamp": time.time()})


@app.route("/items", methods=["GET"])
def list_items():
    # Simulate variable read latency (e.g. database query)
    time.sleep(random.uniform(0.01, 0.15))
    logger.info("GET /items returned %d items", len(_items))
    return jsonify({"items": _items, "count": len(_items)})


@app.route("/items", methods=["POST"])
def create_item():
    global _next_id
    # Simulate variable write latency
    time.sleep(random.uniform(0.05, 0.30))
    data = request.get_json(silent=True) or {}
    item = {
        "id": _next_id,
        "name": data.get("name", f"Widget {_next_id}"),
        "value": data.get("value", random.randint(1, 100)),
    }
    _items.append(item)
    _next_id += 1
    logger.info("POST /items created item id=%d name=%s", item["id"], item["name"])
    return jsonify(item), 201


@app.route("/error")
def trigger_error():
    """Randomly returns 500 — useful for testing the error rate panel."""
    if random.random() < 0.5:
        logger.warning("GET /error triggered simulated 500 response")
        return jsonify({"error": "simulated server error"}), 500
    time.sleep(random.uniform(0.1, 0.4))
    return jsonify({"status": "ok"})


@app.route("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
