//
//  SwiftUIView.swift
//  
//
//  Created by Chocoford on 2021/12/28.
//

import SwiftUI
import WrappingHStack

enum LabelsIterateWay {
    case dataset
    case data
}
struct CoordinatesContainerView<Content: View>: View {
    @EnvironmentObject public var options: ChartOptions
    @EnvironmentObject public var dataset: ChartDataset
    
    // every time these propertis changed, view should redrawn.
//    @State private var geometry: GeometryProxy? = nil
    var maxValue: Double
    var minValue: Double
    var yAxesValueNum: Int
    var alignToLine: Bool
    
    var labelsIterateWay: LabelsIterateWay
    
    
    var yAxesWidth: CGFloat {
        if !options.axes.y.showAxes && !options.axes.y.showValue {
            return 0
        }
        let absMax: Double = [abs(maxValue), abs(minValue)].max()!
        
        let baseWidth: CGFloat = 30
        if absMax <= 100 {
            return baseWidth
        }
        var maxValueDigit = 0, mv = absMax
        while mv > 100 {
            mv /= 10
            maxValueDigit += 1
        }
        
        return options.axes.y.showValue ? baseWidth + CGFloat(maxValueDigit * 8) : 10
    }
    private let content: Content
    
    
    // for animation
    @State private var showYValue: Bool = false
    
    init(//geometry: GeometryProxy,
         maxValue: Double,
         minValue: Double,
         yAxesValueNum: Int,
         alignToLine: Bool = true,
         labelsIterateWay: LabelsIterateWay,
         @ViewBuilder content: () -> Content) {
//        self.geometry = geometry
        self.maxValue = maxValue
        self.minValue = minValue
        self.yAxesValueNum = yAxesValueNum
        self.alignToLine = alignToLine
        self.labelsIterateWay = labelsIterateWay
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // TODO: redundancy labels alignment
                /// data labels
                GeometryReader { labelsGeometry in
                    HStack {
                        switch labelsIterateWay {
                        case .dataset:
                            ForEach(Array(dataset.data.enumerated()), id: \.0) { (index, data) in
                                ChartDataLabelView(label: data.label,
                                                   backgroundColor: data.backgroundColor.value,
                                                   borderColor: data.borderColor.value,
                                                   disabled: .constant(false))
                                    .onTapGesture {
                                        
                                    }
                            }
                        case .data:
                            /// only for first dataset's colors.
                            ForEach(Array(dataset.labels.enumerated()), id: \.0) { (index, label) in
                                ChartDataLabelView(label: label,
                                                   backgroundColor: dataset.data.first?.backgroundColor(at: index).value ?? .clear,
                                                   borderColor: dataset.data.first?.backgroundColor(at: index).value ?? .clear,
                                                   disabled: .constant(false))
                                    .onTapGesture {
                                        
                                    }
                            }
                        }
                    }
                }.frame(height: 20, alignment: .center)
                
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
                            xAxesView(xOptions, in: geometry)
                        }
                    } else if let yOptions = options.axes.y {
                        HStack(spacing: 0) {
                            yAxesView(yOptions)
                            content
                        }
                    } else {
                        content
                    }
                }//.layoutPriority(1)
            }
//            .onAppear {
//                self.geometry = geometry
//            }
//            .onChange(of: geometry.frame(in: .global)) { val in
//                self.geometry = geometry
//            }
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
            let span: Double = maxValue - minValue
            let absMax: Double = [abs(maxValue), abs(minValue)].max()!
            if options.showValue {
                ZStack(alignment: .trailing) {
                    VStack(alignment: .trailing, spacing: 0) {
                        let num = self.options.coordinateLine?.y.number ?? yAxesValueNum
                        /// must has `id` here.
                        ForEach(0..<num, id: \.self) { i in
                            let value: Double = minValue + span / Double(num) * Double(num - i)
                            Text(absMax > 1 ? String(Int(value)) : String(format: "%.1f", value))
                                .offset(x: 0, y: -7)
                                .frame(height: yGeometry.size.height / CGFloat(num), alignment: .top)
                                .animation(.easeInOut(duration: 0.2), value: maxValue)
                                .animation(.spring().delay(Double(i) * 0.04), value: showYValue)
                        }
                    }
                    VStack(alignment: .trailing){
                        Spacer()
                        HStack() {
                            Text(absMax > 1 ? String(Int(minValue)) : String(format: "%.1f", minValue)).offset(x: 0, y: 7)
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
    
    
    func xAxesView(_ options: ChartOptions.AxesOptions.Options, in geometry: GeometryProxy) -> some View {
        let axesLength: CGFloat = geometry.size.width - yAxesWidth
        let actualLabelLength: CGFloat = CGFloat(dataset.labels.map({$0.count}).max() ?? 0) * 8
        let labelFrameWidth: CGFloat = axesLength / CGFloat(alignToLine ? dataset.labels.count - 1 : dataset.labels.count)
        /// same as x Line in `CoordinatesLineView`
        let minLabelFrameWidth: CGFloat = 20
        // TODO: Need a more delegant way to determine whether to rotate.
        let needRotation: Bool = actualLabelLength / labelFrameWidth > 1
        /// for now, only supply 30 degree and 60 degree rotation
        var rotationAngle: Angle {
            if actualLabelLength / labelFrameWidth < 2 {
                return Angle(degrees: -30)
            } else {
                return Angle(degrees: -60)
            }
        }
        
        func renderLabel(content: String, width: CGFloat, index: Int) -> some View {
            VStack() {
                if needRotation {
                    Text(content)
                        .fixedSize()
                        .rotationEffect(rotationAngle, anchor: .trailing)
                        .padding(.trailing, width / 3)
                        .frame(width: width,
                               height: actualLabelLength * CGFloat(sin(abs(rotationAngle.radians))),
                               alignment: .topTrailing)
                        .animation(.easeInOut(duration: 0.2), value: dataset.labels)
                        .animation(Animation.spring().delay(Double(index) * 0.04), value: options.showValue)
                } else {
                    Text(content)
                        .frame(width: width)
                        .animation(.easeInOut(duration: 0.2), value: dataset.labels)
                        .animation(Animation.spring().delay(Double(index) * 0.04), value: options.showValue)
                }
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
            if dataset.labels.count > 0 && options.showValue {
                let capacity: CGFloat = ceil(minLabelFrameWidth / labelFrameWidth)
                if alignToLine, let firstLabel = dataset.labels.first {
                    VStack(alignment: .leading) {
                        renderLabel(content: firstLabel, width: labelFrameWidth * capacity, index: 0)
                            .offset(x: -0.5 * labelFrameWidth * capacity, y: 0)
                    }
                    .frame(width: axesLength, height: nil, alignment: .leading)
                }
                HStack(spacing: 0) {
                    ForEach(Array((alignToLine ? Array(dataset.labels.dropFirst()) : dataset.labels).enumerated()),
                            id: \.0) { (i, label) in
                        let ii = alignToLine ? i + 1 : i
                        if ii % Int(capacity) == 0 {
                            renderLabel(content: label, width: labelFrameWidth * capacity, index: ii)
                                .if(alignToLine, transform: { view in
                                    view
                                        .offset(x: 0.5 * labelFrameWidth * capacity, y: 0)
                                })
                        }
                    }
                }
//                .border(.red)
            }
        }.padding(.leading, yAxesWidth)
            .padding(.top, 6)
            .font(.footnote)
    }
    
}

struct CoordinatesContainerView_Previews: PreviewProvider {
    @State static var labels: [String] = {
        var result: [String] = []
        for i in 0..<22 {
            result.append(String(format: "2021-01-%.2i", i))
        }
        return result
    }()
    static var previews: some View {
        VStack {
            GeometryReader { geometry in
                CoordinatesContainerView(//geometry: geometry,
                                         maxValue: 35,
                                         minValue: -100,
                                         yAxesValueNum: 10,
                                         labelsIterateWay: .data) {
                    GeometryReader { g in
                        HStack{
                            
                        }
                    }
                }
                                         .environmentObject(ChartOptions(axes: .init(x: .init(showAxes: true),
                                                                                     y: .automatic),
                                                                         coordinateLine: .hidden))
                                         .environmentObject(ChartDataset(labels: labels,
                                                                         data: [
                                                                            ChartData(data: [1, 2],
                                                                                      label: "1",
                                                                                      backgroundColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.2),
                                                                                      borderColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.8))
                                                                         ]))
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
        .frame(width: nil, height: 700, alignment: .center)
        .padding()
    }
}
