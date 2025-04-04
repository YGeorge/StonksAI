import Foundation

enum MarketstackError: Error {
    case invalidURL
    case apiError(String)
    case decodingError
    case networkError(Error)
}

// MARK: - User-Friendly Description
extension MarketstackError {
    var userFriendlyDescription: String {
        switch self {
        case .apiError(let message):
            return "Server error: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError:
            return "Failed to process the data"
        case .invalidURL:
            return "Invalid request"
        }
    }
} 