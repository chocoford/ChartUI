import SwiftUI

/// One slice of a `PieChartRow`
struct PieSlice: Identifiable {
    var id = UUID()
    var startDeg: Double
    var endDeg: Double
    var value: Double
}

/// A single row of data, a view in a `PieChart`
public struct PieChartCell: View {
    @State private var show: Bool = false
    var startDegree: Double
	var endDegree: Double

    var index: Int
    var backgroundColor: ChartColor<Color>
    var borderColor: ChartColor<Color>
    
    public var body: some View {
        GeometryReader { geometry in
            let width: CGFloat = geometry.size.width
            let height: CGFloat = geometry.size.height
            let center: CGPoint = .init(x: width / 2, y: height / 2)
            let path = Path { path in
                path.addArc(
                    center: center,
                    radius: width < height ? width / 2 : height / 2,
                    startAngle: Angle(degrees: self.startDegree),
                    endAngle: Angle(degrees: self.endDegree),
                    clockwise: false)
                path.addLine(to: center)
                path.closeSubpath()
            }
            
            path
//                .if(backgroundColor.isPlump, transform: { _ in
//                    ChartColor.plump(fill: backgroundColor.value) {
//                        path
//                    }
//                }, falseTransform: { _ in
//                    path.fill(backgroundColor.value)
//                })
                .fill(backgroundColor.value)
                .overlay(path.stroke(borderColor.value,
                                     lineWidth: (startDegree == 0 && endDegree == 0 ? 0 : 1)))
                .scaleEffect(self.show ? 1 : 0)
                .animation(Animation.spring().delay(Double(self.index) * 0.04), value: show)
                .onAppear {
                    self.show = true
                }
        }
    }
}

struct PieChartCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GeometryReader { geometry in
                PieChartCell(
//                    currentTouchedIndex: .constant(nil),
                    startDegree: 00.0,
                    endDegree: 90.0,
                    index: 0,
                    backgroundColor: ChartColor(color: .red).plump(),
                    borderColor: ChartColor(color: .green))
                }.frame(width: 200, height: 200)
            
            GeometryReader { geometry in
            PieChartCell(
//                currentTouchedIndex: .constant(nil),
                startDegree: 0.0,
                endDegree: 90.0,
                index: 0,
                backgroundColor: ChartColor(color: .green),
                borderColor:  ChartColor(color: .red))
            }.frame(width: 100, height: 100)
            
            GeometryReader { geometry in
            PieChartCell(
//                currentTouchedIndex: .constant(nil),
                startDegree: 100.0,
                endDegree: 135.0,
                index: 0,
                backgroundColor: ChartColor(color: .black),
                borderColor: ChartColor(color: .black))
            }.frame(width: 100, height: 100)
            
            GeometryReader { geometry in
            PieChartCell(
//                currentTouchedIndex: .constant(nil),
                startDegree: 185.0,
                endDegree: 290.0,
                index: 1,
                backgroundColor: ChartColor(color: .purple),
                borderColor: ChartColor(color: .purple))
            }.frame(width: 100, height: 100)
            
            GeometryReader { geometry in
            PieChartCell(
//                currentTouchedIndex: .constant(nil),
                startDegree: 0,
                endDegree: 0,
                index: 0,
                backgroundColor: ChartColor(color: .purple),
                borderColor: ChartColor(color: .purple))
            }.frame(width: 100, height: 100)
            
        }.previewLayout(.fixed(width: 300, height: 300))
    }
}
