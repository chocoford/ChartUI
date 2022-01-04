//
//  SwiftUIView.swift
//  
//
//  Created by Chocoford on 2021/12/28.
//

import SwiftUI

struct CoordinatesContainerView<Content: View>: View {
    @EnvironmentObject public var options: ChartOptions
    @Binding var geometry: GeometryProxy
    @Binding var maxValue: Double
    @Binding var labels: [String]
    
    let yAxesWidth: CGFloat = 40
    private let chartView: Content
    
    init(geometry: Binding<GeometryProxy>,
         maxValue: Binding<Double>,
         labels: Binding<[String]>,
         @ViewBuilder content: () -> Content) {
        self._geometry = geometry
        self._maxValue = maxValue
        self._labels = labels
        self.chartView = content()
    }
    
    var body: some View {
        ZStack {
            if let xOptions = options.axes.x {
                VStack(spacing: 0) {
                    if let yOptions = options.axes.y {
                        HStack(spacing: 0) {
                            yAxesView(yOptions)
                            chartView
                        }
                    } else {
                        chartView
                    }
                    xAxesView(xOptions)
                }
            } else if let yOptions = options.axes.y {
                HStack(spacing: 0) {
                    yAxesView(yOptions)
                    chartView
                }
            } else {
                chartView
            }
            
        }
    }
    func yAxesView(_ options: ChartOptions.AxesOptions.Options) -> some View {
        GeometryReader { yGeometry in
            ZStack(alignment: .trailing) {
                VStack(alignment: .trailing, spacing: 0) {
                    let num = self.options.coordinateLine?.number ?? 5
                    ForEach(0..<num) { i in
                        Text(String(format: "%.1f", maxValue / Double(num) * Double(num - i)))
                            .offset(x: 0, y: -7)
                            .frame(height: yGeometry.size.height / CGFloat(num), alignment: .top)
                    }
                }
                VStack(alignment: .trailing){
                    Spacer()
                    HStack() {
                        Text("0").offset(x: 0, y: 7)
                    }
                }
            }
            .frame(width: yGeometry.size.width - options.axesWidth)
            .padding(.trailing, options.valuePadding)
            
            /// Axes
            if options.showAxes {
                Path { path in
                    path.move(to: .init(x: yGeometry.size.width, y: 0))
                    path.addLine(to: .init(x: yGeometry.size.width, y: yGeometry.size.height))
                }.stroke(options.axesColor, lineWidth: options.axesWidth)
                    .frame(width: options.axesWidth)
                    .transition(.opacity.animation(.linear))
            }
            
        }
        .frame(width: yAxesWidth)
        .font(.footnote)
    }
    
    
    func xAxesView(_ options: ChartOptions.AxesOptions.Options) -> some View {
        let axesLength = geometry.size.width - yAxesWidth
        return ZStack(alignment: .top) {
            if options.showAxes {
                Path { path in
                    path.move(to: .init(x: 0, y: -6))
                    path.addLine(to: .init(x: axesLength, y: -6))
                }.stroke(options.axesColor, lineWidth: options.axesWidth)
                    .transition(.opacity.animation(.linear))
                    .frame(height: 1) // will not show if height < 1
            } else {
                HStack{}.frame(height: options.axesWidth)
            }
            if labels.count > 0 {
                HStack(spacing: 0) {
                    ForEach(0..<labels.count) { i in
                        Text(String(i))
                            .frame(width: axesLength / CGFloat(labels.count))
                            .font(.footnote)
                    }
                }
            }
            
        }.padding(.leading, yAxesWidth)
            .padding(.top, 6)
    }
    
}

struct CoordinatesContainerView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            CoordinatesContainerView(geometry: .constant(geometry),
                                     maxValue: .constant(100),
                                     labels: .constant(["String", "String", "String"])) {
                Circle()
            }
                                     .environmentObject(ChartOptions(axes: .init(x: .init(showAxes: true),
                                                                                 y: .automatic),
                                                                     coordinateLine: .automatic))
        }
        
    }
}
