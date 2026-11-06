import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: MockOTPStore

    var body: some View {
        NavigationStack {
            Group {
                if store.history.isEmpty {
                    ContentUnavailableView("No history", systemImage: "clock", description: Text("Your local test activity will appear here."))
                } else {
                    List {
                        ForEach(store.history) { item in
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text(item.title).font(.headline)
                                    Spacer()
                                    Text(item.status).font(.caption.weight(.semibold))
                                        .foregroundStyle(item.status == "Passed" || item.status == "Created" ? .green : .orange)
                                }
                                Text(item.detail).font(.subheadline).foregroundStyle(.secondary)
                                Text(item.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2).foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { offsets in
                            store.deleteHistory(at: offsets)
                        }
                    }
                }
            }
            .navigationTitle("Test History")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") { store.clearHistory() }
                        .disabled(store.history.isEmpty)
                }
            }
        }
    }
}
