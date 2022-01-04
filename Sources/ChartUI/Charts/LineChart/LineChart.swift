import SwiftUI

/// A single line of data, a view in a `LineChart`
public struct LineChart: View {
    @State private var frame: CGRect = .zero
    public var chartDataset: ChartDataset
    
    @State private var showIndicator: Bool = false
    @State private var touchLocation: CGPoint = .zero
    @State private var showFull: Bool = false
    @State private var showBackground: Bool = true
    var curvedLines: Bool = false

    /// The content and behavior of the `Line`.
    /// Draw the background if showing the full line (?) and the `showBackground` option is set. Above that draw the line, and then the data indicator if the graph is currently being touched.
    /// On appear, set the frame so that the data graph metrics can be calculated. On a drag (touch) gesture, highlight the closest touched data point.
    /// TODO: explain rotation
    public var body: some View {
        ChartContainerView(data: chartDataset) { geometry, maxValue in
            ZStack {
                ForEach(chartDataset.data) { data in
                    LineView(lineData: data)
                }
            }
        }
    }
}


struct LineChart_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LineChart(chartDataset:  .init(labels: [""], data: [.init(data: [1, 4.0, 5, 10],
                                                                                label: "data 1",
                                                                                backgroundColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.2),
                                                                                borderColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.8)),
                                                                          .init(data: [4, 5.0, 2, 15],
                                                                                label: "data 2",
                                                                                backgroundColor: .init(.sRGB, red: 0, green: 1, blue: 0, opacity: 0.2),
                                                                                borderColor: .init(.sRGB, red: 0, green: 1, blue: 0, opacity: 0.8))]))
                .environmentObject(ChartOptions.automatic)
            LineChart(chartDataset:  .init(labels: [""], data: [.init(data: [1, 3.0, 5, 10],
                                                                             label: "data 1",
                                                                             backgroundColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.2),
                                                                             borderColor: .init(.sRGB, red: 1, green: 0, blue: 0, opacity: 0.8)),
                                                                       .init(data: [4, 5.0, 2, 15],
                                                                             label: "data 2",
                                                                             backgroundColor: .init(.sRGB, red: 0, green: 1, blue: 0, opacity: 0.2),
                                                                             borderColor: .init(.sRGB, red: 0, green: 1, blue: 0, opacity: 0.8))]))
                .environmentObject(ChartOptions.automatic)
        }
    }
}

/// Predefined style, black over white, for preview
private let blackLineStyle = ChartStyle(backgroundColor: ColorGradient(.white), foregroundColor: ColorGradient(.black))

/// Predefined stylem red over white, for preview
private let redLineStyle = ChartStyle(backgroundColor: .whiteBlack, foregroundColor: ColorGradient(.red))
