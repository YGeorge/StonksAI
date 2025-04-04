import Foundation

@MainActor
class StocksViewModel: ObservableObject {
    @Published var stocks: [StockQuote] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = MarketstackService()
    private let logger = LoggerService.shared
//    private let defaultSymbols = ["AAPL", "MSFT", "GOOGL", "AMZN", "META", "TSLA", "NVDA", "INTC"]
    private let defaultSymbols = ["AAPL", "MSFT"]

    func fetchStocks() async {
        isLoading = true
        errorMessage = nil
        
        logger.info("Starting to fetch EOD data for symbols: \(defaultSymbols)")
        
        do {
            let allStocks = try await service.fetchEndOfDayData(for: defaultSymbols)
            logger.debug("Received \(allStocks.count) total quotes, processing to get latest data")
            
            // Group stocks by symbol and take the most recent one for each symbol
            stocks = Dictionary(grouping: allStocks, by: { $0.symbol })
                .compactMapValues { quotes in
                    quotes.sorted { $0.date > $1.date }.first
                }
                .values
                .sorted { $0.symbol < $1.symbol }
            
            logger.info("Successfully processed EOD data: showing latest quotes for \(stocks.count) symbols")
            stocks.forEach { stock in
                logger.debug("Symbol: \(stock.symbol), Date: \(stock.date), Close: \(stock.close)")
            }
            
        } catch let error as MarketstackError {
            errorMessage = error.userFriendlyDescription
            logger.error(errorMessage ?? "Unknown error")
        } catch {
            errorMessage = "Unexpected error occurred"
            logger.error("Unexpected error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}
