import Foundation

struct TestResult: Identifiable, Codable {
    var id: UUID
    var date: Date
    var title: String
    var status: String
    var detail: String

    init(id: UUID = UUID(), date: Date = .now, title: String, status: String, detail: String) {
        self.id = id
        self.date = date
        self.title = title
        self.status = status
        self.detail = detail
    }
}
