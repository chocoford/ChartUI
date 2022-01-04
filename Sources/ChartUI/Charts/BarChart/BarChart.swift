import SwiftUI

public struct BarChart: View {
    public var chartDataset: ChartDataset
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
            let spacing = (geometry.size.width - Constant.spacing) / CGFloat(chartDataset.labels.count * 3)
            HStack(alignment: .bottom,
                   spacing: spacing) {
                // FIXME: 这里ForEach会导致数据更新页面不更新
//                ForEach(0..<chartDataset.labels.count, id: \.self) { index in
//                    HStack {
//                        ForEach(chartDataset.data, id: \.id) { dataset in
                ForEach(chartDataset.data.first!.data.map({$0 ?? 0.0}), id: \.self) { data in
                    let normalizedValue = (data ) / Double(maxValue)
                        BarChartCell(value: normalizedValue,
                                     index: 0,
                                     backgroundColor: chartDataset.data.first!.backgroundColor,
                                     borderColor: chartDataset.data.first!.borderColor,
                                     borderWdith: chartDataset.data.first!.borderWidth,
                                     touchLocation: self.touchLocation)
                        //                                       .scaleEffect(getScaleSize(touchLocation: self.touchLocation, index: index), anchor: .bottom)
                            .animation(Animation.easeIn(duration: 0.2), value: chartDataset)
                }
                            /// Value relative to maximum value
//                            let normalizedValue = (dataset.data[index] ?? 0.0) / Double(maxValue)
//                                BarChartCell(value: normalizedValue,
//                                             index: index,
//                                             backgroundColor: dataset.backgroundColor,
//                                             borderColor: dataset.borderColor,
//                                             borderWdith: dataset.borderWidth,
//                                             touchLocation: self.touchLocation)
//                                //                                       .scaleEffect(getScaleSize(touchLocation: self.touchLocation, index: index), anchor: .bottom)
//                                    .animation(Animation.easeIn(duration: 0.2), value: chartDataset)

//                        }
//                    }
//                }
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
    static var previews: some View {
        BarChart(chartDataset: .init(labels: [""],
                             data: [
                                .init(data: [1, 3.0, 5, 10],
                                      label: "data 1",
                                      backgroundColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.2),
                                      borderColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.8)),
                                .init(data: [4, 5.0, 2, 15],
                                      label: "data 2",
                                      backgroundColor: .init(.sRGB, red: 0, green: 1, blue: 0, opacity: 0.2),
                                      borderColor: .init(.sRGB, red: 0, green: 1, blue: 0, opacity: 0.8))
                             ]
                            )
        )
            .environmentObject(ChartOptions.automatic)
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
