import SwiftUI

public struct BarChart: View {
    @ObservedObject public var chartDataset: ChartDataset
    @EnvironmentObject public var options: ChartOptions
    @State private var touchLocation: CGFloat = -1.0
    
    
    enum Constant {
        static let spacing: CGFloat = 16.0
    }
    
    public init(chartDataset: ChartDataset) {
        self.chartDataset = chartDataset
    }
    
    /// The content and behavior of the `BarChartRow`.
    ///
    /// Shows each `BarChartCell` in an `HStack`; may be scaled up if it's the one currently being touched.
    /// Not using a drawing group for optimizing animation.
    /// As touched (dragged) the `touchLocation` is updated and the current value is highlighted.
    public var body: some View {
        ChartContainerView(data: chartDataset) { geometry, maxValue in
            let spacing: CGFloat = (geometry.size.width) / CGFloat(chartDataset.labels.count * 3)
            HStack(alignment: .bottom, spacing: spacing) {
                // FIXME: 这里ForEach会导致数据更新页面不更新
                ForEach(Array(chartDataset.labels.enumerated()), id: \.0) { (index, _) in
                    /// Value relative to maximum value
                    ForEach(chartDataset.data) { dataset in
                        /// leave those `nodata` alone
                        if index < dataset.data.count {
                            let normalizedValue = (dataset.data[index] ?? 0.0) / Double(maxValue)
                            BarChartCell(value: normalizedValue,
                                         index: index,
                                         backgroundColor: dataset.backgroundColor,
                                         borderColor: dataset.borderColor,
                                         borderWdith: dataset.borderWidth,
                                         touchLocation: self.touchLocation)
                            //                                       .scaleEffect(getScaleSize(touchLocation: self.touchLocation, index: index), anchor: .bottom)
                                .animation(Animation.easeIn(duration: 0.2), value: chartDataset)
                        } else {
                            BarChartCell(value: 0, backgroundColor: Color.clear, borderColor: Color.clear, borderWdith: 0, touchLocation: 0)
                        }
                    }
                }
            }
                   .padding(.horizontal, spacing / 2)
                   .gesture(DragGesture()
                                .onChanged({ value in
                       let width = geometry.frame(in: .local).width
                       self.touchLocation = value.location.x/width
                       //                    if let currentValue = self.getCurrentValue(width: width) {
                       //                        self.chartValue.currentValue = currentValue
                       //                        self.chartValue.interactionInProgress = true
                       //                    }
                   })
                                .onEnded({ value in
                       //                    self.chartValue.interactionInProgress = false
                       self.touchLocation = -1
                   })
                   )
        }
    }
    
    
    /// Size to scale the touch indicator
    /// - Parameters:
    ///   - touchLocation: fraction of width where touch is happening
    ///   - index: index into data array
    /// - Returns: a scale larger than 1.0 if in bounds; 1.0 (unscaled) if not in bounds
    //    func getScaleSize(touchLocation: CGFloat, index: Int) -> CGSize {
    //        if touchLocation > CGFloat(index)/CGFloat(chartData.data.count) &&
    //            touchLocation < CGFloat(index+1)/CGFloat(chartData.data.count) {
    //            return CGSize(width: 1.4, height: 1.1)
    //        }
    //        return CGSize(width: 1, height: 1)
    //    }
    //
    /// Get data value where touch happened
    /// - Parameter width: width of chart
    /// - Returns: value as `Double` if chart has data
    //    func getCurrentValue(width: CGFloat) -> Double? {
    //        guard self.chartData.data.count > 0 else { return nil}
    //        let index = max(0,min(self.chartData.data.count-1,Int(floor((self.touchLocation*width)/(width/CGFloat(self.chartData.data.count))))))
    //        return self.chartData.values[index]
    //    }
}
struct MyPreviewProvider_Previews: PreviewProvider {
    @ObservedObject static var data: ChartDataset = .init(labels: [String](), data: [
        .init(data: [1, 3.0, 5, 10],
                                 label: "data 1",
                                 backgroundColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.2),
                                 borderColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.8))
    ])

    static var options: ChartOptions = .automatic
    static var previews: some View {
        VStack {
            BarChart(chartDataset: data)
                .environmentObject(ChartOptions.automatic)
            Button {
                var newData: [Double] = []
                for _ in 0..<data.data[0].data.count {
                    newData.append(Double.random(in: 0...10))
                }
                data.data[0].data = .init(newData)
            } label: {
                Text("随机数据")
            }
            HStack {
                Button {
                    options.axes = .automatic
                } label: {
                    Text("显示坐标")
                }
                Button {
                    options.axes = .hidden
                } label: {
                    Text("隐藏坐标")
                }
            }
            HStack {
                Button {
                    data.data[0].data.append(Double.random(in: 0..<10))
                } label: {
                    Text("添加数据")
                }
                Button {
                    data.data[0].data.removeLast()
                } label: {
                    Text("减少数据")
                }
            }
            HStack {
                Button {
                    data.labels.append(Int.random(in: 0..<10).description)
                } label: {
                    Text("添加标签")
                }
                Button {
                    data.labels.removeLast()
                } label: {
                    Text("减少标签")
                }
            }
        }
    }
}






//protocol BarChartStyle {
//    static var automatic: DefaultButtonStyle { get }
//
//    associatedtype Body : View
//    typealias Configuration = BarChart.ChartStyleConfiguration
//    func makeBody(configuration: Self.Configuration) -> Self.Body
//}
//
///// Style
//extension BarChart {
//    struct ChartStyleConfiguration {
//        struct Label: View {
//            typealias Body = <#type#>
//
//        }
//
//        let label: Label
//    }
//
//    func barChartStyle<S>(_ style: S) -> some View where S : BarChartStyle {
//        return style.makeBody(configuration: ChartStyleConfiguration())
//    }
//
//    struct DefaultChartStyle: BarChartStyle {
//        static var automatic: DefaultButtonStyle = DefaultChartStyle().makeBody(configuration: .init())
//
//        init () {}
//
//        func makeBody(configuration: BarChartStyle.Configuration) -> some View {
//            return configuration.label.padding()
//        }
//    }
//}
