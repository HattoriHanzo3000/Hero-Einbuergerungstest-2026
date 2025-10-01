import SwiftUI

// MARK: - Color Extensions
extension Color {
    /// Blend two colors together
    func blended(with other: Color, ratio: CGFloat) -> Color {
        let uiColor1 = UIColor(self)
        let uiColor2 = UIColor(other)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let blendedR = r1 + (r2 - r1) * ratio
        let blendedG = g1 + (g2 - g1) * ratio
        let blendedB = b1 + (b2 - b1) * ratio
        let blendedA = a1 + (a2 - a1) * ratio
        
        return Color(red: Double(blendedR), green: Double(blendedG), blue: Double(blendedB), opacity: Double(blendedA))
    }
}
