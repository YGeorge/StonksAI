import SwiftUI
import Charts

// MARK: - Volume Chart View
struct VolumeChart: View {
    @ObservedObject var viewModel: VolumeChartViewModel
    
    var body: some View {
        if !viewModel.filteredData.isEmpty && viewModel.filteredData.contains(where: { $0.volume != nil }) {
            Chart(viewModel.filteredData) { quote in
                if let volume = quote.volume {
                    RectangleMark(
                        x: .value("Date", quote.dateObject),
                        yStart: .value("Volume", 0),
                        yEnd: .value("Volume", volume),
                        width: .fixed(viewModel.getBarWidth(for: viewModel.filteredData.count))
                    )
                    .foregroundStyle(viewModel.getBarColor(for: quote))
                }
            }
            .frame(height: 50)
            .chartYScale(domain: 0...viewModel.volumeRange.max)
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .automatic(desiredCount: viewModel.xAxisLabelCount)) { value in
                    AxisGridLine()
                        .foregroundStyle(AppTheme.textColor.opacity(0.3))
                }
            }
            .chartYAxis {
                AxisMarks(preset: .aligned, values: .automatic(desiredCount: 3)) { value in
                    AxisGridLine()
                        .foregroundStyle(AppTheme.textColor.opacity(0.3))
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text(viewModel.formatVolume(Int(doubleValue)))
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(AppTheme.textColor)
                }
            }
        }
    }
} 
