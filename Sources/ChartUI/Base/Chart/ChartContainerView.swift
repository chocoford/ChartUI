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
    
    private let chartView: (_ geometry: GeometryProxy, _ maxValue: CGFloat, _ minValue: CGFloat) -> Content
    
    var alignToValue: Bool
    var lebelsIterateWay: LabelsIterateWay
    
    var gap: Double {
        let values: [Double] = chartDataset.data.flatMap({$0.data}).compactMap({$0})
        guard let max = values.max(),
              let min = values.min() else {
            return 0.1
        }
        let than: Double = max.sign == min.sign ? [abs(max), abs(min)].max()! : (abs(max) + abs(min))
        return getGapValue(than: than, base: options.axes.y.dividedBases)
    }
    
    /// make max value awalys at a interger
    var maxValue: Double {
        let values: [Double] = chartDataset.data.flatMap({$0.data}).compactMap({$0})
        guard values.count > 0 else {
            return 1
        }
        let max: Double = values.max() ?? 1
        if max != 0 {
            if max < 0 && options.axes.y.startAtZero {
                return 0
            }
            
            if self.options.coordinateLine == nil || max <= 0 {
                return max
            } else {
                /// max > 0
                let gapNum: Double = ceil(max / Double(gap))
                let maxValue = gapNum * Double(gap)
                if options.dataset.showValue && (max > maxValue * 0.95) {
                    return (gapNum + 1) * Double(gap)
                } else {
                    return maxValue
                }
            }
        } else {
            return 1
        }
    }

    var minValue: Double {
        let values: [Double] = chartDataset.data.flatMap({$0.data}).compactMap({$0})
        guard values.count > 0 else {
            return 1
        }
        let min: Double = values.min() ?? 0
        if min != 0 {
            if min > 0 && options.axes.y.startAtZero {
                return 0
            }
            /// if not showing coordinate line or `min` greater than 0, it is no need to make change of `min`
            if self.options.coordinateLine == nil || min >= 0 {
                return min
            } else {
                /// min < 0
                let gapNum: Double = ceil(abs(min) / gap)
                let minValue = -1 * gapNum * Double(gap)
                if options.dataset.showValue && (min < minValue * 0.95) {
                    return -1 * (gapNum + 1) * Double(gap)
                } else {
                    return minValue
                }
            }
        } else {
            return 0
        }
    }
    
    public init (alignToValue: Bool = false,
                 lebelsIterateWay: LabelsIterateWay = .dataset,
        @ViewBuilder chartView: @escaping (_ geometry: GeometryProxy, _ maxValue: CGFloat, _ minValue: CGFloat) -> Content) {
        self.alignToValue = alignToValue
        self.lebelsIterateWay = lebelsIterateWay
        self.chartView = chartView
    }
    
    var body: some View {
        let coordinateLineNum: Int = Int((abs(maxValue) + abs(minValue)) / gap)
        
        GeometryReader { geometry in
            CoordinatesContainerView(geometry: geometry,
                                     maxValue: maxValue,
                                     minValue: minValue,
                                     yAxesValueNum: coordinateLineNum,
                                     alignToLine: alignToValue,
                                     labelsIterateWay: self.lebelsIterateWay) {
                ZStack {
                    // MARK: Coordinate Line
                    if options.coordinateLine != nil {
                        CoordinatesLineView(coordinateLineNumber: coordinateLineNum, alignToLabel: alignToValue)
                    }
                    if chartDataset.data.count > 0 && chartDataset.data.first?.data.count ?? 0 > 0 {
                        chartView(geometry, maxValue, minValue)
                    }
//                    Text(gap.description)
                }
            }
        }
        .padding(.top, 6)
    }
}

struct ChartContainerView_Previews: PreviewProvider {
    @ObservedObject static var data: ChartDataset = .init(labels: [String](), data: [])
    static var previews: some View {
        ChartContainerView { geometry, maxValue, minValue  in
            Rectangle().foregroundColor(.clear).border(.red)
        }
        .environmentObject(ChartOptions.automatic)
        .environmentObject(data)
        .frame(width: nil, height: 500, alignment: .center)
        .onAppear {
            Task {
                let data = (await getAvgVideoTimeByDateAPI()).suffix(7)
                self.data.labels = data.map({$0._id})
                self.data.data = [ChartData(data: data.map({Double($0.count)}).map({$0 - 10000}), label: "1",
                                            backgroundColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.2),
                                            borderColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.8))]
            }
        }
    }
}
