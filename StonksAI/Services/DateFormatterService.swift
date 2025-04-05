import Foundation

final class DateFormatterService {
    // Singleton instance
    static let shared = DateFormatterService()
    
    // Private initialization to ensure singleton pattern
    private init() {}
    
    // ISO date formatter for API dates
    lazy var isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    // Short month and day formatter for chart axis
    lazy var shortMonthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    // Helper methods
    func dateFromISOString(_ dateString: String) -> Date {
        return isoFormatter.date(from: dateString) ?? Date()
    }
    
    func shortMonthDayString(from date: Date) -> String {
        return shortMonthDayFormatter.string(from: date)
    }
} 