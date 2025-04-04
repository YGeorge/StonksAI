import Foundation

enum LogLevel: String {
    case debug = "🔵"
    case info = "🟢"
    case warning = "🟡"
    case error = "🔴"
}

class LoggerService {
    static let shared = LoggerService()
    
    private init() {} // Singleton
    
    func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logMessage = "\(level.rawValue) [\(timestamp)] [\(fileName):\(line)] \(function): \(message)"
        
        #if DEBUG
        print(logMessage)
        #endif
        
        // Here you could add additional logging destinations
        // - File logging
        // - Remote logging service
        // - Analytics
    }
    
    // Convenience methods
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
} 