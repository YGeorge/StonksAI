import Foundation

class MarketstackService {
    private let apiKey = "51888202425ebfa81d7d67452432570d"
    private let baseURL = "http://api.marketstack.com/v2"
    private let timeout: TimeInterval = 30
    private let logger = LoggerService.shared
    
    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        return URLSession(configuration: configuration)
    }()
    
    func fetchEndOfDayData(for symbols: [String]) async throws -> [StockQuote] {
        let symbolsString = symbols.joined(separator: ",")
        let urlString = "\(baseURL)/eod?access_key=\(apiKey)&symbols=\(symbolsString)&limit=20"
        
        guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedString) else {
            logger.error("Invalid URL: \(urlString)")
            throw MarketstackError.invalidURL
        }
        
        logger.info("Starting EOD API request for symbols: \(symbols)")
        logger.debug("URL: \(url)")
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid response type")
                throw MarketstackError.apiError("Invalid response")
            }
            
            logger.info("Received response with status code: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                logger.debug("Response body: \(responseString)")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                logger.error("API error with status code: \(httpResponse.statusCode)")
                throw MarketstackError.apiError("API error with status code: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(MarketstackResponse.self, from: data)
                logger.info("Successfully decoded \(response.data.count) stock quotes")
                return response.data
            } catch {
                logger.error("Decoding error: \(error.localizedDescription)")
                throw MarketstackError.decodingError
            }
        } catch {
            logger.error("Network error: \(error.localizedDescription)")
            throw MarketstackError.networkError(error)
        }
    }
    
    func fetchHistoricalData(for symbol: String, months: Int = 3) async throws -> [StockQuote] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let toDate = Date()
        let fromDate = Calendar.current.date(byAdding: .month, value: -months, to: toDate)!
        
        let urlString = "\(baseURL)/eod?access_key=\(apiKey)&symbols=\(symbol)&date_from=\(dateFormatter.string(from: fromDate))&date_to=\(dateFormatter.string(from: toDate))&sort=desc"
        
        guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedString) else {
            logger.error("Invalid URL for historical data: \(urlString)")
            throw MarketstackError.invalidURL
        }
        
        logger.info("Starting historical data request for symbol: \(symbol)")
        logger.debug("URL: \(url)")
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid response type")
                throw MarketstackError.apiError("Invalid response")
            }
            
            logger.info("Received response with status code: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                logger.debug("Response body: \(responseString)")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                logger.error("API error with status code: \(httpResponse.statusCode)")
                throw MarketstackError.apiError("API error with status code: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(MarketstackResponse.self, from: data)
                logger.info("Successfully decoded \(response.data.count) historical quotes")
                return response.data
            } catch {
                logger.error("Decoding error: \(error.localizedDescription)")
                throw MarketstackError.decodingError
            }
        } catch {
            logger.error("Network error: \(error.localizedDescription)")
            throw MarketstackError.networkError(error)
        }
    }
    
    func fetchIntradayData(for symbols: [String]) async throws -> [StockQuote] {
        let symbolsString = symbols.joined(separator: ",")
        let urlString = "\(baseURL)/intraday?access_key=\(apiKey)&symbols=\(symbolsString)&limit=20"
        
        guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedString) else {
            logger.error("Invalid URL: \(urlString)")
            throw MarketstackError.invalidURL
        }
        
        logger.info("Starting intraday API request for symbols: \(symbols)")
        logger.debug("URL: \(url)")
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid response type")
                throw MarketstackError.apiError("Invalid response")
            }
            
            logger.info("Received response with status code: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                logger.debug("Response body: \(responseString)")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                logger.error("API error with status code: \(httpResponse.statusCode)")
                throw MarketstackError.apiError("API error with status code: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(MarketstackResponse.self, from: data)
                logger.info("Successfully decoded \(response.data.count) intraday quotes")
                return response.data
            } catch {
                logger.error("Decoding error: \(error.localizedDescription)")
                throw MarketstackError.decodingError
            }
        } catch {
            logger.error("Network error: \(error.localizedDescription)")
            throw MarketstackError.networkError(error)
        }
    }
} 
