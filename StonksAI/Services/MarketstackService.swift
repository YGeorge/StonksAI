import Foundation

class MarketstackService {
    private let apiKey = "51888202425ebfa81d7d67452432570d"
    private let baseURL = "http://api.marketstack.com/v2"
    private let timeout: TimeInterval = 30
    private let logger = LoggerService.shared
    
    // Flag to switch between mock and real data
    private let useMockData = true
    
    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        return URLSession(configuration: configuration)
    }()
    
    // MARK: - Helper Functions
    private func makeEndpoint(_ path: String, queryItems: [URLQueryItem]) -> URL {
        URL(string:baseURL)!
            .appending(path: path)
            .appending(queryItems: [
                URLQueryItem(name: "access_key", value: apiKey)
            ] + queryItems)
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            logger.error("API error: HTTP \(statusCode)")
            throw MarketstackError.apiError("HTTP \(statusCode)")
        }
        logger.info("Successfully received data from API")
    }
    
    // MARK: - API Methods
    func fetchEndOfDayData(for symbols: [String]) async throws -> [StockQuote] {
        if useMockData {
            logger.info("Using mock data for symbols: \(symbols)")
            
            do {
                guard let mockData = MockData.stockData.data(using: .utf8) else {
                    throw MarketstackError.decodingError
                }
                
                let marketstackResponse = try JSONDecoder().decode(MarketstackResponse.self, from: mockData)
                let filteredData = marketstackResponse.data.filter { symbols.contains($0.symbol) }
                logger.info("Successfully decoded \(filteredData.count) mock stock quotes")
                return filteredData
            } catch {
                logger.error("Mock data decoding error: \(error)")
                throw MarketstackError.decodingError
            }
        }
        
        // Real API call
        let url = makeEndpoint("eod", queryItems: [
            URLQueryItem(name: "symbols", value: symbols.joined(separator: ","))
        ])
        
        logger.debug("Fetching EOD data for symbols: \(symbols)")
        logger.debug("URL: \(url)")
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            try validateResponse(response)
            
            let marketstackResponse = try JSONDecoder().decode(MarketstackResponse.self, from: data)
            logger.info("Successfully decoded \(marketstackResponse.data.count) stock quotes")
            return marketstackResponse.data
            
        } catch let error as DecodingError {
            logger.error("Decoding error: \(error)")
            throw MarketstackError.decodingError
        } catch {
            logger.error("Network error: \(error.localizedDescription)")
            throw MarketstackError.networkError(error)
        }
    }
    
    func fetchHistoricalData(for symbol: String, months: Int = 3) async throws -> [StockQuote] {
        if useMockData {
            logger.info("Using mock historical data for symbol: \(symbol)")
            
            do {
                guard let mockData = MockData.historicalData.data(using: .utf8) else {
                    throw MarketstackError.decodingError
                }
                
                let marketstackResponse = try JSONDecoder().decode(MarketstackResponse.self, from: mockData)
                let filteredData = marketstackResponse.data.filter { $0.symbol == symbol }
                logger.info("Successfully decoded \(filteredData.count) historical quotes for \(symbol)")
                return filteredData
                
            } catch {
                logger.error("Mock historical data decoding error: \(error)")
                throw MarketstackError.decodingError
            }
        }
        
        // Real API call implementation
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let toDate = Date()
        let fromDate = Calendar.current.date(byAdding: .month, value: -months, to: toDate)!
        
        let url = makeEndpoint("eod", queryItems: [
            URLQueryItem(name: "symbols", value: symbol),
            URLQueryItem(name: "date_from", value: dateFormatter.string(from: fromDate)),
            URLQueryItem(name: "date_to", value: dateFormatter.string(from: toDate)),
            URLQueryItem(name: "sort", value: "desc")
        ])
        
        logger.debug("Fetching historical data for symbol: \(symbol)")
        logger.debug("URL: \(url)")
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            try validateResponse(response)
            
            let marketstackResponse = try JSONDecoder().decode(MarketstackResponse.self, from: data)
            logger.info("Successfully decoded \(marketstackResponse.data.count) historical quotes")
            return marketstackResponse.data
            
        } catch let error as DecodingError {
            logger.error("Decoding error: \(error)")
            throw MarketstackError.decodingError
        } catch {
            logger.error("Network error: \(error)")
            throw MarketstackError.networkError(error)
        }
    }
} 
