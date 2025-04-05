import SwiftUI

// MARK: - Chart Style Provider Protocol
protocol ChartStyleProvider {
    func getLineWidth(for dataCount: Int) -> CGFloat
    func getColor(for quote: StockQuote) -> Color
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
} 