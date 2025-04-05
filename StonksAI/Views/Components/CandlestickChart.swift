import SwiftUI
import Charts

// MARK: - Candlestick Chart View
struct CandlestickChart: View {
    private let data: [StockQuote]
    private let dataProvider: ChartDataProvider
    private let styleProvider: ChartStyleProvider
    private let showMA: Bool
    private let maPeriod: Int
    @State private var selectedTimeScale: TimeScale = .month
    
    init(data: [StockQuote], 
         dataProvider: ChartDataProvider? = nil,
         styleProvider: ChartStyleProvider = StockChartStyleProvider(),
         showMA: Bool = false,
         maPeriod: Int = 20) {
        self.data = data
        self.dataProvider = dataProvider ?? StockChartDataProvider(data: data)
        self.styleProvider = styleProvider
        self.showMA = showMA
        self.maPeriod = maPeriod
    }
    
    var body: some View {
        let filteredData = dataProvider.getFilteredData(for: selectedTimeScale)
        let yAxisRange = dataProvider.getYAxisRange(for: filteredData)
        
        // Calculate MA data if enabled
        let maData = showMA ? MovingAverageService.shared.calculateSMA(data: filteredData, period: maPeriod) : []
        
        // Determine the number of labels based on time scale
        let xAxisLabelCount = getLabelCount(for: selectedTimeScale)
        let yAxisLabelCount = getLabelCount(for: selectedTimeScale)
        
        return VStack(spacing: 16) {
            // Price Chart
            VStack(alignment: .leading, spacing: 4) {
                // Legend
                if showMA {
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Rectangle()
                                .fill(.blue)
                                .frame(width: 12, height: 2)
                            Text("MA(\(maPeriod))")
                                .font(.caption)
                                .foregroundColor(AppTheme.textColor)
                        }
                    }
                    .padding(.leading, 8)
                }
                
                Chart {
                    // Candlestick marks
                    ForEach(filteredData) { quote in
                        CandlestickMarkContent(
                            quote: quote,
                            width: styleProvider.getCandlestickWidth(for: filteredData.count),
                            color: styleProvider.getCandlestickColor(for: quote)
                        )
                    }
                    
                    // Moving Average line if enabled
                    if showMA && !maData.isEmpty {
                        ForEach(maData.indices, id: \.self) { index in
                            let maPoint = maData[index]
                            LineMark(
                                x: .value("Date", maPoint.date),
                                y: .value("MA", maPoint.value)
                            )
                            .foregroundStyle(.blue)
                            .lineStyle(StrokeStyle(lineWidth: 2))
                        }
                    }
                }
                .frame(height: 250)
                .chartYScale(domain: yAxisRange.min...yAxisRange.max)
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
                    AxisMarks(preset: .aligned, values: .automatic(desiredCount: yAxisLabelCount)) { value in
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
            }
            
            // Volume Chart
            let volumeProvider = StockVolumeChartProvider(styleProvider: styleProvider)
            let volumeViewModel = VolumeChartViewModel(
                dataProvider: dataProvider,
                volumeProvider: volumeProvider,
                timeScale: selectedTimeScale
            )
            VolumeChart(viewModel: volumeViewModel)
            
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
    
    // Helper function to determine the number of labels based on time scale
    private func getLabelCount(for timeScale: TimeScale) -> Int {
        switch timeScale {
        case .week:
            return 3  // Fewer labels for weekly view
        case .month:
            return 5  // Medium number of labels for monthly view
        case .sixMonths:
            return 5  // Same as monthly view for 6-month view
        }
    }
} 
