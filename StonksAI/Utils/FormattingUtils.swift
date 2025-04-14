import Foundation

class FormattingUtils {
    static func formatVolume(_ volume: Int?) -> String {
        guard let volume = volume else {
            return "N/A"
        }
        
        if volume >= 999_900_000 {
            return String(format: "%.1fB", Double(volume) / 1_000_000_000)
        } else if volume >= 999_900 {
            return String(format: "%.1fM", Double(volume) / 1_000_000)
        } else if volume >= 990 {
            return String(format: "%.1fK", Double(volume) / 1_000)
        } else {
            return String(format: "%.0f", Double(volume))
        }
    }
} 