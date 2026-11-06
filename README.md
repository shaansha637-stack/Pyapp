# OTP Security Tester (Safe Demo)

A native SwiftUI iOS app plus an optional FastAPI mock backend for **local, simulated OTP security testing**.

This repository deliberately contains:
- No SMS, WhatsApp, voice-call, email, or real OTP delivery integrations.
- No third-party OTP provider endpoints.
- No bulk sending or arbitrary phone-number targeting.
- A local mock OTP flow (demo code `123456`) and API diagnostics for an explicitly configured backend.

## Repository layout

```text
OTP-Security-Tester/
├── Backend/
│   ├── main.py
│   ├── mock_engine.py
│   ├── requirements.txt
│   └── tests/test_api.py
├── iOS/
│   ├── OTPTesterApp.swift
│   ├── ContentView.swift
│   ├── DashboardView.swift
│   ├── TestingView.swift
│   ├── HistoryView.swift
│   ├── ReportsView.swift
│   ├── SettingsView.swift
│   ├── APIService.swift
│   ├── MockOTPStore.swift
│   └── Models/TestResult.swift
├── project.yml
└── .github/workflows/ios-unsigned.yml
```

## Build the unsigned IPA using GitHub Actions (iPhone-only editing)

1. Create a new GitHub repository named `OTP-Security-Tester`.
2. Add each file in this repository using GitHub's **Add file → Create new file** screen. Use the exact paths shown above.
3. Commit the files to the `main` branch.
4. Open **Actions** → **Build unsigned iOS IPA** → **Run workflow**.
5. When the run finishes, open the workflow run and download the `OTP-Security-Tester-unsigned-IPA` artifact.

The workflow uses a GitHub-hosted macOS runner, installs XcodeGen, generates the Xcode project from `project.yml`, builds for a generic iOS device with code signing disabled, and packages the `.app` into an `.ipa`-style ZIP.

**Important:** an unsigned IPA is not directly installable on a normal iPhone. It must be signed with a valid certificate/provisioning profile or processed by a compatible sideloading/signing workflow. This project does not bypass Apple's signing requirements.

## Run the optional Python mock backend

On a machine with Python 3.10+:

```bash
cd Backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --host 127.0.0.1 --port 8000
```

Open `http://127.0.0.1:8000/docs` to inspect the mock API.

The backend only simulates OTP requests. It never contacts a phone number or sends a message. The demo code is `123456`.

For an iPhone to reach a backend running on another device, configure the backend's reachable HTTPS URL in the app's Settings tab. Do not expose an unauthenticated development server to the public internet.

## App behavior

- **Dashboard:** counts mock tests and shows recent results.
- **Test:** creates a local simulated OTP challenge and verifies the demo code.
- **History:** stores recent results locally on the device.
- **Reports:** exports a CSV report through the iOS share sheet.
- **Settings:** configure an optional backend base URL and check its `/health` endpoint.

The iOS app works in local demo mode without a backend. The backend URL is used only for a health check; OTP simulation remains local in the app, preventing accidental real-world delivery.

## Safety

Use only synthetic test data and systems you own or are explicitly authorized to test. Do not enter another person's phone number. This demo has no real OTP delivery capability.
