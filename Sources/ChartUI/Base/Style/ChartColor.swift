import SwiftUI

public struct ChartColor<T: ShapeStyle> {
    public var value: T
    public private(set) var isPlump: Bool = false
    
    @available(*, unavailable)
    public init(linearGradient gradient: T) where T == LinearGradient {
        self.value = gradient
    }
    
    @available(*, unavailable)
    public init(radialGradient gradient: T) where T == RadialGradient {
        self.value = gradient
    }
    
}

/// Some predefined colors, used for demos, defaults if color is missing, and data indicator point
extension ChartColor: Hashable, Equatable where T == Color {
    public static let primary: ChartColor = .init(color: .init(r: 71, g: 159, b: 248))
    // Orange
    public static let orangeBright: ChartColor = .init(color: Color(hexString: "#FF782C"))
    public static let orangeDark: ChartColor = .init(color: Color(hexString: "#EC2301"))
    
    public static let legendColor: ChartColor = .init(color: Color(hexString: "#E8E7EA"))
    public static let indicatorKnob: ChartColor = .init(color: Color(hexString: "#FF57A6"))
    
    public init(color: T, isPlump: Bool = false) {
        self.value = color
        self.isPlump = isPlump
    }
    
    
    /// retur a plump ChartColor
    public func plump() -> Self {
        return ChartColor(color: self.value, isPlump: true)
    }
    
    /// generate colors with a base color.
    /// - Parameters:
    ///   - color: the color to begin with.
    ///   - count: the number of generated colors.
    ///   - gap: the gap value between adjacent colors.
    public static func generateColors(with color: T, count: Int, gap: Double = 1 / 6) -> [ChartColor<T>] {
        guard -1...1 ~= gap else { return [] }
        var colors: [ChartColor<T>] = []
        let hue: Double = Double(color.hsbaComponents.hue)
        let opacity: Double = Double(color.hsbaComponents.opacity)
        for i in 0..<count {
            let hue: Double = hue + Double(i) * gap
            colors.append(ChartColor(color: .init(hue: (hue + 1000000).truncatingRemainder(dividingBy: 1),
                                                  saturation: 0.87,
                                                  lightness: 0.57,
                                                  opacity: opacity)))
        }
        return colors
    }
    
    static func plump<Content: Shape>(@ViewBuilder content: @escaping () -> Content) -> some View {
        content()
            .overlay(
                content()
                    .fill(LinearGradient(colors: [.init(.sRGB, white: 0, opacity: 0.2),
                                                  .init(.sRGB, white: 1, opacity: 0.2)],
                                         startPoint: .bottom,
                                         endPoint: .top))
            )
    }
    
    static func plump<Content: Shape, S>(fill: S,
                                         @ViewBuilder content: @escaping () -> Content) -> some View  where S: ShapeStyle {
        content()
            .fill(fill) // <-- different here
            .overlay(
                content()
                    .fill(LinearGradient(colors: [
                        .init(.sRGB, white: 0, opacity: 0.2),
                        .init(.sRGB, white: 1, opacity: 0.2)
                    ],
                                         startPoint: .bottom,
                                         endPoint: .top))
            )
    }
}


struct ChartColor_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                let colors = ChartColor.generateColors(with: .init(r: 71, g: 159, b: 248), count: 5)
                ForEach(colors, id:\.self) { color in
                    ChartColor.plump(fill: color.value) {
                        RoundedRectangle(cornerRadius: 12)
                    }
                    //                    .foregroundColor(color)
                    .frame(width: 100, height: 100, alignment: .center)
                    //                        .background(RoundedRectangle(cornerRadius: 12).fill(.white).shadow(color: .gray, radius: 5, x: 0, y: 0))
                }
            }
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(ChartColor.primary.value)
                    .frame(width: 100, height: 100, alignment: .center)
            }
        }
    }
}
