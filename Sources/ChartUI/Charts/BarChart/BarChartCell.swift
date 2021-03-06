import SwiftUI

/// A single vertical bar in a `BarChart`
public struct BarChartCell<SBG: ShapeStyle, SBR: ShapeStyle>: View {
    var value: Double
    var index: Int = 0
    var backgroundColor: ChartColor<SBG>
    var borderColor: ChartColor<SBR>
    var borderWdith: CGFloat
    var showDelay: Double
    @EnvironmentObject public var options: ChartOptions

    @State private var firstDisplay: Bool = true
    @State private var hover: Bool = false
    
    ///
    /// - Parameters:
    ///   - value: the heiht ratio of the this bar
    ///   - index: index, for animation
    ///   - gradientColor: bar color
    ///   - touchLocation: torch location
    public init(value: Double,
                index: Int = 0,
                backgroundColor: ChartColor<SBG>,
                borderColor: ChartColor<SBR>,
                borderWdith: CGFloat,
                showDelay: Double = 0) {
        self.value = value
        self.index = index
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWdith = borderWdith
        self.showDelay = showDelay
    }

    public var body: some View {
        let bar = RoundedRectangle(cornerRadius: 4)
        GeometryReader { geometry in
            VStack {
                Spacer(minLength: 0)
                bar
                    .fill(with: backgroundColor)
                    .overlay(bar.stroke(borderColor.value, lineWidth: borderWdith))
                    .frame(height: CGFloat(self.firstDisplay ? 0.0 : self.value) * geometry.size.height)
                    .onAppear {
                        self.firstDisplay = false
                    }
                    .onDisappear {
                        self.firstDisplay = true
                    }
                    .animation(Animation.spring().delay(Double(self.index) * 0.04 + showDelay), value: firstDisplay)
                    .animation(Animation.spring(), value: value)
                    .animation(Animation.easeIn, value: options.axes)
                    .onHover { hover in
                        self.hover = hover
                    }
                }   
        }
    }
        
}

struct BarChartCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Group {
                BarChartCell(value: 0.6,
                             backgroundColor: ChartColor(color: .red).plump(),
                             borderColor: ChartColor(color: .red), borderWdith: 1)
                
                BarChartCell(value: 0.2, backgroundColor: ChartColor(color: .red),
                             borderColor: ChartColor(color: .red), borderWdith: 1)
//                BarChartCell(value: 1, gradientColor: ColorGradient.whiteBlack, touchLocation: CGFloat())
//                BarChartCell(value: 1, gradientColor: ColorGradient(.purple), touchLocation: CGFloat())
            }

//            Group {
//                BarChartCell(value: 1, gradientColor: ColorGradient.greenRed, touchLocation: CGFloat())
//                BarChartCell(value: 1, gradientColor: ColorGradient.whiteBlack, touchLocation: CGFloat())
//                BarChartCell(value: 1, gradientColor: ColorGradient(.purple), touchLocation: CGFloat())
//            }.environment(\.colorScheme, .dark)
        }
        .environmentObject(ChartOptions())
    }
}
