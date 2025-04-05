import Foundation

// MARK: - Moving Average Service
class MovingAverageService {
    // Singleton instance
    static let shared = MovingAverageService()
    
    // Private initialization to ensure singleton pattern
    private init() {}
    
    // Calculate Simple Moving Average (SMA) for a given period
    func calculateSMA(data: [StockQuote], period: Int) -> [(date: Date, value: Double)] {
        guard !data.isEmpty, period > 0, period <= data.count else {
            return []
        }
        
        // Sort data by date (oldest first)
        let sortedData = data.sorted { $0.dateObject < $1.dateObject }
        
        var result: [(date: Date, value: Double)] = []
        
        // Calculate SMA for each period
        for i in (period - 1)..<sortedData.count {
            let periodData = sortedData[(i - period + 1)...i]
            let sum = periodData.reduce(0) { $0 + $1.close }
            let average = sum / Double(period)
            
            result.append((date: sortedData[i].dateObject, value: average))
        }
        
        return result
    }
    
    // Calculate Exponential Moving Average (EMA) for a given period
    func calculateEMA(data: [StockQuote], period: Int) -> [(date: Date, value: Double)] {
        guard !data.isEmpty, period > 0, period <= data.count else {
            return []
        }
        
        // Sort data by date (oldest first)
        let sortedData = data.sorted { $0.dateObject < $1.dateObject }
        
        var result: [(date: Date, value: Double)] = []
        
        // Calculate multiplier
        let multiplier = 2.0 / Double(period + 1)
        
        // First EMA is SMA
        var ema = calculateSMA(data: Array(sortedData.prefix(period)), period: period).last?.value ?? 0
        
        // Add first EMA point
        let firstDate = sortedData[period - 1].dateObject
        result.append((date: firstDate, value: ema))
        
        // Calculate EMA for remaining points
        for i in period..<sortedData.count {
            let close = sortedData[i].close
            ema = (close - ema) * multiplier + ema
            result.append((date: sortedData[i].dateObject, value: ema))
        }
        
        return result
    }
} 