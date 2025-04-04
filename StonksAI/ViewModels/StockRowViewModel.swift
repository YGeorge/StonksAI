import Foundation

class StockRowViewModel {
    private let stock: StockQuote
    
    init(stock: StockQuote) {
        self.stock = stock
    }
    
    var symbol: String {
        stock.symbol
    }
    
    var closePrice: Double {
        stock.close
    }
    
    var openPrice: Double {
        stock.open
    }
    
    var highPrice: Double {
        stock.high
    }
    
    var lowPrice: Double {
        stock.low
    }
    
    var priceChange: Double {
        closePrice - openPrice
    }
    
    var priceChangePercentage: Double {
        (priceChange / openPrice) * 100
    }
    
    var isPriceUp: Bool {
        priceChange >= 0
    }
    
    // Formatted strings
    var closePriceFormatted: String {
        String(format: "%.2f", closePrice)
    }
    
    var openPriceFormatted: String {
        String(format: "%.2f", openPrice)
    }
    
    var highPriceFormatted: String {
        String(format: "%.2f", highPrice)
    }
    
    var lowPriceFormatted: String {
        String(format: "%.2f", lowPrice)
    }
    
    var priceChangeFormatted: String {
        String(format: "%+.2f", priceChange)
    }
    
    var priceChangePercentageFormatted: String {
        String(format: "%+.1f%%", priceChangePercentage)
    }
    
    var priceChangeText: String {
        "\(priceChangeFormatted) (\(priceChangePercentageFormatted))"
    }
} 