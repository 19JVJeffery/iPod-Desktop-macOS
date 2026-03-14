import SwiftUI

// MARK: - iPodColorScheme

/// All supported iPod device finish options, each carrying the exact gradient
/// and control colours that match the original ClassiPod Flutter palette.
enum iPodColorScheme: String, CaseIterable, Codable {
    case silver, black, red, orange, yellow, gold, lime, green, blue, pink, purple, brown

    var displayName: String {
        switch self {
        case .silver:  return "Silver"
        case .black:   return "Black"
        case .red:     return "Red"
        case .orange:  return "Orange"
        case .yellow:  return "Yellow"
        case .gold:    return "Gold"
        case .lime:    return "Lime"
        case .green:   return "Green"
        case .blue:    return "Blue"
        case .pink:    return "Pink"
        case .purple:  return "Purple"
        case .brown:   return "Brown"
        }
    }

    // MARK: Frame gradient (top → bottom)

    var frameTopColor: Color {
        switch self {
        case .silver:  return Color(hex: 0xF2F2F2)
        case .black:   return Color(hex: 0x939295)
        case .red:     return Color(hex: 0xE74954)
        case .orange:  return Color(hex: 0xFFE7B6)
        case .yellow:  return Color(hex: 0xFFF0B8)
        case .gold:    return Color(hex: 0xFFF3C3)
        case .lime:    return Color(hex: 0xE9FF87)
        case .green:   return Color(hex: 0xE0FF97)
        case .blue:    return Color(hex: 0x9FD3FF)
        case .pink:    return Color(hex: 0xFFD2EE)
        case .purple:  return Color(hex: 0xE6C9FF)
        case .brown:   return Color(hex: 0xF1E0D6)
        }
    }

    var frameBottomColor: Color {
        switch self {
        case .silver:  return Color(hex: 0xADADAD)
        case .black:   return Color(hex: 0x262527)
        case .red:     return Color(hex: 0x7C0015)
        case .orange:  return Color(hex: 0xE37400)
        case .yellow:  return Color(hex: 0xF2A300)
        case .gold:    return Color(hex: 0xB27700)
        case .lime:    return Color(hex: 0x3C9E00)
        case .green:   return Color(hex: 0x0E5C2A)
        case .blue:    return Color(hex: 0x0F4C9A)
        case .pink:    return Color(hex: 0xD10072)
        case .purple:  return Color(hex: 0x6A1B9A)
        case .brown:   return Color(hex: 0x8D6E63)
        }
    }

    // MARK: Control ring background

    var controlBackground: Color {
        switch self {
        case .silver:  return .white
        case .black:   return Color(hex: 0x212122)
        case .red:     return Color(hex: 0x050505)
        case .orange:  return .white
        case .yellow:  return Color(hex: 0x050505)
        case .gold:    return Color(hex: 0x050505)
        case .lime:    return .white
        case .green:   return Color(hex: 0x050505)
        case .blue:    return Color(hex: 0x1F61B3)
        case .pink:    return .white
        case .purple:  return Color(hex: 0x050505)
        case .brown:   return Color(hex: 0x4E342E)
        }
    }

    // MARK: Control ring border

    var controlBorderColor: Color {
        switch self {
        case .silver:  return Color(hex: 0xAEADAD)
        case .black:   return .black
        case .red:     return Color(hex: 0x1D1D1D)
        case .orange:  return Color(hex: 0xF9B54E)
        case .yellow:  return Color(hex: 0x1D1D1D)
        case .gold:    return Color(hex: 0x1D1D1D)
        case .lime:    return Color(hex: 0xA0D94B)
        case .green:   return Color(hex: 0x1D1D1D)
        case .blue:    return Color(hex: 0x3E7DD3)
        case .pink:    return Color(hex: 0xF5A0CE)
        case .purple:  return Color(hex: 0x1D1D1D)
        case .brown:   return Color(hex: 0xBCAAA4)
        }
    }

    // MARK: Inner button gradient

    var buttonGradientTop: Color {
        switch self {
        case .silver:  return Color(hex: 0xB1B1B0)
        case .black:   return Color(hex: 0x282829)
        case .red:     return Color(hex: 0xFF5F6D)
        case .orange:  return Color(hex: 0xFFE2A1)
        case .yellow:  return Color(hex: 0xFFEAA0)
        case .gold:    return Color(hex: 0xFFE28C)
        case .lime:    return Color(hex: 0xF2FFB5)
        case .green:   return Color(hex: 0xC8FF6E)
        case .blue:    return Color(hex: 0x4D8FE6)
        case .pink:    return Color(hex: 0xFFC4E9)
        case .purple:  return Color(hex: 0xF3DFFF)
        case .brown:   return Color(hex: 0x5D4037)
        }
    }

    var buttonGradientBottom: Color {
        switch self {
        case .silver:  return Color(hex: 0xE1E1E1)
        case .black:   return Color(hex: 0x676467)
        case .red:     return Color(hex: 0x9A001F)
        case .orange:  return Color(hex: 0xF59A28)
        case .yellow:  return Color(hex: 0xF2A300)
        case .gold:    return Color(hex: 0xD08900)
        case .lime:    return Color(hex: 0x6BC300)
        case .green:   return Color(hex: 0x4AA12A)
        case .blue:    return Color(hex: 0x1C4F9A)
        case .pink:    return Color(hex: 0xE20079)
        case .purple:  return Color(hex: 0xB04CCC)
        case .brown:   return Color(hex: 0x8D6E63)
        }
    }

    // MARK: Button icon / accent colour

    var buttonIconColor: Color {
        switch self {
        case .silver:  return Color(hex: 0x8793A0)
        case .black:   return .white
        case .red:     return Color(hex: 0xF7F7F2)
        case .orange:  return Color(hex: 0xE06600)
        case .yellow:  return Color(hex: 0xF7F7F2)
        case .gold:    return Color(hex: 0xF7F7F2)
        case .lime:    return Color(hex: 0x318100)
        case .green:   return Color(hex: 0xF7F7F2)
        case .blue:    return Color(hex: 0xF8FCFF)
        case .pink:    return Color(hex: 0xD00066)
        case .purple:  return Color(hex: 0xF7F7F2)
        case .brown:   return Color(hex: 0xEDE0D4)
        }
    }

    /// Whether the frame counts as a dark variant (affects screen colour handling).
    var isDark: Bool {
        switch self {
        case .black, .red, .green, .blue, .purple, .brown: return true
        default: return false
        }
    }

    /// Noise overlay opacity layered on top of the frame gradient.
    var noiseOpacity: Double {
        switch self {
        case .black:  return 0.3
        case .green:  return 0.6
        case .blue:   return 0.8
        case .brown:  return 0.8
        default:      return 1.0
        }
    }
}

// MARK: - Color helper

extension Color {
    /// Initialise a `Color` from a packed 0xRRGGBB integer literal.
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8)  & 0xFF) / 255
        let b = Double( hex        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
