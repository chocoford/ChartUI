import SwiftUI

public struct PieChart: ChartView {
    @EnvironmentObject var dataset: ChartDataset
    
    var slices: [PieSlice] {
        guard dataset.data.count > 0 else {return []}
        var tempSlices: [PieSlice] = []
        var lastEndDeg: Double = 0
        let maxValue: Double = dataset.data[0].data.compactMap({$0}).reduce(0, +)
        
        for slice in dataset.data[0].data.compactMap({$0}) {
            let normalized: Double = Double(slice) / (maxValue == 0 ? 1 : maxValue)
            let startDeg = lastEndDeg
            let endDeg = lastEndDeg + (normalized * 360)
            lastEndDeg = endDeg
            tempSlices.append(PieSlice(startDeg: startDeg, endDeg: endDeg, value: slice))
        }
        
        return tempSlices
    }
    
    @State private var currentTouchedIndex: Int? = nil
    
    public var body: some View {
        GeometryReader { chartGeometry in
            ZStack(alignment: .top) {
                ChartContainerView(lebelsIterateWay: .data) { geometry, maxValue, minValue in
                    ZStack {
                        if dataset.data.count > 0 {
                            ForEach(Array(dataset.labels.enumerated()), id:\.0) { index, _ in
                                let data: ChartData = dataset.data[0]
                                let backgroundColor: ChartColor<Color> = data.backgroundColor(at: index)
                                let borderColor: ChartColor<Color> = data.borderColor(at: index)
                                let currentTouched: Bool = currentTouchedIndex == index
                                PieChartCell(
                                    startDegree: self.slices[index].startDeg,
                                    endDegree: self.slices[index].endDeg,
                                    index: index,
                                    backgroundColor: backgroundColor,
                                    borderColor: borderColor
                                )
                                    .opacity(currentTouchedIndex == nil ? 1 : (currentTouched ? 1 : 0.7))
                                    .scaleEffect(currentTouched ? 1.1 : 1)
                                    .animation(.spring(), value: currentTouchedIndex)
                            }
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                let rect = geometry.frame(in: .local)
                                let isTouchInPie = isPointInCircle(point: value.location, circleRect: rect)
                                if isTouchInPie {
                                    let touchDegree = degree(for: value.location, inCircleRect: rect)
                                    currentTouchedIndex = slices.firstIndex(where: { $0.startDeg < touchDegree && $0.endDeg > touchDegree }) ?? -1
                                } else {
                                    currentTouchedIndex = nil
                                }
                            })
                            .onEnded({ value in
                                currentTouchedIndex = nil
                            })
                    )
                    .onHover{ hover in
                        // TODO: hover
                        if !hover {
                            currentTouchedIndex = nil
                        }
                    }
                }
                /// Value Indicator
                if let touchedIndex = currentTouchedIndex {
                    ChartValueShowView(geometry: chartGeometry,
                                       dataIndex: touchedIndex,
                                       datasetRange: 0..<1)
                }
            }
        }
    }
}

struct PieChart_Previews: PreviewProvider {
    @ObservedObject static var data: ChartDataset = .init(labels: [String](), data: [
        .init(data: [1, 3.0, 5, 10],
              label: "data 1",
              backgroundColors: [.init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.2),
                                 .init(.sRGB, red: 0.2, green: 1, blue: 0, opacity: 0.2),
                                 .init(.sRGB, red: 0, green: 0.2, blue: 1, opacity: 0.2)],
              borderColors: [.white]),
        .init(data: [2, 7.0, 1, 5],
              label: "data 2",
              backgroundColor: .init(.sRGB, red: 0, green: 1, blue: 0, opacity: 0.2),
              borderColor: .init(.sRGB, red: 0, green: 1, blue: 0, opacity: 0.8)),
        .init(data: [4, 2.0, 2, 9],
              label: "data 3",
              backgroundColor: .init(.sRGB, red: 0, green: 0, blue: 1, opacity: 0.2),
              borderColor: .init(.sRGB, red: 0, green: 0, blue: 1, opacity: 0.8))
    ])

    static var options: ChartOptions = .init(dataset: .automatic, axes: .hidden, coordinateLine: .hidden)
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            VStack {
                PieChart()
                    .environmentObject(options)
                    .environmentObject(data)
                    .onAppear {
                        Task {
                            let data = (await getAvgVideoTimeByDateAPI()).suffix(5)
                            self.data.labels = data.map({$0._id})
                            self.data.data = [ChartData(data: data.map({Double($0.count)}), label: "1",
                                                        backgroundColors: ChartColor.generateColors(with: ChartColor.primary.value, count: data.count).map({$0.plump()}),
                                                        borderColors: [ChartColor(color: .white)])]
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
