//
//  File.swift
//  
//
//  Created by Chocoford on 2021/12/27.
//

import Foundation
import SwiftUI
import Combine

/// [](https://jaredsinclair.com/2020/05/07/swiftui-cheat-sheet.html)
public class ChartOptions: ObservableObject, Equatable {
    public static func == (lhs: ChartOptions, rhs: ChartOptions) -> Bool {
        lhs.dataset == rhs.dataset &&
        lhs.axes == rhs.axes &&
        lhs.coordinateLine == rhs.coordinateLine
    }
    
    public class DatasetOptions: ObservableObject, Equatable {
        public static func == (lhs: ChartOptions.DatasetOptions, rhs: ChartOptions.DatasetOptions) -> Bool {
            lhs.showValue == rhs.showValue
        }
        
        @Published public var showValue: Bool
        var valueHeight: CGFloat = 16
        
        public static var automatic = DatasetOptions(showValue: false)
        
        public init (showValue: Bool = false) {
            self.showValue = showValue
        }
    }
    public class AxesOptions: ObservableObject, Equatable {
        public static func == (lhs: ChartOptions.AxesOptions, rhs: ChartOptions.AxesOptions) -> Bool {
            lhs.x == rhs.x && lhs.y == rhs.y
        }
        
        public static var automatic = AxesOptions(x: .automatic, y: .automatic)
        public static var hidden = AxesOptions(x: .hidden, y: .hidden)
        
        public class Options: ObservableObject, Equatable {
            public static func == (lhs: ChartOptions.AxesOptions.Options, rhs: ChartOptions.AxesOptions.Options) -> Bool {
                lhs.max == rhs.max &&
                lhs.min == rhs.min &&
                lhs.showValue == rhs.showValue &&
                lhs.valuePadding == rhs.valuePadding &&
                lhs.showAxes == rhs.showAxes &&
                lhs.axesWidth == rhs.axesWidth &&
                lhs.axesColor == rhs.axesColor
            }
            
            public static var automatic = Options()
            public static var hidden = Options(showValue: false, showAxes: false, axesWidth: 0.5, axesColor: .primary)
            
            // value
            @Published public var max: Double?
            @Published public var min: Double?
            @Published public var showValue: Bool
            @Published public var valuePadding: CGFloat
            
            // axes
            @Published public var showAxes: Bool
            @Published public var axesWidth: CGFloat
            @Published public var axesColor: Color
            
            public init(max: Double? = nil, min: Double? = nil, showValue: Bool = true, valuePadding: CGFloat = 6, showAxes: Bool = true, axesWidth: CGFloat = 0.5, axesColor: Color = .primary) {
                self.max = max
                self.min = min
                self.showValue = showValue
                self.valuePadding = valuePadding
                self.showAxes = showAxes
                self.axesWidth = axesWidth
                self.axesColor = axesColor
            }
            
        }
        
        @Published public var x: Options
        @Published public var y: Options
        
        var xCancellable: AnyCancellable? = nil
        var yCancellable: AnyCancellable? = nil
        
        public init(x: Options = .hidden, y: Options = .hidden) {
            self.x = x
            self.y = y
            initCancellable()
        }
        
        func initCancellable() {
            xCancellable = x.objectWillChange.sink { [weak self] (_) in
                self?.objectWillChange.send()
            }
            yCancellable = y.objectWillChange.sink { [weak self] (_) in
                self?.objectWillChange.send()
            }
        }
    }
    public class CoordinateLineOptions: ObservableObject, Equatable {
        public static func == (lhs: ChartOptions.CoordinateLineOptions, rhs: ChartOptions.CoordinateLineOptions) -> Bool {
            lhs.number == rhs.number &&
            lhs.lineType == rhs.lineType &&
            lhs.lineColor == rhs.lineColor &&
            lhs.lineWidth == rhs.lineWidth
        }
        
        public enum LineType {
            case solid, dash, dot
        }
        
        public static var automatic = CoordinateLineOptions()
        
        @Published public var number: Int
        @Published public var lineType: LineType
        @Published public var lineColor: Color
        @Published public var lineWidth: CGFloat
        
        init(number: Int=5, lineType: LineType = .dash, lineColor: Color = .primary, lineWidth: CGFloat = 0.5) {
            self.number = number
            self.lineType = lineType
            self.lineColor = lineColor
            self.lineWidth = lineWidth
        }
    }
    
    public static var automatic = ChartOptions(dataset: .automatic, axes: .automatic, coordinateLine: .automatic)
    
    @Published public var dataset: DatasetOptions
    @Published public var axes: AxesOptions
    @Published public var coordinateLine: CoordinateLineOptions?
    
    var datasetCancellable: AnyCancellable? = nil
    var axesCancellable: AnyCancellable? = nil
    var coordinateLineCancellable: AnyCancellable? = nil
    
    public init(dataset: DatasetOptions = .automatic, axes: AxesOptions = .hidden, coordinateLine: CoordinateLineOptions? = nil) {
        self.dataset = dataset
        self.axes = axes
        self.coordinateLine = coordinateLine
        
        initCancellable()
    }
    
    /// nested Observable object.
    /// https://stackoverflow.com/questions/58406287/how-to-tell-swiftui-views-to-bind-to-nested-observableobjects
    func initCancellable() {
        datasetCancellable = dataset.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        axesCancellable = axes.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        coordinateLineCancellable = coordinateLine?.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
    }
}
