import SwiftUI

/// A single line of data, a view in a `LineChart`
public struct LineChart: View {
//    @State private var frame: CGRect = .zero
    @EnvironmentObject var chartDataset: ChartDataset
    
    @State private var showIndicator: Bool = false
    @State private var touchLocation: CGPoint = .zero
    @State private var showFull: Bool = false
    @State private var showBackground: Bool = true
    var curvedLines: Bool

    
    public init(curvedLines: Bool = false) {
        self.curvedLines = curvedLines
    }
    
    public var body: some View {
        ChartContainerView(alignToValue: true) { geometry, maxValue in
            ZStack {
                ForEach(chartDataset.data) { data in
                    renderLineView(data)
                }
            }
        }
    }
    
    func renderLineView(_ data: ChartData) -> some View {
        let difference = chartDataset.labels.count - data.data.count
        if difference > 0 {
            data.data = data.data + Array<Double?>.init(repeating: nil, count: difference)
        }
        return LineView(lineData: data, globalDataCount: chartDataset.labels.count)
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
                    .environmentObject(options)
                    .environmentObject(data)
                    .onAppear {
                        Task {
                            let data = (await getAvgVideoTimeByDateAPI()).suffix(20)
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

/// Predefined style, black over white, for preview
private let blackLineStyle = ChartStyle(backgroundColor: ColorGradient(.white), foregroundColor: ColorGradient(.black))

/// Predefined stylem red over white, for preview
private let redLineStyle = ChartStyle(backgroundColor: .whiteBlack, foregroundColor: ColorGradient(.red))
