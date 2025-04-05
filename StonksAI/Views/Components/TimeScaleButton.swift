import SwiftUI

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