import SwiftUI

public struct LineChart: AnyChart {
    @EnvironmentObject var chartDataset: ChartDataset
    
    @State private var showIndicator: Bool = false
    @State private var touchLocation: CGPoint = .zero
    @State private var showFull: Bool = false
    @State private var showBackground: Bool = true
    var curvedLines: Bool
    
    @State private var chartContainerWidth: CGFloat? = nil
    @State private var touchedLocationX: CGFloat? = nil
    
    public init(curvedLines: Bool = false) {
        self.curvedLines = curvedLines
    }
    
    public var body: some View {
        GeometryReader { chartGeometry in
            ZStack(alignment: .top) {
                ChartContainerView(alignToValue: true) { geometry, maxValue, minValue in
                    ZStack {
                        ForEach(chartDataset.data) { data in
                            renderLineView(data, maxValue: maxValue, minValue: minValue)
                        }
                        Text(touchedLocationX?.description ?? "")
                    }
                    
                    // FIXME: pass width to value show view. But it is ugly
                    .onAppear(perform: {
                        self.chartContainerWidth = geometry.size.width
                    })
                    .onChange(of: geometry.size.width, perform: { newValue in
                        self.chartContainerWidth = newValue
                    })
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                self.touchedLocationX = value.location.x
                            })
                            .onEnded({ value in
                                withAnimation {
                                    self.touchedLocationX = nil
                                }
                            })
                    )
                    // TODO: hover
                    .onHover { hover in
                        if !hover {
                            withAnimation {
                                self.touchedLocationX = nil
                            }
                        }
                    }
                }
                /// Value Indicator
                if let location = touchedLocationX, let containerWidth = chartContainerWidth {
                    let elementWidth: CGFloat = containerWidth / CGFloat(chartDataset.labels.count - 1)
                    ChartValueShowView(geometry: chartGeometry,
                                       dataIndex: Int(location / elementWidth + 0.5))
                }
            }
        }
    }
    
    func renderLineView(_ data: ChartData, maxValue: Double, minValue: Double) -> some View {
        let difference = chartDataset.labels.count - data.data.count
        if difference > 0 {
            data.data = data.data + Array<Double?>.init(repeating: nil, count: difference)
        }
        return LineView(lineData: data,
                        maxValue: maxValue,
                        minValue: minValue,
                        globalDataCount: chartDataset.labels.count,
                        touchLocation: touchedLocationX)
    }
}


struct LineChart_Previews: PreviewProvider {
    @ObservedObject static var data: ChartDataset = .init(labels: [String](), data: [
        .init(data: [1, 3.0, 5, 10],
              label: "data 1",
              backgroundColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.2),
              borderColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.8)),
        .init(data: [2, 7.0, 1, 5],
              label: "data 2",
              backgroundColor: .init(.sRGB, red: 0, green: 1, blue: 0, opacity: 0.2),
              borderColor: .init(.sRGB, red: 0, green: 1, blue: 0, opacity: 0.8)),
        .init(data: [4, 2.0, 2, 9],
              label: "data 3",
              backgroundColor: .init(.sRGB, red: 0, green: 0, blue: 1, opacity: 0.2),
              borderColor: .init(.sRGB, red: 0, green: 0, blue: 1, opacity: 0.8))
    ])

    static var options: ChartOptions = .init(dataset: .init(showValue: true), axes: .automatic, coordinateLine: .automatic)
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            VStack {
                LineChart()
                    .data(data)
                    .environmentObject(options)
                    .onAppear {
                        Task {
                            let data = (await getAvgVideoTimeByDateAPI()).suffix(7)
                            self.data.labels = data.map({$0._id})
                            self.data.data = [ChartData(data: data.map({Double($0.count) - 40000}), label: "1",
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
                        data.data[i].data = .init(newData)
                    }
                } label: {
                    Text("随机数据")
                }
            }
            .preferredColorScheme($0)
        }
    }
}
