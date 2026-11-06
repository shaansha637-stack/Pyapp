import Foundation

@MainActor
final class MockOTPStore: ObservableObject {
    @Published private(set) var history: [TestResult] = []
    @Published private(set) var challengeID: UUID?
    @Published private(set) var demoCode = "123456"
    @Published private(set) var message = "Ready for a safe mock test."
    @Published private(set) var isVerified = false
    @Published private(set) var totalRequests = 0
    @Published private(set) var successfulVerifications = 0
    @Published private(set) var failedVerifications = 0

    private let storageKey = "otp-security-tester.history.v1"
    private var requestDates: [Date] = []

    init() { loadHistory() }

    func createChallenge() {
        let now = Date()
        requestDates = requestDates.filter { now.timeIntervalSince($0) < 60 }
        guard requestDates.count < 5 else {
            message = "Local demo rate limit reached. Wait up to 60 seconds."
            add(title: "Mock challenge", status: "Rate limited", detail: message)
            return
        }
        requestDates.append(now)
        challengeID = UUID()
        isVerified = false
        totalRequests += 1
        message = "Mock challenge created. No SMS, call, or message was sent."
        add(title: "Mock challenge", status: "Created", detail: "Local-only challenge • 5-minute demo validity")
    }

    func verify(code: String) {
        guard challengeID != nil else {
            message = "Create a mock challenge first."
            return
        }
        guard !isVerified else {
            message = "This mock challenge has already been verified."
            return
        }
        if code == demoCode {
            isVerified = true
            successfulVerifications += 1
            message = "Demo OTP verified successfully."
            add(title: "OTP verification", status: "Passed", detail: "The local demo code matched.")
        } else {
            failedVerifications += 1
            message = "Incorrect demo code. Try 123456."
            add(title: "OTP verification", status: "Failed", detail: "Incorrect local demo code.")
        }
    }

    func add(title: String, status: String, detail: String) {
        history.insert(TestResult(title: title, status: status, detail: detail), at: 0)
        if history.count > 200 { history = Array(history.prefix(200)) }
        saveHistory()
    }

    func deleteHistory(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        saveHistory()
    }

    func clearHistory() {
        history.removeAll()
        saveHistory()
    }

    private func saveHistory() {
        guard let data = try? JSONEncoder().encode(history) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([TestResult].self, from: data) else { return }
        history = decoded
    }
}
