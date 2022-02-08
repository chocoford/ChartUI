import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    init(_ colorSpace: RGBColorSpace = .sRGB,
         r: Int, g: Int, b: Int, a: Double = 1) {
        self.init(colorSpace, red: Double(r) / 255.0, green: Double(g) / 255.0, blue: Double(b) / 255.0, opacity: a)
    }
    
	/// Create a `Color` from a hexadecimal representation
	/// - Parameter hexString: 3, 6, or 8-character string, with optional (ignored) punctuation such as "#"
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (red, green, blue) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (red, green, blue) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            // FIXME: I think we need an an alpha value on this one. See link below.
            // https://stackoverflow.com/a/56874327/4475605
            (red, green, blue) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (red, green, blue) = (0, 0, 0)
        }
        self.init(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
    }
    
    init(hue: Double, saturation: Double, lightness: Double, opacity: Double = 1) {
        precondition(0...1 ~= hue &&
                     0...1 ~= saturation &&
                     0...1 ~= lightness &&
                     0...1 ~= opacity, "input range is out of range 0...1")
        
        //From HSL TO HSB ---------
        var newSaturation: Double = 0.0
        
        let brightness = lightness + saturation * min(lightness, 1-lightness)
        
        if brightness == 0 { newSaturation = 0.0 }
        else {
            newSaturation = 2 * (1 - lightness / brightness)
        }
        //---------
        
        self.init(hue: hue, saturation: newSaturation, brightness: brightness, opacity: opacity)
    }
    
    var rgbaComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        
#if canImport(UIKit)
        typealias NativeColor = UIColor
#elseif canImport(AppKit)
        typealias NativeColor = NSColor
#endif
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)
        
        return (r, g, b, o)
    }
    
    var hsbaComponents: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, opacity: CGFloat) {
        
#if canImport(UIKit)
        typealias NativeColor = UIColor
#elseif canImport(AppKit)
        typealias NativeColor = NSColor
#endif
        
        var r: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        NativeColor(self).getHue(&r, saturation: &s, brightness: &b, alpha: &o)
        
        return (r, s, b, o)
    }
}
