import SwiftUI
import Charts

enum TimeScale: String {
    case week = "Week"
    case month = "Month"
    case sixMonths = "6 Months"
    
    var daysToShow: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .sixMonths: return 180
        }
    }
}

struct StockPriceChart: View {
    let data: [StockQuote]
    @State private var selectedTimeScale: TimeScale = .month
    
    private let dateFormatter = DateFormatterService.shared
    
    // Get filtered data for the selected time period
    private func getFilteredData() -> [StockQuote] {
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
    
    // Get dates for X-axis
    private func getXAxisDates() -> [Date] {
        let filteredData = getFilteredData()
        
        // Convert to dates and sort
        var dates: [Date] = []
        for quote in filteredData {
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
                    x: .value("Date", dateFormatter.dateFromISOString(quote.date)),
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
                            Text(dateFormatter.shortMonthDayString(from: date))
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
            
            HStack(spacing: 12) {
                timeScaleButton(for: .week)
                timeScaleButton(for: .month)
                timeScaleButton(for: .sixMonths)
            }
        }
    }
} 
