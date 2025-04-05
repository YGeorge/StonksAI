import SwiftUI

// MARK: - TimeScale Enum
enum TimeScale: String {
    case week = "Week"
    case month = "Month"
    case sixMonths = "6 Months"
    
    var daysToShow: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .sixMonths: return 180
        }
    }
}

struct TimeScaleButton: View {
    let scale: TimeScale
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(scale.rawValue)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.backgroundColor)
                .foregroundColor(isSelected ? AppTheme.positiveColor : .white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.textColor.opacity(0.3), lineWidth: 1)
                )
        }
    }
} 
