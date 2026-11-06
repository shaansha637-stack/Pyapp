from fastapi import FastAPI
from pydantic import BaseModel, Field
from mock_engine import MockOTPService

app = FastAPI(
    title="OTP Security Tester Mock API",
    version="1.0.0",
    description="Simulation-only API. It never sends SMS, calls, WhatsApp, or email.",
)
service = MockOTPService()

class VerifyRequest(BaseModel):
    challenge_id: str = Field(min_length=1, max_length=80)
    code: str = Field(min_length=1, max_length=12)

@app.get("/health")
def health():
    return {"ok": True, "service": "otp-security-tester-mock", "mode": "simulation-only"}

@app.post("/api/v1/mock/otp/request")
def request_mock_otp():
    return service.request()

@app.post("/api/v1/mock/otp/verify")
def verify_mock_otp(payload: VerifyRequest):
    return service.verify(payload.challenge_id, payload.code)

@app.get("/api/v1/mock/limits")
def limits():
    return {
        "max_challenges_per_window": 5,
        "window_seconds": 60,
        "challenge_ttl_seconds": 300,
        "delivery_enabled": False,
    }
