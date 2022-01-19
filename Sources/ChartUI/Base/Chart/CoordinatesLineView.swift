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
    @Binding var overflow: CGFloat
    
    init(overflow: Binding<CGFloat> = .constant(6), coordinateLineNumber: Int) {
        self._overflow = overflow
        self.coordinateLineNumber = coordinateLineNumber
    }
    
    var yLineNum: Int {
        if options.coordinateLine!.number != nil {
            return options.coordinateLine!.number!
        } else {
            return coordinateLineNumber
        }
    }
    
    var body: some View {
        GeometryReader { chartGeometry in
            ForEach(0..<yLineNum, id: \.self) { i in
                let y = chartGeometry.size.height / CGFloat(yLineNum) * CGFloat(i)
                Path { path in
                    path.move(to: .init(x: -overflow , y: y))
                    path.addLine(to: .init(x: chartGeometry.size.width/* + overflow */, y: y))
                }
                .stroke(options.coordinateLine!.lineColor,
                        style: .init(lineWidth: options.coordinateLine!.lineWidth,
                                     lineCap: .round,
                                     dash: options.coordinateLine!.lineType == .dash ? [5] : []))
            }
        }
    }
}

struct CoordinatesLineView_Previews: PreviewProvider {
    static var previews: some View {
        CoordinatesLineView(overflow: .constant(6), coordinateLineNumber: 10)
            .environmentObject(ChartOptions.automatic)
    }
}
