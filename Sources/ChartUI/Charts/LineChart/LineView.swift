//
//  SwiftUIView.swift
//
//
//  Created by Chocoford on 2022/1/2.
//

import SwiftUI

/// Single line displayed in `LineCart`
struct LineView: View {
    @State private var frame: CGRect = .zero
    var lineData: ChartData
    /// The count of the largest data of all data's
    var globalDataCount: Int
    var curvedLines: Bool = true
    
    var touchLocation: CGFloat?
    
    @State private var lineShow: Bool = false
    @State private var backgroundShow: Bool = false

    
    /// Step for plotting through data
    /// For drawing quad curved path.
    /// - Returns: X and Y delta between each data point based on data and view's frame
    var step: CGFloat {
        guard lineData.data.count > 1 else {return 0}
        return frame.size.width / CGFloat(lineData.data.count - 1)
    }
    
    var heightRatio: CGFloat {
        return frame.size.height / CGFloat((lineData.data.compactMap({$0}).max() ?? 0) - (lineData.data.compactMap({$0}).min() ?? 0))
    }
    
    /// Path of line graph, point cannot include in it, otherwise `indicator` will go wrong
    /// - Returns: A path for stroking representing the data, either curved or jagged.
    var path: Path {
        return drawLine(points: lineData.data,
                        step: step,
                        valueRatio: heightRatio,
                        smooth: curvedLines,
                        close: false)
    }
    
    /// Path of linegraph, but also closed at the bottom side
    /// - Returns: A path for filling representing the data, either curved or jagged
    var closedPath: Path {
        return drawLine(points: lineData.data,
                        step: step,
                        valueRatio: heightRatio,
                        smooth: curvedLines,
                        close: true)
    }
    
    
    var poins: Path {
        return drawPoints(points: lineData.data, step: step, valueRatio: heightRatio)
    }
    
    
#if os(iOS)
    // see https://stackoverflow.com/a/62370919
    // This lets geometry be recalculated when device rotates. However it doesn't cover issue of app changing
    // from full screen to split view. Not possible in SwiftUI? Feedback submitted to apple FB8451194.
    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()
#endif
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                self.lineBackgroundView()
                self.linePathView()
                if self.touchLocation != nil {
                    IndicatorPoint()
                        .position(.init(x: self.touchLocation!,
                                        y: self.path.yValue(at: touchLocation!)))
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                }
            }
            .onAppear {
                self.frame = geometry.frame(in: .local)
            }
#if os(iOS)
            .onReceive(orientationChanged) { _ in
                // When we receive notification here, the geometry is still the old value
                // so delay evaluation to get the new frame!
                DispatchQueue.main.async {
                    self.frame = geometry.frame(in: .local)    // recalculate layout with new frame
                }
            }
#endif
        }
    }
}

extension LineView {
    
    /// Calculate point closest to where the user touched
    /// - Parameter touchLocation: location in view where touched
    /// - Returns: `CGPoint` of data point on chart
//    private func getClosestPointOnPath(touchLocation: CGFloat)-> CGPoint {
//        let closest = self.path.yValue(at: touchLocation)
//        return closest
//    }
    
    /// Figure out where closest touch point was
    /// - Parameter point: location of data point on graph, near touch location
    private func getClosestDataPoint(point: CGPoint) {
        let index = Int(round((point.x) / step))
        if (index >= 0 && index < lineData.data.count){
            //            chartValue.currentValue = chartDataset.data[0].data[index] ?? 0
        }
    }
    
    /// Get the view representing the filled in background below the chart, filled with the foreground color's gradient
    ///
    /// TODO: explain rotations
    /// - Returns: SwiftUI `View`
    private func lineBackgroundView() -> some View {
        return self.closedPath
            .fill(lineData.backgroundColor.value)
            .rotationEffect(.degrees(180), anchor: .center)
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            .opacity(backgroundShow ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: 1).delay(0.2 * Double(lineData.data.count))) {
                    self.backgroundShow = true
                }
            }
            .onDisappear {
                self.backgroundShow = false
            }
//            .transition(.opacity.animation(.easeIn.delay(0.2 * Double(lineData.data.count))))
    }
    
    /// Get the view representing the line stroked in the `foregroundColor`
    ///
    /// TODO: Explain how `showFull` works
    /// TODO: explain rotations
    /// - Returns: SwiftUI `View`
    private func linePathView() -> some View {
        ZStack {
            self.path
                .trim(from: 0, to: self.lineShow ? 1:0)
                .stroke(lineData.borderColor.value, lineWidth: lineData.borderWidth)
            
            self.poins
                .trim(from: 0, to: self.lineShow ? 1:0)
                .stroke(lineData.borderColor.value, lineWidth: lineData.borderWidth)
        }
        .rotationEffect(.degrees(180), anchor: .center)
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        .onAppear {
            withAnimation(.easeOut(duration: 0.2 * Double(lineData.data.count))) {
                self.lineShow = true
            }
        }
        .onDisappear {
            self.lineShow = false
        }
        .drawingGroup()
    }
}

struct LineView_Previews: PreviewProvider {
    static var data: ChartData = .init(data: [1, 2, 3, 5, 3, 20, 24, 50, 20, 40, 23, 24, 13, 24, 55, 16, 23, 19, 20, 21],
                                       label: "123",
                                       backgroundColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.2),
                                       borderColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.8))
    static var previews: some View {
//        Group {
            LineView(lineData: data, globalDataCount: 20)
                .environmentObject(ChartOptions.automatic)
            .onAppear {
                Task {
                    let d = (await getAvgVideoTimeByDateAPI()).suffix(20)
                    data = ChartData(data: d.map({Double($0.count)}),
                                     label: "1",
                                     backgroundColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.2),
                                     borderColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.8))
                }
            }
            
//            LineView(lineData:  .init(data: [1, 4.0, 5, 10],
//                                      label: "data 1",
//                                      backgroundColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.2),
//                                      borderColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.8)), globalDataCount: 5)
//                .environmentObject(ChartOptions.automatic)
//        }
    }
}
