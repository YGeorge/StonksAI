import SwiftUI
import Charts

// MARK: - RSI Chart View
struct RSIChart: View {
    private let data: [RSIDataPoint]
    private let period: Int
    private let xAxisLabelCount: Int
    
    init(data: [RSIDataPoint], period: Int, xAxisLabelCount: Int) {
        self.data = data
        self.period = period
        self.xAxisLabelCount = xAxisLabelCount
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("RSI")
                .font(.caption)
                .foregroundColor(AppTheme.textColor)
                .padding(.leading, 8)
            
            Chart {
                ForEach(data) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("RSI", point.value)
                    )
                    .foregroundStyle(.purple)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                
                // Add overbought/oversold lines
                RuleMark(y: .value("Overbought", 70))
                    .foregroundStyle(.red.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                
                RuleMark(y: .value("Oversold", 30))
                    .foregroundStyle(.green.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            }
            .frame(height: 100)
            .chartYScale(domain: 0...100)
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .automatic(desiredCount: xAxisLabelCount)) { value in
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
                            Text(String(format: "%.0f", doubleValue))
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(AppTheme.textColor)
                }
            }
        }
    }
} 