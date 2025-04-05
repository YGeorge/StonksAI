import SwiftUI
import Charts

// MARK: - Candlestick Chart View
struct CandlestickChart: View {
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
        
        // Calculate volume range for the volume chart
        let volumeRange = calculateVolumeRange(from: filteredData)
        
        return VStack(spacing: 16) {
            // Price Chart
            Chart(filteredData) { quote in
                // Candlestick body
                RectangleMark(
                    x: .value("Date", DateFormatterService.shared.dateFromISOString(quote.date)),
                    yStart: .value("Open", quote.open),
                    yEnd: .value("Close", quote.close),
                    width: .fixed(styleProvider.getCandlestickWidth(for: filteredData.count))
                )
                .foregroundStyle(styleProvider.getCandlestickColor(for: quote))
                
                // Upper wick
                RuleMark(
                    x: .value("Date", DateFormatterService.shared.dateFromISOString(quote.date)),
                    yStart: .value("High", quote.high),
                    yEnd: .value("Body Top", max(quote.open, quote.close))
                )
                .foregroundStyle(styleProvider.getCandlestickColor(for: quote))
                .lineStyle(StrokeStyle(lineWidth: 1))
                
                // Lower wick
                RuleMark(
                    x: .value("Date", DateFormatterService.shared.dateFromISOString(quote.date)),
                    yStart: .value("Body Bottom", min(quote.open, quote.close)),
                    yEnd: .value("Low", quote.low)
                )
                .foregroundStyle(styleProvider.getCandlestickColor(for: quote))
                .lineStyle(StrokeStyle(lineWidth: 1))
            }
            .frame(height: 250)
            .chartYScale(domain: yAxisRange.min...yAxisRange.max)
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .automatic(desiredCount: 5)) { value in
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
                AxisMarks(preset: .aligned, values: .automatic(desiredCount: 5)) { value in
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
            
            // Volume Chart
            if !filteredData.isEmpty && filteredData.contains(where: { $0.volume != nil }) {
                Chart(filteredData) { quote in
                    if let volume = quote.volume {
                        RectangleMark(
                            x: .value("Date", DateFormatterService.shared.dateFromISOString(quote.date)),
                            yStart: .value("Volume", 0),
                            yEnd: .value("Volume", volume),
                            width: .fixed(styleProvider.getCandlestickWidth(for: filteredData.count))
                        )
                        .foregroundStyle(styleProvider.getVolumeColor(for: quote))
                    }
                }
                .frame(height: 50)
                .chartYScale(domain: 0...volumeRange.max)
                .chartXAxis {
                    AxisMarks(preset: .aligned, values: .automatic(desiredCount: 5)) { value in
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
                    AxisMarks(preset: .aligned, values: .automatic(desiredCount: 3)) { value in
                        AxisGridLine()
                            .foregroundStyle(AppTheme.textColor.opacity(0.3))
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text(formatVolume(Int(doubleValue)))
                                    .font(.caption)
                            }
                        }
                        .foregroundStyle(AppTheme.textColor)
                    }
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
    
    // Helper function to calculate volume range
    private func calculateVolumeRange(from data: [StockQuote]) -> (min: Double, max: Double) {
        let volumes = data.compactMap { $0.volume }
        guard !volumes.isEmpty else { return (min: 0, max: 100) }
        
        let maxVolume = Double(volumes.max() ?? 0)
        return (min: 0, max: maxVolume * 1.1) // Add 10% padding
    }
    
    // Helper function to format volume values
    private func formatVolume(_ volume: Int) -> String {
        if volume >= 1_000_000_000 {
            return String(format: "%.1fB", Double(volume) / 1_000_000_000)
        } else if volume >= 1_000_000 {
            return String(format: "%.1fM", Double(volume) / 1_000_000)
        } else if volume >= 1_000 {
            return String(format: "%.1fK", Double(volume) / 1_000)
        } else {
            return String(format: "%.0f", Double(volume))
        }
    }
} 