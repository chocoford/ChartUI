import SwiftUI

public struct BarChart: View {
    @EnvironmentObject public var chartDataset: ChartDataset
    @EnvironmentObject public var options: ChartOptions
    @State private var touchedBarsGroupIndex: Int? = nil
    
    
    enum Constant {
        static let spacing: CGFloat = 16.0
    }
    
    /// need explicit init
    public init() {
        
    }
    

    /// The content and behavior of the `BarChartRow`.
    ///
    /// Shows each `BarChartCell` in an `HStack`; may be scaled up if it's the one currently being touched.
    /// Not using a drawing group for optimizing animation.
    /// As touched (dragged) the `touchLocation` is updated and the current value is highlighted.
    public var body: some View {
        GeometryReader { chartGeometry in
            ZStack(alignment: .top) {
                ChartContainerView { geometry, maxValue in
                    let spacing: CGFloat = (geometry.size.width) / CGFloat(chartDataset.labels.count * 3)
                    HStack(alignment: .bottom, spacing: spacing) {
                        ForEach(Array(chartDataset.labels.enumerated()), id: \.0) { (dataIndex, _) in
                            /// Value relative to maximum value
                            HStack(alignment: .bottom, spacing: spacing / 5) {
                                ForEach(Array(chartDataset.data.enumerated()), id: \.1.id) { (datasetIndex, dataset) in
                                    /// leave those `nodata` alone
                                    if dataIndex < dataset.data.count {
                                        let dataValue = dataset.data[dataIndex] ?? 0.0
                                        let normalizedValue: Double = dataValue / Double(maxValue)
                                        ZStack(alignment: .bottom) {
                                            BarChartCell(value: normalizedValue,
                                                         index: dataIndex,
                                                         backgroundColor: dataset.backgroundColor,
                                                         borderColor: dataset.borderColor,
                                                         borderWdith: dataset.borderWidth,
                                                         //                                                     touchLocation: -1,
                                                         showDelay: Double(datasetIndex) * 0.2)
                                                .opacity(self.touchedBarsGroupIndex == nil ? 1 : self.touchedBarsGroupIndex == dataIndex ? 1 : 0.6)
//                                                .animation(.default, value: self.touchedBarsGroupIndex)
                                            // TODO: 不是很完美的解决方案
                                            if options.dataset.showValue {
                                                GeometryReader { geometry in
                                                    let offset: CGFloat = CGFloat(1 - normalizedValue) * geometry.size.height
                                                    VStack(spacing: 0) {
                                                        Spacer().frame(height: offset - 16)
                                                        Text(String(dataValue))
                                                            .font(.footnote)
                                                            .fixedSize()
                                                            .animation(Animation.spring(), value: offset)
                                                            .transition(.opacity)
                                                    }.frame(width: geometry.size.width)
                                                }
                                            }
                                        }
                                        //                                .scaleEffect(getScaleSize(touchLocation: self.touchLocation, index: dataIndex), anchor: .bottom)
                                        .animation(Animation.easeInOut(duration: 0.2), value: chartDataset.labels)
                                    } else {
                                        BarChartCell(value: 0, backgroundColor: Color.clear, borderColor: Color.clear, borderWdith: 0)
                                    }
                                }
                            }
                            .onHover { hover in
                                if hover {
                                    self.touchedBarsGroupIndex = dataIndex
                                }
                            }
                        }
                    }
                    .padding(.horizontal, spacing / 2)
                    #if os(iOS)
                    .gesture(DragGesture()
                                .onChanged({ value in
                        let containerWidth: CGFloat = geometry.size.width
                        let elementWidth: CGFloat = containerWidth / CGFloat(chartDataset.labels.count)
                        self.touchedBarsGroupIndex = Int(value.location.x / elementWidth)
                    })
                                .onEnded({ value in
                        withAnimation {
                            self.touchedBarsGroupIndex = nil
                        }
                    })
                    )
                    #endif
                    .onHover { hover in
                        if !hover {
                            withAnimation {
                                self.touchedBarsGroupIndex = nil
                            }
                            
                        }
                    }
                }
                /// Value Indicator
                if let index = touchedBarsGroupIndex {
                    VStack(alignment: .leading) {
                        Text(chartDataset.labels[index])
                            .font(.title)
                            .bold()
                        ForEach(chartDataset.data) { dataset in
                            HStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 4).fill(dataset.backgroundColor)
                                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(dataset.borderColor))
                                    .frame(width: 10, height: 10, alignment: .center)
                                Text("\(dataset.label) : \(dataset.data[index]!.description)")
                                    .font(.body)
                            }
                        }
                        
                        
                    }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white)
                                .shadow(color: .gray, radius: 4, x: 0, y: 0)
                        )
                        .transition(.opacity.animation(.default))
                        .offset(x: 0, y: 0.1 * chartGeometry.size.height)
                }
            }
        }
    }
    
    
    /// Size to scale the touch indicator
    /// - Parameters:
    ///   - touchLocation: fraction of width where touch is happening
    ///   - index: index into data array
    /// - Returns: a scale larger than 1.0 if in bounds; 1.0 (unscaled) if not in bounds
    func getScaleSize(touchLocation: CGFloat, index: Int) -> CGSize {
        if touchLocation > CGFloat(index) / CGFloat(chartDataset.data.count) &&
            touchLocation < CGFloat(index+1) / CGFloat(chartDataset.data.count) {
            return CGSize(width: 1.4, height: 1.1)
        }
        return CGSize(width: 1, height: 1)
    }
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
struct Barchart_Previews: PreviewProvider {
    @ObservedObject static var data: ChartDataset = .init(labels: [String](), data: [])

    static var options: ChartOptions = .init(dataset: .init(showValue: false), axes: .automatic, coordinateLine: .automatic)
    static var previews: some View {
        VStack {
            BarChart()
                .environmentObject(data)
                .environmentObject(options)
                .onAppear {
                    Task {
                        let data = (await getAvgVideoTimeByDateAPI()).suffix(50)
                        self.data.labels = data.map({$0._id})
                        self.data.data = [ChartData(data: data.map({Double($0.count)}), label: "1",
                                                    backgroundColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.2),
                                                    borderColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.8))]
                    }
                }
            Button {
                for i in 0..<data.data.count {
                    var newData: [Double] = []
                    for _ in 0..<data.data[i].data.count {
                        newData.append(Double.random(in: 0...100))
                    }
                    withAnimation {
                        data.data[i].data = .init(newData)
                    }
                    
                }
            } label: {
                Text("随机数据")
            }
            HStack {
                Button {
                    options.axes = .automatic
                } label: {
                    Text("显示坐标(值)")
                }
                Button {
                    options.axes = .hidden
                } label: {
                    Text("隐藏坐标(值)")
                }
                Button {
                    options.axes.x.showValue = true
                    options.axes.y.showValue = true
                } label: {
                    Text("显示坐标值")
                }
                Button {
                    options.axes.x.showValue = false
                    options.axes.y.showValue = false
                } label: {
                    Text("隐藏坐标值")
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
        .frame(width: nil, height: nil, alignment: .center)
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
