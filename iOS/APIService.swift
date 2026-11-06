import Foundation

struct HealthResponse: Decodable {
    let ok: Bool
    let service: String
    let mode: String
}

enum APIServiceError: LocalizedError {
    case invalidURL
    case badResponse
    case notHealthy

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Enter a valid backend URL."
        case .badResponse: return "The backend returned an unexpected response."
        case .notHealthy: return "The backend health check did not pass."
        }
    }
}

struct APIService {
    func checkHealth(baseURL: String) async throws -> HealthResponse {
        let trimmed = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let base = URL(string: trimmed),
              let url = URL(string: "/health", relativeTo: base) else {
            throw APIServiceError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIServiceError.badResponse
        }
        let result = try JSONDecoder().decode(HealthResponse.self, from: data)
        guard result.ok, result.mode == "simulation-only" else {
            throw APIServiceError.notHealthy
        }
        return result
    }
}
