import Foundation

struct StockQuote: Codable, Identifiable {
    let id = UUID()
    let symbol: String
    let close: Double
    let date: String
    let dateObject: Date
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(String.self, forKey: .symbol)
        close = try container.decode(Double.self, forKey: .close)
        date = try container.decode(String.self, forKey: .date)
        high = try container.decode(Double.self, forKey: .high)
        low = try container.decode(Double.self, forKey: .low)
        open = try container.decode(Double.self, forKey: .open)
        volume = try container.decodeIfPresent(Int.self, forKey: .volume)
        
        // Convert date string to Date object once during initialization
        dateObject = DateFormatterService.shared.dateFromISOString(date)
    }
    
    // Custom initializer for testing
    init(symbol: String, close: Double, date: String, high: Double, low: Double, open: Double, volume: Int?) {
        self.symbol = symbol
        self.close = close
        self.date = date
        self.high = high
        self.low = low
        self.open = open
        self.volume = volume
        
        // Convert date string to Date object once during initialization
        self.dateObject = DateFormatterService.shared.dateFromISOString(date)
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