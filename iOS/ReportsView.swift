import SwiftUI
import UniformTypeIdentifiers

struct ReportsView: View {
    @EnvironmentObject private var store: MockOTPStore
    @State private var exportURL: URL?
    @State private var showingShare = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundStyle(.cyan)
                Text("Test Reports").font(.title2.bold())
                Text("Export locally stored mock test history as a CSV file.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Button {
                    createCSV()
                } label: {
                    Label("Generate CSV report", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.history.isEmpty)
                Text("\(store.history.count) recorded events")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .padding(.top, 30)
            .navigationTitle("Reports")
            .sheet(isPresented: $showingShare) {
                if let exportURL {
                    ShareSheet(items: [exportURL])
                }
            }
        }
    }

    private func createCSV() {
        let header = "Date,Title,Status,Detail\n"
        let rows = store.history.map {
            [
                $0.date.ISO8601Format(),
                $0.title,
                $0.status,
                $0.detail
            ].map(csvEscape).joined(separator: ",")
        }.joined(separator: "\n")
        let contents = header + rows + "\n"
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("OTP-Security-Tester-Report.csv")
        do {
            try contents.write(to: url, atomically: true, encoding: .utf8)
            exportURL = url
            showingShare = true
        } catch {
            exportURL = nil
        }
    }

    private func csvEscape(_ value: String) -> String {
        "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
