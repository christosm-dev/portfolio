import pytest
import app as app_module
from app import app as flask_app


@pytest.fixture(autouse=True)
def reset_state():
    app_module.tasks.clear()
    app_module._next_id = 1
    yield


@pytest.fixture
def client():
    flask_app.config["TESTING"] = True
    with flask_app.test_client() as c:
        yield c


def test_index(client):
    r = client.get("/")
    assert r.status_code == 200
    assert r.get_json()["service"] == "task-tracker"


def test_health(client):
    r = client.get("/health")
    assert r.status_code == 200
    assert r.get_json()["status"] == "healthy"


def test_list_tasks_empty(client):
    r = client.get("/tasks")
    assert r.status_code == 200
    assert r.get_json() == []


def test_create_task(client):
    r = client.post("/tasks", json={"title": "Write tests"})
    assert r.status_code == 201
    body = r.get_json()
    assert body["title"] == "Write tests"
    assert body["done"] is False
    assert "id" in body


def test_create_task_missing_title(client):
    r = client.post("/tasks", json={})
    assert r.status_code == 400


def test_get_task(client):
    created = client.post("/tasks", json={"title": "Read docs"}).get_json()
    r = client.get(f"/tasks/{created['id']}")
    assert r.status_code == 200
    assert r.get_json()["title"] == "Read docs"


def test_get_task_not_found(client):
    r = client.get("/tasks/999")
    assert r.status_code == 404


def test_update_task(client):
    created = client.post("/tasks", json={"title": "Do thing"}).get_json()
    r = client.patch(f"/tasks/{created['id']}", json={"done": True})
    assert r.status_code == 200
    assert r.get_json()["done"] is True


def test_delete_task(client):
    created = client.post("/tasks", json={"title": "Delete me"}).get_json()
    r = client.delete(f"/tasks/{created['id']}")
    assert r.status_code == 204
    assert client.get(f"/tasks/{created['id']}").status_code == 404


def test_delete_task_not_found(client):
    r = client.delete("/tasks/999")
    assert r.status_code == 404
