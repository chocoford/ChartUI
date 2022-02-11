//
//  SwiftUIView.swift
//  
//
//  Created by Chocoford on 2021/12/28.
//

import SwiftUI

enum LabelsIterateWay {
    case dataset
    case data
}
struct CoordinatesContainerView<Content: View>: View {
    @EnvironmentObject public var options: ChartOptions
    @EnvironmentObject public var dataset: ChartDataset
    
    // every time these propertis changed, view should be redrawn.
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
    
    
    @State private var labelsRect: [CGRect] = []//.init(repeating: .zero, count: 12)

    // for animation
    @State private var showYValue: Bool = false
    
    
    init(maxValue: Double,
         minValue: Double,
         yAxesValueNum: Int,
         alignToLine: Bool = true,
         labelsIterateWay: LabelsIterateWay,
         @ViewBuilder content: () -> Content) {
        self.maxValue = maxValue
        self.minValue = minValue
        self.yAxesValueNum = yAxesValueNum
        self.alignToLine = alignToLine
        self.labelsIterateWay = labelsIterateWay
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                /// data labels
                ZStack(alignment: .center) {
                    var width = CGFloat.zero
                    var height = CGFloat.zero
                    let spacing: CGFloat = 4
                    
                    switch labelsIterateWay {
                    case .dataset:
                        ForEach(Array(dataset.data.enumerated()), id: \.0) { (index, data) in
                            ChartDataLabelView(viewIndex: index,
                                               label: data.label,
                                               backgroundColor: data.backgroundColor.value,
                                               borderColor: data.borderColor.value,
                                               disabled: .constant(false))
                                .onTapGesture {
                                    
                                }
                            /// https://stackoverflow.com/a/58876712/12299030
                                .alignmentGuide(HorizontalAlignment.center) { dimentions in
                                    if (abs(width - dimentions.width) > geometry.size.width) {
                                        width = 0
                                        height -= dimentions.height + spacing
                                    }
                                    let result: CGFloat = width
                                    if index >= self.dataset.data.count - 1 {
                                        width = 0 //last item
                                    } else {
                                        width -= dimentions.width + spacing
                                    }
                                    return result
                                }
                                .alignmentGuide(VerticalAlignment.center) { dimentions in
                                    let result = height
                                    if index >= self.dataset.data.count - 1 {
                                        height = 0 // last item
                                    }
                                    return result
                                }
                        }
                    case .data:
                        /// only for first dataset's colors.
                        ForEach(Array(dataset.labels.enumerated()), id: \.0) { (index, label) in
                            ChartDataLabelView(viewIndex: index,
                                               label: label,
                                               backgroundColor: dataset.data.first?.backgroundColor(at: index).value ?? .clear,
                                               borderColor: dataset.data.first?.backgroundColor(at: index).value ?? .clear,
                                               disabled: .constant(false))
                                .onTapGesture {
                                    
                                }
                            /// https://stackoverflow.com/a/58876712/12299030
                                .alignmentGuide(HorizontalAlignment.center) { dimentions in
                                    if (abs(width - dimentions.width) > geometry.size.width) {
                                        width = 0
                                        height -= dimentions.height + spacing
                                    }
                                    let result: CGFloat = width
                                    if index >= self.dataset.labels.count - 1 {
                                        width = 0 //last item
                                    } else {
                                        width -= dimentions.width + spacing
                                    }
                                    return result
                                }
                                .alignmentGuide(VerticalAlignment.center) { dimentions in
                                    let result = height
                                    if index >= self.dataset.labels.count - 1 {
                                        height = 0 // last item
                                    }
                                    return result
                                }
                        }
                    }
                }
                .frame(maxWidth: geometry.size.width, alignment: .center)
                .onPreferenceChange(ChartDataLabelViewPreferenceKey.self) { preferences in
                    switch labelsIterateWay {
                    case .dataset:
                        self.labelsRect = .init(repeating: .zero, count: dataset.data.count)
                    case .data:
                        self.labelsRect = .init(repeating: .zero, count: dataset.labels.count)
                    }
                    for p in preferences {
                        self.labelsRect[p.viewIndex] = p.bounds
                    }
                }
                
                ZStack {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            yAxesView(options.axes.y)
                            content
                        }
                        xAxesView(options.axes.x, in: geometry)
                    }
                }//x.layoutPriority(1)
            }
        }
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
                                .show(options.showValue)
                        }
                    }
                    VStack(alignment: .trailing){
                        Spacer()
                        HStack() {
                            Text(absMax > 1 ? String(Int(minValue)) : String(format: "%.1f", minValue)).offset(x: 0, y: 7)
                                .show(options.showValue)
                        }
                    }
                }
                .frame(width: yGeometry.size.width - options.axesWidth)
                .padding(.trailing, options.valuePadding)
                .transition(.opacity)
                .animation(.easeInOut, value: options)
            }
            let overflow: CGFloat = 1
            /// Axes
            Capsule()
                .fill(options.axesColor)
                .frame(width: yGeometry.size.height + overflow, height: options.axesWidth, alignment: .center)
                .rotationEffect(.degrees(90), anchor: .topLeading)
                .offset(x: yGeometry.size.width, y: 0)
                .show(options.showAxes)
        }
        .frame(width: yAxesWidth)
        .font(.footnote)
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
            let overflow: CGFloat = 0
            Capsule()
                .fill(options.axesColor)
                .frame(width: axesLength + overflow, height: options.axesWidth, alignment: .center)
                .offset(x: -overflow, y: 0)
                .show(options.showAxes)
            
            let capacity: CGFloat = ceil(minLabelFrameWidth / labelFrameWidth)
            if alignToLine, let firstLabel = dataset.labels.first {
                VStack(alignment: .leading) {
                    renderLabel(content: firstLabel, width: labelFrameWidth * capacity, index: 0)
                        .offset(x: -0.5 * labelFrameWidth * capacity, y: 0)
                }
                .padding(.top, 6)
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
            .padding(.top, 6)
            .show(dataset.labels.count > 0 && options.showValue)
        }
        .padding(.leading, yAxesWidth)
        .font(.footnote)
    }
    
}

struct CoordinatesContainerView_Previews: PreviewProvider {
    @State static var labels: [String] = {
        var result: [String] = []
        for i in 0..<5 {
            result.append(String(format: "2021-01-%.2i", i))
        }
        return result
    }()
    @State static var options: ChartOptions = .init(dataset: .init(showValue: false),
                                             axes: .automatic,
                                             coordinateLine: .automatic)
    
    static var previews: some View {
        VStack {
            GeometryReader { geometry in
                CoordinatesContainerView(maxValue: 35,
                                         minValue: -100,
                                         yAxesValueNum: 10,
                                         labelsIterateWay: .dataset)
                {
                    GeometryReader { g in
                        HStack{}
                    }
                }
                .environmentObject(options)
                .environmentObject(ChartDataset(labels: labels,
                                                data: [
                                                    ChartData(data: [1, 2],
                                                              label: "1",
                                                              backgroundColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.2),
                                                              borderColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.8)),
                                                    ChartData(data: [1, 2],
                                                              label: "2",
                                                              backgroundColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.2),
                                                              borderColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.8))
                                                ]))
                .padding(28)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.white)
                        .shadow(color: .gray, radius: 4, x: 0, y: 0)
                )
                .padding(30)
                .frame(height: 500, alignment: .center)
            }
            Button{
                labels.append("string")
            } label: {
                Text("add label")
            }
            HStack {
                Button {
                    options.axes.x.showValue = true
                    options.axes.y.showValue = true
                } label: {
                    Text("显示坐标值")
                }
                Button {
                    options.axes.x.showValue = false
                    options.axes.y.showValue = false
                } label: {
                    Text("隐藏坐标值")
                }
            }
        }
        .frame(width: nil, height: 700, alignment: .center)
        .padding()
    }
}
