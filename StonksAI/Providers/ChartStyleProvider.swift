import SwiftUI

// MARK: - Chart Style Provider Protocol
protocol ChartStyleProvider {
    func getLineWidth(for dataCount: Int) -> CGFloat
    func getColor(for quote: StockQuote) -> Color
    
    // New methods for candlestick styling
    func getCandlestickWidth(for dataCount: Int) -> CGFloat
    func getCandlestickColor(for quote: StockQuote) -> Color
    func getVolumeColor(for quote: StockQuote) -> Color
}

// MARK: - Chart Style Provider Implementation
class StockChartStyleProvider: ChartStyleProvider {
    func getLineWidth(for dataCount: Int) -> CGFloat {
        switch dataCount {
        case 0...7: return 8    // Wider lines for weekly view
        case 8...30: return 4   // Medium width for monthly view
        default: return 2       // Thinner lines for 6-month view
        }
    }
    
    func getColor(for quote: StockQuote) -> Color {
        quote.close < quote.open ? AppTheme.negativeColor : AppTheme.positiveColor
    }
    
    // Implementation for candlestick styling
    func getCandlestickWidth(for dataCount: Int) -> CGFloat {
        switch dataCount {
        case 0...7: return 12   // Wider candlesticks for weekly view
        case 8...30: return 8   // Medium width for monthly view
        default: return 4       // Thinner candlesticks for 6-month view
        }
    }
    
    func getCandlestickColor(for quote: StockQuote) -> Color {
        // For candlesticks, we use the traditional color scheme:
        // - Bullish (close > open): Green or white
        // - Bearish (close < open): Red or black
        quote.close > quote.open ? AppTheme.positiveColor : AppTheme.negativeColor
    }
    
    func getVolumeColor(for quote: StockQuote) -> Color {
        // Volume color is typically based on the price movement
        // - Green for bullish days
        // - Red for bearish days
        // But with reduced opacity to be less prominent than the candlesticks
        let baseColor = quote.close > quote.open ? AppTheme.positiveColor : AppTheme.negativeColor
        return baseColor.opacity(0.5)
    }
} 