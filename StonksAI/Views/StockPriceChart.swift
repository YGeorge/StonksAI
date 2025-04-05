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
        
        // Sort by date (oldest first) for proper display
        result.sort { 
            dateFormatter.dateFromISOString($0.date) < dateFormatter.dateFromISOString($1.date)
        }
        
        return result
    }
    
    // Calculate Y-axis range
    private func getYAxisRange() -> (min: Double, max: Double) {
        let filteredData = getFilteredData()
        
        // If no data, return default range
        guard !filteredData.isEmpty else {
            return (min: 0, max: 100)
        }
        
        // Find minimum and maximum prices
        let minPrice = filteredData.map { $0.low }.min() ?? 0
        let maxPrice = filteredData.map { $0.high }.max() ?? 0
        
        // Calculate range with 30% padding below minimum and 20% above maximum
        let range = maxPrice - minPrice
        let minWithPadding = minPrice - (range * 0.3)
        let maxWithPadding = maxPrice + (range * 0.2)
        
        return (min: minWithPadding, max: maxWithPadding)
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
        let yAxisRange = getYAxisRange()
        
        // Calculate dynamic width based on number of data points
        let lineWidth: CGFloat = {
            switch filteredData.count {
            case 0...7: return 8    // Wider lines for weekly view
            case 8...30: return 4   // Medium width for monthly view
            default: return 2       // Thinner lines for 6-month view
            }
        }()
        
        return VStack(spacing: 16) {
            Chart(filteredData) { quote in
                RectangleMark(
                    x: .value("Date", dateFormatter.dateFromISOString(quote.date)),
                    yStart: .value("Low", quote.low),
                    yEnd: .value("High", quote.high),
                    width: .fixed(lineWidth)
                )
                .foregroundStyle(quote.close < quote.open ? AppTheme.negativeColor : AppTheme.positiveColor)
            }
            .frame(height: 300)
            .chartYScale(domain: yAxisRange.min...yAxisRange.max)
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
