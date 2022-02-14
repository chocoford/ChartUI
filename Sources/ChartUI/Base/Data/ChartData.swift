import SwiftUI
import Combine

public class ChartData: ObservableObject, Equatable, Identifiable {
    // TODO: extend to `ShapeStyle`
    public typealias T = Color
    
    public static func == (lhs: ChartData, rhs: ChartData) -> Bool {
        return lhs.data.map{$0} == rhs.data.map{$0}
    }
    
    public var id: String
    @Published public var label: String
    @Published public var data: [Double?]
    // TODO: support Gradient or even ShapeStyle
    public var backgroundColor: ChartColor<T> {
        backgroundColors.first ?? .init(color: .clear)
    }
    @Published public var backgroundColors: [ChartColor<T>]
    public var borderColor: ChartColor<T> {
        borderColors.first ?? .init(color: .clear)
    }
    @Published public var borderColors: [ChartColor<T>]
    @Published public var borderWidth: CGFloat
    
    /// ChartData initializer
    /// - Parameters:
    ///   - id: id
    ///   - data: the data values of chart. Can be `nil` and in this case point will not show in chart.
    ///   - label: the label of this `ChartData`.
    ///   - backgroundColor: the background color of the chart's cell.
    ///   - borderColor: the border color of the chart's cell. When it is `nil`, it will be the same color as `backgroundColor`.
    ///   - borderWidth: the border width of the chart's cell, default to 1.0
    public init(id: String = UUID().uuidString, data: [Double?], label: String, backgroundColor: T, borderColor: T? = nil, borderWidth: CGFloat = 1.0) {
        self.id = id
        self.label = label
        self.data = data
        self.backgroundColors = [.init(color: backgroundColor)]
        self.borderColors = [.init(color: borderColor ?? backgroundColor)]
        self.borderWidth = borderWidth
    }
    
    /// ChartData initializer
    /// - Parameters:
    ///   - id: id
    ///   - data: the data values of chart. Can be `nil` and in this case point will not show in chart.
    ///   - label: the label of this `ChartData`.
    ///   - backgroundColors: the background colors of the chart's cell.
    ///   - borderColors: the border colosr of the chart's cell. When it is `nil`, it will be the same color as `backgroundColor`.
    ///   - borderWidth: the border width of the chart's cell, default to 1.0
    public init(id: String = UUID().uuidString, data: [Double?], label: String, backgroundColors: [T], borderColors: [T]? = nil, borderWidth: CGFloat = 1.0) {
        self.id = id
        self.label = label
        self.data = data
        self.backgroundColors = backgroundColors.map({.init(color: $0)})
        self.borderColors = (borderColors ?? backgroundColors).map({.init(color: $0)})
        self.borderWidth = borderWidth
    }
    
    /// ChartData initializer
    /// - Parameters:
    ///   - id: id
    ///   - data: the data values of chart. Can be `nil` and in this case point will not show in chart.
    ///   - label: the label of this `ChartData`.
    ///   - backgroundColor: the background color of the chart's cell.
    ///   - borderColor: the border color of the chart's cell. When it is `nil`, it will be the same color as `backgroundColor`.
    ///   - borderWidth: the border width of the chart's cell, default to 1.0
    public init(id: String = UUID().uuidString, data: [Double?], label: String, backgroundColor: ChartColor<T>, borderColor: ChartColor<T>? = nil, borderWidth: CGFloat = 1.0) {
        self.id = id
        self.label = label
        self.data = data
        self.backgroundColors = [backgroundColor]
        self.borderColors = [borderColor ?? backgroundColor]
        self.borderWidth = borderWidth
    }
    
    /// ChartData initializer
    /// - Parameters:
    ///   - id: id
    ///   - data: the data values of chart. Can be `nil` and in this case point will not show in chart.
    ///   - label: the label of this `ChartData`.
    ///   - backgroundColors: the background colosr of the chart's cell.
    ///   - borderColors: the border colors of the chart's cell. When it is `nil`, it will be the same color as `backgroundColor`.
    ///   - borderWidth: the border width of the chart's cell, default to 1.0
    public init(id: String = UUID().uuidString, data: [Double?], label: String, backgroundColors: [ChartColor<T>], borderColors: [ChartColor<T>]? = nil, borderWidth: CGFloat = 1.0) {
        self.id = id
        self.label = label
        self.data = data
        self.backgroundColors = backgroundColors
        self.borderColors = borderColors ?? backgroundColors
        self.borderWidth = borderWidth
    }
    /// init a empty `ChartData`.
    public init() {
        self.id = UUID().uuidString
        self.label = ""
        self.data = [Double]()
        self.backgroundColors = [.init(color: .clear)]
        self.borderColors = [.init(color: .clear)]
        self.borderWidth = 1
    }
    
    public func backgroundColor(at index: Int) -> ChartColor<T> {
        if index >= backgroundColors.count {
            return backgroundColors.last ?? .init(color: .clear)
        } else {
            return backgroundColors[index]
        }
    }
    
    public func borderColor(at index: Int) -> ChartColor<T> {
        if index >= borderColors.count {
            return borderColors.last ?? .init(color: .clear)
        } else {
            return borderColors[index]
        }
    }
}
//
//extension ChartData where T == Double {
//    convenience init() {
//        self.init(id: UUID().uuidString,
//                  data: [Double](),
//                  label: "",
//                  backgroundColor: .clear,
//                  borderColor: .clear)
//    }
//}

/// An observable wrapper for an array of data for use in any chart
///
// FIXME: Do not know how to make `ChartDataset`'s data can apply either `Color` or `Gradient`.
public class ChartDataset: ObservableObject, Equatable  {
    public static func == (lhs: ChartDataset, rhs: ChartDataset) -> Bool {
        return lhs.data == rhs.data
    }
    
    @Published public var data: [ChartData] = [] {
        didSet {
            initCancellable()
        }
    }
    @Published public var labels: [String] = []

    /// Initialize with data array
    /// - Parameter labels: the labels (x-axes labels in general) of data.
    /// - Parameter data: Array of `ChartData`
    public init(labels: [String], data: [ChartData]) {
        /// all `data` length must be equal to each ohter's
        /// allow `data` of `ChartData` to be `nil`
        /// allow `labels`'s length to be not eaual to `data`'s
        /// allow `labels`'s length to be greater than `data`'s
        if data.map{$0.data.count}.filter({$0 == data.first?.data.count ?? 0}).count == data.count {
            self.labels = labels
            self.data = data
            let dataCount = data.first?.data.count ?? 0
            self.adjustLabels(count: dataCount)
        } else {
            print("[ChartUI] The length of ChartDataset's labels must be equal to data's")
            self.labels = []
            self.data = []
        }
        initCancellable()
    }


    public init() {
        self.labels = []
        self.data = []
        initCancellable()
    }
    
    private var dataCancellables = [AnyCancellable]()
    private var dataCountCancellables = [AnyCancellable]()
    
    
    ///https://stackoverflow.com/questions/66884390/swiftui-combine-nested-observed-objects
    private func initCancellable() {
        dataCancellables = data.map { data in
            data.objectWillChange.sink { [weak self] in
                guard let self = self else { return }
                self.objectWillChange.send()
            }
        }
        /// We should get the changed data's count. `data.objectWillChange.sink` cannot give us this information
        dataCountCancellables = data.map { data in
            /// inspired by https://stackoverflow.com/questions/59519530/how-does-combine-know-an-observableobject-actually-changed
            data.$data.sink {
                self.adjustLabels(count: $0.count)
            }
        }
    }
    
    /// Only adjust labels when data's count greater than labels'. Ignore the case that data's count less than labels'.
    /// - Parameter newCount: new data's count which has been changed.
    private func adjustLabels(count newCount: Int) {
        if newCount > labels.count {
            /// auto append empty string
            self.labels.append(contentsOf: Array(repeating: "", count: newCount - labels.count))
        }
    }
}
