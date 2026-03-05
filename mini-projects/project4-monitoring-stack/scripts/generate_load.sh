#!/bin/bash
# Generate synthetic traffic against the Flask demo app.
# Run this to populate the Grafana dashboards with realistic data.
#
# Usage:
#   ./scripts/generate_load.sh              # 60s, 0.5s between requests
#   DURATION=120 INTERVAL=0.2 ./scripts/generate_load.sh

APP_URL="${APP_URL:-http://localhost:5000}"
DURATION="${DURATION:-60}"
INTERVAL="${INTERVAL:-0.5}"

echo "Sending traffic to ${APP_URL} for ${DURATION}s (interval: ${INTERVAL}s)"
echo "Press Ctrl+C to stop early."
echo ""

end=$((SECONDS + DURATION))
count=0

while [ $SECONDS -lt $end ]; do
    # Weighted random endpoint selection — mirrors realistic traffic patterns
    roll=$((RANDOM % 20))

    if [ $roll -lt 7 ]; then
        # 35% — GET /items (most common read)
        curl -s "${APP_URL}/items" > /dev/null
        endpoint="/items GET"
    elif [ $roll -lt 11 ]; then
        # 20% — POST /items (write traffic)
        curl -s -X POST "${APP_URL}/items" \
            -H "Content-Type: application/json" \
            -d "{\"name\":\"Load Test Item ${count}\",\"value\":$((RANDOM % 100))}" > /dev/null
        endpoint="/items POST"
    elif [ $roll -lt 15 ]; then
        # 20% — GET / (index)
        curl -s "${APP_URL}/" > /dev/null
        endpoint="/ GET"
    elif [ $roll -lt 18 ]; then
        # 15% — GET /health (monitoring/probe traffic)
        curl -s "${APP_URL}/health" > /dev/null
        endpoint="/health GET"
    else
        # 10% — GET /error (generates 500s ~50% of the time)
        curl -s "${APP_URL}/error" > /dev/null
        endpoint="/error GET"
    fi

    count=$((count + 1))
    printf "\r  Requests sent: %d  (last: %s)   " "$count" "$endpoint"
    sleep "$INTERVAL"
done

echo ""
echo ""
echo "Done. ${count} requests sent."
