//
//  SwiftUIView.swift
//  
//
//  Created by Chocoford on 2021/12/28.
//

import SwiftUI

struct ChartContainerView<Content: View>: View {

    @EnvironmentObject var chartDataset: ChartDataset
    @EnvironmentObject var options: ChartOptions
    
    private let chartView: (_ geometry: GeometryProxy, _ maxValue: CGFloat) -> Content
    
    var alignToValue: Bool
    
    var gap: Double {
        guard let max = chartDataset.data.flatMap({$0.data}).map({$0 ?? 0}).max() else {
            return 0.1
        }
        return getGapValue(than: max, base: options.axes.y.dividedBases)
    }
    
    /// make max value awalys at a interger
    var maxValue: Double {
        guard let max = chartDataset.data.flatMap({$0.data}).map({$0 ?? 0}).max() else {
            return 1
        }
        if abs(max) != 0 {
            if self.options.coordinateLine == nil {
                return max
            } else {
                let maxValue = (ceil((max) / Double(gap))) * Double(gap)
                if options.dataset.showValue && (max > maxValue * 0.95) {
                    return (ceil((max) / Double(gap)) + 1) * Double(gap)
                } else {
                    return (ceil((max) / Double(gap))) * Double(gap)
                }
            }
        } else {
            return 1
        }
    }

    public init (alignToValue: Bool = false,
        @ViewBuilder chartView: @escaping (_ geometry: GeometryProxy, _ maxValue: CGFloat) -> Content) {
        self.alignToValue = alignToValue
        self.chartView = chartView
    }
    
    var body: some View {
        let coordinateLineNum: Int = Int(maxValue / gap)
//        ZStack {
            GeometryReader { geometry in
                CoordinatesContainerView(geometry: geometry,
                                         maxValue: maxValue,
                                         yAxesValueNum: coordinateLineNum,
                                         alignToLine: alignToValue) {
                    ZStack {
                        // MARK: Coordinate Line
                        if options.coordinateLine != nil {
                            CoordinatesLineView(coordinateLineNumber: coordinateLineNum, alignToLabel: alignToValue)
                        }
                        if chartDataset.data.count > 0 && chartDataset.data.first?.data.count ?? 0 > 0 {
                            chartView(geometry, maxValue)
                        }
                    }
                }
            }
            .padding(.top, 6)
            .environmentObject(chartDataset)
//            if chartData.values.count == 0 {
//                GeometryReader { geometry in
//                    HStack {
//                        Spacer()
//                        VStack {
//                            Spacer()
//                            LoadingView()
//                            Spacer()
//                        }
//                        Spacer()
//                    }
//                }.background(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.2, opacity: 0.8))
//            }
//        }
    }
}

struct ChartContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ChartContainerView { geometry, maxValue  in
            Rectangle().foregroundColor(.yellow)
        }
        .environmentObject(ChartOptions.automatic)
        .environmentObject(ChartDataset())
        .frame(width: nil, height: 500, alignment: .center)
    }
}
