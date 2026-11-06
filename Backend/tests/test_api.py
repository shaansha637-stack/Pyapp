from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_health_is_simulation_only():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["mode"] == "simulation-only"

def test_mock_challenge_and_verify():
    created = client.post("/api/v1/mock/otp/request")
    assert created.status_code == 200
    payload = created.json()
    assert payload["ok"] is True
    assert payload["status"] == "simulated"
    assert payload["demo_code"] == "123456"
    assert "challenge_id" in payload

    verified = client.post(
        "/api/v1/mock/otp/verify",
        json={"challenge_id": payload["challenge_id"], "code": "123456"},
    )
    assert verified.status_code == 200
    assert verified.json()["status"] == "verified"

def test_wrong_code_is_rejected():
    created = client.post("/api/v1/mock/otp/request").json()
    response = client.post(
        "/api/v1/mock/otp/verify",
        json={"challenge_id": created["challenge_id"], "code": "000000"},
    )
    assert response.json()["status"] == "invalid_code"
