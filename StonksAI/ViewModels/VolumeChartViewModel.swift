import SwiftUI
import Combine

// MARK: - Volume Chart View Model
class VolumeChartViewModel: ObservableObject {
    private let dataProvider: ChartDataProvider
    private let volumeProvider: VolumeChartProvider
    private let timeScale: TimeScale
    
    @Published var filteredData: [StockQuote] = []
    @Published var volumeRange: (min: Double, max: Double) = (min: 0, max: 100)
    @Published var xAxisLabelCount: Int = 5
    
    init(dataProvider: ChartDataProvider, 
         volumeProvider: VolumeChartProvider,
         timeScale: TimeScale) {
        self.dataProvider = dataProvider
        self.volumeProvider = volumeProvider
        self.timeScale = timeScale
        
        updateData()
    }
    
    func updateTimeScale(_ newTimeScale: TimeScale) {
        if newTimeScale != timeScale {
            updateData()
        }
    }
    
    private func updateData() {
        filteredData = dataProvider.getFilteredData(for: timeScale)
        volumeRange = volumeProvider.getVolumeRange(from: filteredData)
    }
    
    // Helper functions that delegate to the volume provider
    func formatVolume(_ volume: Int) -> String {
        return volumeProvider.formatVolume(volume)
    }
    
    func getBarWidth(for dataCount: Int) -> CGFloat {
        return volumeProvider.getBarWidth(for: dataCount)
    }
    
    func getBarColor(for quote: StockQuote) -> Color {
        return volumeProvider.getBarColor(for: quote)
    }
} 
