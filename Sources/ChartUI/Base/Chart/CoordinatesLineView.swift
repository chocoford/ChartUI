//
//  SwiftUIView.swift
//  
//
//  Created by Chocoford on 2021/12/29.
//

import SwiftUI

struct CoordinatesLineView: View {
    var coordinateLineNumber: Int
    @EnvironmentObject var options: ChartOptions
    @EnvironmentObject var dataset: ChartDataset
    @Binding var overflow: CGFloat
    
    init(overflow: Binding<CGFloat> = .constant(6), coordinateLineNumber: Int) {
        self._overflow = overflow
        self.coordinateLineNumber = coordinateLineNumber
    }
    
    var yLineNum: Int {
        if options.coordinateLine!.y.number != nil {
            return options.coordinateLine!.y.number!
        } else {
            return coordinateLineNumber
        }
    }
    
    var body: some View {
        GeometryReader { chartGeometry in
            ZStack {
                /// y
                ForEach(0..<yLineNum, id: \.self) { i in
                    let y = chartGeometry.size.height / CGFloat(yLineNum) * CGFloat(i)
                    Path { path in
                        path.move(to: .init(x: -overflow , y: y))
                        path.addLine(to: .init(x: chartGeometry.size.width/* + overflow */, y: y))
                    }
                    .stroke(options.coordinateLine!.y.lineColor,
                            style: .init(lineWidth: options.coordinateLine!.y.lineWidth,
                                         lineCap: .round,
                                         dash: options.coordinateLine!.y.lineType == .dash ? [5] : []))
                }
                
                /// x
                let labelFrameWidth: CGFloat = chartGeometry.size.width / CGFloat(dataset.labels.count)
                /// same as x Line in `CoordinatesContainerView`
                let minLabelFrameWidth: CGFloat = 20
                /// 1 if minLabelFrameWidth less than labelFrameWidth
                let capacity: Int = Int(ceil(minLabelFrameWidth / labelFrameWidth))
                ForEach(Array(dataset.labels.enumerated()), id: \.0) { (i, _) in
                    let x: CGFloat = CGFloat(i) * labelFrameWidth
                    if i % capacity == 0 {
                        Path { path in
                            path.move(to: .init(x: x, y: 0))
                            path.addLine(to: .init(x: x, y: chartGeometry.size.height + overflow))
                        }
                        .stroke(options.coordinateLine!.x.lineColor,
                                style: .init(lineWidth: options.coordinateLine!.x.lineWidth,
                                             lineCap: .round,
                                             dash: options.coordinateLine!.x.lineType == .dash ? [5] : []))
                    }
                }
            }
        }
    }
}

struct CoordinatesLineView_Previews: PreviewProvider {
    static var previews: some View {
        CoordinatesLineView(overflow: .constant(6), coordinateLineNumber: 10)
            .environmentObject(ChartOptions.automatic)
            .environmentObject(ChartDataset.init())
    }
}
