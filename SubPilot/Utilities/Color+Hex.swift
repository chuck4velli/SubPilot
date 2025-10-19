import SwiftUI

extension Color {
    init?(hex: String?) {
        guard let hex, !hex.isEmpty else { return nil }
        var hexSanitsized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitsized.hasPrefix("#") { hexSanitsized.removeFirst() }
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitsized).scanHexInt64(&rgb) else { return nil }
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self = Color(red: red, green: green, blue: blue)
    }
}
