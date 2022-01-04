import SwiftUI
import Combine

public class ChartData: ObservableObject, Equatable, Identifiable {
    public static func == (lhs: ChartData, rhs: ChartData) -> Bool {
        return lhs.data.map{$0} == rhs.data.map{$0}
    }
    
//    public var id: ObjectIdentifier
    public var id: String
    @Published public var label: String
    @Published public var data: [Double?] = []
    // TODO: support Gradient or even ShapeStyle
    @Published public var backgroundColor: Color
    @Published public var borderColor: Color
    @Published public var borderWidth: CGFloat

    public init(id: String = UUID().uuidString, data: [Double?], label: String, backgroundColor: Color = .clear, borderColor: Color = .clear, borderWidth: CGFloat = 1.0) {
        self.id = id
        self.label = label
        self.data = data
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }

    public init() {
        self.id = UUID().uuidString
        self.data = []
        self.label = ""
        self.backgroundColor = Color.clear
        self.borderColor = Color.clear
        self.borderWidth = 1.0
    }
}

/// An observable wrapper for an array of data for use in any chart
///
// FIXME: Do not know how to make `ChartDataset`'s data can apply either `Color` or `Gradient`.
public class ChartDataset: ObservableObject, Equatable  {
    public static func == (lhs: ChartDataset, rhs: ChartDataset) -> Bool {
        return lhs.data == rhs.data
    }
    
    @Published public var data: [ChartData] = []
    
    /// must be equal length with `data`
    @Published public var labels: [String] = []

	/// Initialize with data array
	/// - Parameter data: Array of `Double`
    public init(labels: [String], data: [ChartData]) {
        /// all `data` length must be equal to each ohter's
        /// allow `data` of `ChartData` to be `nil`
        /// allow `labels`'s length to be not eaual to `data`'s
        if data.map{$0.data.count}.filter({$0 == data.first?.data.count ?? 0}).count == data.count {
            self.labels = labels
            let dataCount = data.first?.data.count ?? 0
            if dataCount > labels.count {
                self.labels.append(contentsOf: Array(repeating: "", count: dataCount - labels.count))
            } else {
                self.labels = Array(labels.prefix(upTo: dataCount))
            }
            self.data = data
        } else {
            print("The length of ChartDataset's labels must be equal to data's")
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
    
    
    ///https://stackoverflow.com/questions/66884390/swiftui-combine-nested-observed-objects
    func initCancellable() {
        dataCancellables = data.map { data in
            data.objectWillChange.sink { [weak self] in
                guard let self = self else { return }
                self.objectWillChange.send()
            }
        }
    }
}
