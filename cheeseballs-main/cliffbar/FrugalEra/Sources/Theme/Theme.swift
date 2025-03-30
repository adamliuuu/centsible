import SwiftUI

public struct Theme {
    public static let colors = AppColors.self
}

public struct AppColors {
    public static let primary = Color(hex: "FF6B6B") // Coral red
    public static let secondary = Color(hex: "4ECDC4") // Turquoise
    public static let accent = Color(hex: "FFE66D") // Yellow
    public static let background = Color(hex: "f7ecd7") // Warm cream
    public static let cardBackground = Color.white
    public static let text = Color.black // Changed from soft blue-gray to black
    public static let textSecondary = Color.black.opacity(0.7) // Changed from gray to black with opacity
    
    // Gradient colors
    public static let gradientStart = Color(hex: "FF6B6B")
    public static let gradientEnd = Color(hex: "4ECDC4")
    
    // Status colors
    public static let success = Color(hex: "2ECC71") // Green
    public static let warning = Color(hex: "F1C40F") // Yellow
    public static let error = Color(hex: "E74C3C") // Red
    
    // Feed post colors
    public static let feedColor1 = Color(hex: "D0C3F1") // Soft purple
    public static let feedColor2 = Color(hex: "E9F9E5") // Mint green
    public static let feedColor3 = Color(hex: "CEEEF8") // Light blue
    public static let feedColor4 = Color(hex: "FFD7EE") // Pink
    public static let feedColor5 = Color(hex: "FEF1AB") // Light yellow
    
    public static let feedColors: [Color] = [
        feedColor1,
        feedColor2,
        feedColor3,
        feedColor4,
        feedColor5
    ]
}

extension Color {
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