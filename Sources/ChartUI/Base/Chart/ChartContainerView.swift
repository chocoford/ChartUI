//
//  SwiftUIView.swift
//  
//
//  Created by Chocoford on 2021/12/28.
//

import SwiftUI

struct ChartContainerView<Content: View>: View {

    @ObservedObject public var chartDataset: ChartDataset
    @EnvironmentObject var options: ChartOptions
    @State private var touchLocation: CGFloat = -1.0
    
    private let chartView: (_ geometry: GeometryProxy, _ maxValue: CGFloat) -> Content
    
    /// make max value awalys at a interger
    var maxValue: Double {
        guard let max = chartDataset.data.flatMap({$0.data}).map({$0 ?? 0}).max() else {
            return 1
        }
        
        func getMaxValue(divideNum: Int) -> Double {
            // FIXME: 小数的算法
            if max < Double(divideNum) {
                return ceil(max)
            }
            return ceil(max / Double(divideNum)) * Double(divideNum)
        }
        
        return max != 0 ? self.options.coordinateLine == nil ? max : getMaxValue(divideNum: self.options.coordinateLine!.number) : 1
    }

    public init (data: ChartDataset,
                 @ViewBuilder chartView: @escaping (_ geometry: GeometryProxy, _ maxValue: CGFloat) -> Content) {
        chartDataset = data
        self.chartView = chartView
    }
    
    var body: some View {
//        ZStack {
            GeometryReader { geometry in
                CoordinatesContainerView(geometry: geometry,
                                         maxValue: maxValue,
                                         labels: chartDataset.labels) {
                    ZStack {
                        // MARK: Coordinate Line
                        if options.coordinateLine != nil {
                            CoordinatesLineView()
                        }
                        if chartDataset.data.count > 0 && chartDataset.data.first?.data.count ?? 0 > 0 {
                            chartView(geometry, maxValue)
                        }
                    }
                }
            }
            .padding(.top, 6)
            
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
        ChartContainerView(data: .init()
                           ) { geometry, maxValue  in
            Rectangle().foregroundColor(.yellow)
        }
                           .environmentObject(ChartOptions.automatic)
    }
}
