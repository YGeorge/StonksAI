import Foundation
import SwiftUI

// MARK: - Chart Data Provider Protocol
protocol ChartDataProvider {
    func getFilteredData(for timeScale: TimeScale) -> [StockQuote]
    func getYAxisRange(for data: [StockQuote]) -> (min: Double, max: Double)
    func getXAxisDates(for data: [StockQuote]) -> [Date]
}

// MARK: - Chart Data Provider Implementation
class StockChartDataProvider: ChartDataProvider {
    private let data: [StockQuote]
    private let dateFormatter: DateFormatterService
    
    init(data: [StockQuote], dateFormatter: DateFormatterService = .shared) {
        self.data = data
        self.dateFormatter = dateFormatter
    }
    
    func getFilteredData(for timeScale: TimeScale) -> [StockQuote] {
        // Convert dates and sort
        var datesAndQuotes: [(Date, StockQuote)] = []
        for quote in data {
            let date = dateFormatter.dateFromISOString(quote.date)
            datesAndQuotes.append((date, quote))
        }
        
        // Sort by date (latest first)
        datesAndQuotes.sort { $0.0 > $1.0 }
        
        // If no data, return empty array
        if datesAndQuotes.isEmpty {
            return []
        }
        
        // Get cutoff date
        let latestDate = datesAndQuotes[0].0
        let calendar = Calendar.current
        let cutoffDate = calendar.date(
            byAdding: .day,
            value: -timeScale.daysToShow,
            to: latestDate
        ) ?? latestDate
        
        // Filter and return quotes only
        var result: [StockQuote] = []
        for (date, quote) in datesAndQuotes {
            if date >= cutoffDate {
                result.append(quote)
            }
        }
        
        // Sort by date (oldest first) for proper display
        result.sort { 
            dateFormatter.dateFromISOString($0.date) < dateFormatter.dateFromISOString($1.date)
        }
        
        return result
    }
    
    func getYAxisRange(for data: [StockQuote]) -> (min: Double, max: Double) {
        // If no data, return default range
        guard !data.isEmpty else {
            return (min: 0, max: 100)
        }
        
        // Find minimum and maximum prices
        let minPrice = data.map { $0.low }.min() ?? 0
        let maxPrice = data.map { $0.high }.max() ?? 0
        
        // Calculate range with 30% padding below minimum and 20% above maximum
        let range = maxPrice - minPrice
        let minWithPadding = minPrice - (range * 0.3)
        let maxWithPadding = maxPrice + (range * 0.2)
        
        return (min: minWithPadding, max: maxWithPadding)
    }
    
    func getXAxisDates(for data: [StockQuote]) -> [Date] {
        // Convert to dates and sort
        var dates: [Date] = []
        for quote in data {
            dates.append(dateFormatter.dateFromISOString(quote.date))
        }
        
        dates.sort()
        
        // Return empty array if no dates
        if dates.isEmpty {
            return []
        } else if dates.count < 5 {
            // If we have less than 5 dates, return all of them
            return dates
        } else {
            // Calculate 5 evenly spaced indices
            let step = (dates.count - 1) / 4 // This will give us 5 points including start and end
            return [
                dates[0],                     // First date
                dates[step],                  // 25% point
                dates[step * 2],             // 50% point
                dates[step * 3],             // 75% point
                dates[dates.count - 1]        // Last date
            ]
        }
    }
} 