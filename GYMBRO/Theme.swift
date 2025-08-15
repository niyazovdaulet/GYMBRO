import SwiftUI

// MARK: - Underground Dark Theme
struct UndergroundTheme {
    // Background Colors
    static let primaryBackground = Color(red: 0.08, green: 0.08, blue: 0.12) // Very dark grey
    static let secondaryBackground = Color(red: 0.12, green: 0.12, blue: 0.16) // Dark grey
    static let cardBackground = Color(red: 0.16, green: 0.16, blue: 0.20) // Medium dark grey
    static let elevatedBackground = Color(red: 0.20, green: 0.20, blue: 0.24) // Slightly lighter grey
    
    // Text Colors
    static let primaryText = Color.white
    static let secondaryText = Color(red: 0.7, green: 0.7, blue: 0.7) // Light grey
    static let mutedText = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium grey
    
    // Accent Colors
    static let primaryAccent = Color(red: 0.2, green: 0.8, blue: 0.4) // Neon green
    static let secondaryAccent = Color(red: 0.8, green: 0.4, blue: 0.2) // Neon orange
    static let tertiaryAccent = Color(red: 0.4, green: 0.2, blue: 0.8) // Neon purple
    
    // Border and Divider Colors
    static let borderColor = Color(red: 0.3, green: 0.3, blue: 0.3) // Dark grey border
    static let dividerColor = Color(red: 0.25, green: 0.25, blue: 0.25) // Medium grey divider
    
    // Shadow Colors
    static let shadowColor = Color.black.opacity(0.4)
    static let glowColor = Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.3) // Neon green glow
    
    // Gradient Colors
    static let gradientStart = Color(red: 0.08, green: 0.08, blue: 0.12)
    static let gradientEnd = Color(red: 0.12, green: 0.12, blue: 0.16)
    
    // Status Colors
    static let successColor = Color(red: 0.2, green: 0.8, blue: 0.4) // Neon green
    static let errorColor = Color(red: 0.8, green: 0.2, blue: 0.2) // Neon red
    static let warningColor = Color(red: 0.8, green: 0.6, blue: 0.2) // Neon yellow
}

// MARK: - Theme Extensions
extension Color {
    static let undergroundPrimary = UndergroundTheme.primaryBackground
    static let undergroundSecondary = UndergroundTheme.secondaryBackground
    static let undergroundCard = UndergroundTheme.cardBackground
    static let undergroundElevated = UndergroundTheme.elevatedBackground
    
    static let undergroundText = UndergroundTheme.primaryText
    static let undergroundTextSecondary = UndergroundTheme.secondaryText
    static let undergroundTextMuted = UndergroundTheme.mutedText
    
    static let undergroundAccent = UndergroundTheme.primaryAccent
    static let undergroundAccentSecondary = UndergroundTheme.secondaryAccent
    static let undergroundAccentTertiary = UndergroundTheme.tertiaryAccent
    
    static let undergroundBorder = UndergroundTheme.borderColor
    static let undergroundDivider = UndergroundTheme.dividerColor
    static let undergroundShadow = UndergroundTheme.shadowColor
    static let undergroundGlow = UndergroundTheme.glowColor
}

// MARK: - Custom View Modifiers
struct UndergroundCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.undergroundCard)
            .cornerRadius(16)
            .shadow(color: Color.undergroundShadow, radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.undergroundBorder, lineWidth: 1)
            )
    }
}

struct UndergroundGlowStyle: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 0)
    }
}

extension View {
    func undergroundCard() -> some View {
        self.modifier(UndergroundCardStyle())
    }
    
    func undergroundGlow(color: Color = Color.undergroundAccent) -> some View {
        self.modifier(UndergroundGlowStyle(color: color))
    }
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.undergroundCard)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.undergroundBorder, lineWidth: 1)
            )
            .foregroundColor(Color.undergroundText)
    }
} 