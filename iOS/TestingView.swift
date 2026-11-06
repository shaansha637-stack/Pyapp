import SwiftUI

struct TestingView: View {
    @EnvironmentObject private var store: MockOTPStore
    @State private var code = ""
    @FocusState private var codeFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Label("Local mock environment", systemImage: "shield.checkered")
                        .foregroundStyle(.green)
                    Text("This test creates a simulated challenge on this device. It never contacts a phone number or messaging provider.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: { Text("Environment") }

                Section("1. Create challenge") {
                    Button {
                        store.createChallenge()
                        code = ""
                    } label: {
                        Label("Create mock OTP challenge", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(store.isVerified)
                    Text("Demo code: 123456")
                        .font(.system(.body, design: .monospaced).weight(.bold))
                        .foregroundStyle(.cyan)
                    Text("The demo code is intentionally visible because this is a simulator, not a real authentication flow.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("2. Verify challenge") {
                    TextField("Enter demo code", text: $code)
                        .keyboardType(.numberPad)
                        .focused($codeFocused)
                        .onChange(of: code) { newValue in
                            code = String(newValue.filter(\.isNumber).prefix(6))
                        }
                    Button("Verify mock OTP") {
                        store.verify(code: code)
                        codeFocused = false
                    }
                    .disabled(code.isEmpty || store.isVerified)
                }

                Section("Result") {
                    Text(store.message)
                    if store.isVerified {
                        Label("Verification passed", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            .navigationTitle("Mock OTP Test")
        }
    }
}
