import SwiftUI
import Charts

// MARK: - Volume Chart Provider Protocol
protocol VolumeChartProvider {
    /// Calculates the volume range for the chart
    func getVolumeRange(from data: [StockQuote]) -> (min: Double, max: Double)
    
    /// Formats a volume value for display
    func formatVolume(_ volume: Int) -> String
    
    /// Gets the width for volume bars based on data count
    func getBarWidth(for dataCount: Int) -> CGFloat
    
    /// Gets the color for a volume bar based on the quote
    func getBarColor(for quote: StockQuote) -> Color
}

// MARK: - Stock Volume Chart Provider Implementation
class StockVolumeChartProvider: VolumeChartProvider {
    private let styleProvider: ChartStyleProvider
    
    init(styleProvider: ChartStyleProvider) {
        self.styleProvider = styleProvider
    }
    
    func getVolumeRange(from data: [StockQuote]) -> (min: Double, max: Double) {
        let volumes = data.compactMap { $0.volume }
        guard !volumes.isEmpty else { return (min: 0, max: 100) }
        
        let maxVolume = Double(volumes.max() ?? 0)
        // Use consistent 20% padding for all time scales
        let padding = 1.2 // 20% padding
        return (min: 0, max: maxVolume * padding)
    }
    
    func formatVolume(_ volume: Int) -> String {
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
    
    func getBarWidth(for dataCount: Int) -> CGFloat {
        return styleProvider.getCandlestickWidth(for: dataCount)
    }
    
    func getBarColor(for quote: StockQuote) -> Color {
        return styleProvider.getVolumeColor(for: quote)
    }
} 