import Foundation

struct StockQuote: Codable, Identifiable {
    let id = UUID()
    let symbol: String
    let close: Double
    let date: String
    let high: Double
    let low: Double
    let open: Double
    let volume: Int?
    
    private enum CodingKeys: String, CodingKey {
        case symbol
        case close
        case date
        case high
        case low
        case open
        case volume
    }
}

struct MarketstackResponse: Codable {
    let data: [StockQuote]
    
    // Add pagination info if available in response
    let pagination: Pagination?
}

struct Pagination: Codable {
    let limit: Int
    let offset: Int
    let count: Int
    let total: Int
} 