import SwiftUI

struct SettingsView: View {
    @AppStorage("otp-security-tester.backendURL") private var backendURL = "http://127.0.0.1:8000"
    @State private var status = "Not checked"
    @State private var checking = false
    @State private var serviceName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Optional Python backend") {
                    TextField("Backend base URL", text: $backendURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                    Button {
                        Task { await checkBackend() }
                    } label: {
                        HStack {
                            if checking { ProgressView() }
                            Text("Check backend health")
                        }
                    }
                    .disabled(checking || backendURL.isEmpty)
                    Text(status).font(.footnote).foregroundStyle(.secondary)
                    if !serviceName.isEmpty {
                        Text("Service: \(serviceName)").font(.caption).foregroundStyle(.secondary)
                    }
                }
                Section("Privacy & safety") {
                    Label("Local mock OTP only", systemImage: "checkmark.shield")
                    Text("No real OTP delivery, phone-number targeting, SMS, WhatsApp, voice calls, or email integrations are included.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Interface", value: "SwiftUI")
                    LabeledContent("Backend", value: "Optional FastAPI mock")
                }
            }
            .navigationTitle("Settings")
        }
    }

    @MainActor
    private func checkBackend() async {
        checking = true
        defer { checking = false }
        do {
            let result = try await APIService().checkHealth(baseURL: backendURL)
            status = "Connected • \(result.mode)"
            serviceName = result.service
        } catch {
            status = error.localizedDescription
            serviceName = ""
        }
    }
}
