import Foundation

// MARK: - RSI Service
class RSIService {
    static let shared = RSIService()
    
    private init() {}
    
    /// Calculates the Relative Strength Index (RSI) for a given period
    /// - Parameters:
    ///   - data: Array of stock quotes
    ///   - period: RSI period (default is 14)
    /// - Returns: Array of RSI values with corresponding dates
    func calculateRSI(data: [StockQuote], period: Int = 14) -> [RSIDataPoint] {
        guard data.count > period else { return [] }
        
        // Sort data by date to ensure chronological order
        let sortedData = data.sorted { $0.dateObject < $1.dateObject }
        
        var rsiDataPoints: [RSIDataPoint] = []
        
        // Calculate price changes
        var priceChanges: [Double] = []
        for i in 1..<sortedData.count {
            let change = sortedData[i].close - sortedData[i-1].close
            priceChanges.append(change)
        }
        
        // Calculate RSI for each point after the initial period
        for i in period..<sortedData.count {
            let windowChanges = Array(priceChanges[(i-period)..<i])
            
            // Separate gains and losses
            let gains = windowChanges.map { max($0, 0) }
            let losses = windowChanges.map { max(-$0, 0) }
            
            // Calculate average gain and loss
            let avgGain = gains.reduce(0, +) / Double(period)
            let avgLoss = losses.reduce(0, +) / Double(period)
            
            // Calculate RS and RSI
            let rs = avgLoss == 0 ? 100.0 : avgGain / avgLoss
            let rsi = 100.0 - (100.0 / (1.0 + rs))
            
            // Create data point
            let dataPoint = RSIDataPoint(
                date: sortedData[i].dateObject,
                value: rsi
            )
            
            rsiDataPoints.append(dataPoint)
        }
        
        return rsiDataPoints
    }
}

// MARK: - RSI Data Point
struct RSIDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
} 