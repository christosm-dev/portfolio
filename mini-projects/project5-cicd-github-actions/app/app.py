from flask import Flask, jsonify, request, abort

app = Flask(__name__)

tasks = {}
_next_id = 1


@app.route("/")
def index():
    return jsonify({"service": "task-tracker", "version": "1.0.0"})


@app.route("/health")
def health():
    return jsonify({"status": "healthy"})


@app.route("/tasks", methods=["GET"])
def list_tasks():
    return jsonify(list(tasks.values()))


@app.route("/tasks", methods=["POST"])
def create_task():
    global _next_id
    data = request.get_json(silent=True) or {}
    title = data.get("title", "").strip()
    if not title:
        abort(400, description="title is required")
    task = {"id": _next_id, "title": title, "done": False}
    tasks[_next_id] = task
    _next_id += 1
    return jsonify(task), 201


@app.route("/tasks/<int:task_id>", methods=["GET"])
def get_task(task_id):
    task = tasks.get(task_id)
    if not task:
        abort(404, description=f"Task {task_id} not found")
    return jsonify(task)


@app.route("/tasks/<int:task_id>", methods=["PATCH"])
def update_task(task_id):
    task = tasks.get(task_id)
    if not task:
        abort(404, description=f"Task {task_id} not found")
    data = request.get_json(silent=True) or {}
    if "done" in data:
        task["done"] = bool(data["done"])
    if "title" in data:
        title = data["title"].strip()
        if title:
            task["title"] = title
    return jsonify(task)


@app.route("/tasks/<int:task_id>", methods=["DELETE"])
def delete_task(task_id):
    task = tasks.pop(task_id, None)
    if not task:
        abort(404, description=f"Task {task_id} not found")
    return "", 204


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
