import SwiftUI
import Charts

enum TimeScale: String {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case sixMonths = "6 Months"
    
    var daysToShow: Int {
        switch self {
        case .day: return 1
        case .week: return 7
        case .month: return 30
        case .sixMonths: return 180
        }
    }
}

struct StockPriceChart: View {
    let data: [StockQuote]
    @State private var selectedTimeScale: TimeScale = .month
    
    // Reusable date formatters
    private let isoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    private let axisDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    // Simple date conversion function
    private func dateFromString(_ dateString: String) -> Date {
        return isoDateFormatter.date(from: dateString) ?? Date()
    }
    
    // Get filtered data for the selected time period
    private func getFilteredData() -> [StockQuote] {
        // Convert dates and sort
        var datesAndQuotes: [(Date, StockQuote)] = []
        for quote in data {
            let date = dateFromString(quote.date)
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
            value: -selectedTimeScale.daysToShow,
            to: latestDate
        ) ?? latestDate
        
        // Filter and return quotes only
        var result: [StockQuote] = []
        for (date, quote) in datesAndQuotes {
            if date >= cutoffDate {
                result.append(quote)
            }
        }
        
        return result
    }
    
    // Get three dates for X-axis
    private func getXAxisDates() -> [Date] {
        let filteredData = getFilteredData()
        
        // Convert to dates and sort
        var dates: [Date] = []
        for quote in filteredData {
            dates.append(dateFromString(quote.date))
        }
        
        dates.sort()
        
        // Return appropriate dates based on how many we have
        if dates.isEmpty {
            return []
        } else if dates.count == 1 {
            return [dates[0]]
        } else if dates.count == 2 {
            return [dates[0], dates[1]]
        } else {
            // First, middle, and last
            let first = dates[0]
            let middle = dates[dates.count / 2]
            let last = dates[dates.count - 1]
            return [first, middle, last]
        }
    }
    
    private func timeScaleButton(for scale: TimeScale) -> some View {
        Button(action: {
            selectedTimeScale = scale
        }) {
            Text(scale.rawValue)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.backgroundColor)
                .foregroundColor(selectedTimeScale == scale ? AppTheme.positiveColor : .white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.textColor.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    var body: some View {
        let filteredData = getFilteredData()
        let xAxisDates = getXAxisDates()
        
        return VStack(spacing: 16) {
            Chart(filteredData) { quote in
                LineMark(
                    x: .value("Date", dateFromString(quote.date)),
                    y: .value("Price", quote.close)
                )
                .foregroundStyle(AppTheme.textColor)
            }
            .frame(height: 300)
            .chartXAxis {
                AxisMarks(values: xAxisDates) { value in
                    AxisGridLine()
                        .foregroundStyle(AppTheme.textColor.opacity(0.3))
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(axisDateFormatter.string(from: date))
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(AppTheme.textColor)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(AppTheme.textColor.opacity(0.3))
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text(String(format: "%.2f", doubleValue))
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(AppTheme.textColor)
                }
            }
            
            // Time scale buttons - manually laid out
            HStack(spacing: 12) {
                timeScaleButton(for: .day)
                timeScaleButton(for: .week)
                timeScaleButton(for: .month)
                timeScaleButton(for: .sixMonths)
            }
        }
    }
} 
