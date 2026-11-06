"""Purely local OTP simulation. No network or messaging integrations."""
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from secrets import compare_digest
from typing import Dict
import uuid

DEMO_CODE = "123456"
CODE_TTL_SECONDS = 300
MAX_CHALLENGES_PER_WINDOW = 5
WINDOW_SECONDS = 60

@dataclass
class Challenge:
    challenge_id: str
    created_at: datetime
    expires_at: datetime
    verified: bool = False

class MockOTPService:
    def __init__(self):
        self.challenges: Dict[str, Challenge] = {}
        self.request_times: list[datetime] = []

    def request(self) -> dict:
        now = datetime.now(timezone.utc)
        self.request_times = [
            t for t in self.request_times
            if now - t < timedelta(seconds=WINDOW_SECONDS)
        ]
        if len(self.request_times) >= MAX_CHALLENGES_PER_WINDOW:
            return {
                "ok": False,
                "status": "rate_limited",
                "message": "Demo rate limit reached. Wait before trying again.",
                "retry_after_seconds": WINDOW_SECONDS,
            }
        self.request_times.append(now)
        challenge_id = str(uuid.uuid4())
        self.challenges[challenge_id] = Challenge(
            challenge_id=challenge_id,
            created_at=now,
            expires_at=now + timedelta(seconds=CODE_TTL_SECONDS),
        )
        return {
            "ok": True,
            "status": "simulated",
            "challenge_id": challenge_id,
            "expires_in_seconds": CODE_TTL_SECONDS,
            "demo_code": DEMO_CODE,
            "message": "Mock challenge created. No message was sent.",
        }

    def verify(self, challenge_id: str, code: str) -> dict:
        challenge = self.challenges.get(challenge_id)
        now = datetime.now(timezone.utc)
        if challenge is None:
            return {"ok": False, "status": "not_found", "message": "Challenge not found."}
        if now > challenge.expires_at:
            return {"ok": False, "status": "expired", "message": "Challenge expired."}
        if not compare_digest(code, DEMO_CODE):
            return {"ok": False, "status": "invalid_code", "message": "Demo code is incorrect."}
        challenge.verified = True
        return {"ok": True, "status": "verified", "message": "Mock OTP verified successfully."}
