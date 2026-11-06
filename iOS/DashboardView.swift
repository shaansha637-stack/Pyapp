import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: MockOTPStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SECURITY CONSOLE")
                            .font(.caption.weight(.bold))
                            .tracking(2)
                            .foregroundStyle(.cyan)
                        Text("OTP Security\nTester")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        Text("A safe, simulation-only testing workspace.")
                            .foregroundStyle(.secondary)
                    }
                    HStack(spacing: 12) {
                        metric("Mock tests", value: "\(store.totalRequests)", icon: "flask")
                        metric("Verified", value: "\(store.successfulVerifications)", icon: "checkmark.seal")
                    }
                    HStack(spacing: 12) {
                        metric("Failed checks", value: "\(store.failedVerifications)", icon: "exclamationmark.triangle")
                        metric("History", value: "\(store.history.count)", icon: "clock")
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Safe testing mode", systemImage: "shield.lefthalf.filled")
                            .font(.headline)
                            .foregroundStyle(.green)
                        Text("All OTP challenges are generated locally. This app does not send SMS, WhatsApp messages, phone calls, or emails.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.green.opacity(0.10), in: RoundedRectangle(cornerRadius: 18))
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent activity").font(.headline)
                        if store.history.isEmpty {
                            ContentUnavailableView("No tests yet", systemImage: "tray", description: Text("Open the Test tab to create a mock challenge."))
                        } else {
                            ForEach(store.history.prefix(4)) { item in
                                activityRow(item)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemBackground))
            .navigationBarHidden(true)
        }
    }

    private func metric(_ title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon).font(.title2).foregroundStyle(.cyan)
            Text(value).font(.system(size: 27, weight: .bold, design: .rounded))
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
    }

    private func activityRow(_ item: TestResult) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title).font(.subheadline.weight(.semibold))
                Text(item.detail).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer()
            Text(item.status)
                .font(.caption.weight(.semibold))
                .foregroundStyle(item.status == "Passed" || item.status == "Created" ? .green : .orange)
        }
        .padding(.vertical, 6)
    }
}
