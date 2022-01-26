import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct ChartColor<T: ShapeStyle> {
    var value: T
    
    init(color: T) where T == Color {
        self.value = color
    }
    
    static func generateColors(with color: T, count: Int, opacity: Double = 1.0) -> [T] where T == Color {
        var colors: [T] = []
        
        let gap: Double = 1 / 12
        for i in 0..<count {
            colors.append(.init(hue: Double(i) * gap, saturation: 0.87, lightness: 0.57, opacity: opacity))
        }
        return colors
    }
}

/// Some predefined colors, used for demos, defaults if color is missing, and data indicator point
extension ChartColor where T == Color {
    // Orange
    public static let orangeBright = Color(hexString: "#FF782C")
    public static let orangeDark = Color(hexString: "#EC2301")

    public static let legendColor: Color = Color(hexString: "#E8E7EA")
    public static let indicatorKnob: Color = Color(hexString: "#FF57A6")
}


struct ChartColor_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            let colors = ChartColor.generateColors(with: .red, count: 5)
            ForEach(colors, id:\.self) { color in
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(color)
                    .frame(width: 100, height: 100, alignment: .center)
            }
        }
    }
}
