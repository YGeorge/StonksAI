import SwiftUI
import Charts

// MARK: - TimeScale Enum
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

// MARK: - Stock Price Chart View
struct StockPriceChart: View {
    private let data: [StockQuote]
    private let dataProvider: ChartDataProvider
    private let styleProvider: ChartStyleProvider
    @State private var selectedTimeScale: TimeScale = .month
    
    init(data: [StockQuote], 
         dataProvider: ChartDataProvider? = nil,
         styleProvider: ChartStyleProvider = StockChartStyleProvider()) {
        self.data = data
        self.dataProvider = dataProvider ?? StockChartDataProvider(data: data)
        self.styleProvider = styleProvider
    }
    
    var body: some View {
        let filteredData = dataProvider.getFilteredData(for: selectedTimeScale)
        let xAxisDates = dataProvider.getXAxisDates(for: filteredData)
        let yAxisRange = dataProvider.getYAxisRange(for: filteredData)
        let lineWidth = styleProvider.getLineWidth(for: filteredData.count)
        
        return VStack(spacing: 16) {
            Chart(filteredData) { quote in
                RectangleMark(
                    x: .value("Date", DateFormatterService.shared.dateFromISOString(quote.date)),
                    yStart: .value("Low", quote.low),
                    yEnd: .value("High", quote.high),
                    width: .fixed(lineWidth)
                )
                .foregroundStyle(styleProvider.getColor(for: quote))
            }
            .frame(height: 300)
            .chartYScale(domain: yAxisRange.min...yAxisRange.max)
            .chartXAxis {
                AxisMarks(values: xAxisDates) { value in
                    AxisGridLine()
                        .foregroundStyle(AppTheme.textColor.opacity(0.3))
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(DateFormatterService.shared.shortMonthDayString(from: date))
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
                TimeScaleButton(scale: .week, isSelected: selectedTimeScale == .week) {
                    selectedTimeScale = .week
                }
                TimeScaleButton(scale: .month, isSelected: selectedTimeScale == .month) {
                    selectedTimeScale = .month
                }
                TimeScaleButton(scale: .sixMonths, isSelected: selectedTimeScale == .sixMonths) {
                    selectedTimeScale = .sixMonths
                }
            }
        }
    }
} 