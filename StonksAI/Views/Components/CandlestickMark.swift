import SwiftUI
import Charts

// MARK: - Candlestick Mark Content
struct CandlestickMarkContent: ChartContent {
    let quote: StockQuote
    let width: CGFloat
    let color: Color
    
    var body: some ChartContent {
        // Candlestick body
        RectangleMark(
            x: .value("Date", quote.dateObject),
            yStart: .value("Open", quote.open),
            yEnd: .value("Close", quote.close),
            width: .fixed(width)
        )
        .foregroundStyle(color)
        
        // Upper wick
        RuleMark(
            x: .value("Date", quote.dateObject),
            yStart: .value("High", quote.high),
            yEnd: .value("Body Top", max(quote.open, quote.close))
        )
        .foregroundStyle(color)
        .lineStyle(StrokeStyle(lineWidth: 1))
        
        // Lower wick
        RuleMark(
            x: .value("Date", quote.dateObject),
            yStart: .value("Body Bottom", min(quote.open, quote.close)),
            yEnd: .value("Low", quote.low)
        )
        .foregroundStyle(color)
        .lineStyle(StrokeStyle(lineWidth: 1))
    }
} 