import SwiftUI

// MARK: - Color Tokens
struct DesignTokens {
    // Primary Colors
    static let primary = Color(hex: "#6C5CE7")
    static let secondary = Color(hex: "#00D1B2")
    static let accent = Color(hex: "#FFC107")
    
    // Background Colors
    static let background = Color(.systemBackground)
    static let backgroundDark = Color.black
    
    // Foreground Colors
    static let foreground = Color(.label)
    static let foregroundDark = Color.white
    
    // Muted Colors
    static let muted = Color(.systemGray6)
    static let mutedForeground = Color(.secondaryLabel)
    
    // Destructive Color
    static let destructive = Color(.systemRed)
}

// MARK: - Color Extensions
extension Color {
    // Primary Colors
    static let primary = DesignTokens.primary
    static let secondary = DesignTokens.secondary
    static let accent = DesignTokens.accent
    
    // Background Colors
    static let background = DesignTokens.background
    static let backgroundDark = DesignTokens.backgroundDark
    
    // Foreground Colors
    static let foreground = DesignTokens.foreground
    static let foregroundDark = DesignTokens.foregroundDark
    
    // Muted Colors
    static let muted = DesignTokens.muted
    static let mutedForeground = DesignTokens.mutedForeground
    
    // Destructive Color
    static let destructive = DesignTokens.destructive
    
    // Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography
struct Typography {
    // Large Title
    static let largeTitle = Font.largeTitle.bold()
    
    // Section Headers
    static let title2 = Font.title2
    static let title3 = Font.title3
    
    // Body Text
    static let body = Font.body
    
    // Small Labels
    static let caption = Font.caption
}

// MARK: - UI Constants
struct UI {
    // Corner Radius
    static let corner: CGFloat = 16
    
    // Padding
    struct Padding {
        static let small: CGFloat = 8.0
        static let medium: CGFloat = 16.0
        static let large: CGFloat = 24.0
    }
    
    // Spacing
    struct Spacing {
        static let small: CGFloat = 8.0
        static let medium: CGFloat = 16.0
        static let large: CGFloat = 24.0
        static let extraLarge: CGFloat = 32.0
    }
    
    // Sizes
    struct Size {
        static let buttonHeight: CGFloat = 44
        static let cardHeight: CGFloat = 120
        static let iconSize: CGFloat = 24
        static let largeIconSize: CGFloat = 32
    }
}

// MARK: - Theme Support
extension Color {
    // Dynamic colors that adapt to light/dark mode
    static let adaptiveBackground = Color(.systemBackground)
    static let adaptiveForeground = Color(.label)
    static let adaptiveSecondary = Color(.secondaryLabel)
    static let adaptiveTertiary = Color(.tertiaryLabel)
    static let adaptiveSeparator = Color(.separator)
    static let adaptiveFill = Color(.systemFill)
    static let adaptiveSecondaryFill = Color(.secondarySystemFill)
    static let adaptiveTertiaryFill = Color(.tertiarySystemFill)
}