import SwiftUI

public struct BarChart: ChartView {
    @Environment(\.colorScheme) var currentMode
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
                ChartContainerView { geometry, maxValue, minValue in
                    let span: Double = (maxValue - minValue)
                    let spacing: CGFloat = (geometry.size.width) / CGFloat(chartDataset.labels.count * 3)
                    HStack(alignment: .center, spacing: spacing) {
                        ForEach(Array(chartDataset.labels.enumerated()), id: \.0) { (dataIndex, _) in
                            /// Value relative to maximum value
                            HStack(alignment: .bottom, spacing: spacing / 5) {
                                ForEach(Array(chartDataset.data.enumerated()), id: \.1.id) { (datasetIndex, dataset) in
                                    /// leave those `nodata` alone
                                    if dataIndex < dataset.data.count {
                                        let dataValue = dataset.data[dataIndex] ?? 0.0
                                        let normalizedValue: Double = dataValue / span
                                        ZStack(alignment: .bottom) {
                                            BarChartCell(value: abs(normalizedValue),
                                                         index: dataIndex,
                                                         backgroundColor: dataset.backgroundColor,
                                                         borderColor: dataset.borderColor,
                                                         borderWdith: dataset.borderWidth,
                                                         showDelay: Double(datasetIndex) * 0.2)
                                                .rotationEffect(.init(degrees: normalizedValue.sign == .minus ? 180 : 0),
                                                                anchor: .bottom)
                                                .offset(x: 0, y: minValue / span * geometry.size.height)
                                                .opacity(self.touchedBarsGroupIndex == nil ? 1 : self.touchedBarsGroupIndex == dataIndex ? 1 : 0.6)
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
                                        .animation(Animation.easeInOut(duration: 0.2), value: chartDataset.labels)
                                    } else {
                                        BarChartCell(value: 0, backgroundColor: ChartColor(color: .clear), borderColor: ChartColor(color: .clear), borderWdith: 0)
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
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                let containerWidth: CGFloat = geometry.size.width
                                let elementWidth: CGFloat = containerWidth / CGFloat(chartDataset.labels.count)
                                let index: Int = Int(value.location.x / elementWidth)
                                withAnimation(.linear(duration: 0.2)) {
                                    self.touchedBarsGroupIndex = index < chartDataset.labels.count ? (index > 0 ? index : 0) : chartDataset.labels.count - 1
                                }
                                
                            })
                            .onEnded({ value in
                                withAnimation {
                                    self.touchedBarsGroupIndex = nil
                                }
                            })
                    )
                    .onHover { hover in
                        if !hover {
                            withAnimation(.linear(duration: 0.2)) {
                                self.touchedBarsGroupIndex = nil
                            }
                            
                        }
                    }
                }

                
                /// Value Indicator
                if let index = touchedBarsGroupIndex {
                    ChartValueShowView(geometry: chartGeometry, dataIndex: index)
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
}
struct Barchart_Previews: PreviewProvider {
    @ObservedObject static var data: ChartDataset = .init(labels: [String](), data: [])

    static var options: ChartOptions = .init(dataset: .init(showValue: false),
                                             axes: .automatic,
                                             coordinateLine: .automatic)
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            VStack {
                BarChart()
                    .data(data)
                    .options(options)
                    .onAppear {
                        Task {
                            let data = (await getAvgVideoTimeByDateAPI()).suffix(20)
                            self.data.labels = data.map({$0._id})
                            self.data.data = [ChartData(data: data.map({Double($0.count) - 40000}), label: "data 1",
                                                        backgroundColor: ChartColor(color: .green).plump(),
                                                        borderColor: ChartColor(color: .clear))]
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.white)
                            .shadow(color: .gray, radius: 4, x: 0, y: 0)
                    )
                    .padding(40)
                    .frame(height: 500, alignment: .center)
                Button {
                    for i in 0..<data.data.count {
                        var newData: [Double] = []
                        for _ in 0..<data.data[i].data.count {
                            newData.append(Double.random(in: 0...100))
                        }
//                        withAnimation {
                            data.data[i].data = .init(newData)
//                        }
                    }
                } label: {
                    Text("random data")
                }
                HStack {
                    Button {
                        withAnimation {
                            options.axes = .automatic
                        }
                        
                    } label: {
                        Text("show axes(value)")
                    }
                    Button {
                        withAnimation {
                            options.axes = .hidden
                        }
                    } label: {
                        Text("hide axes(value)")
                    }
                    Button {
                        withAnimation {
                        options.axes.x.showValue = true
                        options.axes.y.showValue = true
                        }
                    } label: {
                        Text("显示坐标值")
                    }
                    Button {
                        withAnimation {
                        options.axes.x.showValue = false
                        options.axes.y.showValue = false
                        }
                    } label: {
                        Text("隐藏坐标值")
                    }
                }
                HStack {
                    Button {
                        data.data[0].data.append(Double.random(in: 0..<10))
                    } label: {
                        Text("add data")
                    }
                    Button {
                        data.data[0].data.removeLast()
                    } label: {
                        Text("remove data")
                    }
                }
                HStack {
                    Button {
                        data.labels.append(Int.random(in: 0..<10).description)
                    } label: {
                        Text("add labels")
                    }
                    Button {
                        data.labels.removeLast()
                    } label: {
                        Text("remove labels")
                    }
                }
            }
           
            
            .preferredColorScheme($0)
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
