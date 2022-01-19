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
    
    @State private var showIndicator: Bool = false
    @State private var touchLocation: CGPoint = .zero
    @State private var showFull: Bool = false
    @State private var showBackground: Bool = true

    
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
    
    /// Path of line graph
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
                if self.showFull && self.showBackground {
                    lineBackgroundView()
                }
                self.linePathView()
                if self.showIndicator {
                    IndicatorPoint()
                        .position(self.getClosestPointOnPath(touchLocation: self.touchLocation))
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
            .gesture(DragGesture()
                        .onChanged({ value in
                self.touchLocation = value.location
                self.showIndicator = true
                self.getClosestDataPoint(point: self.getClosestPointOnPath(touchLocation: value.location))
//                self.chartValue.interactionInProgress = true
            })
                        .onEnded({ value in
                self.touchLocation = .zero
                self.showIndicator = false
//                self.chartValue.interactionInProgress = false
            })
            )
        }
    }
}

extension LineView {
    
    /// Calculate point closest to where the user touched
    /// - Parameter touchLocation: location in view where touched
    /// - Returns: `CGPoint` of data point on chart
    private func getClosestPointOnPath(touchLocation: CGPoint) -> CGPoint {
        let closest = self.path.point(to: touchLocation.x)
        return closest
    }
    
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
            .fill(lineData.backgroundColor)
            .rotationEffect(.degrees(180), anchor: .center)
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            .opacity(0.2)
            .transition(.opacity.animation(.easeIn(duration: 1.6)))
    }
    
    /// Get the view representing the line stroked in the `foregroundColor`
    ///
    /// TODO: Explain how `showFull` works
    /// TODO: explain rotations
    /// - Returns: SwiftUI `View`
    private func linePathView() -> some View {
        self.path
            .trim(from: 0, to: self.showFull ? 1:0)
            .stroke(lineData.borderColor, lineWidth: lineData.borderWidth)
            .rotationEffect(.degrees(180), anchor: .center)
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    self.showFull = true
                }
            }
            .onDisappear {
                self.showFull = false
            }
            .drawingGroup()
    }
}

struct LineView_Previews: PreviewProvider {
    static var data: ChartData = .init()
    static var test: String = "123"
    static var previews: some View {
//        Group {
//            LineView(lineData: data, globalDataCount: 50)
//                .environmentObject(ChartOptions.automatic)
        Text(data.data.description)
            .onAppear {
                test = "12345"
                Task {
                    let d = (await getAvgVideoTimeByDateAPI()).suffix(50)
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
