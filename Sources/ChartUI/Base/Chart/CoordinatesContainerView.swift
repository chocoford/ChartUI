//
//  SwiftUIView.swift
//  
//
//  Created by Chocoford on 2021/12/28.
//

import SwiftUI

struct CoordinatesContainerView<Content: View>: View {
    @EnvironmentObject public var options: ChartOptions
    
    // every time these propertis changed, view should redrawn.
    var geometry: GeometryProxy
    var maxValue: Double
    var yAxesValueNum: Int
    var labels: [String]
    
    var yAxesWidth: CGFloat {
        let baseWidth: CGFloat = 30
        if maxValue <= 100 {
            return baseWidth
        }
        var maxValueDigit = 0, mv = maxValue
        while mv > 100 {
            mv /= 10
            maxValueDigit += 1
        }
        
            return options.axes.y.showValue ? baseWidth + CGFloat(maxValueDigit * 8) : 10
    }
    private let content: Content
    
    // for animation
    @State private var showYValue: Bool = false
    
    init(geometry: GeometryProxy,
         maxValue: Double,
         yAxesValueNum: Int,
         labels: [String],
         @ViewBuilder content: () -> Content) {
        self.geometry = geometry
        self.maxValue = maxValue
        self.yAxesValueNum = yAxesValueNum
        self.labels = labels
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            if let xOptions = options.axes.x {
                VStack(spacing: 0) {
                    if let yOptions = options.axes.y {
                        HStack(spacing: 0) {
                            yAxesView(yOptions)
                            content
                        }
                    } else {
                        content
                    }
                    xAxesView(xOptions)
                }
            } else if let yOptions = options.axes.y {
                HStack(spacing: 0) {
                    yAxesView(yOptions)
                    content
                }
            } else {
                content
            }
        }
//        .onAppear {
//            self.show = true
//        }
//        .onDisappear {
//            self.show = false
//        }
    }
    func yAxesView(_ options: ChartOptions.AxesOptions.Options) -> some View {
        GeometryReader { yGeometry in
            if options.showValue {
                ZStack(alignment: .trailing) {
                    VStack(alignment: .trailing, spacing: 0) {
                        let num = self.options.coordinateLine?.number ?? yAxesValueNum
                        ForEach(0..<num) { i in
                            let value: Double = maxValue / Double(num) * Double(num - i)
                            Text(maxValue > 1 ? String(Int(value)) : String(format: "%.1f", value))
                                .offset(x: 0, y: -7)
                                .frame(height: yGeometry.size.height / CGFloat(num), alignment: .top)
                                .animation(.easeInOut(duration: 0.2), value: maxValue)
                                .animation(.spring().delay(Double(i) * 0.04), value: showYValue)
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
                .onAppear {
                    withAnimation {
                        showYValue = true
                    }
                    
                }
                .onDisappear {
                    withAnimation {
                    showYValue = false
                    }
                }
            }
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
        /// animate when show/hide axesValue
//        .animation(.easeInOut, value: yAxesWidth)
    }
    
    
    func xAxesView(_ options: ChartOptions.AxesOptions.Options) -> some View {
        let axesLength: CGFloat = geometry.size.width - yAxesWidth
        let maxLabelLength: CGFloat = CGFloat(labels.map({$0.count}).max() ?? 0) * 8
        let labelFrameWidth: CGFloat = axesLength / CGFloat(labels.count)
        // TODO: Need a more delegant way to determine whether to rotate.
        let needRotation: Bool = maxLabelLength / labelFrameWidth > 1
        /// for now, only supply 30 degree and 60 degree rotation
        var rotationAngle: Angle {
            if maxLabelLength / labelFrameWidth < 2 {
                return Angle(degrees: -30)
            } else {
                return Angle(degrees: -60)
            }
        }
        
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
                    ForEach(Array(labels.enumerated()), id: \.0) { (i, label) in
                        if needRotation {
                            Text(label)
                                .fixedSize()
                                .rotationEffect(rotationAngle, anchor: .trailing)
                                .padding(.trailing, labelFrameWidth / 3)
                                .frame(width: labelFrameWidth,
                                       height: maxLabelLength * CGFloat(sin(abs(rotationAngle.radians))),
                                       alignment: .topTrailing)
                                .animation(.easeInOut(duration: 0.2), value: labels)
                                .animation(Animation.spring().delay(Double(i) * 0.04), value: options.showValue)
                        } else {
                            Text(label)
                                .frame(width: labelFrameWidth)
                                .animation(.easeInOut(duration: 0.2), value: labels)
                                .animation(Animation.spring().delay(Double(i) * 0.04), value: options.showValue)
                        }
                    }
                }
            }
        }.padding(.leading, yAxesWidth)
            .padding(.top, 6)
            .font(.footnote)
    }
    
}

struct CoordinatesContainerView_Previews: PreviewProvider {
    @State static var labels: [String] = Array.init(repeating: "2021-01-01", count: 22)
    static var previews: some View {
        VStack {
            GeometryReader { geometry in
                CoordinatesContainerView(geometry: geometry,
                                         maxValue: 1000000000,
                                         yAxesValueNum: 10,
                                         labels: labels) {
                    GeometryReader { g in
                        HStack{
                            
                        }
                    }
                }
                                         .environmentObject(ChartOptions(axes: .init(x: .init(showAxes: true),
                                                                                     y: .automatic),
                                                                         coordinateLine: .init(number: 5, lineType: .dash, lineColor: .gray, lineWidth: 0.2)))
//                                         .onAppear {
//                                             Task {
//                                                 let data = (await getAvgVideoTimeByDateAPI()).prefix(50)
//                                                 labels = data.map({$0._id})
//                                             }
//                                         }
            }
            Button{
                labels.append("string")
            } label: {
                Text("add label")
            }
        }
        
    }
}
