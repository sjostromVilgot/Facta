import SwiftUI

// MARK: - Color Tokens
struct DesignTokens {
    // Primary Colors
    static let primary = Color(hex: "#6C5CE7")
    static let secondary = Color(hex: "#00D1B2")
    static let accent = Color(hex: "#FFC107")
    
    // Theme Colors
    static let mintAccent = Color(hex: "#3EB489")
    static let oceanAccent = Color(hex: "#4D9DE0")
    static let sunsetAccent = Color(hex: "#FF6B6B")
    
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
    
    // Theme Colors
    static let mintAccent = DesignTokens.mintAccent
    static let oceanAccent = DesignTokens.oceanAccent
    static let sunsetAccent = DesignTokens.sunsetAccent
    
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
    static let largeTitle = Font.custom("Geist-Bold", size: 34)
    
    // Section Headers
    static let title1 = Font.custom("Geist-Bold", size: 28)
    static let title2 = Font.custom("Geist-Bold", size: 22)
    static let title3 = Font.custom("Geist-SemiBold", size: 20)
    
    // Headlines
    static let headline = Font.custom("Geist-SemiBold", size: 17)
    static let subheadline = Font.custom("Geist-Medium", size: 15)
    
    // Body Text
    static let body = Font.custom("Geist-Regular", size: 17)
    static let callout = Font.custom("Geist-Medium", size: 16)
    
    // Small Labels
    static let caption = Font.custom("Geist-Medium", size: 12)
    static let footnote = Font.custom("Geist-Regular", size: 13)
    
    // Button Text
    static let button = Font.custom("Geist-SemiBold", size: 16)
    static let buttonSmall = Font.custom("Geist-Medium", size: 14)
    
    // Additional weights
    static let light = Font.custom("Geist-Light", size: 17)
    static let extraLight = Font.custom("Geist-ExtraLight", size: 17)
    static let extraBold = Font.custom("Geist-ExtraBold", size: 17)
    static let black = Font.custom("Geist-Black", size: 17)
}

// MARK: - UI Constants
struct UI {
    // Corner Radius
    static let corner: CGFloat = 16
    
    // Padding
    struct Padding {
        static let small: CGFloat = 12.0
        static let medium: CGFloat = 20.0
        static let large: CGFloat = 32.0
        static let extraLarge: CGFloat = 40.0
    }
    
    // Spacing
    struct Spacing {
        static let small: CGFloat = 12.0
        static let medium: CGFloat = 20.0
        static let large: CGFloat = 32.0
        static let extraLarge: CGFloat = 40.0
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